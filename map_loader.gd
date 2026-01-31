extends Node

var current_scene: Node

func load_scene(path: String) -> void:
	if current_scene != null:
		remove_child(current_scene)
		current_scene.queue_free()
	
	current_scene = (load(path) as PackedScene).instantiate()
	add_child(current_scene)

func _ready() -> void:
	load_scene("res://main_menu.tscn")
