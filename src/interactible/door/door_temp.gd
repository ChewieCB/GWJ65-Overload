extends StaticBody3D

enum DOOR_STATES {
	CLOSED,
	OPEN
}

@export var linked_depots: Array[Node3D] = []
@export var state: DOOR_STATES = DOOR_STATES.CLOSED:
	set(value):
		if value != state:
			if anim_player:
				match value:
					DOOR_STATES.CLOSED:
						anim_player.play("close")
					DOOR_STATES.OPEN:
						anim_player.play("open")
		state = value

@onready var anim_player = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	state = state
	for _depot in linked_depots:
		_depot.activated.connect(_activate)


func _activate() -> void:
	if check_activated():
		match state:
			DOOR_STATES.CLOSED:
				state = DOOR_STATES.OPEN
			DOOR_STATES.OPEN:
				state = DOOR_STATES.CLOSED


func check_activated() -> bool:
	for depot in linked_depots:
		if not depot.depot_activated:
			return false
	return true

