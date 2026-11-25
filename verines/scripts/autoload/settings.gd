extends Node
## Configurações do jogador (autoload "Settings"), salvas em user://verines_settings.cfg.

signal changed

const PATH := "user://verines_settings.cfg"
const TEXT_SIZES: Array[int] = [16, 18, 22]
const TEXT_SIZE_NAMES: Array[String] = ["Pequeno", "Médio", "Grande"]

var volume_steps: int = 8      # 0 a 10
var fullscreen: bool = true   # o jogo abre em tela cheia
var show_hints: bool = true
var text_size: int = 1         # índice em TEXT_SIZES
var patience_enabled: bool = true   # paciência dos clientes (tempo)

func _ready() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) == OK:
		volume_steps = clampi(int(cfg.get_value("settings", "volume", 8)), 0, 10)
		fullscreen = bool(cfg.get_value("settings", "fullscreen_v2", true))   # chave nova: ignora o "desligado" antigo
		show_hints = bool(cfg.get_value("settings", "hints", true))
		text_size = clampi(int(cfg.get_value("settings", "text_size", 1)), 0, 2)
		patience_enabled = bool(cfg.get_value("settings", "patience", true))
	apply()

func apply() -> void:
	AudioServer.set_bus_mute(0, volume_steps == 0)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(volume_steps / 10.0, 0.0001)))
	# só troca o modo da janela quando precisa (não "desmaximiza" ao mudar o volume, por exemplo)
	var mode := DisplayServer.window_get_mode()
	var is_full := mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	if fullscreen and not is_full:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif not fullscreen and is_full:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	changed.emit()

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("settings", "volume", volume_steps)
	cfg.set_value("settings", "fullscreen_v2", fullscreen)
	cfg.set_value("settings", "hints", show_hints)
	cfg.set_value("settings", "text_size", text_size)
	cfg.set_value("settings", "patience", patience_enabled)
	cfg.save(PATH)

func change_volume(delta: int) -> void:
	volume_steps = clampi(volume_steps + delta, 0, 10)
	_save()
	apply()

func toggle_fullscreen() -> void:
	fullscreen = not fullscreen
	_save()
	apply()

func toggle_hints() -> void:
	show_hints = not show_hints
	_save()
	apply()

func toggle_patience() -> void:
	patience_enabled = not patience_enabled
	_save()
	apply()

func set_text_size(index: int) -> void:
	text_size = clampi(index, 0, 2)
	_save()
	apply()
