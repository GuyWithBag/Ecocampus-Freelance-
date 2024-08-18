extends NodeComponent
class_name PackedSceneLoader

signal thread_started
#signal thread_ended

@export var start_at_ready: bool

@export_file("*.tres") var packed_scene_loader_arguments: String
@export var extra_paths: PackedStringArray
@export var disabled: bool

var loaded_scenes: Array[PackedScene]
var thread: Thread


func _ready() -> void: 
	if disabled: 
		return
	if start_at_ready: 
		start()


func start() -> void: 
	if disabled: 
		return
	thread_started.emit()
	thread = Thread.new()
	thread.start(_load_scenes)


func _load_scenes() -> void: 
	if !packed_scene_loader_arguments.is_empty(): 
		var args: PackedSceneLoaderArguments = load(packed_scene_loader_arguments)
		loaded_scenes = args.scenes
	if !extra_paths.is_empty(): 
		for path: String in extra_paths: 
			loaded_scenes.append(load(path))
	
	
func _exit_tree():
	if thread && thread.is_alive(): 
		thread.wait_to_finish()
