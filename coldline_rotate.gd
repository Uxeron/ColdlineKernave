extends Node2D


@export var max_rotation: float = deg_to_rad(10)
@export var rotation_speed: float = deg_to_rad(5)
var goes_positive: bool = false


func _ready() -> void:
	rotation = randf_range(-max_rotation, max_rotation)
	
	goes_positive =  randf() > 0.5


func _process(delta: float) -> void:
	if goes_positive:
		positive(delta)
	else:
		negative(delta)


func positive(delta: float) -> void:
	rotation += rotation_speed * delta
	
	if rotation >= max_rotation:
		rotation = max_rotation
		goes_positive = false


func negative(delta: float) -> void:
	rotation -= rotation_speed * delta
	
	if rotation <= -max_rotation:
		rotation = -max_rotation
		goes_positive = true

