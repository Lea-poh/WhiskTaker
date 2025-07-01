extends CharacterBody2D

const SPEED = 500
const GRAVITY = 1000
const JUMP_FORCE = -500
var carried_dish = null
var cupboard: Node
var has_jumped_in_air = false
var delta_since_on_ground = 0 

func _ready():
	cupboard = get_parent().get_node_or_null("IngredientsCupboard")
	if cupboard == null:
		print("❌ Couldn't find IngredientsCupboard")

func _physics_process(delta):
	velocity.y += GRAVITY * delta

	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = direction * SPEED

	# Flip sprite if needed
	if direction != 0:
		$AnimatedSprite2D.flip_h = direction < 0
		
	if is_on_floor():
		delta_since_on_ground = 0
		has_jumped_in_air = false
	else:
		delta_since_on_ground += delta

	# Jumping
	if Input.is_action_just_pressed("ui_accept"):
		if delta_since_on_ground < 0.5:
			velocity.y = JUMP_FORCE
			delta_since_on_ground = 0.5
		elif not has_jumped_in_air:
			velocity.y = JUMP_FORCE
			has_jumped_in_air = true

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

func pick_up_dish(dish: Node2D):
	if carried_dish != null:
		return

	carried_dish = dish

	# Option 1: Remove the RigidBody2D completely
	var physics_body = dish.get_node_or_null("RigidBody2D")
	if physics_body:
		physics_body.queue_free()

	# Reparent dish to holder
	var holder = $DishHolder
	if dish.get_parent():
		dish.get_parent().remove_child(dish)
	holder.add_child(dish)

	# Snap to position
	dish.global_position = holder.global_position

	# ⚠️ Call _on_pickup() deferred so it's safe and after physics is cleaned up
	dish.call_deferred("_on_pickup")

	#print("🍽️ Dish picked up!")

func _deferred_remove_dish(table: Node, spot_name: String):
	table._on_dish_removed(spot_name)

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
		#print("✅ Dish delivered!")
