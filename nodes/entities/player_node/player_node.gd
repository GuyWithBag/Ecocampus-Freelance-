@tool

## ----------------------------- ## DO NOT PUT PLAYER DATA IN PLAYERNODE ## ------------------------------ ##

extends EntityNode
class_name PlayerNode

@export var gender: GlobalEnums.Gender: 
	set(value): 
		gender = value
		if !is_node_ready(): 
			await ready
		if gender == GlobalEnums.Gender.MALE: 
			node_variety_manager.index = 1
		else: 
			node_variety_manager.index = 0
			
@export var animate_y_direction_move: bool = true


@export_group("Dependencies")
@export var move_to_tap: MoveToTapPathFindMovement
@export var mouse_position: MousePositionComponent
@export var cosmetic_equipper_component: CosmeticEquipperComponent
@export var path_find_movement_component: PathFindMovementComponent
@export var y_direction_variety: NodeVarietyManager
@export var walk_state: StateChartState

## Should it be able to move to that position?
var is_move_to_position: bool

## Only purpose for this is for when the player interacts an object and he has to move to that position
var move_to_position: Vector2
var is_animation_only: bool

func _ready() -> void: 
	super._ready()
	if Engine.is_editor_hint(): 
		return
	PlayerManager.init()
	PlayerManager.player_instanced.emit()


func _on_idle_state_entered() -> void:
	path_find.stop()
	y_direction_variety.index = 0
	
	
func _on_walk_state_entered() -> void: 
	if is_animation_only: 
		return
		
	if is_move_to_position: 
		move_to_tap.move_at(move_to_position)
	else: 
		move_to_tap.move()


#func _on_can_tap_state_input(event: InputEvent) -> void:
	##event.
	#if event.is_action_pressed("tap"): 
		#if mouse_position.get_position_direction_relative_to(global_position)[0] == BaseGlobalEnums.Directions.LEFT: 
			#state_chart.send_event("left")
		#else: 
			#state_chart.send_event("right")
			#
		## Idle event is sent first so that it resets. ???
		#state_chart.send_event("idle")
		#state_chart.send_event("walk")


func _on_can_tap_state_entered() -> void:
	GetMousePositionArea.this().tapped.connect(_on_get_mouse_position_area_tapped)


func _on_can_tap_state_exited() -> void:
	GetMousePositionArea.this().tapped.disconnect(_on_get_mouse_position_area_tapped)
	
	
func _on_get_mouse_position_area_tapped() -> void: 
	move()
	
	
func move() -> void: 
	if mouse_position.get_position_direction_relative_to(global_position)[0] == BaseGlobalEnums.Directions.LEFT: 
		state_chart.send_event("left")
	else: 
		state_chart.send_event("right")
	
	state_chart.send_event("idle")
	state_chart.send_event("walk")
	
	
func set_data(value: Entity) -> void: 
	data = value
	if data: 
		if Engine.is_editor_hint(): 
			return
		if !data.gender_changed.is_connected(_on_gender_changed): 
			data.gender_changed.connect(_on_gender_changed)
		gender = data.gender


func _on_gender_changed() -> void: 
	gender = data.gender


func _on_path_find_movement_component_finished_navigation() -> void: 
	state_chart.send_event("idle")


func _on_walk_state_processing(_delta: float) -> void:
	if animate_y_direction_move: 
		if walk.direction.y > 0: 
			y_direction_variety.index = 0
		elif walk.direction.y < 0: 
			y_direction_variety.index = 1
