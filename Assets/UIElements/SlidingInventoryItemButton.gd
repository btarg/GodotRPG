extends Control

@onready var button := $ItemButton as Button
@onready var target := $Target as Control
@onready var tween := create_tween()


func _ready():
	# Button should be offscreen to the left
    if button:
        button.global_position.x -= 1000
        tween.tween_property(button, "global_position:x", target.global_position.x, 3)
    else:
        print("Button not found")
