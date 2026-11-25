class_name IntroStory
extends Control
## Introdução do jogo: 3 cenas em tela cheia, cada uma com imagem e legenda.
## Botão "Próximo": clicar avança uma cena; SEGURAR por HOLD_SECONDS pula a introdução.
##
## Imagens: assets/intro/cena_1.png, cena_2.png, cena_3.png (também aceita .jpg e .webp).
## Ideal: 1920×1080 (16:9). Sem imagem, aparece um fundo liso com o aviso do arquivo esperado.
## Os textos das cenas ficam em SCENES, logo abaixo.

signal finished

const HOLD_SECONDS := 1.0
const FADE_SECONDS := 0.35
const SCENES := [
	{"image": "cena_1", "text": "Por décadas, Verine foi o cozinheiro mais querido do bairro. O restaurante dele vivia cheio, e cada prato saía de um velho livro de receitas."},
	{"image": "cena_2", "text": "Mas o tempo passou. O vovô se foi, as mesas ficaram vazias e o restaurante fechou as portas. O livro foi esquecido, com páginas manchadas e incompletas."},
	{"image": "cena_3", "text": "Agora o restaurante e o livro são seus. Atenda os clientes, recupere as receitas e descubra os segredos do vovô. Será que você consegue fazer o Verine's renascer?"},
]
const PLACEHOLDER_COLORS := [Color(0.35, 0.24, 0.16), Color(0.22, 0.2, 0.24), Color(0.3, 0.26, 0.18)]

var _index: int = 0
var _holding: bool = false
var _hold_time: float = 0.0
var _skipped: bool = false
var _textures: Array = []

var _stage: Control          # imagem + fundo (é o que faz o fade)
var _bg: ColorRect
var _image: TextureRect
var _missing: Label
var _caption: Label
var _counter: Label
var _next: Button
var _hold_fill: ColorRect
var _tween: Tween

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP   # bloqueia cliques no que está por baixo
	for sc in SCENES:
		var base := "res://assets/intro/%s" % sc["image"]
		_textures.append(SceneBackground.load_first([base + ".png", base + ".jpg", base + ".jpeg", base + ".webp"]))
	_build()

func _build() -> void:
	var black := ColorRect.new()
	black.color = Color.BLACK
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(black)
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_stage = Control.new()
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stage)
	_stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg = ColorRect.new()
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_bg)
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_image = TextureRect.new()
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_image)
	_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_missing = Label.new()
	_missing.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_missing.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
	_missing.add_theme_font_size_override("font_size", 18)
	_stage.add_child(_missing)
	_missing.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_missing.position.y = 60
	_missing.grow_horizontal = Control.GROW_DIRECTION_BOTH

	# legenda: balão creme na parte de baixo
	var bubble := PanelContainer.new()
	bubble.add_theme_stylebox_override("panel", UIStyle.cream_box(UIStyle.CREAM, 3, 14, 16))
	bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bubble)
	bubble.anchor_left = 0.0
	bubble.anchor_right = 1.0
	bubble.anchor_top = 1.0
	bubble.anchor_bottom = 1.0
	bubble.offset_left = 40
	bubble.offset_right = -260
	bubble.offset_bottom = -28
	bubble.offset_top = -150
	bubble.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bubble.add_child(box)
	_counter = Label.new()
	_counter.add_theme_color_override("font_color", UIStyle.TITLE)
	_counter.add_theme_font_size_override("font_size", 15)
	box.add_child(_counter)
	_caption = Label.new()
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_caption.add_theme_color_override("font_color", UIStyle.TEXT)
	_caption.add_theme_font_size_override("font_size", 22)
	_caption.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_caption)

	# botão: clicar = próxima cena; segurar = pular
	_next = Button.new()
	_next.custom_minimum_size = Vector2(200, 64)
	_next.add_theme_font_size_override("font_size", 22)
	_next.tooltip_text = "Clique para continuar. Segure para pular a introdução."
	add_child(_next)
	_next.anchor_left = 1.0
	_next.anchor_right = 1.0
	_next.anchor_top = 1.0
	_next.anchor_bottom = 1.0
	_next.offset_left = -232
	_next.offset_right = -32
	_next.offset_top = -120
	_next.offset_bottom = -56
	_next.button_down.connect(_on_down)
	_next.button_up.connect(_on_up)
	_hold_fill = ColorRect.new()   # barra que enche enquanto o botão é segurado
	_hold_fill.color = Color(1.0, 0.85, 0.5, 0.9)
	_hold_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hold_fill.position = Vector2(8, 54)
	_hold_fill.size = Vector2(0, 5)
	_next.add_child(_hold_fill)
	var tip := Label.new()
	tip.text = "Segure para pular"
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.add_theme_font_size_override("font_size", 14)
	SceneBackground.style_label_for_art(tip)
	add_child(tip)
	tip.anchor_left = 1.0
	tip.anchor_right = 1.0
	tip.anchor_top = 1.0
	tip.anchor_bottom = 1.0
	tip.offset_left = -232
	tip.offset_right = -32
	tip.offset_top = -50
	tip.offset_bottom = -26

## Recomeça da cena 1 (chamado ao abrir a introdução).
func start() -> void:
	_index = 0
	_skipped = false
	_holding = false
	_hold_time = 0.0
	_hold_fill.size.x = 0
	_show_scene(false)

func _show_scene(fade: bool) -> void:
	var sc: Dictionary = SCENES[_index]
	var tex: Texture2D = _textures[_index]
	_image.texture = tex
	_image.visible = tex != null
	_bg.color = PLACEHOLDER_COLORS[_index % PLACEHOLDER_COLORS.size()]
	_missing.visible = tex == null
	_missing.text = "Cena %d — adicione a imagem em assets/intro/%s.png" % [_index + 1, sc["image"]]
	_caption.text = str(sc["text"])
	_counter.text = "Cena %d de %d" % [_index + 1, SCENES.size()]
	_next.text = "Começar" if _index == SCENES.size() - 1 else "Próximo ▸"
	if fade:
		if _tween != null and _tween.is_valid():
			_tween.kill()
		_stage.modulate.a = 0.0
		_caption.modulate.a = 0.0
		_tween = create_tween().set_parallel(true)
		_tween.tween_property(_stage, "modulate:a", 1.0, FADE_SECONDS)
		_tween.tween_property(_caption, "modulate:a", 1.0, FADE_SECONDS)
	else:
		_stage.modulate.a = 1.0
		_caption.modulate.a = 1.0

func _on_down() -> void:
	_holding = true
	_hold_time = 0.0

## Soltou antes do tempo de "segurar": é um clique normal (avança uma cena).
func _on_up() -> void:
	if not _holding or _skipped:
		return
	_holding = false
	_hold_fill.size.x = 0
	_advance()

func _process(delta: float) -> void:
	if not visible or not _holding or _skipped:
		return
	_hold_time += delta
	_hold_fill.size.x = (_next.size.x - 16.0) * clampf(_hold_time / HOLD_SECONDS, 0.0, 1.0)
	if _hold_time >= HOLD_SECONDS:
		_skip()

func _advance() -> void:
	if _index >= SCENES.size() - 1:
		_finish()
		return
	_index += 1
	_show_scene(true)

func _skip() -> void:
	_skipped = true
	_holding = false
	_finish()

func _finish() -> void:
	_holding = false
	_hold_fill.size.x = 0
	finished.emit()
