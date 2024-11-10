extends VBoxContainer

@onready var inventory_button := preload("res://Assets/UIElements/InventoryItemButtonPaint.tscn") as PackedScene
var buttons: Array[Control] = []

@export var max_size := 4

func add_button() -> void:
    if buttons.size() >= max_size:
        print("Max size reached")
        return

    var button := inventory_button.instantiate() as Control
    buttons.append(button)

    add_child(button)
    button.focus_entered.connect(_on_button_focus_entered.bind(button))

    if buttons.size() == 1:
        button.grab_focus()

    if buttons.size() > 1:
        var previous := buttons[buttons.size()-2].get_path()
        button.focus_neighbor_top = previous
        button.focus_previous = previous

        for i in range(0, buttons.size()):
            var next := buttons[(i + 1) % buttons.size()].get_path()
            buttons[i].focus_neighbor_bottom = next
            buttons[i].focus_next = next

        var last_item := buttons[buttons.size()-1].get_path()
        buttons[0].focus_neighbor_top = last_item
        buttons[0].focus_previous = last_item

# This is used instead of mouse_exit because we want to always
# have a button highlighted, even if the mouse is away from the buttons
func _on_button_focus_entered(button: Control) -> void:
    for b in buttons:
        if b != button:
            b.release_focus()

func _ready() -> void:
    for i in range(0, 6):
        add_button()
