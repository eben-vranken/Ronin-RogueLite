extends Label3D

var rise_speed = 2.0
var fade_speed = 3
var text_size = 32

func _process(delta):
	# Rise up
	translate(Vector3.UP * rise_speed * delta)

	# Fade out
	transparency += fade_speed * delta
	if transparency <= 0.0:
		queue_free()
