@tool
extends InteractableEntityNode
class_name LadderPlacementArea 

@export var items_accesible_when_climbed: Array[PickuppableEntity]
@export var ground_marker: Marker2D
@export var top_marker: Marker2D
@export var main_camera: MainCamera

var on_ladder: bool
var has_ladder: bool: 
	set(value): 
		has_ladder = value
		if !is_node_ready(): 
			await ready
			
		if value: 
			default_entity_sprite.show()
			tap_hit_box.show()
			disabled = false
			#print(disabled)
			is_item_accepted = true
			show()
		else: 
			default_entity_sprite.hide()
			tap_hit_box.hide()
			disable_items(true)
			disabled = true
			hide()
			
func _ready() -> void: 
	super._ready()
	if Engine.is_editor_hint():
		return
	has_ladder = false
	#set_physics_process(false)


func _on_item_accepted(_item_stack: ItemStack) -> void:
	#default_entity_sprite.show()
	#tap_hit_box.show()
	#disabled = false
	#is_item_accepted = true
	#disable_items(false)
	has_ladder = true


func _interact() -> void: 
	if !is_item_accepted: 
		return
		
	#PlayerManager.player.path_find_movement_component.finished_navigation.connect(
		#func(): 
			#move_to(top_marker)
	#, CONNECT_ONE_SHOT
	#)
	#move_to(ground_marker)
	if on_ladder: 
		move_down()
	else: 
		move_up()
	
	
func move_up() -> void: 
	var tween: Tween = get_tree().create_tween()
	var player: PlayerNode = PlayerManager.player
	#var duration: float = 0.9
	
	GetMousePositionArea.this().visible = false
	
	# For things that are not on the ladder
	for node: Node in get_tree().get_nodes_in_group("LadderDisable"): 
		node.disabled = true
	
	tween.tween_property(player, "global_position", ground_marker.global_position,  0.1)
	tween.chain()
	player.z_index = 1
	tween.step_finished.connect(
		func(_idx: int): 
			player.lock_size = true
			
			player.is_animation_only = true
			player.state_chart.send_event("idle")
			player.state_chart.send_event("walk")
			player.animation_player.play("walk_left")
			ToMapPickerIconButton.this().visible = false
			SettingsIconButton.this().visible = false
			#main_camera.adjust_offset = Vector2.ZERO
			
			player.animate_y_direction_move = false
			player.y_direction_variety.index = 1
			
	, CONNECT_ONE_SHOT
	)
	tween.tween_property(player, "global_position", top_marker.global_position,  0.7)
	tween.finished.connect(
		func(): 
			player.is_animation_only = false
			player.state_chart.send_event("idle")
			player.animation_player.play("idle_left")
			disable_items(false)
			player_is_move_to_position = false
			player.is_move_to_position = true
			wait_for_player_to_come = false
			player.y_direction_variety.index = 0
			
	, CONNECT_ONE_SHOT
	)
	tween.play()
	on_ladder = true
	
	
func move_down() -> void: 
	var tween: Tween = get_tree().create_tween()
	var player: PlayerNode = PlayerManager.player
	var duration: float = 0.9
	
	tween.tween_property(player, "global_position", ground_marker.global_position,  duration)
	#tween.chain()
	#tween.tween_property(player, "global_position", top_marker.global_position,  duration)
	player.animate_y_direction_move = false
	player.y_direction_variety.index = 0
	
	tween.finished.connect(
		func(): 
			player.animate_y_direction_move = true
			player.is_animation_only = false
			player.state_chart.send_event("idle")
			player.animation_player.play("idle_right")
			player.lock_size = false
			disable_items(true)
			player.z_index = 0
			GetMousePositionArea.this().visible = true
			#player_is_move_to_position = false
			#player.is_move_to_position = false
			player_is_move_to_position = true
			player.is_move_to_position = false
			wait_for_player_to_come = true
			#printerr("ASDSADASDASd")
			#main_camera.adjust_offset = Vector2(0, -300)
			for node: Node in get_tree().get_nodes_in_group("LadderDisable"): 
				if node.get("need_quest_before_enabled") != null && node.need_quest_before_enabled: 
					if ExtendedQuestSystem.is_quest_active(node.need_quest_before_enabled): 
						node.disabled = false
				elif node is NPCNode: 
					node.disabled = false
			ToMapPickerIconButton.this().visible = true
			SettingsIconButton.this().visible = true
				
	, CONNECT_ONE_SHOT
	)
	player.is_animation_only = true
	player.state_chart.send_event("enabled")
	player.state_chart.send_event("idle")
	player.state_chart.send_event("walk")
	player.animation_player.play("walk_right")
	
	tween.play()
	
	on_ladder = false
	
	
func disable_items(value: bool) -> void: 
	for ent: PickuppableEntity in items_accesible_when_climbed: 
		if is_instance_valid(ent): 
			ent.disabled = value
		
	
func move_to(target: Node2D) -> void: 
	await get_tree().physics_frame
	PlayerManager.player.path_find_movement_component.target = target
	#printerr(PlayerManager.player.path_find_movement_component.target)
	await get_tree().physics_frame
	set_physics_process(true)
	
	
#func _physics_process(_delta: float) -> void: 
	#if Engine.is_editor_hint(): 
		#return
	#var result: bool = PlayerManager.player.path_find_movement_component.move()
	#if result == false: 
		#set_physics_process(false)
	
func _process(delta: float) -> void: 
	super._process(delta)
	
	if Engine.is_editor_hint(): 
		return
	
	if on_ladder: 
		GetMousePositionArea.this().visible = false
	else: 
		GetMousePositionArea.this().visible = true
	
	#printerr(visible)
	
