class_name SpellItem extends BaseInventoryItem

enum SpellAfinity {
    PHYS,
    FIRE,
    ICE,
    ELEC,
    WIND,
    LIGHT,
    DARK,
    HEAL
}
@export var spell_affinity: SpellAfinity = SpellAfinity.FIRE
@export var spell_power: int = 10
@export var spell_range: int = 1
@export var rolls: int = 1
@export var difficulty_class: int = 10

func get_icon_path() -> String:
    var icon_path := "res://Assets/Icons/elements/"
    match spell_affinity:
        SpellAfinity.PHYS:
            icon_path += "phys"
        SpellAfinity.FIRE:
            icon_path += "fire"
        SpellAfinity.ICE:
            icon_path += "ice"
        SpellAfinity.ELEC:
            icon_path += "elec"
        SpellAfinity.WIND:
            icon_path += "wind"
        SpellAfinity.LIGHT:
            icon_path += "light"
        SpellAfinity.DARK:
            icon_path += "dark"
        SpellAfinity.HEAL:
            icon_path += "heal"
        _:
            icon_path = "heal"

    icon_path += "_element.png"


    return icon_path

func use() -> UseStatus:

    # Roll d20s based on roll amount
    var roll := 0
    for i in range(rolls):
        roll += randi() % 20 + 1

    print("Roll: " + str(roll))
    var status := UseStatus.CANNOT_USE
    if roll == 1:
        status = UseStatus.SPELL_CRIT_FAIL
    elif roll == 20:
        status = UseStatus.SPELL_CRIT_SUCCESS
    elif roll < difficulty_class - 10:
        status = UseStatus.SPELL_FAIL
    elif roll >= difficulty_class - 10 and roll < difficulty_class:
        status = UseStatus.SPELL_SUCCESS
    else:
        status = UseStatus.SPELL_FAIL

    if spell_affinity == SpellAfinity.HEAL and status != UseStatus.SPELL_FAIL and status != UseStatus.SPELL_CRIT_FAIL:
        var calculated_power := spell_power
        if status == UseStatus.SPELL_CRIT_SUCCESS:
            calculated_power *= 2
        elif status == UseStatus.SPELL_SUCCESS:
            calculated_power = int(calculated_power * 1.5)
        print(item_name + " Spell Healed " + str(calculated_power) + " HP!")

    elif status == UseStatus.SPELL_FAIL:
        print(item_name + " Spell Failed!")

    return status

func _on_roll_crit_fail() -> void:
    print("Roll Crit Fail!")
func _on_roll_crit_succcess() -> void:
    print("Roll Crit!")
func _on_roll_fail() -> void:
    print("Roll Fail!")
func _on_roll_success() -> void:
    print("Roll Success!")