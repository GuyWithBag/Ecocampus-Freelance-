## An extended quest for this game
@tool
extends Quest
class_name EcoQuest

signal task_completed(task: EcoQuestTask)

@export var automatically_complete_after_tasks_completed: bool
@export var percentage_description: String
@export var tasks: Array[EcoQuestTask]: 
	set(value): 
		tasks = value
		if Engine.is_editor_hint(): 
			return
			
		for task: EcoQuestTask in tasks: 
			task.completed.connect(
				func(): 
					task_completed.emit(task)
					if automatically_complete_after_tasks_completed: 
						update()
			)
			
## Optional, leave null if not wanted. Unlocks this achievement when finished 
@export var on_complete_unlock_achievement: Achievement
@export var on_complete_get_new_item: ItemStack
@export var invisible_in_gui: bool
@export var take_items: Array[ItemStack]

var percentage_description_format: StringFormatter

var completed_percentage: Percentage: 
	get: 
		#print(Percentage.new(completed_tasks_count, tasks_count))
		return Percentage.new(completed_tasks_count, tasks_count)

var tasks_count: int:
	get: 
		return tasks.size()
		
var completed_tasks_count: int: 
	get: 
		var count: int = 0
		for task: EcoQuestTask in tasks: 
			if task.is_completed: 
				count += 1
		return count


func _init() -> void: 
	percentage_description_format = StringFormatter.new()
	percentage_description_format.format = "%s: %s/%s"
	
	
func start() -> void: 
	for task: EcoQuestTask in tasks: 
		task.start(GameManager.get_tree())
	
	
func update() -> void: 
	#printerr(are_tasks_all_complete())
	if are_tasks_all_complete(): 
		objective_completed = true
		ExtendedQuestSystem.complete_quest(self)
	
	
func are_tasks_all_complete() -> bool: 
	return (
		func(): 
			return tasks.all(
				func(task: EcoQuestTask): 
					return task.is_completed
			)
	).call()
	
	
func complete() -> void: 
	if on_complete_unlock_achievement: 
		on_complete_unlock_achievement.unlock()
		on_complete_unlock_achievement.display()
		
		
func give_item_to_player() -> void: 
	if !objective_completed: 
		return
	if !ExtendedQuestSystem.is_quest_completed(self): 
		return
		
	if on_complete_get_new_item: 
		PlayerManager.player.data.inventory.add_item(on_complete_get_new_item)
	if !take_items.is_empty(): 
		PlayerManager.player.data.inventory.remove_items(take_items, self)
	
func _to_string() -> String: 
	return "%s: <EcoQuest#%s>" % [percentage_description, get_instance_id()]
