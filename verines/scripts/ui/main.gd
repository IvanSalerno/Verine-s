extends Control
<<<<<<< HEAD
## Interface do jogo. Controle EXCLUSIVAMENTE por mouse (desafios com 4 alternativas, A–D).
## O restaurante tem 3 páginas (Salão, Cozinha e Despensa), cada uma com sua cena visual.

## Estados mostrados num balão centralizado (os demais usam o balão lateral, à esquerda,
## deixando a cena visível à direita).
const CENTER_STATES := [
	GameStates.Id.MAIN_MENU, GameStates.Id.INTRO, GameStates.Id.CREDITS, GameStates.Id.SETTINGS,
	GameStates.Id.ENDING, GameStates.Id.RECIPE_BOOK, GameStates.Id.NEWSPAPER,
]
const SIDE_CARD_WIDTH := 540.0     # balão lateral (a cena aparece de x ≈ 570 em diante)
const CENTER_CARD_WIDTH := 800.0
const NOTICE_SECONDS := 5.0
=======
## Interface do jogo. Controle EXCLUSIVAMENTE por mouse (teclado numérico na tela).
## O restaurante tem 3 páginas (Salão, Cozinha e Despensa), cada uma com sua cena visual.

const HIDE_VIEW_STATES := [
	GameStates.Id.MAIN_MENU, GameStates.Id.INTRO, GameStates.Id.CREDITS, GameStates.Id.SETTINGS,
	GameStates.Id.ENDING, GameStates.Id.MATH_CHALLENGE, GameStates.Id.RECIPE_BOOK,
]
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
const MENU_BG_PATHS: Array[String] = [
	"res://assets/cenarios/livro_receitas.png",
	"res://assets/cenarios/livro de receitas.png",
]
const VIEW_SCENES := [
	"res://scenes/salao_view.tscn",
	"res://scenes/cozinha_view.tscn",
	"res://scenes/despensa_view.tscn",
]

var _panels: Dictionary = {}          # GameStates.Id -> VBoxContainer
var _bar: Control
var _menu_bg: TextureRect
var _menu_tex: Texture2D
var _nav: HBoxContainer
var _nav_buttons: Array[Button] = []
var _views: Array[Control] = []
var _last_place: int = 0
<<<<<<< HEAD
var _body: HBoxContainer
var _card: PanelContainer
var _scroll: ScrollContainer
var _content: VBoxContainer
var _toast: PanelContainer
var _toast_timer: Timer
var _menu_overlay: PanelContainer
var _intro: IntroStory
=======
var _menu_overlay: PanelContainer
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
var _menu_button: Button
var _book_button: Button
var _money_label: Label
var _day_label: Label
var _progress_label: Label
var _score_label: Label
var _msg_label: Label
var _confirm_exit: bool = false
var _confirm_delete: bool = false

<<<<<<< HEAD
# Estado da tela de desafio (4 alternativas A–D, sem teclado)
const CHOICE_BG := Color(0.96, 0.94, 0.89)
const CHOICE_HOVER := Color(1.0, 0.9, 0.72)
const CHOICE_BORDER := Color(0.7, 0.6, 0.48)
const CHOICE_RIGHT := Color(0.55, 0.85, 0.55)
const CHOICE_WRONG := Color(0.95, 0.55, 0.5)
const CHOICE_TEXT := Color(0.12, 0.1, 0.08)
var _choice_buttons: Array[Button] = []
var _recipe_buttons: Array[Button] = []
var _hint_label: Label
var _feedback_label: Label
var _continue_button: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
=======
# Estado da tela de desafio
var _answer: String = ""
var _selected_choice: int = -1
var _answer_label: Label
var _hint_label: Label
var _feedback_label: Label
var _submit_button: Button
var _continue_button: Button
var _keypad: GridContainer

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	_build_layout()
	Flow.state_changed.connect(_on_state_changed)
	Flow.order_changed.connect(_refresh)
	Flow.dish_changed.connect(_refresh)
	Flow.notice.connect(_on_notice)
	Game.money_changed.connect(_on_top_changed)
	Game.score_changed.connect(_on_top_changed)
	Game.day_changed.connect(_on_top_changed)
	Game.inventory_changed.connect(_on_inventory_changed)
	Settings.changed.connect(_apply_settings)
	_apply_settings()
	_on_state_changed(Flow.state)

func _apply_settings() -> void:
<<<<<<< HEAD
	theme = UIStyle.build_theme(Settings.TEXT_SIZES[Settings.text_size])
	if Flow.state == GameStates.Id.SETTINGS:
		_refresh()
	_fit_card.call_deferred()

# ============================================================== layout / helpers
## Camadas (de trás para a frente): fundo liso → imagem do menu → cena da página (tela toda)
## → barra superior, navegação e balão de informações → aviso → menu ☰.
func _build_layout() -> void:
	var base := ColorRect.new()
	base.color = UIStyle.BACKGROUND
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(base)
	base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# fundo do menu inicial (livro de receitas), escurecido para leitura
=======
	var t := Theme.new()
	t.default_font_size = Settings.TEXT_SIZES[Settings.text_size]
	theme = t
	if Flow.state == GameStates.Id.SETTINGS:
		_refresh()

# ============================================================== layout / helpers
func _build_layout() -> void:
	# fundo do menu inicial (livro de receitas), atrás de tudo e escurecido para leitura
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	_menu_bg = TextureRect.new()
	_menu_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_menu_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_menu_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_menu_bg.visible = false
	add_child(_menu_bg)
<<<<<<< HEAD
	_menu_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
=======
	_menu_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.5)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_menu_bg.add_child(dim)
<<<<<<< HEAD
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_menu_tex = SceneBackground.load_first(MENU_BG_PATHS)
	_menu_bg.texture = _menu_tex

	# ---- cenas das páginas, ocupando a tela toda
	var view_layer := Control.new()
	view_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(view_layer)
	view_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for path in VIEW_SCENES:
		var v: Control = load(path).instantiate()
		v.visible = false
		view_layer.add_child(v)
		v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_views.append(v)

	# ---- interface por cima da cena (contêineres não bloqueiam o mouse; só os balões e botões)
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
=======
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_menu_tex = SceneBackground.load_first(MENU_BG_PATHS)
	_menu_bg.texture = _menu_tex

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	add_child(margin)

	var root := VBoxContainer.new()
<<<<<<< HEAD
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	# ---- barra superior: cada informação num balãozinho creme
	_bar = Control.new()
	_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
=======
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	# ---- barra superior
	_bar = Control.new()
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	_bar.custom_minimum_size = Vector2(0, 58)
	root.add_child(_bar)

	# canto superior esquerdo: menu (☰), saldo e livro de receitas
	var left := HBoxContainer.new()
<<<<<<< HEAD
	left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left.add_theme_constant_override("separation", 10)
=======
	left.add_theme_constant_override("separation", 12)
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	_bar.add_child(left)
	_menu_button = MenuIconButton.new()
	_menu_button.tooltip_text = "Menu"
	_menu_button.pressed.connect(_toggle_menu)
	left.add_child(_menu_button)
	_money_label = Label.new()
	_money_label.add_theme_font_size_override("font_size", 20)
<<<<<<< HEAD
	left.add_child(_chip(_money_label))
=======
	left.add_child(_money_label)
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	_book_button = _button("Livro de receitas", Flow.open_book)
	left.add_child(_book_button)
	left.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE)

	# centro superior: contador de dias
	var center := VBoxContainer.new()
<<<<<<< HEAD
	center.add_theme_constant_override("separation", 0)
	_day_label = Label.new()
	_day_label.add_theme_font_size_override("font_size", 24)
	_day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(_day_label)
	_progress_label = Label.new()
	_progress_label.add_theme_font_size_override("font_size", 14)
	_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(_progress_label)
	var center_chip := _chip(center)
	_bar.add_child(center_chip)
	center_chip.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE)
	center_chip.grow_horizontal = Control.GROW_DIRECTION_BOTH

	# canto superior direito: placar de pontos
	_score_label = Label.new()
	_score_label.add_theme_font_size_override("font_size", 22)
	_score_label.add_theme_color_override("font_color", UIStyle.TITLE)
	var score_chip := _chip(_score_label)
	_bar.add_child(score_chip)
	score_chip.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE)
	score_chip.grow_horizontal = Control.GROW_DIRECTION_BEGIN

	# ---- navegação entre as páginas do restaurante
	_nav = HBoxContainer.new()
	_nav.mouse_filter = Control.MOUSE_FILTER_IGNORE
=======
	_bar.add_child(center)
	_day_label = Label.new()
	_day_label.add_theme_font_size_override("font_size", 28)
	_day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(_day_label)
	_progress_label = Label.new()
	_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(_progress_label)
	center.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE)
	center.grow_horizontal = Control.GROW_DIRECTION_BOTH

	# canto superior direito: placar de pontos
	_score_label = Label.new()
	_score_label.add_theme_font_size_override("font_size", 24)
	_score_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	_bar.add_child(_score_label)
	_score_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE)
	_score_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN

	# ---- navegação entre as páginas do restaurante
	_nav = HBoxContainer.new()
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	root.add_child(_nav)
	var place_names := ["Salão (atendimento)", "Cozinha", "Despensa e escritório"]
	for i in place_names.size():
		var b := _button(place_names[i], Flow.goto_place.bind(i))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_nav.add_child(b)
		_nav_buttons.append(b)

<<<<<<< HEAD
	# ---- balão de informações (pedido, dicas, botões...), com rolagem se o texto for longo
	_body = HBoxContainer.new()
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.resized.connect(_fit_card)
	root.add_child(_body)
	_card = PanelContainer.new()
	_card.custom_minimum_size.x = SIDE_CARD_WIDTH
	_body.add_child(_card)
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_card.add_child(_scroll)
	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.minimum_size_changed.connect(_fit_card_later)
	_scroll.add_child(_content)
=======
	# ---- uma cena visual por página
	for path in VIEW_SCENES:
		var v: Control = load(path).instantiate()
		v.visible = false
		root.add_child(v)
		_views.append(v)

	# ---- painéis de conteúdo
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	for id in GameStates.Id.values():
		var panel := VBoxContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.add_theme_constant_override("separation", 8)
<<<<<<< HEAD
		_content.add_child(panel)
		_panels[id] = panel

	# ---- aviso (balão no rodapé, some sozinho)
	_toast = PanelContainer.new()
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast.add_theme_stylebox_override("panel", UIStyle.cream_box(UIStyle.CREAM, 3, 14, 10))
	_toast.visible = false
	add_child(_toast)
	_toast.anchor_left = 0.5
	_toast.anchor_right = 0.5
	_toast.anchor_top = 1.0
	_toast.anchor_bottom = 1.0
	_toast.offset_left = -330
	_toast.offset_right = 330
	_toast.offset_bottom = -24
	_toast.offset_top = -60
	_toast.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_toast.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_msg_label = _label("")
	_msg_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_msg_label.add_theme_color_override("font_color", UIStyle.NOTICE)
	_msg_label.custom_minimum_size.x = 636
	_toast.add_child(_msg_label)
	_toast_timer = Timer.new()
	_toast_timer.one_shot = true
	_toast_timer.timeout.connect(_hide_notice)
	add_child(_toast_timer)

	# ---- introdução (3 cenas em tela cheia), por cima da interface
	_intro = IntroStory.new()
	_intro.visible = false
	_intro.finished.connect(Flow.finish_intro)
	add_child(_intro)
	_intro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
=======
		content.add_child(panel)
		_panels[id] = panel

	_msg_label = _label("")
	_msg_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	root.add_child(_msg_label)
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d

	# ---- menu suspenso (☰), por cima de tudo
	_menu_overlay = PanelContainer.new()
	_menu_overlay.visible = false
<<<<<<< HEAD
	_menu_overlay.position = Vector2(16, 82)
	add_child(_menu_overlay)

## Linha com a imagem do ingrediente e um texto (lista de ingredientes da cozinha).
func _icon_label(ingredient_id: String, text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var icon := TextureRect.new()
	icon.texture = IngredientArt.icon_for(ingredient_id)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(28, 28)
	row.add_child(icon)
	var lbl := _label(text)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(lbl)
	return row

## Balãozinho creme para as informações da barra superior.
func _chip(child: Control) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.add_theme_stylebox_override("panel", UIStyle.cream_box(UIStyle.CREAM, 2, 10, 6))
	chip.add_child(child)
	return chip

## Balão lateral (à esquerda, cena visível à direita) ou centralizado (menus, livro, desafios gerais).
func _set_card_mode(centered: bool) -> void:
	_body.alignment = BoxContainer.ALIGNMENT_CENTER if centered else BoxContainer.ALIGNMENT_BEGIN
	_card.custom_minimum_size.x = CENTER_CARD_WIDTH if centered else SIDE_CARD_WIDTH
	_card.size_flags_vertical = Control.SIZE_SHRINK_CENTER if centered else Control.SIZE_SHRINK_BEGIN
	_scroll.scroll_vertical = 0
	_fit_card_later()

func _fit_card_later() -> void:
	_fit_card.call_deferred()

## O balão cresce com o conteúdo até a altura disponível; daí em diante, rola.
func _fit_card() -> void:
	if _body == null or _content == null:
		return
	var pad := 24.0   # margens internas do balão (cima + baixo)
	var avail := maxf(80.0, _body.size.y - pad)
	var need := _content.get_combined_minimum_size().y
	_scroll.custom_minimum_size.y = minf(need, avail)

=======
	_menu_overlay.position = Vector2(16, 76)
	add_child(_menu_overlay)

>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
func _label(text: String, font_size: int = 0) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if font_size > 0:
		l.add_theme_font_size_override("font_size", font_size)
	return l

func _button(text: String, callback: Callable, is_disabled: bool = false) -> Button:
	var b := Button.new()
	b.text = text
	b.disabled = is_disabled
	b.custom_minimum_size = Vector2(0, 40)
	b.pressed.connect(callback)
	return b

func _begin(id: GameStates.Id) -> VBoxContainer:
	var p: VBoxContainer = _panels[id]
	for c in p.get_children():
		p.remove_child(c)
		c.queue_free()
	return p

# ==================================================================== eventos
func _on_state_changed(s: int) -> void:
<<<<<<< HEAD
	_hide_notice()
=======
	_msg_label.text = ""
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	_menu_overlay.visible = false
	_confirm_exit = false
	_confirm_delete = false
	for id in _panels:
		_panels[id].visible = (id == s)
	var in_menus: bool = s in [GameStates.Id.MAIN_MENU, GameStates.Id.INTRO, GameStates.Id.CREDITS] \
		or (s == GameStates.Id.SETTINGS and Flow.settings_return == GameStates.Id.MAIN_MENU)
	_bar.visible = not in_menus
<<<<<<< HEAD
	var intro_on := s == GameStates.Id.INTRO
	if intro_on and not _intro.visible:
		_intro.start()   # sempre começa da cena 1
	_intro.visible = intro_on
	_card.visible = not intro_on
=======
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	_menu_bg.visible = in_menus and _menu_tex != null
	_menu_button.visible = s != GameStates.Id.ENDING
	_book_button.visible = s in [GameStates.Id.RESTAURANT, GameStates.Id.ACTIVE_ORDER,
		GameStates.Id.INVESTIGATION, GameStates.Id.KITCHEN]
	# navegação e cenas
	_nav.visible = GameStates.can_navigate(s)
	var place := GameStates.place_of(s)
	if place != -1:
		_last_place = place
	for i in _nav_buttons.size():
		_nav_buttons[i].disabled = (i == place)
<<<<<<< HEAD
	# a cena da última página fica ao fundo (também atrás do livro, dos desafios e das configurações)
	var views_visible := not in_menus and s != GameStates.Id.ENDING
	var view_index := _last_place
	var bubble_challenge := SalaoView.challenge_in_bubble()
	if bubble_challenge:
		# desafio ligado ao cliente: mostra o Salão, com o enunciado no balão ao lado dele
		view_index = GameStates.Place.SALAO
	for i in _views.size():
		_views[i].visible = views_visible and i == view_index
	var centered: bool = s in CENTER_STATES or (s == GameStates.Id.MATH_CHALLENGE and not bubble_challenge)
	if s == GameStates.Id.RECIPE_BOOK and SalaoView.awaiting_recipe() and view_index == GameStates.Place.SALAO:
		centered = false   # livro ao lado, cliente e pedido à vista para comparar
	_set_card_mode(centered)
=======
	var views_visible := not (s in HIDE_VIEW_STATES)
	for i in _views.size():
		_views[i].visible = views_visible and i == _last_place
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	_refresh()

func _on_notice(text: String) -> void:
	_msg_label.text = text
<<<<<<< HEAD
	_toast.visible = text != ""
	if text != "":
		_toast.offset_top = _toast.offset_bottom - 10.0   # a altura se ajusta ao texto, crescendo para cima
		_toast_timer.start(NOTICE_SECONDS)

func _hide_notice() -> void:
	_msg_label.text = ""
	_toast.visible = false
=======
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d

func _on_top_changed(_value: int) -> void:
	_update_top_bar()

func _on_inventory_changed() -> void:
	if Flow.state == GameStates.Id.ADMINISTRATION or Flow.state == GameStates.Id.KITCHEN:
		_refresh()

func _update_top_bar() -> void:
	_money_label.text = "Saldo: " + Money.format(Game.money_cents)
	_day_label.text = "Dia %d" % Game.day
	_score_label.text = "Pontos: %d" % Game.score
<<<<<<< HEAD
	var rep := ("%.1f" % Game.reputation).replace(".", ",")
	_progress_label.text = "Pedidos: %d/%d  |  Nível %d  |  Reputação %s/5" % [Game.orders_completed, Flow.WIN_ORDERS, Flow.current_tier(), rep]
=======
	_progress_label.text = "Pedidos: %d/%d  |  Nível %d" % [Game.orders_completed, Flow.WIN_ORDERS, Flow.current_tier()]
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d

func _refresh() -> void:
	_update_top_bar()
	match Flow.state:
		GameStates.Id.MAIN_MENU: _build_menu()
		GameStates.Id.INTRO: _build_intro()
		GameStates.Id.RESTAURANT: _build_restaurant()
		GameStates.Id.ACTIVE_ORDER: _build_order()
		GameStates.Id.INVESTIGATION: _build_investigation()
		GameStates.Id.RECIPE_BOOK: _build_book()
		GameStates.Id.MATH_CHALLENGE: _build_challenge()
		GameStates.Id.KITCHEN: _build_kitchen()
		GameStates.Id.DELIVERY: _build_delivery()
		GameStates.Id.ADMINISTRATION: _build_admin()
		GameStates.Id.RESULT: _build_result()
		GameStates.Id.DAY_SUMMARY: _build_day_summary()
		GameStates.Id.SETTINGS: _build_settings()
		GameStates.Id.CREDITS: _build_credits()
		GameStates.Id.ENDING: _build_ending()
<<<<<<< HEAD
		GameStates.Id.NEWSPAPER: _build_newspaper()
=======
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d

# ============================================================ menu suspenso (☰)
func _toggle_menu() -> void:
	if _menu_overlay.visible:
		_menu_overlay.visible = false
		return
	_confirm_exit = false
	_fill_menu_overlay()
	_menu_overlay.visible = true

func _fill_menu_overlay() -> void:
	for c in _menu_overlay.get_children():
		_menu_overlay.remove_child(c)
		c.queue_free()
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(300, 0)
	box.add_theme_constant_override("separation", 6)
	_menu_overlay.add_child(box)
	box.add_child(_label("Menu", 22))
	box.add_child(_button("Salvar jogo", _on_menu_save, not Flow.can_save()))
	box.add_child(_button("Configurações", _on_menu_settings))
	if _confirm_exit:
		box.add_child(_label("O progresso não salvo será perdido."))
		box.add_child(_button("Confirmar: voltar ao menu principal", _on_menu_exit))
	else:
		box.add_child(_button("Voltar ao menu principal", _on_menu_exit_ask))
	box.add_child(_button("Fechar", _toggle_menu))

func _on_menu_save() -> void:
	_menu_overlay.visible = false
	Flow.save_now()

func _on_menu_settings() -> void:
	_menu_overlay.visible = false
	Flow.open_settings()

func _on_menu_exit_ask() -> void:
	_confirm_exit = true
	_fill_menu_overlay()

func _on_menu_exit() -> void:
	_menu_overlay.visible = false
	Flow.go(GameStates.Id.MAIN_MENU)

# ====================================================================== painéis
func _build_menu() -> void:
	var p := _begin(GameStates.Id.MAIN_MENU)
	p.add_child(_label("VERINE'S", 44))
	p.add_child(_label("Culinária, administração e matemática."))
	if Game.best_score > 0:
		p.add_child(_label("Recorde: %d pontos" % Game.best_score))
	p.add_child(_button("Novo jogo", Flow.start_game))
	var has_save := SaveSystem.has_save()
	p.add_child(_button("Continuar jogo salvo", Flow.continue_game, not has_save))
	if has_save:
		p.add_child(_label(SaveSystem.info(), 14))
	p.add_child(_button("Configurações", Flow.open_settings))
	p.add_child(_button("Créditos", Flow.open_credits))
	p.add_child(_button("Sair", get_tree().quit))

func _build_settings() -> void:
	var p := _begin(GameStates.Id.SETTINGS)
	p.add_child(_label("Configurações", 30))

	var vrow := HBoxContainer.new()
	vrow.add_child(_label("Volume: %d/10" % Settings.volume_steps))
	vrow.add_child(_button("−", Settings.change_volume.bind(-1)))
	vrow.add_child(_button("+", Settings.change_volume.bind(1)))
	p.add_child(vrow)

	var frow := HBoxContainer.new()
	frow.add_child(_label("Tela cheia: %s" % ("ligada" if Settings.fullscreen else "desligada")))
	frow.add_child(_button("Alternar", Settings.toggle_fullscreen))
	p.add_child(frow)

	var hrow := HBoxContainer.new()
	hrow.add_child(_label("Dicas do tutorial: %s" % ("ligadas" if Settings.show_hints else "desligadas")))
	hrow.add_child(_button("Alternar", Settings.toggle_hints))
	p.add_child(hrow)

<<<<<<< HEAD
	var prow := HBoxContainer.new()
	prow.add_child(_label("Paciência dos clientes (tempo): %s" % ("ligada" if Settings.patience_enabled else "desligada")))
	prow.add_child(_button("Alternar", Settings.toggle_patience))
	p.add_child(prow)

=======
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	var trow := HBoxContainer.new()
	trow.add_child(_label("Tamanho do texto: %s" % Settings.TEXT_SIZE_NAMES[Settings.text_size]))
	for i in 3:
		trow.add_child(_button(Settings.TEXT_SIZE_NAMES[i], Settings.set_text_size.bind(i), i == Settings.text_size))
	p.add_child(trow)

	if SaveSystem.has_save():
		if _confirm_delete:
			p.add_child(_button("Clique de novo para APAGAR o jogo salvo", _on_delete_save))
		else:
			p.add_child(_button("Apagar jogo salvo", _on_delete_ask))
	p.add_child(_button("Voltar", Flow.close_settings))

func _on_delete_ask() -> void:
	_confirm_delete = true
	_refresh()

func _on_delete_save() -> void:
	SaveSystem.delete()
	_confirm_delete = false
	Flow.say("Jogo salvo apagado.")
	_refresh()

func _build_credits() -> void:
	var p := _begin(GameStates.Id.CREDITS)
	p.add_child(_label("VERINE'S", 40))
	for line in Credits.LINES:
		p.add_child(_label(line))
	p.add_child(_button("Voltar", Flow.close_credits))

<<<<<<< HEAD
## A introdução é a tela IntroStory (3 cenas em tela cheia); o balão de informações fica escondido.
func _build_intro() -> void:
	_begin(GameStates.Id.INTRO)
=======
func _build_intro() -> void:
	var p := _begin(GameStates.Id.INTRO)
	p.add_child(_label("A herança do vovô", 30))
	p.add_child(_label("Você herdou de seu avô, Verine, um restaurante que precisa ser recuperado. Junto com ele veio um livro de receitas antigo, com páginas manchadas e incompletas.\n\nAtenda os clientes no Salão, prepare os pratos na Cozinha, cuide do estoque na Despensa e reinvista o lucro. Cada pedido pode esconder uma pista sobre os segredos do restaurante."))
	p.add_child(_label("Controles: o jogo é jogado somente com o mouse. As respostas numéricas usam o teclado na tela. Use o botão de menu (três linhas, no canto superior esquerdo) para salvar."))
	p.add_child(_button("Abrir o restaurante", Flow.finish_intro))
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d

# ------------------------------------------------------------------- SALÃO
func _build_restaurant() -> void:
	var p := _begin(GameStates.Id.RESTAURANT)
	p.add_child(_label("Salão do restaurante", 28))
	p.add_child(_label("Pedidos concluídos: %d de %d.   Pedidos de hoje: %d de %d." % [
		Game.orders_completed, Flow.WIN_ORDERS, Game.orders_today, Flow.ORDERS_PER_DAY]))
<<<<<<< HEAD
	var special_text := _special_text()
	if special_text != "":
		p.add_child(_label(special_text))
	var ev: Dictionary = GameData.EVENTS.get(Game.today_event, {})
	if Game.today_event != "normal" and not ev.is_empty():
		p.add_child(_label("Hoje: %s — %s" % [ev["title"], ev["text"]], 16))
	p.add_child(_label(Flow.chapter_goal_status(), 16))
	p.add_child(_label("Contas de hoje (aluguel e luz): %s, cobradas ao fechar o dia." % Money.format(Game.rent_today()), 16))
	if Game.days_in_red > 0:
		p.add_child(_label("Atenção: saldo negativo há %d dia(s) seguidos. Com %d, o restaurante fecha!" % [Game.days_in_red, Game.BANKRUPT_DAYS], 16))
	if Flow.waiting != null:
		p.add_child(_button("Atender %s (na fila)" % Flow.waiting.customer_name, Flow.call_next_customer))
	else:
		p.add_child(_button("Chamar próximo cliente", Flow.call_next_customer))

func _special_text() -> String:
	if not GameData.recipes.has(Game.daily_special):
		return ""
	var r: Recipe = GameData.recipes[Game.daily_special]
	return "Prato do dia: %s (+%d%% no valor se for pedido hoje; chega mais pedidos dele)" % [r.display_name, int(Flow.SPECIAL_BONUS_PERCENT)]
=======
	p.add_child(_button("Chamar próximo cliente", Flow.call_next_customer))
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d

func _build_order() -> void:
	var p := _begin(GameStates.Id.ACTIVE_ORDER)
	var o := Flow.order
	if o == null:
		return
	p.add_child(_label("Cliente: %s" % o.customer_name, 26))
<<<<<<< HEAD
	if not SalaoView.order_in_bubble():
		p.add_child(_label("\"%s\"" % o.description))
	p.add_child(_label("Porções: %d   |   Situação: %s" % [o.servings, Order.state_name(o.state)]))
	if o.is_phone():
		p.add_child(_label("Pedido por telefone — entrega em: %s" % o.address, 16))
	if not o.restrictions.is_empty():
		p.add_child(_label("Restrição alimentar: %s. Na cozinha, use os ingredientes substitutos (compre na Despensa)." % GameData.restriction_text(o.restrictions), 16))
	if Flow.waiting != null:
		p.add_child(_label("Na fila: %s (a paciência dele também está passando)." % Flow.waiting.customer_name, 16))
=======
	p.add_child(_label("\"%s\"" % o.description))
	p.add_child(_label("Porções: %d   |   Situação: %s" % [o.servings, Order.state_name(o.state)]))
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	if Game.orders_completed == 0 and Settings.show_hints:
		p.add_child(_label(_tutorial_hint(o), 16))

	match o.state:
		Order.State.CREATED, Order.State.INVESTIGATING:
<<<<<<< HEAD
			_add_recipe_choice(p, o)
=======
			p.add_child(_button("Investigar e escolher a receita", Flow.open_investigation))
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
		Order.State.IDENTIFIED:
			var recipe: Recipe = GameData.recipes[o.selected_recipe_id]
			p.add_child(_label("Receita escolhida: %s. Agora vá para a Cozinha: lá você ajusta as quantidades e prepara o prato." % recipe.display_name))
			p.add_child(_button("Ir para a cozinha", Flow.goto_place.bind(GameStates.Place.COZINHA)))
		Order.State.PREPARING:
			if Flow.dish != null and Flow.dish.state == Dish.State.READY:
				p.add_child(_label("O prato está pronto! Entregue ao cliente."))
				p.add_child(_button("Entregar ao cliente", Flow.start_delivery))
			else:
				p.add_child(_label("O prato ainda está sendo preparado na Cozinha."))
				p.add_child(_button("Ir para a cozinha", Flow.goto_place.bind(GameStates.Place.COZINHA)))
	p.add_child(_button("Cancelar pedido", Flow.cancel_order))

<<<<<<< HEAD
## Descobrir a receita: pistas + livro de receitas; a resposta é o NOME da receita,
## escolhido no bloco branco abaixo do pedido (no balão do cliente).
func _add_recipe_choice(p: VBoxContainer, o: Order) -> void:
=======
func _tutorial_hint(o: Order) -> String:
	match o.state:
		Order.State.CREATED, Order.State.INVESTIGATING:
			return "Dica: leia o pedido e compare com as receitas do livro. Neste pedido o cliente cita o prato."
		Order.State.IDENTIFIED:
			return "Dica: na Cozinha, resolva os desafios para ajustar as quantidades. Se faltar ingrediente, compre na Despensa."
		Order.State.PREPARING:
			return "Dica: execute cada etapa na Cozinha; com o prato pronto, volte ao Salão para entregar."
	return ""

func _build_investigation() -> void:
	var p := _begin(GameStates.Id.INVESTIGATION)
	var o := Flow.order
	if o == null:
		return
	p.add_child(_label("Investigação — pedido de %s" % o.customer_name, 26))
	p.add_child(_label("\"%s\"" % o.description))
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	p.add_child(_label("Pistas:", 20))
	var shown := o.visible_clues()
	if shown.is_empty():
		p.add_child(_label("(Sem pistas adicionais. Releia o pedido.)"))
	for cid in shown:
		var clue: Clue = GameData.clues[cid]
		p.add_child(_label("• " + clue.text))
	p.add_child(_button("Pedir pista extra (reduz o pagamento)", Flow.reveal_hint,
		o.hints_used >= o.hidden_clue_ids.size()))
<<<<<<< HEAD
	p.add_child(_label("Consulte o livro e escolha o nome da receita no balão do cliente."))
	p.add_child(_button("Abrir o livro de receitas", Flow.open_book))
	_place_recipe_names(p)

## Nomes das receitas (bloco branco): no balão do cliente quando o Salão está à vista; senão, no balão de informações.
func _place_recipe_names(p: VBoxContainer) -> void:
	var salao := _views[GameStates.Place.SALAO] as SalaoView
	if salao != null and SalaoView.order_in_bubble() and _views[GameStates.Place.SALAO].visible:
		salao.set_answer_block(_recipe_names_block(salao.answer_block_width()))
	else:
		p.add_child(_recipe_names_block(SIDE_CARD_WIDTH - 40.0))

func _recipe_names_block(width: float) -> PanelContainer:
	var names: Array[String] = []
	for rid in Game.unlocked_recipes:
		var r: Recipe = GameData.recipes[rid]
		names.append(r.display_name)
	_recipe_buttons.clear()
	return _options_block(names, width, _on_pick_recipe, _recipe_buttons)

func _on_pick_recipe(index: int) -> void:
	if index >= Game.unlocked_recipes.size() or index >= _recipe_buttons.size():
		return
	var rid: String = Game.unlocked_recipes[index]
	var b := _recipe_buttons[index]
	if not Flow.choose_recipe(rid) and is_instance_valid(b):
		_style_choice(b, CHOICE_WRONG)   # receita errada: conta erro e fica desativada
		b.disabled = true

func _tutorial_hint(o: Order) -> String:
	match o.state:
		Order.State.CREATED, Order.State.INVESTIGATING:
			return "Dica: leia o pedido, abra o livro de receitas e compare. Depois clique no nome da receita, no balão do cliente. Neste pedido o cliente cita o prato."
		Order.State.IDENTIFIED:
			return "Dica: na Cozinha, resolva os desafios para ajustar as quantidades. Se faltar ingrediente, compre na Despensa."
		Order.State.PREPARING:
			return "Dica: execute cada etapa na Cozinha; com o prato pronto, volte ao Salão para entregar."
	return ""

## Estado antigo (saves): mostra o mesmo atendimento simplificado.
func _build_investigation() -> void:
	var p := _begin(GameStates.Id.INVESTIGATION)
	var o := Flow.order
	if o == null:
		return
	p.add_child(_label("Pedido de %s" % o.customer_name, 26))
	if SalaoView.awaiting_recipe():
		_add_recipe_choice(p, o)
	p.add_child(_button("Voltar", Flow.go.bind(GameStates.Id.ACTIVE_ORDER)))

## Livro de receitas: detalhes de cada receita. Se um cliente espera a resposta, os nomes
## continuam no balão dele (o livro fica no balão lateral para o cliente seguir à vista).
func _build_book() -> void:
	var p := _begin(GameStates.Id.RECIPE_BOOK)
	p.add_child(_label("Livro de receitas do vovô", 26))
	var choosing := SalaoView.awaiting_recipe() and Flow.order != null and not Flow.order.is_closed()
	if choosing:
		p.add_child(_label("Compare com o pedido de %s e clique no nome da receita no balão dele." % Flow.order.customer_name, 16))
		_place_recipe_names(p)
=======
	p.add_child(_label("Receitas do livro:", 20))
	for rid in Game.unlocked_recipes:
		p.add_child(_recipe_card(GameData.recipes[rid], true))
	p.add_child(_button("Voltar", Flow.go.bind(GameStates.Id.ACTIVE_ORDER)))

func _build_book() -> void:
	var p := _begin(GameStates.Id.RECIPE_BOOK)
	p.add_child(_label("Livro de receitas do vovô", 26))
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	for rid in Game.unlocked_recipes:
		p.add_child(_recipe_card(GameData.recipes[rid], false))
	p.add_child(_button("Fechar o livro", Flow.close_book))

func _recipe_card(recipe: Recipe, selectable: bool) -> Control:
	var card := PanelContainer.new()
<<<<<<< HEAD
	card.add_theme_stylebox_override("panel", UIStyle.cream_box(UIStyle.CREAM_DARK, 2, 10, 10))
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)
	var dish_tex := IngredientArt.dish_image(recipe.id)
	if dish_tex != null:   # foto do prato pronto (assets/pratos/<id>.png)
		var pic := TextureRect.new()
		pic.texture = dish_tex
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic.custom_minimum_size = Vector2(96, 96)
		pic.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		row.add_child(pic)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(box)
	box.add_child(_label(recipe.display_name, 20))
	box.add_child(_label(recipe.description))
	box.add_child(_label("Rende %d porções (dados originais)" % recipe.base_servings))
	if recipe.has_heat():
		box.add_child(_label("Etapa com fogo \"%s\": tempo ideal = %d + %d × p minutos (p = nº de porções)" % [
			recipe.steps[recipe.heat_step], recipe.heat_base, recipe.heat_per_serving]))
=======
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var box := VBoxContainer.new()
	card.add_child(box)
	box.add_child(_label(recipe.display_name, 20))
	box.add_child(_label(recipe.description))
	box.add_child(_label("Rende %d porções (dados originais)" % recipe.base_servings))
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	for line in recipe.lines:
		var ing: Ingredient = GameData.ingredients[line["ingredient_id"]]
		var unit: Units.Unit = line["unit"]
		if Game.is_line_known(recipe, line):
			var rec_note := " (recuperado)" if line["hidden"] else ""
<<<<<<< HEAD
			box.add_child(_icon_label(ing.id, "%s: %s %s%s" % [ing.display_name,
=======
			box.add_child(_label("• %s: %s %s%s" % [ing.display_name,
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
				Units.fmt_amount(Game.get_known_amount(recipe, line)), Units.label(unit), rec_note]))
		else:
			box.add_child(_label("• %s: ??? %s (página manchada)" % [ing.display_name, Units.label(unit)]))
	var clue_texts: PackedStringArray = []
	for cid in recipe.clue_ids:
		var clue: Clue = GameData.clues[cid]
		clue_texts.append(clue.text)
	box.add_child(_label("Pistas relacionadas: " + " / ".join(clue_texts)))
	if not selectable:
		box.add_child(_label("Preparo: " + " → ".join(recipe.steps)))
	else:
		box.add_child(_button("Escolher esta receita", Flow.select_recipe.bind(recipe.id)))
	return card

func _build_delivery() -> void:
	var p := _begin(GameStates.Id.DELIVERY)
	var o := Flow.order
	if o == null:
		return
	p.add_child(_label("Entrega para %s" % o.customer_name, 26))
	p.add_child(_label("Valor do prato: %s" % Money.format(Flow.delivery_bill_cents)))
<<<<<<< HEAD
	if o.is_phone():
		p.add_child(_label("Entrega por telefone: %s" % o.address))
		if Flow.delivery_freight_cents > 0:
			p.add_child(_label("Frete: %s (entra na conta)" % Money.format(Flow.delivery_freight_cents)))
	for step in Flow.delivery_steps():
=======
	for step in [["portion", "Dividir o prato"], ["change", "Receber pagamento e dar o troco"]]:
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
		var done: bool = Flow.delivery_steps_done.has(step[0])
		p.add_child(_label("%s %s" % ["[x]" if done else "[ ]", step[1]]))
	p.add_child(_button(Flow.delivery_next_label(), Flow.delivery_next))

func _build_result() -> void:
	var p := _begin(GameStates.Id.RESULT)
	var r := Flow.last_result
	if r.is_empty():
		return
<<<<<<< HEAD
	var reactions := ["Péssimo!", "Meh...", "Bom.", "Muito bom!", "Excelente!"]
	var stars := clampi(int(r["stars"]), 1, 5)
	p.add_child(_label("Atendimento concluído — %s" % r["customer"], 26))
	p.add_child(_label("Reação do cliente: %s   (%d de 5 estrelas, felicidade %d%%)" % [reactions[stars - 1], stars, int(r["satisfaction"])], 20))
	if str(r["cook"]) != "":
		p.add_child(_label("Cozimento: %s   |   Respostas erradas: %d   |   Pistas extras: %d" % [r["cook"], r["mistakes"], r["hints"]]))
	else:
		p.add_child(_label("Respostas erradas: %d   |   Pistas extras: %d" % [r["mistakes"], r["hints"]]))
	p.add_child(_label("Preço-base: %s" % Money.format(r["base"])))
	p.add_child(_label("Melhorias e reputação: %s" % Money.format(r["upgrade_bonus"])))
	if int(r["special_bonus"]) > 0:
		p.add_child(_label("Prato do dia: +%s" % Money.format(r["special_bonus"])))
	p.add_child(_label("Gorjeta: +%s" % Money.format(r["tip"])))
	if int(r.get("freight", 0)) > 0:
		p.add_child(_label("Frete da entrega: +%s" % Money.format(r["freight"])))
	if int(r.get("patience", -1)) >= 0:
		p.add_child(_label("Paciência restante: %d%%   |   Porção: %s" % [int(r["patience"]), Flow.PORTION_NAMES.get(str(r.get("portion", "normal")), "Normal")]))
	elif str(r.get("portion", "normal")) != "normal":
		p.add_child(_label("Porção: %s" % Flow.PORTION_NAMES.get(str(r["portion"]), "Normal")))
	if int(r["refund"]) > 0:
		p.add_child(_label("Reembolso (cliente insatisfeito): −%s" % Money.format(r["refund"])))
=======
	p.add_child(_label("Atendimento concluído — %s" % r["customer"], 26))
	p.add_child(_label("Preço-base: %s" % Money.format(r["base"])))
	p.add_child(_label("Bônus de melhorias: %s" % Money.format(r["upgrade_bonus"])))
	p.add_child(_label("Bônus por atendimento perfeito: %s" % Money.format(r["bonus"])))
	p.add_child(_label("Penalidades (%d erro(s), %d pista(s) extra): −%s" % [
		r["mistakes"], r["hints"], Money.format(r["penalty"])]))
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	p.add_child(_label("Total recebido: %s" % Money.format(r["total"]), 22))
	p.add_child(_label("Pontos ganhos neste pedido: +%d" % int(r["points"])))
	if str(r["story"]) != "":
		p.add_child(_label(str(r["story"])))
	p.add_child(_button("Continuar", Flow.continue_after_result))

func _build_day_summary() -> void:
	var p := _begin(GameStates.Id.DAY_SUMMARY)
	p.add_child(_label("Fim do dia %d" % Game.day, 30))
<<<<<<< HEAD
	p.add_child(_label("Pedidos atendidos hoje: %d   |   Reputação: %s de 5" % [Game.orders_today, ("%.1f" % Game.reputation).replace(".", ",")]))
	p.add_child(_label("Aluguel e contas cobrados hoje: %s" % Money.format(Flow.last_rent_cents)))
	p.add_child(_label("Receita do dia: %s   |   Despesas do dia: %s   |   Lucro do dia: %s" % [
		Money.format(Game.day_income()), Money.format(Game.day_expenses()),
		Money.format(Game.day_income() - Game.day_expenses())]))
	if Game.money_cents < 0:
		p.add_child(_label("Saldo NEGATIVO (%s)! Se o dia começar assim por %d dias seguidos, o restaurante fecha. Peça ajuda ao vizinho na Despensa ou capriche nos próximos pedidos." % [
			Money.format(Game.money_cents), Game.BANKRUPT_DAYS], 18))
	p.add_child(_label(Flow.chapter_goal_status(), 16))
=======
	p.add_child(_label("Pedidos atendidos hoje: %d" % Game.orders_today))
	p.add_child(_label("Receita do dia: %s   |   Despesas do dia: %s   |   Lucro do dia: %s" % [
		Money.format(Game.day_income()), Money.format(Game.day_expenses()),
		Money.format(Game.day_income() - Game.day_expenses())]))
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	if not Game.day_history.is_empty():
		p.add_child(_label("Dias anteriores:", 20))
		var start := maxi(0, Game.day_history.size() - 5)
		for i in range(start, Game.day_history.size()):
			var e: Dictionary = Game.day_history[i]
			p.add_child(_label("• Dia %d: lucro %s (%d pedidos)" % [e["day"], Money.format(e["profit"]), e["orders"]]))
	if Game.daily_challenge_done:
		p.add_child(_label("Desafio de gestão de hoje: concluído!"))
	else:
		p.add_child(_label("Desafio de gestão do dia (opcional): vale bônus em dinheiro e pontos."))
		p.add_child(_button("Resolver o desafio de gestão", Flow.start_daily_challenge))
	p.add_child(_button("Começar o dia %d (salva automaticamente)" % (Game.day + 1), Flow.start_next_day))

# ----------------------------------------------------------------- COZINHA
func _build_kitchen() -> void:
	var p := _begin(GameStates.Id.KITCHEN)
	p.add_child(_label("Cozinha", 28))
	var o := Flow.order
	if o == null or o.is_closed():
		p.add_child(_label("Nenhum pedido em andamento. Chame um cliente no Salão."))
		p.add_child(_button("Ir para o salão", Flow.goto_place.bind(GameStates.Place.SALAO)))
		return
	if Game.orders_completed == 0 and Settings.show_hints:
		p.add_child(_label(_tutorial_hint(o), 16))
	match o.state:
		Order.State.CREATED, Order.State.INVESTIGATING:
			p.add_child(_label("Ainda não sabemos qual prato %s pediu. Descubra a receita no Salão." % o.customer_name))
			p.add_child(_button("Ir para o salão", Flow.goto_place.bind(GameStates.Place.SALAO)))
		Order.State.IDENTIFIED:
			_build_kitchen_prep(p, o)
		Order.State.PREPARING:
			_build_kitchen_cooking(p)
		_:
			p.add_child(_label("Nada para cozinhar agora."))

func _build_kitchen_prep(p: VBoxContainer, o: Order) -> void:
	var recipe: Recipe = GameData.recipes[o.selected_recipe_id]
	p.add_child(_label("Receita: %s — %d porções" % [recipe.display_name, o.servings], 22))
	if Flow.adjusted != null:
		p.add_child(_label("Ingredientes para %d porções:" % o.servings, 18))
		for line in Flow.adjusted.lines:
			var ing: Ingredient = GameData.ingredients[line["ingredient_id"]]
<<<<<<< HEAD
			var orig_id: String = str(line.get("original_id", ing.id))
			var pct := o.mod_percent(orig_id)
			if pct <= -100:
				var orig_ing: Ingredient = GameData.ingredients[orig_id]
				p.add_child(_icon_label(orig_id, "%s: NÃO USAR (o cliente pediu sem)" % orig_ing.display_name))
				continue
			var swap_text := ""
			if orig_id != ing.id:
				var o_ing: Ingredient = GameData.ingredients[orig_id]
				swap_text = " (no lugar de %s)" % o_ing.display_name
			var amount_text := "???"
			var needs_calc: bool = Flow.adjusted.servings != recipe.base_servings or not o.mods.is_empty()
			var hidden_by_scaling: bool = needs_calc and not Flow.challenge_queue.is_empty()
			if line["known"] and not hidden_by_scaling:
				amount_text = "%s %s" % [Units.fmt_amount(line["amount"]), Units.label(line["unit"])]
			var mod_text := ""
			if pct != 0:
				mod_text = "  [pedido: %s%d%%]" % ["+" if pct > 0 else "−", absi(pct)]
			p.add_child(_icon_label(ing.id, "%s%s: %s%s   (estoque: %d %s)" % [ing.display_name, swap_text, amount_text, mod_text,
=======
			var amount_text := "???"
			var hidden_by_scaling: bool = Flow.adjusted.servings != recipe.base_servings and not Flow.challenge_queue.is_empty()
			if line["known"] and not hidden_by_scaling:
				amount_text = "%s %s" % [Units.fmt_amount(line["amount"]), Units.label(line["unit"])]
			p.add_child(_label("• %s: %s   (estoque: %d %s)" % [ing.display_name, amount_text,
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
				Game.get_stock(ing.id), Units.label(ing.unit)]))
	if not Flow.challenge_queue.is_empty():
		p.add_child(_label("Faltam %d desafio(s) para fechar as quantidades." % Flow.challenge_queue.size()))
		p.add_child(_button("Resolver próximo desafio", Flow.next_order_challenge))
	elif Flow.is_ready_to_cook():
<<<<<<< HEAD
		_add_portion_choice(p, o)
		p.add_child(_button("Começar a preparar", Flow.start_preparation))
	p.add_child(_button("Comprar ingredientes na Despensa", Flow.goto_place.bind(GameStates.Place.DESPENSA)))

## Porção econômica (gasta menos, cliente menos feliz) × generosa (gasta mais, cliente mais feliz).
func _add_portion_choice(p: VBoxContainer, o: Order) -> void:
	p.add_child(_label("Tamanho da porção:", 18))
	var row := HBoxContainer.new()
	for style in ["economica", "normal", "generosa"]:
		var pct := roundi((float(Flow.PORTION_FACTORS[style]) - 1.0) * 100.0)
		var txt := "%s (%s%d%%)" % [Flow.PORTION_NAMES[style], "+" if pct > 0 else ("−" if pct < 0 else "±"), absi(pct)]
		var b := _button(txt, Flow.set_portion.bind(style), o.portion_style == style)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(b)
	p.add_child(row)
	var sat := int(Flow.PORTION_SATISFACTION[o.portion_style])
	var desc := "Usa a receita exata."
	if sat < 0:
		desc = "Economiza 20%% dos ingredientes, mas o cliente fica menos feliz (%d de felicidade)." % sat
	elif sat > 0:
		desc = "Gasta 20%% a mais de ingredientes, e o cliente fica mais feliz (+%d de felicidade)." % sat
	p.add_child(_label(desc, 16))
	var use := Flow.portion_adjusted()
	if use != null and o.portion_style != "normal":
		var parts: PackedStringArray = []
		for line in use.lines:
			if int(line["base_needed"]) > 0:
				var ing: Ingredient = GameData.ingredients[line["ingredient_id"]]
				parts.append("%s %d %s" % [ing.display_name, int(line["base_needed"]), Units.label(ing.unit)])
		p.add_child(_label("Vai sair do estoque: " + ", ".join(parts), 16))

=======
		p.add_child(_button("Começar a preparar", Flow.start_preparation))
	p.add_child(_button("Comprar ingredientes na Despensa", Flow.goto_place.bind(GameStates.Place.DESPENSA)))

>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
func _build_kitchen_cooking(p: VBoxContainer) -> void:
	var d := Flow.dish
	if d == null:
		return
	var recipe: Recipe = GameData.recipes[d.recipe_id]
	p.add_child(_label("Preparando: %s (%d porções)" % [recipe.display_name, d.servings], 22))
	for i in d.steps.size():
		var mark := "[ ]"
		if i < d.steps_done:
			mark = "[x]"
		elif i == d.steps_done and d.state == Dish.State.PREPARING:
			mark = "[>]"
<<<<<<< HEAD
		var step_text := "%s %s" % [mark, d.steps[i]]
		if i == recipe.heat_step and i < d.steps_done and d.cook_result != "":
			step_text += "  (cozimento: %s)" % d.cook_result
		p.add_child(_label(step_text))
	if d.state == Dish.State.PREPARING:
		if Flow.is_assembly_step():
			var rec: Recipe = GameData.recipes[d.recipe_id]
			var burger: bool = rec.stacked
			if burger:
				var first_name := ""
				if rec.assembly_first != "":
					first_name = " Comece pela base: %s." % (GameData.ingredients[rec.assembly_first] as Ingredient).display_name
				var extra := ""
				if rec.layer_images.has("farinha"):
					extra = " A farinha vira a massa da pizza."
				if "pao_hamburguer" in Flow.assembly_required():
					extra = " A tampa do pão vem no final."
				p.add_child(_label("Monte: %s. Arraste os ingredientes certos da bancada até o prato (ou clique neles); cada um cai como uma camada.%s%s Ingrediente errado conta como erro." % [rec.display_name, first_name, extra], 18))
			else:
				p.add_child(_label("Montagem: arraste os ingredientes certos da bancada até a tigela (ou clique neles). Ingrediente errado conta como erro.", 18))
			p.add_child(_label("%s: %d de %d." % ["No prato" if burger else "Na tigela", d.placed.size(), Flow.assembly_required().size()]))
		elif Flow.is_heat_step():
			_build_heat_controls(p, recipe, d)
		else:
			p.add_child(_button("Executar: %s" % d.next_step_label(), Flow.do_prep_step))
=======
		p.add_child(_label("%s %s" % [mark, d.steps[i]]))
	if d.state == Dish.State.PREPARING:
		p.add_child(_button("Executar: %s" % d.next_step_label(), Flow.do_prep_step))
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	elif d.state == Dish.State.READY:
		p.add_child(_label("O prato está pronto! Leve ao cliente no Salão.", 20))
		p.add_child(_button("Ir para o salão", Flow.goto_place.bind(GameStates.Place.SALAO)))

<<<<<<< HEAD
## Etapa com fogo/forno: o jogador calcula o tempo (função do 1º grau) e ajusta o timer.
func _build_heat_controls(p: VBoxContainer, recipe: Recipe, d: Dish) -> void:
	p.add_child(_label("Etapa com fogo: %s" % d.next_step_label(), 20))
	p.add_child(_label("Tempo ideal = %d + %d × p minutos, com p = número de porções (%d). Calcule e ajuste o timer." % [
		recipe.heat_base, recipe.heat_per_serving, d.servings]))
	p.add_child(_label("Margem para o ponto perfeito: ±%d min (melhore comprando um forno melhor na Despensa)." % Flow.heat_tolerance()))
	p.add_child(_label("Timer: %d min" % Flow.heat_minutes, 26))
	var row := HBoxContainer.new()
	for delta in [-5, -1, 1, 5]:
		var text := ("+%d" % delta) if delta > 0 else str(delta)
		var b := _button(text, Flow.heat_adjust.bind(delta))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(b)
	p.add_child(row)
	p.add_child(_button("Ligar por %d min" % Flow.heat_minutes, Flow.do_heat_step))

# ---------------------------------------------------------------- DESAFIO
## Toda questão tem 4 alternativas (A, B, C, D) num bloco branco logo abaixo do enunciado.
## Desafios do cliente: enunciado + bloco no balão ao lado dele (Salão). Os demais: no painel.
## Clicar numa alternativa já responde: certa fica verde, errada fica vermelha (e conta erro).
=======
# ---------------------------------------------------------------- DESAFIO
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
func _build_challenge() -> void:
	var p := _begin(GameStates.Id.MATH_CHALLENGE)
	var c := Flow.current_challenge
	if c == null:
		return
<<<<<<< HEAD
	_choice_buttons.clear()
	var salao := _views[GameStates.Place.SALAO] as SalaoView
	if SalaoView.challenge_in_bubble() and salao != null:
		p.add_child(_label("%s pergunta — escolha uma alternativa no balão." % Flow.order.customer_name, 20))
		salao.set_answer_block(_choices_block(c, salao.answer_block_width()))
	else:
		p.add_child(_label("Desafio: %s (nível %d)" % [c.topic, c.tier], 26))
		p.add_child(_label(c.statement))
		var block := _choices_block(c, CENTER_CARD_WIDTH - 60.0)
		block.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		p.add_child(block)

	_feedback_label = _label("")
	p.add_child(_feedback_label)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	p.add_child(row)
	_continue_button = _button("Continuar", Flow.leave_challenge)
	_continue_button.visible = false
	row.add_child(_continue_button)
	row.add_child(_button("Pedir uma dica", _on_hint))
	row.add_child(_button("Voltar (resolver depois)", Flow.leave_challenge))
	_hint_label = _label("")
	p.add_child(_hint_label)

## Bloco branco com as 4 alternativas (A–D) do desafio.
func _choices_block(c: MathChallenge, width: float) -> PanelContainer:
	var texts: Array[String] = []
	for i in c.choices.size():
		texts.append(ChoiceMaker.label(i, c.choices[i]))
	_choice_buttons.clear()
	return _options_block(texts, width, _on_choice, _choice_buttons)

## Bloco branco com botões de opção. Duas colunas se os textos couberem; senão, uma.
## Cada botão chama on_pick(índice); os botões criados vão para out_buttons.
func _options_block(texts: Array[String], width: float, on_pick: Callable, out_buttons: Array[Button]) -> PanelContainer:
	var block := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color.WHITE
	sb.border_color = CHOICE_BORDER
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(8)
	block.add_theme_stylebox_override("panel", sb)
	block.custom_minimum_size.x = width

	var grid := GridContainer.new()
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	block.add_child(grid)

	var font := get_theme_default_font()
	var fs := get_theme_default_font_size()
	var widest := 0.0
	for t in texts:
		widest = maxf(widest, font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 28.0)
	var inner := width - 16.0
	grid.columns = 2 if widest <= (inner - 6.0) / 2.0 else 1

	for i in texts.size():
		var b := Button.new()
		b.text = texts[i]
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size = Vector2((inner - 6.0) / grid.columns, 36)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.clip_text = true
		b.tooltip_text = texts[i]
		_style_choice(b, CHOICE_BG)
		b.pressed.connect(on_pick.bind(i))
		grid.add_child(b)
		out_buttons.append(b)
	return block

func _style_choice(b: Button, bg: Color) -> void:
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		var st := StyleBoxFlat.new()
		st.bg_color = CHOICE_HOVER if state_name == "hover" else bg
		st.border_color = CHOICE_BORDER
		st.set_border_width_all(1)
		st.set_corner_radius_all(6)
		st.content_margin_left = 10
		st.content_margin_right = 10
		if state_name == "focus":
			st.draw_center = false
		b.add_theme_stylebox_override(state_name, st)
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
		b.add_theme_color_override(color_name, CHOICE_TEXT)
=======
	_answer = ""
	_selected_choice = -1
	p.add_child(_label("Desafio: %s (nível %d)" % [c.topic, c.tier], 26))
	p.add_child(_label(c.statement))
	_hint_label = _label("")
	p.add_child(_hint_label)
	p.add_child(_button("Pedir uma dica", _on_hint))

	_answer_label = _label("Resposta: ", 22)
	p.add_child(_answer_label)

	if c.type == MathChallenge.Type.MULTIPLE_CHOICE:
		for i in c.choices.size():
			p.add_child(_button(c.choices[i], _on_choice.bind(i)))
	else:
		_keypad = GridContainer.new()
		_keypad.columns = 4
		var keys := ["7", "8", "9", "⌫", "4", "5", "6", "C", "1", "2", "3", ",", "0", "/", ";", "-"]
		for k in keys:
			var kb := _button(k, _on_key.bind(k))
			kb.custom_minimum_size = Vector2(70, 44)
			_keypad.add_child(kb)
		p.add_child(_keypad)

	_feedback_label = _label("")
	p.add_child(_feedback_label)
	_submit_button = _button("Responder", _on_submit)
	p.add_child(_submit_button)
	_continue_button = _button("Continuar", Flow.leave_challenge)
	_continue_button.visible = false
	p.add_child(_continue_button)
	p.add_child(_button("Voltar (resolver depois)", Flow.leave_challenge))
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d

func _on_hint() -> void:
	if Flow.current_challenge != null:
		_hint_label.text = "Dica: " + Flow.current_challenge.hint

<<<<<<< HEAD
func _on_choice(index: int) -> void:
	if Flow.current_challenge == null or index >= _choice_buttons.size():
		return
	var res := Flow.submit_answer(index)
	_feedback_label.text = res["message"]
	var b := _choice_buttons[index]
	if res["ok"]:
		_style_choice(b, CHOICE_RIGHT)
		for other in _choice_buttons:
			other.disabled = true
		_continue_button.visible = true
	else:
		_style_choice(b, CHOICE_WRONG)
		b.disabled = true
=======
func _on_key(k: String) -> void:
	if k == "⌫":
		_answer = _answer.left(maxi(0, _answer.length() - 1))
	elif k == "C":
		_answer = ""
	else:
		_answer += k
	_answer_label.text = "Resposta: " + _answer

func _on_choice(index: int) -> void:
	_selected_choice = index
	var c := Flow.current_challenge
	_answer_label.text = "Resposta: " + c.choices[index]

func _on_submit() -> void:
	var c := Flow.current_challenge
	if c == null:
		return
	var raw: Variant
	if c.type == MathChallenge.Type.MULTIPLE_CHOICE:
		if _selected_choice < 0:
			_feedback_label.text = "Escolha uma alternativa."
			return
		raw = _selected_choice
	else:
		if _answer.strip_edges() == "":
			_feedback_label.text = "Digite uma resposta no teclado da tela."
			return
		raw = _answer
	var res := Flow.submit_answer(raw)
	_feedback_label.text = res["message"]
	if res["ok"]:
		_submit_button.disabled = true
		_continue_button.visible = true
		if _keypad != null:
			for kb in _keypad.get_children():
				(kb as Button).disabled = true
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d

# ----------------------------------------------------------------- DESPENSA
func _build_admin() -> void:
	var p := _begin(GameStates.Id.ADMINISTRATION)
	p.add_child(_label("Despensa e escritório", 28))
	p.add_child(_label("Saldo: %s   |   Receita: %s   |   Despesas: %s   |   Lucro: %s" % [
		Money.format(Game.money_cents), Money.format(Game.total_income),
		Money.format(Game.total_expenses), Money.format(Game.profit())]))
	if Game.next_purchase_discount_percent > 0.0:
		p.add_child(_label("Desconto ativo na próxima compra: %d%%" % int(Game.next_purchase_discount_percent)))

	p.add_child(_label("Estoque e compras", 20))
	for id in GameData.ingredients:
		var ing: Ingredient = GameData.ingredients[id]
		var limit := Game.get_storage_limit(id)
		var txt := "%s: %d %s" % [ing.display_name, Game.get_stock(id), Units.label(ing.unit)]
		if limit > 0:
			txt += " / %d" % limit
		if Game.needs_restock(id):
			txt += "  (estoque baixo)"
		var row := HBoxContainer.new()
		row.add_child(_label(txt))
		row.add_child(_button("Comprar %d %s (%s)" % [ing.pack_size, Units.label(ing.unit),
			Money.format(Game.purchase_price(id, 1))], _on_buy.bind(id)))
		p.add_child(row)
	p.add_child(_button("Planejar compras (desafio nível %d: desconto na próxima compra)" % Flow.current_tier(), Flow.start_planning_challenge))
	if Game.can_ask_help():
		p.add_child(_button("Pedir ajuda ao vizinho (+%s, restam %d)" % [Money.format(Game.HELP_AMOUNT),
			Game.HELP_MAX_USES - Game.help_uses], _on_help))

	p.add_child(_label("Melhorias", 20))
	for uid in GameData.upgrades:
		var u: Upgrade = GameData.upgrades[uid]
		var check := Game.can_buy_upgrade(uid)
		var owned: bool = uid in Game.purchased_upgrades
		var urow := HBoxContainer.new()
		urow.add_child(_label("%s — %s (%s)" % [u.display_name, u.description, Money.format(u.cost_cents)]))
		var btn_text: String = "Adquirida" if owned else ("Comprar" if check["ok"] else str(check["reason"]))
		urow.add_child(_button(btn_text, _on_buy_upgrade.bind(uid), not check["ok"]))
		p.add_child(urow)

	p.add_child(_label("Últimas movimentações", 20))
	var start := maxi(0, Game.ledger.size() - 5)
	for i in range(Game.ledger.size() - 1, start - 1, -1):
		var e: Dictionary = Game.ledger[i]
		var sign_text := "+" if e["kind"] == "entrada" else "−"
		p.add_child(_label("%s %s  %s" % [sign_text, Money.format(e["cents"]), e["reason"]]))
	p.add_child(_button("Voltar ao salão", Flow.goto_place.bind(GameStates.Place.SALAO)))

func _on_help() -> void:
	if Game.ask_help():
		Flow.say("Seu vizinho emprestou um dinheiro para você repor o estoque.")

func _on_buy(id: String) -> void:
	var r := Game.buy_ingredient(id, 1)
	Flow.say(r["message"])

func _on_buy_upgrade(uid: String) -> void:
	var r := Game.buy_upgrade(uid)
	Flow.say(r["message"])

# ---------------------------------------------------------------------- FIM
func _build_ending() -> void:
	var p := _begin(GameStates.Id.ENDING)
<<<<<<< HEAD
	if Flow.ending_kind == "falencia":
		p.add_child(_label("O restaurante fechou as portas...", 32))
		p.add_child(_label("Foram %d dias seguidos com o saldo negativo e as contas não fecharam. O livro do vovô volta para a gaveta — mas você pode tentar de novo!" % Game.BANKRUPT_DAYS))
		p.add_child(_label("Pontuação final: %d   |   Recorde: %d%s" % [
			Game.score, Game.best_score, "  (novo recorde!)" if Flow.new_record else ""], 22))
		p.add_child(_button("Voltar ao menu principal", Flow.go.bind(GameStates.Id.MAIN_MENU)))
		return
=======
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	p.add_child(_label("O restaurante renasceu!", 32))
	p.add_child(_label("Você atendeu %d pedidos em %d dias e terminou com %s em caixa (lucro total: %s)." % [
		Game.orders_completed, Game.day, Money.format(Game.money_cents), Money.format(Game.profit())]))
	p.add_child(_label("Pontuação final: %d   |   Recorde: %d%s" % [
		Game.score, Game.best_score, "  (novo recorde!)" if Flow.new_record else ""], 22))
	p.add_child(_label("(Desfecho provisório: o final da história ainda será definido pela equipe.)"))
	p.add_child(_button("Voltar ao menu principal", Flow.go.bind(GameStates.Id.MAIN_MENU)))
<<<<<<< HEAD

# --------------------------------------------------------------------- JORNAL
## Jornal do dia: manchete (capítulo ou evento), evento do dia, gráfico você × rival e um desafio opcional.
func _build_newspaper() -> void:
	var p := _begin(GameStates.Id.NEWSPAPER)
	p.add_child(_label("GAZETA DO BAIRRO — Dia %d" % Game.day, 30))
	var idx := GameData.chapter_index(Game.orders_completed)
	var ch: Dictionary = GameData.CHAPTERS[idx]
	if Game.chapter_seen < idx:
		p.add_child(_label(str(ch["news"]), 22))
		p.add_child(_label("%s — Meta: %s (recompensa: %s)" % [ch["title"], ch["goal_text"], Money.format(int(ch["reward"]))], 16))
	var ev: Dictionary = GameData.EVENTS.get(Game.today_event, GameData.EVENTS["normal"])
	p.add_child(_label("Evento do dia: %s" % ev["title"], 20))
	p.add_child(_label(str(ev["text"])))
	if GameData.recipes.has(Game.daily_special):
		var sr: Recipe = GameData.recipes[Game.daily_special]
		p.add_child(_label("Prato do dia no Verine's: %s." % sr.display_name))

	p.add_child(_label("Concorrência: %s × Verine's (pratos vendidos por dia)" % GameData.RIVAL_NAME, 20))
	var rival := Flow.rival_recent()
	var labels: Array[String] = []
	var you: Array = []
	var start := maxi(0, Game.rival_history.size() - rival.size())
	for i in rival.size():
		var e: Dictionary = Game.rival_history[start + i]
		var dnum := int(e["day"])
		labels.append(("Dia %d" % dnum) if dnum >= 1 else ("Pré-%d" % (1 - dnum)))
		var mine := 0
		for h in Game.day_history:
			if int(h["day"]) == dnum:
				mine = int(h["orders"])
		you.append(mine)
	var chart := BarChart.new()
	chart.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chart.set_data(labels, [
		{"name": "Verine's", "color": Color(0.85, 0.55, 0.2), "values": you},
		{"name": GameData.RIVAL_NAME, "color": Color(0.35, 0.5, 0.75), "values": rival},
	])
	p.add_child(chart)
	var last_rating: float = float(Game.rival_history[Game.rival_history.size() - 1]["rating"]) if not Game.rival_history.is_empty() else 3.5
	p.add_child(_label("Nota do rival: %s de 5   |   Sua reputação: %s de 5" % [
		("%.1f" % last_rating).replace(".", ","), ("%.1f" % Game.reputation).replace(".", ",")], 16))
	if Game.news_done:
		p.add_child(_label("Desafio do jornal de hoje: resolvido!"))
	else:
		p.add_child(_button("Desafio do jornal: analisar os números do rival (bônus)", Flow.start_news_challenge))
	p.add_child(_button("Abrir o restaurante", Flow.close_newspaper))
=======
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
