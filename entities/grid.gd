extends Node2D
class_name Grid

const CELL = preload("res://entities/cell.tscn")

@export var size := Vector2(160, 90)
@export var cell_size : Vector2

@export var on_color := Color.CYAN
@export var off_color := Color.DARK_MAGENTA

var paused := false

class Strategy:
	func create_cell(grid: Grid, pos: Vector2) -> Cell:
		var cell = CELL.instantiate()
		cell.setup(grid, pos)
		grid.add_child(cell)
		cell.off()
		return cell


class FullDictionaryStrategy extends Strategy:
	var cells = {}

	func get_cells():
		return cells.values()

	func get_cell(p: Vector2) -> Cell:
		return cells.get(p)

	func on(p: Vector2):
		var cell = get_cell(p)
		if cell:
			cell.on()

	func off(p: Vector2):
		var cell = get_cell(p)
		if cell:
			cell.off()

class NeighborHandles extends FullDictionaryStrategy:
	func setup(size: Vector2, grid: Grid) -> void:
		for y in range(size.y):
			for x in range(size.x):
				var pos = Vector2(x, y)
				var cell = create_cell(grid, pos)
				cells[pos] = cell

		for c in cells.values():
			var neighbors : Array[Cell] = []
			for y in range(c.grid_position.y - 1, c.grid_position.y + 2):
				for x in range(c.grid_position.x - 1, c.grid_position.x + 2):
					var n_pos := Vector2(x, y)
					var neighbor = cells.get(n_pos)
					if n_pos != c.grid_position && neighbor:
						neighbors.push_back(neighbor)

			c.neighbors = neighbors

	func generation() -> void:
		var lifes = []
		var deaths = []

		for cell in cells.values():
			var status = cell.live_or_die()
			if status == GOL.State.ALIVE:
				lifes.push_back(cell)
			elif status == GOL.State.DEAD:
				deaths.push_back(cell)

		for life in lifes:
			life.on()

		for death in deaths:
			death.off()

class DictionaryCountStrategy extends FullDictionaryStrategy:
	func count_neighbors(pos: Vector2) -> int:
		var results := 0
		for y in range(pos.y - 1, pos.y + 2):
			for x in range(pos.x - 1, pos.x + 2):
				var n_pos := Vector2(x, y)
				if pos != n_pos:
					var cell = cells.get(n_pos)
					if cell && cell.value:
						results += 1

		return results

	func setup(size: Vector2, grid: Grid) -> void:
		for y in range(size.y):
			for x in range(size.x):
				var pos = Vector2(x, y)
				var cell = create_cell(grid, pos)
				cells[pos] = cell

	func generation() -> void:
		var lifes = []
		var deaths = []

		for cell in cells.values():
			var status = GOL.live_or_die(cell.value, count_neighbors(cell.grid_position))
			if status == GOL.State.ALIVE:
				lifes.push_back(cell)
			elif status == GOL.State.DEAD:
				deaths.push_back(cell)

		for cell in lifes:
			cell.on()

		for cell in deaths:
			cell.off()


class SparseDictionary extends Strategy:
	var size : Vector2
	var grid : Grid
	var cells = {}

	func has_cell(p: Vector2) -> bool:
		return cells.has(p)

	func get_cells():
		return cells.values()

	func get_cell(p: Vector2) -> Cell:
		return cells.get(p)

	func on(p: Vector2):
		if !has_cell(p):
			var newCell = create_cell(grid, p)
			newCell.on()
			cells[p] = newCell

	func off(p: Vector2):
		var cell = get_cell(p)
		if cell:
			cell.queue_free()
			cells.erase(p)

	func setup(_size: Vector2, _grid: Grid) -> void:
		size = _size
		grid = _grid

	func generation():
		var lifes : Array[Vector2] = []
		var deaths : Array[Vector2] = []

		var dead_cells_to_check = {}

		for pos in cells:
			var neighbor_count := 0
			for y in range(pos.y - 1, pos.y + 2):
				for x in range(pos.x - 1, pos.x + 2):
					var p := Vector2(x, y)
					if has_cell(p):
						neighbor_count += 1
					else:
						dead_cells_to_check[p] = null

			var status = GOL.live_or_die(1, neighbor_count)

			if status == GOL.State.ALIVE:
				lifes.push_back(pos)
			elif status == GOL.State.DEAD:
				deaths.push_back(pos)

		for pos in dead_cells_to_check:
			var neighbor_count := 0
			for y in range(pos.y - 1, pos.y + 2):
				for x in range(pos.x - 1, pos.x + 2):
					var p := Vector2(x, y)
					var neighbor := get_cell(p)
					if neighbor:
						neighbor_count += 1

			var status = GOL.live_or_die(0, neighbor_count)

			if status == GOL.State.ALIVE:
				lifes.push_back(pos)

		for pos in lifes:
			on(pos)

		for pos in deaths:
			off(pos)


var strategy = SparseDictionary.new()

func _ready() -> void:
	cell_size = Vector2(get_viewport().size.x / size.x, get_viewport().size.y / size.y)

	strategy.setup(size, self)

func _process(_delta: float) -> void:
	if !wandomizing && !paused:
		strategy.generation.call_deferred()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() && event.keycode == KEY_W:
			wandomize.call_deferred()
		if event.is_pressed() && event.keycode == KEY_A:
			create_glider()
		if event.is_pressed() && event.keycode == KEY_SPACE:
			paused = !paused
		if event.is_pressed() && event.keycode == KEY_N:
			strategy.generation()
		if event.is_pressed() && event.keycode == KEY_S:
			all_off()
		if event.is_pressed() && event.keycode == KEY_F:
			all_on()

var wandomizing = false
func wandomize() -> void:
	print('randomizing....')
	wandomizing = true
	for y in range(0, size.y):
		for x in range(0, size.x):
			var pos = Vector2(x, y)
			if randf() < 0.1:
				strategy.on.call_deferred(pos)
			else:
				strategy.off.call_deferred(pos)

	wandomizing = false


func create_glider() -> void:
	for v in GOL.glider:
		var cell = strategy.get_cell(v)
		if cell:
			cell.on()

func all_off() -> void:
	for cell in strategy.get_cells():
		cell.off()

func all_on() -> void:
	for cell in strategy.get_cells():
		cell.on()
