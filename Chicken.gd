extends CharacterBody2D

@export var EggScene: PackedScene

@export var speed := 100.0
@export var gravity := 400.0
@export var jump_force := -400.0
@export var jump_chance := 0.8  # 2% chance to jump per cooldown
@export var jump_cooldown := 1.5  # Seconds between jump attempts

var direction := -1  # Start moving left
var jump_timer := 0.0
var is_jumping := false

func _ready():
	randomize()

func _physics_process(delta):
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
	
	# Laying eggs
	if is_jumping and randf() < 0.005:
		drop_egg()

	move_and_slide()

	# Flip sprite based on direction
	$AnimatedSprite2D.flip_h = direction > 0
	if $AnimatedSprite2D.animation != "move":
		$AnimatedSprite2D.play("move")
		
func drop_egg():
	if EggScene:
		var egg = EggScene.instantiate()
		get_parent().add_child(egg)
		egg.global_position = global_position + Vector2(0, 10)
