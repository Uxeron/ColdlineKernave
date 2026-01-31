class_name Goon
extends CharacterBody2D

@export var speed: float = 50.0
@export var health: float = 70.0
@export var damage: float = 100.0
@export var target: Node2D
@onready var self_destructing_particles: SelfDestructingParticles = $SelfDestructingParticles
@onready var model = get_child(0)

var did_animation: bool = false
var animating: bool = false

var knockback: Vector2 = Vector2.ZERO

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var scaling = randf_range(0.3, 1.4)
	
	model.scale = Vector2(scaling, scaling)
	$CollisionShape2D.scale = model.scale
	speed = speed * (1 / scaling)
	health = health * scaling
	damage = damage * scaling

func _physics_process(_delta: float) -> void:
	if health <= 0:
		die()
	
	if animating:
		return
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider == null:
			continue
		
		if collider == target:
			assert(target.get("health") != null)
			target.health -= damage
			die()
			return
		if collider.name == "Character":
			collider.velocity = -collision.get_normal() * collision.get_collider_velocity().length()
			collider.move_and_slide()

	global_rotation = global_position.angle_to_point(target.global_position)
	if knockback == Vector2.ZERO:
		velocity = (target.global_position - global_position).normalized() * speed
	else:
		velocity = knockback / 2.0
		if velocity.length() < 5.0:
			velocity = Vector2.ZERO
		knockback = velocity
	move_and_slide()
	
	if not did_animation and global_position.distance_to(target.global_position) < 70:
		animating = true
		model.jump()
		model.done.connect(func(): animating = false; did_animation = true; speed = 400, ConnectFlags.CONNECT_ONE_SHOT)

func die() -> void:
	self_destructing_particles.run()
	queue_free()
