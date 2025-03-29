extends MultiplayerSynchronizer

# Set via RPC to simulate is_action_just_pressed.
@export var jumping := false
@export var shooting := false

# Synchronized property.
@export var direction := Vector2()
@export var mouse_rotation: Vector3

@export var MOUSE_SENSITIVITY: float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)

var _rotation_input: float
var _tilt_input: float
var _mouse_input: bool = false

func _ready():
	# Only process for the local player
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())


@rpc("call_local")
func jump():
	jumping = true

@rpc("call_local")
func shoot():
	shooting = true
	
	
@rpc("call_local")
func update_ui():
	if 1 == multiplayer.get_remote_sender_id():
		$"../../../UI".p1_health = $"..".health
	else:
		$"../../../UI".p2_health = $"..".health
		
func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY

func _update_camera(delta):
	mouse_rotation.x += _tilt_input*delta
	mouse_rotation.x = clamp(mouse_rotation.x,TILT_LOWER_LIMIT,TILT_UPPER_LIMIT)
	mouse_rotation.y += _rotation_input * delta
	
	_rotation_input = 0.0
	_tilt_input = 0.0
	
func _process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	_update_camera(delta)
	
	if Input.is_action_just_pressed("ui_accept"):
		jump.rpc()
	if Input.is_action_just_pressed("shoot"):
		shoot.rpc()
		
	update_ui.rpc()
