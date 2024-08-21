extends GUI
class_name QuizAttemptGUI


@export var quiz_attempt: QuizAttempt: 
	set(value): 
		quiz_attempt = value
		if !is_node_ready(): 
			await ready
			
		quiz_attempt.completed.connect(
			_on_quiz_attempt_completed
		)
		title.text = quiz_attempt.quiz.title
		end_title.text = quiz_attempt.quiz.title
		description.text = quiz_attempt.quiz.description
		

@export var problem_page: QuizProblemPage
@export var title: Label
@export var end_title: Label
@export var description: Label

@export var score: FormattedLabel
@export var wrong: Label
@export var problem_page_router: PageRouter
@export var again_page_router: PageRouter
@export var play_again_button: TextureButtonPlus

var quiz: Quiz: 
	set(value): 
		quiz = value
		if !is_node_ready(): 
			await ready
		play_again_button.disabled = false


func start(q: Quiz) -> void: 
	quiz = q
	quiz_attempt = quiz.attempt()


func _on_quiz_attempt_completed() -> void: 
	score.input([str(quiz_attempt.score), str(quiz_attempt.quiz.maximum_score)])
	if quiz.has_victory(): 
		play_again_button.disabled = true
		SaveManager.save_game()
		SaveManager.save_game_to_file(true)


func _on_play_pressed() -> void: 
	quiz_attempt.start()
	problem_page.quiz_attempt = quiz_attempt


func _on_exit_pressed() -> void: 
	GUIManager.set_gui_active(self, false)


func _on_quiz_problem_page_quiz_completed() -> void:
	problem_page_router.route()
	if quiz_attempt.has_passed_attempt(): 
		quiz.on_victory_unloch_achievement.unlock()
		quiz.on_victory_unloch_achievement.display()


func again() -> void: 
	again_page_router.route()


#func _activated() -> void: 
	#GameManager.enable_player_on_playing_entered = false
#
#
#func _deactivated() -> void: 
	#GameManager.enable_player_on_playing_entered = true
	
	
