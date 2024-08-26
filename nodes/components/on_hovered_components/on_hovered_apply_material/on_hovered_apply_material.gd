@tool
extends OnHoveredComponent
class_name OnHoveredApplyMaterial

@export var disabled: bool
@export var material: Material: 
	set(value): 
		material = value
		if !is_node_ready(): 
			await ready
		if !control.is_node_ready(): 
			await control.ready
		apply_material_to_node.material = material
		
@export var apply_to_node: Node: 
	set(value): 
		apply_to_node = value
		if !is_node_ready(): 
			await ready
		if !apply_material_to_node.is_node_ready(): 
			await apply_material_to_node.ready
		apply_material_to_node.node = apply_to_node

@export var apply_material_to_node: ApplyMaterialToNode


func _on_mouse_entered() -> void: 
	if disabled: 
		return
	apply_material_to_node.apply = true


func _on_mouse_exited() -> void: 
	if disabled: 
		return
	apply_material_to_node.apply = false
	
	
