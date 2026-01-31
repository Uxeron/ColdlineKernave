class_name Character
extends CharacterBody2D

@export var speed: float = 200.0
@export var health: float = 100.0
@export var damage: float = 50.0
@export var knockback: float = 2000.0
@onready var model: Model = get_child(0)
@onready var weapon_collider: Area2D = model.weapon_collider
@onready var hit_particles: Node2D = $HitParticles

var can_swing: bool = true
var hit_objects: Array = []

func _physics_process(_delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	global_rotation = global_position.angle_to_point(mouse_position)
	
	var motion = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = motion * speed
	move_and_slide()
	
	if not can_swing:
		# If we can't swing, means we're already swinging
		if model.can_damage:
			attack()
		return
		
	if Input.is_action_pressed("attack"):
		print("Is pressed")
		can_swing = false
		model.hit()
		model.done.connect(func(): can_swing = true; hit_objects = [], ConnectFlags.CONNECT_ONE_SHOT)

func attack() -> void:
	var bodies = weapon_collider.get_overlapping_bodies()
	for body in bodies:
		if body is Goon and not hit_objects.has(body):
			print("damaging ", body.name)
			body.health -= damage
			var direction = Vector2.RIGHT.rotated(global_rotation)
			body.knockback = direction * knockback
			var particles = hit_particles.duplicate()
			add_child(particles)
			particles.global_position = body.global_position
			particles.global_rotation = body.global_rotation
			particles.run()
			hit_objects.append(body)
