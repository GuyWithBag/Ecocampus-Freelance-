@tool
extends GUI
class_name DialogueGUI

## Used for DialogueArguments
enum DialogueGUIAlias {
	RETAIN_LAST_DIALOGUE, 
	DIALOGUE_BOX, 
	TITLE_CARD, 
}


@export var dialogue_gui_alias: DialogueGUIAlias
@export var character_label: RichTextLabel
@export var responses_menu: DialogueResponsesMenu
@export var dialogue_label: DialogueLabel
@export var show_fast_forward_button_after_first_intereaction: bool

@export var speaker_sprites_switcher: SpeakerSpritesSwitcher

@export var dialogue_text_preset: String = "%s"
@export var hide_character_text: bool
@export var character_text_preset: String = "%s"

@export var print_color: PrintColor: 
	set(value): 
		print_color = value
		print_color.owner = self

@export var fast_forward_speed: float = 2
@export var typing_audio: AudioManagerPlayer
@export var skip_button: Button
@export var skip_typing_button: Button

var current_arguments: DialogueArguments
var text_speed_multiplier: float = 1
var auto_play: bool

var dialogue_container_input_disabled: bool = false

## The dialogue resource
var resource: DialogueResource

## See if we are waiting for the player
var is_waiting_for_input: bool = false

var is_emoting: bool 

## See if we are running a long mutation and should hide the balloon
## Only set this in DialogueGUIManager
var will_hide_balloon: bool = false: 
	set(value): 
		will_hide_balloon = value

var dialogue_line: DialogueLine:
	set(next_dialogue_line): 
		#if !is_node_ready(): 
			#await ready
		#printerr(next_dialogue_line)
		if not next_dialogue_line: 
			if will_hide_balloon: 
				GUIManager.set_gui_active(GUIManager.dialogue_gui_manager, false)
			return
		elif !GUIManager.dialogue_gui_manager.active: 
			GUIManager.set_gui_active(GUIManager.dialogue_gui_manager, true)
		print_color.out_debug_wvalue("dialogue playing", next_dialogue_line)

		is_waiting_for_input = false
		
		dialogue_label.finished_typing.connect(
			func(): 
				await get_tree().create_timer(0.7).timeout
				if !is_emoting: 
					speaker_sprites_switcher.set_current_speaker_rect_texture(speaker_sprites_switcher.get_speaker_idle_sprite(dialogue_line.character))
		, CONNECT_ONE_SHOT
		)
		
		dialogue_line = next_dialogue_line
		speed_up_line(dialogue_line, text_speed_multiplier)
		
		## Sets the speaker icon. 
		if speaker_sprites_switcher.is_main_speaker(dialogue_line.character): 
			speaker_sprites_switcher.speaker = SpeakerSpritesSwitcher.Speaker.MAIN
		else: 
			speaker_sprites_switcher.speaker = SpeakerSpritesSwitcher.Speaker.SECONDARY
		
		if !is_emoting: 
			speaker_sprites_switcher.set_current_speaker_rect_texture(speaker_sprites_switcher.get_speaker_idle_sprite(dialogue_line.character))
		
		# Flips sprite
		if !speaker_sprites_switcher.is_main_speaker(dialogue_line.character): 
			var speaker: Entity = speaker_sprites_switcher.get_speaker(dialogue_line.character)
			speaker_sprites_switcher.current_speaker_rect.flip_h = !speaker.facing_left
		
		get_tree().create_timer(0.1).timeout.connect(
			func(): 
				if !is_emoting: 
					speaker_sprites_switcher.set_current_speaker_rect_texture(speaker_sprites_switcher.get_speaker_talk_sprite(dialogue_line.character))
		)
		
		next_dialogue_line.text = dialogue_text_preset % next_dialogue_line.text
		#speed_up_line(dialogue_line, GUIManager.dialogue_gui_manager.text_speed_multiplier)
		if character_label != null: 
			#var character_label = character_label
			if hide_character_text: 
				character_label.visible =  false
			else: 
				character_label.visible = not dialogue_line.character.is_empty()
				character_label.text = character_text_preset % dialogue_line.character
		#dialogue_label.modulate.a = 0
		dialogue_label.custom_minimum_size.x = dialogue_label.get_parent().size.x - 1
		dialogue_label.dialogue_line = dialogue_line
		
		responses_menu.hide()
		responses_menu.set_responses(dialogue_line.responses)
		
		# Show our balloon
		show()
		#will_hide_balloon = false
		
		dialogue_label.show()
		if not dialogue_line.text.is_empty():
			dialogue_label.type_out()
			await dialogue_label.finished_typing
			
		if auto_play: 
			dialogue_line.time = "auto"
			
		# Wait for input
		if dialogue_line.responses.size() > 0:
			focus_mode = Control.FOCUS_NONE
			responses_menu.show()
		# Time related stuff

		elif dialogue_line.time != "": 
			var time: float = 0
			if dialogue_line.time == "auto": 
				time = (dialogue_line.text.length() * 0.02 ) / text_speed_multiplier
			else:
				time = dialogue_line.time.to_float() / text_speed_multiplier
			#time = 0.2
			await get_tree().create_timer(time).timeout
			next_from_id(dialogue_line.next_id)
		else: 
			is_waiting_for_input = true
			focus_mode = Control.FOCUS_ALL
			grab_focus()
			
			
func start(arguments: DialogueArguments, title_variation_counter: PointCounterComponent) -> void: 
	var dialogue_resource: DialogueResource = arguments.dialogue_resource
	var title: String = arguments.title 
	var extra_game_states: Array = arguments.extra_game_states 
	var title_variation: int = arguments.title_variation
	
	arguments.played_count += 1
	current_arguments = arguments
	#var is_dialogue_game_state: bool = arguments.is_dialogue_game_state
	
	var plus_game_states: Array = [self] + extra_game_states
	
	## Speaker Sprites
	speaker_sprites_switcher.main_speakers = arguments.main_speakers
	
	is_waiting_for_input = false
	resource = dialogue_resource
	# My implementation of title variety
	title_variation_counter.points.reset_after_maximum_hit = arguments.reset_when_title_variation_reached
	title_variation_counter.points.when_maximum_stay = !arguments.reset_when_title_variation_reached
	if title_variation > 0: 
		title_variation_counter.points.maximum = title_variation
		if title_variation_counter.points.current > 0: 
			title = title + "_var_%s" % title_variation_counter.points.current
		title_variation_counter.points.increment()
		
		
	self.dialogue_line = await resource.get_next_dialogue_line(title, plus_game_states)
	#if is_instance_valid(CutsceneManager.cutscene_player): 
		#CutsceneManager.cutscene_player.pause()
	
	
# This gets called even with the [auto] mutation. 
## Go to the next_from_id line
func next_from_id(next_id: String) -> void: 
	self.dialogue_line = await resource.get_next_dialogue_line(next_id, dialogue_line.extra_game_states)
	
	
func next() -> void: 
	next_from_id(dialogue_line.next_id)
	
	
func _on_balloon_gui_input(event: InputEvent) -> void: 
	#if dialogue_container_input_disabled: 
		#return
	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed("ui_cancel")
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()
	#print(get_viewport().gui_get_focus_owner())
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		next_from_id(dialogue_line.next_id)
	elif event.is_action_pressed("ui_accept") and get_viewport().gui_get_focus_owner() == self:
		next_from_id(dialogue_line.next_id)
		
		
		
# TODO: THIS IS WHERE THE INFINFINITE RECURSION HAPPENS! 
func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	# FIRST
	#next_id_from_response = response.next_id
	#printerr(response.next_id)
	#printerr(response.next_id)
	next_from_id(response.next_id)
	#print(await resource.get_next_dialogue_line(response.next_id, temporary_game_states))
	#printerr(response.next_id)
	pass
	
	#if will_stop: 
		#stopped = true


func _on_fast_forward_toggled(toggled_on: bool) -> void: 
	if toggled_on: 
		text_speed_multiplier = fast_forward_speed
	else: 
		text_speed_multiplier = 1


# FIXME: BUGGED
func _on_auto_play_toggled(toggled_on: bool) -> void:
	auto_play = toggled_on
	#if auto_play: 
		#if dialogue_label.is_typing: 
			#dialogue_label.finished_typing.connect(
				#func(): 
					#next_from_id(dialogue_line.next_id)
			#, CONNECT_ONE_SHOT
			#)


func _on_skip_pressed() -> void:
	next_from_id(dialogue_line.next_id)


func _on_cancel_pressed() -> void:
	dialogue_line = null


func speed_up_line(line: DialogueLine, multiplier: float) -> void: 
	line.speeds[0] = multiplier
	for key: int in line.speeds.keys(): 
		#line.speeds[i] *= multiplier
		#print(key)
		line.speeds[key] *= multiplier


func _on_dialogue_label_spoke(letter: String, _letter_index: int, _speed: float) -> void:
	if is_visible_in_tree(): 
		typing_audio.play()


func set_sprite_to_sad() -> void: 
	is_emoting = true
	speaker_sprites_switcher.set_current_speaker_rect_texture(speaker_sprites_switcher.get_speaker_sad_sprite(dialogue_line.character))
	
	
func set_sprite_to_idle() -> void: 
	is_emoting = false
	speaker_sprites_switcher.set_current_speaker_rect_texture(speaker_sprites_switcher.get_speaker_idle_sprite(dialogue_line.character))


func _on_skip_typing_pressed() -> void:
	dialogue_label.skip_typing()
	
	
func _process(delta: float) -> void: 
	if !current_arguments:
		return 
		
	if current_arguments.played_count > 1:
		if dialogue_label.is_typing: 
			skip_typing_button.show()
			skip_button.hide()
		else:
			skip_button.show()
			skip_typing_button.hide()
	else:
		skip_typing_button.hide()
		skip_button.hide()
	
	
	
