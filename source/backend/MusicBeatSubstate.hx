package backend;

import flixel.FlxSubState;

class MusicBeatSubstate extends FlxSubState
{
	public static var instance:MusicBeatSubstate;

	var crtFilter:FlxSprite;
	var whiteAnimeshoun:FlxSprite;
	var camAnimeshoun:FlxSprite;
	var staticAnimeshoun:FlxSprite;
	var constantstaticAnimeshoun:FlxSprite;

	public function new()
	{
		instance = this;
		// controls.isInSubstate = true;
		super();

		Paths.image("overlays/ctr");
		Paths.image("overlays/white_scanline" + (ClientPrefs.data.downScroll ? "-ds" : ""));
		Paths.image("overlays/cam_fuck");
		Paths.image("static/static",);
		crtFilter = new FlxSprite().loadGraphic(Paths.image('overlays/crt'));
		crtFilter.scrollFactor.set();
		crtFilter.antialiasing = true;
		crtFilter.screenCenter();

		whiteAnimeshoun = new FlxSprite();
		whiteAnimeshoun.frames = Paths.getSparrowAtlas('overlays/white_scanline' + (ClientPrefs.data.downScroll ? "-ds" : ""));
		whiteAnimeshoun.animation.addByPrefix('idle', 'scanline', 24, true);
		whiteAnimeshoun.screenCenter();
		whiteAnimeshoun.scrollFactor.set();
		whiteAnimeshoun.antialiasing = true;
		whiteAnimeshoun.animation.play('idle');

		camAnimeshoun = new FlxSprite();
		camAnimeshoun.frames = Paths.getSparrowAtlas('overlays/cam_fuck');
		camAnimeshoun.animation.addByPrefix('idle', 'cam-idle', 24, true);
		camAnimeshoun.screenCenter();
		camAnimeshoun.scrollFactor.set();
		camAnimeshoun.antialiasing = false;
		camAnimeshoun.animation.play('idle', true);

		staticAnimeshoun = new FlxSprite();
		staticAnimeshoun.frames = Paths.getSparrowAtlas('static/static');
		staticAnimeshoun.animation.addByPrefix('idle', 'idle', 24, true);
		staticAnimeshoun.screenCenter();
		staticAnimeshoun.scrollFactor.set();
		staticAnimeshoun.animation.play('idle');
		staticAnimeshoun.visible = false;

		constantstaticAnimeshoun = new FlxSprite();
		constantstaticAnimeshoun.frames = Paths.getSparrowAtlas('static/static');
		constantstaticAnimeshoun.animation.addByPrefix('idle', 'idle', 24, true);
		constantstaticAnimeshoun.screenCenter();
		constantstaticAnimeshoun.scrollFactor.set();
		constantstaticAnimeshoun.animation.play('idle');
		constantstaticAnimeshoun.visible = false;
	}

	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return Controls.instance;

	#if TOUCH_CONTROLS_ALLOWED
	public var touchPad:TouchPad;
	public var hitbox:Hitbox;
	public var camControls:FlxCamera;
	public var tpadCam:FlxCamera;

	public function addTouchPad(DPad:String, Action:String)
	{
		touchPad = new TouchPad(DPad, Action);
		add(touchPad);
	}

	public function removeTouchPad()
	{
		if (touchPad != null)
		{
			remove(touchPad);
			touchPad = FlxDestroyUtil.destroy(touchPad);
		}

		if (tpadCam != null)
		{
			FlxG.cameras.remove(tpadCam);
			tpadCam = FlxDestroyUtil.destroy(tpadCam);
		}
	}

	public function addHitbox(defaultDrawTarget:Bool = false):Void
	{
		var extraMode = MobileData.extraActions.get(ClientPrefs.data.extraHints);

		hitbox = new Hitbox(extraMode, MobileData.getButtonsColors());

		camControls = new FlxCamera();
		camControls.bgColor.alpha = 0;
		FlxG.cameras.add(camControls, defaultDrawTarget);

		hitbox.cameras = [camControls];
		hitbox.visible = false;
		add(hitbox);
	}

	public function removeHitbox()
	{
		if (hitbox != null)
		{
			remove(hitbox);
			hitbox = FlxDestroyUtil.destroy(hitbox);
			hitbox = null;
		}

		if (camControls != null)
		{
			FlxG.cameras.remove(camControls);
			camControls = FlxDestroyUtil.destroy(camControls);
		}
	}

	public function addTouchPadCamera(defaultDrawTarget:Bool = false):Void
	{
		if (touchPad != null)
		{
			tpadCam = new FlxCamera();
			tpadCam.bgColor.alpha = 0;
			FlxG.cameras.add(tpadCam, defaultDrawTarget);
			touchPad.cameras = [tpadCam];
		}
	}

	override function destroy()
	{
		// controls.isInSubstate = false;
		removeTouchPad();
		removeHitbox();

		super.destroy();
	}
	#end

	override function update(elapsed:Float)
	{
		// everyStep();
		if (!persistentUpdate)
			MusicBeatState.timePassedOnState += elapsed;
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if (curStep > 0)
				stepHit();

			if (PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if (stepsToDo < 1)
			stepsToDo = Math.round(getBeatsOnSection() * 4);
		while (curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if (curStep < 0)
			return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if (stepsToDo > curStep)
					break;

				curSection++;
			}
		}

		if (curSection > lastSection)
			sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep / 4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}

	public function sectionHit():Void
	{
		// yep, you guessed it, nothing again, dumbass
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if (PlayState.SONG != null && PlayState.SONG.notes[curSection] != null)
			val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}

	public function addCameraOverlay()
	{
		// add(constantstaticAnimeshoun);
		// add(staticAnimeshoun);
		add(whiteAnimeshoun);
		add(camAnimeshoun);
		add(crtFilter);
	}

	public function removeCameraOverlay()
	{
		// remove(constantstaticAnimeshoun);
		// remove(staticAnimeshoun);
		remove(whiteAnimeshoun);
		remove(camAnimeshoun);
		remove(crtFilter);
	}

	public function hideCameraOverlay(hide:Bool = false)
	{
		camAnimeshoun.visible = !hide;
		crtFilter.visible = !hide;
		// staticAnimeshoun.visible = !hide;
		whiteAnimeshoun.visible = !hide;
		// constantstaticAnimeshoun.visible = !hide;
	}
}
