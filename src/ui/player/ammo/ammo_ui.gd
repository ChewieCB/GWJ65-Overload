extends Control


@onready var max_ammo_count_1 = $MarginContainer/VBoxContainer/TotalAmmoCounts/AmmoType1/MarginContainer2/AmmoCount1
@onready var max_ammo_count_2 = $MarginContainer/VBoxContainer/TotalAmmoCounts/AmmoType2/MarginContainer2/AmmoCount2
@onready var max_ammo_count_3 = $MarginContainer/VBoxContainer/TotalAmmoCounts/AmmoType3/MarginContainer2/AmmoCount3
# 
@onready var loaded_shell_1 = $MarginContainer/VBoxContainer/LoadedAmmoCount/HBoxContainer/Shell1/TextureRect
@onready var loaded_shell_2 = $MarginContainer/VBoxContainer/LoadedAmmoCount/HBoxContainer/Shell2/TextureRect
@onready var loaded_shell_3 = $MarginContainer/VBoxContainer/LoadedAmmoCount/HBoxContainer/Shell3/TextureRect
@onready var loaded_shell_4 = $MarginContainer/VBoxContainer/LoadedAmmoCount/HBoxContainer/Shell4/TextureRect
@onready var loaded_shell_5 = $MarginContainer/VBoxContainer/LoadedAmmoCount/HBoxContainer/Shell5/TextureRect
@onready var shell_icons = [loaded_shell_1, loaded_shell_2, loaded_shell_3, loaded_shell_4, loaded_shell_5]
@onready var shell_icons_reversed = shell_icons.duplicate()
@onready var red_shell_tex = load("res://src/ui/player/ammo/icon_ammo_red_32.png")
@onready var blue_shell_tex = load("res://src/ui/player/ammo/icon_ammo_blue_32.png")
@onready var yellow_shell_tex = load("res://src/ui/player/ammo/icon_ammo_yellow_32.png")
@onready var empty_shell_tex = load("res://src/ui/player/ammo/icon_shell_empty_32.png")


func _ready():
	shell_icons_reversed.reverse()


func spend_shell():
	# Get the most recent non-spent shell and change it to spent
	# In reverse order so we load right to left
	for _shell in shell_icons_reversed:
		if _shell.texture != empty_shell_tex:
			_shell.texture = empty_shell_tex
			break

func load_shell(shell_type: int = 0):
	var shell_texture
	match shell_type:
		0:
			shell_texture = red_shell_tex
		1:
			shell_texture = blue_shell_tex
		2:
			shell_texture = yellow_shell_tex
	
	for _shell in shell_icons:
		if _shell.texture == empty_shell_tex:
			_shell.texture = shell_texture
			break

func change_max_ammo(shell_type: int, new_count: int):
	var label_to_change
	match shell_type:
		0:
			label_to_change = max_ammo_count_1
		1:
			label_to_change = max_ammo_count_2
		2:
			label_to_change = max_ammo_count_3
	
	label_to_change.text = str(max(new_count, 0))
