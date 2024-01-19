extends Node2D

@onready var anim_player = $AnimationPlayer
@onready var game_viewport: SubViewport = $SubViewport


func _ready():
	TransitionManager.enter_scene.connect(_tv_on)
	TransitionManager.exit_scene.connect(_tv_off)


func _input(event):
	if event.is_action_pressed("DEBUG_add_box"):
		anim_player.play("slide_zoom_in_quarter")
	elif event.is_action_pressed("DEBUG_remove_box"):
		anim_player.play("slide_zoom_out_quarter")
	
	game_viewport.push_input(event)


func _tv_on():
	anim_player.play("tv_on")
	await anim_player.animation_finished
	anim_player.play("slide_zoom_in_quarter")

func _tv_off():
	anim_player.play("slide_zoom_out_quarter")
	await anim_player.animation_finished
	await get_tree().create_timer(1.0).timeout
	anim_player.play("tv_off")
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
