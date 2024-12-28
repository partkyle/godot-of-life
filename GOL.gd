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
