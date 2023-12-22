extends CharacterBody2D

@export var boom_force : float = 10.0

@onready var boom_area : Area2D = $"Boom Trigger"
@onready var boom_timer : Timer = $"Boom Timer"
@onready var boom_light : PointLight2D = $"Boom Light"


var exploding : bool = false

func _on_boom_trigger_body_entered(body):
	if exploding:
		return
	if body.name == "Player":
		boom_timer.start()
		exploding = true
		var tween : Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "modulate", Color(255,0,0),1)
		tween.tween_property(boom_light, "color", Color(3,0,0),1)


func _on_boom_timer_timeout():
	for body in boom_area.get_overlapping_bodies():
		if body.name == "Player":
			var dist = body.global_position - global_position
			
			body.velocity += dist.normalized()*(boom_force/dist.length())
			body.velocity += dist.normalized()*(boom_force - ((boom_force/2)/$"Boom Trigger/CollisionShape2D".shape.radius) * dist.length())
			
			body.disable_jump()
	queue_free()
