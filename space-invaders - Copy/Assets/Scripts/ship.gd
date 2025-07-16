extends CharacterBody2D

signal inst_laser
signal game_over
signal complete

@onready var shoot_timer: Timer = $Shoot
@onready var particle: Sprite2D = $Particle
@onready var light: Timer = $Light
@onready var death_particles: CPUParticles2D = $"Death Particles"
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var death_sfx: AudioStreamPlayer2D = $DeathSfx
@onready var collision_shape_2d: CollisionShape2D = $Collision/CollisionShape2D


var can_shoot := true
var speed := 1000.0
var start_pos_y := 1000.0 - wave_AMP / 2
var shoot_knockback := 20
var wave_AMP := 0.5
var wave_FREQ := 0.06
var wave := 0.0
var width := 60
var is_game_over = false


func _process(delta: float) -> void:
	#float effect
	wave += wave_FREQ
	start_pos_y += sin(wave) * wave_AMP
	
	#inputs
	if not Input.is_action_pressed("left") or not Input.is_action_pressed("right"):
		velocity.x = lerp(velocity.x, 0.0, 0.2)
		rotation = lerp(rotation, deg_to_rad(0), 0.2)
	if Input.is_action_pressed("left"):
		velocity.x = lerp(velocity.x, -speed, 0.2)
		rotation = lerp(rotation, deg_to_rad(-30), 0.2)
	if Input.is_action_pressed("right"):
		velocity.x = lerp(velocity.x, speed, 0.2)
		rotation = lerp(rotation, deg_to_rad(30), 0.2)
	
	global_position.y = lerp(global_position.y, start_pos_y, 0.2)
	
	#actions
	if !is_game_over:
		if Input.is_action_just_pressed("shoot"):
			shoot()
			
		if Input.is_action_pressed("shoot"):
			if can_shoot:
				shoot()
	
	#teleport when out of map
	if global_position.x < -width:
		global_position.x = get_viewport_rect().size.x + width
	if global_position.x > get_viewport_rect().size.x + width:
		global_position.x = -width
	
	if Global.enemies_left == 0:
		emit_signal("complete")
		Global.is_game_end = true
		queue_free()
	
	move_and_slide()

func _on_timer_timeout() -> void:
	can_shoot = true
	if Input.is_action_pressed("shoot"):
		shoot_timer.start()

func shoot():
	emit_signal("inst_laser")
	particle.visible = true
	can_shoot = false
	global_position.y = start_pos_y + shoot_knockback
	rotation = rotation / 2
	light.start()
	shoot_timer.start()


func _on_light_timeout() -> void:
	particle.visible = false

func death():
	is_game_over = true
	collision_shape_2d.queue_free()
	death_particles.emitting = true
	sprite_2d.visible = false
	death_sfx.play()
	emit_signal("game_over")
	

func _on_collision_area_entered(area: Area2D) -> void:
	if area is EnemyLaser:
		death()
	if area is Enemy:
		death()
