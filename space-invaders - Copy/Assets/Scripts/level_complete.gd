extends Control

@onready var ship: CharacterBody2D = $"../Ship"
@onready var panel: Panel = $Panel
@onready var main_menu: MarginContainer = $Panel/MarginContainer
@onready var anim: Timer = $Anim
@onready var go_timer: Timer = $"../Menu Animation"
@onready var label: Label = $Panel/MarginContainer/VBoxContainer/Label


var button_pressed : String

func _ready() -> void:
	ship.connect("complete", appear)
	panel.size.y = 0

func appear():
	if !Global.completed_levels.has(Global.level) and Global.level < 10:
		Global.completed_levels.append(Global.level)
	label.text = "Time: " + str(Global.time) + "s"
	main_menu.visible = false
	anim.start()
	var tween = create_tween()
	tween.tween_property(self, "global_position:y", 0, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "panel:size:y", 409.0, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func disappear():
	go_timer.start()
	main_menu.visible = false
	var tween = create_tween()
	tween.tween_property(self, "panel:size:y", 0, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "global_position:y", 1000, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)

func _on_anim_timeout() -> void:
	main_menu.visible = true

func _on_next_pressed() -> void:
	disappear()
	button_pressed = "next"

func _on_main_menu_pressed() -> void:
	disappear()
	button_pressed = "main_menu"

func _on_menu_animation_timeout() -> void:
	if button_pressed == "next":
		Global.level += 1
		get_tree().change_scene_to_file("res://Assets/Scenes/world.tscn")
	if button_pressed == "main_menu":
		Global.level += 1
		get_tree().change_scene_to_file("res://Assets/Scenes/main_menu.tscn")
