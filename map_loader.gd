extends Node

var current_scene: Node

func load_scene(path: String) -> void:
	var new_scene = (load(path) as PackedScene).instantiate()

	if current_scene != null:
		remove_child(current_scene)
		current_scene.queue_free()
	
	current_scene = new_scene
	add_child(current_scene)

func add_scene(path: String) -> void:
	var new_scene = (load(path) as PackedScene).instantiate()
	current_scene.add_child(new_scene)

func _ready() -> void:
	load_scene("res://main_menu.tscn")
