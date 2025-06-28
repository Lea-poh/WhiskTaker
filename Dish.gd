extends Node2D

var is_carried = false
var carrier = null

func _ready():
	mode = RigidBody2D.MODE_RIGID

func pick_up(by_node):
	carrier = by_node
	mode = RigidBody2D.MODE_KINEMATIC
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	get_parent().remove_child(self)
	carrier.add_child(self)
	global_position = Vector2.ZERO  # Adjust as needed, e.g., offset for holding

func drop(drop_position):
	mode = RigidBody2D.MODE_RIGID
	set_deferred("collision_layer", 1)
	set_deferred("collision_mask", 1)
	carrier.remove_child(self)
	get_parent().add_child(self)
	global_position = drop_position
	carrier = null

