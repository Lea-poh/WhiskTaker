extends CharacterBody2D

const SPEED = 400
const GRAVITY = 700
const JUMP_FORCE = -500

func _physics_process(delta):
	velocity.y += GRAVITY * delta

	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = direction * SPEED

	# Flip sprite if needed
	if direction != 0:
		$AnimatedSprite2D.flip_h = direction < 0

	# Jumping
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_FORCE

	# Animation switching
	if not is_on_floor():
		$AnimatedSprite2D.play("default") # Or "jump" if you have one
	elif direction != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")

	move_and_slide()
