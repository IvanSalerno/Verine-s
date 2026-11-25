class_name IngredientChip
extends Button
## Ingrediente da bancada na montagem: imagem + nome. Arraste até a tigela/prato (ou clique).

const CHIP_SIZE := Vector2(80, 72)

var ingredient_id: String = ""

func setup(id: String) -> void:
	ingredient_id = id
	var ing: Ingredient = GameData.ingredients[id]
	text = ing.display_name
	tooltip_text = "Arraste para a montagem: %s" % ing.display_name
	icon = IngredientArt.icon_for(id)
	expand_icon = true
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	custom_minimum_size = CHIP_SIZE
	clip_text = true
	add_theme_font_size_override("font_size", 11)
	add_theme_constant_override("icon_max_width", 40)
	pressed.connect(func(): Flow.assemble_add(ingredient_id))

func _get_drag_data(_at_position: Vector2) -> Variant:
	if disabled:
		return null
	var preview := TextureRect.new()
	preview.texture = icon
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.size = Vector2(56, 56)
	preview.position = Vector2(-28, -28)
	var holder := Control.new()   # centraliza a imagem no ponteiro
	holder.add_child(preview)
	set_drag_preview(holder)
	return {"ingredient_id": ingredient_id}

## Animação de erro: balança e pisca em vermelho.
func shake() -> void:
	var base_x := position.x
	var tw := create_tween()
	modulate = Color(1, 0.5, 0.5)
	for dx in [-6.0, 6.0, -4.0, 4.0, 0.0]:
		tw.tween_property(self, "position:x", base_x + dx, 0.05)
	tw.tween_property(self, "modulate", Color.WHITE, 0.15)
