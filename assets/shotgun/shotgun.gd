extends Node3D

@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree["parameters/playback"]

# Shooting 
# Damage per pellet
var damage: int = 5
var spread: int = 10
@onready var ray_container = $Rays

# Ammo
enum AMMO_TYPE {
	BUCKSHOT,
	BLUE,
	YELLOW
}
# Ammo - meshes/textures
@onready var ammo_mesh = $Rig/Shotgun/Ammo
@onready var ammo_red_tex = load("res://assets/shotgun/Ammo_Textures/Ammo.png")
@onready var ammo_yellow_tex = load("res://assets/shotgun/Ammo_Textures/ammo_yellow.png")
@onready var ammo_blue_tex = load("res://assets/shotgun/Ammo_Textures/ammo_blue.png")
@onready var ammo_textures = [ammo_red_tex, ammo_blue_tex, ammo_yellow_tex]

@onready var ammo_ui = $UI/AmmoUI

var current_tex_idx = 0
# The type/colour of shell currently held, to be loaded on next reload
var palmed_shell_idx = 0
var palmed_shell = AMMO_TYPE.BUCKSHOT

var max_ammo: int = 5
var _current_ammo: int = 5
var current_ammo_1: int = 0
var current_ammo_2: int = 0
var current_ammo_3: int = 0
var current_ammo_pools = [current_ammo_1, current_ammo_2, current_ammo_3]
var reserve_ammo_1: int = 30
var reserve_ammo_2: int = 30
var reserve_ammo_3: int = 30
var reserve_ammo_pools = [reserve_ammo_1, reserve_ammo_2, reserve_ammo_3]
#
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
	randomize()
	for _ray in ray_container.get_children():
		_ray.target_position.z = randi_range(spread, -spread)
		_ray.target_position.y = randi_range(spread, -spread)
	
	state_machine.start("idle")
	# Load the initial ammo into the UI
	for _shell in range(max_ammo):
		ammo_ui.load_shell(AMMO_TYPE.BUCKSHOT)
		loaded_ammo.push_back(AMMO_TYPE.BUCKSHOT)
		current_ammo_1 += 1


func cycle_shell(backwards:bool=false):
	if backwards:
		palmed_shell_idx -= 1
	else:
		palmed_shell_idx += 1
	# Cycle the index through the ammo types
	var _new_shell_idx = palmed_shell_idx % AMMO_TYPE.size()
	palmed_shell = _new_shell_idx


func reset_shell():
	# Set the shell to whatever the last 
	palmed_shell_idx = loaded_ammo.back()
	palmed_shell = palmed_shell_idx


func shoot(is_one_handed: bool = false):
	# Do nothing if the shoot timer hasn't finished
	if not _shoot_timer.is_stopped():
		return
	
	if _current_ammo == 0:
		print("Click")
		# TODO - Play empty click
		# TODO - Add auto reload 1 available shell when empty
		return
				
	var next_shell_idx = loaded_ammo.pop_front()
	match next_shell_idx:
		0:
			current_ammo_1 -= 1
		1:
			current_ammo_2 -= 1
		2:
			current_ammo_3 -= 1
	
	_current_ammo -= 1
	
	# 
	for _ray in ray_container.get_children():
		_ray.target_position.z = randi_range(spread, -spread)
		_ray.target_position.y = randi_range(spread, -spread)
		if _ray.is_colliding():
			#_draw_debug_sphere(0.1, _ray.get_collision_point())
			var collider = _ray.get_collider()
			if collider is CharacterBody3D or collider is RigidBody3D:
				collider.hit(damage)
			# Draw spark
			if collider is CharacterBody3D:
				var spark_instance = load("res://src/particles/spark/SparkParticles.tscn").instantiate()
				spark_instance.set_position(_ray.get_collision_point())
				get_tree().get_root().add_child(spark_instance)
	
	# UI updates
	ammo_ui.spend_shell()
	
	var _anim_state = "shoot"
	var _time = _2h_shot_time
	if is_one_handed:
		_anim_state = "shoot_1_hand"
		_time = _1h_shot_time
	
	state_machine.travel(_anim_state)
	_shoot_timer.start(_time)


func _draw_debug_sphere(size: float, location: Vector3) -> void:
	var scene_root = get_tree().root.get_children()[0]
	# Draw a debug sphere on impact
	var debug_sphere = SphereMesh.new()
	debug_sphere.radial_segments = 4
	debug_sphere.rings = 4
	debug_sphere.radius = size
	debug_sphere.height = size * 2
	# Bright red material (unshaded).
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 0, 0)
	material.flags_unshaded = true
	debug_sphere.surface_set_material(0, material)
	# Add to meshinstance in the right place.
	var node = MeshInstance3D.new()
	node.mesh = debug_sphere
	node.global_transform.origin = location
	scene_root.add_child(node)


func reload():
	if not _reload_timer.is_stopped():
		return
	
	match palmed_shell:
		AMMO_TYPE.BUCKSHOT:
			if reserve_ammo_1 > 0 and _current_ammo < max_ammo:
				current_ammo_1 += 1
				reserve_ammo_1 -= 1
			else:
				return
		AMMO_TYPE.BLUE:
			if reserve_ammo_2 > 0 and _current_ammo < max_ammo:
				current_ammo_2 += 1
				reserve_ammo_2 -= 1
			else:
				return
		AMMO_TYPE.YELLOW:
			if reserve_ammo_3 > 0 and _current_ammo < max_ammo:
				current_ammo_3 += 1
				reserve_ammo_3 -= 1
			else:
				return
		_:
			return
	
	_current_ammo += 1
		
	var _anim_state = "reload"
	var _time = _2h_reload_time
	
	state_machine.travel(_anim_state)
	_reload_timer.start(_time)
	
	loaded_ammo.push_back(palmed_shell)
	
	# UI updates
	ammo_ui.load_shell(palmed_shell)
	ammo_ui.change_max_ammo(palmed_shell, [reserve_ammo_1, reserve_ammo_2, reserve_ammo_3][palmed_shell])


func next_ammo_type():
	var next_texture = ammo_textures[palmed_shell]
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
		var player = get_parent().get_parent().get_parent()
		box_instance.player = player
		
		var box_pos = spawn_node.global_transform.origin
		var box_rot = spawn_node.global_transform.basis
		var direction = box_rot.rotated(Vector3(1, 0, 0), PI/10)
		
		box_instance.transform.basis = box_rot
		box_instance.set_position(box_pos)
		box_instance.apply_impulse(-direction.z * 20, Vector3.ZERO)
		get_tree().get_root().add_child(box_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
