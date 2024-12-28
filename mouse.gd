extends Node2D

@onready var grid: Grid = $"../Grid"
@onready var coordinates: Label = $Coordinates
@onready var neighbors: Label = $Neighbors
@onready var live_or_die: Label = $LiveOrDie

@export var label_offset := Vector2(40, -20)
var mouse_position : Vector2

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.position

func cell_position() -> Vector2:
	return Vector2(int(mouse_position.x / grid.cell_size.x), int(mouse_position.y / grid.cell_size.y))

func _process(_delta: float) -> void:
	position = mouse_position + label_offset
	var cell_pos := cell_position()
	coordinates.text = str(cell_pos)
	var c := grid.count_neighbors(cell_pos)
	neighbors.text = 'neighbors ' + str(c)
	live_or_die.text = 'alive: ' + str(Grid.live_or_die(grid.cells[cell_pos].value, c))
