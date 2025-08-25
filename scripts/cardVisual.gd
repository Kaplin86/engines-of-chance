extends Sprite2D

func startrainbow(): #this will be started by external sources
	var NewTween = create_tween()
	var NewValue = Color.from_hsv(modulate.h + 0.1,modulate.s,modulate.v,modulate.a) #choose new hue
	NewTween.tween_property(self,"modulate",NewValue,0.25)
	NewTween.finished.connect(startrainbow) #this will loop the function
