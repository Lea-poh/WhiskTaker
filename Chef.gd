extends CharacterBody2D

const SPEED = 400
const GRAVITY = 700
const JUMP_FORCE = -500
var carried_dish = null

@onready var cupboard = get_node("/root/Main/IngredientsCupboard")  # Adjust path as needed

func _ready():
	# Nothing required here for now unless you want debug output
	pass

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

func collect_egg(egg):
	cupboard.add_egg()
	egg.queue_free()
	
func has_dish() -> bool:
	return carried_dish != null

func pick_up_dish(dish: Node2D) -> void:
	if carried_dish != null:
		return

	carried_dish = dish
	var body = dish.get_node("RigidBody2D")
	var dish_holder = get_node("DishHolder")

	if body:
		# Correct enum and deferred call
		body.set_deferred("mode", PhysicsServer2D.BODY_MODE_STATIC)
		body.set_deferred("gravity_scale", 0)
		body.set_deferred("linear_velocity", Vector2.ZERO)
		body.set_deferred("angular_velocity", 0)
		body.set_deferred("sleeping", true)

	# Reparent after physics changes are scheduled
	if dish.get_parent():
		dish.get_parent().remove_child(dish)
	dish_holder.add_child(dish)

	# Set local position inside DishHolder
	dish.call_deferred("set_position", Vector2.ZERO)

	print("🍽️ Dish picked up!")




# Add this to dish.gd (or attach dynamically if you prefer)
func _set_global_position(pos: Vector2) -> void:
	global_position = pos

func drop_dish():
	if carried_dish == null:
		return

	var body = carried_dish.get_node("RigidBody2D")
	if body:
		# Restore physics
		body.set_deferred("mode", PhysicsServer2D.BODY_MODE_RIGID)
		body.set_deferred("gravity_scale", 1.0)
		body.set_deferred("sleeping", false)

	# Reparent the dish back to the world (or wherever appropriate)
	var world = get_tree().get_root().get_node("Main")  # Adjust if needed
	var drop_direction = -1 if $AnimatedSprite2D.flip_h else 1
	var drop_position = global_position + Vector2(30 * drop_direction, 0)

	if carried_dish.get_parent():
		carried_dish.get_parent().remove_child(carried_dish)
	world.add_child(carried_dish)
	carried_dish.global_position = drop_position

	carried_dish = null
	print("🥄 Dish dropped.")

func deliver_dish():
	if carried_dish:
		carried_dish.queue_free()
		carried_dish = null
		print("✅ Dish delivered!")
