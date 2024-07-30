extends Node

var inventory: Node

var test_item := preload("res://Scripts/Inventory/Resources/new_item.tres") as BaseInventoryItem
var test_item2 := preload("res://Scripts/Inventory/Resources/new_item2.tres") as BaseInventoryItem

# Item index map
var item_index_map: Dictionary = {}

func _ready():
	# Lists have one signal that we can connect to for every item
	InventoryManager.connect("inventory_updated", update_inventory)
	$InventoryList.connect("item_activated", _handle_item_clicked)

	# debug: grab focus
	$InventoryList.grab_focus()
	
	# Add items to the inventory
	InventoryManager.add_item(test_item2, 2)
	
	# Print the inventory
	InventoryManager.print_inventory()
	
func update_inventory(item: BaseInventoryItem, count: int, is_new_item: bool) -> void:
	if count == 0:
		print("Item count is 0. Removing item.")
		remove_item(item)
	else:
		add_item(item, count, is_new_item)

func remove_item(item: BaseInventoryItem) -> void:
	var item_index: int = item_index_map[item.item_id]
	$InventoryList.remove_item(item_index)
	# remove the item from the dictionary
	item_index_map.erase(item.item_id)
	# set focused item to the previous item in the list
	if item_index > 0:
		$InventoryList.select(item_index - 1)
	else:
		$InventoryList.select(0)

func add_item(item: BaseInventoryItem, count: int, is_new_item: bool) -> void:
	var item_icon := load(item.get_icon_path()) as Texture2D
	var display_text: String = item.item_name + " x" + str(count)
	if is_new_item:
		var added_item_index: int = $InventoryList.add_item(display_text, item_icon)
		print("Added item at index: " + str(added_item_index))
		# if it is the first item, focus it
		if added_item_index == 0:
			$InventoryList.select(added_item_index)

		# put this item's index into a dictionary along with the item_id
		item_index_map[item.item_id] = added_item_index

	else:
		# Find the existing item via the item_id
		var item_index: int = item_index_map[item.item_id]
		$InventoryList.set_item_icon(item_index, item_icon)
		$InventoryList.set_item_text(item_index, display_text)
		print("Updated item at index: " + str(item_index))

func _handle_item_clicked(index: int) -> void:
	print("Keys: " + str(item_index_map.keys()))
	var item_id: String = item_index_map.keys()[index]
	# get the item from its id
	var item: BaseInventoryItem = InventoryManager.get_item(item_id)
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
	elif event.is_action_pressed("ui_right"):
		InventoryManager.remove_item(test_item, 1)
