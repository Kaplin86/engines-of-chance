extends Sprite2D

func startrainbow():
	var NewTween = create_tween()
	var NewValue = Color.from_hsv(modulate.h + 0.1,modulate.s,modulate.v,modulate.a)
	NewTween.tween_property(self,"modulate",NewValue,0.25)
	NewTween.finished.connect(startrainbow)
