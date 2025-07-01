extends CharacterBody2D

@export var EggScene: PackedScene

@export var speed := 300.0
@export var gravity := 700.0
@export var jump_force := -500.0
@export var jump_chance := 0.5  # 2% chance to jump per cooldown
@export var jump_cooldown := 1.5  # Seconds between jump attempts

@onready var wait_bar = $WaitBar  # Adjust path if needed
@export var wait_time := 40 # before customer leaves
var wait_elapsed := 0.0


var direction := -1  # Start moving left
var jump_timer := 0.0
var is_jumping := false
var has_left := false 

signal happy_leave
signal unhappy_leave


func _ready():
	randomize()

func _physics_process(delta):
	if has_left:
		return
	
	# Apply gravity
	velocity.y += gravity * delta

	# Ground + wall checks
	$GroundCheck.position.x = direction * 30
	#$GroundCheck.target_position = Vector2(0, 20)

	#$WallCheck.position.x = direction * 10
	$WallCheck.target_position = Vector2(direction * 75, 0)

	var at_edge = not $GroundCheck.is_colliding()
	var hit_wall = $WallCheck.is_colliding()

	# Turn around if at edge or hit wall
	if is_on_floor():
		if hit_wall:
			direction *= -1
			velocity.y = jump_force
			is_jumping = true
		elif at_edge:
			direction *= -1

	# Handle random jumping
	if is_on_floor():
		jump_timer -= delta
		if jump_timer <= 0:
			if randf() < jump_chance:
				velocity.y = jump_force
				is_jumping = true
			jump_timer = jump_cooldown

		# Stop jump state once back on ground and falling
		if velocity.y >= 0:
			is_jumping = false

	# Horizontal movement
	if is_jumping:
		velocity.x = direction * speed * 1.5
	else:
		velocity.x = direction * speed

	move_and_slide()

		# Animation switching
	if not is_on_floor():
		$AnimatedSprite2D.play("jump") # Or "jump" if you have one
	elif direction != 0:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")
		
	wait_elapsed += delta
	var remaining = clamp((wait_time - wait_elapsed) / wait_time, 0.0, 1.0)
	wait_bar.value = remaining * 100
	if wait_elapsed >= wait_time:
		#print("😠 Customer left unhappy...")
		leave_unhappy()


func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		var chef = area.get_parent()
		if chef.carried_dish != null:
			#print("🍳 Dish received!")
			chef.deliver_dish()
			handle_dish_received()

func handle_dish_received():
	print("We got a happy customer!")
	emit_signal("happy_leave")  # Emit signal to notify main scene
	$AnimatedSprite2D.play("happy")
	await get_tree().create_timer(1).timeout
	queue_free()  # Customer leaves

func leave_unhappy():
	if has_left:
		return
	has_left = true

	# Play animation, delay removal, etc.
	$AnimationPlayer.play("unhappy")

	await get_tree().create_timer(1.0).timeout
	emit_signal("unhappy_leave")
	queue_free()
