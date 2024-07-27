@tool
extends InteractableEntityNode
class_name TiedPlasticBags


@export var unlock_entities: Array[EntityNode]


func _ready() -> void: 
	for entity: EntityNode in unlock_entities: 
		entity.hide()
		entity.disabled = true


func _on_item_accepted(item_stack: ItemStack) -> void:
	for entity: EntityNode in unlock_entities: 
		entity.show()
		entity.disabled = false
		
