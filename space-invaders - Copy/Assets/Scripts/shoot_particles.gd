extends Node2D

func _process(delta: float) -> void:
	if get_child(0).emitting == false:
		queue_free()
