extends NodeComponent
class_name DisablePlayerOnThisScene


func _ready() -> void: 
	if PlayerManager.player: 
		PlayerManager.player.state_chart.send_event("disabled")
