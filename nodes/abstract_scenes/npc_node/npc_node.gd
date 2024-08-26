@tool
extends EntityNode
class_name NPCNode

@export var idle_animate_if_quest_incomplete: bool
@export var idle_animation_timer: Timer

var is_idle_animating_if_quest_incomplete: bool
var rng: RandomNumberGenerator = RandomNumberGenerator.new() 
	
	
func _ready() -> void: 
	super._ready() 
	if Engine.is_editor_hint(): 
		return
		
	#interact_description = RichLabelText.new()
	#
	#interact_description.format = StringFormatter.new()
	#
	#interact_description.format.format = \
#"[outline_size=4][outline_color=BLACK][b][font_size=38]%s[/font_size][/b]
#[font_size=28][b]Type:[/b] %s[/font_size]
#[font_size=28][b]Environmental Impact:[/b] %s[/font_size]"
	#
	#interact_description.texts = [
		#data.name, 
		#GlobalVariables.get_enum_name(ItemEntity.Type, data.type).to_pascal_case(), 
		#inventory.items[0].model.description
	#] as Array[String]
	idle_animation_if_quest_incomplete()
	
	
func idle_animation_if_quest_incomplete() -> void: 
	#if !is_instance_valid(get_tree()): 
		#return
	#
	if is_idle_animating_if_quest_incomplete: 
		return
	#is_idle_animating_if_quest_incomplete = true
	#is_idle_animating_if_quest_incomplete = false
	rng.randomize() 
	idle_animation_timer.wait_time = rng.randi_range(3, 7)
	idle_animation_timer.start()
	
	idle_animation_timer.timeout.connect(
		func(): 
			#idle_animation_if_quest_incomplete()
			if quest == null: 
				return
				
			if ExtendedQuestSystem.is_quest_completed(quest) || GUIManager.dialogue_gui_manager.visible || QuizAttemptScreen.this().visible: 
				return
				
			default_entity_sprite.flip_h = !default_entity_sprite.flip_h
	)
	
	
func show_interact_dialog(_description: BaseLabelText) -> void: 
	if disabled: 
		return
		
	var text: LabelText = LabelText.new()
	text.texts.append("%s" % data.custom_name)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	var dialog: InteractDialog = InteractDialog.display(
		InteractDialogData.new()\
			.set_caller(
				PlayerManager.player
			)\
			.set_gui_position(interact_dialog_position.global_position)\
			.set_on_button_pressed(_on_interact)\
			.set_description(text)\
			.set_custom_ok_text("HI")
	)
	
	if interact_audio: 
		dialog.ok_button.button_audio_player.disabled = true
		
		
		
