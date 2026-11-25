extends Node
## Máquina de estados e regras do atendimento (autoload "Flow").
## Controla: pedidos, investigação, desafios, preparo, entrega, pagamento e progressão.

signal state_changed(new_state: int)
signal order_changed
signal dish_changed
signal challenge_started(challenge: MathChallenge)
## Montagem: cada ingrediente solto na tigela/prato (para as animações). done = montagem completa.
signal assembly_event(ingredient_id: String, ok: bool, done: bool)
signal challenge_finished(ok: bool, message: String)
signal notice(text: String)

# Balanceamento (valores provisórios — ajustar nos testes).
const WIN_ORDERS := 10
const ORDERS_PER_DAY := 2   # pedidos concluídos para fechar o dia
const TIER2_AT := 3   # pedidos concluídos para o nível 2
const TIER3_AT := 6   # pedidos concluídos para o nível 3
const BONUS_NO_MISTAKE_PERCENT := 10.0
const PENALTY_MISTAKE_PERCENT := 5.0
const PENALTY_HINT_PERCENT := 3.0
const MAX_PENALTY_PERCENT := 40.0
const SPECIAL_BONUS_PERCENT := 30.0   # bônus do prato do dia
const UNLOCK_PUDIM_AT := 3
# ---- backlog (v20)
const PATIENCE_SEC_BY_TIER: Array[float] = [300.0, 240.0, 200.0]   # tempo até a paciência acabar
const QUEUE_PATIENCE_FACTOR := 0.5     # na fila, a paciência cai pela metade da velocidade
const QUEUE_MIN_COMPLETED := 2         # a fila começa depois de 2 pedidos concluídos
const QUEUE_CHANCE := 0.35             # chance de chegar alguém na fila a cada QUEUE_CHECK_SEC
const QUEUE_CHECK_SEC := 20.0
const PORTION_FACTORS := {"economica": 0.8, "normal": 1.0, "generosa": 1.2}
const PORTION_SATISFACTION := {"economica": -12, "normal": 0, "generosa": 8}
const PORTION_NAMES := {"economica": "Econômica", "normal": "Normal", "generosa": "Generosa"}
## Estados em que o tempo (paciência e fila) fica pausado.
const PAUSED_STATES := [GameStates.Id.MAIN_MENU, GameStates.Id.INTRO, GameStates.Id.SETTINGS,
	GameStates.Id.CREDITS, GameStates.Id.ENDING, GameStates.Id.RESULT, GameStates.Id.DAY_SUMMARY,
	GameStates.Id.NEWSPAPER]

var state: GameStates.Id = GameStates.Id.MAIN_MENU
var return_state: GameStates.Id = GameStates.Id.RESTAURANT

var order: Order = null
var adjusted: AdjustedRecipe = null
var dish: Dish = null

var current_challenge: MathChallenge = null
var challenge_context: String = ""            # "order" | "delivery" | "planning"
var challenge_queue: Array[Dictionary] = []   # {kind: "recover"|"scale", ingredient_id}
var delivery_steps_done: Dictionary = {}
var delivery_bill_cents: int = 0
var last_result: Dictionary = {}
var new_record: bool = false
var settings_return: GameStates.Id = GameStates.Id.MAIN_MENU

var _current_spec: Dictionary = {}
var _delivery_order_id: int = -1
var heat_minutes: int = 20   # timer escolhido pelo jogador na etapa com fogo
var waiting: Order = null               # cliente esperando na fila (no máximo 1: atendimento + fila)
var followup_tpl: Dictionary = {}       # segundo prato do último cliente (pedido em sequência)
var delivery_freight_cents: int = 0     # frete da entrega por telefone
var last_rent_cents: int = 0            # contas cobradas no fechamento do dia
var ending_kind: String = "vitoria"     # "vitoria" ou "falencia"
var _queue_timer: float = 0.0
var _next_order_id: int = 1
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()

## Paciência do cliente atual e da fila; chegada de clientes na fila.
func _process(delta: float) -> void:
	if state in PAUSED_STATES or not Settings.patience_enabled:
		return
	var mult := float(Game.event_effect("patience_mult", 1.0))
	if order != null and not order.is_closed() and not order.paid and order.patience > 0.0:
		var before := order.patience
		order.drain_patience(delta, mult)
		if before > 25.0 and order.patience <= 25.0:
			say("%s está ficando impaciente!" % order.customer_name)
		elif order.patience <= 0.0:
			say("%s perdeu a paciência... a gorjeta vai diminuir." % order.customer_name)
	if waiting != null and waiting.drain_patience(delta, mult * QUEUE_PATIENCE_FACTOR):
		say("%s cansou de esperar na fila e foi embora. (reputação −0,2)" % waiting.customer_name)
		Game.reputation = maxf(1.0, Game.reputation - 0.2)
		waiting = null
		order_changed.emit()
	_queue_timer += delta
	if _queue_timer >= QUEUE_CHECK_SEC:
		_queue_timer = 0.0
		_maybe_queue_customer()

func _maybe_queue_customer() -> void:
	if waiting != null or order == null or order.is_closed() or Game.orders_completed < QUEUE_MIN_COMPLETED:
		return
	var chance := float(Game.event_effect("queue_chance", QUEUE_CHANCE))
	if _rng.randf() >= chance:
		return
	var tpl := _pick_template(order.customer_name, false)
	if tpl.is_empty():
		return
	waiting = _create_order(tpl)
	say("Chegou mais um cliente: %s está esperando na fila." % waiting.customer_name)
	order_changed.emit()

func say(text: String) -> void:
	notice.emit(text)

## Nível de dificuldade dos desafios (1 a 3), conforme os pedidos concluídos.
func current_tier() -> int:
	if Game.orders_completed >= TIER3_AT:
		return 3
	if Game.orders_completed >= TIER2_AT:
		return 2
	return 1

func go(new_state: GameStates.Id) -> void:
	state = new_state
	state_changed.emit(new_state)

# ------------------------------------------------------------------ menu / intro
func start_game() -> void:
	Game.new_game()
	order = null
	adjusted = null
	dish = null
	current_challenge = null
	challenge_queue.clear()
	delivery_steps_done.clear()
	last_result = {}
	_next_order_id = 1
	waiting = null
	followup_tpl = {}
	delivery_freight_cents = 0
	ending_kind = "vitoria"
	go(GameStates.Id.INTRO)

func finish_intro() -> void:
	if state != GameStates.Id.INTRO:
		return   # evita abrir o jogo duas vezes (clique + segurar)
	Game.today_event = "normal"
	go(GameStates.Id.NEWSPAPER)   # o jornal do dia 1 apresenta o capítulo 1

func open_admin() -> void:
	go(GameStates.Id.ADMINISTRATION)

func open_book() -> void:
	if state == GameStates.Id.RECIPE_BOOK:
		return
	return_state = state
	go(GameStates.Id.RECIPE_BOOK)

func close_book() -> void:
	go(return_state)

# ---------------------------------------------------------------------- pedidos
func call_next_customer() -> bool:
	if order != null and not order.is_closed():
		say("Termine ou cancele o atendimento atual primeiro.")
		return false
	if waiting != null:
		order = waiting   # quem está na fila é atendido primeiro
		waiting = null
	else:
		# evita o mesmo personagem duas vezes seguidas (são só 7 clientes fixos)
		var tpl := _pick_template(str(last_result.get("customer", "")))
		if tpl.is_empty():
			tpl = _pick_template()
		if tpl.is_empty():
			return false
		order = _create_order(tpl)
	_queue_timer = 0.0
	adjusted = null
	dish = null
	challenge_queue.clear()
	order_changed.emit()
	go(GameStates.Id.ACTIVE_ORDER)
	return true

## exclude_customer: não repete quem já está sendo atendido; allow_phone: false para a fila do balcão.
func _pick_template(exclude_customer: String = "", allow_phone: bool = true) -> Dictionary:
	var pool: Array[Dictionary] = []
	for t in GameData.order_templates:
		if t.get("tutorial", false):
			if Game.orders_completed == 0 and exclude_customer == "":
				return t
			continue
		if str(t["customer"]) == exclude_customer or (not allow_phone and t.get("phone", false)):
			continue
		if not Game.is_recipe_unlocked(str(t["recipe_id"])):
			continue
		if int(t.get("min_completed", 0)) <= Game.orders_completed:
			pool.append(t)
	if pool.is_empty():
		return {}
	# o prato do dia aparece com o dobro de chance
	for t in pool.duplicate():
		if t["recipe_id"] == Game.daily_special:
			pool.append(t)
	return pool[_rng.randi() % pool.size()]

func _create_order(tpl: Dictionary) -> Order:
	var o := Order.new()
	o.id = _next_order_id
	_next_order_id += 1
	o.customer_name = tpl["customer"]
	o.kind = tpl["kind"]
	o.description = tpl["text"]
	o.correct_recipe_id = tpl["recipe_id"]
	o.servings = tpl["servings"]
	o.clue_ids.assign(tpl.get("clues", []))
	o.hidden_clue_ids.assign(tpl.get("hidden_clues", []))
	o.restrictions.assign(tpl.get("restrictions", []))
	for m in tpl.get("mods", []):
		o.mods.append({"ingredient_id": str(m["ingredient_id"]), "percent": int(m["percent"])})
	var recipe: Recipe = GameData.recipes[o.correct_recipe_id]
	o.base_reward_cents = recipe.price_per_serving_cents * o.servings
	o.patience_sec = PATIENCE_SEC_BY_TIER[current_tier() - 1]
	o.patience = 100.0
	if tpl.get("phone", false):
		o.channel = "telefone"
		o.address = str(tpl.get("address", ""))
		o.route = tpl.get("route", [3, 4])
	var fu: Variant = tpl.get("followup", {})
	if typeof(fu) == TYPE_DICTIONARY:
		o.followup = fu
	return o

## Segundo prato do mesmo cliente.
func _create_followup(fu: Dictionary, customer: String, channel: String) -> Order:
	# conversões explícitas: depois de salvar/carregar (JSON), os números viram float
	var tpl := {"customer": customer, "kind": int(fu.get("kind", 0)) as Order.Kind, "text": str(fu["text"]),
		"recipe_id": str(fu["recipe_id"]), "servings": int(fu["servings"]),
		"clues": fu.get("clues", []), "hidden_clues": fu.get("hidden_clues", [])}
	var o := _create_order(tpl)
	o.channel = channel
	return o

func cancel_order() -> void:
	if order == null or order.is_closed():
		return
	order.transition(Order.State.CANCELLED)
	dish = null
	adjusted = null
	challenge_queue.clear()
	order_changed.emit()
	go(GameStates.Id.RESTAURANT)
	say("Atendimento cancelado.")

# ------------------------------------------------------------------ investigação
func open_investigation() -> void:
	if order == null:
		return
	if order.state == Order.State.CREATED:
		order.transition(Order.State.INVESTIGATING)
	go(GameStates.Id.INVESTIGATION)

func reveal_hint() -> void:
	if order != null and order.state == Order.State.CREATED:
		order.transition(Order.State.INVESTIGATING)
	if order == null or order.state != Order.State.INVESTIGATING:
		return
	if order.hints_used >= order.hidden_clue_ids.size():
		say("Não há mais pistas disponíveis.")
		return
	order.hints_used += 1
	order_changed.emit()
	say("Pista extra revelada (penalidade no pagamento).")

## O jogador escolhe a receita pelo nome (no balão do cliente), depois de consultar o livro.
func choose_recipe(recipe_id: String) -> bool:
	if order != null and order.state == Order.State.CREATED:
		order.transition(Order.State.INVESTIGATING)
	return select_recipe(recipe_id)

func select_recipe(recipe_id: String) -> bool:
	if order == null or order.state != Order.State.INVESTIGATING:
		return false
	if not Game.is_recipe_unlocked(recipe_id):
		return false
	if recipe_id != order.correct_recipe_id:
		order.mistakes += 1
		say("Essa não parece ser a receita pedida. Releia as pistas e compare com o livro.")
		return false
	order.selected_recipe_id = recipe_id
	order.transition(Order.State.IDENTIFIED)
	_build_adjusted()
	order_changed.emit()
	go(GameStates.Id.ACTIVE_ORDER)
	say("Receita identificada!")
	return true

func _build_adjusted() -> void:
	var recipe: Recipe = GameData.recipes[order.selected_recipe_id]
	adjusted = AdjustedRecipe.build(recipe, order.servings, Game.recovered, order.mods, order.restrictions)
	challenge_queue.clear()
	var usable: Array[Dictionary] = []   # ingredientes que serão usados (não removidos pelo cliente)
	for line in recipe.lines:
		if order.mod_percent(line["ingredient_id"]) > -100:
			usable.append(line)
	for line in usable:
		if not Game.is_line_known(recipe, line):
			challenge_queue.append({"kind": "recover", "ingredient_id": line["ingredient_id"]})
	for line in usable:
		var ing_id: String = line["ingredient_id"]
		if order.mod_percent(ing_id) != 0:
			challenge_queue.append({"kind": "scale_mod", "ingredient_id": ing_id})
		elif order.servings != recipe.base_servings:
			challenge_queue.append({"kind": "scale", "ingredient_id": ing_id})
	# Desafios extras conforme o nível (um ingrediente sorteado da receita).
	var tier := current_tier()
	if tier >= 2:
		var pick: Dictionary = usable[_rng.randi() % usable.size()]
		challenge_queue.append({"kind": "capacity", "ingredient_id": pick["ingredient_id"]})
	if tier >= 3:
		var pick2: Dictionary = usable[_rng.randi() % usable.size()]
		challenge_queue.append({"kind": "cost", "ingredient_id": pick2["ingredient_id"]})

func is_ready_to_cook() -> bool:
	return order != null and order.state == Order.State.IDENTIFIED \
		and challenge_queue.is_empty() and adjusted != null and adjusted.is_complete()

# ----------------------------------------------------------------------- desafios
func begin_challenge(ch: MathChallenge, context: String) -> void:
	ChoiceMaker.prepare(ch, _rng)   # toda questão vira 4 alternativas (A, B, C, D)
	current_challenge = ch
	challenge_context = context
	go(GameStates.Id.MATH_CHALLENGE)
	challenge_started.emit(ch)

func next_order_challenge() -> bool:
	if challenge_queue.is_empty() or adjusted == null or order == null:
		return false
	var spec: Dictionary = challenge_queue.pop_front()
	var recipe: Recipe = GameData.recipes[adjusted.recipe_id]
	var ing_id: String = spec["ingredient_id"]
	var line := recipe.get_line(ing_id)
	var ch: MathChallenge = null
	var ing: Ingredient = GameData.ingredients[ing_id]
	match spec["kind"]:
		"recover":
			ch = GameData.make_recovery_challenge(recipe, ing_id)
		"scale_mod":
			ch = ChallengeFactory.scaling_mod(ing, line["unit"], Game.get_known_amount(recipe, line),
				recipe.base_servings, order.servings, order.mod_percent(ing_id))
		"capacity":
			ch = ChallengeFactory.capacity(_rng, ing, line["unit"],
				Game.get_known_amount(recipe, line), recipe.base_servings)
		"cost":
			var needed := 0
			for al in adjusted.lines:
				if al.get("original_id", al["ingredient_id"]) == ing_id:
					needed = int(al["base_needed"])
			ch = ChallengeFactory.order_cost(ing, needed, order.servings)
		_:
			ch = ChallengeFactory.scaling(ing, line["unit"],
				Game.get_known_amount(recipe, line), recipe.base_servings, order.servings)
	if ch == null:
		push_error("Sem desafio de recuperação para %s / %s" % [recipe.id, ing_id])
		return false
	_current_spec = spec
	begin_challenge(ch, "order")
	return true

func start_planning_challenge() -> void:
	var ch: MathChallenge = ChallengeFactory.planning(_rng, current_tier())
	begin_challenge(ch, "planning")

func start_daily_challenge() -> void:
	if Game.daily_challenge_done:
		say("O desafio de gestão de hoje já foi concluído.")
		return
	begin_challenge(ChallengeFactory.daily(_rng, current_tier(), Game.day_history), "daily")

func submit_answer(raw: Variant) -> Dictionary:
	if current_challenge == null:
		return {"ok": false, "message": ""}
	var res := current_challenge.validate(raw)
	if res["ok"]:
		var pts := (10 if current_challenge.attempts == 1 else 5) * current_challenge.tier
		Game.add_score(pts, "Desafio resolvido")
		_apply_consequence(current_challenge.consequence)
		_current_spec = {}
	elif order != null and challenge_context in ["order", "delivery"]:
		order.mistakes += 1
		res["message"] = str(res["message"]) + " (erro registrado: reduz o pagamento)"
	challenge_finished.emit(res["ok"], res["message"])
	return res

func _apply_consequence(c: Dictionary) -> void:
	match c.get("type", ""):
		"recover_line":
			Game.recover_line(c["recipe_id"], c["ingredient_id"], float(c["amount"]))
			if adjusted != null and order != null:
				adjusted = AdjustedRecipe.build(GameData.recipes[adjusted.recipe_id], order.servings, Game.recovered, order.mods, order.restrictions)
		"scale_line":
			pass   # a fila de desafios já controla o avanço
		"delivery_step":
			delivery_steps_done[c["step"]] = true
			if c.has("cents"):
				delivery_freight_cents = int(c["cents"])   # frete da entrega por telefone
		"purchase_discount":
			Game.next_purchase_discount_percent = float(c.get("percent", 0.0))
		"management_bonus":
			Game.add_money(int(c["cents"]), "Bônus de gestão")
			Game.add_score(int(c["points"]), "Desafio de gestão")
			Game.daily_challenge_done = true
		"news_bonus":
			Game.add_money(int(c["cents"]), "Bônus do jornal")
			Game.add_score(int(c["points"]), "Desafio do jornal")
			Game.news_done = true

## Chamado pelo botão Continuar/Voltar da tela de desafio.
func leave_challenge() -> void:
	var solved := current_challenge != null and current_challenge.solved
	if not solved and not _current_spec.is_empty():
		challenge_queue.push_front(_current_spec)   # desafio não resolvido volta para a fila
	_current_spec = {}
	current_challenge = null
	order_changed.emit()
	match challenge_context:
		"order":
			go(GameStates.Id.KITCHEN)
		"delivery":
			go(GameStates.Id.DELIVERY)
		"planning":
			go(GameStates.Id.ADMINISTRATION)
		"daily":
			go(GameStates.Id.DAY_SUMMARY)
		"news":
			go(GameStates.Id.NEWSPAPER)
		_:
			go(GameStates.Id.RESTAURANT)

# ------------------------------------------------------------------------ preparo
func start_preparation() -> bool:
	if not is_ready_to_cook():
		say("Resolva os desafios da receita antes de cozinhar.")
		return false
	var to_use := portion_adjusted()
	var check := Game.has_ingredients(to_use)
	if not check["ok"]:
		say(_missing_text(check["missing"]))
		return false
	if not Game.consume_ingredients(to_use):   # consumo único dos ingredientes (com a porção escolhida)
		return false
	order.transition(Order.State.PREPARING)
	var recipe: Recipe = GameData.recipes[adjusted.recipe_id]
	dish = Dish.new(recipe.id, order.servings, recipe.steps)
	dish.ingredients_consumed = true
	dish.start()
	heat_minutes = 20
	order_changed.emit()
	dish_changed.emit()
	go(GameStates.Id.KITCHEN)
	return true

## Porção econômica (−20%), normal ou generosa (+20%): muda o gasto e a felicidade do cliente.
func set_portion(style: String) -> void:
	if order == null or not PORTION_FACTORS.has(style) or order.state != Order.State.IDENTIFIED:
		return
	order.portion_style = style
	order_changed.emit()

## Receita ajustada com a porção escolhida (é o que sai do estoque).
func portion_adjusted() -> AdjustedRecipe:
	if adjusted == null:
		return null
	var style := order.portion_style if order != null else "normal"
	return adjusted.scaled(float(PORTION_FACTORS.get(style, 1.0)))

# ---------------------------------------------------- montagem (arrastar ingredientes)
## A etapa atual é a de separar os ingredientes (montagem por arrastar)?
func is_assembly_step() -> bool:
	if dish == null or dish.state != Dish.State.PREPARING or adjusted == null:
		return false
	var recipe: Recipe = GameData.recipes[dish.recipe_id]
	return dish.steps_done == recipe.assembly_step

func assembly_required() -> Array[String]:
	if adjusted == null:
		return []
	return adjusted.required_ids()

## Jogador soltou um ingrediente na tigela. Ingrediente errado conta como erro.
func assemble_add(ingredient_id: String) -> void:
	if not is_assembly_step() or not GameData.ingredients.has(ingredient_id):
		return
	var ing: Ingredient = GameData.ingredients[ingredient_id]
	if ingredient_id in dish.placed:
		say("%s já foi colocado." % ing.display_name)
		return
	var req := assembly_required()
	var recipe: Recipe = GameData.recipes[dish.recipe_id]
	var where := "no prato" if recipe.stacked else "na tigela"
	if recipe.assembly_first != "" and recipe.assembly_first in req and not (recipe.assembly_first in dish.placed) \
			and ingredient_id != recipe.assembly_first and ingredient_id in req:
		var first: Ingredient = GameData.ingredients[recipe.assembly_first]
		say("Comece pela base: %s vai primeiro no prato." % first.display_name)
		return
	if ingredient_id in req:
		dish.placed.append(ingredient_id)
		var done := dish.placed.size() >= req.size()
		if done:
			dish.advance()
			var nxt := dish.next_step_label()
			say("Montagem completa!" + (" Próxima etapa: %s." % nxt if nxt != "" else ""))
		else:
			say("%s %s (%d de %d)." % [ing.display_name, where, dish.placed.size(), req.size()])
		assembly_event.emit(ingredient_id, true, done)
	else:
		order.mistakes += 1
		say(_assembly_error(ingredient_id) + " (erro registrado)")
		assembly_event.emit(ingredient_id, false, false)
	dish_changed.emit()

func _assembly_error(ingredient_id: String) -> String:
	var ing: Ingredient = GameData.ingredients[ingredient_id]
	for line in adjusted.lines:
		if str(line.get("original_id", "")) == ingredient_id and str(line["ingredient_id"]) != ingredient_id:
			var sub: Ingredient = GameData.ingredients[line["ingredient_id"]]
			return "O pedido é %s: use %s no lugar de %s." % [GameData.restriction_text(order.restrictions), sub.display_name, ing.display_name]
	if order.mod_percent(ingredient_id) <= -100:
		return "O cliente pediu SEM %s!" % ing.display_name
	return "Esta receita não leva %s." % ing.display_name

## A etapa atual é a que usa fogo/forno (cozimento cronometrado)?
func is_heat_step() -> bool:
	if dish == null or dish.state != Dish.State.PREPARING:
		return false
	var recipe: Recipe = GameData.recipes[dish.recipe_id]
	return recipe.has_heat() and recipe.heat_step == dish.steps_done

func heat_target() -> int:
	var recipe: Recipe = GameData.recipes[dish.recipe_id]
	return recipe.heat_minutes_for(dish.servings)

## Margem (em minutos) para o cozimento "perfeito". Melhora com o forno profissional/digital.
func heat_tolerance() -> int:
	return 1 + int(Game.get_effect_total("oven_tolerance"))

func heat_adjust(delta: int) -> void:
	heat_minutes = clampi(heat_minutes + delta, 1, 180)
	dish_changed.emit()

## Liga o fogo/forno com o tempo escolhido e avalia o cozimento.
func do_heat_step() -> void:
	if not is_heat_step():
		return
	var target := heat_target()
	var diff := heat_minutes - target
	var tol := heat_tolerance()
	var msg := ""
	if absi(diff) <= tol:
		dish.cook_result = "perfeito"
		msg = "No ponto perfeito! (ideal: %d min, você usou %d)" % [target, heat_minutes]
	elif absi(diff) <= tol + 3:
		dish.cook_result = "bom"
		msg = "Ficou bom, mas não perfeito. (ideal: %d min, você usou %d)" % [target, heat_minutes]
	elif diff < 0:
		dish.cook_result = "cru"
		msg = "Ficou cru! (ideal: %d min, você usou só %d)" % [target, heat_minutes]
	else:
		dish.cook_result = "queimado"
		msg = "Queimou! (ideal: %d min, você usou %d)" % [target, heat_minutes]
	dish.cook_diff = diff
	dish.advance()
	if dish.state == Dish.State.READY:
		msg += "  Prato pronto!"
	say(msg)
	dish_changed.emit()

func do_prep_step() -> void:
	if is_assembly_step():
		say("Arraste os ingredientes certos da bancada (ou clique neles).")
		return
	if dish == null or is_heat_step() or not dish.advance():
		return
	if dish.state == Dish.State.READY:
		say("Prato pronto!")
	dish_changed.emit()

func _missing_text(missing: Array) -> String:
	var parts: PackedStringArray = []
	for m in missing:
		var ing: Ingredient = GameData.ingredients[m["ingredient_id"]]
		parts.append("%s (faltam %d %s)" % [ing.display_name, int(m["missing"]), Units.label(ing.unit)])
	return "Ingredientes insuficientes: " + ", ".join(parts) + ". Compre na Administração."

# ------------------------------------------------------------------------ entrega
func start_delivery() -> bool:
	if dish == null or dish.state != Dish.State.READY:
		say("O prato ainda não está pronto.")
		return false
	if _delivery_order_id != order.id:
		delivery_steps_done.clear()
		_delivery_order_id = order.id
	delivery_bill_cents = order.base_reward_cents
	if delivery_steps_done.is_empty():
		delivery_freight_cents = 0
	go(GameStates.Id.DELIVERY)
	return true

## Etapas da entrega: no balcão (dividir e troco) ou por telefone (rota, frete e troco).
func delivery_steps() -> Array:
	if order != null and order.is_phone():
		return [["route", "Calcular a rota até a casa do cliente"], ["freight", "Calcular o frete"],
			["change", "Receber o pagamento e dar o troco"]]
	return [["portion", "Dividir o prato"], ["change", "Receber o pagamento e dar o troco"]]

func _next_delivery_step() -> String:
	for st in delivery_steps():
		if not delivery_steps_done.has(st[0]):
			return st[0]
	return ""

func delivery_next_label() -> String:
	match _next_delivery_step():
		"portion":
			return "Dividir o prato em porções (desafio)"
		"route":
			return "Calcular a rota da entrega (desafio)"
		"freight":
			return "Calcular o frete (desafio)"
		"change":
			return "Receber o pagamento e dar o troco (desafio)"
	return "Enviar o prato" if order != null and order.is_phone() else "Entregar o prato"

func delivery_next() -> void:
	match _next_delivery_step():
		"portion":
			begin_challenge(ChallengeFactory.fraction_portion(_rng, current_tier()), "delivery")
		"route":
			begin_challenge(ChallengeFactory.route(order.route, current_tier()), "delivery")
		"freight":
			begin_challenge(ChallengeFactory.freight(ChallengeFactory.route_meters(order.route, current_tier())), "delivery")
		"change":
			begin_challenge(ChallengeFactory.change(_rng, delivery_bill_cents + delivery_freight_cents, current_tier()), "delivery")
		_:
			finalize_delivery()

## Felicidade do cliente (0 a 100): cai com respostas erradas, pistas extras (pedir esclarecimento)
## e cozimento ruim. Ela define as estrelas e a gorjeta.
func _satisfaction() -> int:
	var sat := 100
	sat -= mini(order.mistakes, 5) * 8
	sat -= order.hints_used * 10
	match dish.cook_result:
		"bom":
			sat -= 10
		"cru", "queimado":
			sat -= 30
	sat += _patience_effect()
	sat += int(PORTION_SATISFACTION.get(order.portion_style, 0))
	return clampi(sat, 0, 100)

## Atender rápido deixa o cliente mais feliz; deixar esperando, menos.
func _patience_effect() -> int:
	if not Settings.patience_enabled or order.patience_sec <= 0.0:
		return 0
	if order.patience >= 60.0:
		return 5
	if order.patience >= 30.0:
		return 0
	if order.patience > 0.0:
		return -10
	return -20

func _stars_for(sat: int) -> int:
	if sat >= 90:
		return 5
	if sat >= 75:
		return 4
	if sat >= 60:
		return 3
	if sat >= 40:
		return 2
	return 1

## Pagamento = preço-base + melhorias/reputação + prato do dia + gorjeta − reembolso
## (calculado uma única vez por pedido).
func finalize_delivery() -> void:
	if order == null or dish == null or dish.state != Dish.State.READY:
		return
	if order.paid:
		return
	if _next_delivery_step() != "":
		return
	var correct := dish.recipe_id == order.correct_recipe_id and dish.servings == order.servings
	var base := order.base_reward_cents if correct else 0
	# reputação alta atrai clientes que pagam mais; baixa afasta
	var rep_pct := 10.0 if Game.reputation >= 4.0 else (-10.0 if Game.reputation < 2.0 else 0.0)
	var upgrade_bonus := roundi(base * (Game.get_effect_total("price_bonus_percent") + rep_pct) / 100.0)
	var special_bonus := 0
	if correct and order.correct_recipe_id == Game.daily_special:
		special_bonus = roundi(base * SPECIAL_BONUS_PERCENT / 100.0)
	var sat := _satisfaction()
	var stars := _stars_for(sat)
	var tip_pct: int = [-10, 0, 5, 10, 20][stars - 1]   # 1 estrela = reembolso de 10%
	if stars >= 3:
		tip_pct += int(Game.get_effect_total("tip_bonus_percent")) + int(float(Game.event_effect("tip_bonus", 0.0)))
	var tip_value := roundi(base * tip_pct / 100.0)
	var tip := maxi(tip_value, 0)
	var refund := maxi(-tip_value, 0)
	var freight := delivery_freight_cents if order.is_phone() else 0
	var total := maxi(0, base + upgrade_bonus + special_bonus + tip - refund) + freight

	order.paid = true
	Game.add_money(total, "Pedido #%d (%s)" % [order.id, order.customer_name])
	dish.state = Dish.State.DELIVERED
	order.transition(Order.State.COMPLETED)
	var points := 100 + 20 * current_tier() + 15 * stars
	Game.add_score(points, "Pedido concluído")
	Game.add_rating(stars)
	var chapter_before := GameData.chapter_index(Game.orders_completed)
	if stars >= 3:
		Game.chapter_progress += 1
	var chapter_msg := _chapter_check(chapter_before, "order")
	Game.orders_completed += 1
	Game.orders_today += 1
	var story := _on_progress()
	var chapter_now := GameData.chapter_index(Game.orders_completed)
	if chapter_now != chapter_before:
		Game.chapter_progress = 0
		var ch: Dictionary = GameData.CHAPTERS[chapter_now]
		chapter_msg += ("\n" if chapter_msg != "" else "") + "Começa o %s! Meta: %s" % [ch["title"], ch["goal_text"]]
	if chapter_msg != "":
		story += ("\n" if story != "" else "") + chapter_msg
	followup_tpl = {}
	if not order.followup.is_empty():
		followup_tpl = {"fu": order.followup, "customer": order.customer_name, "channel": order.channel}

	last_result = {
		"customer": order.customer_name,
		"base": base, "upgrade_bonus": upgrade_bonus, "special_bonus": special_bonus,
		"tip": tip, "refund": refund, "total": total, "points": points,
		"stars": stars, "satisfaction": sat, "cook": dish.cook_result,
		"mistakes": order.mistakes, "hints": order.hints_used, "story": story,
		"freight": freight, "patience": int(roundf(order.patience)) if order.patience_sec > 0.0 and Settings.patience_enabled else -1,
		"portion": order.portion_style,
	}
	dish = null
	adjusted = null
	order_changed.emit()
	go(GameStates.Id.RESULT)

func _on_progress() -> String:
	var story := GameData.note_for(Game.orders_completed)
	if Game.orders_completed >= UNLOCK_PUDIM_AT and not Game.is_recipe_unlocked("pudim_verine"):
		Game.unlock_recipe("pudim_verine")
		story += "\nNova receita desbloqueada no livro: Pudim do Verine."
	return story

func continue_after_result() -> void:
	if Game.orders_completed >= WIN_ORDERS:
		ending_kind = "vitoria"
		new_record = Game.register_final_score()
		SaveSystem.delete()   # partida terminada: o save deixa de existir
		go(GameStates.Id.ENDING)
	elif not followup_tpl.is_empty():
		# o mesmo cliente pede mais um prato
		order = _create_followup(followup_tpl["fu"], str(followup_tpl["customer"]), str(followup_tpl["channel"]))
		followup_tpl = {}
		adjusted = null
		dish = null
		challenge_queue.clear()
		order_changed.emit()
		go(GameStates.Id.ACTIVE_ORDER)
		say("%s quer mais um prato!" % order.customer_name)
	elif Game.orders_today >= ORDERS_PER_DAY:
		_enter_day_summary()
	else:
		go(GameStates.Id.RESTAURANT)

## Fechamento do dia: cobra aluguel e contas e confere a meta do capítulo.
func _enter_day_summary() -> void:
	var rent := Game.charge_daily_bills()
	if rent > 0:
		last_rent_cents = rent
	var msg := _chapter_check(GameData.chapter_index(Game.orders_completed), "day")
	go(GameStates.Id.DAY_SUMMARY)
	if msg != "":
		say(msg)

func start_next_day() -> void:
	Game.start_next_day()
	if Game.is_bankrupt():
		ending_kind = "falencia"
		new_record = Game.register_final_score()
		SaveSystem.delete()
		go(GameStates.Id.ENDING)
		return
	Game.today_event = GameData.roll_event(_rng, Game.day)
	if waiting != null:
		waiting = null   # a fila não passa a noite no restaurante
	go(GameStates.Id.NEWSPAPER)
	SaveSystem.save()   # salvamento automático no início de cada dia

# ------------------------------------------------------- jornal do dia e capítulos
## Fecha o jornal e abre o restaurante.
func close_newspaper() -> void:
	Game.chapter_seen = GameData.chapter_index(Game.orders_completed)
	go(GameStates.Id.RESTAURANT)
	var special_text := ""
	if GameData.recipes.has(Game.daily_special):
		var sr: Recipe = GameData.recipes[Game.daily_special]
		special_text = " Prato do dia: %s." % sr.display_name
	say("O dia %d começou!%s" % [Game.day, special_text])

## Pratos vendidos pelo rival nos últimos dias (no máximo 4), publicados no jornal.
func rival_recent() -> Array:
	var out: Array = []
	var start := maxi(0, Game.rival_history.size() - 4)
	for i in range(start, Game.rival_history.size()):
		out.append(int(Game.rival_history[i]["orders"]))
	return out

func start_news_challenge() -> void:
	if Game.news_done:
		say("Você já resolveu o desafio do jornal de hoje.")
		return
	begin_challenge(ChallengeFactory.news(_rng, current_tier(), rival_recent(), GameData.RIVAL_NAME), "news")

## Confere a meta do capítulo idx. Retorna a mensagem de recompensa (ou "").
func _chapter_check(idx: int, context: String) -> String:
	if idx in Game.chapters_done or idx < 0 or idx >= GameData.CHAPTERS.size():
		return ""
	var ch: Dictionary = GameData.CHAPTERS[idx]
	var done := false
	match str(ch["goal"]):
		"stars3":
			done = Game.chapter_progress >= int(ch["target"])
		"day_profit":
			done = context == "day" and Game.day_income() - Game.day_expenses() >= int(ch["target"])
		"reputation":
			done = Game.reputation >= float(ch["target"])
	if not done:
		return ""
	Game.chapters_done.append(idx)
	Game.add_money(int(ch["reward"]), "Meta do capítulo")
	Game.add_score(int(ch["points"]), "Meta do capítulo")
	return "Meta do %s cumprida! +%s e +%d pontos." % [ch["title"], Money.format(int(ch["reward"])), int(ch["points"])]

## Texto da meta do capítulo atual, com o progresso.
func chapter_goal_status() -> String:
	var idx := GameData.chapter_index(Game.orders_completed)
	var ch: Dictionary = GameData.CHAPTERS[idx]
	if idx in Game.chapters_done:
		return "%s — meta cumprida!" % ch["title"]
	var progress := ""
	match str(ch["goal"]):
		"stars3":
			progress = " (%d de %d)" % [mini(Game.chapter_progress, int(ch["target"])), int(ch["target"])]
		"reputation":
			progress = " (agora: %s)" % ("%.1f" % Game.reputation).replace(".", ",")
	return "%s — Meta: %s%s" % [ch["title"], ch["goal_text"], progress]

# =============================================================== navegação / menus
## Vai para uma página do restaurante (Salão, Cozinha ou Despensa).
func goto_place(place: int) -> void:
	match place:
		GameStates.Place.SALAO:
			if order != null and not order.is_closed():
				go(GameStates.Id.ACTIVE_ORDER)
			else:
				go(GameStates.Id.RESTAURANT)
		GameStates.Place.COZINHA:
			go(GameStates.Id.KITCHEN)
		GameStates.Place.DESPENSA:
			go(GameStates.Id.ADMINISTRATION)

func open_settings() -> void:
	if state != GameStates.Id.SETTINGS:
		settings_return = state
		go(GameStates.Id.SETTINGS)

func close_settings() -> void:
	go(settings_return)

func open_credits() -> void:
	go(GameStates.Id.CREDITS)

func close_credits() -> void:
	go(GameStates.Id.MAIN_MENU)

# ======================================================================= salvamento
## Estado "real" da partida (o livro e as configurações são telas de passagem).
func _effective_state() -> int:
	if state == GameStates.Id.RECIPE_BOOK:
		return int(return_state)
	if state == GameStates.Id.SETTINGS:
		return int(settings_return)
	return int(state)

func can_save() -> bool:
	var s := _effective_state()
	return not (s in [GameStates.Id.MAIN_MENU, GameStates.Id.INTRO, GameStates.Id.CREDITS,
		GameStates.Id.ENDING, GameStates.Id.MATH_CHALLENGE])   # o jornal pode ser salvo

func save_now() -> bool:
	if not can_save():
		say("Não é possível salvar agora. Termine ou saia do desafio primeiro.")
		return false
	if SaveSystem.save():
		say("Jogo salvo (dia %d, %d pontos)." % [Game.day, Game.score])
		return true
	say("Erro ao salvar o jogo.")
	return false

func continue_game() -> void:
	if SaveSystem.load_into():
		say("Jogo carregado.")
	else:
		say("Não foi possível carregar o jogo salvo.")

func to_dict() -> Dictionary:
	return {
		"state": _effective_state(),
		"order": order.to_dict() if order != null else {},
		"dish": dish.to_dict() if dish != null else {},
		"queue": challenge_queue,
		"delivery_steps": delivery_steps_done.keys(),
		"delivery_bill": delivery_bill_cents,
		"last_result": last_result,
		"next_order_id": _next_order_id,
		"waiting": waiting.to_dict() if waiting != null else {},
		"followup": followup_tpl,
		"freight": delivery_freight_cents,
		"last_rent": last_rent_cents,
	}

func from_dict(d: Dictionary) -> void:
	order = null
	dish = null
	adjusted = null
	current_challenge = null
	_current_spec = {}
	var od: Dictionary = d.get("order", {})
	if not od.is_empty():
		order = Order.from_dict(od)
	var dd: Dictionary = d.get("dish", {})
	if not dd.is_empty():
		dish = Dish.from_dict(dd)
	challenge_queue.clear()
	for q in d.get("queue", []):
		challenge_queue.append({"kind": str(q["kind"]), "ingredient_id": str(q["ingredient_id"])})
	delivery_steps_done.clear()
	for s in d.get("delivery_steps", []):
		delivery_steps_done[str(s)] = true
	delivery_bill_cents = int(d.get("delivery_bill", 0))
	last_result = _clean_result(d.get("last_result", {}))
	_next_order_id = int(d.get("next_order_id", 1))
	waiting = null
	var wd: Dictionary = d.get("waiting", {})
	if not wd.is_empty():
		waiting = Order.from_dict(wd)
	var fu: Variant = d.get("followup", {})
	followup_tpl = fu if typeof(fu) == TYPE_DICTIONARY else {}
	delivery_freight_cents = int(d.get("freight", 0))
	last_rent_cents = int(d.get("last_rent", 0))
	if order != null and order.selected_recipe_id != "" and GameData.recipes.has(order.selected_recipe_id):
		adjusted = AdjustedRecipe.build(GameData.recipes[order.selected_recipe_id], order.servings, Game.recovered, order.mods, order.restrictions)
	if order != null and not delivery_steps_done.is_empty():
		_delivery_order_id = order.id
	heat_minutes = 20
	var target := _safe_state(int(d.get("state", GameStates.Id.RESTAURANT)))
	return_state = GameStates.Id.RESTAURANT
	go(target)

func _clean_result(r: Dictionary) -> Dictionary:
	if r.is_empty():
		return {}
	var out := {"customer": str(r.get("customer", "")), "story": str(r.get("story", "")), "cook": str(r.get("cook", "")),
		"portion": str(r.get("portion", "normal"))}
	out["patience"] = int(r.get("patience", -1))
	for k in ["base", "upgrade_bonus", "special_bonus", "tip", "refund", "total", "points", "stars", "satisfaction", "mistakes", "hints", "freight"]:
		out[k] = int(r.get(k, 0))
	return out

## Garante que o estado carregado é coerente com os dados (pedido, prato, resultado).
func _safe_state(s: int) -> GameStates.Id:
	var has_order := order != null and not order.is_closed()
	match s:
		GameStates.Id.ACTIVE_ORDER, GameStates.Id.INVESTIGATION:
			return s as GameStates.Id if has_order else GameStates.Id.RESTAURANT
		GameStates.Id.DELIVERY:
			if has_order and dish != null and dish.state == Dish.State.READY:
				return GameStates.Id.DELIVERY
			return GameStates.Id.ACTIVE_ORDER if has_order else GameStates.Id.RESTAURANT
		GameStates.Id.RESULT:
			return GameStates.Id.RESULT if not last_result.is_empty() else GameStates.Id.RESTAURANT
		GameStates.Id.KITCHEN, GameStates.Id.ADMINISTRATION, GameStates.Id.DAY_SUMMARY, GameStates.Id.RESTAURANT, GameStates.Id.NEWSPAPER:
			return s as GameStates.Id
	return GameStates.Id.RESTAURANT
