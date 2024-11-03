extends Control

@onready var heart_pixel := preload("res://Assets/UIElements/heart_pixel.tscn") as PackedScene
@onready var style_empty := preload("res://Assets/Themes/heart/pixel_black.tres") as StyleBoxFlat
@onready var style_full := preload("res://Assets/Themes/heart/pixel_red.tres") as StyleBoxFlat

var spawned_heart_pixels: Array[Panel] = []
const rows: Array[Array] = [
        [false, true, false, true, false],
        [true, true, true, true, true],
        [true, true, true, true, true],
        [false, true, true, true, false],
        [false, false, true, false, false]
    ]


var max_hp := 200
var health := max_hp

var animate_health := health:
    get:
        return animate_health
    set(value):
        animate_health = value
        _update_segments_fill()

# Key is heart_pixel instance id, Value is Tween instance
var tweens: Dictionary = {}

# Key: heart_pixel instance id, Value: target object instance
var pixel_position_targets: Dictionary = {}

func _ready() -> void:
    for row_num in range(rows.size()):
        for pixel_index in range(rows[row_num].size()):
            var row_filled := rows[row_num][pixel_index] as bool
            if not row_filled:
                continue
            var pixel_instance := heart_pixel.instantiate() as Panel

            var pixel_size := pixel_instance.get_size().x
            var padding_offset := pixel_size / 16

            var pixel_x := ((pixel_size + padding_offset) * pixel_index)
            var pixel_y := ((pixel_size + padding_offset) * row_num)
            var target_pos := Vector2(pixel_x, pixel_y)

            # add a target node as a child of this object
            var target := Control.new()
            add_child(target)
            target.set_position(target_pos)
            # add the heart_pixel to the scene
            get_tree().root.add_child.call_deferred(pixel_instance)
            pixel_instance.name = "HeartPixel" + str(pixel_index)

            # spawn around the edge of the screen
            pixel_instance.set_position(get_viewport().get_visible_rect().size)
            spawned_heart_pixels.append(pixel_instance)

            # store the target object reference for the heart_pixel
            pixel_position_targets[pixel_instance.get_instance_id()] = target

    _update_segments_fill()

func cleanup() -> void:
    for p in spawned_heart_pixels:
        p.queue_free()
    for t in pixel_position_targets.values():
        t.queue_free()
    for tw in tweens.values():
        tw.kill()

    spawned_heart_pixels.clear()
    pixel_position_targets.clear()
    tweens.clear()

func move_to_position(destination: Vector2) -> void:
    set_global_position(destination)
    for pixel_id in pixel_position_targets.keys():
        var pixel_from_id := instance_from_id(pixel_id) as Control
        var target := pixel_position_targets[pixel_id] as Control

        var target_pos := target.get_global_position()
        var distance := pixel_from_id.global_position.distance_to(destination)
        
        # Calculate duration based on distance (closer pixels move faster)
        var duration := distance / 1000.0

        if tweens.has(pixel_id):
            tweens[pixel_id].kill()
            tweens.erase(pixel_id)
        var tween = tweens.get_or_add(pixel_id, create_tween())
        tween.tween_property(pixel_from_id, "global_position", target_pos, duration).set_trans(Tween.TRANS_SINE)


func set_health(value: int) -> void:
    var difference: int = abs(health - value)
    print("Health difference: ", difference)
    
    # set actual health value instantly
    health = value
    if health < 0:
        health = 0
    elif health > max_hp:
        health = max_hp

    # get difference percentage
    var percentage := float(difference) / float(max_hp)
    print("Health diff percentage: ", percentage)
    # only animate large percentage changes
    if percentage >= 0.25:
        # animate health value
        var tween = get_tree().create_tween()
        tween.tween_property(self, "animate_health", value, percentage * 0.45)
    else:
        animate_health = value
    

func _update_segments_fill() -> void:
    var health_percentage := float(animate_health) / float(max_hp)
    var health_segments := int(spawned_heart_pixels.size() * health_percentage)
    for i in range(spawned_heart_pixels.size()):
        var segment := spawned_heart_pixels[i]
        if segment is Panel:
            _update_panel(segment, i >= spawned_heart_pixels.size() - health_segments)

func _update_panel(to_update: Panel, full: bool = true) -> void:
    to_update.remove_theme_stylebox_override("panel")
    var style := style_full if full else style_empty
    to_update.add_theme_stylebox_override("panel", style)

func _input(event: InputEvent) -> void:
    if event.is_echo():
        return

    if event is InputEventKey and event.is_pressed():
        if event.keycode == KEY_ESCAPE:
            get_tree().quit()
        elif event.keycode == KEY_DOWN:
            set_health(0)
        elif event.keycode == KEY_UP:
            set_health(max_hp)
        elif event.keycode == KEY_LEFT:
            set_health(health - 50)
        elif event.keycode == KEY_RIGHT:
            set_health(health + 50)
        elif event.keycode == KEY_SPACE:
            _ready()
        elif event.keycode == KEY_C:
            cleanup()

    elif event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
            var move_target := get_viewport().get_mouse_position()
            move_to_position(move_target)

    # elif event is InputEventMouseMotion:
    #     var move_target := get_viewport().get_mouse_position()
    #     set_position(move_target)
