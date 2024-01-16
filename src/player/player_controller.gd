extends CharacterBody3D


const SPEED = 10.0
const JUMP_VELOCITY = 5.5

@export var MOUSE_SENSITIVITY: float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Camera3D

@onready var shotgun = $CameraController/Camera3D/Shotgun

var _mouse_input: bool = false
var _mouse_rotation: Vector3
var _rotation_input: float
var _tilt_input: float
var _player_rotation: Vector3
var _camera_rotation: Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_1_handed: bool = false:
	set(value):
		is_1_handed = value
		match is_1_handed:
			true:
				shotgun.state_machine.travel("idle_1_hand")
			false:
				shotgun.state_machine.travel("idle")


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent):
	if event.is_action_pressed("exit"):
		get_tree().quit()
	elif event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _unhandled_input(event: InputEvent):
	_mouse_input = event is InputEventMouseMotion and \
	Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
	
	if event.is_action_pressed("DEBUG_add_box"):
		shotgun.add_box()
	elif event.is_action_pressed("DEBUG_remove_box"):
		shotgun.remove_box()
	
	if event.is_action_pressed("primary_fire"):
		if is_1_handed:
			shotgun.state_machine.travel("shoot_1_hand")
		else:
			shotgun.state_machine.travel("shoot")
	elif event.is_action_pressed("secondary_fire"):
		if is_1_handed:
			shotgun.state_machine.travel("push_1_hand")
			shotgun.launch_box()
		else:
			shotgun.state_machine.travel("push")
	elif event.is_action_released("reload"):
		if is_1_handed:
			pass
		else:
			shotgun.state_machine.travel("reload")
	elif event.is_action_released("switch_ammo_left"):
		if shotgun.state_machine.get_current_node() in [
			"show_ammo", "switch_ammo_retrieve", 
		]:
			if is_1_handed:
				pass
			else:
				shotgun.state_machine.travel("switch_ammo_pocket")
		else:
			if is_1_handed:
				pass
			else:
				shotgun.state_machine.travel("show_ammo")
	elif event.is_action_released("switch_ammo_right"):
		if shotgun.state_machine.get_current_node() in [
			"show_ammo", "switch_ammo_retrieve", 
		]:
			if is_1_handed:
				pass
			else:
				shotgun.state_machine.travel("switch_ammo_pocket")
		else:
			if is_1_handed:
				pass
			else:
				shotgun.state_machine.travel("show_ammo")


func _update_camera(delta: float):
	# Rotate camerae using outer rotation
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	_update_camera(delta)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
