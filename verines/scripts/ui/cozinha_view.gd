class_name CozinhaView
extends Control
## Página da COZINHA. Imagens (em assets/cenarios/):
##   cozinha.png    - ajuste das quantidades e prato pronto
##   preparacao.png - etapas de preparo (separar, misturar, montar, finalizar...)
##   fogao.png      - etapas que usam fogo (assar, cozinhar, fritar, aquecer, calda)
## Sem imagens, usa a blocagem de scenes/cozinha_view.tscn.

const PATHS_COZINHA: Array[String] = ["res://assets/cenarios/cozinha.png"]
const PATHS_PREPARO: Array[String] = ["res://assets/cenarios/preparacao.png"]
const PATHS_FOGAO: Array[String] = ["res://assets/cenarios/fogao.png"]
## Palavras que indicam que a etapa usa o fogão/forno.
<<<<<<< HEAD
const HEAT_WORDS: Array[String] = ["assar", "cozinhar", "fritar", "aquecer", "calda", "forno", "grelhar"]
=======
const HEAT_WORDS: Array[String] = ["assar", "cozinhar", "fritar", "aquecer", "calda", "forno"]
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d

var _bg: TextureRect
var _tex_cozinha: Texture2D
var _tex_preparo: Texture2D
var _tex_fogao: Texture2D
<<<<<<< HEAD
## Montagem: arraste da bancada (fichas com imagem) para a tigela — ou, no hambúrguer, para o prato,
## onde os ingredientes empilham em camadas. Coordenadas do Palco (1280×720).
const BOWL_RECT := Rect2(880, 292, 340, 172)
const CHIPS_POS := Vector2(830, 474)
const CHIP_COLUMNS := 5
const FLY_SECONDS := 0.45
const LINGER_SECONDS := 1.4    # o prato montado fica à vista um pouco antes da próxima etapa
## Camadas do hambúrguer (largura × altura); o pão de baixo é a base, a tampa cai no fim.
const LAYER_SIZES := {
	"pao_hamburguer": Vector2(200, 24), "carne_hamburguer": Vector2(190, 20), "queijo": Vector2(210, 8),
	"queijo_zero": Vector2(210, 8), "alface": Vector2(214, 10), "tomate": Vector2(180, 10),
}
var _bowl: DropBowl
var _chips_grid: GridContainer
var _chips: Dictionary = {}    # ingredient_id -> IngredientChip
var _stack: Control            # o que já caiu na tigela/prato
var _flyers: Control           # ingredientes voando
var _stack_key: String = ""
var _stack_count: int = 0
var _stack_height: float = 0.0
var _linger: bool = false
## Prato pronto (vista de cima): louça + imagem do prato, sobre a bancada.
const READY_RECT := Rect2(960, 250, 230, 230)
var _ready_view: Control
## Camadas com imagem (assets/ingredientes): largura na tela e quanto da altura a pilha "sobe".
## As imagens têm perspectiva, então cada camada encaixa sobre a de baixo (STEP < 1).
const IMG_WIDTHS := {
	"pao_hamburguer_base": 158.0, "carne_hamburguer": 172.0, "queijo": 176.0, "queijo_zero": 176.0,
	"alface": 185.0, "tomate": 176.0, "pao_hamburguer": 169.0,
	"massa_pizza": 230.0, "molho_tomate": 189.0, "queijo_ralado": 180.0,
}
const IMG_STEPS := {
	"pao_hamburguer_base": 0.5, "carne_hamburguer": 0.42, "queijo": 0.22, "queijo_zero": 0.22,
	"alface": 0.3, "tomate": 0.5,
	"massa_pizza": 0.146, "molho_tomate": 0.122, "queijo_ralado": 0.2,
}
const PLATE_SIDE_WIDTH := 270.0
const PLATE_REST := 0.72   # onde a comida "assenta" na louça lateral (fração da altura da imagem)
const TOP_BUN_OVERLAP := 0.12   # quanto a tampa do pão desce sobre a última camada
const BASE_BUN_IMAGE := "pao_hamburguer_base"   # metade de baixo do pão (a de cima é pao_hamburguer)

@onready var _dish_block: ColorRect = $Palco/Prato
@onready var _dish_label: Label = $Palco/Prato/Texto
@onready var _recipe_label: Label = $Palco/Receita
=======

@onready var _dish_block: ColorRect = $Prato
@onready var _dish_label: Label = $Prato/Texto
@onready var _recipe_label: Label = $Receita
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d

func _ready() -> void:
	_dish_block.set_meta("keep", true)
	_bg = SceneBackground.create_layer(self)
	_tex_cozinha = SceneBackground.load_first(PATHS_COZINHA)
	_tex_preparo = SceneBackground.load_first(PATHS_PREPARO)
	_tex_fogao = SceneBackground.load_first(PATHS_FOGAO)
	SceneBackground.style_label_for_art(_recipe_label)
<<<<<<< HEAD
	_build_assembly()
=======
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	Flow.state_changed.connect(_update)
	Flow.order_changed.connect(_update)
	Flow.dish_changed.connect(_update)
	_update()

<<<<<<< HEAD
func _build_assembly() -> void:
	var palco: Control = $Palco
	_bowl = DropBowl.new()
	_bowl.position = BOWL_RECT.position
	_bowl.custom_minimum_size = BOWL_RECT.size
	_bowl.pivot_offset = BOWL_RECT.size / 2.0
	_bowl.z_index = 4
	_bowl.visible = false
	palco.add_child(_bowl)
	_stack = Control.new()
	_stack.position = BOWL_RECT.position
	_stack.size = BOWL_RECT.size
	_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stack.z_index = 5
	_stack.visible = false
	palco.add_child(_stack)
	_chips_grid = GridContainer.new()
	_chips_grid.columns = CHIP_COLUMNS
	_chips_grid.add_theme_constant_override("h_separation", 4)
	_chips_grid.add_theme_constant_override("v_separation", 4)
	_chips_grid.position = CHIPS_POS
	_chips_grid.z_index = 4
	_chips_grid.visible = false
	palco.add_child(_chips_grid)
	for id in GameData.ingredients:
		var chip := IngredientChip.new()
		chip.setup(str(id))
		_chips_grid.add_child(chip)
		_chips[id] = chip
	_ready_view = Control.new()
	_ready_view.position = READY_RECT.position
	_ready_view.size = READY_RECT.size
	_ready_view.pivot_offset = READY_RECT.size / 2.0
	_ready_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ready_view.z_index = 4
	_ready_view.visible = false
	palco.add_child(_ready_view)
	_flyers = Control.new()
	_flyers.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flyers.z_index = 6
	palco.add_child(_flyers)
	Flow.assembly_event.connect(_on_assembly_event)

func _is_stacked() -> bool:
	if Flow.dish == null:
		return false
	var r: Recipe = GameData.recipes[Flow.dish.recipe_id]
	return r.stacked

func _update_assembly() -> void:
	var on := Flow.is_assembly_step() or _linger
	_bowl.visible = on
	_stack.visible = on
	_chips_grid.visible = on and not _linger
	if not on or Flow.dish == null:
		return
	_sync_stack()
	var placed: Array[String] = Flow.dish.placed
	var total := Flow.assembly_required().size()
	var stacked := _is_stacked()
	var title := "Prato" if stacked else "Tigela"
	if _linger:
		_bowl.set_text("%s pronto!" % title if stacked else "Tudo na tigela!")
	elif placed.is_empty():
		_bowl.set_text("%s — arraste para cá os ingredientes (0 de %d)" % [title, total])
	else:
		_bowl.set_text("%s (%d de %d)" % [title, placed.size(), total])
	for id in _chips:
		var chip: IngredientChip = _chips[id]
		chip.disabled = id in placed

## Mantém o desenho da tigela/prato igual ao que já foi colocado (ex.: depois de carregar o jogo).
func _sync_stack() -> void:
	var key := "%d:%s" % [Flow.order.id if Flow.order != null else 0, Flow.dish.recipe_id]
	var placed: Array[String] = Flow.dish.placed
	if key != _stack_key or placed.size() < _stack_count:
		_clear_stack()
		_stack_key = key
		if _is_stacked():
			_add_plate()
	while _stack_count < placed.size():
		_land(placed[_stack_count], false)
		_stack_count += 1

func _clear_stack() -> void:
	for c in _stack.get_children():
		c.queue_free()
	for c in _flyers.get_children():
		c.queue_free()
	_stack_count = 0
	_stack_height = 0.0

## Louça onde o prato empilhado é montado: a versão lateral (perspectiva) se existir;
## senão a de cima, achatada.
func _add_plate() -> void:
	var side := IngredientArt.plate_side_image()
	if side != null:
		var h := PLATE_SIDE_WIDTH * side.get_height() / float(side.get_width())
		var sp := TextureRect.new()
		sp.texture = side
		sp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sp.stretch_mode = TextureRect.STRETCH_SCALE
		sp.size = Vector2(PLATE_SIDE_WIDTH, h)
		sp.position = Vector2((BOWL_RECT.size.x - PLATE_SIDE_WIDTH) / 2.0, BOWL_RECT.size.y - 22 - h * PLATE_REST)
		sp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stack.add_child(sp)
		return
	var tex := IngredientArt.plate_image()
	if tex != null:
		var tr := TextureRect.new()
		tr.texture = tex
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_SCALE
		tr.size = Vector2(290, 74)
		tr.position = Vector2((BOWL_RECT.size.x - 290) / 2.0, BOWL_RECT.size.y - 52)
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stack.add_child(tr)
		return
	var plate := _layer_panel(Color(0.97, 0.97, 0.97), Vector2(270, 14), 7)
	plate.position = Vector2((BOWL_RECT.size.x - 270) / 2.0, BOWL_RECT.size.y - 22)
	_stack.add_child(plate)

## Prato pronto sobre a bancada: louça + imagem do prato (se existir). Aparece com um "pop".
func _update_ready_view(d: Dish) -> bool:
	var visible_now := d != null and d.state == Dish.State.READY and Flow.state == GameStates.Id.KITCHEN and not _linger
	var dish_tex: Texture2D = IngredientArt.dish_image(d.recipe_id) if d != null else null
	visible_now = visible_now and dish_tex != null
	if not visible_now:
		_ready_view.visible = false
		return false
	if _ready_view.visible and _ready_view.get_meta("recipe", "") == d.recipe_id:
		return true
	for c in _ready_view.get_children():
		c.queue_free()
	var side_plate := IngredientArt.plate_side_image()
	var r: Recipe = GameData.recipes[d.recipe_id]
	if (r.stacked or r.side_dish) and side_plate != null:
		# prato em perspectiva: louça lateral embaixo e o prato pronto apoiado nela
		var pw := READY_RECT.size.x
		var ph := pw * side_plate.get_height() / float(side_plate.get_width())
		var plate_y := READY_RECT.size.y - ph
		_ready_view.add_child(_fit_texture(side_plate, Vector2(pw, ph), Vector2(0, plate_y)))
		var dw := pw * 0.8
		var dh := dw * dish_tex.get_height() / float(dish_tex.get_width())
		var max_h := READY_RECT.size.y * 0.8   # pratos altos (hambúrguer) diminuem para caber
		if dh > max_h:
			dw *= max_h / dh
			dh = max_h
		_ready_view.add_child(_fit_texture(dish_tex, Vector2(dw, dh), Vector2((pw - dw) / 2.0, plate_y + ph * PLATE_REST - dh)))
	else:
		var plate_tex := IngredientArt.plate_image()
		if plate_tex != null:
			_ready_view.add_child(_fit_texture(plate_tex, READY_RECT.size, Vector2.ZERO))
		var inner := READY_RECT.size * 0.72
		_ready_view.add_child(_fit_texture(dish_tex, inner, (READY_RECT.size - inner) / 2.0))
	_ready_view.set_meta("recipe", d.recipe_id)
	_ready_view.visible = true
	_ready_view.scale = Vector2(0.6, 0.6)
	var tw := create_tween()
	tw.tween_property(_ready_view, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return true

func _fit_texture(tex: Texture2D, sz: Vector2, pos: Vector2) -> TextureRect:
	var tr := TextureRect.new()
	tr.texture = tex
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.size = sz
	tr.position = pos
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tr

func _layer_panel(color: Color, sz: Vector2, radius: int) -> Panel:
	var pn := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.border_color = color.darkened(0.35)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(radius)
	pn.add_theme_stylebox_override("panel", sb)
	pn.size = sz
	pn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return pn

# ------------------------------------------------------------------ animações
func _on_assembly_event(ingredient_id: String, ok: bool, done: bool) -> void:
	if not ok:
		if _chips.has(ingredient_id):
			(_chips[ingredient_id] as IngredientChip).shake()
		var tw := create_tween()
		_bowl.modulate = Color(1, 0.6, 0.6)
		tw.tween_property(_bowl, "modulate", Color.WHITE, 0.3)
		return
	if Flow.dish == null:
		return
	if _stack_key == "":
		_sync_stack()
	var index := _stack_count
	_stack_count += 1   # reserva o lugar já agora (a animação ainda está no ar)
	_fly(ingredient_id, index, done)
	if done:
		_linger = true
		get_tree().create_timer(LINGER_SECONDS + FLY_SECONDS).timeout.connect(_end_linger)

func _end_linger() -> void:
	_linger = false
	_update()

## Ingrediente voa em arco da ficha até a tigela/prato.
func _fly(id: String, index: int, done: bool) -> void:
	var palco: Control = $Palco
	var start := BOWL_RECT.position + Vector2(BOWL_RECT.size.x / 2.0, -80)
	if _chips.has(id):
		var chip: IngredientChip = _chips[id]
		start = chip.global_position - palco.global_position + chip.size / 2.0
	var target := BOWL_RECT.position + _target_in_bowl(id, index)
	var fl := TextureRect.new()
	fl.texture = IngredientArt.icon_for(id)
	fl.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fl.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	fl.size = Vector2(48, 48)
	fl.pivot_offset = Vector2(24, 24)
	fl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flyers.add_child(fl)
	var peak := Vector2((start.x + target.x) / 2.0, minf(start.y, target.y) - 90.0)
	# curva de Bézier: início -> ponto alto -> tigela/prato
	var arc := func(t: float) -> void:
		var a: Vector2 = start.lerp(peak, t)
		var b: Vector2 = peak.lerp(target, t)
		fl.position = a.lerp(b, t) - Vector2(24, 24)
	var tw := create_tween().set_parallel(true)
	tw.tween_method(arc, 0.0, 1.0, FLY_SECONDS).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(fl, "rotation", deg_to_rad(360.0), FLY_SECONDS)
	tw.tween_property(fl, "scale", Vector2(0.7, 0.7), FLY_SECONDS).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(_arrive.bind(fl, id, done))

func _arrive(fl: Control, id: String, done: bool) -> void:
	fl.queue_free()
	if Flow.dish == null and not _linger:
		return
	_land(id, true)
	if done and _is_stacked() and "pao_hamburguer" in _required_for_current():
		_drop_top_bun()

## Ingredientes da montagem atual (também durante o "prato pronto", quando a etapa já passou).
func _required_for_current() -> Array[String]:
	return Flow.assembly_required()

## Onde o ingrediente vai parar (coordenadas da tigela/prato).
func _target_in_bowl(id: String, index: int) -> Vector2:
	if _is_stacked():
		var info := _layer_info(id)
		(info["node"] as Node).free()   # só precisamos do tamanho aqui
		var sz: Vector2 = info["size"]
		return Vector2(BOWL_RECT.size.x / 2.0, BOWL_RECT.size.y - 22 - _stack_height - sz.y / 2.0)
	return Vector2(36 + (index % 8) * 38, BOWL_RECT.size.y - 40 - (index / 8) * 34)

## O ingrediente "chega": camada que cai e quica (hambúrguer) ou ícone que pula na tigela.
func _land(id: String, animate: bool) -> void:
	if _is_stacked():
		var info := _layer_info(id)
		var sz: Vector2 = info["size"]
		var layer: Control = info["node"]
		var final_pos := Vector2((BOWL_RECT.size.x - sz.x) / 2.0, BOWL_RECT.size.y - 22 - _stack_height - sz.y)
		_stack_height += float(info["step"])
		_stack.add_child(layer)
		layer.position = final_pos
		if animate:
			layer.position = final_pos - Vector2(0, 50)
			var tw := create_tween()
			tw.tween_property(layer, "position", final_pos, 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	else:
		var icon := TextureRect.new()
		icon.texture = IngredientArt.icon_for(id)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.size = Vector2(32, 32)
		icon.pivot_offset = Vector2(16, 16)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var count := _stack.get_child_count()
		icon.position = Vector2(20 + (count % 8) * 38, BOWL_RECT.size.y - 56 - (count / 8) * 34)
		_stack.add_child(icon)
		if animate:
			icon.scale = Vector2.ZERO
			var tw := create_tween()
			tw.tween_property(icon, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if animate:
		# a tigela/prato "sente" o peso: achata e volta
		var bt := create_tween()
		bt.tween_property(_bowl, "scale", Vector2(1.05, 0.93), 0.08)
		bt.tween_property(_bowl, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

## Camada da pilha: imagem do ingrediente (se existir) ou faixa colorida.
## O pão, quando é a primeira camada, usa a imagem da metade de baixo.
func _layer_info(id: String, top_bun: bool = false) -> Dictionary:
	var img_id := id
	if Flow.dish != null:
		var r: Recipe = GameData.recipes[Flow.dish.recipe_id]
		img_id = str(r.layer_images.get(id, id))
	if id == "pao_hamburguer" and not top_bun:
		img_id = BASE_BUN_IMAGE
	var tex := IngredientArt.image_for(img_id)
	if tex != null:
		var w: float = IMG_WIDTHS.get(img_id, 196.0)
		var h := w * tex.get_height() / float(tex.get_width())
		var tr := TextureRect.new()
		tr.texture = tex
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_SCALE
		tr.size = Vector2(w, h)
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return {"node": tr, "size": Vector2(w, h), "step": h * float(IMG_STEPS.get(img_id, 0.3))}
	var sz: Vector2 = LAYER_SIZES.get(id, Vector2(190, 14))
	return {"node": _layer_panel(IngredientArt.color_for(id), sz, 5 if sz.y < 15 else 9), "size": sz, "step": sz.y - 2.0}

## Fim do hambúrguer: a tampa do pão cai por cima.
func _drop_top_bun() -> void:
	var bun: Control
	var sz := Vector2(204, 32)
	var top_tex := IngredientArt.image_for("pao_hamburguer")
	if top_tex != null:
		var info := _layer_info("pao_hamburguer", true)
		bun = info["node"]
		sz = info["size"]
	else:
		var pn := Panel.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = IngredientArt.color_for("pao_hamburguer")
		sb.border_color = sb.bg_color.darkened(0.35)
		sb.set_border_width_all(2)
		sb.corner_radius_top_left = 60
		sb.corner_radius_top_right = 60
		sb.corner_radius_bottom_left = 6
		sb.corner_radius_bottom_right = 6
		pn.add_theme_stylebox_override("panel", sb)
		pn.size = sz
		pn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for i in 5:   # gergelim
			var dot := ColorRect.new()
			dot.color = Color(1, 0.96, 0.82)
			dot.size = Vector2(6, 3)
			dot.position = Vector2(50 + i * 24, 8 + (i % 2) * 6)
			dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			pn.add_child(dot)
		bun = pn
	# a tampa encaixa um pouco sobre a última camada
	var overlap := sz.y * (TOP_BUN_OVERLAP if top_tex != null else 0.0)
	var final_pos := Vector2((BOWL_RECT.size.x - sz.x) / 2.0, BOWL_RECT.size.y - 22 - _stack_height - sz.y + 2.0 + overlap)
	_stack.add_child(bun)
	bun.position = final_pos - Vector2(0, 120)
	var tw := create_tween()
	tw.tween_property(bun, "position", final_pos, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.tween_property(_bowl, "modulate", Color(1.15, 1.1, 0.8), 0.15)
	tw.tween_property(_bowl, "modulate", Color.WHITE, 0.35)

=======
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
## Escolhe a imagem conforme o que está acontecendo na cozinha.
func _pick_texture() -> Texture2D:
	var d := Flow.dish
	if d != null and d.state == Dish.State.PREPARING:
		var step := d.next_step_label().to_lower()
		for w in HEAT_WORDS:
			if step.contains(w):
				return SceneBackground.first_of([_tex_fogao, _tex_preparo, _tex_cozinha])
		return SceneBackground.first_of([_tex_preparo, _tex_cozinha])
	return _tex_cozinha

func _update(_unused: int = 0) -> void:
	var has_image := SceneBackground.show_image(self, _bg, _pick_texture())
	var o := Flow.order
	var active := o != null and not o.is_closed() and o.selected_recipe_id != ""
	_recipe_label.visible = active
	if active:
		var r: Recipe = GameData.recipes[o.selected_recipe_id]
		_recipe_label.text = "Pedido de %s: %s (%d porções)" % [o.customer_name, r.display_name, o.servings]
<<<<<<< HEAD
		if not o.restrictions.is_empty():
			_recipe_label.text += " — %s" % GameData.restriction_text(o.restrictions)
	var d := Flow.dish
	var ready_shown := _update_ready_view(d)
	_dish_block.visible = d != null and not has_image and not Flow.is_assembly_step() and not ready_shown
	_update_assembly()
=======
	var d := Flow.dish
	_dish_block.visible = d != null and not has_image   # com imagem, o painel abaixo mostra as etapas
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	if d != null:
		var recipe: Recipe = GameData.recipes[d.recipe_id]
		if d.state == Dish.State.READY:
			_dish_block.color = Color(0.4, 0.8, 0.4)
			_dish_label.text = "%s\npronto!" % recipe.display_name
		else:
			_dish_block.color = Color(0.95, 0.65, 0.2)
			_dish_label.text = "%s\n%d/%d etapas" % [recipe.display_name, d.steps_done, d.steps.size()]
