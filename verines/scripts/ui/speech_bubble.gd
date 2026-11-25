class_name SpeechBubble
extends PanelContainer
## Balão de fala que aparece ao lado do cliente no Salão.
## Mostra um título curto (ex.: "Pedido", "Desafio: Frações") e o texto (pedido ou enunciado).
## Embaixo do texto pode receber um bloco extra (as alternativas A–D), via set_extra().
## A largura é fixa; a altura cresce com o texto e, se não couber em max_height,
## a fonte diminui até MIN_FONT_SIZE.

const MIN_FONT_SIZE := 11
const TAIL_WIDTH := 18.0     # quanto a ponta avança para a esquerda (na direção do cliente)
const TAIL_HEIGHT := 22.0    # altura da base da ponta
const TAIL_TOP := 22.0       # distância do topo do balão até a ponta
const BG_COLOR := UIStyle.CREAM
const BORDER_COLOR := UIStyle.BROWN
const TITLE_COLOR := UIStyle.TITLE
const TEXT_COLOR := UIStyle.TEXT
const BORDER := 3
const PADDING := 12

var bubble_width: float = 440.0
var max_height: float = 200.0

var _title: Label
var _body: Label
var _slot: VBoxContainer   # bloco extra (alternativas), abaixo do texto
var _style: StyleBoxFlat

func _init() -> void:
	name = "BalaoFala"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

	_style = UIStyle.cream_box(BG_COLOR, BORDER, 14, PADDING)
	add_theme_stylebox_override("panel", _style)

	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 2)
	add_child(box)

	_title = Label.new()
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title.add_theme_color_override("font_color", TITLE_COLOR)
	box.add_child(_title)

	_body = Label.new()
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.add_theme_color_override("font_color", TEXT_COLOR)
	box.add_child(_body)

	_slot = VBoxContainer.new()
	_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_slot.visible = false
	box.add_child(_slot)

## Mostra o balão com o título e o texto. Texto vazio esconde o balão.
func show_text(title: String, text: String) -> void:
	if text.strip_edges() == "":
		hide_bubble()
		return
	_title.text = title
	_title.visible = title != ""
	_body.text = text
	visible = true
	if is_inside_tree():
		_fit()               # já mostra no tamanho certo
	_fit.call_deferred()   # e ajusta de novo depois que o tema (tamanho do texto) estiver atualizado

func hide_bubble() -> void:
	visible = false
	clear_extra()

## Coloca um controle (ex.: bloco de alternativas) abaixo do texto. Substitui o anterior.
func set_extra(control: Control) -> void:
	clear_extra()
	_slot.add_child(control)
	_slot.visible = true
	_fit.call_deferred()

func clear_extra() -> void:
	for ch in _slot.get_children():
		_slot.remove_child(ch)
		ch.queue_free()
	_slot.visible = false

## Largura útil para o bloco extra (largura do balão menos as margens).
func inner_width() -> float:
	return bubble_width - 2.0 * PADDING

## Escolhe o maior tamanho de fonte que cabe em max_height e ajusta o tamanho do balão.
func _fit() -> void:
	if not visible:
		return
	var font: Font = _body.get_theme_font("font")
	var base_size: int = get_theme_default_font_size()   # segue Configurações > Tamanho do texto
	var inner_w := bubble_width - 2.0 * PADDING
	_body.custom_minimum_size.x = inner_w
	var chrome_h := float(PADDING * 2) + 2.0   # margens + separação
	if _slot.visible:
		chrome_h += _slot.get_combined_minimum_size().y + 6.0
	var chosen := MIN_FONT_SIZE
	for fs in range(base_size, MIN_FONT_SIZE - 1, -1):
		var title_fs := maxi(MIN_FONT_SIZE, fs - 3)
		var h := chrome_h + font.get_multiline_string_size(_body.text, HORIZONTAL_ALIGNMENT_LEFT, inner_w, fs).y
		if _title.visible:
			h += font.get_height(title_fs)
		if h <= max_height:
			chosen = fs
			break
	_body.add_theme_font_size_override("font_size", chosen)
	_title.add_theme_font_size_override("font_size", maxi(MIN_FONT_SIZE, chosen - 3))
	custom_minimum_size = Vector2(bubble_width, 0)
	size = Vector2(bubble_width, 0)
	reset_size()
	queue_redraw()

## Ponta do balão apontando para a esquerda (para o cliente). Desenhada por cima da borda.
func _draw() -> void:
	var y0 := TAIL_TOP
	var tip := Vector2(-TAIL_WIDTH, y0 + TAIL_HEIGHT * 0.35)
	var inner := float(BORDER) + 1.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(inner, y0), tip, Vector2(inner, y0 + TAIL_HEIGHT)]), BG_COLOR)
	draw_polyline(PackedVector2Array([
		Vector2(BORDER * 0.5, y0), tip, Vector2(BORDER * 0.5, y0 + TAIL_HEIGHT)]), BORDER_COLOR, float(BORDER), true)
