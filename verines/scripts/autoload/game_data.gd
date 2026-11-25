extends Node
## Catálogo do jogo (autoload "GameData"): ingredientes, receitas, pistas, desafios,
## melhorias, pedidos e notas da história. O catálogo definitivo deve ser ampliado pela equipe.

var ingredients: Dictionary = {}   # id -> Ingredient
var recipes: Dictionary = {}       # id -> Recipe
var clues: Dictionary = {}         # id -> Clue
var challenges: Dictionary = {}    # id -> MathChallenge (modelos; use clone())
var upgrades: Dictionary = {}      # id -> Upgrade
var order_templates: Array[Dictionary] = []
var story_notes: Array[Dictionary] = []

<<<<<<< HEAD
## Restrições alimentares: cada uma troca ingredientes da receita por versões compatíveis
## (que precisam ser compradas na Despensa).
const RESTRICTIONS := {
	"sem_lactose": {"name": "sem lactose", "swap": {"leite": "leite_zero", "queijo": "queijo_zero", "queijo_ralado": "queijo_zero"}},
	"sem_gluten": {"name": "sem glúten", "swap": {"farinha": "farinha_sg", "macarrao": "macarrao_sg"}},
}

## Eventos do dia (anunciados no jornal). effects: patience_mult, tip_bonus, buy_discount,
## rating_weight, queue_chance. "weight" = chance relativa de sair no sorteio.
const EVENTS := {
	"normal": {"title": "Dia tranquilo no bairro", "text": "Nada de especial hoje. Bom trabalho!", "weight": 3, "effects": {}},
	"chuva": {"title": "Chuva forte no bairro", "text": "Os clientes chegam molhados, mas sem pressa: paciência +50%.", "weight": 1, "effects": {"patience_mult": 0.67}},
	"calor": {"title": "Onda de calor", "text": "Todo mundo com pressa: a paciência acaba 40% mais rápido.", "weight": 1, "effects": {"patience_mult": 1.4}},
	"festa": {"title": "Festa no bairro", "text": "Clientes animados: gorjetas +10 pontos percentuais.", "weight": 1, "effects": {"tip_bonus": 10.0}},
	"promo": {"title": "Promoção no fornecedor", "text": "15% de desconto em todas as compras hoje.", "weight": 1, "effects": {"buy_discount": 15.0}},
	"critico": {"title": "Crítico gastronômico na cidade", "text": "As avaliações de hoje contam em dobro na reputação.", "weight": 1, "effects": {"rating_weight": 2.0}},
	"movimento": {"title": "Movimento intenso", "text": "Chegam mais clientes: a fila enche mais rápido.", "weight": 1, "effects": {"queue_chance": 0.7}},
}

## Capítulos da história, com uma meta cada (recompensa em dinheiro e pontos).
const CHAPTERS := [
	{"at": 0, "title": "Capítulo 1 — A herança", "goal_text": "Atenda 3 clientes com 3 estrelas ou mais.",
		"goal": "stars3", "target": 3, "reward": 1000, "points": 50,
		"news": "Neto de Verine reabre o restaurante da família. Vizinhos estão curiosos."},
	{"at": 3, "title": "Capítulo 2 — A página manchada", "goal_text": "Feche um dia com lucro de pelo menos R$ 25,00.",
		"goal": "day_profit", "target": 2500, "reward": 1500, "points": 80,
		"news": "Receita perdida do Pudim do Verine reaparece. Clientes antigos voltam a perguntar por ela."},
	{"at": 6, "title": "Capítulo 3 — O segredo da despensa", "goal_text": "Alcance reputação 4,0 de 5.",
		"goal": "reputation", "target": 4, "reward": 2500, "points": 120,
		"news": "Boatos: o velho Verine guardava algo no fundo da despensa. O que será?"},
]
const RIVAL_NAME := "Cantina do Bortolo"

func _ready() -> void:
	_build_ingredients()
	_build_recipes()
	_build_heat()
=======
func _ready() -> void:
	_build_ingredients()
	_build_recipes()
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	_build_clues()
	_link_clues_to_recipes()
	_build_challenges()
	_build_upgrades()
	_build_orders()
<<<<<<< HEAD
	_build_extra_orders()
	_build_extra_upgrades()
	_build_story()
	_build_backlog_content()
=======
	_build_story()
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	_validate_data()

# ---------------------------------------------------------------- ingredientes
func _add_ingredient(id: String, nm: String, unit: Units.Unit, pack_size: int, cost: int,
		category: String, limit: int, min_stock: int) -> void:
	ingredients[id] = Ingredient.new(id, nm, unit, pack_size, cost, category, limit, min_stock)

func _build_ingredients() -> void:
	_add_ingredient("farinha", "Farinha", Units.Unit.G, 1000, 600, "Secos", 5000, 300)
	_add_ingredient("acucar", "Açúcar", Units.Unit.G, 1000, 550, "Secos", 5000, 300)
	_add_ingredient("macarrao", "Macarrão", Units.Unit.G, 500, 600, "Secos", 3000, 250)
	_add_ingredient("molho_tomate", "Molho de tomate", Units.Unit.G, 500, 700, "Molhos", 3000, 200)
	_add_ingredient("queijo", "Queijo", Units.Unit.G, 500, 2200, "Laticínios", 2000, 150)
	_add_ingredient("leite", "Leite", Units.Unit.ML, 1000, 550, "Laticínios", 5000, 300)
	_add_ingredient("ovo", "Ovos", Units.Unit.UN, 12, 1200, "Frescos", 36, 4)
<<<<<<< HEAD
	# substitutos para restrições alimentares (mais caros)
	_add_ingredient("leite_zero", "Leite sem lactose", Units.Unit.ML, 1000, 900, "Sem lactose", 3000, 0)
	_add_ingredient("queijo_zero", "Queijo sem lactose", Units.Unit.G, 500, 3000, "Sem lactose", 1500, 0)
	_add_ingredient("farinha_sg", "Farinha sem glúten", Units.Unit.G, 1000, 1100, "Sem glúten", 3000, 0)
	_add_ingredient("macarrao_sg", "Macarrão sem glúten", Units.Unit.G, 500, 1000, "Sem glúten", 2000, 0)
	# hambúrguer
	_add_ingredient("pao_hamburguer", "Pão de hambúrguer", Units.Unit.UN, 6, 900, "Padaria", 24, 2)
	_add_ingredient("carne_hamburguer", "Carne de hambúrguer", Units.Unit.UN, 4, 1600, "Carnes", 16, 2)
	_add_ingredient("alface", "Alface", Units.Unit.G, 200, 400, "Hortifrúti", 1000, 60)
	_add_ingredient("tomate", "Tomate", Units.Unit.G, 500, 500, "Hortifrúti", 2000, 100)
	# pizza
	_add_ingredient("queijo_ralado", "Queijo ralado", Units.Unit.G, 500, 2200, "Laticínios", 2000, 100)
=======
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d

# -------------------------------------------------------------------- receitas
func _add_recipe(id: String, nm: String, desc: String, base: int, price: int,
		steps: Array, unlocked: bool = true) -> Recipe:
	var r := Recipe.new()
	r.id = id
	r.display_name = nm
	r.description = desc
	r.base_servings = base
	r.price_per_serving_cents = price
	r.steps.assign(steps)
	r.unlocked_by_default = unlocked
	recipes[id] = r
	return r

func _build_recipes() -> void:
	_add_recipe("bolo", "Bolo da Vovó", "Bolo simples e fofinho, clássico da casa.", 4, 500,
		["Separar os ingredientes", "Misturar a massa", "Assar no forno", "Finalizar", "Servir"]) \
		.add_line("farinha", 200, Units.Unit.G) \
		.add_line("ovo", 2, Units.Unit.UN) \
		.add_line("leite", 100, Units.Unit.ML) \
		.add_line("acucar", 150, Units.Unit.G)

	_add_recipe("lasanha", "Lasanha de Forno", "Massa em camadas com molho e queijo gratinado.", 4, 900,
		["Separar os ingredientes", "Montar as camadas", "Assar no forno", "Finalizar", "Servir"]) \
		.add_line("macarrao", 250, Units.Unit.G) \
		.add_line("molho_tomate", 200, Units.Unit.G) \
		.add_line("queijo", 150, Units.Unit.G, true)   # página manchada: dado ilegível

	_add_recipe("macarrao_ao_molho", "Macarrão ao Molho", "Massa cozida na panela com molho de tomate.", 2, 600,
		["Separar os ingredientes", "Cozinhar a massa", "Aquecer o molho", "Misturar", "Servir"]) \
		.add_line("macarrao", 200, Units.Unit.G) \
		.add_line("molho_tomate", 150, Units.Unit.G, true) \
		.add_line("queijo", 40, Units.Unit.G)

	_add_recipe("panqueca", "Panqueca Recheada", "Massa fina feita na frigideira e enrolada com recheio.", 2, 450,
		["Separar os ingredientes", "Misturar a massa", "Fritar na frigideira", "Rechear e enrolar", "Servir"]) \
		.add_line("farinha", 100, Units.Unit.G) \
		.add_line("ovo", 1, Units.Unit.UN) \
		.add_line("leite", 200, Units.Unit.ML, true)

<<<<<<< HEAD
	# Hambúrguer: grelhar a carne e depois montar em camadas (montagem com animação de empilhar)
	var burger := _add_recipe("hamburguer", "Hambúrguer da Casa", "Pão, carne grelhada, queijo e salada, montados em camadas.", 2, 800,
		["Grelhar a carne", "Montar o hambúrguer", "Servir"])
	burger.add_line("pao_hamburguer", 2, Units.Unit.UN) \
		.add_line("carne_hamburguer", 2, Units.Unit.UN) \
		.add_line("queijo", 40, Units.Unit.G) \
		.add_line("alface", 30, Units.Unit.G) \
		.add_line("tomate", 80, Units.Unit.G)
	burger.assembly_step = 1
	burger.stacked = true
	burger.assembly_first = "pao_hamburguer"   # a base do pão vai primeiro no prato
	burger.layer_images = {"queijo_zero": "queijo"}

	# Pizza: montada em camadas (massa -> molho -> queijo), em perspectiva como o hambúrguer
	var pizza := _add_recipe("pizza", "Pizza de Queijo", "Massa redonda e fina, com molho de tomate e queijo derretido.", 2, 700,
		["Montar a pizza", "Assar no forno", "Servir"])
	pizza.add_line("farinha", 250, Units.Unit.G) \
		.add_line("molho_tomate", 100, Units.Unit.G) \
		.add_line("queijo_ralado", 150, Units.Unit.G)
	pizza.stacked = true
	pizza.assembly_first = "farinha"   # a massa é a base
	pizza.layer_images = {"farinha": "massa_pizza", "farinha_sg": "massa_pizza", "queijo_zero": "queijo_ralado"}

=======
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	_add_recipe("pudim_verine", "Pudim do Verine", "Receita antiga do avô, página parcialmente apagada.", 4, 900,
		["Separar os ingredientes", "Fazer a calda", "Bater a mistura", "Assar em banho-maria", "Servir"], false) \
		.add_line("leite", 500, Units.Unit.ML) \
		.add_line("ovo", 3, Units.Unit.UN) \
		.add_line("acucar", 200, Units.Unit.G, true)

# ---------------------------------------------------------------------- pistas
func _add_clue(id: String, text: String, recipe_ids: Array) -> void:
	clues[id] = Clue.new(id, text, recipe_ids)

func _build_clues() -> void:
	_add_clue("c_doce", "Prato doce, servido de sobremesa.", ["bolo", "pudim_verine"])
<<<<<<< HEAD
	_add_clue("c_forno", "Vai ao forno.", ["bolo", "lasanha", "pizza"])
	_add_clue("c_massa_assada", "Massa assada.", ["lasanha"])
	_add_clue("c_molho_tomate", "Leva molho de tomate.", ["lasanha", "macarrao_ao_molho", "pizza"])
	_add_clue("c_queijo_gratinado", "Queijo derretido por cima.", ["lasanha", "pizza"])
	_add_clue("c_camadas", "É montado em camadas.", ["lasanha", "hamburguer"])
=======
	_add_clue("c_forno", "Vai ao forno.", ["bolo", "lasanha"])
	_add_clue("c_massa_assada", "Massa assada.", ["lasanha"])
	_add_clue("c_molho_tomate", "Leva molho de tomate.", ["lasanha", "macarrao_ao_molho"])
	_add_clue("c_queijo_gratinado", "Queijo derretido por cima.", ["lasanha"])
	_add_clue("c_camadas", "É montado em camadas.", ["lasanha"])
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	_add_clue("c_massa_cozida", "Massa cozida na panela.", ["macarrao_ao_molho"])
	_add_clue("c_sem_forno", "Não precisa de forno.", ["macarrao_ao_molho", "panqueca"])
	_add_clue("c_massa_fina", "Massa bem fina e leve.", ["panqueca"])
	_add_clue("c_recheio", "É enrolado com recheio.", ["panqueca"])
	_add_clue("c_frigideira", "Feito na frigideira.", ["panqueca"])
	_add_clue("c_doce_domingo", "Era o doce de domingo do Verine.", ["pudim_verine"])
	_add_clue("c_cremoso", "Textura cremosa que balança no prato.", ["pudim_verine"])
	_add_clue("c_calda", "Coberto com calda dourada.", ["pudim_verine"])
<<<<<<< HEAD
	_add_clue("c_lanche", "É um lanche, comido com as mãos.", ["hamburguer"])
	_add_clue("c_redonda", "É redonda e servida em fatias.", ["pizza"])
	_add_clue("c_massa_aberta", "A massa é aberta bem fina antes de assar.", ["pizza"])
	_add_clue("c_grelhado", "Leva carne grelhada na chapa.", ["hamburguer"])
	_add_clue("c_pao", "Servido dentro de um pão.", ["hamburguer"])
=======
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d

func _link_clues_to_recipes() -> void:
	for cid in clues:
		var clue: Clue = clues[cid]
		for rid in clue.recipe_ids:
			var r: Recipe = recipes[rid]
			if not (cid in r.clue_ids):
				r.clue_ids.append(cid)

# ------------------------------------------------------------------- desafios
func _build_challenges() -> void:
	# Recuperação de dado ilegível: queijo da lasanha (razão e proporção).
	var c := MathChallenge.new()
	c.id = "rec_lasanha_queijo"
	c.topic = "Razão e proporção"
	c.type = MathChallenge.Type.DECIMAL
	c.operation = "Proporção direta"
	c.statement = "Uma mancha cobriu a quantidade de queijo da Lasanha de Forno (receita para 4 porções).\nUma anotação do vovô diz: \"para 2 porções eu usava 75 g de queijo\".\nQuantos gramas de queijo a receita pede para 4 porções?"
	c.expected = 150.0
	c.tolerance = 0.01
	c.hint = "4 porções é o dobro de 2 porções."
	c.success_feedback = "Dado recuperado! O livro de receitas foi atualizado."
	c.tier = 1
	c.consequence = {"type": "recover_line", "recipe_id": "lasanha", "ingredient_id": "queijo", "amount": 150.0}
	challenges[c.id] = c
	recipes["lasanha"].challenge_ids.append(c.id)

	# Recuperação: açúcar do pudim (fração de uma quantidade).
	var d := MathChallenge.new()
	d.id = "rec_pudim_acucar"
	d.topic = "Frações"
	d.type = MathChallenge.Type.INTEGER
	d.operation = "Fração de uma quantidade"
	d.statement = "A página do Pudim do Verine está apagada no trecho do açúcar.\nA nota na margem diz: \"o açúcar é 2/5 do volume de leite (considere 1 ml = 1 g)\".\nA receita leva 500 ml de leite. Quantos gramas de açúcar ela pede?"
	d.expected = 200
	d.hint = "Calcule 500 ÷ 5 e depois multiplique por 2."
	d.success_feedback = "Dado recuperado! Mais uma página do livro foi restaurada."
	d.tier = 2
	d.consequence = {"type": "recover_line", "recipe_id": "pudim_verine", "ingredient_id": "acucar", "amount": 200.0}
	challenges[d.id] = d
	recipes["pudim_verine"].challenge_ids.append(d.id)

	# Recuperação: molho do macarrão (porcentagem) — nível 2.
	var e := MathChallenge.new()
	e.id = "rec_macarrao_molho"
	e.tier = 2
	e.topic = "Porcentagem"
	e.type = MathChallenge.Type.DECIMAL
	e.operation = "Porcentagem de uma quantidade"
	e.statement = "A quantidade de molho do Macarrão ao Molho (receita para 2 porções) está borrada.\nA nota do vovô diz: \"o molho pesa 75% do peso do macarrão\".\nA receita usa 200 g de macarrão. Quantos gramas de molho ela pede?"
	e.expected = 150.0
	e.tolerance = 0.01
	e.hint = "75% = 75/100. Calcule 200 × 0,75."
	e.success_feedback = "Dado recuperado! A página do macarrão está legível de novo."
	e.consequence = {"type": "recover_line", "recipe_id": "macarrao_ao_molho", "ingredient_id": "molho_tomate", "amount": 150.0}
	challenges[e.id] = e
	recipes["macarrao_ao_molho"].challenge_ids.append(e.id)

	# Recuperação: leite da panqueca (equação do 1º grau) — nível 3.
	var f := MathChallenge.new()
	f.id = "rec_panqueca_leite"
	f.tier = 3
	f.topic = "Equação do 1º grau"
	f.type = MathChallenge.Type.INTEGER
	f.operation = "Resolução de equação do 1º grau"
	f.statement = "A quantidade de leite da Panqueca Recheada (receita para 2 porções) sumiu da página.\nA nota diz: \"leite + farinha = 300\" (considere 1 ml = 1 g).\nA receita usa 100 g de farinha. Quantos ml de leite ela pede? (resolva x + 100 = 300)"
	f.expected = 200
	f.hint = "Isole o x: subtraia 100 dos dois lados da equação."
	f.success_feedback = "Dado recuperado! A página da panqueca está legível de novo."
	f.consequence = {"type": "recover_line", "recipe_id": "panqueca", "ingredient_id": "leite", "amount": 200.0}
	challenges[f.id] = f
	recipes["panqueca"].challenge_ids.append(f.id)

## Devolve uma cópia nova do desafio de recuperação da linha, ou null.
func make_recovery_challenge(recipe: Recipe, ingredient_id: String) -> MathChallenge:
	for cid in recipe.challenge_ids:
		var ch: MathChallenge = challenges[cid]
		if ch.consequence.get("ingredient_id", "") == ingredient_id:
			return ch.clone()
	return null

# ------------------------------------------------------------------- melhorias
func _build_upgrades() -> void:
	_add_upgrade(Upgrade.new("u_despensa", "Despensa maior", "+50% de capacidade de estoque.", 3000,
		{"type": "storage_percent", "value": 50.0}))
	_add_upgrade(Upgrade.new("u_fornecedor", "Fornecedor parceiro", "10% de desconto em todas as compras.", 2500,
		{"type": "purchase_discount_percent", "value": 10.0}))
	_add_upgrade(Upgrade.new("u_cartaz", "Cartaz na calçada", "+10% no valor dos atendimentos.", 2000,
		{"type": "price_bonus_percent", "value": 10.0}))
	_add_upgrade(Upgrade.new("u_vitrine", "Vitrine renovada", "+15% no valor dos atendimentos.", 4500,
		{"type": "price_bonus_percent", "value": 15.0}, ["u_cartaz"]))

func _add_upgrade(u: Upgrade) -> void:
	upgrades[u.id] = u

# --------------------------------------------------------------------- pedidos
## kind: Order.Kind. "tutorial" aparece só no primeiro atendimento.
## min_completed define quando o pedido pode aparecer (nível 1: 0-2, nível 2: 3-5, nível 3: 6+).
func _add_order(tpl: Dictionary) -> void:
	order_templates.append(tpl)

func _build_orders() -> void:
	# --- Nível 1 ---
<<<<<<< HEAD
	# Primeiro pedido do jogo (tutorial): um hambúrguer.
	_add_order({"tutorial": true, "customer": "João", "kind": Order.Kind.DIRECT,
		"text": "Bom dia! Quero um Hambúrguer da Casa, por favor. Para 2 pessoas.",
		"recipe_id": "hamburguer", "servings": 2})
	_add_order({"customer": "Felipe", "kind": Order.Kind.DESCRIPTIVE, "min_completed": 1,
=======
	_add_order({"tutorial": true, "customer": "Dona Maria", "kind": Order.Kind.DIRECT,
		"text": "Bom dia! Quero um Bolo da Vovó, por favor. Para 4 pessoas.",
		"recipe_id": "bolo", "servings": 4})
	_add_order({"customer": "João", "kind": Order.Kind.DESCRIPTIVE, "min_completed": 1,
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
		"text": "Estou com vontade de uma massa assada, com molho de tomate e queijo derretido por cima. Para 4, por favor.",
		"recipe_id": "lasanha", "servings": 4,
		"clues": ["c_massa_assada", "c_molho_tomate", "c_queijo_gratinado"], "hidden_clues": ["c_camadas"]})
	_add_order({"customer": "Marta", "kind": Order.Kind.DIRECT, "min_completed": 1,
		"text": "Um Bolo da Vovó para 2 pessoas, por favor.",
		"recipe_id": "bolo", "servings": 2})
	_add_order({"customer": "Pedro", "kind": Order.Kind.DESCRIPTIVE, "min_completed": 1,
		"text": "Quero algo de massa assada, em camadas, com molho de tomate. Só para 2.",
		"recipe_id": "lasanha", "servings": 2,
		"clues": ["c_massa_assada", "c_molho_tomate"], "hidden_clues": ["c_queijo_gratinado"]})
<<<<<<< HEAD
	_add_order({"customer": "Caio", "kind": Order.Kind.DIRECT, "min_completed": 1,
		"text": "Um Bolo da Vovó para 6 pessoas, por favor.",
		"recipe_id": "bolo", "servings": 6})
	# --- Nível 2 ---
	_add_order({"customer": "Rafael", "kind": Order.Kind.DIRECT, "min_completed": 3,
		"text": "Um Macarrão ao Molho para 6 pessoas. Vim com a família toda!",
		"recipe_id": "macarrao_ao_molho", "servings": 6})
	_add_order({"customer": "Felipe", "kind": Order.Kind.ENIGMATIC, "min_completed": 3,
		"text": "Procuro um prato que não vai ao forno, é de massa e leva molho vermelho. Para 4 pessoas.",
		"recipe_id": "macarrao_ao_molho", "servings": 4,
		"clues": ["c_sem_forno", "c_molho_tomate"], "hidden_clues": ["c_massa_cozida"]})
	_add_order({"customer": "Seu Tavares", "kind": Order.Kind.ENIGMATIC, "min_completed": 3,
=======
	_add_order({"customer": "Bia", "kind": Order.Kind.DIRECT, "min_completed": 1,
		"text": "Um Bolo da Vovó para 6 pessoas, por favor.",
		"recipe_id": "bolo", "servings": 6})
	# --- Nível 2 ---
	_add_order({"customer": "Seu Carlos", "kind": Order.Kind.DIRECT, "min_completed": 3,
		"text": "Um Macarrão ao Molho para 6 pessoas. Vim com a família toda!",
		"recipe_id": "macarrao_ao_molho", "servings": 6})
	_add_order({"customer": "Dona Lúcia", "kind": Order.Kind.ENIGMATIC, "min_completed": 3,
		"text": "Procuro um prato que não vai ao forno, é de massa e leva molho vermelho. Para 4 pessoas.",
		"recipe_id": "macarrao_ao_molho", "servings": 4,
		"clues": ["c_sem_forno", "c_molho_tomate"], "hidden_clues": ["c_massa_cozida"]})
	_add_order({"customer": "Sr. Tavares", "kind": Order.Kind.ENIGMATIC, "min_completed": 3,
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
		"text": "Meu pai vinha aqui todo domingo por causa de um doce que o Verine fazia. Cremoso, balançava no prato... Você sabe qual é? Para 4.",
		"recipe_id": "pudim_verine", "servings": 4,
		"clues": ["c_doce_domingo", "c_cremoso"], "hidden_clues": ["c_calda"]})
	# --- Nível 3 ---
<<<<<<< HEAD
	_add_order({"customer": "Marta", "kind": Order.Kind.DESCRIPTIVE, "min_completed": 6,
=======
	_add_order({"customer": "Dona Rosa", "kind": Order.Kind.DESCRIPTIVE, "min_completed": 6,
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
		"text": "Quero uma massa fininha, enrolada com recheio. Para 2 pessoas.",
		"recipe_id": "panqueca", "servings": 2,
		"clues": ["c_massa_fina", "c_recheio"], "hidden_clues": ["c_frigideira"]})
	_add_order({"customer": "Caio", "kind": Order.Kind.ENIGMATIC, "min_completed": 6,
		"text": "Preciso de algo leve, sem forno, que se enrola com recheio. Para 4 pessoas.",
		"recipe_id": "panqueca", "servings": 4,
		"clues": ["c_sem_forno", "c_recheio"], "hidden_clues": ["c_massa_fina", "c_frigideira"]})
<<<<<<< HEAD
	_add_order({"customer": "Seu Tavares", "kind": Order.Kind.ENIGMATIC, "min_completed": 6,
		"text": "O doce de domingo do Verine, cremoso e com calda dourada, para a família inteira: 8 pessoas!",
		"recipe_id": "pudim_verine", "servings": 8,
		"clues": ["c_doce_domingo", "c_calda"], "hidden_clues": ["c_cremoso"]})
	_add_order({"customer": "Rafael", "kind": Order.Kind.DESCRIPTIVE, "min_completed": 6,
=======
	_add_order({"customer": "Sra. Vera", "kind": Order.Kind.ENIGMATIC, "min_completed": 6,
		"text": "O doce de domingo do Verine, cremoso e com calda dourada, para a família inteira: 8 pessoas!",
		"recipe_id": "pudim_verine", "servings": 8,
		"clues": ["c_doce_domingo", "c_calda"], "hidden_clues": ["c_cremoso"]})
	_add_order({"customer": "Rafa", "kind": Order.Kind.DESCRIPTIVE, "min_completed": 6,
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
		"text": "Churrasco de aniversário! Quero a massa assada em camadas com queijo gratinado, para 8 pessoas.",
		"recipe_id": "lasanha", "servings": 8,
		"clues": ["c_massa_assada", "c_camadas", "c_queijo_gratinado"], "hidden_clues": ["c_molho_tomate"]})

# ------------------------------------------------------------------- história
<<<<<<< HEAD
# ---------------------------------------------------------- cozimento (fogo/forno)
## set_heat(índice da etapa, minutos base, minutos por porção): tempo = base + por_porção × porções.
func _build_heat() -> void:
	recipes["bolo"].set_heat(2, 10, 5)                # Assar no forno
	recipes["lasanha"].set_heat(2, 20, 5)             # Assar no forno
	recipes["macarrao_ao_molho"].set_heat(1, 6, 2)    # Cozinhar a massa
	recipes["panqueca"].set_heat(2, 4, 3)             # Fritar na frigideira
	recipes["pudim_verine"].set_heat(3, 25, 5)        # Assar em banho-maria
	recipes["hamburguer"].set_heat(0, 4, 1)           # Grelhar a carne
	# pratos prontos desenhados de lado (louça lateral); o macarrão é visto de cima
	for rid in ["bolo", "lasanha", "panqueca", "pudim_verine", "hamburguer", "pizza"]:
		recipes[rid].side_dish = true
	recipes["pizza"].set_heat(1, 10, 2)               # Assar no forno

# ------------------------------------------------- pedidos personalizados e melhorias
## mods: [{ingredient_id, percent}] -> +50 = 50% a mais; -25 = 25% a menos; -100 = sem o ingrediente.
func _build_extra_orders() -> void:
	_add_order({"customer": "Marta", "kind": Order.Kind.DIRECT, "min_completed": 1,
		"text": "Um Bolo da Vovó para 4 pessoas, mas bem fofinho: coloque 50% a mais de leite, por favor.",
		"recipe_id": "bolo", "servings": 4, "mods": [{"ingredient_id": "leite", "percent": 50}]})
	_add_order({"customer": "Felipe", "kind": Order.Kind.DESCRIPTIVE, "min_completed": 1,
		"text": "Quero a massa assada em camadas, com molho de tomate, para 4. Mas SEM queijo, por favor!",
		"recipe_id": "lasanha", "servings": 4,
		"clues": ["c_massa_assada", "c_molho_tomate", "c_camadas"], "hidden_clues": [],
		"mods": [{"ingredient_id": "queijo", "percent": -100}]})
	_add_order({"customer": "Pedro", "kind": Order.Kind.DIRECT, "min_completed": 3,
		"text": "Macarrão ao Molho para 4 pessoas, com 50% a mais de molho. Adoro bem molhadinho!",
		"recipe_id": "macarrao_ao_molho", "servings": 4,
		"mods": [{"ingredient_id": "molho_tomate", "percent": 50}]})
	_add_order({"customer": "Seu Tavares", "kind": Order.Kind.ENIGMATIC, "min_completed": 6,
		"text": "O doce de domingo do Verine, cremoso, para 8 pessoas. Mas com 25% menos de açúcar: estou de dieta!",
		"recipe_id": "pudim_verine", "servings": 8,
		"clues": ["c_doce_domingo", "c_cremoso"], "hidden_clues": ["c_calda"],
		"mods": [{"ingredient_id": "acucar", "percent": -25}]})

func _build_extra_upgrades() -> void:
	_add_upgrade(Upgrade.new("u_forno", "Forno profissional", "+1 minuto de tolerância no cozimento perfeito.", 3000,
		{"type": "oven_tolerance", "value": 1.0}))
	_add_upgrade(Upgrade.new("u_forno2", "Forno digital", "Mais +1 minuto de tolerância no cozimento.", 5000,
		{"type": "oven_tolerance", "value": 1.0}, ["u_forno"]))
	_add_upgrade(Upgrade.new("u_cardapio", "Cardápio ilustrado", "+5 pontos percentuais nas gorjetas.", 2200,
		{"type": "tip_bonus_percent", "value": 5.0}))

=======
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
## TEXTOS PROVISÓRIOS: a sequência dos mistérios e o desfecho ainda serão definidos pela equipe.
func _build_story() -> void:
	story_notes.append({"at": 1, "text": "Entre as páginas do livro cai uma anotação: \"O segredo não está só na receita.\""})
	story_notes.append({"at": 3, "text": "A página do Pudim do Verine volta a ser legível. Por que o vovô a escondeu?"})
	story_notes.append({"at": 6, "text": "Um cliente antigo comenta que o vovô guardava algo no fundo da despensa."})
	story_notes.append({"at": 10, "text": "Você reconstruiu o restaurante. O mistério do livro ainda guarda uma última página..."})

<<<<<<< HEAD
# ------------------------------------------------------- backlog (v20)
func _build_backlog_content() -> void:
	# Restrições alimentares
	_add_order({"customer": "Marta", "kind": Order.Kind.DESCRIPTIVE, "min_completed": 1,
		"text": "Quero o bolo fofinho da casa, que vai ao forno, para 4. Mas sou intolerante à lactose: nada de leite comum!",
		"recipe_id": "bolo", "servings": 4, "restrictions": ["sem_lactose"],
		"clues": ["c_doce", "c_forno"], "hidden_clues": []})
	_add_order({"customer": "João", "kind": Order.Kind.DIRECT, "min_completed": 3,
		"text": "Um Macarrão ao Molho para 2, por favor. Ah: tem que ser sem glúten!",
		"recipe_id": "macarrao_ao_molho", "servings": 2, "restrictions": ["sem_gluten"]})
	_add_order({"customer": "Caio", "kind": Order.Kind.ENIGMATIC, "min_completed": 6,
		"text": "Uma massa assada em camadas, com queijo gratinado, para 4. Só que eu não posso lactose nem glúten!",
		"recipe_id": "lasanha", "servings": 4, "restrictions": ["sem_lactose", "sem_gluten"],
		"clues": ["c_massa_assada", "c_camadas", "c_queijo_gratinado"], "hidden_clues": []})
	# Pedidos por telefone (entrega): route = [quadras a leste, quadras ao norte]
	_add_order({"customer": "João", "kind": Order.Kind.DIRECT, "min_completed": 2, "phone": true,
		"address": "Rua das Flores — 3 quadras a leste e 4 ao norte", "route": [3, 4],
		"text": "Alô? Quero um Bolo da Vovó para 4, entregue em casa: Rua das Flores, 3 quadras a leste e 4 ao norte daí.",
		"recipe_id": "bolo", "servings": 4})
	_add_order({"customer": "Pedro", "kind": Order.Kind.DESCRIPTIVE, "min_completed": 3, "phone": true,
		"address": "Av. do Porto — 6 quadras a leste e 8 ao norte", "route": [6, 8],
		"text": "Alô, é do Verine's? Quero aquela massa cozida na panela com molho de tomate, para 4. Moro na Av. do Porto: 6 quadras a leste e 8 ao norte.",
		"recipe_id": "macarrao_ao_molho", "servings": 4,
		"clues": ["c_massa_cozida", "c_molho_tomate"], "hidden_clues": ["c_sem_forno"]})
	_add_order({"customer": "Felipe", "kind": Order.Kind.DESCRIPTIVE, "min_completed": 6, "phone": true,
		"address": "Rua do Mirante — 5 quadras a leste e 12 ao norte", "route": [5, 12],
		"text": "Boa noite! Uma massa fininha enrolada com recheio, para 2. Entrega na Rua do Mirante: 5 quadras a leste e 12 ao norte.",
		"recipe_id": "panqueca", "servings": 2,
		"clues": ["c_massa_fina", "c_recheio"], "hidden_clues": ["c_frigideira"]})
	# Vários pratos por cliente: depois do primeiro, o mesmo cliente pede o segundo
	_add_order({"customer": "Marta", "kind": Order.Kind.DESCRIPTIVE, "min_completed": 1,
		"text": "Para começar, uma massa assada em camadas com molho de tomate, para 4. Depois eu peço a sobremesa!",
		"recipe_id": "lasanha", "servings": 4,
		"clues": ["c_massa_assada", "c_camadas", "c_molho_tomate"], "hidden_clues": ["c_queijo_gratinado"],
		"followup": {"recipe_id": "bolo", "servings": 4, "kind": Order.Kind.DESCRIPTIVE,
			"text": "Estava ótimo! Agora a sobremesa: um doce simples e fofinho, que vai ao forno, para os mesmos 4.",
			"clues": ["c_doce", "c_forno"], "hidden_clues": []}})
	_add_order({"customer": "Seu Tavares", "kind": Order.Kind.DIRECT, "min_completed": 4,
		"text": "Um Macarrão ao Molho para 2, por favor. E guarde espaço para o doce!",
		"recipe_id": "macarrao_ao_molho", "servings": 2,
		"followup": {"recipe_id": "pudim_verine", "servings": 4, "kind": Order.Kind.ENIGMATIC,
			"text": "Agora o doce: aquele cremoso que o Verine fazia aos domingos, com calda. Para 4, que vou levar para casa.",
			"clues": ["c_doce_domingo", "c_cremoso"], "hidden_clues": ["c_calda"]}})
	# Hambúrguer
	_add_order({"customer": "Pedro", "kind": Order.Kind.DIRECT, "min_completed": 1,
		"text": "E aí! Um Hambúrguer da Casa para 2, por favor. Tô morrendo de fome!",
		"recipe_id": "hamburguer", "servings": 2})
	_add_order({"customer": "Caio", "kind": Order.Kind.DESCRIPTIVE, "min_completed": 2,
		"text": "Quero um lanche no pão, com carne grelhada e salada, para 4 pessoas.",
		"recipe_id": "hamburguer", "servings": 4,
		"clues": ["c_lanche", "c_grelhado"], "hidden_clues": ["c_pao"]})
	_add_order({"customer": "Felipe", "kind": Order.Kind.DIRECT, "min_completed": 3,
		"text": "Um Hambúrguer da Casa para 2. Mas sem lactose, tá? Queijo comum me faz mal.",
		"recipe_id": "hamburguer", "servings": 2, "restrictions": ["sem_lactose"]})
	_add_order({"customer": "Rafael", "kind": Order.Kind.ENIGMATIC, "min_completed": 6,
		"text": "Para a turma do futebol: aquele lanche montado em camadas, que se come com as mãos. Para 6! E capricha: 50% a mais de queijo.",
		"recipe_id": "hamburguer", "servings": 6, "mods": [{"ingredient_id": "queijo", "percent": 50}],
		"clues": ["c_lanche", "c_camadas"], "hidden_clues": ["c_grelhado", "c_pao"]})

	# Pizza
	_add_order({"customer": "Caio", "kind": Order.Kind.DIRECT, "min_completed": 1,
		"text": "Opa! Uma Pizza de Queijo para 2, por favor.",
		"recipe_id": "pizza", "servings": 2})
	_add_order({"customer": "Marta", "kind": Order.Kind.DESCRIPTIVE, "min_completed": 3,
		"text": "Quero algo redondo, que vai ao forno, com molho de tomate e queijo derretido por cima. Para 4.",
		"recipe_id": "pizza", "servings": 4,
		"clues": ["c_redonda", "c_forno"], "hidden_clues": ["c_massa_aberta"]})
	_add_order({"customer": "João", "kind": Order.Kind.DIRECT, "min_completed": 2, "phone": true,
		"address": "Rua do Comércio — 3 quadras a leste e 4 ao norte", "route": [3, 4],
		"text": "Alô? Uma Pizza de Queijo para 4, para o pessoal do escritório: Rua do Comércio, 3 quadras a leste e 4 ao norte.",
		"recipe_id": "pizza", "servings": 4})

	# Decoração (cosmética): aparece no Salão
	_add_upgrade(Upgrade.new("d_quadro", "Quadro do vovô", "Decoração: retrato do Verine na parede do Salão.", 1200,
		{"type": "decor", "value": 0.0}))
	_add_upgrade(Upgrade.new("d_plantas", "Vasos de plantas", "Decoração: plantas nos cantos do Salão.", 1500,
		{"type": "decor", "value": 0.0}))
	_add_upgrade(Upgrade.new("d_toalhas", "Toalhas xadrez", "Decoração: toalhas vermelhas nas mesas.", 1800,
		{"type": "decor", "value": 0.0}))
	_add_upgrade(Upgrade.new("d_luzes", "Varal de luzes", "Decoração: luzinhas penduradas no Salão.", 2500,
		{"type": "decor", "value": 0.0}))

## Ingrediente a usar no lugar de "ingredient_id" por causa das restrições do pedido.
func substitute_for(ingredient_id: String, restrictions: Array) -> String:
	for r in restrictions:
		var info: Dictionary = RESTRICTIONS.get(str(r), {})
		var swap: Dictionary = info.get("swap", {})
		if swap.has(ingredient_id):
			return str(swap[ingredient_id])
	return ingredient_id

## "sem lactose e sem glúten"
func restriction_text(restrictions: Array) -> String:
	var parts: PackedStringArray = []
	for r in restrictions:
		var info: Dictionary = RESTRICTIONS.get(str(r), {})
		parts.append(str(info.get("name", r)))
	return " e ".join(parts)

## Capítulo atual (índice em CHAPTERS) conforme os pedidos concluídos.
func chapter_index(completed: int) -> int:
	var idx := 0
	for i in CHAPTERS.size():
		if completed >= int(CHAPTERS[i]["at"]):
			idx = i
	return idx

## Sorteia o evento do dia (dia 1 é sempre tranquilo).
func roll_event(rng: RandomNumberGenerator, day_number: int) -> String:
	if day_number <= 1:
		return "normal"
	var total := 0
	for id in EVENTS:
		total += int(EVENTS[id]["weight"])
	var pick := rng.randi_range(1, total)
	for id in EVENTS:
		pick -= int(EVENTS[id]["weight"])
		if pick <= 0:
			return str(id)
	return "normal"

=======
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
func note_for(completed_count: int) -> String:
	for n in story_notes:
		if int(n["at"]) == completed_count:
			return str(n["text"])
	return ""

# ------------------------------------------------------------------ validação
func _validate_data() -> void:
	for rid in recipes:
		var r: Recipe = recipes[rid]
		for line in r.lines:
			var iid: String = line["ingredient_id"]
			if not ingredients.has(iid):
				push_error("Receita %s usa ingrediente inexistente: %s" % [rid, iid])
				continue
			var ing: Ingredient = ingredients[iid]
			if not Units.compatible(line["unit"], ing.unit):
				push_error("Unidade incompatível em %s / %s" % [rid, iid])
	for t in order_templates:
		if not recipes.has(t["recipe_id"]):
			push_error("Pedido aponta para receita inexistente: %s" % t["recipe_id"])
<<<<<<< HEAD
		for r in t.get("restrictions", []):
			if not RESTRICTIONS.has(str(r)):
				push_error("Pedido com restrição desconhecida: %s" % r)
	for rid in RESTRICTIONS:
		var swap: Dictionary = RESTRICTIONS[rid]["swap"]
		for k in swap:
			if not ingredients.has(str(k)) or not ingredients.has(str(swap[k])):
				push_error("Restrição %s com ingrediente inexistente" % rid)
=======
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
