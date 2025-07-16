extends CharacterBody2D

var speed := 1000
var death_anim = false

@onready var ship = get_node("/root/World/Ship")
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var death: Timer = $Death

func _ready() -> void:
	velocity.y = speed
	ship.game_over.connect(remove)

func remove():
	if global_position.x > ship.global_position.x - 30 and global_position.x < ship.global_position.x + 30:
		death_anim = true
		velocity.y = -speed
		modulate = Color.from_hsv(0.0, 0.0, 1.0)
		cpu_particles_2d.emitting = false
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(0, 0), 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		death.start()

func _process(delta: float) -> void:
	move_and_slide()
	if death_anim == true:
		velocity.y = lerp(velocity.y, 0.0, 0.2)
	if global_position.y > get_viewport_rect().size.y + 1000:
		queue_free()


func _on_death_timeout() -> void:
	queue_free()
