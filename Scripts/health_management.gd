extends Node3D

# Label Stuff
@export var label_height_above_model = 0
@export var label_radius_around_model = 0.25
@export var text_size := 32

# Stats
@export var health = 50
@export var knockback_time = 0.2
var knockback_timer = Timer.new();

# Owner
@onready var object = get_owner()
@onready var player = get_tree().get_first_node_in_group("Player")

var damage_count_label = load("res://damage_count_label.tscn")

func _ready():
	knockback_timer.connect("timeout", Callable(self, "stop_knockback"))
	add_child(knockback_timer)

func _process(_delta):
	if health <= 0:
		# Die
		object.queue_free()
		# HitstopManager.hitstop(0.10)

func take_damage(damage, doKnockback, knockback_amount=0):
	health -= damage

	# Knockback
	if(doKnockback):
		take_knockback(knockback_amount)

	# Instantiate label
	var damage_count_label_instance = damage_count_label.instantiate()
	damage_count_label_instance.text = str(damage)

	# Generate a random offset within the radius
	var random_offset = Vector3(
		randf() * label_radius_around_model * 2 - label_radius_around_model,
		0,
		randf() * label_radius_around_model * 2 - label_radius_around_model
	)

	# Set height
	damage_count_label_instance.transform.origin = random_offset + Vector3(0, label_height_above_model, 0)

	# Set font size
	damage_count_label_instance.font_size = text_size

	add_child(damage_count_label_instance)

func take_knockback(knockback_amount):
	owner.isKnockedBack = true



	var knockback_direction = -owner.global_position.direction_to(player.global_position)
	owner.velocity += knockback_direction * knockback_amount

	knockback_timer.start(knockback_time)

func stop_knockback():
	owner.isKnockedBack = false
