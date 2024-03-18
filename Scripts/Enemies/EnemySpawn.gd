extends Node3D

@export var spawn_radius = 10
@export var enemyPerWave = 5
@export var secondsPerWave = 10
@onready var enemy = preload("res://Objects/Enemies/enemy.tscn")
@onready var player = get_tree().get_first_node_in_group("Player")

var timer = Timer.new()

func _ready():
	timer.set_wait_time(secondsPerWave)
	timer.set_one_shot(false)
	timer.connect("timeout", Callable(self, "spawn_enemies"))
	add_child(timer)
	timer.start()

	spawn_enemies()


func spawn_enemies():
	for i in range(enemyPerWave):
		var enemy_instance = enemy.instantiate()
		add_child(enemy_instance)
		var spawn_position = generate_spawn_position()
		enemy_instance.global_transform.origin = Vector3(spawn_position.x, 0.5, spawn_position.z)

func generate_spawn_position():
	var player_position = player.global_transform.origin
	var spawn_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	var spawn_distance = randf_range(1, spawn_radius)
	return player_position + spawn_direction * spawn_distance
