extends Panel

@onready var item_sprite = $CenterContainer/Panel/ItemSprite

func update(slot: InventorySlot):
	if !slot.item:
		item_sprite.visible = false
	else:
		item_sprite.texture = slot.item.sprite
		item_sprite.visible = true
