extends Panel

@onready var item_sprite = $CenterContainer/Panel/ItemSprite

func update(item: InventoryItem):
	if !item:
		item_sprite.visible = false
	else:
		item_sprite.texture = item.sprite
		item_sprite.visible = true
