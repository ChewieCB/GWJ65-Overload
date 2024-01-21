extends VBoxContainer

@export var level: String
@onready var best_time_label = $MarginContainer2/HBoxContainer/Label
@onready var button = $"../LevelIcon2/MarginContainer/Button"

@export var is_locked: bool = true:
	set(value):
		is_locked = value
		if is_locked:
			self.modulate = Color(0.4, 0.4, 0.4, 1)
			button.disabled = true
		else:
			self.modulate = Color(1, 1, 1, 1)
			button.disabled = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_select_button_down():
	if level:
		TransitionManager.current_level_path = level
		TransitionManager.emit_signal("level_select", level)
