extends Node2D

@export var spawned_object: PackedScene
@export var target: Node2D
@export var min_time: int = 5
@export var max_time: int = 30

func _ready() -> void:
	spawn()

func spawn() -> void:
	$Timer.start(randi_range(min_time, max_time))
	await $Timer.timeout
	
	var entity : Node2D = spawned_object.instantiate()
	entity.target = target
	entity.global_position = global_position
	get_tree().root.add_child(entity)
	
	spawn()
