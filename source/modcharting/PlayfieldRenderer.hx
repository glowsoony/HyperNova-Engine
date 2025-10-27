package modcharting;

// import HazardAFT_Capture.HazardAFT_CaptureMultiCam as MultiCamCapture;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxAngle;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer.FlxTimerManager;
// import modcharting.ArrowPathBitmap;
import modcharting.Modifier;
import modcharting.Proxiefield.Proxie as Proxy;
import objects.Note;
import objects.StrumNote;
import objects.SustainTrail;
import openfl.geom.Vector3D;
import states.PlayState;

using StringTools;

/*import flixel.tweens.misc.BezierPathTween;
	import flixel.tweens.misc.BezierPathNumTween; */
// a few todos im gonna leave here:
//--ZORO--
// setup quaternions for everything else (incoming angles and the rotate mod)
// do add and remove buttons on stacked events in editor
// fix switching event type in editor so you can actually do set events (as well as adding "add and value" events - Edwhak)
// finish setting up tooltips in editor (as 4.0 should go, this will be made)
// start documenting more stuff idk (same as 4.0)
//--EDWHAK--
// finish editor itself and fix some errors zoro didn't (mostly on editors)
// Optimize arrowPath and add the other variant (we have "ArrowPathFill" but not "ArrowPath")
// Make editor optimized as well as playfieldRenderer (includes Arrows and Sustains) (most likely it's way to render it's the lag issue)
// Grain shit for sustains (the higger value the most and most soft sustain looks) -- possible, i just don't know how
// Optimize the tool for better performance, would be cool see this thing run on low end PC's
// Editor 4.0 (psych has no windows tabs so i need create my own)
// Fix "Stealth" mods when using playfields (for some reason playfields ask a general change instead of individual even if they are their own note copy??)
// ^^^ this also happens in "McMadness mod" in combo-meal song when notes goes timeStop (added playfields and got same result!!) interesting.

typedef StrumNoteType = objects.StrumNote;

class PlayfieldRenderer extends FlxBasic
{
	public var strumGroup:FlxTypedGroup<StrumNoteType>;
	public var notes:FlxTypedGroup<Note>;
	public var instance:ModchartMusicBeatState;
	public var playStateInstance:PlayState;
	// public var editorPlayStateInstance:editors.content.EditorPlayState;
	public var playfields:Array<Playfield> = []; // adding an extra playfield will add 1 for each player
	public var proxiefields:Array<Proxiefield> = [];

	public var eventManager:ModchartEventManager;
	public var modifierTable:ModTable;
	public var tweenManager:FlxTweenManager = null;
	public var timerManager:FlxTimerManager = null;

	public var modchart:ModchartFile;
	public var inEditor:Bool = false;
	public var editorPaused:Bool = false;

	public var speed:Float = 1.0;

	public var modifiers(get, default):Map<String, Modifier>;

	public var isEditor:Bool = false;

	// public var aftCapture:MultiCamCapture = null;

	private function get_modifiers():Map<String, Modifier>
	{
		return modifierTable.modifiers; // back compat with lua modcharts
	}

	public var noteFields:FlxTypedGroup<NoteField> = new FlxTypedGroup<NoteField>();

	public function new(instance:ModchartMusicBeatState)
	{
		super();

		this.instance = instance;
		if (Std.isOfType(instance, PlayState))
			playStateInstance = cast instance; // so it just casts once
		/*if (Std.isOfType(instance, editors.content.EditorPlayState))
			{
				editorPlayStateInstance = cast instance; // so it just casts once
				isEditor = true;
		}*/

		// fix stupid crash because the renderer in playstate is still technically null at this point and its needed for json loading
		instance.playfieldRenderer = this;

		tweenManager = new FlxTweenManager();
		timerManager = new FlxTimerManager();
		eventManager = new ModchartEventManager(this);
		modifierTable = new ModTable(instance, this);
		addPlayfield(0);

		// why ??

		// addNewProxiefield(new Proxy());
		modchart = new ModchartFile(this);
	}

	public function addPlayfield(?index:Int)
		noteFields.add(new NoteField(this, index ?? noteFields?.members?.length - 1));
	public function removePlayfield(index:Int)
		noteFields.remove(noteFields.members[index]);

	public function addNewProxiefield(proxy:Proxy)
		proxiefields.push(new Proxiefield(proxy));

	override function update(elapsed:Float)
	{
		eventManager.update(elapsed);
		tweenManager.update(elapsed); // should be automatically paused when you pause in game
		timerManager.update(elapsed);
		noteFields.update(elapsed);
	}

	override function draw()
		noteFields.draw();

	public function getCorrectScrollSpeed()
		return ModchartUtil.getScrollSpeed(inEditor ? null : playStateInstance);

	public function createTween(Object:Dynamic, Values:Dynamic, Duration:Float, ?Options:TweenOptions):FlxTween
	{
		final tween:FlxTween = tweenManager.tween(Object, Values, Duration, Options);
		tween.manager = tweenManager;
		return tween;
	}

	public function createTweenNum(FromValue:Float, ToValue:Float, Duration:Float = 1, ?Options:TweenOptions, ?TweenFunction:Float->Void):FlxTween
	{
		final tween:FlxTween = tweenManager.num(FromValue, ToValue, Duration, Options, TweenFunction);
		tween.manager = tweenManager;
		return tween;
	}

	override public function destroy()
	{
		if (modchart != null)
			for (customMod in modchart.customModifiers)
				customMod.destroy(); // make sure the interps are dead
		super.destroy();
	}
}
