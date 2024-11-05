extends Panel
class_name HeartPixel

var pixel_target: Control
var _track_location := Vector2.ZERO

var should_track := true

const SPEED_MULTIPLIER := 100

func update_track_position(track: Vector2) -> void:
    if should_track:
        _track_location = track

func _physics_process(_delta: float) -> void:
    if pixel_target == null or not should_track:
        return

    var target_pos := pixel_target.global_position
    var distance_to_track_location := global_position.distance_to(_track_location)

    # Calculate interpolation factor based on inverse distance (closer pixels move faster)
    var factor := sin((1.0 / (distance_to_track_location + SPEED_MULTIPLIER))) * SPEED_MULTIPLIER
    set_global_position(global_position.lerp(target_pos, factor))
