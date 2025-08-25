@tool
extends Node

@export var my_value: int = 0:
	set(new_value):
		my_value = new_value
		_on_my_value_changed() # Call a function to handle the change

func _on_my_value_changed():
	# Place your desired code here to run when my_value changes
	print("my_value changed to: ", my_value)
	# Example: Update a visual element, adjust a property of another node, etc.
