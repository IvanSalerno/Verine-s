class_name IngredientArt
extends RefCounted
## Imagens dos ingredientes (cozinha: bancada, tigela/prato e lista do balão).
## Coloque em assets/ingredientes/<id>.png (também aceita .webp e .jpg). Ex.: farinha.png,
## ovo.png, pao_hamburguer.png. Sem imagem, usa um círculo colorido com a cor do ingrediente.
## A lista completa de nomes de arquivo está no README (seção v23).

const FOLDER := "res://assets/ingredientes/"
const EXTENSIONS: Array[String] = [".png", ".webp", ".jpg", ".jpeg"]
## Cor de cada ingrediente (usada no círculo provisório e nas camadas do hambúrguer).
const COLORS := {
	"farinha": Color(0.95, 0.93, 0.86), "acucar": Color(1.0, 1.0, 0.97), "leite": Color(0.97, 0.97, 1.0),
	"ovo": Color(0.98, 0.85, 0.45), "macarrao": Color(0.96, 0.82, 0.45), "molho_tomate": Color(0.8, 0.18, 0.12),
	"queijo": Color(1.0, 0.8, 0.25), "leite_zero": Color(0.85, 0.92, 1.0), "queijo_zero": Color(0.98, 0.88, 0.5),
	"farinha_sg": Color(0.9, 0.86, 0.7), "macarrao_sg": Color(0.9, 0.75, 0.4),
	"pao_hamburguer": Color(0.85, 0.58, 0.28), "carne_hamburguer": Color(0.42, 0.24, 0.14),
	"alface": Color(0.45, 0.78, 0.3), "tomate": Color(0.9, 0.25, 0.2),
}

const DISH_FOLDER := "res://assets/pratos/"   # <id_da_receita>.png (prato pronto) e prato.png (louça)

static var _cache: Dictionary = {}

static func _load(base: String) -> Texture2D:
	if not _cache.has(base):
		_cache[base] = SceneBackground.load_first(EXTENSIONS.map(func(e): return base + e))
	return _cache[base]

## Imagem do prato pronto (assets/pratos/<recipe_id>.png) ou null.
static func dish_image(recipe_id: String) -> Texture2D:
	return _load(DISH_FOLDER + recipe_id)

## Louça (assets/pratos/prato.png) ou null.
static func plate_image() -> Texture2D:
	return _load(DISH_FOLDER + "prato")

## Louça vista de lado, em perspectiva (assets/pratos/prato_lateral.png) ou null.
static func plate_side_image() -> Texture2D:
	return _load(DISH_FOLDER + "prato_lateral")

static func color_for(id: String) -> Color:
	if COLORS.has(id):
		return COLORS[id]
	return Color.from_hsv(float(absi(id.hash()) % 360) / 360.0, 0.5, 0.85)

## Imagem do ingrediente (ou null se o arquivo não existir).
static func image_for(id: String) -> Texture2D:
	var key := "img:" + id
	if not _cache.has(key):
		_cache[key] = SceneBackground.load_first(EXTENSIONS.map(func(e): return FOLDER + id + e))
	return _cache[key]

## Imagem do ingrediente ou, se não houver, um círculo colorido provisório.
static func icon_for(id: String) -> Texture2D:
	var img := image_for(id)
	if img != null:
		return img
	var key := "dot:" + id
	if not _cache.has(key):
		_cache[key] = _make_dot(color_for(id))
	return _cache[key]

static func _make_dot(c: Color) -> Texture2D:
	var n := 64
	var im := Image.create(n, n, false, Image.FORMAT_RGBA8)
	var center := Vector2(n / 2.0, n / 2.0)
	var border := c.darkened(0.45)
	for y in n:
		for x in n:
			var d := Vector2(x + 0.5, y + 0.5).distance_to(center)
			if d <= 27.0:
				im.set_pixel(x, y, c)
			elif d <= 31.0:
				im.set_pixel(x, y, border)
			else:
				im.set_pixel(x, y, Color(0, 0, 0, 0))
	return ImageTexture.create_from_image(im)
