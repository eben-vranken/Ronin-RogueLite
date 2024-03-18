extends CharacterBody3D

### Character properties
# Movement speeds
@export var walk_speed = 10
@export var sprint_speed = 15
@export var focus_speed = 5
@export var acceleration = 1.5
@export var max_speed = 30
@onready var sprintParticle: GPUParticles3D = $SprintParticle

# Dash
@export var dash_force = 25
@export var dash_length = 0.15
@export var dash_cooldown = 1.25
var is_dashing = false
var can_dash = true
var dash_timer = Timer.new()
var dash_reset = Timer.new()
@onready var dashParticle: GPUParticles3D = $DashParticle

# Attack
@export var defaultDamage = 20
@export var dashDamage = 35
var activeDamage = defaultDamage

@export var default_knockback = 10
@export var dash_knockback = 15
var active_knockback = default_knockback

@export var attack_length = 0.10
@export var attack_cooldown = 0.25
var is_attacking = false
var can_attack = true
var attack_timer = Timer.new()
var attack_reset = Timer.new()
@onready var swordModel = $Sword
@onready var swordCollision = $"Sword/Sword Hurtbox"

# INPUTS
var move_direction
var look_direction

func _ready():
	# Dash Timers
	dash_timer.connect("timeout", Callable(self, "stop_dash"))
	add_child(dash_timer)
	dash_reset.connect("timeout", Callable(self, "reset_dash"))
	add_child(dash_reset)

	# Attack timers
	attack_timer.connect("timeout", Callable(self, "stop_attack"))
	add_child(attack_timer)
	attack_reset.connect("timeout", Callable(self, "reset_attack"))
	add_child(attack_reset)

func _physics_process(delta):
	# If hitfreeze
	if Engine.time_scale == 0:
		return

	move_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	look_direction = Input.get_vector("look_left", "look_right", "look_up", "look_down")

	### PLAYER ROTATION
	# Normalize input
	look_direction = Vector3(look_direction.x, 0, look_direction.y).normalized()

	# Movement direction
	var movement_direction = Vector3(move_direction.x, 0, move_direction.y).normalized()

	# Set target direction
	var target_direction = look_direction if look_direction && !Input.is_action_pressed("sprint") else movement_direction

	# Freeze rotation when not moving.
	if target_direction:
		# Calculate look at rotation
		var look_rotation = Vector2(target_direction.x, target_direction.z).angle()
		rotate_y(-look_rotation - rotation.y)

	### PLAYER MOVEMENT
	# Apply input to velocity
	var speed = sprint_speed if Input.is_action_pressed("sprint") && !look_direction else focus_speed if Input.is_action_pressed("focus") else walk_speed

	# Don't move while dashing
	if not is_dashing:
		velocity.x = move_toward(velocity.x, speed * move_direction.x, acceleration)
		velocity.z = move_toward(velocity.z, speed * move_direction.y, acceleration)

	# Cap velocity
	velocity = velocity.limit_length(max_speed)

	# Apply velocity to body
	move_and_slide()

	# Enable sprint particles when sprinting
	sprintParticle.emitting = Input.is_action_pressed("sprint") && movement_direction && ((move_direction.x > 0.65 || move_direction.y > 0.65) || (move_direction.x < -0.65 || move_direction.y < -0.65))

	### PLAYER ATTACKING
	# Enable sword when attacking
	swordModel.visible = is_attacking
	swordCollision.disabled = !is_attacking

### INPUT CHECKS
func _input(_event):
	# Dash
	if Input.is_action_pressed('dash') and can_dash:
		dash()

	if Input.is_action_just_pressed("attack") and can_attack:
		attack()

### DASHING FUNCTIONS
func dash():
	can_dash = false
	is_dashing = true

	# Set dash stat upgrades
	activeDamage = dashDamage
	active_knockback = dash_knockback

	# Enable Particle
	dashParticle.emitting = true

	# Dash Length timer
	dash_timer.start(dash_length)

	# Dash reset timer
	dash_reset.start(dash_cooldown)

	var dash_vector: Vector3
	if(move_direction):
		dash_vector = Vector3(move_direction.x, 0, move_direction.y).normalized()
	# Player is standing still, dash in direction the model is aiming at.
	else:
		dash_vector = global_transform.basis.x.normalized()

	# Apply dash
	velocity = dash_vector * dash_force



func stop_dash():
	is_dashing = false
	dash_timer.stop()

	# Disable particle
	dashParticle.emitting = false

	# Reset dash stats
	activeDamage = defaultDamage
	active_knockback = default_knockback

func reset_dash():
	can_dash = true
	dash_reset.stop()

### ATTACKING FUNCTIONS
func attack():
	can_attack = false
	is_attacking = true

	# Dash Length timer
	attack_timer.start(attack_length)

	# Dash reset timer
	attack_reset.start(attack_cooldown)

func stop_attack():
	is_attacking = false
	attack_timer.stop()

func reset_attack():
	can_attack = true
	attack_reset.stop()

# Sword hit something
func _on_sword_body_entered(body):
	var hitTarget = body

	# If target was enemy
	if hitTarget.is_in_group("enemy"):
		# Vibrate controller
		Input.start_joy_vibration(0,1,1,attack_length)

		hitTarget.get_node('Health System').take_damage(activeDamage, true, active_knockback)

	if hitTarget.is_in_group("hit"):
		# Vibrate controller
		Input.start_joy_vibration(0,1,1,attack_length)

		hitTarget.get_node('Health System').take_damage(activeDamage, false)
