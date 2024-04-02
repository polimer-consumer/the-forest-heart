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
