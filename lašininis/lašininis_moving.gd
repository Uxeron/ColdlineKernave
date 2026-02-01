class_name Lašininis
extends CharacterBody2D

@export var speed: float = 50.0
@export var turning_speed: float = 0.1
@onready var dash_turning_speed: float = turning_speed * 0.04
@export var health: float = 400.0:
	set(value):
		if value < health:
			$HitFlesh.play()
			if current_state == STATE.EATING:
				move(0.0)
		health = value
		if health <= 0.0:
			die.call_deferred()
		Global.lasininis_hp.emit(health / max_health)

@onready var max_health: float = health
@export var healing_amount: float = 200.0
@export var damage: float = 30.0
@export var knockback_target: float = 3000.0
@export var target: Node2D
@onready var model = get_child(0)
@onready var animation_player: AnimationPlayer = $Lašininis/AnimationPlayer
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

enum STATE { MOVING, ATTACKING, DASHING, EATING, DEAD }

var current_state: STATE
var preparing_to_dash: bool = false

func _ready() -> void:
	current_state = STATE.MOVING
	animation_player.play("dundėjimas")
	
	actor_setup.call_deferred()

func actor_setup():
	await get_tree().physics_frame
	navigation_agent.target_position = target.global_position


func _physics_process(delta: float) -> void:
	navigation_agent.target_position = target.global_position
	match current_state:
		STATE.MOVING:
			move(delta)
		STATE.ATTACKING:
			pass
		STATE.DASHING:
			dash(delta)
		STATE.EATING:
			pass
		STATE.DEAD:
			pass


func move(delta: float) -> void:
	if current_state != STATE.MOVING:
		current_state = STATE.MOVING
		animation_player.stop()
		$"LašininisWalk".play()
		animation_player.play("dundėjimas")
	
	generic_move(delta)
	if $AttackArea.overlaps_body(target):
		_on_attack_area_body_entered(target)


func dash(delta: float) -> void:
	if preparing_to_dash:
		return
	
	if current_state != STATE.DASHING:
		preparing_to_dash = true
		current_state = STATE.DASHING
		animation_player.stop()
		await get_tree().create_timer(0.5).timeout
		
		animation_player.play("dundėjimas")
		animation_player.speed_scale = 3.0
		preparing_to_dash = false
		get_tree().create_timer(1.5).timeout.connect(func(): eat())
	
	generic_move(delta * 5.0)


func eat() -> void:
	if current_state != STATE.DASHING:
		return # We hit the player
	
	current_state = STATE.EATING
	animation_player.stop()
	animation_player.speed_scale = 1.0
	animation_player.play("paėdimas")
	await get_tree().create_timer(animation_player.current_animation_length).timeout
	
	if current_state != STATE.EATING:
		return # Was interrupted
	
	health += healing_amount
	if health > max_health:
		health = max_health
	
	move(0.0)


func generic_move(delta: float) -> void:
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var rotation_to_next_position = global_position.angle_to_point(next_path_position)
	var rotation_delta = rotation_to_next_position - global_rotation
	
	var rotation_to_target = global_position.angle_to_point(target.global_position)
	var rotation_to_target_delta = rotation_to_target - global_rotation
	if abs(rotation_to_target_delta) < 0.1 and global_position.distance_to(target.global_position) > 200 and current_state != STATE.DASHING:
		if randi_range(0, 200) == 0:
			call_deferred("dash", 0.0)
	
	print(rotation_delta)
	if rotation_delta > 5.0:
		rotation_delta -= TAU
	if rotation_delta < -5.0:
		rotation_delta += TAU
	
	var current_turning_speed = turning_speed
	if current_state == STATE.DASHING:
		current_turning_speed = dash_turning_speed
	
	if rotation_delta > current_turning_speed:
		rotation_delta = current_turning_speed
	if rotation_delta < -current_turning_speed:
		rotation_delta = -current_turning_speed
	global_rotation += rotation_delta
	
	var motion = Vector2.RIGHT.rotated(global_rotation).normalized() * speed
	var collision = move_and_collide(motion * delta)
	
	if collision and current_state == STATE.DASHING:
		var collider = collision.get_collider()
		if collider == target:
			target.health -= damage * 2.0
			animation_player.speed_scale = 1.0
			move(0.0)
		if collider is StaticBody2D:
			eat()


func attack() -> void:
	current_state = STATE.ATTACKING
	animation_player.stop()

	animation_player.play("užvožimas")
	$"Maišas".play()
	await get_tree().create_timer(animation_player.current_animation_length).timeout
	
	move(0.0)


func _on_attack_area_body_entered(body: Node2D) -> void:
	if current_state != STATE.MOVING:
		return
	
	if body != target:
		return
	
	if current_state == STATE.MOVING:
		attack()


func _on_bag_collider_area_body_entered(body: Node2D) -> void:
	if body != target:
		return
	
	if not model.can_deal_damage:
		return
	
	target.health -= damage
	if body.get("knockback") != null:
		var direction = Vector2.RIGHT.rotated(global_rotation)
		body.knockback = direction * knockback_target

	print("dealt damage!")

func die() -> void:
	current_state = STATE.DEAD
	set_physics_process(false)
	Global.character_stage += 1
	
	$GPUParticles2D.emitting = true
	await get_tree().create_timer(2.0).timeout
	MapLoader.add_scene("res://ui/laimėjimas.tscn")
