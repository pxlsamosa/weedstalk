extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerData.counter_updated.connect(_on_update)

func _on_update():
	update_label()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_label():
	text = str(PlayerData.total_plant_counter)
