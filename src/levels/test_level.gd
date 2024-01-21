extends Node3D

@export var box_count: int = 50

@onready var box_node = $Boxes
@onready var box_spawn = $BoxSpawnZone/CollisionShape3D
@onready var spawn_area = box_spawn.shape.extents
@onready var spawn_origin = box_spawn.global_position - spawn_area


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
