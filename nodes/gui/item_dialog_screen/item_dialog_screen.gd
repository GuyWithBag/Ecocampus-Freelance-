@tool
extends GUI
class_name ItemDialogScreen

#@export var data: InteractDialogData
@export var rich_text_description_format: RichLabelText

@export var description_label: Label
@export var rich_description_label: RichTextLabel


static func this() -> ItemDialogScreen: 
	return GameManager.get_tree().get_first_node_in_group("ItemDialogScreen")
	
	
func display(item: ItemModel) -> void: 
	show()
	
	
	#rich_label_text.format = StringFormatter.new()
	#
	#rich_label_text.format.format = \
#"[outline_size=4][outline_color=BLACK][b][font_size=38]%s[/font_size][/b]
#[font_size=28][b]Type:[/b] %s[/font_size]
#[font_size=28][b]Environmental Impact:[/b] %s[/font_size]"
	#
	
	rich_text_description_format.texts = [
		item.name, 
		GlobalVariables.get_enum_name(ItemModel.Type, item.type).to_pascal_case(), 
		item.description
	] as Array[String]
	
	var args: InteractDialogData = InteractDialogData.new()
	
	args.set_description(rich_text_description_format)
	
	if args.description is LabelText: 
		args.description.set_label(description_label)
		
	elif args.description is RichLabelText: 
		args.description.set_label(rich_description_label)
		rich_description_label.show()
		description_label.hide()
	
	
	
