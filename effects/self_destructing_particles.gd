class_name SelfDestructingParticles
extends Node2D

func run():
	assert(get_children().size() == 1)
	if not is_inside_tree():
		return
	
	reparent(MapLoader.current_scene)
	
	var particles : GPUParticles2D = get_child(0)
	particles.emitting = true
	
	await get_tree().create_timer(particles.lifetime).timeout
	
	queue_free()
