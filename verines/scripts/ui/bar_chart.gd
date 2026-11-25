class_name BarChart
extends Control
## Gráfico de barras agrupadas simples (ex.: pratos por dia: você × rival), desenhado por código.

var labels: Array[String] = []
var series: Array = []          # [{name, color, values: Array[int]}]
const PAD_LEFT := 34.0
const PAD_BOTTOM := 26.0
const PAD_TOP := 26.0

func _init() -> void:
	custom_minimum_size = Vector2(0, 190)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_data(p_labels: Array[String], p_series: Array) -> void:
	labels = p_labels
	series = p_series
	queue_redraw()

func _draw() -> void:
	var font := get_theme_default_font()
	var fs := 13
	var w := size.x
	var h := size.y
	var max_v := 1
	for s in series:
		for v in s["values"]:
			max_v = maxi(max_v, int(v))
	var plot_h := h - PAD_BOTTOM - PAD_TOP
	var plot_w := w - PAD_LEFT - 8.0
	# eixos e linhas de grade
	for k in range(0, max_v + 1):
		var y := PAD_TOP + plot_h - plot_h * k / float(max_v)
		draw_line(Vector2(PAD_LEFT, y), Vector2(w - 8.0, y), Color(UIStyle.BROWN, 0.15), 1.0)
		draw_string(font, Vector2(4, y + 4), str(k), HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UIStyle.TEXT)
	draw_line(Vector2(PAD_LEFT, PAD_TOP), Vector2(PAD_LEFT, PAD_TOP + plot_h), UIStyle.BROWN, 2.0)
	draw_line(Vector2(PAD_LEFT, PAD_TOP + plot_h), Vector2(w - 8.0, PAD_TOP + plot_h), UIStyle.BROWN, 2.0)
	if labels.is_empty() or series.is_empty():
		return
	var group_w := plot_w / labels.size()
	var bar_w := minf(36.0, group_w * 0.8 / series.size())
	for i in labels.size():
		var gx := PAD_LEFT + group_w * i + (group_w - bar_w * series.size()) / 2.0
		for j in series.size():
			var vals: Array = series[j]["values"]
			var v := int(vals[i]) if i < vals.size() else 0
			var bh := plot_h * v / float(max_v)
			var r := Rect2(gx + bar_w * j, PAD_TOP + plot_h - bh, bar_w - 3.0, bh)
			draw_rect(r, series[j]["color"])
			draw_string(font, Vector2(r.position.x, r.position.y - 3), str(v), HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UIStyle.TEXT)
		draw_string(font, Vector2(PAD_LEFT + group_w * i, h - 6), labels[i], HORIZONTAL_ALIGNMENT_CENTER, group_w, fs, UIStyle.TEXT)
	# legenda
	var lx := PAD_LEFT + 6.0
	for s in series:
		draw_rect(Rect2(lx, 6, 12, 12), s["color"])
		draw_string(font, Vector2(lx + 16, 17), str(s["name"]), HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UIStyle.TEXT)
		lx += 30.0 + font.get_string_size(str(s["name"]), HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
