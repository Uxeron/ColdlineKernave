extends Node

var enemy_count: int = 0

func _unhandled_key_input(event: InputEvent) -> void:
	if event.keycode == KEY_ESCAPE:
		get_tree().quit()
