class_name Model
extends Node2D

signal done

@onready var weapon_collider: Area2D = %WeaponCollider
@export var can_damage: bool = false

func hit() -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.play("hit")
	await get_tree().create_timer($AnimationPlayer.current_animation_length).timeout
	done.emit()
