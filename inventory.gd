extends Resource

class_name Inventory

signal update_slot

@export var items: Array[InventorySlot]

func insert(item: InventoryItem):
	var item_slots = items.filter(func(slot): return slot.item == item)
	if !item_slots.is_empty():
		item_slots[0].count += 1
	else:
		var empty_slots = items.filter(func(slot): return slot.item == null)
		if !empty_slots.is_empty():
			empty_slots[0].item = item
			empty_slots[0].count = 1
	
	update_slot.emit()

func delete(item: InventoryItem):
	var item_slots = items.filter(func(slot): return slot.item == item)
	if !item_slots.is_empty():
		if item_slots[0].count > 1:
			item_slots[0].count -= 1
		else:
			item_slots[0].item = null
			item_slots[0].count = 0
	else:
		pass
