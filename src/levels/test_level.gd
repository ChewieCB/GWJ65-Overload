extends Node3D

@onready var box_node = $Boxes


func _ready():
	TransitionManager.retry_current_level.connect(_retry_level)
	TransitionManager.pause_scene.connect(_pause)
	TransitionManager.resume_scene.connect(_resume)

func _pause():
	set_physics_process(false)
	set_process(false)

func _resume():
	set_physics_process(true)
	set_process(true)

func _retry_level():
	get_tree().reload_current_scene()


func _on_end_level_trigger_body_entered(body):
	if body is Player:
		TransitionManager.complete_level(self)
