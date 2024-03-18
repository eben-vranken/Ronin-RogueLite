extends Label

var debugFormat = "FPS: {fps}\nFPS Lock: {fpsLock}\nCollisions: {collisionsVisible}"

@export var fpsLock = true
@export var collision_visible= false
signal variable_changed(fpsLock)

# Initialize
func _ready():
	Engine.max_fps = 60 if fpsLock else 0

func _process(_delta):
	var fps = Engine.get_frames_per_second()

	text = debugFormat.format({"fps": fps, "fpsLock": fpsLock, "collisionsVisible": collision_visible})

func _input(_event):
	# Lock FPS
	if Input.is_action_just_pressed("debug_fpslock"):
		fpsLock = !fpsLock
		Engine.max_fps = 60 if fpsLock else 0

	# Visible Collisions
	if Input.is_action_just_pressed("debug_visiblecollision"):
		collision_visible = !collision_visible
		get_tree().set_debug_collisions_hint(collision_visible)
