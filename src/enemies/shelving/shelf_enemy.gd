extends CharacterBody3D

signal dead

@onready var state_chart = $StateChart
@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var anim_state_machine = anim_tree["parameters/playback"]

@onready var sfx_creak_1 = load("res://src/enemies/shelving/sfx/Shelf_Creak_1.mp3")
@onready var sfx_creak_2 = load("res://src/enemies/shelving/sfx/Shelf_Creak_2.mp3")
@onready var creak_sfx = [
	sfx_creak_1, sfx_creak_2
]
@onready var sfx_hit_1 = load("res://src/enemies/shelving/sfx/Shelf_bullet_1.wav")
@onready var sfx_hit_2 = load("res://src/enemies/shelving/sfx/Shelf_bulelt_2.wav")
@onready var sfx_hit_3 = load("res://src/enemies/shelving/sfx/Shelf_bullet_3.wav")
@onready var hit_sfx = [
	sfx_hit_1, sfx_hit_2, sfx_hit_3
]
@onready var sfx_die = load("res://src/enemies/shelving/sfx/Shelf_die.mp3")
@onready var sfx_step_1 = load("res://src/enemies/shelving/sfx/Shelf_Step_individual_1.mp3")
@onready var sfx_step_2 = load("res://src/enemies/shelving/sfx/Shelf_Step_individual_2.mp3")
@onready var sfx_step_3 = load("res://src/enemies/shelving/sfx/Shelf_Step_individual_3.mp3")
@onready var sfx_step_4 = load("res://src/enemies/shelving/sfx/Shelf_Step_individual_4.mp3")
@onready var sfx_step_5 = load("res://src/enemies/shelving/sfx/Shelf_Step_individual_5.mp3")
@onready var sfx_step_6 = load("res://src/enemies/shelving/sfx/Shelf_Step_individual_6.mp3")
@onready var sfx_step_7 = load("res://src/enemies/shelving/sfx/Shelf_Step_individual_7.mp3")
@onready var step_sfx = [
	sfx_step_1, sfx_step_2, sfx_step_3, sfx_step_4, sfx_step_5, sfx_step_6, sfx_step_7
]

@onready var aim_timer = $AimingTimer

@onready var meshes = $Meshes
@onready var box_spawns = [
	$Meshes/BoxSpawn1,
	$Meshes/BoxSpawn2,
	$Meshes/BoxSpawn3,
	$Meshes/BoxSpawn4
	
]
@onready var red_mat = load("res://src/interactible/box/red_box_mat.tres")
@onready var blue_mat = load("res://src/interactible/box/blue_box_mat.tres")
@onready var yellow_mat = load("res://src/interactible/box/yellow_box_mat.tres")
@onready var colour_mats = [
	null,
	red_mat,
	blue_mat,
	yellow_mat
]
var held_box_colours = []

@export var is_static: bool = false
@export var shot_damage: float = 20.0
@export var health: float = 100.0:
	set(value):
		health = clamp(value, 0, 100.0)
		if health == 0:
			state_chart.send_event("death")
@export var aiming_time: float = 0.8

var target: CharacterBody3D
var locked_shot_position

var starting_rotation
var goal_rotation

const SPEED = 3.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	anim_state_machine.start("idle")
	# Randomize box colours
	for _spawn in box_spawns:
		var box_colour = randi_range(0, colour_mats.size() -1)
		_spawn.get_child(0).set_surface_override_material(0, colour_mats[box_colour])
		held_box_colours.append(box_colour)


func _physics_process(delta):
	velocity.y -= gravity
	move_and_slide()


func remove_box() -> bool:
	if box_spawns.size() > 0:
		return true
	return false


func shoot_box():
	if remove_box():
		# Determine target direction
		var spawn_marker = box_spawns.pop_front()
		var box_pos = spawn_marker.global_transform.origin
		if not locked_shot_position:
			return
		spawn_marker.look_at(locked_shot_position, Vector3.UP)
		var box_rot = spawn_marker.global_transform.basis
		var direction = box_rot#.rotated(Vector3(1, 0, 0), PI/10)
		
		# Spawn box and throw
		var box_instance = load("res://src/interactible/box/Box.tscn").instantiate()
		box_instance.transform.basis = box_rot
		box_instance.player = target
		box_instance.set_position(box_pos)
		box_instance.one_off_damage = 10.0
		box_instance.apply_impulse(-direction.z * 40, Vector3.ZERO)
		get_tree().get_root().add_child(box_instance)
		box_instance.current_box_colour = held_box_colours.pop_front()
		box_instance.pickup_timer.start(1.0)
		
		# Remove spawn
		spawn_marker.visible = false
		#spawn_marker.queue_free()
		#meshes.remove_child(spawn_marker)
		# Remove the damage after we can expect it to have missed the player
		await get_tree().create_timer(1.0).timeout
		if is_instance_valid(box_instance):
			box_instance.one_off_damage = 0.0
		
	# If we have no boxes left to shoot, repopulate
	if not remove_box():
		box_spawns = [
			$Meshes/BoxSpawn1,
			$Meshes/BoxSpawn2,
			$Meshes/BoxSpawn3,
			$Meshes/BoxSpawn4
		]
		for _spawn in box_spawns:
			var box_colour = randi_range(0, colour_mats.size() -1)
			_spawn.get_child(0).set_surface_override_material(0, colour_mats[box_colour])
			held_box_colours.append(box_colour)
			_spawn.visible = true


func populate_boxes_on_death():
	if box_spawns.size() > 0:
		for spawn in box_spawns:
			var box_pos = spawn.global_transform.origin
			var box_rot = spawn.global_transform.basis
			var box_instance = load("res://src/interactible/box/Box.tscn").instantiate()
			box_instance.transform.basis = box_rot
			if target:
				box_instance.player = target
			box_instance.set_position(box_pos)
			box_instance.apply_impulse(Vector3.UP * 10, Vector3.ZERO)
			spawn.queue_free()
			get_tree().get_root().add_child(box_instance)
			box_instance.pickup_timer.start(0.0)


func hit(damage:float=0.0, ammo_type:int=-1):
	health -= damage
	SoundManager.play_sound(hit_sfx[randi_range(0, hit_sfx.size()-1)])
	state_chart.send_event("hurt")


func sfx_creak():
	SoundManager.play_sound(creak_sfx[randi_range(0, creak_sfx.size()-1)])


func sfx_step():
	SoundManager.play_sound(step_sfx[randi_range(0, step_sfx.size()-1)])


func sfx_death():
	SoundManager.play_sound(sfx_die)


func _on_idle_state_entered():
	anim_state_machine.travel("idle")
	velocity = Vector3.ZERO


func _on_walking_state_entered():
	if is_static:
		return
	anim_state_machine.travel("walk")

func _on_walking_state_physics_processing(delta):
	if is_static:
		return
	if target:
		var _target_position = target.transform.origin
		_target_position.y = 0
		self.look_at(_target_position, Vector3.UP)
		velocity = -global_transform.basis.z * SPEED
		move_and_slide()


func _on_aiming_state_entered():
	anim_state_machine.travel("aim")
	velocity = Vector3.ZERO
	# Aim for a bit
	aim_timer.start(aiming_time)
	await aim_timer.timeout
	# Lock aim
	locked_shot_position = target.global_transform.origin
	self.look_at(locked_shot_position, Vector3.UP)
	# Shoot
	state_chart.send_event("shoot")

func _on_aiming_state_physics_processing(delta):
	if not locked_shot_position:
		var _target_position = target.transform.origin
		_target_position.y = 0
		self.look_at(_target_position, Vector3.UP)

func _on_aiming_state_exited():
	aim_timer.stop()
	anim_state_machine.travel("aim")


func _on_shooting_state_entered():
	anim_state_machine.travel("shoot")
	await get_tree().create_timer(0.7).timeout
	locked_shot_position = null
	var is_detected: bool = false
	var is_in_range: bool = false
	for body in $DetectionArea.get_overlapping_bodies():
		if body is Player:
			is_detected = true
			break
	for body in $ShootingArea.get_overlapping_bodies():
		if body is Player:
			is_in_range = true
	if is_detected:
		if is_in_range:
			state_chart.send_event("in_range")
		else:
			state_chart.send_event("left_range")
	else:
		state_chart.send_event("player_evaded")

func _on_shooting_state_physics_processing(delta):
	pass # Replace with function body.


func _on_hurt_state_entered():
	velocity = Vector3.ZERO
	anim_state_machine.travel("hurt")
	await get_tree().create_timer(0.2).timeout
	
	var is_detected: bool = false
	var is_in_range: bool = false
	for body in $DetectionArea.get_overlapping_bodies():
		if body is Player:
			is_detected = true
			break
	for body in $ShootingArea.get_overlapping_bodies():
		if body is Player:
			is_in_range = true
	if is_detected:
		if is_in_range:
			state_chart.send_event("in_range")
		else:
			state_chart.send_event("player_seen")
	else:
		state_chart.send_event("to_idle")
	
	for body in $DetectionArea.get_overlapping_bodies():
		if body is Player:
			target = body
			state_chart.send_event("player_seen")
			return
	
	state_chart.send_event("to_idle")


func _on_dead_state_entered():
	velocity = Vector3.ZERO
	emit_signal("dead")
	anim_state_machine.travel("die")
	await get_tree().create_timer(0.55).timeout
	populate_boxes_on_death()


func _on_detection_area_body_entered(body):
	if body is Player:
		target = body
		state_chart.send_event("player_seen")


func _on_detection_area_body_exited(body):
	if body is Player:
		target = null
		state_chart.send_event("player_lost")


func _on_shooting_area_body_entered(body):
	state_chart.send_event("in_range")


func _on_shooting_area_body_exited(body):
	state_chart.send_event("out_of_range")


func _on_box_deflection_area_body_entered(body):
	if body is RigidBody3D:
		if body.mass < 50:
			var direction = self.global_transform.basis
			# Rotate it away
			var rotation_z = PI/4
			var rotation_y = PI/8
			if body.position.x < 0:
				rotation_z = -PI/4
			direction = direction.rotated(Vector3.RIGHT, rotation_z)
			direction = direction.rotated(Vector3.FORWARD, rotation_y)
			body.apply_impulse(-direction.z * 200, Vector3.ZERO)
