extends TextureButtonPlus
class_name SettingsIconButton

@export var icon: TextureRect

static func this() -> SettingsIconButton: 
	return GameManager.get_tree().get_first_node_in_group("SettingsIconButton")


func _on_pressed() -> void:
	GUIManager.toggle_gui(GUIManager.settings_menu)
	update()
	if !GUIManager.settings_menu.visibility_changed.is_connected(_on_visibility_changed):
		GUIManager.settings_menu.visibility_changed.connect(_on_visibility_changed)
	
	
func _on_visibility_changed() -> void: 
	update()
	
	
func update() -> void: 
	icon.visible = !GUIManager.settings_menu.is_visible_in_tree()
	close_icon.visible = GUIManager.settings_menu.is_visible_in_tree()
