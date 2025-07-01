extends Node2D

@export var level_paths := [
	"res://scenes/level_1.tscn",
	"res://scenes/level_2.tscn",
	#"res://Level3.tscn"
]

var current_level_index := 0
var game_end_customers := 5

@onready var start_pic = $CanvasLayer/CenterContainer/StartPicture
@onready var start_button = start_pic.get_node("StartButton")  # Adjust path if needed
@onready var happy_label = $CanvasLayer/ScoreContainer/VBoxContainer/HappyLabel
@onready var unhappy_label = $CanvasLayer/ScoreContainer/VBoxContainer/UnhappyLabel
@onready var finish_label = $CanvasLayer/CenterContainer/FinishBanner/Label
@onready var restart_button = $CanvasLayer/CenterContainer/FinishBanner.get_node("RestartButton")
@onready var next_level_button = $CanvasLayer/CenterContainer/FinishBanner.get_node("NextLevelButton")
@onready var timer_label = $CanvasLayer/TimerContainer/TimerLabel

@export var customer_scene: PackedScene  # Assign in Inspector

var game_active := false  # Don't start until button is pressed
var happy_customers := 0
var unhappy_customers := 0
var elapsed_time := 0.0

var current_level: Node
var customer_spawn_point: Node2D

func _ready():
	_load_level()
	# Connect the Start button
	start_button.connect("pressed", Callable(self, "_on_start_pressed"))	
	restart_button.connect("pressed", Callable(self, "_on_restart_pressed"))
	next_level_button.connect("pressed", Callable(self, "_on_next_level_pressed"))

func _process(delta):
	if game_active:
		elapsed_time += delta
		timer_label.text = "⏱️ %.1f" % elapsed_time
		
func _load_level():
	# Remove previous level if any
	if current_level:
		current_level.queue_free()

	var level_scene = load(level_paths[current_level_index])
	current_level = level_scene.instantiate()
	add_child(current_level)



func _on_start_pressed():
	start_pic.visible = false
	game_active = true
	print("current level is ", current_level)
	customer_spawn_point = current_level.get_node_or_null("CustomerSpawnPoint")
	
	if not customer_spawn_point:
		print("❌ Couldn't find CustomerSpawnPoint in the current level")
		return
	_spawn_customer()
	happy_label.visible = true
	unhappy_label.visible = true
	timer_label.visible = true
	update_labels()

func _spawn_customer():
	var customer = customer_scene.instantiate()
	customer.global_position = customer_spawn_point.global_position
	current_level.add_child(customer)
	
	# Connect signals for happy and unhappy customers
	customer.connect("happy_leave", Callable(self, "_on_customer_happy_leave"))
	customer.connect("unhappy_leave", Callable(self, "_on_customer_unhappy_leave"))

func _on_customer_happy_leave():
	print("Received happy leave!")
	increment_happy()
	if happy_customers >= game_end_customers:
		level_finished()

func _on_customer_unhappy_leave():
	increment_unhappy()

func increment_happy():
	happy_customers += 1
	update_labels()

func increment_unhappy():
	unhappy_customers += 1
	update_labels()

func update_labels():
	happy_label.text = "😊  %d" % happy_customers
	unhappy_label.text = "😡  %d" % unhappy_customers

func level_finished():
	print("🎉 Level completed in %d seconds!" % elapsed_time)
	game_active = false
	$CanvasLayer/CenterContainer/FinishBanner.visible = true
	finish_label.text = "🎉 Level Complete! 🎉 \n Level finished in %ds!" % elapsed_time 
	
func _on_restart_pressed():
	print("Restarting level...")
	get_tree().reload_current_scene()
	
func _on_next_level_pressed():
	print("Loading next level...")
	#get_tree().change_scene("res://path_to_next_level.tscn")
