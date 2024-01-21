extends VBoxContainer

@export var level: String
@onready var best_time_label = $MarginContainer2/HBoxContainer/Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_select_button_down():
	if level:
		TransitionManager.emit_signal("level_select", level)
