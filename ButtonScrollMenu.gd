extends Control

var buttons: Array[Control] = []
var count: Array[float] = []

var index: int = 0
var selected_button: Control = null

var scroll: float = 1
var current_mouse_input_cooldown: float = 0
@export var mouse_input_cooldown: float = 0.40

@export var button_spacing_offset := 50
var button_spacing: int = -1

@export var button_scene = preload("res://Assets/UIElements/InventoryItemButtonPaint.tscn") as PackedScene
@onready var scrollbar_visual := $ColorRect/scroll as ColorRect
@onready var SCROLLBAR_BOTTOM := scrollbar_visual.position.y

func add_button() -> void:
    var new_button := button_scene.instantiate() as InventoryItemButtonPaint

    # initialize button spacing
    if button_spacing == -1:
        button_spacing = round(new_button.size.y) + button_spacing_offset
        print("New button spacing: " + str(button_spacing))
    
    new_button.connect("mouse_entered", _handleButtonFocus.bind(new_button))

    buttons.append(new_button)
    count.append(0)
    $ClipControl.add_child(new_button)

func update_index(direction: int = -1, wraparound: bool = true) -> void:
    current_mouse_input_cooldown = mouse_input_cooldown

    index += direction
    if wraparound:
        if index >= buttons.size():
            index = 0
        elif index < 0:
            index = buttons.size() - 1
    else:
        index = clamp(index, 0, buttons.size() - 1)

    scroll = clamp((index - 2) * -button_spacing, -button_spacing * (buttons.size() - 1), 0)

    update_focus()

func _input(event: InputEvent) -> void:
    if Input.is_action_just_pressed("ui_cancel"):
        add_button()

    if button_spacing == -1:
        return
    
    if Input.is_action_pressed("ui_up"):
        update_index(-1)
    elif Input.is_action_pressed("ui_down"):
        update_index(1)
    elif event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_pressed():
            update_index(-1, false)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_pressed():
            update_index(1, false)

func _physics_process(delta: float) -> void:
    if button_spacing == -1:
        scrollbar_visual.hide()
        return

    for i in range(buttons.size()):
        count[i] -= delta
        if count[i] < 0:
            var target_position = Vector2(0, i * button_spacing + scroll)
            if i == 0:
                target_position.y = scroll
            buttons[i].position = buttons[i].position.lerp(target_position, delta * 20)

    scrollbar_visual.show()
    scrollbar_visual.position.y = lerp(scrollbar_visual.position.y, 2 + (float(index) / float(buttons.size() - 1)) * 188.00, 0.1) if buttons.size() > 1 else 2
    scrollbar_visual.position.y = clamp(scrollbar_visual.position.y, 2, SCROLLBAR_BOTTOM)
    
    selected_button = buttons[index]
    selected_button.grab_focus()

    current_mouse_input_cooldown -= delta
    if current_mouse_input_cooldown < 0:
        current_mouse_input_cooldown = 0


func update_focus() -> void:
    for i in range(buttons.size()):
        if i == index:
            buttons[i].grab_focus()
        else:
            buttons[i].release_focus()
    print("Selected index: " + str(index))

func _handleButtonFocus(focused_button: Control) -> void:
    if current_mouse_input_cooldown == 0:
        index = buttons.find(focused_button)

func _handleButtonPressed(pressed_button: Control) -> void:
    print("Button pressed: " + pressed_button.name)