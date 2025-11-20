class_name SignalUtils

class WhenAny:
	signal completed()
	
static func when_any(signals: Array[Signal]) -> WhenAny:
	var source = WhenAny.new()
	
	for s in signals:
		s.connect(source.completed.emit, Object.CONNECT_ONE_SHOT)
	
	return source;
