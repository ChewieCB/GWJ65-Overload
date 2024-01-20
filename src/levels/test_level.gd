extends Node3D

@export var box_count: int = 50

@onready var box_node = $Boxes
@onready var box_spawn = $BoxSpawnZone/CollisionShape3D
@onready var spawn_area = box_spawn.shape.extents
@onready var spawn_origin = box_spawn.global_position - spawn_area


func _ready():
	for _old_box in box_node.get_children():
		_old_box.queue_free()
		box_node.remove_child(_old_box)
	randomize()
	var box_scene = load("res://src/interactible/box/Box.tscn")
	for _box in box_count:
		var box_instance = box_scene.instantiate()
		var box_pos = gen_random_pos()
		box_instance.set_position(box_pos)
		box_instance.rotation = Vector3(
			randf_range(0, TAU),
			randf_range(0, TAU),
			randf_range(0, TAU),
		)
		box_instance.apply_impulse(
			Vector3(0, -20, 0), Vector3.ZERO
		)
		box_node.add_child(box_instance)


func gen_random_pos():
	var x = randi_range(spawn_origin.x, spawn_area.x)
	var z = randi_range(spawn_origin.z, spawn_area.z)
	return Vector3(x, box_spawn.global_position.y, z)
