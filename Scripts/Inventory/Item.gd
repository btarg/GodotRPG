class_name BaseInventoryItem
extends Resource

enum ItemType {
	WEAPON,
	ARMOR,
	CONSUMABLE_HP,
	CONSUMABLE_MP,
	QUEST,
	MISC
}

# Declare the class and its properties
@export var item_type: ItemType = ItemType.WEAPON
@export var item_id: String = ""
@export var item_name: String = ""
@export var item_description: String = "Test Description"
@export var max_stack: int = 999

# Constructor for easy creation
func _init(_item_name: String = "", _max_stack: int = 999):
	self.item_name = _item_name
	self.max_stack = _max_stack

func get_rich_name(icon_size: int = 64) -> String:
	# icon path switch statement based on enum type
	var icon_path: String = ""
	match item_type:
		ItemType.WEAPON:
			icon_path = "res://Assets/Icons/item_weapon.png"
		ItemType.ARMOR:
			icon_path = "res://Assets/Icons/item_misc.png"
		ItemType.CONSUMABLE_HP:
			icon_path = "res://Assets/Icons/item_consumable_hp.png"
		ItemType.CONSUMABLE_MP:
			icon_path = "res://Assets/Icons/item_consumable_sp.png"

		ItemType.QUEST:
			icon_path = "res://Assets/Icons/item_quest.png"
		ItemType.MISC:
			icon_path = "res://Assets/Icons/item_misc.png"
		_:
			icon_path = "res://Assets/Icons/item_misc.png"

	return "[hint=%s][img=%s]%s[/img]%s[/hint]" % [item_description, icon_size, icon_path, item_name]