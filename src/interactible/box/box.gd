extends RigidBody3D

@onready var anim_player := $AnimationPlayer
@onready var particles := $CPUParticles3D

var player: Player


var health: float = 15.0:
	set(value):
		health = clamp(value, 0, 15.0)
		if health == 0.0:
			anim_player.play("smoke")
			await get_tree().create_timer(0.3).timeout
			self.queue_free()

func _ready():
	var material = $ParticlesPivot/CPUParticles3D.mesh.get_material()
	material.albedo_color = Color(1, 1, 1, 1)

func _physics_process(delta):
	if player:
		if is_instance_valid(particles):
			# FIXME
			# Rotate emitter to always point upwards
			#$ParticlesPivot.look_at(self.global_transform.origin + Vector3.UP)
			pass


func hit(damage:float=0.0):
	health -= damage


func fade_particle(time: float):
	var tween = get_tree().create_tween()
	tween.tween_property(
		$ParticlesPivot/CPUParticles3D.mesh.get_material(), 
		"albedo_color", 
		Color(1, 1, 1, 0), 
		time
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
