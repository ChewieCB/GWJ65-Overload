extends Node3D

@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree["parameters/playback"]

@onready var ammo_mesh = $Rig/Shotgun/Ammo
@onready var ammo_red_tex = load("res://assets/shotgun/Ammo_Textures/Ammo.png")
@onready var ammo_yellow_tex = load("res://assets/shotgun/Ammo_Textures/ammo_yellow.png")
@onready var ammo_blue_tex = load("res://assets/shotgun/Ammo_Textures/ammo_blue.png")
@onready var ammo_textures = [ammo_red_tex, ammo_yellow_tex, ammo_blue_tex]
var current_tex_idx = 0

@onready var box_slot_1 = $Box1Slot
@onready var box_slot_2 = $Box2Slot
@onready var box_slot_3 = $Box3Slot
@onready var box_slots = [box_slot_1, box_slot_2, box_slot_3]
var max_boxes = 3
var boxes_held = 0



# Called when the node enters the scene tree for the first time.
func _ready():
	state_machine.start("idle")


func next_ammo_type():
	current_tex_idx += 1
	if current_tex_idx > ammo_textures.size() - 1:
		current_tex_idx = 0
	var next_texture = ammo_textures[current_tex_idx]
	ammo_mesh.texture.albedo_texture = next_texture


func add_box():
	if boxes_held == max_boxes:
		return
	box_slots[boxes_held].visible = true
	boxes_held += 1


func remove_box():
	if boxes_held == 0:
		return false
	box_slots[boxes_held - 1].visible = false
	boxes_held -= 1
	return true


func launch_box():
	if remove_box():
		var box_instance = load("res://src/interactible/box/Box.tscn").instantiate()
		var spawn_node = get_parent().get_node("BoxSpawn")
		var box_pos = spawn_node.global_transform.origin
		var box_rot = spawn_node.global_transform.basis
		box_instance.transform.basis = box_rot
		box_instance.set_position(box_pos)
		box_instance.apply_impulse(Vector3(0.0, 0.0, 10.0), Vector3.ZERO)
		get_tree().get_root().add_child(box_instance)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
