extends Node

var inventory: Node

var test_item := preload("res://Scripts/Inventory/Resources/new_item.tres") as BaseInventoryItem
var test_item2 := preload("res://Scripts/Inventory/Resources/new_item2.tres") as BaseInventoryItem


func _ready():
	# Create some items
	InventoryManager.connect("inventory_updated", update_inventory)
	
	# Add items to the inventory
	InventoryManager.add_item(test_item2, 2)
	
	# Print the inventory
	InventoryManager.print_inventory()
	
func update_inventory(item: BaseInventoryItem, count: int, is_new_item: bool) -> void:

	if is_new_item:
		# Create a new item display
		var item_label = preload("res://item_display.tscn").instantiate()
		# Set the text of the item display
		item_label.text = item.get_rich_name() + " x" + str(count)
		# Set the name of the item display to the item ID
		item_label.name = item.item_id
		# Add the item display to the inventory list
		$InventoryList.add_child(item_label)
	else:
		# Find the item display by name
		var item_label = $InventoryList.get_node(item.item_id)
		# Update the text of the item display
		item_label.text = item.get_rich_name() + " x" + str(InventoryManager.get_item_count(item.item_id))


# on input add an item
func _input(event):
	if event.is_action_pressed("ui_select"):
		InventoryManager.add_item(test_item, 1)
		InventoryManager.print_inventory()