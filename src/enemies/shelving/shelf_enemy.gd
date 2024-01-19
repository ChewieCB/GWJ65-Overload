extends CharacterBody3D

@onready var state_chart = $StateChart
@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var anim_state_machine = anim_tree["parameters/playback"]

@export var shot_damage: float = 20.0
@export var health: float = 100.0:
	set(value):
		health = clamp(value, 0, 100.0)
		if health == 0:
			state_chart.send_event("death")

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





func shoot_box():
	pass


func hit(damage:float=0.0):
	health -= damage
	state_chart.send_event("hit")
