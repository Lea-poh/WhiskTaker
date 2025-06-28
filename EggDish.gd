extends Node2D

signal dish_removed(spot_name: String)

var spawn_point_name := ""

func set_spawn_point_name(name):
	spawn_point_name = name

func _on_pickup():  # Call this when the chef picks up the dish
	print("I have been picked up")
	print("Spawn point name is:", spawn_point_name)
	print("Emitting signal: dish_removed")
	emit_signal("dish_removed", spawn_point_name)

func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		# print("Touched by:", area.name, " Groups:", area.get_groups())
		var chef = area.get_parent()
		if chef.has_dish():
			return
		#chef.pick_up_dish(self)
		chef.call_deferred("pick_up_dish", self)

