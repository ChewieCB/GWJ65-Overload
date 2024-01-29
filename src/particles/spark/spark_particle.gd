extends CPUParticles3D
class_name SparkParticle


func fade_particle(time: float):
	var tween = get_tree().create_tween()
	tween.tween_property(
		self.mesh.get_material(), 
		"albedo_color", 
		Color(1, 1, 1, 0), 
		time
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)


func end_spark():
	self.queue_free()
