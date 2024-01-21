extends Node3D

signal activated

enum BOX_COLOR {
	BLANK,
	RED,
	BLUE,
	YELLOW
}

@onready var colour_label = $ColourLabel
@onready var count_label = $CountLabel
@onready var mesh = $Area3D/MeshInstance3D

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
		if boxes_held == boxes_required:
			depot_activated = true

var depot_activated: bool = false:
	set(value):
		depot_activated = value
		if depot_activated:
			emit_signal("activated")
		

func _ready():
	count_label.text = "(%s)" % [str(boxes_required - boxes_held)]
	count_label.text = "(%s)" % [str(boxes_required - boxes_held)]
	var mat = mesh.get_active_material(0)
	match accepts_colour:
		BOX_COLOR.BLANK:
			colour_label.text = "ANY"
			mat.albedo_color = Color("#23d513")
		BOX_COLOR.RED:
			colour_label.text = "RED"
			mat.albedo_color = Color("#ff2153")
		BOX_COLOR.BLUE:
			colour_label.text = "BLUE"
			mat.albedo_color = Color("#3a67cc")
		BOX_COLOR.YELLOW:
			colour_label.text = "YELLOW"
			mat.albedo_color = Color("#65d1f8")
	mat.albedo_color.a = 0.5
	mesh.set_surface_override_material(0, mat)
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
			else:
				var bounce = body.get_linear_velocity()
				bounce = bounce.reflect(Vector3.UP)
				body.set_linear_velocity(Vector3.ZERO)
				#body.set_inertia(Vector3.ZERO)
				body.apply_impulse(bounce * 1.7, Vector3.ZERO)
		else:
			await get_tree().create_timer(0.2).timeout
			body.health = 0
			boxes_held += 1
