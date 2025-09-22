extends Node2D

@onready var sprite = $AnimatedSprite2d #this is how you reference nodes from the scene tree
@onready var label: Label = $Label

var plant_amount : int = 0 #this is how you make variables

func _ready(): 
	label.text = str(plant_amount) #set the labels text to 0
	sprite.play("idle")


#this checks for a left mouse click on the area2d node
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Clicked on Plant!") #this prints to the output log
		
		scale *= Vector2(1.1, 1.1) # we clicked on the plant, so let's scale it 1.1x to make it pop a bit
		await get_tree().create_timer(0.25).timeout #this creates a timer, so it stays scaled for quarter second
		plant_amount += 1 # then we raise plant_amount by one
		label.text = str(plant_amount) #set the label to the plant amount which is now one higher
		scale = Vector2(1, 1) # this resets our scale back to default
