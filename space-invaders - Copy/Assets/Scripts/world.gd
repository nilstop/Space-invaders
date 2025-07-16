extends Node2D

var laser = preload("res://Assets/Scenes/laser.tscn")
var shoot_particles = preload("res://Assets/Scenes/shoot_particles.tscn")
var G = Global
@onready var ship: CharacterBody2D = $Ship
@onready var game_over_screen: Control = $"Game Over Screen"
@onready var timer: Timer = $Timer
@onready var level_complete: Control = $"Level Complete"

var viewport = get_viewport_rect()

#enemy spawning
var enemy = preload("res://Assets/Scenes/enemy.tscn")

#level setter, Copypaste:

#G.columns = 
#G.rows = 
#G.shooters = []
#G.tanks = []
func set_level_values():
	
	if G.level == 1:
		G.columns = 3
		G.rows = 3
		G.shooters = []
		G.tanks = []
		G.empties = ["0,1", "1,2", "2,1"]
	
	if G.level == 2:
		G.columns = 5
		G.rows = 3
		G.shooters = []
		G.tanks = []
		G.empties = ["0,0", "2,0", "4,0", "1,1", "3,1", "0,2", "2,2", "4,2"]
	
	if G.level == 3:
		G.columns = 4
		G.rows = 4
		G.shooters = []
		G.tanks = ["1,1", "2,1"]
		G.empties = ["1,3", "2,3", "0,2", "3,2"]
	
	if G.level == 4:
		G.columns = 5
		G.rows = 3
		G.shooters = []
		G.tanks = ["0,1", "1,0", "3,0", "4,1"]
		G.empties = ["0,2", "2,2", "4,2"]
	
	if G.level == 5:
		G.columns = 5
		G.rows = 4
		G.shooters = []
		G.tanks = ["0,3", "1,0", "2,3", "3,0", "4,3", "2,2"]
		G.empties = ["0,0", "2,0", "4,0",
					"1,1", "3,1", "1,2", "3,2", "1,3", "3,3"]
	
	if G.level == 6:
		G.columns = 5
		G.rows = 2
		G.shooters = ["2,0"]
		G.tanks = ["0,1", "2,1", "4,1"]
		G.empties = ["0,0", "4,0"]
	
	if G.level == 7:
		G.columns = 4
		G.rows = 5
		G.shooters = ["1,1", "2,1"]
		G.tanks = ["1,2", "2,2", "1,4", "2,4"]
		G.empties = ["0,0", "3,0", "0,4", "3,4", "1,3", "2,3"]
	
	if G.level == 8:
		G.columns = 3
		G.rows = 7
		G.shooters = ["1,1", "1,5"]
		G.tanks = ["1,0", "0,1", "2,1", "1,2", "1,4", "0,5", "2,5", "1,6"]
		G.empties = ["0,0", "2,0", "0,2", "2,2", "0,3", "1,3", "2,3", "0,4", "2,4", "0,6", "2,6"]
	
	if G.level == 9:
		G.columns = 5
		G.rows = 6
		G.shooters = ["1,2", "1,3", "1,4", "3,2", "3,3", "3,4",  "0,0", "0,1", "4,0", "4,1", "2,0"]
		G.tanks = ["2,1", "1,5", "3,5", "1,0", "1,1", "3,0", "3,1"]
		G.empties = ["0,2", "0,3", "0,4", "0,5", "4,2", "4,3", "4,4", "4,5", "2,2", "2,3", "2,4", "2,5"]
	
	if G.level > 9:
		G.columns = 6
		G.rows = 7
		G.shooters = []
		G.tanks = []
		G.empties = []
		ship.shoot_timer.wait_time = 0.0001
	
	if Global.completed_levels.size() == 9:
		ship.shoot_timer.wait_time = 0.0001
	
	G.movement = get_viewport().get_visible_rect().size.x - G.offset / 2 - G.columns * G.grid_width
	G.enemies_left = G.columns * G.rows - G.empties.size()

func game_over():
	game_over_screen.z_index = 1000
	game_over_screen.global_position = Vector2(172.5, 1000)
	game_over_screen.visible = true

func complete():
	level_complete.z_index = 1000
	level_complete.global_position = Vector2(0, -1000)
	level_complete.visible = true

func _ready() -> void:
	ship.connect("complete", complete)
	ship.connect("inst_laser", shoot)
	ship.connect("game_over", game_over)
	G.time = 0
	#enemy spawning
	set_level_values()
	for column in Global.columns:
		for row in Global.rows:
			inst_enemy(column, row)
	
#instantiate enemies netgid
func inst_enemy(column, row):
	if !Global.empties.has(str(column) + "," + str(row)):
		var instance = enemy.instantiate()
		if Global.shooters.has(str(column) + "," + str(row)):
			instance.enemy_type = "Shooter"
		elif Global.tanks.has(str(column) + "," + str(row)):
			instance.enemy_type = "Tank"
		else:
			instance.enemy_type = "Default"
		instance.base_position = Vector2(column * Global.grid_width, row * Global.grid_height) + Vector2(Global.offset, Global.offset)
		add_child(instance)
	

#instantiate lasers and particles
func inst(object, pos, from_ship: bool):
	var instance = object.instantiate()
	instance.position = pos
	if from_ship:
		instance.position.x += ship.velocity.x / 13
		if Input.is_action_pressed("left"):
			instance.rotation = ship.rotation
		if Input.is_action_pressed("right"):
			instance.rotation = ship.rotation

	add_child(instance)
	if object == shoot_particles:
		instance.get_child(0).emitting = true

func shoot():
	$ShootSfx.play()
	inst(laser, ship.global_position - Vector2(0, 80), true)
	inst(shoot_particles, ship.global_position - Vector2(0, 25), true)


func _on_timer_timeout() -> void:
	timer.start()
	G.time += 1
