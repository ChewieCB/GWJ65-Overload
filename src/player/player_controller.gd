extends CharacterBody3D
class_name Player

var is_player_control_disabled: bool = false
var is_dead: bool = false

# Movement vars
var SPEED = 10.0
const JUMP_VELOCITY = 6.5

@export var MOUSE_SENSITIVITY: float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Camera3D

@onready var state_chart = $StateChart
@onready var anim_player = $AnimationPlayer
@onready var anim_player_text = $AnimationPlayerText
@onready var overlay_label = $UI/Overlay/CenterContainer/MarkerText/Label

@onready var shotgun = $CameraController/Camera3D/Shotgun
@onready var melee_area = $MeleeArea

var _mouse_input: bool = false
var _mouse_rotation: Vector3
var _rotation_input: float
var _tilt_input: float
var _player_rotation: Vector3
var _camera_rotation: Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Health
var max_health: float = 100.0
var health: float = max_health:
	set(value):
		health = clamp(value, 0.0, max_health)
		shotgun.health_ui.update_health_bar(int(health))
		if health == 0.0:
			if shotgun.health_ui.lose_health_tick():
				health = max_health
				shotgun.health_ui.update_health_bar(int(health))
				state_chart.send_event("hurt")
				#
				if shotgun.health_ui.citations_left == 0:
					overlay_label.text = "Final Warning!"
				anim_player_text.play("citation")
			else:
				state_chart.send_event("death")
		else:
			state_chart.send_event("hurt")

# Gun handling

var is_1_handed: bool = false:
	set(value):
		var previous_value = is_1_handed
		is_1_handed = value
		
		if previous_value != is_1_handed:
			match is_1_handed:
				true:
					shotgun.state_machine.travel("idle_1_hand")
				false:
					shotgun.state_machine.travel("idle")


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_mouse_rotation = self.rotation
	is_player_control_disabled = true
	await get_tree().create_timer(0.8).timeout
	is_player_control_disabled = false


func _input(event: InputEvent):
	if event.is_action_pressed("exit"):
		get_tree().quit()
	elif event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _unhandled_input(event: InputEvent):
	if is_player_control_disabled:
		return
	
	_mouse_input = event is InputEventMouseMotion and \
	Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
	
	is_1_handed = shotgun.boxes_held > 0
	
	if event.is_action_pressed("primary_fire"):
		if shotgun.state_machine.get_current_node() in [
			"show_ammo", "switch_ammo_retrieve", 
		]:
			if shotgun._current_ammo < shotgun.max_ammo:
				shotgun.reload()
				await get_tree().create_timer(0.65).timeout
				shotgun.shoot(is_1_handed)
				return
			else:
				shotgun.state_machine.travel("cancel_ammo_change")
				return
		shotgun.shoot(is_1_handed)
	elif event.is_action_pressed("secondary_fire"):
		if is_1_handed:
			shotgun.state_machine.travel("push_1_hand")
			shotgun.launch_box()
		else:
			shotgun.state_machine.travel("push")
		shove()
	elif event.is_action_pressed("reload"):
		if is_1_handed:
			return
		if shotgun.state_machine.get_current_node() in [
			"show_ammo", "switch_ammo_retrieve", 
		]:
			if shotgun.current_ammo_pools[shotgun.palmed_shell] < shotgun.max_ammo:
				shotgun.reload()
				return
			else:
				shotgun.state_machine.travel("cancel_ammo_change")
		else:
			shotgun.reload()
	elif event.is_action_released("switch_ammo_left"):
		if shotgun.state_machine.get_current_node() in [
			"show_ammo", "switch_ammo_retrieve", 
		]:
			if is_1_handed:
				pass
			else:
				shotgun.state_machine.travel("switch_ammo_pocket")
				shotgun.cycle_shell(true)
				await get_tree().create_timer(0.3).timeout
				shotgun.state_machine.travel("switch_ammo_retrieve")
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
				shotgun.cycle_shell()
				await get_tree().create_timer(0.3).timeout
				shotgun.state_machine.travel("switch_ammo_retrieve")
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

	if not is_player_control_disabled:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		# Number of boxes carried affects move speed
		if shotgun.boxes_held > 0:
			match shotgun.boxes_held:
				0:
					SPEED = 17.0
				1:
					SPEED = 12.0
				2:
					SPEED = 8.0
				3:
					SPEED = 4.0

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
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func shove():
	for body in melee_area.get_overlapping_bodies():
		if body is RigidBody3D:
			var direction = self.global_transform.basis.rotated(Vector3.LEFT, PI/4)
			body.apply_impulse(-direction.z * 100, Vector3.ZERO)


func hurt(damage:float=0.0):
	health -= damage



func _on_hurt_state_entered():
	anim_player.play("hurt")
	await get_tree().create_timer(1.0).timeout
	state_chart.send_event("hurt_finish")


func _on_dead_state_entered():
	is_dead = true
	anim_player.play("dead")
	# Disable controls
	is_player_control_disabled = true
	# Show game over UI
	TransitionManager.emit_signal("game_over")


func _on_projectile_detection_aera_body_entered(body):
	if body is RigidBody3D:
		if body.one_off_damage > 0:
			health -= body.one_off_damage
