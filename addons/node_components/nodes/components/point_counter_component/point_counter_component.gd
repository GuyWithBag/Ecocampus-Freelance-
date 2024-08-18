@icon("res://addons/node_components/class_icons/points-counter.png")
extends NodeComponent
class_name PointCounterComponent

@export var points: PointCounter
@export var ready_unique_resource: ReadyUniqueResource

func set_properties(props: PointCounterProperties) -> void: 
	points.starting_value = props.starting_value
	points.maximum = props.maximum
	points.minimum = props.minimum
