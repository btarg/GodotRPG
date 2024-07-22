extends Node

# Define a dictionary to hold the items and their counts
var items: Dictionary = {}

signal inventory_updated

# Function to add items to the inventory
func add_item(item: BaseInventoryItem, count: int = 1) -> void:
	var is_new_item: bool = false
	if item.item_id in items:
		var current_count = items[item.item_id]["count"]
		var new_count = current_count + count
		# Ensure we do not exceed the max stack count
		if new_count > item.max_stack:
			print("Cannot add more than max stack count")
			new_count = item.max_stack
		items[item.item_id]["count"] = new_count
	else:
		# Add the item to the inventory
		items[item.item_id] = {"resource": item, "count": count}
		is_new_item = true
	emit_signal("inventory_updated", item, count, is_new_item)

# Function to get item count
func get_item_count(item_id: String) -> int:
	if item_id in items:
		return items[item_id]["count"]
	return 0

# Function to print the inventory
func print_inventory() -> void:
	for item_id in items.keys():
		print(item_id + ": " + str(items[item_id]["count"]))
