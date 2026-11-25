class_name DropBowl
extends PanelContainer
## Tigela da bancada: recebe os ingredientes arrastados na montagem do prato.

var _label: Label

func _init() -> void:
	add_theme_stylebox_override("panel", UIStyle.cream_box(Color(0.93, 0.95, 0.97), 3, 40, 10))
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_color_override("font_color", UIStyle.TEXT)
	_label.add_theme_font_size_override("font_size", 13)
	add_child(_label)

func set_text(t: String) -> void:
	_label.text = t

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and (data as Dictionary).has("ingredient_id")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	Flow.assemble_add(str((data as Dictionary)["ingredient_id"]))
