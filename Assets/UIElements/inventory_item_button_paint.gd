extends Control
class_name InventoryItemButtonPaint

@onready var item_name_label := $Paint/Label as Label
@onready var count_background := $Paint/CountBG as Panel

var shader_mat: ShaderMaterial
var count_style_box: StyleBoxFlat

var tweens: Array[Tween] = []

const TEXT_COLOR := Color(213, 207, 190, 1)
const COUNT_BACKGROUND_COLOR := Color(217, 217, 217, 1)

const TRANSITION_TIME := 0.3

func _ready() -> void:
    # make unique
    shader_mat = $Paint.material.duplicate()
    $Paint.material = shader_mat
    # set shader parameter "progress" to 0.0
    shader_mat.set_shader_parameter("progress", 0.0)

    item_name_label.label_settings.font_color = TEXT_COLOR
    # make unique
    item_name_label.label_settings = item_name_label.label_settings.duplicate()

    count_style_box = count_background.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
    count_background.add_theme_stylebox_override("panel", count_style_box)
    count_style_box.bg_color = COUNT_BACKGROUND_COLOR

    for child in count_background.get_children():
        if child is Label:
            # make unique
            child.label_settings = child.label_settings.duplicate()
            child.label_settings.font_color = Color.BLACK

    focus_entered.connect(_on_focus_entered)
    focus_exited.connect(_on_focus_exited)
    mouse_entered.connect(_on_mouse_entered)


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
        print("clicked on " + name)
    elif event is InputEventKey and event.keycode == KEY_ENTER and event.is_pressed():
        print("pressed enter on " + name)

func _on_mouse_entered() -> void:
    # call focus_entered
    grab_focus()

func _on_focus_entered() -> void:
    kill_tweens()
    var tween := create_tween()
    tweens.append(tween)
    # tween the shader property "progress"
    tween.tween_property(item_name_label.label_settings, "font_color", Color.BLACK, 0.05)
    tween.tween_property(shader_mat, "shader_parameter/progress", 0.5, TRANSITION_TIME).set_trans(Tween.TRANS_SINE)
    
    count_style_box.bg_color = Color.BLACK

    for child in count_background.get_children():
        if child is Label:
            child.label_settings.font_color = TEXT_COLOR

func _on_focus_exited() -> void:
    kill_tweens()
    shader_mat.set_shader_parameter("progress", 1.0)
    var tween := create_tween()
    tweens.append(tween)
    tween.tween_property(item_name_label.label_settings, "font_color", TEXT_COLOR, 0.05)
    tween.tween_property(shader_mat, "shader_parameter/progress", 0.0, TRANSITION_TIME / 2)

    count_style_box.bg_color = COUNT_BACKGROUND_COLOR

    for child in count_background.get_children():
        if child is Label:
            child.label_settings.font_color = Color.BLACK
    

func kill_tweens() -> void:
    for tween in tweens:
        tween.kill()
    tweens.clear()