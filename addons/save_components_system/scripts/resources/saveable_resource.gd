extends Resource
class_name SaveableResource

## In order for you to save properties with custom resources, in the _init(), define properties (var) some items that you want to save. 
## func _init()
## 	properties = ["scene_file", "items"] 
## 	super._init() 
@export var save_as_resource_path: bool = false
@export var exclude_save_as_resource_path_on: Array[String]

var save: PropertiesToSave
#var use_script_resource_path_as_key: bool

func _init() -> void: 
	_save()
	
	
func _save() -> void: 
	if Engine.is_editor_hint() || save != null: 
		return
	save = PropertiesToSave.from(_save_properties())


## Virtual Function
## Return the list of properties writting in string here that you want to save. 
func _save_properties() -> PackedStringArray: 
	#if Engine.is_editor_hint(): 
		#return
	#save = PropertiesToSave.from_resource(self, properties)
	return []
	
	
func to_dict() -> Dictionary: 
	#if use_script_resource_path_as_key: 
		#return {
			#str(get_script().resource_path): save.to_dict(self)
		#}
	var dict: Dictionary = {
		"script_resource_path": get_script().resource_path, 
		"resource_path": resource_path
	}
	#printerr(self)
	#printerr(save)
	if save == null: 
		_save()
	dict.merge(save.to_dict(self))
	return dict

# Called by PropertiesToSave
func load_update(data) -> void: 
	_load_update(data)


## Virtual Function
func _load_update(_data) -> void: 
	pass
	
