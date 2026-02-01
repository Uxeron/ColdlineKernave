extends Node

@warning_ignore("unused_signal")
signal kanapinis_hp(value: float)
@warning_ignore("unused_signal")
signal lasininis_hp(value: float)

var enemy_count: int = 30
var active_enemies: int = 0
var fullscreen: bool = false

var character_stage: int = 0

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
	
	if event.keycode == KEY_ESCAPE:
		get_tree().quit()
	
	if event.keycode == KEY_F:
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullscreen = !fullscreen
