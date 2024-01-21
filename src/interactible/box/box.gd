extends RigidBody3D
class_name Box

@onready var anim_player := $AnimationPlayer
@onready var particles := $ParticlesPivot/CPUParticles3D
@onready var mesh = $CardboardBox
@onready var collider = $CollisionShape3D
@onready var pickup_highlight = $PickupArea/PickupHighlight
@onready var pickup_timer = $PickupTimer

@onready var box_change_sfx = load("res://src/interactible/box/sfx/Box_type_change.mp3")
@onready var box_impact_1 = load("res://src/interactible/box/sfx/Cardboard_impct_1.mp3")
@onready var box_impact_2 = load("res://src/interactible/box/sfx/Cardboard_impct_2.mp3")
@onready var box_impact_3 = load("res://src/interactible/box/sfx/Cardboard_impct_3.mp3")
@onready var box_impact_4 = load("res://src/interactible/box/sfx/Cardboard_impct_4.mp3")
@onready var box_impact_5 = load("res://src/interactible/box/sfx/Cardboard_impct_5.mp3")
@onready var box_impact_6 = load("res://src/interactible/box/sfx/Cardboard_impct_6.mp3")
@onready var box_impacts = [
	box_impact_1, box_impact_2, box_impact_3, box_impact_4, box_impact_5, box_impact_6
]
@onready var collision_sfx_timer = $CollisionSFXTimer
var is_collision_sfx: bool = false

func box_impact_sfx() -> AudioStream:
	return box_impacts[randi_range(0, 5)]

enum BOX_COLOR {
	BLANK,
	RED,
	BLUE,
	YELLOW
}
@onready var colour_mats = [
	null,
	preload("res://src/interactible/box/red_box_mat.tres"),
	preload("res://src/interactible/box/blue_box_mat.tres"),
	preload("res://src/interactible/box/yellow_box_mat.tres")
]

var player: Player

var can_pickup: bool = false:
	set(value):
		can_pickup = value
		pickup_highlight.visible = can_pickup

var health: float = 15.0:
	set(value):
		health = clamp(value, 0, 15.0)
		if health == 0.0:
			anim_player.play("smoke")
			await get_tree().create_timer(0.3).timeout
			self.queue_free()

# For shelves throwing boxes at the player, we want that first impact only to hurt 
var one_off_damage: float = 0.0

@export var current_box_colour: BOX_COLOR = BOX_COLOR.BLANK:
	set(value):
		# Update mesh colour
		if value != current_box_colour:
			if value == 0:
				mesh.set_surface_override_material(0, null)
			else:
				var new_mat = colour_mats[value]
				mesh.set_surface_override_material(0, new_mat)
			SoundManager.play_sound(box_change_sfx)
		current_box_colour = value

func _ready():
	var material = $ParticlesPivot/CPUParticles3D.mesh.get_material()
	material.albedo_color = Color(1, 1, 1, 1)


func _unhandled_input(event):
	if event.is_action_pressed("pickup"):
		if can_pickup:
			if player.shotgun.add_box(current_box_colour):
				can_pickup = false
				self.queue_free()


func _physics_process(delta):
	pass
	#if player:
		#if is_instance_valid(particles):
			## FIXME
			## Rotate emitter to always point upwards
			##$ParticlesPivot.look_at(self.global_transform.origin + Vector3.UP)
			#pass


func hit(damage:float=0.0, ammo_type:int=-1):
	if ammo_type >= 0:
		var new_colour = clamp(ammo_type + 1, 0, colour_mats.size())
		if not new_colour == current_box_colour:
			current_box_colour = new_colour
			# Hacky timer here to stop pellets from the same shot destroying a box
			#await get_tree().create_timer(0.7).timeout
			#return
	#health -= damage


func fade_particle(time: float):
	var tween = get_tree().create_tween()
	tween.tween_property(
		$ParticlesPivot/CPUParticles3D.mesh.get_material(), 
		"albedo_color", 
		Color(1, 1, 1, 0), 
		time
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	


func _on_pickup_area_body_entered(body):
	if not pickup_timer.is_stopped():
		return
	
	if body is Player:
		if not player:
			player = body
		if player.shotgun.boxes_held <= player.shotgun.max_boxes:
			can_pickup = true


func _on_pickup_area_body_exited(body):
	if body is Player:
		can_pickup = false

func _on_body_entered(body):
	if is_collision_sfx and collision_sfx_timer.is_stopped():
		SoundManager.play_sound(box_impact_sfx())
		collision_sfx_timer.start(0.3)
