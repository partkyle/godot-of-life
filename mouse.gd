extends Node2D

@onready var grid: Grid = $"../Grid"
@onready var coordinates: Label = $Coordinates
@onready var neighbors: Label = $Neighbors
@onready var live_or_die: Label = $LiveOrDie

@export var label_offset := Vector2(40, -20)
var mouse_position : Vector2

var drawing_cells : Array[Cell] = []

func _ready() -> void:
	for i in range(0, 9):
		var cell = Grid.CELL.instantiate()
		cell.grid = grid
		drawing_cells.push_back(cell)
		grid.add_child(cell)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.position

func cell_position() -> Vector2:
	return Vector2(int(mouse_position.x / grid.cell_size.x), int(mouse_position.y / grid.cell_size.y))

func _process(_delta: float) -> void:
	position = mouse_position + label_offset
	var cell_pos := cell_position()
	coordinates.text = str(cell_pos)

	var cell = grid.cells.get(cell_pos)
	if cell:
		for n in drawing_cells:
			n.visible = false

		var visible_neighbors := 0
		var neighbors_text = '['
		for n in cell.neighbors:
			var c = drawing_cells[visible_neighbors]
			c.grid_position = n.grid_position
			c.global_position = grid.cell_size * c.grid_position
			c.color_rect.color = Color.YELLOW
			c.visible = true
			visible_neighbors += 1
			neighbors_text += '(' + str(n.grid_position.x) + ', ' + str(n.grid_position.y) + ')'
		neighbors_text += ']'

		neighbors.text = 'neighbors: ' + neighbors_text

		if cell:
			live_or_die.text = 'live_or_die: ' +  str(grid.cells[cell_pos].live_or_die())
