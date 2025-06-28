extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

@export var EggDishScene: PackedScene
@onready var spawn_points_container = $DishSpawnPoints

func spawn_dish():
	var free_spawn_points = []
	for spawn_point in spawn_points_container.get_children():
		if not spawn_point.has_meta("occupied") or spawn_point.get_meta("occupied") == false:
			free_spawn_points.append(spawn_point)
			
	if free_spawn_points.size() == 0:
		print("No free spawn points available, can't spawn dish.")
		return
	
	var spawn_point = free_spawn_points[0]  # pick first free spawn point
	
	# Mark as occupied
	spawn_point.set_meta("occupied", true)
	
	
	var dish = EggDishScene.instantiate()
	dish.name = spawn_point.name  # Give each dish a useful name
	dish.set_spawn_point_name(spawn_point.name)
	spawn_point.add_child(dish)
	dish.global_position = spawn_point.global_position
	
	dish.connect("dish_removed", Callable(self, "_on_dish_removed"))
	print("Connected dish_removed signal for:", dish.name)



func is_full() -> bool:
	for spawn_point in spawn_points_container.get_children():
		if not spawn_point.get_meta("occupied", false):
			return false  # found a free spot
	return true  # all occupied

func _on_dish_removed(spot_name: String) -> void:
	print("Table received dish_removed signal for:", spot_name)
	for spawn_point in spawn_points_container.get_children():
		if spawn_point.name == spot_name:
			spawn_point.set_meta("occupied", false)
			print("Spawn point freed:", spot_name)
			break

