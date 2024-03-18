extends Node3D

@onready var player = $SubViewportContainer/SubViewport/Player

func _physics_process(_delta):
	get_tree().call_group("enemy", "update_target", player.global_transform.origin)
