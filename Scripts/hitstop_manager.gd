extends Node

func hitstop(freeze_time):
	# Freeze
	Engine.time_scale = 0

	await get_tree().create_timer(freeze_time, true, false, true).timeout

	# Unfreeze
	Engine.time_scale = 1
