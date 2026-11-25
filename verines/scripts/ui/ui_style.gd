class_name UIStyle
extends RefCounted
## Estilo visual único da interface: balões creme com borda marrom e cantos arredondados,
## botões marrons com texto creme. Mude as cores aqui para alterar o jogo todo.

const CREAM := Color(1.0, 0.97, 0.89)
const CREAM_DARK := Color(0.96, 0.9, 0.78)    # cartões dentro de balões (ex.: receitas)
const BROWN := Color(0.36, 0.22, 0.12)        # bordas
const TEXT := Color(0.2, 0.13, 0.08)          # texto sobre o creme
const TITLE := Color(0.55, 0.3, 0.12)         # títulos pequenos
const BUTTON := Color(0.56, 0.35, 0.19)
const BUTTON_HOVER := Color(0.68, 0.44, 0.25)
const BUTTON_PRESSED := Color(0.42, 0.26, 0.13)
const BUTTON_TEXT := Color(1.0, 0.96, 0.88)
const NOTICE := Color(0.62, 0.32, 0.08)       # avisos (texto)
const BACKGROUND := Color(0.2, 0.14, 0.1)     # fundo quando não há cena (menus)

## Caixa creme com borda marrom e cantos arredondados (balões, painéis, cartões).
static func cream_box(bg: Color = CREAM, border: int = 3, radius: int = 14, padding: int = 12) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = BROWN
	sb.set_border_width_all(border)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(padding)
	sb.shadow_color = Color(0, 0, 0, 0.3)
	sb.shadow_size = 4
	sb.shadow_offset = Vector2(2, 3)
	return sb

static func _button_box(bg: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = BROWN
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	return sb

## Tema aplicado na raiz da interface (main.gd).
static func build_theme(font_size: int) -> Theme:
	var t := Theme.new()
	t.default_font_size = font_size
	# textos escuros (ficam sobre os balões creme)
	t.set_color("font_color", "Label", TEXT)
	# painéis = balões creme
	t.set_stylebox("panel", "PanelContainer", cream_box())
	t.set_stylebox("panel", "TooltipPanel", cream_box(CREAM, 2, 8, 6))
	t.set_color("font_color", "TooltipLabel", TEXT)
	# botões marrons
	t.set_stylebox("normal", "Button", _button_box(BUTTON))
	t.set_stylebox("hover", "Button", _button_box(BUTTON_HOVER))
	t.set_stylebox("pressed", "Button", _button_box(BUTTON_PRESSED))
	var dis := _button_box(Color(BUTTON, 0.45))
	dis.border_color = Color(BROWN, 0.5)
	t.set_stylebox("disabled", "Button", dis)
	var focus := _button_box(Color(0, 0, 0, 0))
	focus.draw_center = false
	focus.border_color = Color(1.0, 0.85, 0.5)
	t.set_stylebox("focus", "Button", focus)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		t.set_color(c, "Button", BUTTON_TEXT)
	t.set_color("font_disabled_color", "Button", Color(BUTTON_TEXT, 0.6))
	return t
