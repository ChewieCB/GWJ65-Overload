extends RigidBody3D
class_name Box

@onready var anim_player := $AnimationPlayer
@onready var particles := $ParticlesPivot/CPUParticles3D
@onready var mesh = $CardboardBox
@onready var pickup_highlight = $PickupArea/PickupHighlight
@onready var pickup_timer = $PickupTimer

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

func _ready():
	var material = $ParticlesPivot/CPUParticles3D.mesh.get_material()
	material.albedo_color = Color(1, 1, 1, 1)


func _unhandled_input(event):
	if event.is_action_pressed("pickup"):
		if can_pickup:
			if player.shotgun.add_box():
				can_pickup = false
				self.queue_free()


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
