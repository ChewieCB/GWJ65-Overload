extends Node3D


func _on_area_3d_body_entered(body):
	if body is Box:
		await get_tree().create_timer(0.2).timeout
		body.health = 0
		# TODO - Add score
		#
		# TODO - Update UI
		#
		# TODO - play SFX
