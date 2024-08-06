class_name BaseInventoryItem
extends Resource

enum ItemType {
    SPELL,
    WEAPON,
    ARMOR,
    CONSUMABLE_HP,
    CONSUMABLE_MP,
    QUEST,
    MISC
}
enum UseStatus {
    SPELL_FAIL,
    SPELL_SUCCESS,
    SPELL_CRIT_FAIL,
    SPELL_CRIT_SUCCESS,
    CONSUMED_HP,
    CONSUMED_MP,
    CANNOT_USE,
    EQUIPPED
}

@export var item_type: ItemType = ItemType.WEAPON
@export var item_id: String = ""
@export var item_name: String = "???"
@export var item_description: String = "Test Description"
@export var max_stack: int = 999
signal item_used

# Preload audio types
var heal_sound := preload("res://Assets/Sounds/heal.wav") as AudioStream
var mana_sound := preload("res://Assets/Sounds/mana.wav") as AudioStream

func _init(_item_name: String = "", _max_stack: int = 999) -> void:
    self.item_name = _item_name
    self.max_stack = _max_stack

func get_icon_path() -> String:
    var icon_path := "res://Assets/Icons/item_"
    match item_type:
        ItemType.WEAPON:
            icon_path += "weapon"
        ItemType.ARMOR:
            icon_path += "misc"
        ItemType.CONSUMABLE_HP:
            icon_path += "consumable_hp"
        ItemType.CONSUMABLE_MP:
            icon_path += "consumable_sp"
        ItemType.QUEST:
            icon_path += "quest"
        ItemType.MISC:
            icon_path += "misc"
        _:
            icon_path += "misc"
    return icon_path + ".png"

func get_rich_name(icon_size: int = 64) -> String:
    var icon_path = get_icon_path()
    return "[hint=%s][img=%s]%s[/img]%s[/hint]" % [item_description, icon_size, icon_path, item_name]

func get_use_sound() -> AudioStream:
    match item_type:
        ItemType.CONSUMABLE_HP:
            return heal_sound
        ItemType.CONSUMABLE_MP:
            return mana_sound
        _:
            return null

func use() -> UseStatus:
    var status: UseStatus

    match item_type:
        ItemType.CONSUMABLE_HP:
            print("HP Item used: %s" % item_name)
            status = UseStatus.CONSUMED_HP
        ItemType.CONSUMABLE_MP:
            print("MP Item used: %s" % item_name)
            status = UseStatus.CONSUMED_MP
        _:
            print("Item cannot be consumed: %s" % item_name)
            status = UseStatus.CANNOT_USE

    emit_signal("item_used", status)
    return status
