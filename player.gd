extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var CAMERA_CONTROLLER: Camera3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _player_rotation: Vector3 
var _camera_rotation: Vector3

@export var health = 10
var a = preload("res://sphere.tscn")

# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		print("multi", id)
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)

# Player synchronized input.
@onready var input = $PlayerInput
@onready var cam = $CameraPivot/Camera3D
@onready var ball_spawn := $"../../Objects"
@onready var ray_cast := $CameraPivot/Camera3D/RayCast3D


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Set the camera as current if we are this player.
	if player == multiplayer.get_unique_id():
		cam.current = true
	# Only process on server.
	# EDIT: Left the client simulate player movement too to compesate network latency.
	# set_physics_process(multiplayer.is_server())

func _update_camera(delta):
	_player_rotation = Vector3(0.0,input.mouse_rotation.y,0.0)
	_camera_rotation = Vector3(input.mouse_rotation.x,0.0,0.0)
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	
func _shoot():
	var ball := a.instantiate()
	ball_spawn.add_child(ball, true)
	ball.position = ray_cast.global_position
	ball.linear_velocity = ray_cast.global_transform.basis * Vector3(0,0,-10.0)
	
func take_damage(damage):
	print("taking damage")
	health -= damage
	print(health)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	_update_camera(delta)

	# Handle Jump.
	if input.jumping and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if input.shooting:
		_shoot()

	# Reset jump state.
	input.jumping = false
	input.shooting = false

	# Handle movement.
	var direction = (transform.basis * Vector3(input.direction.x, 0, input.direction.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
