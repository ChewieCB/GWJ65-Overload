extends Node

signal enter_scene
signal exit_scene
signal game_over
signal retry_current_level
signal level_complete(level)
signal level_select(level)
signal pause_scene
signal resume_scene

# Hardcoded info anims
signal info_0

@onready var levels:
	set(value):
		levels = value
		for level in levels:
			if level is VBoxContainer:
				level.is_locked = true
var unlocked_level_idx: int:
	set(value):
		unlocked_level_idx = value
var completed_levels = []

@onready var intro_music = load("res://assets/music/main_menu/main_intro.mp3")
@onready var main_menu_music = load("res://assets/music/main_menu/main_level_select.mp3")
@onready var level_1_music = load("res://assets/music/level_1_music.mp3")

var current_level_path: String


func _ready():
	SoundManager.play_music(intro_music, 0.5)
	#retry_current_level.connect(_restart_level)


func main_screen():
	SoundManager.play_music(main_menu_music, 0.5)


func change_level(level: String):
	SoundManager.stop_music(1.0)
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://src/levels/MainScenePostProcessing.tscn")
	SoundManager.play_music(level_1_music)

#func _restart_level():
	#get_tree().change_scene_to_file()


func complete_level(level: Node3D):
	completed_levels.append(level)
	unlocked_level_idx += 1
	var test0 = SoundManager.get_currently_playing_music()
	get_tree().change_scene_to_file("res://src/levels/IntroScene.tscn")



