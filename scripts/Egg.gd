extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_area_2d_area_entered(area):
	# print("Touched by:", area.name, "Groups:", area.get_groups())
	if area.is_in_group("player"):
		# print("✅ It's the player!")
		var cupboard = get_parent().get_node("IngredientsCupboard")
		cupboard.add_egg()
		$EggPickupSound.play()
		await $EggPickupSound.finished
		queue_free()
