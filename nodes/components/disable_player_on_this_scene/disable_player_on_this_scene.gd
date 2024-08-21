extends NodeComponent
class_name DisablePlayerOnThisScene

var flag: bool = false

func _process(delta: float) -> void:
	#await PlayerManager.player_instanced
	if flag: 
		return
		
	if PlayerManager.player: 
		PlayerManager.player.state_chart.send_event("disabled")
		flag = true
