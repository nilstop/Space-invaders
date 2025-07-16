extends Area2D
class_name Enemy

signal move_down

#node paths
@onready var base_position : Vector2
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var death_particles: CPUParticles2D = $DeathParticles
@onready var move_down_timer: Timer = $"Move Down Timer"
@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_particles: CPUParticles2D = $ShootParticles
@onready var ship = get_node("/root/World/Ship")



#preloads
@export var default_text = preload("res://Assets/Sprites/Space Shooter/PNG/Enemies/enemyBlack1.png")
@export var shooter_text = preload("res://Assets/Sprites/Space Shooter/PNG/Enemies/enemyBlue2.png")
@export var tank_text = preload("res://Assets/Sprites/Space Shooter/PNG/Enemies/enemyGreen4.png")

var laser = preload("res://Assets/Scenes/enemy_laser.tscn")

#enemy types
var enemy_type : String

#common variables
var health : int
var direction := "right"
var speed := 0.7
var movement = 0

#animation variables
var brightness_val = 0
var shake_val = 0
var wave_AMP := 0.3
var wave_FREQ := 0.06
var wave := randf_range(0.0, 1000.0)
var move_down_animation := false

#death animation variables
var death_anim = false
var death_y_velocity := -25.0
var death_gravity := 1.5
var start_death_x_velocity := randi_range(-2, 2)
var death_x_velocity := 0.0
var animation := 0.0

#func ready
func _ready() -> void:
	global_position = base_position
	self.move_down.connect(_move_down)
	ship.game_over.connect(game_over)
	if enemy_type == "Default":
		health = 70
		sprite.texture = default_text
	if enemy_type == "Shooter":
		health = 60
		sprite.texture = shooter_text
		shoot_timer.start()
	if enemy_type == "Tank":
		health = 200
		sprite.texture = tank_text

#functions
func game_over():
	var tween = create_tween()
	tween.tween_property(self, "speed", 0.0, 2).set_trans(Tween.TRANS_QUAD)

func switch_side():
	movement = 0
	emit_signal("move_down")
	if direction == "right":
		direction = "left"
	else:
		direction = "right"

func move_to_side():
	if direction == "right":
		base_position.x += speed
		movement += speed
	else:
		base_position.x -= speed
		movement += speed

func destroy():
	Global.enemies_left -= 1
	collision_shape.queue_free()
	if !death_anim:
		$DeathSfx.play()
	death_anim = true
	death_particles.emitting = true
	set_modulate(Color.from_hsv(0.0, 0.0, 5, 1.0))
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1)

func death_anim_false(delta):
	#set shake animation values
	if death_anim == false:
		shake(shake_val)
		color_anim(brightness_val)
	if shake_val > 0:
		shake_val -= 0.5 * 60 * delta
	else:
		shake_val = 0 * 60 * delta
	
	if brightness_val > 0:
		brightness_val -= 0.5 * 60 * delta
	else:
		brightness_val = 0 * 60 * delta
	
	if !move_down_animation:
		wave += wave_FREQ
	sprite.scale.x = lerp(sprite.scale.x, 1.0, 0.2)
	sprite.scale.y = lerp(sprite.scale.y, 1.0, 0.2)
	global_position.y = lerp(global_position.y, base_position.y, 0.2)
	global_position.x = lerp(global_position.x, base_position.x, 0.2)
	
	if movement < Global.movement:
		move_to_side()
	else:
		switch_side()

func death_anim_true():
	#death animation, gravity and rotation
	z_index = 1000
	animation += 0.6
	scale.y = sin(animation + 3.0) * 0.4 + 1.0
	scale.x = sin(animation) * 0.4 + 1.0
	global_position += Vector2(death_x_velocity, death_y_velocity)
	death_y_velocity += death_gravity
	rotation += deg_to_rad(death_x_velocity * 3)
	if abs(death_x_velocity) < 3:
		rotation += deg_to_rad(5)
		death_x_velocity = start_death_x_velocity

func shoot():
	inst_laser()
	shoot_particles.z_index = 1000
	shoot_particles.emitting = true
	brightness_val = 10
	sprite.scale = Vector2(0.4, 1.7)
	set_modulate(Color.from_hsv(0.0, 0.0, 5, 1.0))

func inst_laser():
	var instance = laser.instantiate()
	instance.global_position = global_position + Vector2(0, 60)
	get_parent().add_child(instance)

func _move_down():
	move_down_animation = true
	move_down_timer.start()
	var tween = create_tween()
	tween.tween_property(self, "base_position:y", base_position.y + Global.grid_height, 0.5).set_trans(Tween.TRANS_BACK)

func shake(anim):
	sprite.global_position = base_position + Vector2(randi_range(-anim, anim), randi_range(-anim, anim))

func color_anim(anim):
	set_modulate(Color.from_hsv(0.0, 0.0, float(anim / 10 * 5 + 1), 1.0))

func hit():
	$HitSfx.play()
	shake_val = 10
	brightness_val = 10
	health -= 10
	if health > 0:
		if randi_range(0, 1) == 0:
			sprite.scale.x = randi_range(1.6, 2.5)
			sprite.scale.y = randi_range(0.2, 0.6)
		
		else:
			sprite.scale.x = randi_range(0.2, 0.6)
			sprite.scale.y = randi_range(1.6, 2.5)
	else:
		health = 0
		destroy()

#process
func _process(delta: float) -> void:
	base_position.y += sin(wave) * wave_AMP
	#lerp back values after getting hit
	if death_anim == false:
		death_anim_false(delta)
	
	if death_anim == true:
		death_anim_true()
	
	#destroy if invisible
	if modulate.a == 0:
		queue_free()
	
	if !Global.is_game_end:
		if global_position.y > 1060 and !ship.is_game_over and !death_anim:
			ship.death()


#signals
func _on_area_entered(area: Area2D) -> void:
	if !death_anim and area is Laser:
		death_x_velocity = area.get_parent().rotation_degrees * 0.5
		hit()

func _on_move_down_timer_timeout() -> void:
	move_down_animation = false

func _on_shoot_timer_timeout() -> void:
	if !ship.is_game_over and death_anim == false:
		shoot()
		shoot_timer.start()
