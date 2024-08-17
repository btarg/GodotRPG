extends Control

var buttons: Array[Button] = []
# Dictionary to map buttons to their index in the array for easy lookup
var button_map = {}
var count: Array[float] = []

var index: int = 0
var selected_button: Button = null

var scroll: int = 1
var current_mouse_input_cooldown: float = 0
## Cooldown to apply to mouse input after scrolling (physics delta time)
@export var mouse_input_cooldown: float = 0.40


## Spacing between each button relative to the button's size
@export var button_spacing_offset := 50
var button_spacing: int = -1

@export var button_scene = preload("res://Assets/UIElements/InventoryItemButton.tscn") as PackedScene

@onready var scrollbar_visual := $ColorRect/scroll as ColorRect
@onready var select_fx := $select_fx as Polygon2D
    

func add_button() -> void:
    var new_button := button_scene.instantiate() as Button
    # initialize button spacing
    if button_spacing == -1:
        button_spacing = round(new_button.size.y) + button_spacing_offset
        print("New button spacing: " + str(button_spacing))
    
    new_button.connect("mouse_entered", _handleButtonFocus.bind(new_button))
    new_button.connect("pressed", _handleButtonPressed.bind(new_button))

    buttons.append(new_button)
    button_map[new_button] = buttons.size() - 1 # Add button to the dictionary with its index
    count.append(0)
    add_child(new_button)


func update_index(direction: int = -1, wraparound: bool = true) -> void:
    # don't allow mouse hover for a short time after scrolling
    # this avoids the scroll jumping toward where the mouse is on screen
    current_mouse_input_cooldown = mouse_input_cooldown

    # update the actual scrolling index
    index += direction
    if wraparound:
        if index >= buttons.size():
            index = 0
        elif index < 0:
            index = buttons.size() - 1
    else:
        index = clamp(index, 0, buttons.size() - 1)

    # determine when to scroll the whole list view up or down
    var internal_scroll_index : int = 0
    if index > internal_scroll_index + 4:
        scroll = (index - 4) * -button_spacing
        internal_scroll_index += 1
    if index < internal_scroll_index + 1:
        internal_scroll_index -= 1
        scroll = (index - 1) * -button_spacing

    

func _input(event: InputEvent) -> void:
    # debug: add a new button
    if Input.is_action_just_pressed("ui_cancel"):
        add_button()
    else:
        if button_spacing == -1:
            return
    
    if Input.is_action_pressed("ui_up"):
        # scroll up
        update_index()
    elif Input.is_action_pressed("ui_down"):
        # scroll down
        update_index(1)

    else:
        if event is InputEventMouseButton:
            if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_pressed():
                update_index(-2, false)
            elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_pressed():
                update_index(2, false)
            
    
func _physics_process(delta: float) -> void:
    # if we haven't initialized the button spacing,
    # then we don't have any buttons
    if button_spacing == -1:
        return

    for button in button_map:
        var i: int = button_map[button]
        count[i] -= delta
        if count[i] < 0:
            button.position = button.position.lerp($anchor.position + Vector2(0, (i * button_spacing) + scroll), delta * 20)
            button.scale = button.scale.lerp(Vector2.ONE * 2, delta * 20)
    
    scrollbar_visual.position.y = lerp(scrollbar_visual.position.y, 2 + (float(index) / float(buttons.size() - 1)) * 188.00, 0.1) if buttons.size() > 1 else 2
    scrollbar_visual.position.y = clamp(scrollbar_visual.position.y, 2, 184.00)
    
    selected_button = buttons[index]
    selected_button.grab_focus()
    selected_button.scale += Vector2.ONE * delta * 2
    select_fx.position = select_fx.position.lerp(selected_button.position + Vector2(-185, 0), delta * 23)
    select_fx.scale.y = abs(sin(Time.get_ticks_msec() * delta * 0.4) * 0.4)

    current_mouse_input_cooldown -= delta
    if current_mouse_input_cooldown < 0:
        current_mouse_input_cooldown = 0


func _handleButtonFocus(focused_button: Control) -> void:
    if focused_button in button_map and current_mouse_input_cooldown == 0:
        index = button_map[focused_button]

func _handleButtonPressed(pressed_button: Control) -> void:
    print("Button pressed: " + pressed_button.name)