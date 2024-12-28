extends Node2D
class_name Grid

const CELL = preload("res://entities/cell.tscn")

@export var size := Vector2(160, 90) * 0.5
@export var cell_size : Vector2

@export var on_color := Color.CYAN
@export var off_color := Color.DARK_MAGENTA

var paused := false

var cells = {}

var glider : Array[Vector2] = [
	Vector2(1, 0),
	Vector2(2, 1),
	Vector2(0, 2),
	Vector2(1, 2),
	Vector2(2, 2),
]

func _ready() -> void:
	cell_size = Vector2(get_viewport().size.x / size.x, get_viewport().size.y / size.y)

	for y in range(size.y):
		for x in range(size.x):
			var cell = CELL.instantiate()
			var pos = Vector2(x, y)
			cell.setup(self, pos)
			add_child(cell)
			cell.off()
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


func _process(_delta: float) -> void:
	if !paused:
		generation()

	#if !paused:
		#generation()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() && event.keycode == KEY_W:
			wandomize()
		if event.is_pressed() && event.keycode == KEY_A:
			create_glider()
		if event.is_pressed() && event.keycode == KEY_SPACE:
			paused = !paused
		if event.is_pressed() && event.keycode == KEY_N:
			generation()
		if event.is_pressed() && event.keycode == KEY_S:
			all_off()
		if event.is_pressed() && event.keycode == KEY_F:
			all_on()

func wandomize() -> void:
	print('randomizing....')
	for cell in cells.values():
		if randf() < 0.2:
			cell.on()
		else:
			cell.off()

func create_glider() -> void:
	for v in glider:
		var cell = cells.get(v)
		if cell:
			cell.on()

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

func generation() -> void:
	newgeneration()

func newgeneration() -> void:
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

func oldgeneration() -> void:
	var lifes = []
	var deaths = []

	for pos in cells:
		var cell = cells[pos]
		var status = GOL.live_or_die(cell.value, count_neighbors(pos))
		if status == GOL.State.ALIVE:
			lifes.push_back(cell)
		elif status == GOL.State.DEAD:
			deaths.push_back(cell)

	for cell in lifes:
		cell.on()

	for cell in deaths:
		cell.off()

func all_off() -> void:
	for cell in cells.values():
		cell.off()

func all_on() -> void:
	for cell in cells.values():
		cell.on()
