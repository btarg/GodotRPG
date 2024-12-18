extends Control

@onready var heart_pixel := preload("res://Assets/UIElements/heart_pixel.tscn") as PackedScene
@onready var style_empty := preload("res://Assets/Themes/heart/pixel_black.tres") as StyleBoxFlat
@onready var style_full := preload("res://Assets/Themes/heart/pixel_red.tres") as StyleBoxFlat

@onready var background_node := $"../HeartBackground" as Polygon2D

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


const PIXEL_PADDING := 1
@export var position_offset := Vector2.ZERO

func get_random_position_out_of_bounds() -> Vector2:
    var screen_size := get_viewport().get_visible_rect().size
    var result_pos := Vector2.ZERO

    var edge := randi() % 4
    match edge:
        0: # Top edge
            result_pos.x = randf_range(0, screen_size.x)
            result_pos.y = -10
        1: # Bottom edge
            result_pos.x = randf_range(0, screen_size.x)
            result_pos.y = screen_size.y + 10
        2: # Left edge
            result_pos.x = -10
            result_pos.y = randf_range(0, screen_size.y)
        3: # Right edge
            result_pos.x = screen_size.x + 10
            result_pos.y = randf_range(0, screen_size.y)

    return result_pos


func _ready() -> void:
    for row_num in range(rows.size()):
        for pixel_index in range(rows[row_num].size()):
            var row_filled := rows[row_num][pixel_index] as bool
            if not row_filled:
                continue
            var pixel_instance := heart_pixel.instantiate() as HeartPixel

            var pixel_size := pixel_instance.get_size().x
            # position the target nodes in a grid
            var target_pos := Vector2(
                (pixel_size + PIXEL_PADDING) * (pixel_index - rows[row_num].size() * 0.5),
                (pixel_size + PIXEL_PADDING) * (row_num - rows.size() * 0.5)
            ) + position_offset

            # add a target node as a child of this object
            var target := Control.new()
            target.name = "Target" + str(row_num) + str(pixel_index)
            add_child(target)
            target.set_position(target_pos)

            # add the heart_pixel to the root
            get_tree().root.add_child.call_deferred(pixel_instance)

            # spawn randomly around the edge of the screen
            pixel_instance.set_position(get_random_position_out_of_bounds())
            spawned_heart_pixels.append(pixel_instance)

            # Set target
            pixel_instance.pixel_target = target
            # pixel_instance.update_track_position(Vector2.ZERO)

    _update_segments_fill()

func cleanup() -> void:
    for p in spawned_heart_pixels:
        p.queue_free()
    spawned_heart_pixels.clear()

    # kill children
    for child in get_children():
        if child is HeartPixel:
            child.queue_free()

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
    # TODO: add animation for filling and emptying the pixel (e.g. shake)

func update_tracking_position(track: Vector2) -> void:
    set_global_position(track)
    get_tree().call_group("HeartSegment", "update_track_position", track)
    
    if background_node:
        background_node.set_global_position(track)

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

    # # on click set global position
    # if event is InputEventMouseButton:
    #     if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
    #         update_tracking_position(get_viewport().get_mouse_position())

    if event is InputEventMouseMotion:
        update_tracking_position(get_viewport().get_mouse_position())
