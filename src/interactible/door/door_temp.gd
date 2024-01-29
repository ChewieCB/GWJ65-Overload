extends StaticBody3D

enum DOOR_STATES {
	CLOSED,
	OPEN
}

@export var linked_depots: Array[BoxDepot] = []
@export var linked_enemies: Array[CharacterBody3D] = []
@export var state: DOOR_STATES = DOOR_STATES.CLOSED:
	set(value):
		if anim_player:
			match value:
				DOOR_STATES.CLOSED:
					anim_player.play("close")
				DOOR_STATES.OPEN:
					anim_player.play("open")
		state = value

@onready var anim_player = $AnimationPlayer
@onready var sfx_open = load("res://src/interactible/door/sfx/Door_open.mp3")
@onready var sfx_close = load("res://src/interactible/door/sfx/Door_close.mp3")


# Called when the node enters the scene tree for the first time.
func _ready():
	state = state
	for _depot in linked_depots:
		_depot.activated.connect(_activate)
	for _enemy in linked_enemies:
		_enemy.dead.connect(_activate)


func _activate() -> void:
	if check_activated():
		match state:
			DOOR_STATES.CLOSED:
				state = DOOR_STATES.OPEN
				SoundManager.play_sound(sfx_open)
			DOOR_STATES.OPEN:
				state = DOOR_STATES.CLOSED
				SoundManager.play_sound(sfx_close)


func check_activated() -> bool:
	for depot in linked_depots:
		if not depot.depot_activated:
			return false
	for enemy in linked_enemies:
		if not enemy.health == 0:
			return false
	return true

