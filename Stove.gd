extends Node2D

@export var cook_time := 8.5 # Seconds it takes to cook an egg
@export var EggDishScene: PackedScene

@onready var cook_sound = $CookSound
@onready var table = get_node("/root/Main/Table")
@onready var spawn_points_container: Node2D = get_node("/root/Main/Table/DishSpawnPoints")

var cooking := false
var cook_timer := 0.0
var occupied_spots := []

func _on_ready():
	pass


func _on_area_entered(area):
	if area.is_in_group("player") and not cooking:
		if table.is_full():
			print("🛑 Table is full. Cannot start cooking.")
			return
		var cupboard = get_node("/root/Main/IngredientsCupboard")
		if cupboard.egg_count > 0:
			cupboard.remove_egg()
			start_cooking()

func start_cooking():
	cooking = true
	cook_timer = 0.0
	$EggTimer.visible = true
	$EggTimer.value = 0
	cook_sound.play()
	print("Started cooking egg...")

func _process(delta):
	if cooking:
		cook_timer += delta
		var progress = clamp(cook_timer / cook_time, 0, 1)
		$EggTimer.value = progress * 100
		if cook_timer >= cook_time:
			cooking = false
			$EggTimer.visible = false
			print("Egg cooked!")
			var placed = table.spawn_dish()
			if not placed:
				print("⚠️ Table is full! Dish not placed.")
