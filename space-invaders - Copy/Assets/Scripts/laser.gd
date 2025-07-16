extends CharacterBody2D

var speed := 3000
var bullet_hit_particles = preload("res://Assets/Scenes/bullet_hit_particles.tscn")
var width := 60

func inst(pos, rot):
	var instance = bullet_hit_particles.instantiate()
	instance.position = pos
	instance.rotation = rot
	get_node("/root/World").add_child(instance)
	instance.get_child(0).emitting = true

func _ready() -> void:
	rotation += deg_to_rad(randi_range(-1, 1))
	velocity = Vector2(0, -speed).rotated(rotation)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	scale += Vector2(0.1, 0.1)
	
	if global_position.y < -100:
		queue_free()
	
	move_and_slide()
	
	if global_position.x < -width:
		global_position.x = get_viewport_rect().size.x + width
	if global_position.x > get_viewport_rect().size.x + width:
		global_position.x = -width

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Enemy:
		inst(global_position - Vector2(0, 50), rotation + deg_to_rad(180))
		queue_free()
