@tool
extends CharacterBody2D
class_name EntityNode

signal starting_interact
signal interacted


@export var lock_size: bool: 
	set(value): 
		lock_size = value
		if !is_node_ready(): 
			await ready
		two_point_5d_node_simulator.disabled = lock_size
		
@export var node_variety_index: int: 
	set(value): 
		node_variety_index = value
		if !is_node_ready(): 
			await ready
		node_variety_manager.index = node_variety_index
		
@export var display_interact_dialog: bool = true
@export var wait_for_player_to_come: bool = true
@export var only_display_interact_dialog_once: bool = false

@export var faucets_show: bool

## IF true, player can move to this position
@export var player_is_move_to_position: bool = true

@export var interact_audio: AudioStreamPlayerArguments: 
	set(value): 
		interact_audio = value
		if !is_node_ready(): 
			await ready
		if interact_audio: 
			interact_audio_player.audio = interact_audio
		
@export var on_interact_call_world_event: WorldEventCall: 
	set(value): 
		on_interact_call_world_event = value
		if !is_node_ready(): 
			await ready
		await get_tree().physics_frame
		call_world_event_component.event_call = on_interact_call_world_event

@export var inventory: Inventory: 
	set(value): 
		inventory = value
		if inventory: 
			inventory.owner = self

@export var data: Entity: set = set_data
@export var interact_description: BaseLabelText
@export var dialogue: DialogueArguments: 
	set(value): 
		dialogue = value
		if !is_node_ready(): 
			await ready
		dialogue_starter.dialogue = dialogue
		
@export var dialogue_if_disabled: DialogueArguments

@export var quiz: Quiz
@export var quest: EcoQuest
@export var disable_after_interact: bool
@export var disable_tap_hit_box_if_disabled: bool = true: 
	set(value): 
		disable_tap_hit_box_if_disabled = value
		if !is_node_ready(): 
			await ready
		if disabled && !disable_tap_hit_box_if_disabled: 
			disable_tap_hit_box(false)
		
		
@export var disabled: bool: 
	set(value): 
		disabled = value
		#printerr(get_path())
		#printerr(disabled)
		#printerr("\n")
		if !is_node_ready(): 
			await ready
		if disable_tap_hit_box_if_disabled: 
			disable_tap_hit_box(disabled)
			
@export var use_custom_position: bool: 
	set(value): 
		use_custom_position = value
		if !is_node_ready(): 
			await ready
		two_point_5d_node_simulator.use_custom_position = use_custom_position
		
@export var custom_position: Vector2: 
	set(value): 
		custom_position = value
		if !is_node_ready(): 
			await ready
		two_point_5d_node_simulator.custom_position = custom_position
		
@export var on_tap_jump: bool
@export var on_tap_face_player: bool

@export_group("Dependencies")
@export var state_chart: StateChart
@export var path_find: PathFindMovementComponent
@export var walk: MovementComponent
@export var hitbox: Hitbox
@export var node_variety_manager: NodeVarietyManager
@export var interact_audio_player: AudioManagerPlayer
@export var interact_dialog_position: Marker2D
@export var dialogue_starter: DialogueStarter
@export var dialogue_response_handler: DialogueResponseHandler
@export var call_world_event_component: CallWorldEventComponent
@export var ready_unique_resource: ReadyUniqueResource
@export var master_save_component: MasterSaveComponent
@export var tap_hit_box: Button
@export var tap_hit_box_root: Control
@export var default_entity_sprite: Sprite2D
@export var two_point_5d_node_simulator: TwoPoint5DNodeSimulator
@export var dialogue_starter_for_disabled: DialogueStarter
@export var animation_player: AnimationPlayer

#var interacted_count: int = 0

func _ready() -> void: 
	#GameManager.playing_state.state_entered.connect(_on_playing_state_entered)
	pass
	#
	
## FIXME: BANDAID SOLUTION!
#func _on_playing_state_entered() -> void: 
	#if GUIManager.quiz_attempt_screen.visible: 
		#tap_hit_box.visible = false
	
	
func _process(_delta: float) -> void: 
	tap_hit_box_root.global_position = global_position
	tap_hit_box_root.scale = scale
	
	
func set_data(value: Entity) -> void: 
	data = value


func interact() -> void: 
	_on_interact()


## Virtual Function
func _interact() -> void: 
	pass


func _on_interact() -> void: 
	if disabled || !visible: 
		if dialogue_if_disabled: 
			dialogue_starter_for_disabled.dialogue = dialogue_if_disabled
			dialogue_starter_for_disabled.start()
		return
	#interacted_count += 1
	starting_interact.emit()
	if disable_after_interact: 
		disabled = true
	if is_instance_valid(quest): 
		if dialogue: 
			DialogueManager.dialogue_ended.connect(
				func(_resource): 
					quest.give_item_to_player()
			, CONNECT_ONE_SHOT
			)
		quest.update()
	if AchievementUnlockedScreen.this().visible: 
		await AchievementUnlockedScreen.this().deactivated
	_interact()
	if interact_audio_player: 
		interact_audio_player.play()
	if dialogue == null: 
		if quiz != null: 
			QuizAttemptScreen.display(quiz, data)
	dialogue_starter.start()
	#if quest: 
		#if quest.on_complete_get_new_item:
			#if dialogue:  
				#await DialogueManager.dialogue_ended
			#quest.give_item_to_player()
	call_world_event_component.play()
	interacted.emit()
	if disable_after_interact: 
		disabled = true


func show_interact_dialog(description: BaseLabelText) -> void: 
	if disabled || !visible: 
		return
	#if interacted_count > 1: 
		#return
		
	if inventory && !inventory.items.is_empty(): 
		if PlayerManager.player.data.inventory.item_was_in_history(inventory.items[0].model): 
			_on_interact()
			return
		
	var dialog: InteractDialog = InteractDialog.display(
		InteractDialogData.new()\
			.set_caller(
				PlayerManager.player
			)\
			.set_gui_position(interact_dialog_position.global_position)\
			.set_on_button_pressed(_on_interact)\
			.set_description(description)
	)
	
	if interact_audio: 
		dialog.ok_button.button_audio_player.disabled = true


func _on_tap_hit_box_pressed() -> void:
	if !PlayerManager.player: 
		return
		
	if player_is_move_to_position: 
		PlayerManager.player.is_move_to_position = true
		PlayerManager.player.move_to_position = global_position
		PlayerManager.player.move_to_position.y += 40 * scale.y
	
		if !disabled: 
			PlayerManager.player.move()
	
	#printerr(get_path())
	#printerr(disabled)
	#printerr("\n")
	if disabled: 
		_on_interact()
		if player_is_move_to_position: 
			PlayerManager.player.is_move_to_position = false
	elif wait_for_player_to_come: 
		if !PlayerManager.player.path_find.changed_target.is_connected(_on_changed_target): 
			PlayerManager.player.path_find.changed_target.connect(_on_changed_target, CONNECT_ONE_SHOT)
		if !PlayerManager.player.path_find.finished_navigation.is_connected(_on_finished_navigation): 
			PlayerManager.player.path_find.finished_navigation.connect(_on_finished_navigation, CONNECT_ONE_SHOT)
	#else: 
		#show_interact_dialog(interact_description)
	else: 
		if display_interact_dialog: 
			show_interact_dialog(interact_description)
		else: 
			_on_interact()
			
	if on_tap_jump: 
		jump_animation()
		
	if on_tap_face_player: 
		face_player()


func jump_animation() -> void: 
	var tween_arg: TweenArguments = TweenArguments.new()
	
	var tween: Tween = tween_arg.create_tween(get_tree())
	
	var orig_pos: Vector2 = default_entity_sprite.position
	tween.tween_property(default_entity_sprite, "position:y", orig_pos.y + -75 * two_point_5d_node_simulator.get_space_simulator().get_space_scale(default_entity_sprite.global_position, walk.base_values.values.speed), 0.3)
	tween.tween_property(default_entity_sprite, "position:y", orig_pos.y, 0.3)
	
	tween.play()


func face_player() -> void: 
	if data is NPCEntity: 
		var player_direction: Vector2 = global_position.direction_to(PlayerManager.player.global_position)
		if data.facing_left: 
			if player_direction.x > 0: 
				default_entity_sprite.flip_h = true
			else: 
				default_entity_sprite.flip_h = false
			return
		
		if player_direction.x < 0: 
			default_entity_sprite.flip_h = true
		else: 
			default_entity_sprite.flip_h = false
			
		
		


func _on_changed_target() -> void: 
	if PlayerManager.player.path_find.finished_navigation.is_connected(_on_finished_navigation): 
		PlayerManager.player.path_find.finished_navigation.disconnect(_on_finished_navigation)


func _on_finished_navigation() -> void: 
	if display_interact_dialog: 
		show_interact_dialog(interact_description)
	else: 
		_on_interact()
		
	if player_is_move_to_position: 
		PlayerManager.player.is_move_to_position = false


func _on_dialogue_response_handler_responded(value: String) -> void: 
	match value: 
		"start_quiz": 
			QuizAttemptScreen.display(quiz, data)
		"start_quest": 
			ExtendedQuestSystem.mark_quest_as_available(quest)
			ExtendedQuestSystem.start_quest(quest)
			quest.update()
			#GameManager.show_quest_entities()
			if faucets_show: 
				GameManager.faucets_show = faucets_show
			
		"remove_dialogue": 
			dialogue = null
		"sad_expression": 
			GUIManager.dialogue_gui_manager.current_dialogue_gui.set_sprite_to_sad()
			node_variety_index = 1
		"idle_expression": 
			GUIManager.dialogue_gui_manager.current_dialogue_gui.set_sprite_to_idle() 
			node_variety_index = 0



func _on_ready_unique_resource_resource_ready() -> void:
	if inventory: 
		inventory.owner = self


func disable_tap_hit_box(value: bool) -> void: 
	tap_hit_box.visible = !value 
	for component: Node in tap_hit_box.get_children(): 
		if component.has_method("disabled"): 
			component.disabled = value
	
	
