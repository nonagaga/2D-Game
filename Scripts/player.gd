extends CharacterBody2D


@export var SPEED = 300.0

#Jump Variables

@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float

@onready var jump_velocity : float = -1 * ((2.0 * jump_height) / jump_time_to_peak)
@onready var jump_gravity : float = -1 * ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak))
@onready var fall_gravity : float =  -1 * ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent))

var jump_timer = 0.0
var coyote_timer = 0.0


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += get_gravity() * delta
		coyote_timer -= delta
	else:
		coyote_timer = 0.1

	if Input.is_action_just_pressed("jump"):
		jump_timer = 0.1
	jump_timer -= delta

	if jump_timer > 0 and coyote_timer > 0:
		velocity.y = jump_velocity
		jump_timer = 0
		coyote_timer = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func get_gravity():
	return jump_gravity if velocity.y < 0 else fall_gravity
