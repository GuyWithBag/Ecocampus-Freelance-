@tool
extends Sprite2D
class_name PlayerSpriteDisplay


@export var player: Player: 
	set(value): 
		player = value
		player.gender_changed.connect(
			update
		)
		update()


func _ready() -> void: 
	update()
	

func update() -> void: 
	if !is_node_ready(): 
		await ready
	texture = player.current_cosmetic.get_icon(player.gender)
