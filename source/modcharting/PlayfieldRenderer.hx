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

	public function new(strumGroup:FlxTypedGroup<StrumNoteType>, notes:FlxTypedGroup<Note>, instance:ModchartMusicBeatState)
	{
		super();
		this.strumGroup = strumGroup;
		this.notes = notes;
		this.instance = instance;
		if (Std.isOfType(instance, PlayState))
			playStateInstance = cast instance; // so it just casts once
		/*if (Std.isOfType(instance, editors.content.EditorPlayState))
			{
				editorPlayStateInstance = cast instance; // so it just casts once
				isEditor = true;
		}*/

		strumGroup.visible = false; // drawing with renderer instead
		notes.visible = false;

		// fix stupid crash because the renderer in playstate is still technically null at this point and its needed for json loading
		instance.playfieldRenderer = this;

		tweenManager = new FlxTweenManager();
		timerManager = new FlxTimerManager();
		eventManager = new ModchartEventManager(this);
		modifierTable = new ModTable(instance, this);
		addNewPlayfield(0, 0, 0);

		// why ??
		// addNewProxiefield(new Proxy());
		modchart = new ModchartFile(this);
	}

	public function addNewPlayfield(?x:Float = 0, ?y:Float = 0, ?z:Float = 0, ?alpha:Float = 1)
	{
		playfields.push(new Playfield(x, y, z, alpha));
	}

	public function addNewProxiefield(proxy:Proxy)
	{
		proxiefields.push(new Proxiefield(proxy));
	}

	override function update(elapsed:Float)
	{
		eventManager.update(elapsed);
		tweenManager.update(elapsed); // should be automatically paused when you pause in game
		timerManager.update(elapsed);
		super.update(elapsed);
	}

	override public function draw()
	{
		if (!visible)
			return;

		strumGroup.cameras = this.cameras;
		notes.cameras = this.cameras;

		// draw notes to screen
		if (!debuggingMode)
		{
			drawStuff(getNotePositions());
		}
		else
		{
			try
			{
				drawStuff(getNotePositions());
			}
			catch (e)
			{
				trace(e);
			}
		}
	}

	private var debuggingMode:Bool = true; // to make tracing errors easier instead of a vague "null object reference"

	private function addDataToStrum(strumData:NotePositionData, strum:StrumNote)
	{
		// not really needed since we draw the shit manually now

		strum.x = strumData.x;
		strum.y = strumData.y;
		strum.angle = strumData.angle;
		//strum.angleZ = strumData.angleZ;
		strum.angleY = strumData.angleY;
		strum.angleX = strumData.angleX;
		strum.alpha = strumData.alpha;
		strum.scale.x = strumData.scaleX;
		strum.scale.y = strumData.scaleY;
		strum.skew.x = strumData.skewX;
		strum.skew.y = strumData.skewY;
		 

		strum.rgbShader.stealthGlow = strumData.stealthGlow;
		strum.rgbShader.stealthGlowRed = strumData.glowRed;
		strum.rgbShader.stealthGlowGreen = strumData.glowGreen;
		strum.rgbShader.stealthGlowBlue = strumData.glowBlue;
	}

	private function getDataForStrum(i:Int, pf:Int)
	{
		var strumX = NoteMovement.defaultStrumX[i];
		var strumY = NoteMovement.defaultStrumY[i];
		var strumZ = 0;
		var strumScaleX = NoteMovement.defaultScale[i];
		var strumScaleY = NoteMovement.defaultScale[i];
		var strumSkewX = NoteMovement.defaultSkewX[i];
		var strumSkewY = NoteMovement.defaultSkewY[i];
		if (ModchartUtil.getIsPixelStage(instance))
		{
			// work on pixel stages
			strumScaleX = 1 * PlayState.daPixelZoom;
			strumScaleY = 1 * PlayState.daPixelZoom;
		}
		var strumData:NotePositionData = NotePositionData.get();
		strumData.setupStrum(strumX, strumY, strumZ, i, strumScaleX, strumScaleY, strumSkewX, strumSkewY, pf);
		playfields[pf].applyOffsets(strumData);
		modifierTable.applyStrumMods(strumData, i, pf);
		return strumData;
	}

	private function addDataToNote(noteData:NotePositionData, daNote:Note)
	{
		daNote.x = noteData.x;
		daNote.y = noteData.y;
		daNote.z = noteData.z;
		daNote.angle = noteData.angle;
		//daNote.angleZ = noteData.angleZ;
		daNote.angleY = noteData.angleY;
		daNote.angleX = noteData.angleX;
		daNote.alpha = noteData.alpha;
		daNote.scale.x = noteData.scaleX;
		daNote.scale.y = noteData.scaleY;
		daNote.skew.x = noteData.skewX;
		daNote.skew.y = noteData.skewY;

		daNote.rgbShader.stealthGlow = noteData.stealthGlow;
		daNote.rgbShader.stealthGlowRed = noteData.glowRed;
		daNote.rgbShader.stealthGlowGreen = noteData.glowGreen;
		daNote.rgbShader.stealthGlowBlue = noteData.glowBlue;
	}

	private function createDataFromNote(noteIndex:Int, playfieldIndex:Int, curPos:Float, noteDist:Float, incomingAngle:Array<Float>)
	{
		var noteX = notes.members[noteIndex].x;
		var noteY = notes.members[noteIndex].y;
		var noteZ = notes.members[noteIndex].z;
		var lane = getLane(noteIndex);
		var noteScaleX = NoteMovement.defaultScale[lane];
		var noteScaleY = NoteMovement.defaultScale[lane];
		var noteSkewX = notes.members[noteIndex].skew.x;
		var noteSkewY = notes.members[noteIndex].skew.y;

		var noteAlpha:Float = 1;

		// if (!notesGroup[field][noteIndex].specialHurt)
		#if PSYCH
		if (!notes.members[noteIndex].specialHurt)
		{
			noteAlpha = notes.members[noteIndex].multAlpha;
			if (notes.members[noteIndex].hurtNote)
				noteAlpha = 0.55;
			if (notes.members[noteIndex].mimicNote)
				noteAlpha = ClientPrefs.data.mimicNoteAlpha;
		}
		else
		{
			noteAlpha = 0;
		}
		#else
		if (notes.members[noteIndex].isSustainNote)
			noteAlpha = 0.6;
		else
			noteAlpha = 1;
		#end

		if (ModchartUtil.getIsPixelStage(instance))
		{
			// work on pixel stages
			noteScaleX = 1 * PlayState.daPixelZoom;
			noteScaleY = 1 * PlayState.daPixelZoom;
		}

		var noteData:NotePositionData = NotePositionData.get();
		noteData.setupNote(noteX, noteY, noteZ, lane, noteScaleX, noteScaleY, noteSkewX, noteSkewY, playfieldIndex, noteAlpha, curPos, noteDist,
			incomingAngle[0], incomingAngle[1], notes.members[noteIndex].strumTime, noteIndex, notes.members[noteIndex].isSustainNote);
		playfields[playfieldIndex].applyOffsets(noteData);
		return noteData;
	}

	private function getNoteCurPos(noteIndex:Int, strumTimeOffset:Float = 0, ?pf:Int = 0)
	{
		#if PSYCH
		if (notes.members[noteIndex].isSustainNote && ModchartUtil.getDownscroll(instance))
			strumTimeOffset -= Std.int(Conductor.stepCrochet / getCorrectScrollSpeed()); // psych does this to fix its sustains but that breaks the visuals so basically reverse it back to normal
		#else
		if (notes.members[noteIndex].isSustainNote && !ModchartUtil.getDownscroll(instance))
			strumTimeOffset += Conductor.stepCrochet; // fix upscroll lol
		#end
		if (notes.members[noteIndex].isSustainNote)
		{
			// moved those inside holdsMath cuz they are only needed for sustains ig?
			var lane = getLane(noteIndex);

			var noteDist = getNoteDist(noteIndex);
			noteDist = modifierTable.applyNoteDistMods(noteDist, lane, pf);

			strumTimeOffset += Std.int(Conductor.stepCrochet / getCorrectScrollSpeed());

			final scrollDivition = 1 / getCorrectScrollSpeed();
			if (ModchartUtil.getDownscroll(instance))
			{
				if (noteDist > 0)
					strumTimeOffset -= Std.int(Conductor.stepCrochet); // down
				else
				{
					strumTimeOffset += Std.int(Conductor.stepCrochet * scrollDivition);
					strumTimeOffset -= Std.int(Conductor.stepCrochet * scrollDivition);
				}
			}
			else
			{
				if (noteDist > 0)
				{
					strumTimeOffset -= Std.int(Conductor.stepCrochet * scrollDivition); // down
					strumTimeOffset -= Std.int(Conductor.stepCrochet); // down
				}
				else
					strumTimeOffset -= Std.int(Conductor.stepCrochet * scrollDivition);
			}
			// FINALLY OMG I HATE THIS FUCKING MATH LMAO
		}

		var distance = (Conductor.songPosition - notes.members[noteIndex].strumTime) + strumTimeOffset;
		return distance * getCorrectScrollSpeed();
	}

	private function getLane(noteIndex:Int)
	{
		return (notes.members[noteIndex].mustPress ? notes.members[noteIndex].noteData + NoteMovement.keyCount : notes.members[noteIndex].noteData);
	}

	// lol XD
	public function getNoteDist(noteIndex:Int)
	{
		var noteDist = -0.55;
		if (ModchartUtil.getDownscroll(instance))
			noteDist *= -1;
		return noteDist;
	}

	// Todo: Find how to create arrow paths using strum notes and notes using this function to make both work (I.E Create NoteDataPositions for ArrowPath)
	private function getNotePositions()
	{
		var notePositions:Array<NotePositionData> = [];
		for (pf in 0...playfields.length)
		{
			for (i in 0...strumGroup.members.length)
			{
				var strumData = getDataForStrum(i, pf);
				notePositions.push(strumData);
			}
			for (i in 0...notes.members.length)
			{
				var songSpeed = getCorrectScrollSpeed();

				var lane = getLane(i);
				var sustainTimeThingy:Float = 0;

				var noteDist = getNoteDist(i);
				var curPos = getNoteCurPos(i, sustainTimeThingy, pf);

				noteDist = modifierTable.applyNoteDistMods(noteDist, lane, pf);

				// this code was to make sustains end match their ACTUAL size on spritesheed, but as it tells you, it doesn't work (yet) lmao

				// just causes too many issues lol, might fix it at some point
				// if (notes.members[i].animation.curAnim.name.endsWith('end') && ClientPrefs.data.downScroll) //checking rn LMAO
				// {
				//     if (noteDist > 0)
				//         sustainTimeThingy = (ModchartUtil.getFakeCrochet()/4)/2; //fix stretched sustain ends (downscroll)
				//     //else
				//         //sustainTimeThingy = (-NoteMovement.getFakeCrochet()/4)/songSpeed;
				// }

				curPos = modifierTable.applyCurPosMods(lane, curPos, pf);

				if ((notes.members[i].wasGoodHit || (notes.members[i].prevNote.wasGoodHit))
					&& curPos >= 0
					&& notes.members[i].isSustainNote)
					curPos = 0; // sustain clip

				var incomingAngle:Array<Float> = modifierTable.applyIncomingAngleMods(lane, curPos, pf);
				if (noteDist < 0)
					incomingAngle[0] += 180; // make it match for both scrolls

				// get the general note path
				NoteMovement.setNotePath(notes.members[i], lane, songSpeed, curPos, noteDist, incomingAngle[0], incomingAngle[1]);

				// save the position data
				var noteData = createDataFromNote(i, pf, curPos, noteDist, incomingAngle);

				// add offsets to data with modifiers
				modifierTable.applyNoteMods(noteData, lane, curPos, pf);

				// add position data to list
				notePositions.push(noteData);
			}
		}
		// sort by z before drawing
		notePositions.sort(function(a, b)
		{
			if (a.z < b.z)
				return -1;
			else if (a.z > b.z)
				return 1;
			else
				return 0;
		});
		return notePositions;
	}

	private function drawStrum(noteData:NotePositionData)
	{
		if (noteData.alpha <= 0)
			return;
		var changeX:Bool = noteData.z != 0;

		/*targetGroup<Array<Array>> = new Array<Array>();

		targetGroup = [
			[0,1,2,3,4,5,6,7],
			[0,1,2,3,4,5,6,7]
		];

		*/
		// var strumNote = targetGroup[0][noteData.index];
		var strumNote = strumGroup.members[noteData.index];

		// if (strumNote == null)
		// {
		// 	strumNote.setupMesh();
		// }

		var thisNotePos;
		if (changeX)
			thisNotePos = ModchartUtil.calculatePerspective(new Vector3D(noteData.x + (strumNote.width / 2), noteData.y + (strumNote.height / 2),
				noteData.z * 0.001),
				ModchartUtil.defaultFOV * (Math.PI / 180),
				-(strumNote.width / 2),
				-(strumNote.height / 2));
		else
			thisNotePos = new Vector3D(noteData.x, noteData.y, 0);

		var skewX = ModchartUtil.getStrumSkew(strumNote, false);
		var skewY = ModchartUtil.getStrumSkew(strumNote, true);
		noteData.x = thisNotePos.x;
		noteData.y = thisNotePos.y;
		if (changeX)
		{
			noteData.scaleX *= (1 / -thisNotePos.z);
			noteData.scaleY *= (1 / -thisNotePos.z);
		}

		// var getNextNote = getNotePoss(noteData,1);

		// Orient can be fixed, just need make it on strums too
		// if (noteData.orient != 0)
		// 	noteData.angle = (-90 + (angle = Math.atan2(getNextNote.y - noteData.y , getNextNote.x - noteData.x) * FlxAngle.TO_DEG)) * noteData.orient;

		if (noteData.stealthGlow != 0)
			strumNote.rgbShader.enabled = true; // enable stealthGlow once it finds its not 0?

		addDataToStrum(noteData, strumNote); // set position and stuff before drawing

		strumNote.cameras = this.cameras;

		// Same as strums case
		// if (strumNote != null)
		// {
		// 	strumNote.setupMesh(noteData);
		// 	strumNote.draw();
		// }
		// else
			//strumNote.applyNoteData(noteData);
			strumNote.draw();
	}

	private function drawNote(noteData:NotePositionData)
	{
		if (noteData.alpha <= 0)
			return;
		var changeX:Bool = noteData.z != 0;
		var daNote = notes.members[noteData.index];

		// if (daNote == null)
		// {
		// 	daNote.setupMesh();
		// }

		var thisNotePos;
		if (changeX)
			thisNotePos = ModchartUtil.calculatePerspective(new Vector3D(noteData.x + (daNote.width / 2) + ModchartUtil.getNoteOffsetX(daNote, instance),
				noteData.y + (daNote.height / 2), noteData.z * 0.001),
				ModchartUtil.defaultFOV * (Math.PI / 180),
				-(daNote.width / 2),
				-(daNote.height / 2));
		else
			thisNotePos = new Vector3D(noteData.x, noteData.y, 0);

		var skewX = ModchartUtil.getNoteSkew(daNote, false);
		var skewY = ModchartUtil.getNoteSkew(daNote, true);
		noteData.x = thisNotePos.x;
		noteData.y = thisNotePos.y;
		if (changeX)
		{
			noteData.scaleX *= (1 / -thisNotePos.z);
			noteData.scaleY *= (1 / -thisNotePos.z);
		}

		var getNextNote = getNotePoss(noteData, 1);

		if (noteData.orient != 0)
			noteData.angle = ((Math.atan2(getNextNote.y - noteData.y, getNextNote.x - noteData.x) * FlxAngle.TO_DEG) - 90) * noteData.orient;

		addDataToNote(noteData, daNote);

		daNote.cameras = this.cameras;
		// Same as strums case
		// if (daNote != null)
		// {
		// 	daNote.setupMesh(noteData);
		// 	daNote.draw();
		// }
		// else
			//daNote.applyNoteData(noteData);
			daNote.draw();
	}

	private function drawSustainNote(noteData:NotePositionData)
	{
		if (noteData.alpha <= 0)
			return;

		var daNote = notes.members[noteData.index];
		if (daNote.mesh == null)
			daNote.mesh = new SustainStrip(daNote);

		var spiral = (noteData.spiralHold >= 0.5);

		daNote.alpha = noteData.alpha;
		daNote.mesh.alpha = daNote.alpha;
		daNote.mesh.shader = daNote.rgbShader.parent.shader; // idfk if this works.
		daNote.mesh.spiralHolds = spiral; // if noteData its 1 spiral holds mod should be enabled?

		var songSpeed = getCorrectScrollSpeed();
		var lane = noteData.lane;

		// makes the sustain match the center of the parent note when at weird angles
		var yOffsetThingy = (NoteMovement.arrowSizes[lane] / 2);

		var timeToNextSustain = ModchartUtil.getFakeCrochet() / 4;
		if (noteData.noteDist < 0)
			timeToNextSustain *= -1; // weird shit that fixes upscroll lol

		var top = [];
		var mid = [];
		var bot = [];

		if (spiral)
		{
			top = [getSustainPoint(noteData, 0), getSustainPoint(noteData, 1)];
			mid = [
				getSustainPoint(noteData, timeToNextSustain * .5),
				getSustainPoint(noteData, timeToNextSustain * .5 + 1)
			];
			bot = [
				getSustainPoint(noteData, timeToNextSustain),
				getSustainPoint(noteData, timeToNextSustain + 1)
			];
		}
		else
		{
			top = [getSustainPoint(noteData, 0)];
			mid = [getSustainPoint(noteData, timeToNextSustain * .5)];
			bot = [getSustainPoint(noteData, timeToNextSustain)];
		}

		var flipGraphic = false;

		// mod/bound to 360, add 360 for negative angles, mod again just in case
		var fixedAngY = ((noteData.incomingAngleY % 360) + 360) % 360;

		var reverseClip = (fixedAngY > 90 && fixedAngY < 270);

		if (noteData.noteDist > 0) // downscroll
		{
			if (!ModchartUtil.getDownscroll(instance)) // fix reverse
				flipGraphic = true;
		}
		else
		{
			if (ModchartUtil.getDownscroll(instance))
				flipGraphic = true;
		}
		// render that shit
		daNote.mesh.constructVertices(noteData, top, mid, bot, flipGraphic, reverseClip);

		daNote.mesh.cameras = this.cameras;
		daNote.mesh.draw();
	}

	private function drawArrowPathNew(noteData:NotePositionData)
	{ // this one is unused since i have no clue what to do.
		if (noteData.arrowPathAlpha <= 0)
			return;

		// TODO:
		/*
			- make this draw similar to VSLICE sustain draw (so i can make sustain mesh correctly, maybe just copy paste sustain code and change info to MT?)
			- make sure this shit doesn't lag the engine out unlike the old one
			- make sure that if no graphic exist, we create one (such as a FlxGraphic with the size the strip needs and stuff like that)
			- optimize the code to make it easier to understand
		 */

		var strumNote = strumGroup.members[noteData.index];

		var arrowPathLength:Float = noteData.arrowPathLength * 100;
		var arrowPathBackLength:Float = noteData.arrowPathBackwardsLength * 100;

		if (strumNote.arrowPath == null)
			strumNote.arrowPath = new SustainTrail(noteData.index, arrowPathLength, this);

		strumNote.arrowPath.alpha = noteData.arrowPathAlpha;

		strumNote.arrowPath.fullSustainLength = strumNote.arrowPath.sustainLength = arrowPathLength + arrowPathBackLength;
		strumNote.arrowPath.strumTime = Conductor.songPosition;
		strumNote.arrowPath.strumTime -= arrowPathBackLength;
		strumNote.arrowPath.x = 0;
		strumNote.arrowPath.y = 0;

		strumNote.arrowPath.shader = strumNote.rgbShader.parent.shader; // idfk if this works.

		strumNote.arrowPath.updateClipping_mods(noteData);

		strumNote.arrowPath.cameras = this.cameras;
		strumNote.arrowPath.draw();
	}

	private function drawStuff(notePositions:Array<NotePositionData>)
	{
		for (noteData in notePositions)
		{
			if (noteData.isStrum) // make sure we draw the path for each before we even draw each?
				drawArrowPathNew(noteData);

			if (noteData.isStrum) // draw strum
				drawStrum(noteData);
			else if (!notes.members[noteData.index].isSustainNote) // draw note
				drawNote(noteData);
			else // draw Sustain
				drawSustainNote(noteData);
		}
	}

	function getSustainPoint(noteData:NotePositionData, timeOffset:Float):NotePositionData
	{
		var daNote:Note = notes.members[noteData.index];
		var songSpeed:Float = getCorrectScrollSpeed();
		var lane:Int = noteData.lane;
		var pf:Int = noteData.playfieldIndex;

		var noteDist:Float = getNoteDist(noteData.index);
		var curPos:Float = getNoteCurPos(noteData.index, timeOffset, pf);

		curPos = modifierTable.applyCurPosMods(lane, curPos, pf);

		if ((daNote.wasGoodHit || (daNote.prevNote.wasGoodHit)) && curPos >= 0)
			curPos = 0; // so sustain does a "fake" clip

		noteDist = modifierTable.applyNoteDistMods(noteDist, lane, pf);
		var incomingAngle:Array<Float> = modifierTable.applyIncomingAngleMods(lane, curPos, pf);
		if (noteDist < 0)
			incomingAngle[0] += 180; // make it match for both scrolls
		// get the general note path for the next note
		NoteMovement.setNotePath(daNote, lane, songSpeed, curPos, noteDist, incomingAngle[0], incomingAngle[1]);
		// save the position data
		var noteData = createDataFromNote(noteData.index, pf, curPos, noteDist, incomingAngle);
		// add offsets to data with modifiers
		modifierTable.applyNoteMods(noteData, lane, curPos, pf);
		var yOffsetThingy = (NoteMovement.arrowSizes[lane] / 2);
		var finalNotePos = ModchartUtil.calculatePerspective(new Vector3D(noteData.x
			+ (daNote.width / 2)
			+ ModchartUtil.getNoteOffsetX(daNote, instance),
			noteData.y
			+ (NoteMovement.arrowSizes[noteData.lane] / 2), noteData.z * 0.001),
			ModchartUtil.defaultFOV * (Math.PI / 180), 0, 0);

		noteData.x = finalNotePos.x;
		noteData.y = finalNotePos.y;
		noteData.z = finalNotePos.z;

		return noteData;
	}

	function getNotePoss(noteData:NotePositionData, timeOffset:Float):NotePositionData
	{
		var daNote:Note = notes.members[noteData.index];
		var songSpeed:Float = getCorrectScrollSpeed();
		var lane:Int = noteData.lane;
		var pf:Int = noteData.playfieldIndex;

		var noteDist:Float = getNoteDist(noteData.index);
		var curPos:Float = getNoteCurPos(noteData.index, timeOffset, pf);

		curPos = modifierTable.applyCurPosMods(lane, curPos, pf);

		noteDist = modifierTable.applyNoteDistMods(noteDist, lane, pf);
		var incomingAngle:Array<Float> = modifierTable.applyIncomingAngleMods(lane, curPos, pf);
		if (noteDist < 0)
			incomingAngle[0] += 180; // make it match for both scrolls
		// get the general note path for the next note
		NoteMovement.setNotePath(daNote, lane, songSpeed, curPos, noteDist, incomingAngle[0], incomingAngle[1]);
		// save the position data
		var noteData = createDataFromNote(noteData.index, pf, curPos, noteDist, incomingAngle);
		// add offsets to data with modifiers
		modifierTable.applyNoteMods(noteData, lane, curPos, pf);

		var changeX:Bool = noteData.z != 0;

		var finalNotePos;
		if (changeX)
		{
			finalNotePos = ModchartUtil.calculatePerspective(new Vector3D(noteData.x + (daNote.width / 2) + ModchartUtil.getNoteOffsetX(daNote, instance),
				noteData.y + (daNote.height / 2), noteData.z * 0.001),
				ModchartUtil.defaultFOV * (Math.PI / 180));
		}
		else
		{
			finalNotePos = new Vector3D(noteData.x + (daNote.width / 2) + ModchartUtil.getNoteOffsetX(daNote, instance), noteData.y + (daNote.height / 2), 0);
		}

		noteData.x = finalNotePos.x;
		noteData.y = finalNotePos.y;
		noteData.z = finalNotePos.z;

		return noteData;
	}

	public function getCorrectScrollSpeed()
	{
		return ModchartUtil.getScrollSpeed(inEditor ? null : playStateInstance);
	}

	public function createTween(Object:Dynamic, Values:Dynamic, Duration:Float, ?Options:TweenOptions):FlxTween
	{
		var tween:FlxTween = tweenManager.tween(Object, Values, Duration, Options);
		tween.manager = tweenManager;
		return tween;
	}

	public function createTweenNum(FromValue:Float, ToValue:Float, Duration:Float = 1, ?Options:TweenOptions, ?TweenFunction:Float->Void):FlxTween
	{
		var tween:FlxTween = tweenManager.num(FromValue, ToValue, Duration, Options, TweenFunction);
		tween.manager = tweenManager;
		return tween;
	}

	override public function destroy()
	{
		if (modchart != null)
		{
			for (customMod in modchart.customModifiers)
			{
				customMod.destroy(); // make sure the interps are dead
			}
		}
		super.destroy();
	}
}
