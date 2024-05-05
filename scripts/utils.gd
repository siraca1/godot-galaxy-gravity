extends Node


func set_parent(node: Node, new_parent: Node = null, reset_position: bool = false) -> void:
	if not node:
		return
	
	var original_parent = node.get_parent()
	
	if original_parent:
		original_parent.remove_child.call_deferred(node)
		await get_tree().process_frame
	
	if new_parent:
		new_parent.add_child(node)
	else:
		get_tree().current_scene.add_child.call_deferred(node)
		await get_tree().process_frame
	
	if not node is Node3D:
		return
	
	if reset_position:
		node.transform = new_parent.transform if new_parent else node.transform
	else:
		node.transform = original_parent.transform if original_parent else node.transform
