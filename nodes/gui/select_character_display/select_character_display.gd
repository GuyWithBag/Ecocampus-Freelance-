@tool
extends CenterContainer
class_name SelectCharacterDisplay

@export var player_data: Entity
@export var gender: GlobalEnums.Gender: 
	set(value): 
		gender = value
		if !is_node_ready(): 
			await ready
		if gender == GlobalEnums.Gender.MALE: 
			sprites_switcher.current_tab = 0
			gender_label.text = "Male Character"
		else: 
			sprites_switcher.current_tab = 1
			gender_label.text = "Female Character"
		
@export var sprites_switcher: TabContainer
@export var gender_label: Label
@export var to_map_picker: ChangeSceneComponent
#@export_file("*.ogv") var cutscene_path: String

@export var animation_player: AnimationPlayer
@export var animation_direction: String = "from_left"


func _ready() -> void: 
	animation_player.play(animation_direction)


func _on_on_control_tapped() -> void:
	player_data.gender = gender
	to_map_picker.change()
	#var stream: VideoStreamTheora = VideoStreamTheora.new()
	#stream.file = cutscene_path
	VideoCutscenePlayer.play_absolute()
