extends ColorRect

@export var player : CharacterBody2D
func _process(_delta):
	position = player.position - Vector2(size.x/2, size.y/2)
