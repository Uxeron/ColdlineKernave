extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func uppies() -> void:
	animation_player.play("uppies")


func anti_uppies() -> void:
	animation_player.play("letsgetdowntobussiness")
