extends Node2D

signal dish_removed(spot_name: String)

var spawn_point_name := ""

func set_spawn_point_name(name):
	spawn_point_name = name

func _on_pickup():  # Call this when the chef picks up the dish
	dish_removed.emit(spawn_point_name)
