extends CharacterBody2D

@export var speed: float = 100.0
@export var health: float = 100.0
@export var damage: float = 100.0
@export var target: Node2D
@onready var self_destructing_particles: SelfDestructingParticles = $SelfDestructingParticles

func _physics_process(_delta: float) -> void:
	if health <= 0:
		die()
	
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider == target:
			assert(target.get("health") != null)
			target.health -= damage
			die()
			return

	global_rotation = global_position.angle_to_point(target.global_position)
	velocity = (target.global_position - global_position).normalized() * speed
	move_and_slide()

func die() -> void:
	self_destructing_particles.run()
	queue_free()
