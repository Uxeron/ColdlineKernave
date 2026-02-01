class_name Goon
extends CharacterBody2D

@export var speed: float = 50.0
@export var health: float = 70.0:
	set(value):
		health = value
		if is_ready:
			$HitSnowman.play()

@export var damage: float = 100.0
@export var target: Node2D
@onready var self_destructing_particles: SelfDestructingParticles = $SelfDestructingParticles
@onready var model = get_child(0)
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var did_animation: bool = false
var animating: bool = false

var knockback: Vector2 = Vector2.ZERO
var is_ready: bool = false

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var scaling = randf_range(0.3, 1.4)
	
	$Walk.play()
	
	model.scale = Vector2(scaling, scaling)
	$CollisionShape2D.scale = model.scale
	speed = speed * (1 / scaling)
	health = health * scaling
	damage = damage * scaling
	
	is_ready = true
	
	actor_setup.call_deferred()

func actor_setup():
	await get_tree().physics_frame
	navigation_agent.target_position = target.global_position

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
		#velocity = (target.global_position - global_position).normalized() * speed
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		velocity = global_position.direction_to(next_path_position) * speed
	else:
		velocity = knockback / 2.0
		if velocity.length() < 5.0:
			velocity = Vector2.ZERO
		knockback = velocity
	move_and_slide()
	
	if not did_animation and global_position.distance_to(target.global_position) < 70:
		animating = true
		$Walk.stop()
		model.jump()
		model.done.connect(func(): animating = false; did_animation = true; speed = 400, ConnectFlags.CONNECT_ONE_SHOT)

func die() -> void:
	var sound = $DieSnowman
	sound.reparent(self_destructing_particles)
	sound.play()
	self_destructing_particles.run()
	Global.active_enemies -= 1
	print("died")
	queue_free()
