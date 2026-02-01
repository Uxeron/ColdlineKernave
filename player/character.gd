class_name Character
extends CharacterBody2D

@export var speed: float = 200.0
@export var health: float = 100.0:
	set(value):
		health = value
		Global.kanapinis_hp.emit(health / max_health)
		take_damage()

@onready var max_health: float = health
@export var damage: float = 50.0
@export var knockback_target: float = 2000.0
@onready var model: Model = get_child(0)
@onready var weapon_collider: Area2D = model.weapon_collider
@onready var hit_particles: Node2D = $HitParticles

@export var character: int = 0

var can_swing: bool = true
var hit_objects: Array = []

var knockback: Vector2 = Vector2.ZERO

var previous_motion: Vector2 = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	global_rotation = global_position.angle_to_point(mouse_position)
	
	var motion = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if motion != Vector2.ZERO and previous_motion == Vector2.ZERO:
		$Walk.play()
	if motion == Vector2.ZERO and previous_motion != Vector2.ZERO:
		$Walk.stop()
	previous_motion = motion
	
	if knockback == Vector2.ZERO:
		velocity = motion * speed
	else:
		velocity = knockback / 2.0
		if velocity.length() > 400:
			velocity = velocity.normalized() * 400.0
			
		knockback -= velocity
		if knockback.length() < 5.0:
			knockback = Vector2.ZERO
	move_and_slide()
	
	if not can_swing:
		# If we can't swing, means we're already swinging
		if model.can_damage:
			attack()
		return
		
	if Input.is_action_pressed("attack"):
		can_swing = false
		if model.name == "Kanapinis":
			$"Maišas".play()
		if model.name == "Giltine":
			$Dalgis.play()
		
		model.hit()
		model.done.connect(func(): can_swing = true; hit_objects = [], ConnectFlags.CONNECT_ONE_SHOT)

func take_damage():
	$HitFlesh.play()
	
	if health <= 0.0:
		MapLoader.add_scene("res://ui/game_loss.tscn")
		process_mode = Node.PROCESS_MODE_DISABLED
		return

func attack() -> void:
	var bodies = weapon_collider.get_overlapping_bodies()
	for body in bodies:
		if (body is Goon or body is Lašininis) and not hit_objects.has(body):
			print("player hit ", body)
			body.health -= damage
			hit_objects.append(body)
			if body.get("knockback") != null:
				var direction = Vector2.RIGHT.rotated(global_rotation)
				body.knockback = direction * knockback_target
				var particles = hit_particles.duplicate()
				add_child(particles)
				particles.global_position = body.global_position
				particles.global_rotation = body.global_rotation
				particles.run()
