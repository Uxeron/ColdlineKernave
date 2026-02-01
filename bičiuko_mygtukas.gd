extends Button


@export var target_scene_path: String = "res://kiemas/kiemas.tscn"
@export var snukis: Node2D
@export var character_stage: int = 0

@export var aš_esu_vydūnas: bool = false


func _ready() -> void:
	self.pressed.connect(_pressed)
	
	disabled = Global.character_stage < character_stage
	
	self.mouse_entered.connect(do_face_effect)
	self.mouse_exited.connect(undo_face_effect)


func _pressed() -> void:
	%LoadingIndicator.visible = true
	await get_tree().create_timer(0.1).timeout # Make sure the "Loading" shows up
	
	MapLoader.load_scene(target_scene_path)


func do_face_effect() -> void:
	snukis.scale = Vector2(40, 40)
	
	if aš_esu_vydūnas:
		for child in snukis.get_children(true):
			if child is AnimationPlayer:
				child.play("uppies")


func undo_face_effect() -> void:
	snukis.scale = Vector2(25, 25)
	
	if aš_esu_vydūnas:
		for child in snukis.get_children(true):
			if child is AnimationPlayer:
				child.play("letsgetdowntobussiness")
