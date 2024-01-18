extends Node3D

@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree["parameters/playback"]

# Ammo
@onready var ammo_mesh = $Rig/Shotgun/Ammo
@onready var ammo_red_tex = load("res://assets/shotgun/Ammo_Textures/Ammo.png")
@onready var ammo_yellow_tex = load("res://assets/shotgun/Ammo_Textures/ammo_yellow.png")
@onready var ammo_blue_tex = load("res://assets/shotgun/Ammo_Textures/ammo_blue.png")
@onready var ammo_textures = [ammo_red_tex, ammo_yellow_tex, ammo_blue_tex]

@onready var ammo_ui = $UI/AmmoUI

var current_tex_idx = 0

var max_ammo: int = 5
var _current_ammo: int = max_ammo
var reserve_ammo: int = 30
enum AMMO_TYPE {
	BUCKSHOT,
	BLUE,
	YELLOW
}
var current_ammo_type: AMMO_TYPE = AMMO_TYPE.BUCKSHOT
var loaded_ammo = []

var _2h_shot_time: float = 0.7
var _1h_shot_time: float = 1.1
var _2h_reload_time: float = 0.65
#var _1h_reload_time: float = 1.1
@onready var _shoot_timer = $ShootTimer
@onready var _reload_timer = $ReloadTimer

# Boxes
@onready var box_slot_1 = $Box1Slot
@onready var box_slot_2 = $Box2Slot
@onready var box_slot_3 = $Box3Slot
@onready var box_slots = [box_slot_1, box_slot_2, box_slot_3]
var max_boxes = 3
var boxes_held = 0




func _ready():
	state_machine.start("idle")
	# Load the initial ammo into the UI
	for _shell in range(max_ammo):
		ammo_ui.load_shell(AMMO_TYPE.BUCKSHOT)


func shoot(is_one_handed: bool = false):
	# Do nothing if the shoot timer hasn't finished
	if not _shoot_timer.is_stopped():
		return
	
	_current_ammo -= 1
	
	# TODO - add random spread raycasts for buckshot
	
	# UI updates
	ammo_ui.spend_shell()
	
	var _anim_state = "shoot"
	var _time = _2h_shot_time
	if is_one_handed:
		_anim_state = "shoot_1_hand"
		_time = _1h_shot_time
	
	state_machine.travel(_anim_state)
	_shoot_timer.start(_time)
	
	loaded_ammo.pop_front()


func reload(ammo_type: AMMO_TYPE = AMMO_TYPE.BUCKSHOT):
	if not _reload_timer.is_stopped():
		return
	
	if reserve_ammo > 0:
		_current_ammo += 1
		reserve_ammo -= 1
		
		var _anim_state = "reload"
		var _time = _2h_reload_time
		
		state_machine.travel(_anim_state)
		_reload_timer.start(_time)
		
		loaded_ammo.push_back(ammo_type)
		
		# UI updates
		ammo_ui.load_shell(ammo_type)
		ammo_ui.change_max_ammo(ammo_type, reserve_ammo)


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
