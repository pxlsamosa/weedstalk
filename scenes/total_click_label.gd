extends RichTextLabel


func _ready() -> void:
	PlayerData.counter_updated.connect(_on_update)

func _on_update():
	update_label()


func update_label():
	text = str(PlayerData.total_plant_counter)
