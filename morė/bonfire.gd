extends StaticBody2D

@export var health: float = 1000.0:
	set(value):
		health = value
		take_damage()
@onready var max_health: float = health

@onready var start_light_scale: float = $PointLight2D.texture_scale
@onready var light_scale: float = start_light_scale
var adjusting_light: bool = false

func take_damage():
	var scaling = health / max_health
	$Ugnis.scale = Vector2(scaling, scaling)
	$Ugnis.amount_ratio = scaling
	$Dūmai.scale = Vector2(scaling, scaling)
	$Dūmai.amount_ratio = scaling
	light_scale = start_light_scale * scaling

func _process(_delta: float) -> void:
	if not adjusting_light:
		var light_tweener = get_tree().create_tween()
		adjusting_light = true
		light_tweener.tween_property(
			$PointLight2D,
			"texture_scale",
			light_scale + randf_range(-(light_scale/10.0), (light_scale/10.0)),
			0.3)
		light_tweener.tween_callback((func(): adjusting_light = false))
