extends BaseGUIManager


@export var transitions_manager: TransitionsManager
@export var dialogue_gui_manager: DialogueGUIManager

@export var customize_character_screen: CustomizeCharacterScreen
@export var settings_menu: SettingsMenu
@export var quiz_attempt_screen: QuizAttemptScreen
@export var achievement_unlocked_screen: AchievementUnlockedScreen

@export var player_hud: PlayerHUD
@export var item_obtained_screen: ItemObtainedScreen
@export var intro_animation: Node

func reset() -> void: 
	GUIManager.set_gui_active(quiz_attempt_screen, false)
	GUIManager.set_gui_active(GUIManager.dialogue_gui_manager, false)
	if AchievementUnlockedScreen.this() != null: 
		GUIManager.set_gui_active(AchievementUnlockedScreen.this(), false)
