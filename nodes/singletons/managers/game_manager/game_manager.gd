extends Node

#Reason why the state tree is weird is because I had to implement the history state. 

@export var cosmetics_collection: CosmeticsCollection
@export var achievements_collection: AchievementsCollection

@export var state_chart: StateChart
@export var to_map_picker: ChangeSceneComponent
@export var to_select_character: ChangeSceneComponent
@export var playing_state: AtomicState
@export var paused_state: CompoundState
@export var main_menu_state: AtomicState
@export var map_picker_state: AtomicState
@export var assesment_state: AtomicState
@export var customize_character_state: AtomicState
@export var dialogue_state: AtomicState
@export var main_screen_state: CompoundState
@export var history_state: HistoryState
@export var dialog_state: CompoundState

@export var menu_music: AudioManagerPlayer
@export var playing_music: AudioManagerPlayer
@export var print_color: PrintColor: 
	set(value): 
		print_color = value
		print_color.owner = self

var enable_player_on_playing_entered: bool = true: 
	set(value): 
		enable_player_on_playing_entered = value
		if enable_player_on_playing_entered: 
			PlayerManager.player.state_chart.send_event("enabled")

var faucets_show: bool

func show_quest_entities() -> void: 
	for node: Node in get_tree().get_nodes_in_group("QuestEntity"): 
		node.show()
		await get_tree().create_timer(0.05).timeout
		

func start() -> void: 
	if SaveManager.save_files_is_empty(): 
		to_select_character.change()
	else: 
		to_map_picker.change()


func is_playing() -> bool: 
	return playing_state.active


func is_paused() -> bool: 
	return paused_state.active


func _on_playing_state_entered() -> void: 
	await get_tree().process_frame
	if AudioManager.music_player.stream != null && AudioManager.music_player.stream.resource_path != playing_music.audio.get_sound_path(): 
		playing_music.play()
	if enable_player_on_playing_entered: 
		if PlayerManager.player: 
			PlayerManager.player.state_chart.send_event("enabled")


func _on_main_menu_state_entered() -> void:
	menu_music.play()


func _on_playing_state_exited() -> void: 
	if PlayerManager.player: 
		PlayerManager.player.state_chart.send_event("disabled")


func _on_state_chart_event_received(event: StringName) -> void:
	print_color.out_debug_wvalue("State chart event received", event)


func _on_dialogue_state_entered() -> void:
	PlayerManager.player.state_chart.send_event("disabled")


func _on_map_picker_state_entered() -> void:
	pass # Replace with function body.


## _notification doesn't work with mobile??
func is_close_request(what: int) -> bool: 
	return what == NOTIFICATION_WM_CLOSE_REQUEST || what == NOTIFICATION_CRASH || what == NOTIFICATION_APPLICATION_PAUSED || what == DisplayServer.WINDOW_EVENT_CLOSE_REQUEST


func reset_all_data() -> void: 
	ExtendedQuestSystem.reset_all()
	cosmetics_collection.reset()
	achievements_collection.reset()
	PlayerManager.player_data.reset()
	GlobalData.achievements_tracker.reset()
	SaveManager.remove_save_file("save_file_1")
	SaveManager.current_saved_data = GameSave.new()
	GUIManager.reset()
	state_chart.send_event("main_menu")
	faucets_show = false


func _on_history_state_state_entered() -> void:
	print_color.out_debug_wvalue("History state", history_state.history)


func _on_history_state_event_received(_event: StringName) -> void:
	print_color.out_debug_wvalue("History state", history_state.history)
