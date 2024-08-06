extends Control

var selected_button: Button = null
var is_moving: bool = false

var inventory_button := preload("res://Assets/UIElements/InventoryItemButton.tscn") as PackedScene

# Debug items
var test_item := preload("res://Scripts/Inventory/Resources/new_item.tres") as BaseInventoryItem
var test_item2 := preload("res://Scripts/Inventory/Resources/new_item2.tres") as BaseInventoryItem
var test_spell := preload("res://Scripts/Inventory/Resources/Spells/test_healing_spell.tres") as SpellItem


# Map item id to button
var item_button_map: Dictionary = {}

var empty_string := "- NO ITEMS IN INVENTORY -"

@onready var item_inventory := Inventory.new()
@onready var select_panel := $SelectPanel as Panel
@onready var select_panel_shadow := $SelectPanelShadow as Panel
@onready var item_description := %ItemDescription as Label
@onready var inventory_elements := %InventoryElements as VBoxContainer

@onready var background_panel := %InventoryBackground as PanelContainer
@onready var tween := create_tween()

# Cache sounds
@onready var hover_sound := $hover_sound as AudioStreamPlayer
@onready var click_sound := $click_sound as AudioStreamPlayer
@onready var denied_sound := $denied_sound as AudioStreamPlayer
@onready var inventory_use_sound := $inventory_use_sound as AudioStreamPlayer



func _ready() -> void:
    # Disable the select select_panel by default
    select_panel.visible = false
    select_panel_shadow.visible = false

    background_panel.material.set("shader_parameter/percentage", 0.0)
    # lerp the percentage of the shader to 1.0 (tween)
    tween.tween_property(background_panel.material, "shader_parameter/percentage", 1.0, 0.5)

    # Connect to the item_inventory updated signal
    item_inventory.connect("inventory_updated", update_inventory)

    # Add some test items
    item_inventory.add_item(test_spell, 15)
    item_inventory.add_item(test_item, 10)
    item_inventory.add_item(test_item2, 10)

func _physics_process(_delta) -> void:
    if selected_button:
        var selected_y := roundf(selected_button.global_position.y)
        var panel_y := roundf(select_panel.global_position.y)

        # lerp the select_panel color back to white for when we change colour on select
        select_panel.self_modulate = select_panel.self_modulate.lerp(Color.WHITE, 0.15)
        
        if selected_y == panel_y:
            is_moving = false
            # calculate the shadow's target position with the offset
            var shadow_target_pos := select_panel.global_position + Vector2(16, 8)
            # lerp the shadow's position to the target position
            select_panel_shadow.global_position = select_panel_shadow.global_position.lerp(shadow_target_pos, 0.25)
            
        else:
            is_moving = true
            
            var target_y: float = selected_y - panel_y
            # Move the select select_panel towards the selected button
            select_panel.global_position.y += target_y * 0.25
            # calculate the shadow's target position with the offset
            var shadow_target_pos := select_panel.global_position + Vector2(16, 8)
            # lerp the shadow's position to the target position
            select_panel_shadow.global_position = select_panel_shadow.global_position.lerp(shadow_target_pos, 0.25)
            # lerp the select select_panel scale to 1.0 quickly
            select_panel.scale = select_panel.scale.lerp(Vector2(1.0, 1.0), 0.25)
    else:
        # Move offscreen
        select_panel.global_position.y = -1000
        select_panel_shadow.global_position.y = -1000
        is_moving = false
        item_description.text = empty_string

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
    item_description.text = item_inventory.get_item(button.name).item_description
    # Check if the button is already focused
    if selected_button == button:
        return
    selected_button = button
    hover_sound.play()

func update_inventory(item: BaseInventoryItem, count: int, is_new_item: bool) -> void:
    print("Updating item_inventory: " + item.item_name + " x" + str(count))
    if count == 0:
        print("Item count is 0. Removing item.")
        remove_item_button(item)
    else:
        add_item(item, count, is_new_item)

func remove_item_button(item: BaseInventoryItem) -> void:
    var button = item_button_map[item.item_id]
    inventory_elements.remove_child(button)
    item_button_map.erase(item.item_id)
    # If the removed button was the selected button,
    # try to focus the next button in the list or
    # set selected_button to null
    if selected_button == button:
        var button_list = _get_button_children(self)
        if button_list.size() > 0:
            selected_button = button_list[0]
            select_panel.global_position.y = selected_button.global_position.y
            _handleButtonFocus(selected_button)
        else:
            selected_button = null
            select_panel.global_position.y = -1000
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

        inventory_elements.add_child(new_button)
        item_button_map[item.item_id] = new_button

        # Connect signals for the new button
        new_button.connect("mouse_entered", _handleButtonFocus.bind(new_button))
        new_button.connect("focus_entered", _handleButtonFocus.bind(new_button))

        # Connect the button's pressed signal to the _handle_item_clicked function
        new_button.connect("pressed", _handle_item_clicked.bind(new_button.name))

        # If it is the first item, focus it
        if selected_button == null:
            selected_button = new_button
            select_panel.global_position.y = new_button.global_position.y
            select_panel.visible = true
            select_panel_shadow.visible = true
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
        inventory_use_sound.set_stream(item.get_use_sound())
        inventory_use_sound.play()
        _flash_select_panel(true)

    elif status == BaseInventoryItem.UseStatus.CANNOT_USE:
        print("Item cannot be used")
        denied_sound.play()
        _flash_select_panel(false)
    elif status == BaseInventoryItem.UseStatus.EQUIPPED:
        print("Item equipped")
        click_sound.play()
        _flash_select_panel(true)

func _flash_select_panel(success: bool = true) -> void:
    if success:
        select_panel.self_modulate = Color.AQUA
    else:
        select_panel.self_modulate = Color.RED

func _input(event):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_T:
            if event.shift_pressed:
                item_inventory.remove_item(test_item2, 1)
            else:
               item_inventory.add_item(test_item2, 1)
