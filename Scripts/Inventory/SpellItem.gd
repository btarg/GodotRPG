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

enum CritBehaviour {
    CRIT_ON_ANY_NAT, # Any of the dice rolled is max value
    CRIT_ON_ALL_NAT, # All dice rolled are max value
    CRIT_ON_TWICE_DC # Total roll is twice the difficulty class
}

@export var spell_affinity: SpellAfinity = SpellAfinity.FIRE
@export var spell_power: int = 10
# @export var spell_range: int = 1
@export_range(4, 100) var die_sides: int = 20
@export_range(1, 10) var num_rolls: int = 1
@export_range(1, 100) var difficulty_class: int = 10
@export var crit_behaviour: CritBehaviour = CritBehaviour.CRIT_ON_ANY_NAT

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


func use(bonus: int = 0) -> UseStatus:
    var calculated_power: int = spell_power
    var total_roll: int = bonus
    var crits: int = 0
    # roll all dice and add together
    for i in range(num_rolls):
        var die := randi() % die_sides + 1
        total_roll += die
        # add upp crits
        var crit_string := ""
        if die == die_sides:
            crits += 1
            crit_string = " (Nat %s!)" % str(die_sides)

        print("Roll no." + str(i + 1) + ": " + str(die) + crit_string)
    print("Total Rolls: " + str(total_roll) + " Bonus: " + str(bonus))
    
    var status := UseStatus.CANNOT_USE
    if total_roll == 1:
        status = UseStatus.SPELL_CRIT_FAIL
        calculated_power = int(calculated_power * (power_multiplier_crit_fail))
    elif total_roll < difficulty_class:
        status = UseStatus.SPELL_FAIL
        calculated_power = int(calculated_power * (power_multiplier_fail))
    else:
        if crits > 0 and (
            crit_behaviour == CritBehaviour.CRIT_ON_ANY_NAT or
            crit_behaviour == CritBehaviour.CRIT_ON_ALL_NAT and crits == num_rolls
        ) or (crit_behaviour == CritBehaviour.CRIT_ON_TWICE_DC and total_roll >= (difficulty_class * 2)):
            status = UseStatus.SPELL_CRIT_SUCCESS
            calculated_power = int(calculated_power * (power_multiplier_crit_success))
        else:
            status = UseStatus.SPELL_SUCCESS
            calculated_power = int(calculated_power * (power_multiplier_success))
        

    if spell_affinity == SpellAfinity.HEAL:
        _handle_healing(calculated_power)
        
    elif status == UseStatus.SPELL_FAIL:
        print(item_name + " Spell Failed!")

    emit_signal("item_used", status)
    return status

func _handle_healing(heal_power: float) -> void:
    print(item_name + " Spell Healed " + str(heal_power) + " HP!")