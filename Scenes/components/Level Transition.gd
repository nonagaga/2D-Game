extends Area2D



@export var destination = preload("res://Scenes/Levels/level_0.tscn")
@onready var dest:String = destination.resource_path

func _on_body_entered(body):
	if(body == $"../Player"):
		print(destination)
		get_tree().change_scene_to_file(dest)
