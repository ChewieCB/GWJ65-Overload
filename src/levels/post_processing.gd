extends Node2D

@onready var anim_player = $AnimationPlayer


func _ready():
	TransitionManager.enter_scene.connect(_tv_on)
	TransitionManager.exit_scene.connect(_tv_off)


func _tv_on():
	anim_player.play("tv_on")

func _tv_off():
	anim_player.play("tv_off")
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
