class_name Lašininis
extends CharacterBody2D

@export var speed: float = 50.0
@export var turning_speed: float = 0.1
@onready var dash_turning_speed: float = turning_speed * 0.04
@export var health: float = 70.0:
	set(value):
		if value < health and current_state == STATE.EATING:
			move(0.0)
		health = value

@onready var max_health: float = health
@export var healing_amount: float = 20.0
@export var damage: float = 30.0
@export var target: Node2D
@onready var model = get_child(0)
@onready var animation_player: AnimationPlayer = $Lašininis/AnimationPlayer

enum STATE { MOVING, ATTACKING, DASHING, EATING }

var current_state: STATE
var preparing_to_dash: bool = false

func _ready() -> void:
	current_state = STATE.MOVING
	animation_player.play("dundėjimas")


func _physics_process(delta: float) -> void:
	match current_state:
		STATE.MOVING:
			move(delta)
			if randi_range(0, 300) == 0:
				call_deferred("dash", 0.0)
		STATE.ATTACKING:
			pass
		STATE.DASHING:
			dash(delta)
		STATE.EATING:
			pass


func move(delta: float) -> void:
	if current_state != STATE.MOVING:
		current_state = STATE.MOVING
		animation_player.stop()
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
	var rotation_to_target = global_position.angle_to_point(target.global_position)
	var rotation_delta = rotation_to_target - global_rotation
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


func attack() -> void:
	current_state = STATE.ATTACKING
	animation_player.stop()

	animation_player.play("užvožimas")
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
	print("dealt damage!")
