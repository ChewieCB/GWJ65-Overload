extends CharacterBody3D

@onready var state_chart = $StateChart
@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var anim_state_machine = anim_tree["parameters/playback"]
@onready var u_turn_ray = $UTurnRayCast

@export var max_charge_time: float = 2.0

var target: CharacterBody3D

var starting_rotation
var goal_rotation

const SPEED = 25.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	anim_state_machine.start("idle")


func _physics_process(delta):
	velocity.y -= gravity
	move_and_slide()


func start_charge():
	state_chart.send_event("start_chase")


func _on_detection_area_body_entered(body):
	if body is Player:
		target = body
		state_chart.send_event("player_seen")


func _on_detection_area_body_exited(body):
	pass
	#if body == target:
		#target = null
	#state_chart.send_event("player_lost")

func _on_crash_area_body_entered(body):
	state_chart.send_event("crash")


func _on_idle_state_entered():
	anim_state_machine.travel("idle")
	velocity = Vector3.ZERO
	for body in $DetectionArea.get_overlapping_bodies():
		if body is Player:
			state_chart.send_event("reverse")

func _on_idle_state_physics_processing(delta):
	# Check if we need to U-Turn
	if u_turn_ray.is_colliding():
		state_chart.send_event("u_turn")


func _on_chase_buildup_state_entered():
	anim_state_machine.travel("charge_release")
	if target:
		var target_position = target.global_transform.origin
		self.look_at(target_position, Vector3.UP)

func _on_chase_buildup_state_physics_processing(delta):
	if target:
		var _target_position = target.transform.origin
		self.look_at(_target_position, Vector3.UP)


func _on_chasing_state_entered():
	anim_state_machine.travel("charging")
	# If we don't hit anything within the max_charge_time window, go back to Idle
	await get_tree().create_timer(max_charge_time).timeout
	state_chart.send_event("charge_ended")
	

func _on_chasing_state_physics_processing(delta):
	velocity = -global_transform.basis.z * SPEED
	move_and_slide()


func _on_crashing_state_entered():
	anim_state_machine.travel("crash")
	await get_tree().create_timer(0.2).timeout
	state_chart.send_event("crash_finished")

func _on_crashing_state_physics_processing(delta):
	velocity = global_transform.basis.z * 5.0
	move_and_slide()

func _on_crashing_state_exited():
	# Check if we need to U-Turn
	# Check if player still in detection area
	for body in $DetectionArea.get_overlapping_bodies():
		if body is Player:
			state_chart.send_event("reverse")
	state_chart.send_event("u_turn")
	
	#if u_turn_ray.is_colliding():
		#state_chart.send_event("u_turn")
	#else:
		#state_chart.send_event("reverse")


func _on_u_turning_state_entered():
	anim_state_machine.travel("u_turn")
	await get_tree().create_timer(0.6).timeout
	state_chart.send_event("u_turn_complete")

func _on_u_turning_state_physics_processing(delta):
	self.rotation.y += delta * 5
	velocity = global_transform.basis.z * 7.0
	move_and_slide()


func _on_reverse_state_entered():
	starting_rotation = self.rotation
	anim_state_machine.travel("driving")
	await get_tree().create_timer(0.6).timeout
	state_chart.send_event("end_reverse")


func _on_reverse_state_physics_processing(delta):
	velocity = global_transform.basis.z * 7.0
	move_and_slide()


func _on_reverse_state_exited():
	for body in $DetectionArea.get_overlapping_bodies():
		if body is Player:
			state_chart.send_event("player_seen")