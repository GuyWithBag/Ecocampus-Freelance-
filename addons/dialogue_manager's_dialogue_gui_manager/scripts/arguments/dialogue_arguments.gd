@tool
extends SaveableResource
class_name DialogueArguments

@export var dialogue_gui: DialogueGUI.DialogueGUIAlias
@export var dialogue_resource: DialogueResource
@export var main_speakers: Array[Entity]
@export var title: String: 
	get: 
		return title.to_snake_case()
@export var extra_game_states: Array = []
@export var title_variation: int = 0: 
	set(value): 
		title_variation = clamp(value, 0, 99)
@export var reset_when_title_variation_reached: bool = false

@export var is_dialogue_game_state: bool = true 

var played_count: int

func set_main_speaker(value: Array[Entity]) -> DialogueArguments:
	main_speakers = value
	return self


func set_dialogue_resource(value: DialogueResource) -> DialogueArguments:
	dialogue_resource = value
	return self


func set_title(value: String) -> DialogueArguments:
	title = value
	return self


func set_extra_game_states(value: Array) -> DialogueArguments:
	extra_game_states = value
	return self


func add_extra_game_states(value: Array) -> DialogueArguments:
	extra_game_states.append_array(value)
	return self


func set_title_variation(value: int) -> DialogueArguments:
	title_variation = value
	return self


func set_is_dialogue_game_state(value: bool) -> DialogueArguments:
	is_dialogue_game_state = value
	return self


func set_reset_when_title_variation_reached(value: bool) -> DialogueArguments:
	reset_when_title_variation_reached = value
	return self


func _save_properties() -> PackedStringArray: 
	return [
		"extra_game_states", 
		"dialogue_gui", 
		"dialogue_resource", 
		"main_speakers", 
		"title", 
		"title_variation", 
		"reset_when_title_variation_reached", 
		"is_dialogue_game_state"
	]
