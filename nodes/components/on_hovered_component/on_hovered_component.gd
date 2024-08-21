@tool
extends NodeComponent
class_name OnHoveredComponent


@export var control: Control: 
	set(value): 
		control = value
		
		if !is_node_ready(): 
			await ready
			
		if !control.is_node_ready(): 
			await control.ready
		if control == null: 
			return
			
		control.mouse_entered.connect(
			func(): 
				is_hovering = true
				_on_mouse_entered()
		)
		control.mouse_exited.connect(
			func(): 
				_on_mouse_exited()
				is_hovering = false
		)

var is_hovering: bool


func _on_mouse_entered() -> void: 
	pass


func _on_mouse_exited() -> void: 
	pass
