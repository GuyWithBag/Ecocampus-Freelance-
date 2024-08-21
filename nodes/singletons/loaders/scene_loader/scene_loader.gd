extends Node

signal load_started
signal thread_load_loaded
signal load_ended(path: String)
signal scene_entered_tree

#signal current_scene_entered_tree

@export var _print_color: PrintColor: 
	set(value): 
		_print_color = value
		_print_color.owner = self

var has_thread_load_loaded: bool
var _next_scene_path: String
var load_status: ResourceLoader.ThreadLoadStatus
var load_progress: Array

var is_loading: bool
#var _loaded_scene
#@onready var load_screen: LoadScreen = GUIManager.load_screen


#func _init() -> void: 
	#set_process.call_deferred(false)

# BANDAID SOLUTION
func _process(_delta: float) -> void: 
	#var current_scene: Node = get_tree().current_scene
	#load_screen.load_progress = load_progress
	
	#var current_scene: Node = get_tree().current_scene 
	#if current_scene != null: 
		#current_scene_entered_tree.emit()
		#
	#
	if !is_loading: 
		return
		
	#print(load_status)
	load_status = ResourceLoader.load_threaded_get_status(_next_scene_path, load_progress)
	match load_status: 
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE: 
			is_loading = false
			push_error("Error: Cannot load scene, resource is invalid.")
			load_ended.emit()
		# For loading screens with progress bars
#			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
#				load_screen.get_node("Control/ProgressBar").value = load_progress[0]
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			is_loading = false
			push_error("Error: Loading failed!")
			load_ended.emit()
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			is_loading = false
			has_thread_load_loaded = true
			thread_load_loaded.emit()
			var next_scene: PackedScene = ResourceLoader.load_threaded_get(_next_scene_path)
			
			#if GUIManager.transitions_manager.middle_transition_condition != MiddleTransitionGUI.EndCondition.NONE: 
			#if GUIManager.transitions_manager.transitioning: 
				#await GUIManager.transitions_manager.middle_transition.ended
			if GUIManager.transitions_manager.transitioning: 
				if is_instance_valid(GUIManager.transitions_manager.start_transition): 
					await GUIManager.transitions_manager.start_transition.ended
			get_tree().change_scene_to_packed(next_scene)
			#if GUIManager.transitions_manager.end_transition: 
				#await GUIManager.transitions_manager.middle_transition.started
			#await get_tree().process_frame
			scene_entered_tree.emit()
			#printerr(get_tree().current_scene)
			_print_color.out_debug_wvalue("Loading scene finished", _next_scene_path)
			load_ended.emit(_next_scene_path)
			has_thread_load_loaded = false
			#print_orphan_nodes()


func load_file(args: ChangeSceneArguments) -> void:
	_next_scene_path = args.scene
	if !ResourceLoader.exists(_next_scene_path): 
		push_error("Error: Attempting to load non-existent file: %s" % _next_scene_path)
		return
	
	GUIManager.transitions_manager.prepare_transition(args.transition)
	GUIManager.transitions_manager.start(args.transition, args.middle_transition_end_condition)

	ResourceLoader.load_threaded_request(_next_scene_path)
	_print_color.out_debug_wvalue("Started loading scene", _next_scene_path)
	is_loading = true
	#set_process.call_deferred(true)
	load_started.emit()


#func change_scene() -> void: 
	#pass
	#
	
