extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D

@export var speed = 15
@export var acceleration = 15
var isKnockedBack = false

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("Player")

func _physics_process(delta):
	await get_tree().physics_frame

	### MOVEMENT
	if not isKnockedBack:
		var current_position = global_transform.origin
		var next_position = nav_agent.get_next_path_position()
		var target_velocity = (next_position - current_position).normalized() * speed

		# Calculate acceleration towards the target velocity
		var acceleration_vector = (target_velocity - velocity).normalized() * acceleration

		# Update velocity with acceleration
		velocity += acceleration_vector * delta

		# Move with the updated velocity
	move_and_slide()

	### ROTATION
	var look_rotation = Vector3(player.position.x, global_position.y,player.position.z)
	look_at(look_rotation)

func update_target(target_location):
	nav_agent.target_position = target_location
