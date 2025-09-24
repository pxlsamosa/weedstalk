extends Node
#PlayerData.gd global autoload

@export var total_plant_counter : int = 0 

signal counter_updated

func update_click_count():
	total_plant_counter += 1
	emit_signal("counter_updated")
