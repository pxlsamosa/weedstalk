extends Node2D

@onready var sprite = $AnimatedSprite2d

func _ready():
	sprite.play("idle")
