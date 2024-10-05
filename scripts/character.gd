extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = 500.0
const GRAVITY_FORCE = -5000.0 # The force pulling towards the center
const SPHERE_RADIUS = 5000.0 # Adjust this to match your sphere size
const SLIDE_THRESHOLD = 5.0 # Threshold to stop the character from sliding

var sphere_center = Vector2(0, 0) # Center of the sphere

func _physics_process(delta: float) -> void:
	# Calculate the direction from the character to the sphere's center
	var to_center = (sphere_center - global_position).normalized()

	# Apply gravity towards the center of the sphere
	if not is_on_floor():
		velocity -= to_center * GRAVITY_FORCE * delta
	
	# Ensure the character stays on the surface by adjusting its distance from the center
	var distance_to_center = global_position.distance_to(sphere_center)
	if distance_to_center > SPHERE_RADIUS:
		var correction_vector = (sphere_center - global_position).normalized() * (distance_to_center - SPHERE_RADIUS)
		global_position += correction_vector * delta
	
	# Handle jumping, which pushes the character away from the center
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity -= to_center * JUMP_VELOCITY

	# Handle movement along the surface (tangential to the sphere)
	var direction = Input.get_axis("ui_right", "ui_left")
	if direction:
		# Get the tangent to the sphere at the current position
		var tangent = Vector2(-to_center.y, to_center.x)
		velocity.x = tangent.x * direction * SPEED
		velocity.y = tangent.y * direction * SPEED
	else:
		# Slow down the character's movement gradually when no input is given
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		velocity.y = move_toward(velocity.y, 0, SPEED * delta)

		# Stop sliding when the velocity is below the threshold
		if velocity.length() < SLIDE_THRESHOLD:
			velocity = Vector2.ZERO

	# Align the sprite's rotation with the surface of the sphere
	rotation = to_center.angle() - PI / 2  # Adjust the rotation of the sprite

	# Move the character based on the calculated velocity
	move_and_slide()
	
