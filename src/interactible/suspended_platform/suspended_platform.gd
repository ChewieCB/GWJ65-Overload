extends CharacterBody3D

enum STATES {
	RETRACTED,
	EXTENDED
}
@export var extended_y_pos: float
@export var retracted_y_pos: float

@export var linked_depots: Array[Node3D] = []
@export var linked_enemies: Array[CharacterBody3D] = []
@export var state: STATES = STATES.RETRACTED:
	set(value):
		match value:
			STATES.RETRACTED:
				retract()
			STATES.EXTENDED:
				open()
		state = value

@onready var sfx_open = load("res://src/interactible/door/sfx/Door_open.mp3")
@onready var sfx_close = load("res://src/interactible/door/sfx/Door_close.mp3")


# Called when the node enters the scene tree for the first time.
func _ready():
	for _depot in linked_depots:
		_depot.activated.connect(_activate)
	for _enemy in linked_enemies:
		_enemy.dead.connect(_activate)
	match state:
		STATES.RETRACTED:
			global_transform.origin.y = retracted_y_pos
		STATES.EXTENDED:
			global_transform.origin.y = extended_y_pos


func retract():
	transform.origin.y = retracted_y_pos
	#if not get_tree():
		#return
	#var tween = get_tree().create_tween()
	#tween.tween_property(self, "self.global_transform.origin.y", retracted_y_pos, 1.0)


func open():
	transform.origin.y = extended_y_pos
	#if not get_tree():
		#return
	#var tween = get_tree().create_tween()
	#tween.tween_property(self, "self.global_transform.origin.y", extended_y_pos, 1.0)


func _activate() -> void:
	if check_activated():
		match state:
			STATES.RETRACTED:
				state = STATES.EXTENDED
				SoundManager.play_sound(sfx_open)
			STATES.EXTENDED:
				state = STATES.RETRACTED
				SoundManager.play_sound(sfx_close)


func check_activated() -> bool:
	for depot in linked_depots:
		if not depot.depot_activated:
			return false
	for enemy in linked_enemies:
		if not enemy.health == 0:
			return false
	return true

