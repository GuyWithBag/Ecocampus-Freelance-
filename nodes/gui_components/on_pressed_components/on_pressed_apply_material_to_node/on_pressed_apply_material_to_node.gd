extends OnPressedComponent
class_name OnPressedApplyShaderToNode



@export var material: Material: 
	set(value): 
		material = value
		if !is_node_ready(): 
			await ready
		if !control.is_node_ready(): 
			await control.ready
		apply_material_to_node.material = material
		
@export var duration: float: 
	set(value): 
		duration = value
		if !is_node_ready(): 
			await ready
		if !apply_material_to_node.is_node_ready(): 
			await apply_material_to_node.ready
		apply_material_to_node.duration = duration
		
@export var apply_to_node: Node: 
	set(value): 
		apply_to_node = value
		if !is_node_ready(): 
			await ready
		if !apply_material_to_node.is_node_ready(): 
			await apply_material_to_node.ready
		apply_material_to_node.node = apply_to_node

@export var apply_material_to_node: ApplyMaterialToNode


func _on_pressed() -> void: 
	apply_material_to_node.toggle()
