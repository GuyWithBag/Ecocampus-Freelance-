## Abstract class for types of save data
extends Resource
class_name PropertiesToSave


## The properties that will be saved. 
@export var properties: PackedStringArray
@export var save_properties_as_resource_path: PackedStringArray
#@export var additional_node_save_data: Array[FollowerSaveComponent]


#func to_json() -> JSON: 
	#var json: JSON = JSON.new()
	#var error = json.parse(JSON.stringify(data))
	#if error == OK:
		#return json
	#return null
#

static func from(props: PackedStringArray) -> PropertiesToSave: 
	var save: PropertiesToSave = PropertiesToSave.new()
	save.properties = props
	return save
	
	
func to_dict(from_object: Object) -> Dictionary: 
	var data: Dictionary = {}
	for property: String in properties: 
		var value = from_object.get(property)
		if value is SaveableResource: 
			if property in save_properties_as_resource_path: 
				data[property] = value.resource_path
				continue
			elif value.save_as_resource_path && !(from_object.name in value.exclude_save_as_resource_path_on): 
				data[property] = value.resource_path
			else: 
				data[property] = value.to_dict()
		elif value is Vector2: 
			data[property] = {
				"x": value.x, 
				"y": value.y
			}
		elif value is Array: 
			data[property] = []
			for i in value.size(): 
				var item = value[i]
				if is_instance_valid(item) && item is SaveableResource: 
					data[property].append({
						i: item.to_dict()
					})
		elif value is Resource: 
			if ResourceLoader.exists(value.resource_path): 
				data[property] = value.resource_path
			else: 
				push_error("%s from %s is not a SaveableResource and does not have a resource path. From object: %s" % [value, value.resource_path, from_object])
		else: 
			data[property] = value
	return data


# FIXME
# This was hell lmao. 
static func load_dict_to_object(obj: Object, dict: Dictionary) -> void: 
	#if obj is Node: 
		#if dict.has("is_queued_free") && dict["is_queued_free"] == true: 
			#obj.queue_free()
			#return
	for property: String in dict.keys(): 
		var value = dict[property]
		#print("obj: %s, property: %s" % [obj, property])
		if value is String: 
			#if property == "items": 
				#print("%s is string" % value)
			if value == "script_resource_path": 
				continue
			elif ResourceLoader.exists(value): 
				obj.set(property, load(value))
		elif value is Dictionary: 
			if value.has("x") && value.has("y"): 
				obj.set(property, Vector2(value["x"], value["y"]))
			else: 
				#print("from: %s property: %s, value %s" % [obj, property, value])
				#if property == "items": 
					#printerr("%s is dict" % value)
				#printerr(obj)
				#print("%s has dict" % obj.get(property))
				#printerr(value)
				#if obj.get(property) == null: 
					#printerr("%s get property: %s is null" % [obj, property])
				#printerr(obj)
				#printerr("property: %s" % property)
				load_dict_to_object(obj.get(property), value)
				#for value_prop: String in value.keys(): 
					#var value_value = value[value_prop]
					#obj.set(value_prop, value_value)
		elif value is Array: 
			#if property == "items": 
				#print("%s with Array: %s" % [obj, str(value)])
				#pass
			#print(obj)
			for i: int in value.size(): 
				
				# Supposed to be a dictionary
				var value_value = value[i]
				var obj_array: Array = obj.get(property)
				var obj_array_value = null
				
				# Supposed to check for the index
				if value_value is Dictionary: 
					if value_value.has(str(i)): 
						obj_array_value = value_value[str(i)]
					elif value_value.has(i): 
						obj_array_value = value_value[i]
				else: 
					obj_array_value = value_value
					
				#printerr(value_value)
				if obj_array_value == null:
					#print(value_value)
					printerr("ASDASd")
				
				#printerr("obj array: ", obj_array)
				if obj_array_value is Dictionary: 
					#if property == "items": 
						#printerr("%s is dict and from %s" % [str(value_value), obj])
					#load_dict_to_object(obj, value_value)
					if i < obj_array.size(): 
						#printerr("obj array item: %s with %s" % [obj.get(property)[i], value_value[str(i)]])
						load_dict_to_object(obj.get(property)[i], obj_array_value)
					
					# If the array does not have the item at that index. 
					elif i >= obj_array.size(): 
						# If the item is a SaveableResource
						if obj_array_value.has("script_resource_path"): 
							var resource = load(obj_array_value["script_resource_path"]).new()
							obj_array.append(resource)
							#print("from: ", obj_array)
							load_dict_to_object(obj_array[i], obj_array_value)
							obj.load_update(resource)
							#value.load_update()
							#printerr("to: ", obj_array)
				# FIXME: Idk if this is necessary
				else: 
					if i > obj_array.size(): 
						obj_array.append(obj_array_value)
					elif obj_array.size() != 0: 
						#printerr(obj_array.size())
						obj_array[i] = obj_array_value
		else: 
			#print(obj.get(property))
			#if property == "items": 
			#printerr("%s is none" % value)
			#print("obj: %s, property: %s" % [obj, property])
			obj.set(property, value)
			#printerr(obj.get(property))
