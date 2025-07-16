extends Control

@onready var ship: CharacterBody2D = $"../Ship"
@onready var panel: Panel = $Panel
@onready var panel2: Panel = $Panel/MarginContainer/Panel2
@onready var anim: Timer = $Anim
@onready var go_timer: Timer = $"../Menu Animation"


var button_pressed : String

func _ready() -> void:
	ship.connect("game_over", appear)
	size.y = 0
	

func appear():
	panel2.visible = false
	anim.start()
	var tween = create_tween()
	tween.tween_property(self, "global_position:y", 154.5, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "size:y", 771, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_anim_timeout() -> void:
	panel2.visible = true

func disappear():
	go_timer.start()
	panel2.visible = false
	var tween = create_tween()
	tween.tween_property(self, "size:y", 0, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "global_position:y", 1200, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)

func _on_retry_pressed() -> void:
	disappear()
	button_pressed = "retry"

func _on_main_menu_button_down() -> void:
	disappear()
	button_pressed = "menu"

func _on_game_over_animation_timeout() -> void:
	if button_pressed == "menu":
		get_tree().change_scene_to_file("res://Assets/Scenes/main_menu.tscn")
	if button_pressed == "retry":
		get_tree().change_scene_to_file("res://Assets/Scenes/world.tscn")
