extends Node2D
class_name Cell

@export var grid: Grid
@export var grid_position = Vector2.ZERO

var neighbors : Array[Cell]

@onready var color_rect: ColorRect = $ColorRect

var value := 0

func setup(_grid: Grid, _grid_position: Vector2):
	grid = _grid
	grid_position = _grid_position

func _ready() -> void:
	global_position = grid.cell_size * grid_position
	color_rect.size = grid.cell_size

func on() -> void:
	value = 1
	color_rect.color = grid.on_color

func off() -> void:
	value = 0
	color_rect.color = grid.off_color

func live_or_die() -> GOL.State:
	var count := 0
	for neighbor in neighbors:
		if neighbor.value:
			count += 1

	return GOL.live_or_die(value, count)
