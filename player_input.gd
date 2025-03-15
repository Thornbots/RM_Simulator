extends MultiplayerSynchronizer

# Set via RPC to simulate is_action_just_pressed.
@export var jumping := false

# Synchronized property.
@export var direction := Vector2()

@onready var ball_spawn := $"../../../Objects"


func _ready():
	# Only process for the local player
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())


@rpc("call_local")
func jump():
	jumping = true

@rpc("call_local")
func balls():
	print("Received RPC call: " + str(multiplayer.get_unique_id()))
	var ball := preload("res://sphere.tscn").instantiate()
	ball.position = $"..".position
	ball.linear_velocity = Vector3(0, 2, -4)
	ball_spawn.add_child(ball, true)
	
@rpc("call_local")
func update_ui():
	if 1 == multiplayer.get_unique_id():
		$"../../../UI".p1_health = $"..".fuckass
	else:
		$"../../../UI".p2_health = $"..".fuckass
	
func _process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if Input.is_action_just_pressed("ui_accept"):
		jump.rpc()
		update_ui.rpc()
	if Input.is_action_just_pressed("shoot"):
		print("Sending RPC call: " + str(multiplayer.get_unique_id()))
		balls.rpc()
