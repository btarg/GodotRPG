extends VBoxContainer

@onready var style_empty := preload("res://Assets/Themes/heart/pixel_black.tres") as StyleBoxFlat
@onready var style_full := preload("res://Assets/Themes/heart/pixel_red.tres") as StyleBoxFlat

@onready var heart_segments := get_tree().get_nodes_in_group("HeartSegment")

var max_hp := 200
var health := max_hp

var animate_health := health:
    get:
        return animate_health
    set(value):
        animate_health = value
        _update_segments()

func _ready() -> void:
    _update_segments()

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
    

func _update_segments() -> void:
    var health_percentage := float(animate_health) / float(max_hp)
    var health_segments := int(heart_segments.size() * health_percentage)
    for i in range(heart_segments.size()):
        var segment := heart_segments[i]
        if segment is Panel:
            _update_panel(segment, i >= heart_segments.size() - health_segments)

func _update_panel(to_update: Panel, full: bool = true) -> void:
    to_update.remove_theme_stylebox_override("panel")
    var style := style_full if full else style_empty
    to_update.add_theme_stylebox_override("panel", style)

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.is_pressed() and not event.is_echo():
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
