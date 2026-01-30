extends CharacterBody2D

@export var speed: float = 200.0
@export var health: float = 100.0
@export var damage: float = 50.0
@onready var damage_area: Area2D = $DamageArea

func _physics_process(_delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	global_rotation = global_position.angle_to_point(mouse_position)
	
	var motion = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = motion * speed
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("attack") and event.is_pressed():
		var bodies = damage_area.get_overlapping_bodies()
		for body in bodies:
			if body.get("health") != null:
				print("damaging", body.name)
				body.health -= damage
