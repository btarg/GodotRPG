class_name DiceRoller

enum CritBehaviour {
    CRIT_ON_ANY_NAT, # Any of the dice rolled is max value
    CRIT_ON_ALL_NAT, # All dice rolled are max value
    CRIT_ON_TWICE_DC # Total roll is twice the difficulty class
}
enum DiceStatus {
    ROLL_SUCCESS,
    ROLL_FAIL,
    ROLL_CRIT_SUCCESS,
    ROLL_CRIT_FAIL
}

static func roll(die_sides: int, difficulty_class: int, num_rolls: int = 1, crit_behaviour: CritBehaviour = CritBehaviour.CRIT_ON_ANY_NAT, bonus: int = 0) -> Array:
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

    var status := DiceStatus.ROLL_FAIL

    if total_roll == 1:
        status = DiceStatus.ROLL_CRIT_FAIL
    elif total_roll < difficulty_class:
        status = DiceStatus.ROLL_FAIL
    else:
        if crits > 0 and (
            crit_behaviour == CritBehaviour.CRIT_ON_ANY_NAT or
            crit_behaviour == CritBehaviour.CRIT_ON_ALL_NAT and crits == num_rolls
        ) or (crit_behaviour == CritBehaviour.CRIT_ON_TWICE_DC and total_roll >= (difficulty_class * 2)):
            status = DiceStatus.ROLL_CRIT_SUCCESS
        else:
            status = DiceStatus.ROLL_SUCCESS

    return [total_roll, crits, status]