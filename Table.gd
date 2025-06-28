extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

@export var EggDishScene: PackedScene
@onready var spawn_points_container = $DishSpawnPoints
var occupied_spots := []

func spawn_dish():
	print("Try to spawn dish")
	for spot in spawn_points_container.get_children():
		if spot.name not in occupied_spots:
			var dish = EggDishScene.instantiate()
			get_tree().current_scene.add_child(dish)
			dish.global_position = spot.global_position
			dish.set_spawn_point_name(spot.name)
			dish.connect("dish_removed", Callable(self, "_on_dish_removed"))
			occupied_spots.append(spot.name)
			return true  # success
	return false  # table full

func is_full() -> bool:
	return occupied_spots.size() >= spawn_points_container.get_child_count()

func _on_dish_removed(spot_name):
	if spot_name in occupied_spots:
		occupied_spots.erase(spot_name)

