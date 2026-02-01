extends Camera2D


@export var max_offset: float = 30


func _process(_delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var the_size = get_viewport().get_visible_rect().size
	
	var offset_ratio_x: float = (clamp(mouse_pos.x / the_size.x, 0.0, 1.0) - 0.5) * 2.0
	var offset_ratio_y: float = (clamp(mouse_pos.y / the_size.y, 0.0, 1.0) - 0.5) * 2.0
	
	var offset_ratio = Vector2(offset_ratio_x, offset_ratio_y)
	
	print(offset_ratio)
	
	offset = max_offset * offset_ratio
