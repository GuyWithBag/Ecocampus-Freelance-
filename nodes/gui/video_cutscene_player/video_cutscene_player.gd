extends GUI
class_name VideoCutscenePlayer


#@export var video_stream: VideoStreamTheora

@export var video_stream_player: VideoStreamPlayer
@export var fade_in: ColorPropertyLerpComponent
@export var fade_out: ColorPropertyLerpComponent
@export var music_volume_slider: AudioBusVolumeSlider

static func this() -> VideoCutscenePlayer: 
	return GameManager.get_tree().get_first_node_in_group("VideoCutscenePlayer")


static func play_absolute() -> void: 
	VideoCutscenePlayer.this().play()


func play() -> void: 
	await get_tree().create_timer(0.1).timeout
	GUIManager.set_gui_active(VideoCutscenePlayer.this(), true)
	video_stream_player.finished.connect(
		func(): 
			GUIManager.set_gui_active(VideoCutscenePlayer.this(), false)
	, CONNECT_ONE_SHOT
	)
	#video_stream_player.stream = stream
	video_stream_player.play()
	
	
func _activated() -> void: 
	show()
	visible = true
	#get_tree().paused = true
	video_stream_player.paused = false
	music_volume_slider.mute = true
	fade_out.process_enabled = true
	fade_in.finished.connect(
		func(): 
			fade_out.process_enabled = false
	, CONNECT_ONE_SHOT
	)
	fade_in.play()
	
	
func _deactivated() -> void: 
	fade_out.process_enabled = true
	music_volume_slider.mute = false
	fade_out.finished.connect(
		func(): 
			hide()
			fade_out.process_enabled = false
	, CONNECT_ONE_SHOT
	)
	fade_out.play()
	#get_tree().paused = true
	video_stream_player.paused = true


func _on_skip_button_pressed() -> void:
	GUIManager.set_gui_active(VideoCutscenePlayer.this(), false)
