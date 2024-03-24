extends CharacterBody3D

@onready var animation_player : AnimationPlayer = $Pivot/LowPolyGirl/AnimationPlayer
@onready var main_camera : Camera3D = $MainCamera

# TODO Change from export to const variables
@export var MAX_WALK: float = 10.0 # Good walk is 2.6
@export var MAX_RUN: float = 18.0
@export var STAMINA_REGENERATION_RATE = 40.0
@export var SPRINT_STAMINA_USE = 20.0
@export var JUMP_STAMINA_USE = 20
@export var HUNGER_RATE = 10.0
@export var FALL_ACCELERATION = 75.0
@export var JUMP_IMPULSE = 20.0
@export var WALK_ANIMATION_SPEED_SCALE: float = 1.0
@export var RUN_ANIMATION_SPEED_SCALE: float = 2.0
@export var IDLE_ANIMATION_SPEED_SCALE: float = 1.0

var max_health = 100
var health

var max_stamina = 100
var stamina
var used_stamina: bool
var can_use_stamina = true

var max_hunger = 100
var hunger

var target_velocity = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
# This would be saved to whatever the players last saved values would be
func _ready():
	health = max_health
	stamina = max_stamina
	hunger = max_hunger


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _physics_process(delta):
	var direction = Vector3.ZERO
	used_stamina = false
	animation_player.speed_scale = WALK_ANIMATION_SPEED_SCALE
	
# ------------ DIRECTIONAL INPUT ----------
	if Input.is_action_pressed("input_up"):
		direction.z -= 1
	if Input.is_action_pressed("input_down"):
		direction.z += 1 
	if Input.is_action_pressed("input_left"):
		direction.x -= 1
	if Input.is_action_pressed("input_right"):
		direction.x += 1
	
# ------------ CHECK FOR WALKING OR RUNNING ----------
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction)
		# RUNNING
		if Input.is_action_pressed("input_shift") and can_use_stamina:
			if use_stamina_over_time(SPRINT_STAMINA_USE, delta):
				target_velocity.x = direction.x * MAX_RUN
				target_velocity.z = direction.z * MAX_RUN
				used_stamina = true
				animation_player.speed_scale = RUN_ANIMATION_SPEED_SCALE
				animation_player.play("run", 0.25)
		# WALKING
		else:
			target_velocity.x = direction.x * MAX_WALK
			target_velocity.z = direction.z * MAX_WALK
			animation_player.play("walk", 0.25)
	# IDLE
	else:
		if is_on_floor():
			target_velocity.x = 0
			target_velocity.z = 0
		animation_player.speed_scale = IDLE_ANIMATION_SPEED_SCALE
		animation_player.play("idle", 0.25)

# ------------ APPLYING GRAVITY ----------
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (FALL_ACCELERATION * delta)

# ------------ JUMP INPUT ----------
	if Input.is_action_pressed("input_jump") and is_on_floor():
		if use_stamina_chunk(JUMP_STAMINA_USE):
			target_velocity.y = JUMP_IMPULSE
		else:
			target_velocity.y = JUMP_IMPULSE / 4
		used_stamina = true
	
# ------------ STAMINA REGEN CHECK ----------
	if not used_stamina and stamina < max_stamina and is_on_floor():
		regenerate_stamina(delta)

# ------------ USE HUNGER ----------
	use_hunger(delta)

# ------------ APPLYING FINAL VELOCITY AND MOVING ----------
	velocity = target_velocity
	move_and_slide()

# Returns true if there is still stamina left
# False if stamina ran out with that use
func use_stamina_over_time(action_stamina_rate, delta):
	if action_stamina_rate * delta > stamina:
		stamina = 0
		$MainCamera/StaminaBar.value = 0
		$FloatingHealthBar/SubViewport/Panel/ProgressBar.value = 0
		can_use_stamina = false
		$StaminaCooldown.start()
		return false
	else:
		stamina -= action_stamina_rate * delta
		$MainCamera/StaminaBar.value = stamina
		$FloatingHealthBar/SubViewport/Panel/ProgressBar.value = stamina
		return true


func use_stamina_chunk(stamina_amount):
	if stamina_amount > stamina:
		return false
	else:
		stamina -= stamina_amount
		$MainCamera/StaminaBar.value = stamina
		$FloatingHealthBar/SubViewport/Panel/ProgressBar.value = stamina
		return true


func regenerate_stamina(delta):
	stamina += STAMINA_REGENERATION_RATE * delta
	$MainCamera/StaminaBar.value = stamina
	$FloatingHealthBar/SubViewport/Panel/ProgressBar.value = stamina


func use_hunger(delta):
	if HUNGER_RATE * delta > hunger:
		hunger = 0
		$MainCamera/HungerBar.value = 0
		
		health -= HUNGER_RATE * delta
		$MainCamera/HealthBar.value = health
	else:
		hunger -= HUNGER_RATE * delta
		$MainCamera/HungerBar.value = hunger


func _on_stamina_cooldown_timeout():
	can_use_stamina = true
