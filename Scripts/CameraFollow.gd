extends Camera3D

@export var cameraOffset = Vector3(0, 17.5, 10)
@export var cameraFollowSpeed = 10

var playerCharacter: CharacterBody3D

func _ready():
	playerCharacter = get_tree().get_first_node_in_group("Player")

	# Look at player
	look_at(playerCharacter.position, Vector3.UP, false)

func _process(delta):
	# Calculate target position
	var target_position = playerCharacter.position + cameraOffset

	# Lerp to target position
	position = position.lerp(target_position, delta * cameraFollowSpeed)
