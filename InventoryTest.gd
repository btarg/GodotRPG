extends Node

var inventory: Node

var test_item := preload("res://Scripts/Inventory/Resources/new_item.tres") as BaseInventoryItem
var test_item2 := preload("res://Scripts/Inventory/Resources/new_item2.tres") as BaseInventoryItem

func _ready():
	# Create some items
	InventoryManager.connect("inventory_updated", Callable(self, "update_inventory"))
	
	# Add items to the inventory
	InventoryManager.add_item(test_item2, 2)
	
	# Print the inventory
	InventoryManager.print_inventory()
	
func update_inventory(item: BaseInventoryItem, count: int, is_new_item: bool) -> void:
	if is_new_item:
		# Create a new item display
		var item_label = preload("res://item_display.tscn").instantiate()
		# Set the text of the item display
		item_label.text = item.item_name + " x" + str(count)
		item_label.icon = load(item.get_icon_path())
		# Connect the button press signal and bind the item as a parameter
		item_label.connect("pressed", _on_item_label_pressed.bind(item))

		# Set the name of the item display to the item ID
		item_label.name = item.item_id
		# Add the item display to the inventory list
		$InventoryList.add_child(item_label)
		# if it is the first item, focus it
		if $InventoryList.get_child_count() == 1:
			item_label.grab_focus()

	else:
		# Find the item display by name
		var item_label = $InventoryList.get_node(item.item_id)
		# Update the text of the item display
		item_label.text = item.item_name + " x" + str(InventoryManager.get_item_count(item.item_id))
		#item_label.text = item.get_rich_name() + " x" + str(InventoryManager.get_item_count(item.item_id))

func _on_item_label_pressed(item: BaseInventoryItem) -> void:
	print("Button clicked for item: " + item.item_name + " x" + str(InventoryManager.get_item_count(item.item_id)))
	var status = item.use()
	if status == BaseInventoryItem.UseStatus.CONSUMED_HP or status == BaseInventoryItem.UseStatus.CONSUMED_MP:
		print("Item consumed")
	elif status == BaseInventoryItem.UseStatus.CANNOT_USE:
		print("Item cannot be used")
	elif status == BaseInventoryItem.UseStatus.EQUIPPED:
		print("Item equipped")

# on input add an item
func _input(event):
	if event.is_action_pressed("ui_select"):
		InventoryManager.add_item(test_item, 1)
		InventoryManager.print_inventory()
