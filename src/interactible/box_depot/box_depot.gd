extends Node3D
class_name BoxDepot

signal activated

enum BOX_COLOR {
	BLANK,
	RED,
	BLUE,
	YELLOW
}

@onready var colour_label = $ColourLabel
@onready var count_label = $CountLabel
@onready var mesh_any = $Area3D/MeshAny
@onready var mesh_red = $Area3D/MeshRed
@onready var mesh_blue = $Area3D/MeshBlue
@onready var mesh_yellow = $Area3D/MeshYellow
@onready var meshes = [mesh_any, mesh_red, mesh_blue, mesh_yellow]

@onready var sfx_activated = load("res://src/interactible/door/sfx/Door_Ding.mp3")

@export var is_colour_specific: bool = false
@export var accepts_colour: BOX_COLOR = BOX_COLOR.BLANK
@export var boxes_required: int = 100:
	set(value):
		boxes_required = value
		if count_label:
			count_label.text = "(%s)" % [str(boxes_required - boxes_held)]
var boxes_held: int = 0:
	set(value):
		boxes_held = clamp(value, 0, boxes_required)
		if count_label:
			count_label.text = "(%s)" % [str(boxes_required - boxes_held)]
		if boxes_held >= boxes_required:
			if not depot_activated:
				depot_activated = true

var depot_activated: bool = false:
	set(value):
		depot_activated = value
		if depot_activated:
			emit_signal("activated")
		

func _ready():
	count_label.text = "(%s)" % [str(boxes_required - boxes_held)]
	count_label.text = "(%s)" % [str(boxes_required - boxes_held)]
	match accepts_colour:
		BOX_COLOR.BLANK:
			colour_label.text = "ANY"
			mesh_any.visible = true
			mesh_red.visible = false
			mesh_blue.visible = false
			mesh_yellow.visible = false
		BOX_COLOR.RED:
			colour_label.text = "RED"
			mesh_any.visible = false
			mesh_red.visible = true
			mesh_blue.visible = false
			mesh_yellow.visible = false
		BOX_COLOR.BLUE:
			colour_label.text = "BLUE"
			mesh_any.visible = false
			mesh_red.visible = false
			mesh_blue.visible = true
			mesh_yellow.visible = false
		BOX_COLOR.YELLOW:
			colour_label.text = "YELLOW"
			mesh_any.visible = false
			mesh_red.visible = false
			mesh_blue.visible = false
			mesh_yellow.visible = true
	count_label.text = "(%s)" % [str(boxes_required - boxes_held)]


func _on_area_3d_body_entered(body):
	if body is Box:
		if is_colour_specific:
			if body.current_box_colour == accepts_colour:
				await get_tree().create_timer(0.2).timeout
				body.health = 0
				boxes_held += 1
				# TODO - Add score
				#
				# TODO - Update UI
				#
				# TODO - play SFX
				SoundManager.play_sound(sfx_activated)
			else:
				var bounce = body.get_linear_velocity()
				bounce = bounce.reflect(Vector3.UP)
				body.set_linear_velocity(Vector3.ZERO)
				#body.set_inertia(Vector3.ZERO)
				body.apply_impulse(bounce * 1.7, Vector3.ZERO)
		else:
			await get_tree().create_timer(0.2).timeout
			if is_instance_valid(body):
				body.health = 0
			boxes_held += 1
			SoundManager.play_sound(sfx_activated)
