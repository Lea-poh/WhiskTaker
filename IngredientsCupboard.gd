extends Area2D

var egg_count: int = 0
@onready var egg_icon = $Eggs_in_Cb  # Adjust path to your egg icon node

func _ready():
	pass # Replace with function body.

func add_egg():
	egg_count += 1
	print("🥚 Egg stored! Total:", egg_count)
	update_label()
	_update_egg_icon()
	
func remove_egg():
	egg_count = max(egg_count - 1, 0)
	print("🥚 Egg removed! Total:", egg_count)
	update_label()
	_update_egg_icon()

func update_label():
	if has_node("Label"):
		$Label.text = "🥚: " + str(egg_count)

func _update_egg_icon():
	egg_icon.visible = egg_count > 0
