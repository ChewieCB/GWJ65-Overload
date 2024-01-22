extends Control

@onready var health_tick_1 = $MarginContainer/LoadedAmmoCount/VBoxContainer/MarginContainer/HBoxContainer/HealthTick1/TextureRect
@onready var health_tick_2 = $MarginContainer/LoadedAmmoCount/VBoxContainer/MarginContainer/HBoxContainer/HealthTick2/TextureRect
@onready var health_tick_3 = $MarginContainer/LoadedAmmoCount/VBoxContainer/MarginContainer/HBoxContainer/HealthTick3/TextureRect
@onready var health_tick_4 = $MarginContainer/LoadedAmmoCount/VBoxContainer/MarginContainer/HBoxContainer/HealthTick4/TextureRect
@onready var health_ticks = [health_tick_4, health_tick_3, health_tick_2, health_tick_1]

@onready var health_bar = $MarginContainer/LoadedAmmoCount/VBoxContainer/MarginContainer2/ProgressBar
# TODO - find a more appropriate icon
@onready var red_shell_tex = load("res://src/ui/player/ammo/icon_ammo_red_32.png")
@onready var empty_shell_tex = load("res://src/ui/player/ammo/icon_shell_empty_32.png")

var citations_left: int = 4

func _ready():
	var reversed_ticks = health_ticks
	reversed_ticks.reverse()
	for idx in range(citations_left):
		reversed_ticks[idx].texture = red_shell_tex


func lose_health_tick() -> bool:
	# In reverse order so we go right to left
	for _tick in health_ticks:
		if _tick.texture != empty_shell_tex:
			_tick.texture = empty_shell_tex
			citations_left -= 1
			return true
	return false


func gain_health_tick():
	for _tick in health_ticks:
		if _tick.texture == empty_shell_tex:
			_tick.texture = red_shell_tex
			citations_left += 1
			break


func update_health_bar(value: int):
	health_bar.value = value

