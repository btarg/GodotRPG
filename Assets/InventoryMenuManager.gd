extends Control

var selected_button: Button = null
var is_moving: bool = false

var inventory_button := preload("res://Assets/UIElements/InventoryItemButton.tscn") as PackedScene

# Debug items
var test_item := preload("res://Scripts/Inventory/Resources/new_item.tres") as BaseInventoryItem
var test_item2 := preload("res://Scripts/Inventory/Resources/new_item2.tres") as BaseInventoryItem

# Map item id to button
var item_button_map: Dictionary = {}

func _ready():
    # Disable the select panel by default
    $SelectPanel.visible = false

    # Connect to the inventory updated signal
    InventoryManager.connect("inventory_updated", update_inventory)

    # Add items to the inventory
    InventoryManager.add_item(test_item2, 2)
    InventoryManager.add_item(test_item, 33)

    # Connect signals for buttons
    connect_signals_for_buttons(self)

func _physics_process(delta):
    if selected_button:
        var selected_y := roundf(selected_button.global_position.y)
        var panel_y := roundf($SelectPanel.global_position.y)
        
        if selected_y == panel_y:
            is_moving = false
            return
        is_moving = true
        
        var target_y: float = selected_y - panel_y
        # Move the select panel towards the selected button
        $SelectPanel.global_position.y += target_y * 0.25
    else:
        # Move offscreen
        $SelectPanel.global_position.y = -1000
        is_moving = false

func connect_signals_for_buttons(node) -> void:
    for child in _get_button_children(node):
        child.connect("mouse_entered", _handleButtonFocus.bind(child))
        child.connect("focus_entered", _handleButtonFocus.bind(child))
        child.connect("pressed", _handle_item_clicked.bind(child.name))
        

func _get_button_children(root_node: Node) -> Array:
    var button_list: Array = []
    var stack: Array = [root_node]

    while stack.size() > 0:
        var current_node = stack.pop_back()
        for child in current_node.get_children():
            if child is Button:
                button_list.append(child)
            if child.has_method("get_children"):
                stack.append(child)

    return button_list


func _handleButtonFocus(button: Button) -> void:
    print("Button focused: " + button.name)
    selected_button = button
    button.grab_focus()

func update_inventory(item: BaseInventoryItem, count: int, is_new_item: bool) -> void:
    print("Updating inventory: " + item.item_name + " x" + str(count))
    if count == 0:
        print("Item count is 0. Removing item.")
        remove_item_button(item)
    else:
        add_item(item, count, is_new_item)

func remove_item_button(item: BaseInventoryItem) -> void:
    var button = item_button_map[item.item_id]
    %InventoryElements.remove_child(button)
    item_button_map.erase(item.item_id)
    # If the removed button was the selected button,
    # try to focus the next button in the list or
    # set selected_button to null
    if selected_button == button:
        var button_list = _get_button_children(self)
        if button_list.size() > 0:
            selected_button = button_list[0]
            $SelectPanel.global_position.y = selected_button.global_position.y
            _handleButtonFocus(selected_button)
        else:
            selected_button = null
            $SelectPanel.global_position.y = -1000
            is_moving = false

func add_item(item: BaseInventoryItem, count: int, is_new_item: bool) -> void:
    if is_new_item:
        var new_button := inventory_button.instantiate() as Button
        # Name of the button is the item ID for lookup
        new_button.name = item.item_id
        # Max character count for the item name
        var item_name_display = item.item_name.substr(0, 13) + "..." if item.item_name.length() > 16 else item.item_name
        new_button.text = item_name_display
        new_button.icon = load(item.get_icon_path()) as Texture2D
        
        # Set count label for new item
        _update_count_label(new_button, count)

        %InventoryElements.add_child(new_button)
        item_button_map[item.item_id] = new_button

        # Connect signals for the new button
        new_button.connect("mouse_entered", _handleButtonFocus.bind(new_button))
        new_button.connect("focus_entered", _handleButtonFocus.bind(new_button))

        # Connect the button's pressed signal to the _handle_item_clicked function
        new_button.connect("pressed", _handle_item_clicked.bind(new_button.name))

        # If it is the first item, focus it
        if selected_button == null:
            selected_button = new_button
            $SelectPanel.global_position.y = new_button.global_position.y
            $SelectPanel.visible = true
            _handleButtonFocus(new_button)
    else:
        # Set count label for existing item
        _update_count_label(item_button_map[item.item_id], count)

func _update_count_label(node, count: int) -> void:
    node.get_node("count_panel/count_label").text = "x%03d" % min(count, 999)

func _handle_item_clicked(item_id: String) -> void:
    var item := InventoryManager.get_item(item_id)
    var status := item.use()

    if status == BaseInventoryItem.UseStatus.CONSUMED_HP or status == BaseInventoryItem.UseStatus.CONSUMED_MP:
        print("Item consumed")
        InventoryManager.remove_item(item_id, 1)
    elif status == BaseInventoryItem.UseStatus.CANNOT_USE:
        print("Item cannot be used")
    elif status == BaseInventoryItem.UseStatus.EQUIPPED:
        print("Item equipped")

func _input(event):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_T:
            if event.shift_pressed:
                InventoryManager.remove_item(test_item, 1)
            else:
               InventoryManager.add_item(test_item, 1)