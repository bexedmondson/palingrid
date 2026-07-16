@tool
extends Theme

@export_tool_button ("Hello", "Callable") var hello_action = hello

func hello():
	var things = self.get_color_type_list()
	print(things)