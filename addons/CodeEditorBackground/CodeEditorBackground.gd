@tool
extends EditorPlugin

var codes : Array = ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"]

var cse
var se
var defaultBackground : String = "res://addons/CodeEditorBackground/Background/Background.png"
var at = load("res://addons/CodeEditorBackground/BackgroundOptions.tscn")
var at_inst
signal setData

# 🔊 audio player
var audio_player : AudioStreamPlayer

var UserData : Dictionary = {
	"userBackground": "",
	"userTransparency": "1e",
	"randomFolder": "",
	"mode": 6,
	"OpacityValue": 30
}

func _enter_tree() -> void:
	var script_editor = get_editor_interface().get_script_editor()
	script_editor.connect("editor_script_changed", Callable(self, "_on_editor_script_changed"))
	script_editor.connect("resized", Callable(self, "ResizeBackground"))

	add_tool_menu_item("Change Background", Callable(self, "ShowWindow"))
	at_inst = at.instantiate()
	add_control_to_dock(2, at_inst)
	at_inst.connect("Transparency_Update", Callable(self, "set_transparency"))
	at_inst.connect("Update_Stretch", Callable(self, "Stretch_Update"))
	at_inst.connect("RandomBG", Callable(self, "RandomBackground"))
	at_inst.connect("SaveSettings", Callable(self, "SaveData"))
	at_inst.connect("ChangeBackground", Callable(self, "ShowWindow"))
	self.connect("setData", Callable(at_inst, "LoadingData"))

	# 🔊 setup audio player
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = load("res://addons/CodeEditorBackground/sfx/key_press.wav")
	add_child(audio_player)

	LoadData()

	# force apply once at startup
	call_deferred("_refresh_all_editors")


func _exit_tree() -> void:
	remove_tool_menu_item("Change Background")
	cse = get_editor_interface().get_script_editor().get_open_script_editors()
	remove_control_from_docks(at_inst)
	for all in cse:
		var code_edit = _get_code_edit(all)
		if code_edit and code_edit.get_child_count() >= 1:
			code_edit.get_child(0).queue_free()


# called when any script is switched/focused
func _on_editor_script_changed(script: Script) -> void:
	await get_tree().process_frame
	_refresh_all_editors()


func _refresh_all_editors() -> void:
	var editors = get_editor_interface().get_script_editor().get_open_script_editors()
	for e in editors:
		changed(null, e)


func changed(script: Script, editor: Control = null) -> void:
	cse = editor if editor != null else get_editor_interface().get_script_editor().get_current_editor()
	if cse == null:
		return

	var code_edit = _get_code_edit(cse)
	if code_edit == null:
		return

	se = code_edit

	# 🎹 connect keypress events
	if not se.is_connected("gui_input", Callable(self, "_on_editor_gui_input")):
		se.connect("gui_input", Callable(self, "_on_editor_gui_input"))

	# background setup
	var bg = TextureRect.new()
	if UserData["userBackground"] != "":
		var img = Image.new()
		if img.load(UserData["userBackground"]) == OK:
			var tex = ImageTexture.new()
			tex.set_image(img)
			bg.texture = tex
	else:
		bg.texture = load(defaultBackground)

	bg.set_stretch_mode(UserData["mode"])
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.self_modulate = Color("ffffff" + UserData["userTransparency"])
	bg.size = se.size
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# clear old backgrounds
	for child in se.get_children():
		if child is TextureRect:
			child.queue_free()
	se.add_child(bg)
	se.move_child(bg, 0)


func _get_code_edit(node: Node) -> TextEdit:
	for child in node.get_children():
		if child is TextEdit:
			return child
		var found = _get_code_edit(child)
		if found:
			return found
	return null


func ResizeBackground() -> void:
	if se and se.get_child_count() == 1:
		se.get_child(0).size = se.size


func ShowWindow() -> void:
	var w = load("res://addons/CodeEditorBackground/file_dialog.tscn").instantiate()
	w.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	w.size = Vector2(500, 300)
	w.title = "Choose an Image"
	add_child(w)
	w.connect("file_selected", Callable(self, "LoadImage"))


func LoadImage(path:String) -> void:
	UserData["userBackground"] = path
	changed(null)


func set_transparency(value:int) -> void:
	var ans = value / 16
	var rem = value % 16
	UserData["userTransparency"] = codes[ans] + codes[rem]
	UserData["OpacityValue"] = value
	changed(null)


func Stretch_Update(id: int) -> void:
	UserData["mode"] = id
	changed(null)


func RandomBackground(files: Array, path: String) -> void:
	UserData["userBackground"] = files.pick_random()
	UserData["randomFolder"] = path
	changed(null)


func SaveData() -> void:
	var f = FileAccess.open_encrypted_with_pass("res://addons/CodeEditorBackground/UserSettings.json", FileAccess.WRITE, "PoutineForEnlynn")
	f.store_line(JSON.stringify(UserData))
	print("User data stored at res://addons/CodeEditorBackground/UserSettings.json")


func LoadData() -> void:
	if FileAccess.file_exists("res://addons/CodeEditorBackground/UserSettings.json"):
		var f = FileAccess.open_encrypted_with_pass("res://addons/CodeEditorBackground/UserSettings.json", FileAccess.READ, "PoutineForEnlynn")
		var j = JSON.new()
		var parse_error = j.parse(f.get_as_text())
		if parse_error == OK:
			UserData = j.get_data()
			setLoadedData()


func setLoadedData() -> void:
	emit_signal("setData", UserData)


## 🎹 typing SFX
#func _on_editor_gui_input(event: InputEvent) -> void:
	#if event is InputEventKey and event.pressed and not event.echo:
		#if audio_player.playing:
			#audio_player.stop()
#
		#match event.keycode:
			#KEY_ENTER, KEY_KP_ENTER:
				#audio_player.pitch_scale = randf_range(0.8, 0.9)
				#audio_player.volume_db = -4.0
			#KEY_BACKSPACE:
				#audio_player.pitch_scale = randf_range(1.2, 1.3)
				#audio_player.volume_db = -2.0
			#KEY_SPACE:
				#audio_player.pitch_scale = randf_range(0.95, 1.05)
				#audio_player.volume_db = -4.0
			#_:
				#audio_player.pitch_scale = randf_range(0.9, 1.1)
				#audio_player.volume_db = -5.0
				#
		#audio_player.volume_db += randf_range(-10, -9.5)
		#audio_player.play()
