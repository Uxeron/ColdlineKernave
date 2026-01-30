extends StaticBody2D

@export var health: float = 1000.0:
	set(value):
		health = value
		take_damage()
@onready var max_health: float = health

func take_damage():
	scale = Vector2(health / max_health, health / max_health)
