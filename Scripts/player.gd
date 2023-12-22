extends CharacterBody2D

@export_group("Speed Variables")
@export var MAX_SPEED : float = 30.0
@export var ACCELERATION : float = 5.0
#Wall slide Variables
@export_group("Wall Interactions")
@export var wall_slide_accel : float = 1
@export var wall_slide_max_speed : float = 20
@export var wall_jump_multiplier : float = 5

#Jump Variables
@export_group("Jump Variables")
@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float
@export var shorthop_velocity_decrease : float

@export_subgroup("Jump Timers")
@export var jump_buffer_length : float = 0.1
@export var coyote_timer_length : float = 0.1

var jump_buffer_timer : float = 0.0
var coyote_timer : float = 0.0

@onready var jump_velocity : float = -1 * ((2.0 * jump_height) / jump_time_to_peak)
@onready var jump_gravity : float = -1 * ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak))
@onready var fall_gravity : float =  -1 * ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent))



var wall_slide : float = false

func _physics_process(delta):
	#DEBUG CODE TO VISUALISE JUMP TIMINGS
	if can_jump():
		modulate = Color(0, 255, 0)
	elif !can_jump():
		modulate = Color(255, 0, 0)
	#END OF DEBUG CODE
	
	#Handling gravity and the players ability to jump ALSO WALL SLIDING ;-;
	#Chekcs if the player is holding into a wall
	if is_on_wall() && (Input.is_action_pressed("left")||Input.is_action_pressed("right")) && !is_on_floor():
		coyote_timer = coyote_timer_length
		#Checks if the player is falling then slows it to the slide
		if velocity.y >= 0:
			wall_slide = true
			velocity.y = min(velocity.y + wall_slide_accel, wall_slide_max_speed)
			coyote_timer = coyote_timer_length
		else:
			velocity.y += get_gravity() * delta
	#Handles gravity and jumping when not on a wall
	elif !is_on_floor():
		velocity.y += get_gravity() * delta
		coyote_timer -= delta
	else:
		coyote_timer = coyote_timer_length
		
	
	#Sets jump timer to account for input buffering
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_length
	jump_buffer_timer -= delta
	
	#jump_buffer_timer essentially replaces the input mapping for jump to account for input buffering
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_velocity
		if is_on_wall_only():
			if(Input.is_action_pressed("left")):
				velocity.x += wall_jump_multiplier * MAX_SPEED
			if(Input.is_action_pressed("right")):
				velocity.x -= wall_jump_multiplier * MAX_SPEED
		disable_jump()
	
	#Controls how the variable jump height/short hop works
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y += shorthop_velocity_decrease
	
	
	
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")
	#If the player is holding left or right
	if direction:
		#If the player is holding left
		if direction < 0:
			#If the velocity is less than the max speed in that direction, speed them up to the max speed
			if velocity.x > -1 * MAX_SPEED:
				velocity.x = max(velocity.x + (ACCELERATION * direction), -1 * MAX_SPEED)
			#If the velocity is more than the max speed in that direction, slow them down less
			else:
				velocity.x = move_toward(velocity.x, 0, get_friction() * ACCELERATION/4)
		#If the player is holding right
		if direction > 0:
			#If the velocity is less than the max speed in that direction, speed them up to the max speed
			if velocity.x < MAX_SPEED:
				velocity.x = min(velocity.x + (ACCELERATION * direction), MAX_SPEED)
			#If the velocity is more than the max speed in that direction, slow them down less
			else:
				velocity.x = move_toward(velocity.x, 0, get_friction() * ACCELERATION/4)
	#If the player is NOT holding left or right, slow them down by ACCELERATION/2
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION/2)

	move_and_slide()

#Pretty Self Explanitory
func get_gravity():
	return jump_gravity if velocity.y < 0 else fall_gravity

func get_friction():
	if is_on_floor():
		return 1.0
	else:
		return 0.0
#Honestly disabling jump_buffer_timer is kinda optional here but whatever
func disable_jump():
	coyote_timer = 0.0
	jump_buffer_timer = 0.0

#Returns true if the player can jump and false if it cannot
func can_jump():
	return true if coyote_timer > 0 else false
