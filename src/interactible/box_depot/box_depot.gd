extends Node3D

enum BOX_COLOR {
	BLANK,
	RED,
	BLUE,
	YELLOW
}

@export var is_colour_specific: bool = false
@export var accepts_colour: BOX_COLOR = BOX_COLOR.BLANK

@onready var label = $Label3D
@onready var mesh = $Area3D/MeshInstance3D

func _ready():
	var mat = mesh.get_active_material(0)
	match accepts_colour:
		BOX_COLOR.BLANK:
			label.text = "ANY"
			mat.albedo_color = Color("#23d513")
		BOX_COLOR.RED:
			label.text = "RED"
			mat.albedo_color = Color("#ff2153")
		BOX_COLOR.BLUE:
			label.text = "BLUE"
			mat.albedo_color = Color("#3a67cc")
		BOX_COLOR.YELLOW:
			label.text = "YELLOW"
			mat.albedo_color = Color("#65d1f8")
	mat.albedo_color.a = 0.5
	mesh.set_surface_override_material(0, mat)


func _on_area_3d_body_entered(body):
	if body is Box:
		if is_colour_specific:
			if body.current_box_colour == accepts_colour:
				await get_tree().create_timer(0.2).timeout
				body.health = 0
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
