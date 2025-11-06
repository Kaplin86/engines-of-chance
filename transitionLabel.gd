extends Label
func _ready() -> void:
	TranslationServer.set_locale("ja")
	text = tr("pressToBegin").replace("{ACCEPT_CONTROL}",tr("ACCEPT_CONTROL"))
	print("the thing is", tr("pressToBegin"))
