@tool
extends DialogGUI
class_name InteractDialog

@export var body: Control


@export var rich_description_label: RichTextLabel
@export var description_label: FormattedLabel
@export var ok_button: TextureButtonPlus

@export var empty_button_texture: Texture2D

var data: InteractDialogData

static func display(args: InteractDialogData) -> InteractDialog: 
	var gui: InteractDialog = GUICollection.interact_dialogue.instantiate()
	#print(_caller)
	gui.data = args
	
	const limit = 300
	if gui.data.gui_position.y <= limit: 
		gui.global_position = Vector2(gui.data.gui_position.x, gui.data.gui_position.y + limit)
	else: 
		gui.global_position = gui.data.gui_position
	
	if gui.global_position.x < GlobalVariables.viewport_size.x / 2: 
		gui.body.pivot_offset = gui.body.size / 2
		gui.body.position.x += 700
	
	if gui.data.description is LabelText: 
		gui.data.description.set_label(gui.description_label)
		
	elif gui.data.description is RichLabelText: 
		gui.data.description.set_label(gui.rich_description_label)
		gui.rich_description_label.show()
		gui.description_label.hide()
		
	GUIManager.add_gui(gui)
	
	if !args.custom_ok_text.is_empty(): 
		gui.ok_button.label.text = args.custom_ok_text
		gui.ok_button.texture_normal = gui.empty_button_texture
		
		
	gui.data.caller.state_chart.send_event("disabled")
	return gui


func _on_medium_wooden_button_pressed() -> void:
	data.on_button_pressed.call()
	_close()


func _deactivated() -> void: 
	_close()


func _close() -> void: 
	queue_free()
	if GameManager.is_playing(): 
		data.caller.state_chart.send_event("enabled")
