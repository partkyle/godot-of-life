extends Object
class_name GOL

enum State {
	ALIVE,
	DEAD,
	UNCHANGED,
}

static func live_or_die(value: int, count: int) -> GOL.State:
	if value:
		if count > 3:
			return GOL.State.DEAD
		elif count < 2:
			return GOL.State.DEAD
	else:
		if count == 3:
			return GOL.State.ALIVE

	return GOL.State.UNCHANGED

static var glider : Array[Vector2] = [
	Vector2(1, 0),
	Vector2(2, 1),
	Vector2(0, 2),
	Vector2(1, 2),
	Vector2(2, 2),
]
