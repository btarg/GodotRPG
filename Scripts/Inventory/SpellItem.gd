class_name SpellItem extends BaseInventoryItem

enum SpellAfinity {
    PHYS,
    FIRE,
    ICE,
    ELEC,
    WIND,
    LIGHT,
    DARK,
    HEAL,
    MANA
}

@export var spell_affinity: SpellAfinity = SpellAfinity.FIRE
@export var spell_power: int = 10
# @export var spell_range: int = 1
@export_range(4, 100) var die_sides: int = 20
@export_range(1, 10) var num_rolls: int = 1
@export_range(1, 100) var difficulty_class: int = 10
@export var crit_behaviour: DiceRoller.CritBehaviour = DiceRoller.CritBehaviour.CRIT_ON_ANY_NAT

@export var power_multiplier_success: float = 1.0
@export var power_multiplier_crit_success: float = 2.0
@export var power_multiplier_fail: float = 0.5
@export var power_multiplier_crit_fail: float = 0.0


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

func get_use_sound(status: UseStatus = UseStatus.SPELL_SUCCESS) -> AudioStream:
    if (spell_affinity == SpellAfinity.HEAL and
    status == UseStatus.SPELL_SUCCESS or
    status == UseStatus.SPELL_CRIT_SUCCESS
    ):
        return heal_sound
    return null


func use() -> UseStatus:
    var calculated_power := spell_power
    var result := DiceRoller.roll(die_sides, difficulty_class, num_rolls, crit_behaviour)
    
    var dice_status := result[1] as DiceRoller.DiceStatus
    var status := UseStatus.SPELL_FAIL

    match dice_status:
        DiceRoller.DiceStatus.ROLL_CRIT_SUCCESS:
            calculated_power *= power_multiplier_crit_success
            status = UseStatus.SPELL_CRIT_SUCCESS
        DiceRoller.DiceStatus.ROLL_SUCCESS:
            calculated_power *= power_multiplier_success
            status = UseStatus.SPELL_SUCCESS
        DiceRoller.DiceStatus.ROLL_CRIT_FAIL:
            calculated_power *= power_multiplier_crit_fail
            status = UseStatus.SPELL_CRIT_FAIL
        DiceRoller.DiceStatus.ROLL_FAIL:
            calculated_power *= power_multiplier_fail
            status = UseStatus.SPELL_FAIL

    if spell_affinity == SpellAfinity.HEAL:
        _handle_healing(calculated_power)
    elif status == UseStatus.SPELL_FAIL:
        print(item_name + " Spell Failed!")

    emit_signal("item_used", status)
    return status

func _handle_healing(heal_power: float) -> void:
    print(item_name + " Spell Healed " + str(heal_power) + " HP!")