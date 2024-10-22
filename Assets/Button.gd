extends Button

@onready var test := %HelloWorld as Hello

func _on_pressed() -> void:
	print("Button pressed")
	var hello: int = 0
	hello = 3
	# comment