extends Node2D

@export var cook_time := 8.5 # Seconds it takes to cook an egg
@onready var cook_sound = $CookSound

var cooking := false
var cook_timer := 0.0

func _on_area_entered(area):
	if area.is_in_group("player") and not cooking:
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
