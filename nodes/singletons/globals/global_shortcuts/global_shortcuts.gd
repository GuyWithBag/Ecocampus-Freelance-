extends Node

@export var to_main_menu: ChangeSceneComponent

func _input(event: InputEvent) -> void: 
	if event.is_action_pressed("open_customize_character_screen"): 
		GUIManager.toggle_gui(GUIManager.customize_character_screen) 
		
	elif event.is_action_pressed("reset_game"): 
		GlobalData.achievements_tracker.show_victory_screen()

	elif event.is_action_pressed("back"): 
		var back = get_tree().get_first_node_in_group("BackRequest")
		if back != null: 
			back.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	
	elif event.is_action_pressed("skip_dialogue"): 
		if GUIManager.dialogue_gui_manager.is_visible_in_tree(): 
			GUIManager.dialogue_gui_manager.current_dialogue_gui.next()

	elif event.is_action_pressed("god_mode"): 
		GlobalData.achievements_tracker.medals.points.add(999)
	
	elif event.is_action_pressed("deactivate_cutscene"): 
		GUIManager.set_gui_active(VideoCutscenePlayer.this(), false)
		
		
