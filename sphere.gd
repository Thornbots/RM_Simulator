extends RigidBody3D

@export var damage = 1

#FIXME: Bullets can collide with each other
func _on_body_entered(other: CollisionObject3D) -> void:
	print("Collided with: ", other)
	print(other.collision_layer)
	print(other.get_collision_layer_value(2))
	
	if other.get_collision_layer_value(2):
		print("Hit other player")
		other.take_damage(damage)
	queue_free()
