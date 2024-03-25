extends Camera3D

# Modifier keys' speed multiplier
const SHIFT_MULTIPLIER = 2.5
const ALT_MULTIPLIER = 1.0 / SHIFT_MULTIPLIER

@onready var player_node = get_parent().get_parent()
@export var lerp_speed = 3.0
@export var camera_offset = Vector3(0, 6, 8)
@export var initial_camera_rotation = deg_to_rad(-30)
@export_range(0.0, 1.0) var sensitivity: float = 0.25

var player_movement_pause = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$HealthBar.value = player_node.max_health
	$StaminaBar.value = player_node.max_stamina
	$HungerBar.value = player_node.max_hunger
	pass

func _input(event):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var target_player_position = player_node.global_transform.translated_local(camera_offset)
	global_transform = global_transform.interpolate_with(target_player_position, lerp_speed * delta)
