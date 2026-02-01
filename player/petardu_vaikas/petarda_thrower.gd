extends Sprite2D

const PETARDA = preload("uid://74hxitbrtyph")

func throw() -> void:
	var instance = PETARDA.instantiate()
	instance.target = get_global_mouse_position()
	instance.global_position = global_position
	MapLoader.current_scene.add_child(instance)
