extends Camera3D

@export var lerp_speed = 3.0
@export var camera_offset = Vector3(0, 6, 8)
@export var camera_rotation = deg_to_rad(-30)
@onready var player_node = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	$HealthBar.value = player_node.max_health
	$StaminaBar.value = player_node.max_stamina
	$HungerBar.value = player_node.max_hunger

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _physics_process(delta):
	var target_player_position = player_node.global_transform.translated_local(camera_offset)
	global_transform = global_transform.interpolate_with(target_player_position, lerp_speed * delta)
	
	rotation.x = camera_rotation
	
