extends Control

var selected_button: Button = null
var is_moving: bool = false

var inventory_button := preload("res://Assets/UIElements/InventoryItemButton.tscn") as PackedScene

# Debug items
var test_item := preload("res://Scripts/Inventory/Resources/new_item.tres") as BaseInventoryItem
var test_item2 := preload("res://Scripts/Inventory/Resources/new_item2.tres") as BaseInventoryItem

# Map item id to button
var item_button_map: Dictionary = {}

var empty_string := "- NO ITEMS IN INVENTORY -"

@onready var item_inventory := Inventory.new()

func _ready() -> void:
    # Disable the select panel by default
    $SelectPanel.visible = false

    # Connect to the item_inventory updated signal
    item_inventory.connect("inventory_updated", update_inventory)

    # # Add items to the item_inventory
    # item_inventory.add_item(test_item, 10)
    # item_inventory.add_item(test_item2, 33)

func test() -> void:
    print("Hello from InventoryMenuManager")

func _physics_process(delta) -> void:
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
        %item_description.text = empty_string
        
# recursively get all children that are buttons of the root node
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
    button.grab_focus()
    %item_description.text = item_inventory.get_item(button.name).item_description
    # Check if the button is already focused
    if selected_button == button:
        return
    selected_button = button
    $hover_sound.play()

func update_inventory(item: BaseInventoryItem, count: int, is_new_item: bool) -> void:
    print("Updating item_inventory: " + item.item_name + " x" + str(count))
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
        # var item_name_display = item.item_name.substr(0, 13) + "..." if item.item_name.length() > 16 else item.item_name
        var item_name_display := item.item_name
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

func _update_count_label(button_root: Node, count: int) -> void:
    button_root.get_node("count_panel/count_label").text = "x%03d" % min(count, 999) if count < 999 else "x999+"

func _handle_item_clicked(item_id: String) -> void:

    var item := item_inventory.get_item(item_id) as BaseInventoryItem
    var status := item.use()

    if status == BaseInventoryItem.UseStatus.CONSUMED_HP or status == BaseInventoryItem.UseStatus.CONSUMED_MP:
        print("Item consumed")
        item_inventory.remove_item(item_id, 1)
        $inventory_use_sound.set_stream(item.get_use_sound())
        $inventory_use_sound.play()

    elif status == BaseInventoryItem.UseStatus.CANNOT_USE:
        print("Item cannot be used")
        $denied_sound.play()
    elif status == BaseInventoryItem.UseStatus.EQUIPPED:
        print("Item equipped")
        $click_sound.play()

func _input(event):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_T:
            if event.shift_pressed:
                item_inventory.remove_item(test_item2, 1)
            else:
               item_inventory.add_item(test_item2, 1)
