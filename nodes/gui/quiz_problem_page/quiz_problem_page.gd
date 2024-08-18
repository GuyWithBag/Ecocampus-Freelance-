@tool
extends GUI
class_name QuizProblemPage

signal quiz_completed
#signal correctly_answered

@export var quiz_attempt: QuizAttempt: 
	set(value): 
		quiz_attempt = value
		if quiz_attempt == null: 
			return
		quiz_attempt.completed.connect(_on_quiz_completed, CONNECT_ONE_SHOT)
		update()

@export var question_label: FormattedLabel

@export var answers: GridContainer

@export var answer_a: TextureButtonPlus
@export var answer_b: TextureButtonPlus
@export var answer_c: TextureButtonPlus
@export var answer_d: TextureButtonPlus

var problem_attempt: QuizProblemAttempt: 
	set(value): 
		problem_attempt = value
		if !is_node_ready(): 
			await ready
		if !is_instance_valid(problem_attempt): 
			return
		
		question_label.input([str(quiz_attempt.problem_attempts.find(problem_attempt) + 1), problem_attempt.problem.question])
		
		var p_answers: Array[String] = problem_attempt.problem.get_answers()
		answer_a.label.text = p_answers[0]
		answer_b.label.text = p_answers[1]
		answer_c.label.text = p_answers[2]
		answer_d.label.text = p_answers[3]


static func create(parent: Control, _problem_attempt: QuizProblemAttempt) -> QuizProblemPage: 
	var gui: QuizProblemPage = GUICollection.quiz_problem_page.instantiate()
	parent.add_child(gui)
	gui.problem_attempt = _problem_attempt
	#gui.page_router.page_router_container = parent
	return gui


func _ready() -> void: 
	for button: TextureButtonPlus in answers.get_children(): 
		button.pressed.connect(_on_answer_pressed.bind(button))
		
		
func _on_answer_pressed(button: TextureButtonPlus) -> void: 
	problem_attempt.submit_answer(button.label.text)
	quiz_attempt.next_problem()
	#print(quiz_attempt.current_problem_index.current)
	if !quiz_attempt.current_problem_index.has_exceeded_maximum(): 
		update()
	#page_router.route()


func update() -> void: 
	problem_attempt = quiz_attempt.get_current_problem()
	
	
func _on_quiz_completed() -> void: 
	quiz_completed.emit()
