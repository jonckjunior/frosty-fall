extends RichTextLabel

func update():
	text = "\n[center]highest: [wave]" + str( snapped(GameManager.max_score, 0.01) )
