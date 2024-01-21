extends Node3D

@onready var ammo_meshes = [
	$Meshes/AmmoMesh1,
	$Meshes/AmmoMesh2,
	$Meshes/AmmoMesh3
]
@onready var ammo_red_tex = load("res://assets/shotgun/Ammo_Textures/Ammo.png")
@onready var ammo_yellow_tex = load("res://assets/shotgun/Ammo_Textures/ammo_yellow.png")
@onready var ammo_blue_tex = load("res://assets/shotgun/Ammo_Textures/ammo_blue.png")
@onready var ammo_textures = [ammo_red_tex, ammo_blue_tex, ammo_yellow_tex]

@onready var counter_label = $Meshes/CounterLabel
@export var ammo_amount: int = 1

@onready var sfx_ammo_1 = load("res://src/interactible/ammo_pickup/sfx/Pocket_Bullets.mp3")
@onready var sfx_ammo_2 = load("res://src/interactible/ammo_pickup/sfx/Pocket_Bullets_2.mp3")
@onready var sfx_ammo_3 = load("res://src/interactible/ammo_pickup/sfx/Pocket_Bullets_3.mp3")
@onready var sfx_ammo_4 = load("res://src/interactible/ammo_pickup/sfx/Pocket_Bullets_4.mp3")
@onready var sfx_ammo = [sfx_ammo_1, sfx_ammo_2, sfx_ammo_3, sfx_ammo_4]

func get_sfx_ammo() -> AudioStream:
	return sfx_ammo[randi_range(0, 3)]

@onready var anim_player = $AnimationPlayer

enum AMMO_TYPE {
	RED,
	BLUE,
	YELLOW
}

@export var ammo_type: AMMO_TYPE = AMMO_TYPE.RED:
	set(value):
		ammo_type = value
		if ammo_meshes:
			for _mesh in ammo_meshes:
				_mesh.texture.albedo_texture = ammo_textures[ammo_type]


func _ready():
	counter_label.text = str(ammo_amount)
	for _mesh in ammo_meshes:
		_mesh.get_active_material(0).albedo_texture = ammo_textures[ammo_type]


func _physics_process(delta):
	rotation.y += delta


func _on_pickup_area_body_entered(body):
	if body is Player:
		match ammo_type:
			AMMO_TYPE.RED:
				body.shotgun.reserve_ammo_1 += ammo_amount
			AMMO_TYPE.BLUE:
				body.shotgun.reserve_ammo_2 += ammo_amount
			AMMO_TYPE.YELLOW:
				body.shotgun.reserve_ammo_3 += ammo_amount
		SoundManager.play_sound(get_sfx_ammo())
		anim_player.play("pickup")
		await anim_player.animation_finished
		self.queue_free()
