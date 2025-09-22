extends Node2D

@onready var sprite = $AnimatedSprite2d
@onready var label: Label = $Label

var plant_amount : int = 0

func _ready():
	label.text = str(plant_amount)
	sprite.play("idle")



func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Clicked on Plant!")
		plant_amount += 1
		label.text = str(plant_amount)
