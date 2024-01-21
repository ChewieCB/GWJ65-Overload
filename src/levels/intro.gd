extends Node2D

@onready var anim_player = $AnimationPlayer
@onready var anim_scene_player = $SceneAnims
@onready var anim_state_machine = $SceneAnimTree.get("parameters/playback")
@onready var game_viewport: SubViewport = $SubViewport
@onready var vhs_bg: TextureRect = $TVContent/VideoSlidesFrame/Control/TextureRect

@export var skip_intro: bool = true

func _ready():
	if skip_intro:
		anim_state_machine.travel("level_select_in_skip")
	else:
		anim_state_machine.travel("intro_0_welcome")
	TransitionManager.level_select.connect(_select_level)


#func _input(event):
	#game_viewport.push_input(event)

func start_game():
	pass
	#get_tree().change_scene_to_file("res://src/levels/MainScenePostProcessing.tscn")


func _select_level(level: String):
	anim_state_machine.travel("level_select_out")
	await get_tree().create_timer(0.9).timeout
	get_tree().change_scene_to_file(level)


func _change_bg_texture(new_texture: GradientTexture1D):
	vhs_bg.texture = new_texture

func _change_bg_text(label_path: NodePath, text: String):
	var label = get_node(label_path)
	label.text = text

func _pause_gameplay():
	TransitionManager.emit_signal("pause_scene")

func _resume_gameplay():
	TransitionManager.emit_signal("resume_scene")

func _release_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _capture_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
