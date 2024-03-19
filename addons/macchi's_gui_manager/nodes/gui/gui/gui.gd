# All gui related things that can be controled by the GUIManager. 
# All code that shows the gui must start at set_active(), also so it is less prone to bugs. 
@tool
extends Control 
class_name GUI

signal activated 
signal deactivated

# GUIType are for identifying what types of guis are focused. 

#enum Alias {
	#NONE, 
	#INVENTORY, 
	#PAUSE, 
	#INTERACT_OPTIONS, 
#}

# FUN_FACT: Setting a default value, it will call this setter first, 
# then if you set another value from the editor, it will call it but after the default value. Happy Coding! 
@export var inactive_on_ready = true: 
	set(value): 
		inactive_on_ready = value
		#if !is_node_ready(): 
			#await ready
		#if name == "EnterNameMenu": 
			#printerr(self, value)
			#print()
@export var active: bool = true: set = set_active
@export var alias: String

@export var disabled: bool = false

@export var acting_container: ActingContainer

var _initialized: bool = false
	
	
#func _ready() -> void: 
	#print(self, _initialized, active)
	

## Activateds and makes the gui visible. Never use this method, only use GUIManager.set_gui_active. 
func set_active(value: bool) -> void: 
	if disabled: 
		return
	#_initialized = false
	if !is_node_ready(): 
		await ready
	#if name == "EnterNameMenu": 
		#printerr(self, value)
		#print()
		#printerr(name)
	#printerr(self, _initialized)
	if !Engine.is_editor_hint(): 
		if inactive_on_ready && _initialized == false: 
			visible = false
			active = false
			_initialized = true 
			#printerr(self, active)
			return
	if value && _activate_condition(): 
		active = true
		set_process(true)
		_activated()
		activated.emit()
		_initialized = true
	elif !value && _deactivate_condition(): 
		active = false
		set_process(false)
		_deactivated()
		deactivated.emit()

	
	
#func activate() -> void: 
	#active = true
	#_activated()
	#activated.emit()
	#
	#
#func deactivate() -> void: 
	#active = false
	#_deactivated()
	#deactivated.emit()
	
	
func _activated() -> void: 
	visible = true
	
	
func _deactivated() -> void: 
	visible = false
	
	
func _activate_condition() -> bool: 
	return true
	
	
func _deactivate_condition() -> bool: 
	return true
