extends Node2D

@onready var anim_player = $AnimationPlayer
@onready var anim_scene_player = $SceneAnims
@onready var game_viewport: SubViewport = $SubViewport
@onready var vhs_bg: TextureRect = $TVContent/VideoSlidesFrame/Control/TextureRect


func _ready():
	TransitionManager.game_over.connect(_game_over)
	anim_scene_player.play("default")
	await anim_scene_player.animation_finished
	anim_scene_player.play("level_start")


func _input(event):
	game_viewport.push_input(event)


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


func _game_over():
	anim_scene_player.play("game_over")
	await anim_player.animation_finished


#func _tv_on():
	#anim_player.play("tv_on")
	#await anim_player.animation_finished
	#anim_player.play("slide_zoom_in_quarter")
#
#func _tv_off():
	#anim_player.play("slide_zoom_out_quarter")
	#await anim_player.animation_finished
	#await get_tree().create_timer(1.0).timeout
	#anim_player.play("tv_off")
	#await get_tree().create_timer(2.0).timeout
	#get_tree().reload_current_scene()


func _on_button_pressed():
	anim_scene_player.play("game_over_transition")
	await get_tree().create_timer(1.8).timeout
	TransitionManager.emit_signal("retry_current_level")
