extends Node2D

@export var SaladDishScene: PackedScene

@onready var cook_sound = $CookSound


var cooking := false
var cook_timer := 0.0
var occupied_spots := []
var table: Node
var cupboard: Node2D
var spawn_points_container: Node2D
var req_ingredients = {
	"tomato": 1,
	"lettuce": 1
}

func _ready():
	table = get_parent().get_node_or_null("Table")
	if table == null:
		print("❌ Couldn't find Table")
	spawn_points_container = table.get_node_or_null("DishSpawnPoints")
	if spawn_points_container == null:
		print("❌ Couldn't find DishSpawnPoints")



func _on_ready():
	pass


func _on_area_entered(area):
	if area.is_in_group("player") and not cooking:
		if table.is_full():
			update_label()
			print("🛑 Table is full. Cannot start cooking.")
			return
		cupboard = get_parent().get_node_or_null("IngredientsCupboard")
		if spawn_points_container == null:
			print("❌ Couldn't find IngredientsCupboard in Stove")
		if cupboard.has_ingredients(req_ingredients):
			cupboard.remove_ingredients(req_ingredients)
			start_cooking()

func update_label():
	if table.is_full():
		$Label.text = "🛑 Table is full"
	else:
		$Label.text = ""
		
	

func start_cooking():
	cooking = true
	cook_timer = 0.0
	$CookTimer.visible = true
	$CookTimer.value = 0
	cook_sound.play()
	#print("Started cooking egg...")

func _process(delta):
	update_label()
	if cooking:
		cook_timer += delta
		var cook_time = cook_sound.stream.get_length() - 1.7
		var progress = clamp(cook_timer / cook_time, 0, 1)
		$CookTimer.value = progress * 100
		if cook_timer >= cook_time:
			cooking = false
			$CookTimer.visible = false
			print("Salad done!")
			table.spawn_dish(preload("res://scenes/SaladDish.tscn"))
