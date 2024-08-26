extends EcoQuestTaskScriptCondition
class_name TurnOffFaucetTaskCondition 

var listener: WorldEventListener

func _initialized() -> void: 
	if !WorldEventManager.event_called.is_connected(_on_event_called): 
		WorldEventManager.event_called.connect(_on_event_called)
	initialized()
	
	
func initialized() -> void: 
	var faucets: Array[Node] = tree.get_nodes_in_group("Faucet")
	#if PlayerManager.player_data.faucets_turned_off == maximum_points: 
		#counter.max_out()
		#return
	for faucet: Faucet in faucets: 
		if !faucet.is_on(): 
			counter.increment()
		else: 
			if !faucet.turned_off.is_connected(_on_faucet_turned_off): 
				faucet.turned_off.connect(_on_faucet_turned_off)
	update_current()
	
	
func _on_event_called(event: String, _by: Node, _args: Array) -> void: 
	if event == "ready": 
		initialized()
	
	
func update_current() -> void: 
	#await GameManager.get_tree().process_frame
	counter.current = PlayerManager.player_data.faucets_turned_off
	if counter.current == maximum_points: 
		counter.max_out()
	#printerr(counter.current)
	
	
func _on_faucet_turned_off() -> void: 
	update_current()
	
	
func _finished() -> void: 
	var faucets: Array[Node] = tree.get_nodes_in_group("Faucet")
	for faucet: Faucet in faucets: 
		if faucet.is_on(): 
			faucet.turned_off.disconnect(_on_faucet_turned_off)
	if WorldEventManager.event_called.is_connected(_on_event_called): 
		WorldEventManager.event_called.disconnect(_on_event_called)
