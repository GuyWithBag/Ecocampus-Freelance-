extends Node
class_name AchievementsTracker

# Hard coding this cuz why not

#@export var achievements_collection: AchievementsCollection: 
	#set(value): 
		#achievements_collection = value
		#if !is_node_ready(): 
			#await ready
		#for child: Node in get_achievements(): 
			#child.queue_free()
			#
		#for achievement: Achievement in achievements_collection.collection: 
			#var node: AchievementNode = achievements_collection.achievement_node_scene.instantiate()
			#achievements.add_child(node)
			#node.achievement = achievement
			
#@export var achievements_quests: Array[EcoQuest]

@export var achievements_collection: AchievementsCollection: 
	set(value): 
		achievements_collection = value
		update_victory()
		
		
@export var collection: Array[Achievement]: 
	get: 
		return achievements_collection.collection
		
		
@export var medals: PointCounterComponent
@export var print_color: PrintColor: 
	set(value): 
		print_color = value
		print_color.owner = self

func _ready() -> void: 
	#for quest: EcoQuest in achievements_quests: 
		#ExtendedQuestSystem.start_quest(quest)
		#
	#ExtendedQuestSystem.quest_completed.connect(_on_quest_completed)
	update_victory()
	
#func _on_quest_completed(quest: Quest) -> void: 
	#var eco_quest: EcoQuest = quest
	#pass
	#medals.points.add(eco_quest.on_complete_unlock_achievement.reward_medals)
	
	
func unlock_cosmetic(cosmetic: Cosmetic) -> void: 
	var debug: float = medals.points.current
	cosmetic.unlock(int(medals.points.current))
	if cosmetic.is_unlocked(): 
		medals.points.subtract(cosmetic.medals_required)
		print_color.out_debug_wvalue("Unlocked cosmetic with medals", [cosmetic, debug])


func update_victory() -> void: 
	
	if !is_node_ready(): 
		await ready
	
	#printerr("all: ", achievements_collection.collection.all(
		#func(item: Achievement): 
			#printerr(item.unlocked)
			#return item.unlocked
	#))
	#for i: Achievement in achievements_collection.collection: 
		#printerr(i.is_unlocked)
		
	if achievements_collection.collection.all(
		func(item: Achievement): 
			return item.is_unlocked
	): 
		show_victory_screen()
		
		
func show_victory_screen() -> void: 
	if AchievementUnlockedScreen.this() != null && AchievementUnlockedScreen.this().visible: 
		await AchievementUnlockedScreen.this().deactivated
	else: 
		await get_tree().create_timer(1).timeout
	GUIManager.add_gui(GUICollection.victory_screen.instantiate())
	
	
func reset() -> void: 
	medals.points.reset()
	
	
	
	
