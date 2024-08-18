@tool
extends Resource
class_name PrintColor 

@export var disabled: bool
@export var color: Color
@export var owner_name_color: Color = Color("0000ff")
@export var value_color: Color = Color("ff0000")
@export var automatic_value_color: bool = true
@export var use_spaces_for_node_name: bool

var owner: Object

## Bandiad solution
var production_disabled: bool = true

func out(output: String) -> void: 
	if production_disabled: 
		return
	if disabled: 
		return
	print_rich("[color=%s]%s" % [color.to_html(), output])
	
	
func out_debug(output: String) -> void: 
	if production_disabled: 
		return
		
	if disabled: 
		return
	var node_name: String
	if is_instance_valid(owner): 
		node_name = owner.name
	else: 
		node_name = str(owner)
	if use_spaces_for_node_name: 
		node_name = node_name.capitalize()
	print_rich("[color=%s]%s: [color=%s]%s" % [owner_name_color.to_html(), node_name, color.to_html(), output])
	
	
func out_debug_wvalue(output: String, real_value) -> void: 
	if production_disabled: 
		return
	if disabled: 
		return
	var final_color: Color = value_color
	#if !(val is String): 
		#val = str(val)
	if automatic_value_color: 
		if real_value is int || real_value is float: 
			final_color = GlobalVariables.COLOR_EDITOR_LIGHT_GREEN
		elif real_value is Array: 
			final_color = GlobalVariables.COLOR_EDITOR_GREEN
		elif real_value is bool && real_value == true: 
			final_color = GlobalVariables.COLOR_EDITOR_GREEN
		elif real_value is bool && real_value == false: 
			final_color = GlobalVariables.COLOR_EDITOR_RED
		elif real_value is Vector2: 
			final_color = GlobalVariables.COLOR_EDITOR_GREEN
		elif !is_instance_valid(real_value) && !(real_value is String) && !(real_value is StringName): 
			final_color = GlobalVariables.COLOR_EDITOR_RED
		elif real_value is Object: 
			final_color = GlobalVariables.COLOR_EDITOR_LIGHT_GREEN
		else: 
			final_color = GlobalVariables.COLOR_EDITOR_YELLOW
			
	out_debug("%s: [color=%s]%s" % [output, final_color.to_html(), real_value])
	
	
