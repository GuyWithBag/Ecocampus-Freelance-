extends GUI
class_name QuizAttemptScreen

@export var assesment_music: AudioManagerPlayer
@export var quiz_attempt_gui: QuizAttemptGUI

@export var quiz: Quiz: 
	set(value): 
		quiz = value
		#quiz_attempt_gui
		
@export var entity_answering: NPCEntity: 
	set(value): 
		entity_answering = value
		if !entity_answering: 
			return
		idle.flip_h = !entity_answering.facing_left
		happy.flip_h = !entity_answering.facing_left
		sad.flip_h = !entity_answering.facing_left
		
		idle.texture = entity_answering.get_speaker_idle_sprite()
		happy.texture = entity_answering.happy_sprite
		sad.texture = entity_answering.sad_sprite
		
@export var idle: TextureRect
@export var happy: TextureRect
@export var sad: TextureRect

@export var reaction_sprites: TabContainer


static func this() -> QuizAttemptScreen: 
	return GameManager.get_tree().get_first_node_in_group("QuizAttemptScreen")
	

static func display(q: Quiz, _entity_answering: Entity) -> QuizAttemptScreen: 
	var screen: QuizAttemptScreen = GUIManager.quiz_attempt_screen
	GUIManager.set_gui_active(screen, true)
	GUIManager.set_gui_active(screen.quiz_attempt_gui, true)
	if _entity_answering is NPCEntity: 
		screen.entity_answering = _entity_answering
	screen.start(q)
	return screen
	
	
static func conceal() -> QuizAttemptScreen: 
	var screen: QuizAttemptScreen = GUIManager.quiz_attempt_screen
	screen.close()
	return screen
	
	
func start(q: Quiz) -> void: 
	quiz = q
	quiz_attempt_gui.again()
	assesment_music.play()
	quiz_attempt_gui.start(quiz)
	quiz_attempt_gui.quiz_attempt.state_changed.connect(
		_on_quiz_attempt_state_changed
	)
	reaction_sprites.current_tab = 0


func _on_quiz_attempt_state_changed(state: QuizAttempt.AttemptState) -> void: 
	match state: 
		QuizAttempt.AttemptState.ANSWERING: 
			reaction_sprites.current_tab = 0
		QuizAttempt.AttemptState.VICTORY: 
			reaction_sprites.current_tab = 1
		QuizAttempt.AttemptState.LOST: 
			reaction_sprites.current_tab = 2


func _on_quiz_attempt_gui_deactivated() -> void:
	close()


func close() -> void: 
	GUIManager.set_gui_active(self, false)
	
