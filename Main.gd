extends Node2D

@onready var happy_label = $CanvasLayer/MarginContainer/VBoxContainer/HappyLabel
@onready var unhappy_label = $CanvasLayer/MarginContainer/VBoxContainer/UnhappyLabel

@export var customer_scene: PackedScene  # Assign in Inspector
@export var customer_spawn_point: Node2D  # Assign in Inspector

var happy_customers := 0
var unhappy_customers := 0

func _ready():
	# Start spawning customers every 20 seconds
	var timer = Timer.new()
	timer.wait_time = 20
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.connect("timeout", Callable(self, "_spawn_customer"))

	# Initialize UI
	update_labels()

func _spawn_customer():
	var customer = customer_scene.instantiate()
	customer.global_position = customer_spawn_point.global_position
	add_child(customer)
	
	# Connect signals for happy and unhappy customers
	customer.connect("happy_leave", Callable(self, "_on_customer_happy_leave"))
	customer.connect("unhappy_leave", Callable(self, "_on_customer_unhappy_leave"))

func _on_customer_happy_leave():
	increment_happy()
	if happy_customers >= 5:
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
	happy_label.text = "😊 Happy: %d" % happy_customers
	unhappy_label.text = "😠 Unhappy: %d" % unhappy_customers

func level_finished():
	print("🎉 Level completed with 5 happy customers!")
	# Add whatever you want here to finish the level, show message, etc.
