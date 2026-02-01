extends Node2D

@export var spawned_object: PackedScene
@export var target: Node2D
@export var min_time: float = 1.0
@export var max_time: float = 3.0
@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D


func _ready() -> void:
	spawn.call_deferred()

func spawn() -> void:
	if Global.enemy_count <= 0:
		return
	
	path_follow.progress_ratio = randf()
	
	print("spawning")
	var entity : Node2D = spawned_object.instantiate()
	entity.target = target
	entity.global_position = path_follow.global_position
	MapLoader.current_scene.add_child(entity)
	Global.enemy_count -= 1
	Global.active_enemies += 1
	
	$Timer.start(1.5)
	await $Timer.timeout
	
	spawn()
