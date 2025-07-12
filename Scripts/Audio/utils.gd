extends Node

class_name Utils

static func find_node_by_type(parent:Node, type) -> Node:
	for child in parent.get_children():
		if is_instance_of(child, type):
			return child
		var grandchild = find_node_by_type(child, type)
		if grandchild != null:
			return grandchild
	return null

static func find_node_by_group(parent:Node, group) -> Node:
	for child in parent.get_children():
		if child.is_in_group(group):
			return child
		var grandchild = find_node_by_group(child, group)
		if grandchild != null:
			return grandchild
	return null
