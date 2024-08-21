@tool
extends VBoxContainer
class_name QuestTaskContainer

@export var quest: EcoQuest: 
	set(value): 
		quest = value 
		
		for child: Control in get_children(): 
			child.queue_free()
			
		for task: EcoQuestTask in quest.tasks: 
			add_task(task)
			
			
@export var eco_quest_task_gui: PackedScene


func add_task(task: EcoQuestTask) -> void: 
	var gui: QuestTaskGUI = eco_quest_task_gui.instantiate()
	gui.task = task
	add_child(gui)
