extends Node

@export var navbar: NavbarGUI


func play() -> void: 
	var anim: TweenArguments = TweenArguments.new().set_duration(1.5) 
	var tween: Tween = anim.create_tween(get_tree())
	
	navbar.position.y = -300
	tween.tween_property(navbar, "position", Vector2(0, 0), anim.duration)
	tween.play() 
	
	
	
