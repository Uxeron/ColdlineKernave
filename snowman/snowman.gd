extends Node2D

signal done

func _ready() -> void:
	$AnimationPlayer.play("walk")

func jump() -> void:
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("jump")
	await get_tree().create_timer($AnimationPlayer.current_animation_length - 0.15).timeout
	done.emit()
