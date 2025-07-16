extends Control

var world = "res://Assets/Scenes/world.tscn"

@onready var completed_levels: Label = $"Completed Levels"


func _ready() -> void:
	completed_levels.text = "Completed: " + str(Global.completed_levels.size()) + "/9"

func _on_level_1_pressed() -> void:
	Global.level = 1
	get_tree().change_scene_to_file(world)

func _on_level_2_pressed() -> void:
	Global.level = 2
	get_tree().change_scene_to_file(world)

func _on_level_3_pressed() -> void:
	Global.level = 3
	get_tree().change_scene_to_file(world)

func _on_level_4_pressed() -> void:
	Global.level = 4
	get_tree().change_scene_to_file(world)

func _on_level_5_pressed() -> void:
	Global.level = 5
	get_tree().change_scene_to_file(world)

func _on_level_6_pressed() -> void:
	Global.level = 6
	get_tree().change_scene_to_file(world)

func _on_level_7_pressed() -> void:
	Global.level = 7
	get_tree().change_scene_to_file(world)

func _on_level_8_pressed() -> void:
	Global.level = 8
	get_tree().change_scene_to_file(world)

func _on_level_9_pressed() -> void:
	Global.level = 9
	get_tree().change_scene_to_file(world)


func _on_button_pressed() -> void:
	get_tree().quit()
