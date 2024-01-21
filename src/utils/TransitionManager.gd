extends Node

signal enter_scene
signal exit_scene
signal game_over
signal retry_current_level
signal level_select(level)
signal pause_scene
signal resume_scene

var current_level_idx = 0
var levels = [
	"res://src/levels/test_qwazy_qodot/TestQodot.tscn",
]
var locked_levels = []
var completed_levels = []


func _ready():
	locked_levels = levels.duplicate()
	locked_levels.pop_front()


func complete_level(level: Node3D):
	completed_levels.append(levels[current_level_idx])
	current_level_idx += 1
	locked_levels.remove_at(current_level_idx)
	get_tree().change_scene_to_file("res://src/levels/IntroScene.tscn")



