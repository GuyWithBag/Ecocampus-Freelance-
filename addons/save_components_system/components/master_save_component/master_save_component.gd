## Master means it is an owner of multiple SaveComponents. It will search the node of SaveComponents then it will gather it for to_dict(). 
extends FollowerSaveComponent
class_name MasterSaveComponent

@export var dont_use: bool: 
	set(value): 
		dont_use = value
		if dont_use: 
			remove_from_group("MasterSaveComponent")
		else: 
			if !is_in_group("MasterSaveComponent"): 
				add_to_group("MasterSaveComponent")
		
@export var id: IDComponent

@export var do_not_search_nodes: PackedStringArray
@export var no_king: bool
@export var is_queued_free: bool

func to_dict() -> Dictionary: 
	var follower_dicts: Dictionary = {}
	
	for save: FollowerSaveComponent in _get_all_save_components(node): 
		#print(path)
		follower_dicts.merge(save.to_dict()) 
		
	#print("\nfollower dict: %s\n" % follower_dicts)
	var key: String = get_path()
	#print(node.get_path())
	var master_dict: Dictionary = {}
	
	if data != null: 
		master_dict[key] = data.to_dict(node)
		#if is_queued_free: 
			#master_dict[key]["is_queued_free"] = true
			##master_dict[key].merge({
				##"is_queued_free": true
			##})
		#else: 
			#master_dict[key]["is_queued_free"] = false
	#if id.data != null: 
		#master_dict.merge({
			#"id": id.data.value
		#})
	master_dict.merge(follower_dicts)
	#if is_queued_free: 
		#printerr(master_dict)
	#print("\nmaster_dict: %s\n" % master_dict)
	#if master_dict.has(key) && master_dict[key].has("is_queued_free"): 
		#printerr("master: ", master_dict[key]["is_queued_free"])
	return master_dict

# {
#  node_path: { all properties }, 
#  merged_data: { props }
# }

func _get_all_save_components(parent: Node) -> Array[FollowerSaveComponent]: 
	var save_components_in_node: Array[FollowerSaveComponent] = []
	for child: Node in parent.get_children(): 
		if child.name in do_not_search_nodes: 
			continue
		if child is FollowerSaveComponent && !child is MasterSaveComponent: 
			save_components_in_node.append(child)
		elif child.get_child_count() > 0: 
			save_components_in_node.append_array(_get_all_save_components(child))
	return save_components_in_node


#func load_dict(master_dict: Dictionary) -> void: 
	##super.load_dict(dict)
	#for master_property: String in master_dict.keys(): 
		#if master_property == "follower_saves": 
			#var follower_dict: Dictionary = master_dict[master_property]
			#for follower_node_path: String in follower_dict: 
				#var follower_save: FollowerSaveComponent = get_node(follower_node_path)
				#var follower_data: Dictionary =  follower_dict[follower_node_path]
				#follower_save.load_dict(follower_data) 
			#continue
		#var master_value = str(master_dict[master_property])
		#node.set(master_property, master_value)
