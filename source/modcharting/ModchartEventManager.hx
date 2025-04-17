package modcharting;

#if LEATHER
import game.Conductor;
#end
import haxe.ds.Vector;

using modcharting.utils.OptimizationUtil;

class ModchartEventManager
{
	private var renderer:PlayfieldRenderer;

	private var events:Vector<ModchartEvent>;
	private var eventsLength:Int = 0;

	private inline static var DEFAULT_CAPACITY:Int = 32;
	private inline static var EXPAND_SIZE:Int = 16;

	public function new(renderer:PlayfieldRenderer)
	{
		this.renderer = renderer;
		events = new Vector<ModchartEvent>(DEFAULT_CAPACITY);
	}

	public function update(elapsed:Float)
	{
		if (eventsLength > 1)
		{
            events.nullSort(function(a, b){
                if (a.time < b.time)
                    return -1;
                else if (a.time > b.time)
                    return 1;
                return 0;
            });
		}

		var i = 0;
		while (i < eventsLength)
		{
			var event = events[i];
			if (Conductor.songPosition < event.time)
				break;

			event.func(event.args);

			events[i] = events[--eventsLength];
			events[eventsLength] = null;
		}

		Modifier.beat = ((Conductor.songPosition * 0.001) * (Conductor.bpm / 60));
	}

	public function addEvent(beat:Float, func:Array<String>->Void, args:Array<String>)
	{
		var time = ModchartUtil.getTimeFromBeat(beat);
        events = OptimizationUtil.ensureVectorCapacity(events, eventsLength, EXPAND_SIZE);
		events[eventsLength++] = new ModchartEvent(time, func, args);
	}

	public function clearEvents()
	{
		for (i in 0...eventsLength)
			events[i] = null;
		eventsLength = 0;
	}
}
