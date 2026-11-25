class_name SalaoView
extends Control
## Página do SALÃO. Fundo: assets/cenarios/salao.png (atendimento) e
## assets/cenarios/caixa_registradora.png (na hora de pagar e dar o troco).
## Sem imagens, usa a blocagem de scenes/salao_view.tscn.

const PATHS_SALAO: Array[String] = ["res://assets/cenarios/salao.png"]
const PATHS_CAIXA: Array[String] = ["res://assets/cenarios/caixa_registradora.png"]
<<<<<<< HEAD

## ---- CLIENTES ----------------------------------------------------------------------------
## Aparências disponíveis: arquivos "cliente_<nome>.png" (procurados em assets/clientes/,
## assets/cenarios/, assets/ e na raiz do projeto). Para pixel art: aba Importar > Filtro = Nearest.
const LOOK_NAMES: Array[String] = ["vermelho", "azul", "amarelo", "careca", "alto", "oculos", "cracha"]
const SEARCH_FOLDERS: Array[String] = ["res://assets/clientes/", "res://assets/cenarios/", "res://assets/", "res://"]
const EXTENSIONS: Array[String] = [".png", ".webp", ".jpg", ".jpeg"]

## Os 7 clientes fixos do Verine's: cada um tem sempre a mesma aparência (imagem cliente_<aparência>).
## Os pedidos em GameData usam estes nomes. Para trocar um nome, mude aqui E nos pedidos.
##   João        — cliente_cracha   (trabalha no escritório ao lado, sempre com o crachá)
##   Felipe      — cliente_oculos
##   Marta       — cliente_vermelho (a única cliente mulher)
##   Pedro       — cliente_azul
##   Caio        — cliente_amarelo
##   Seu Tavares — cliente_careca   (freguês antigo, do tempo do Verine; adora o pudim)
##   Rafael      — cliente_alto     (vem com a família toda)
const CUSTOMER_LOOK := {
	"João": "cracha",
	"Felipe": "oculos",
	"Marta": "vermelho",
	"Pedro": "azul",
	"Caio": "amarelo",
	"Seu Tavares": "careca",
	"Rafael": "alto",
}
## Cor do bloco usado se a imagem da aparência não for encontrada.
const LOOK_COLORS := {
	"vermelho": Color(0.8, 0.25, 0.25), "azul": Color(0.25, 0.4, 0.8), "amarelo": Color(0.9, 0.75, 0.2),
	"careca": Color(0.6, 0.45, 0.35), "alto": Color(0.3, 0.6, 0.45), "oculos": Color(0.55, 0.4, 0.7),
	"cracha": Color(0.3, 0.6, 0.7),
}

## ---- BALÃO DE FALA -----------------------------------------------------------------------
## Fica à direita do cliente. Mostra o pedido (atendimento/investigação) e o enunciado
## dos desafios ligados ao cliente. Contextos de desafio que aparecem no balão
## ("order" = ajuste da receita, "delivery" = porções e troco). "planning" e "daily"
## não têm cliente, então continuam no painel de baixo.
const BUBBLE_CHALLENGE_CONTEXTS: Array[String] = ["order", "delivery"]
const BUBBLE_POS := Vector2(835, 150)   # canto superior esquerdo do balão (o cliente ocupa x 570–810)
const BUBBLE_WIDTH := 425.0
## Estados em que o pedido aparece no balão (no livro também, para comparar enquanto lê).
const ORDER_STATES := [GameStates.Id.ACTIVE_ORDER, GameStates.Id.INVESTIGATION, GameStates.Id.RECIPE_BOOK]


## ---- PACIÊNCIA, FILA, TELEFONE E DECORAÇÃO (v20) — coordenadas do Palco (1280×720)
const PATIENCE_RECT := Rect2(600, 232, 180, 10)
const QUEUE_RECT := Rect2(1150, 470, 90, 140)     # cliente esperando na fila (menor)
const PHONE_COLOR := Color(0.62, 0.68, 0.78)

var _patience_bg: ColorRect
var _patience_fill: ColorRect
var _queue_sprite: TextureRect
var _queue_block: ColorRect
var _queue_label: Label
var _queue_bar: ColorRect
var _decor: Dictionary = {}   # upgrade_id -> Array[Control]

var _looks: Dictionary = {}     # nome da aparência -> Texture2D (ou null)
var _bg: TextureRect
var _tex_salao: Texture2D
var _tex_caixa: Texture2D
var _bubble: SpeechBubble

@onready var _palco: Control = $Palco
@onready var _client_sprite: TextureRect = $Palco/Cliente
@onready var _client_block: ColorRect = $Palco/ClienteBloco
@onready var _client_name: Label = $Palco/NomeCliente
=======
## Imagens dos clientes. Para pixel art: aba Importar > Filtro = Nearest.
const CLIENT_TEXTURE_PATHS: Array[String] = [
	"res://assets/clientes/cliente_vermelho.png",
	"res://assets/clientes/cliente_azul.png",
	"res://assets/clientes/cliente_amarelo.png",
]
const CLIENT_BLOCK_COLORS: Array[Color] = [
	Color(0.8, 0.25, 0.25), Color(0.25, 0.4, 0.8), Color(0.9, 0.75, 0.2),
]

var _textures: Array = []
var _bg: TextureRect
var _tex_salao: Texture2D
var _tex_caixa: Texture2D

@onready var _client_sprite: TextureRect = $Cliente
@onready var _client_block: ColorRect = $ClienteBloco
@onready var _client_name: Label = $NomeCliente
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d

func _ready() -> void:
	_client_block.set_meta("keep", true)
	_bg = SceneBackground.create_layer(self)
	_tex_salao = SceneBackground.load_first(PATHS_SALAO)
	_tex_caixa = SceneBackground.load_first(PATHS_CAIXA)
	SceneBackground.style_label_for_art(_client_name)
<<<<<<< HEAD
	_load_looks()
	_bubble = SpeechBubble.new()
	_bubble.bubble_width = BUBBLE_WIDTH
	_bubble.z_index = 5   # sempre por cima do cliente e da cena
	_palco.add_child(_bubble)   # acompanha o cliente em qualquer proporção de tela
	_bubble.position = BUBBLE_POS
	_build_extras()
	Flow.state_changed.connect(_update)
	Flow.order_changed.connect(_update)
	Settings.changed.connect(_update)
	Game.upgrade_purchased.connect(func(_id): _update_decor())
	_update()

## Barra de paciência e cliente da fila ficam em tempo real.
func _process(_delta: float) -> void:
	if not is_visible_in_tree():
		return
	var o := Flow.order
	var show_bar := Settings.patience_enabled and _client_name.visible and o != null and o.patience_sec > 0.0
	_patience_bg.visible = show_bar
	_patience_fill.visible = show_bar
	if show_bar:
		_patience_fill.size.x = PATIENCE_RECT.size.x * o.patience / 100.0
		_patience_fill.color = _patience_color(o.patience)
	var w := Flow.waiting
	var show_q := w != null and not (Flow.state == GameStates.Id.DELIVERY and _tex_caixa != null)
	_queue_label.visible = show_q
	_queue_bar.visible = show_q and Settings.patience_enabled
	if not show_q:
		_queue_sprite.visible = false
		_queue_block.visible = false
		return
	_queue_label.text = "Na fila:\n%s" % w.customer_name
	_queue_bar.size.x = QUEUE_RECT.size.x * w.patience / 100.0
	_queue_bar.color = _patience_color(w.patience)
	var tex: Texture2D = _looks.get(_look_for(w.customer_name))
	_queue_sprite.texture = tex
	_queue_sprite.visible = tex != null
	_queue_block.visible = tex == null
	_queue_block.color = LOOK_COLORS.get(_look_for(w.customer_name), Color(0.6, 0.6, 0.6))

func _patience_color(p: float) -> Color:
	if p >= 60.0:
		return Color(0.35, 0.75, 0.35)
	if p >= 30.0:
		return Color(0.95, 0.75, 0.2)
	return Color(0.9, 0.3, 0.25)

func _rect_node(parent: Control, r: Rect2, color: Color) -> ColorRect:
	var c := ColorRect.new()
	c.position = r.position
	c.size = r.size
	c.color = color
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.set_meta("keep", true)   # não some quando há imagem de fundo
	parent.add_child(c)
	return c

func _build_extras() -> void:
	_patience_bg = _rect_node(_palco, PATIENCE_RECT.grow(2.0), Color(0.15, 0.1, 0.07, 0.8))
	_patience_fill = _rect_node(_palco, PATIENCE_RECT, Color(0.35, 0.75, 0.35))
	_queue_block = _rect_node(_palco, QUEUE_RECT, Color(0.6, 0.6, 0.6))
	_queue_sprite = TextureRect.new()
	_queue_sprite.position = QUEUE_RECT.position
	_queue_sprite.size = QUEUE_RECT.size
	_queue_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_queue_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_queue_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_palco.add_child(_queue_sprite)
	_queue_label = Label.new()
	_queue_label.position = QUEUE_RECT.position + Vector2(-20, -52)
	_queue_label.size = Vector2(QUEUE_RECT.size.x + 40, 40)
	_queue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_queue_label.add_theme_font_size_override("font_size", 13)
	SceneBackground.style_label_for_art(_queue_label)
	_palco.add_child(_queue_label)
	_queue_bar = _rect_node(_palco, Rect2(QUEUE_RECT.position + Vector2(0, -10), Vector2(QUEUE_RECT.size.x, 6)), Color(0.35, 0.75, 0.35))
	# decoração comprada na Despensa (cosmética)
	_decor["d_quadro"] = [_rect_node(_palco, Rect2(630, 128, 120, 62), Color(0.45, 0.28, 0.12)),
		_rect_node(_palco, Rect2(638, 134, 104, 50), Color(0.85, 0.75, 0.55))]
	var portrait := Label.new()
	portrait.text = "Verine"
	portrait.position = Vector2(638, 146)
	portrait.size = Vector2(104, 24)
	portrait.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait.add_theme_color_override("font_color", Color(0.3, 0.18, 0.08))
	portrait.add_theme_font_size_override("font_size", 14)
	_palco.add_child(portrait)
	_decor["d_quadro"].append(portrait)
	var plants: Array = []
	for x in [560.0, 1236.0]:
		plants.append(_rect_node(_palco, Rect2(x, 585, 36, 32), Color(0.6, 0.35, 0.2)))
		plants.append(_rect_node(_palco, Rect2(x - 6, 545, 48, 44), Color(0.25, 0.55, 0.3)))
	_decor["d_plantas"] = plants
	var cloths: Array = []
	for i in range(8):
		var mx := 570.0 + i * 87.0
		cloths.append(_rect_node(_palco, Rect2(mx + 4, 624, 64, 26), Color(0.8, 0.2, 0.2)))
		cloths.append(_rect_node(_palco, Rect2(mx + 4, 636, 64, 4), Color(1, 1, 1, 0.8)))
	_decor["d_toalhas"] = cloths
	var lights: Array = []
	var colors := [Color(1, 0.85, 0.3), Color(1, 0.4, 0.4), Color(0.5, 0.8, 1), Color(0.6, 1, 0.5)]
	for i in range(18):
		lights.append(_rect_node(_palco, Rect2(575 + i * 38, 128 + (i % 2) * 6, 9, 9), colors[i % colors.size()]))
	_decor["d_luzes"] = lights
	_update_decor()

func _update_decor() -> void:
	for uid in _decor:
		var owned: bool = uid in Game.purchased_upgrades
		for n in _decor[uid]:
			(n as CanvasItem).visible = owned

## true se o desafio atual deve aparecer no balão do cliente (e não no painel de baixo).
## Usado também por main.gd para mostrar o Salão durante esses desafios.
static func challenge_in_bubble() -> bool:
	var o := Flow.order
	return Flow.state == GameStates.Id.MATH_CHALLENGE and Flow.current_challenge != null \
		and Flow.challenge_context in BUBBLE_CHALLENGE_CONTEXTS \
		and o != null and not o.is_closed()

## true se o cliente ainda espera que o jogador descubra qual receita ele pediu.
static func awaiting_recipe() -> bool:
	var o := Flow.order
	return o != null and o.state in [Order.State.CREATED, Order.State.INVESTIGATING]

## true se o pedido do cliente deve aparecer no balão (e não no painel de baixo).
static func order_in_bubble() -> bool:
	var o := Flow.order
	return Flow.state in ORDER_STATES and o != null and not o.is_closed()

func _load_looks() -> void:
	for look in LOOK_NAMES:
		var tex := _find_texture("cliente_" + look)
		_looks[look] = tex
		if tex == null:
			push_warning("Imagem do cliente não encontrada: cliente_%s (coloque em assets/clientes/)" % look)
		else:
			print("[Clientes] cliente_%s: OK" % look)

func _find_texture(base_name: String) -> Texture2D:
	for folder in SEARCH_FOLDERS:
		for ext in EXTENSIONS:
			var path: String = folder + base_name + ext
			if ResourceLoader.exists(path):
				var t := load(path) as Texture2D
				if t != null:
					return t
			elif FileAccess.file_exists(path):
				# imagem ainda não importada pelo editor: lê o arquivo direto
				var img := Image.load_from_file(path)
				if img != null:
					return ImageTexture.create_from_image(img)
	return null

func _look_for(customer_name: String) -> String:
	if CUSTOMER_LOOK.has(customer_name):
		return CUSTOMER_LOOK[customer_name]
	return LOOK_NAMES[int(customer_name.hash() % LOOK_NAMES.size())]

func _update(_unused: int = 0) -> void:
	_update_client()
	_update_bubble()

## Coloca o bloco de alternativas (montado por main.gd) abaixo do enunciado, no balão.
func set_answer_block(block: Control) -> void:
	_bubble.set_extra(block)

## Largura disponível para o bloco de alternativas dentro do balão.
func answer_block_width() -> float:
	return _bubble.inner_width()

func _update_bubble() -> void:
	_bubble.max_height = 720.0 - BUBBLE_POS.y - 20.0   # altura do Palco
	if challenge_in_bubble():
		# o desafio sempre aparece no balão (mesmo se o cliente estiver escondido)
		var c := Flow.current_challenge
		var text := c.statement if c.statement.strip_edges() != "" else "(enunciado indisponível)"
		_bubble.show_text("Desafio: %s (nível %d)" % [c.topic, c.tier], text)
	elif not _client_name.visible:
		_bubble.hide_bubble()
	elif order_in_bubble():
		_bubble.clear_extra()   # main.gd recoloca os nomes das receitas, se o pedido ainda não foi identificado
		var title := "Pedido — %d porções" % Flow.order.servings
		if awaiting_recipe():
			title += " · qual receita é?"
		_bubble.show_text(title, "\"%s\"" % Flow.order.description)
	else:
		_bubble.hide_bubble()

func _update_client() -> void:
=======
	for path in CLIENT_TEXTURE_PATHS:
		if ResourceLoader.exists(path):
			_textures.append(load(path))
		else:
			_textures.append(null)
	Flow.state_changed.connect(_update)
	Flow.order_changed.connect(_update)
	_update()

func _update(_unused: int = 0) -> void:
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	# Na entrega (pagamento e troco) mostra a caixa registradora, se houver imagem.
	var at_register := Flow.state == GameStates.Id.DELIVERY and _tex_caixa != null
	var tex: Texture2D = _tex_caixa if at_register else _tex_salao
	SceneBackground.show_image(self, _bg, tex)

<<<<<<< HEAD
	_update_decor()
=======
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
	var o := Flow.order
	var present := o != null and not o.is_closed() and not at_register
	_client_name.visible = present
	_client_sprite.visible = false
	_client_block.visible = false
<<<<<<< HEAD
	if present and o.is_phone():
		# pedido por telefone: o cliente não está no salão
		_client_name.text = "%s (telefone)" % o.customer_name
		_client_block.color = PHONE_COLOR
		($Palco/ClienteBloco/Texto as Label).text = "Pedido por\ntelefone"
		_client_block.visible = true
		return
	($Palco/ClienteBloco/Texto as Label).text = "Cliente\n(sem imagem)"
	if present:
		var look := _look_for(o.customer_name)
		_client_name.text = o.customer_name
		var client_tex: Texture2D = _looks.get(look)
		if client_tex == null:
			# aparência sem imagem: usa qualquer outra imagem de cliente disponível
			for other in LOOK_NAMES:
				if _looks.get(other) != null:
					client_tex = _looks[other]
					break
=======
	if present:
		var idx: int = int(o.customer_name.hash() % CLIENT_TEXTURE_PATHS.size())
		_client_name.text = o.customer_name
		var client_tex: Texture2D = _textures[idx]
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
		if client_tex != null:
			_client_sprite.texture = client_tex
			_client_sprite.visible = true
		else:
<<<<<<< HEAD
			_client_block.color = LOOK_COLORS.get(look, Color(0.6, 0.6, 0.6))
=======
			_client_block.color = CLIENT_BLOCK_COLORS[idx]
>>>>>>> d565e7e4fb61ac8b2a9bb15a8d9b0cec7b06978d
			_client_block.visible = true
