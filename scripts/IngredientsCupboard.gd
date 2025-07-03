extends Area2D

var eggs: int = 0
var tomatoes: int = 5
var lettuce: int = 5

@onready var egg_icon = $Eggs_in_Cb  # Adjust this path if needed
@onready var egg_label = $EggLabel  # Shows the number of eggs
@onready var tomato_icon = $Tomatoes_in_Cb
@onready var tomato_label = $TomatoLabel  # Shows the number of tomatoes
@onready var lettuce_icon = $Lettuce_in_Cb
@onready var lettuce_label = $LettuceLabel  # Shows the number of Lettuces

func _ready():
	update_ui()

# Adds an ingredient by name
func add_ingredient(ingredient: String, amount: int = 1):
	match ingredient:
		"egg": eggs += amount
		"tomato": tomatoes += amount
		"lettuce": lettuce += amount
	update_ui()

# Removes an ingredient safely (won’t go negative)
func remove_ingredient(ingredient: String, amount: int = 1):
	match ingredient:
		"egg": eggs = max(eggs - amount, 0)
		"tomato": tomatoes = max(tomatoes - amount, 0)
		"lettuce": lettuce = max(lettuce - amount, 0)
	update_ui()

# For cooking stations to verify if enough of each ingredient exists
func has_ingredients(required: Dictionary) -> bool:
	for item in required:
		if get_count(item) < required[item]:
			return false
	return true

# Removes multiple ingredients
func remove_ingredients(required: Dictionary):
	for item in required:
		remove_ingredient(item, required[item])

# Gets the count of a specific ingredient
func get_count(ingredient: String) -> int:
	match ingredient:
		"egg": return eggs
		"tomato": return tomatoes
		"lettuce": return lettuce
		_: return 0

# Updates UI (for now just eggs, expand later)
func update_ui():
	_update_icons()
	_update_labels()

func _update_icons():
	egg_icon.visible = eggs > 0
	tomato_icon.visible = tomatoes > 0
	lettuce_icon.visible = lettuce > 0

func _update_labels():
	if eggs > 0:
		egg_label.text = str(eggs) + "x"
	else:
		egg_label.text = ""
	if tomatoes > 0:
		tomato_label.text = str(tomatoes) + "x"
	else:
		tomato_label.text = ""
	if lettuce > 0:
		lettuce_label.text = str(lettuce) + "x"
	else:
		lettuce_label.text = ""
