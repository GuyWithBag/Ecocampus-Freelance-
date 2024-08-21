@tool
extends PanelContainer
class_name QuestTaskGUI


@export var task: EcoQuestTask: 
	set(value): 
		task = value
		if !is_node_ready(): 
			await ready
		update()
		task.get_counter().current_changed.connect(
			_on_task_counter_current_changed
		)
		
@export var label: FormattedLabel


func _on_task_counter_current_changed(_new: float, _prev: float) -> void: 
	update()
	
	
func update() -> void: 
	if task.hide_counter_in_gui: 
		label.hide()
		return
	label.input([task.description, str(task.get_counter().current), str(task.get_counter().maximum)])
