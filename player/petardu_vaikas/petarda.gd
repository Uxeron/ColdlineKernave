extends CharacterBody2D

var speed: float = 200.0
var fuse: float = 1.0
var damage: float = 100.0
var target: Vector2

func _ready() -> void:
	get_tree().create_timer(fuse).timeout.connect(func(): explode())


func _physics_process(delta: float) -> void:
	if target == global_position:
		collision_layer = 0
		return
	
	var motion := (target - global_position).normalized() * speed * delta
	if motion.length() > (target - global_position).length():
		motion = (target - global_position)
	
	var collision := move_and_collide(motion)
	if collision:
		target = global_position

func explode() -> void:
	var bodies = $Explosion.get_overlapping_bodies()
	for body in bodies:
		if body is Goon:
			body.health -= damage
	$SelfDestructingParticles.run()
	queue_free()
