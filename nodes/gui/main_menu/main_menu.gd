extends MainScreen
class_name MainMenu

@export var print_color: PrintColor: 
	set(value): 
		print_color = value
		print_color.owner = self
@export var body: Control

var flag: bool

func _ready() -> void:
	super._ready()
	BackManager.history.data.clear()
	print_color.out_debug_wvalue("Does have save?", SaveManager.does_save_file_name_exists("save_file_1"))
	
	
func _physics_process(_delta: float) -> void: 
	if flag: 
		return
		
	shake_animation()
	flag = true
	

func shake_animation() -> void: 
	#var orig_pos: Vector2 = 
	var anim: TweenArguments = TweenArguments.new().set_duration(3).set_ease_type(Tween.EASE_IN_OUT)
	var tween: Tween = anim.create_tween(get_tree()).set_loops()
	tree_exited.connect(
		func(): 
			tween.kill()
	, CONNECT_ONE_SHOT
	)
	var orig_pos: Vector2 = body.position
	
	var anim_offset: int = 20
	tween.tween_property(body, "position", orig_pos + Vector2(0, 0), anim.duration)
	tween.tween_property(body, "position", orig_pos + Vector2(0, anim_offset), anim.duration)
	#tween.tween_property(body, "position", orig_pos + Vector2(anim_offset, anim_offset), anim.duration)
	#tween.tween_property(body, "position", orig_pos + Vector2(-anim_offset, -anim_offset), anim.duration)
	tween.play()
