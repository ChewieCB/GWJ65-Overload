extends Node3D

@onready var box_node = $Boxes


func _ready():
	#TransitionManager.retry_current_level.connect()
	TransitionManager.pause_scene.connect(_pause)
	TransitionManager.resume_scene.connect(_resume)

func _pause():
	set_physics_process(false)
	set_process(false)

func _resume():
	set_physics_process(true)
	set_process(true)


func _on_end_level_trigger_body_entered(body):
	if body is Player:
		TransitionManager.complete_level(self)


func _on_info_0_trigger_body_entered(body):
	if body is Player:
		TransitionManager.emit_signal("info_0")
		$AnimTriggers/Info0Trigger.queue_free()


func _on_kill_zone_body_entered(body):
	if body is Player:
		body.state_chart.send_event("death")
	elif body is CharacterBody3D or body is RigidBody3D:
		body.health -= 200
