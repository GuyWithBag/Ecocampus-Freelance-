@tool
extends EditorPlugin


func _enter_tree() -> void:
	#add_autoload_singleton("DebuggerGUI", "res://addons/macchi's_gui_manager/nodes/singletons/debugger_gui/debugger_gui.tscn")
	pass


func _exit_tree() -> void:
	#remove_autoload_singleton("DebuggerGUI")
	pass
