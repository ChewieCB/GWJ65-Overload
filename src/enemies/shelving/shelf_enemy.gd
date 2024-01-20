extends CharacterBody3D

@onready var state_chart = $StateChart
@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var anim_state_machine = anim_tree["parameters/playback"]

@onready var aim_timer = $AimingTimer

@export var shot_damage: float = 20.0
@export var health: float = 100.0:
	set(value):
		health = clamp(value, 0, 100.0)
		if health == 0:
			state_chart.send_event("death")
@export var aiming_time: float = 2.0

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


func _physics_process(delta):
	velocity.y -= gravity
	move_and_slide()


func shoot_box():
	pass


func hit(damage:float=0.0):
	health -= damage
	state_chart.send_event("hurt")


func _on_idle_state_entered():
	anim_state_machine.travel("idle")
	velocity = Vector3.ZERO


func _on_walking_state_entered():
	anim_state_machine.travel("walk")

func _on_walking_state_physics_processing(delta):
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
	locked_shot_position = target.transform.origin
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
	locked_shot_position = null


func _on_shooting_state_entered():
	anim_state_machine.travel("shoot")
	await get_tree().create_timer(0.7).timeout
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
	
	for body in $DetectionArea.get_overlapping_bodies():
		if body is Player:
			target = body
			state_chart.send_event("player_seen")
			return
	
	state_chart.send_event("to_idle")


func _on_dead_state_entered():
	velocity = Vector3.ZERO
	anim_state_machine.travel("die")


func _on_detection_area_body_entered(body):
	if body is Player:
		print("Player detected")
		target = body
		print("Target = ", target.name)
		state_chart.send_event("player_seen")


func _on_detection_area_body_exited(body):
	if body is Player:
		target = null
		state_chart.send_event("player_lost")


func _on_shooting_area_body_entered(body):
	state_chart.send_event("in_range")


func _on_shooting_area_body_exited(body):
	state_chart.send_event("out_of_range")

