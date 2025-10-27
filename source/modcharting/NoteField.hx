package modcharting;

import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxAngle;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer.FlxTimerManager;
import modcharting.Modifier;
import modcharting.Proxiefield.Proxie as Proxy;
import objects.Note;
import objects.StrumNote;
import objects.SustainTrail;
import openfl.geom.Vector3D;
import states.PlayState;

using StringTools;

class NoteField extends FlxBasic
{
	public var strums:FlxTypedGroup<StrumNote>;
	public var notes:FlxTypedGroup<Note>;
	public var renderer:PlayfieldRenderer = null;
	public var pfIndex:Int = 0;

	public function new(renderer:PlayfieldRenderer, pfIndex:Int = 0)
	{
		super();
		this.renderer = renderer;
		this.pfIndex = pfIndex;

		try
		{
			if (Reflect.getProperty(renderer.instance, 'strumLineNotes') != null)
				this.strums = Reflect.getProperty(renderer.instance, 'strumLineNotes');

			if (Reflect.getProperty(renderer.instance, 'notes') != null)
				this.notes = Reflect.getProperty(renderer.instance, 'notes');
		}
		catch (e:haxe.Exception)
			trace(e.message, e.stack);
		trace(pfIndex);
		trace(notes.length);
		trace(strums.length);
	}

	private var debuggingMode:Bool = false; // to make tracing errors easier instead of a vague "null object reference"

	private function addDataToStrum(strumData:NotePositionData, strum:StrumNote)
	{
		// not really needed since we draw the shit manually now

		strum.x = strumData.x;
		strum.y = strumData.y;
		strum.angle = strumData.angle;
		// strum.angleZ = strumData.angleZ;
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

	private function getDataForStrum(i:Int)
	{
		var strumX = NoteMovement.defaultStrumX[i];
		var strumY = NoteMovement.defaultStrumY[i];
		var strumZ = 0;
		var strumScaleX = NoteMovement.defaultScale[i];
		var strumScaleY = NoteMovement.defaultScale[i];
		var strumSkewX = NoteMovement.defaultSkewX[i];
		var strumSkewY = NoteMovement.defaultSkewY[i];
		if (ModchartUtil.getIsPixelStage(renderer.instance))
		{
			// work on pixel stages
			strumScaleX = 1 * PlayState.daPixelZoom;
			strumScaleY = 1 * PlayState.daPixelZoom;
		}
		final strumData:NotePositionData = NotePositionData.get();
		strumData.setupStrum(strumX, strumY, strumZ, i, strumScaleX, strumScaleY, strumSkewX, strumSkewY, pfIndex);
		renderer.modifierTable.applyStrumMods(strumData, i, pfIndex);
		return strumData;
	}

	private function addDataToNote(noteData:NotePositionData, daNote:Note)
	{
		daNote.x = noteData.x;
		daNote.y = noteData.y;
		daNote.z = noteData.z;
		daNote.angle = noteData.angle;
		// daNote.angleZ = noteData.angleZ;
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

	private function createDataFromNote(noteIndex:Int, curPos:Float, noteDist:Float, incomingAngle:Array<Float>)
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

		if (ModchartUtil.getIsPixelStage(renderer.instance))
		{
			// work on pixel stages
			noteScaleX = 1 * PlayState.daPixelZoom;
			noteScaleY = 1 * PlayState.daPixelZoom;
		}

		final noteData:NotePositionData = NotePositionData.get();
		noteData.setupNote(noteX, noteY, noteZ, lane, noteScaleX, noteScaleY, noteSkewX, noteSkewY, pfIndex, noteAlpha, curPos, noteDist, incomingAngle[0],
			incomingAngle[1], notes.members[noteIndex].strumTime, noteIndex, notes.members[noteIndex].isSustainNote);
		return noteData;
	}

	private function getNoteCurPos(noteIndex:Int, strumTimeOffset:Float = 0)
	{
		#if PSYCH
		if (notes.members[noteIndex].isSustainNote && ModchartUtil.getDownscroll(renderer.instance))
			strumTimeOffset -= Std.int(Conductor.stepCrochet / renderer.getCorrectScrollSpeed()); // psych does this to fix its sustains but that breaks the visuals so basically reverse it back to normal
		#else
		if (notes.members[noteIndex].isSustainNote && !ModchartUtil.getDownscroll(renderer.instance))
			strumTimeOffset += Conductor.stepCrochet; // fix upscroll lol
		#end
		if (notes.members[noteIndex].isSustainNote)
		{
			// moved those inside holdsMath cuz they are only needed for sustains ig?
			var lane = getLane(noteIndex);

			var noteDist = getNoteDist();
			noteDist = renderer.modifierTable.applyNoteDistMods(noteDist, lane, pfIndex);

			strumTimeOffset += Std.int(Conductor.stepCrochet / renderer.getCorrectScrollSpeed());

			final scrollDivition = 1 / renderer.getCorrectScrollSpeed();
			if (ModchartUtil.getDownscroll(renderer.instance))
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
		return distance * renderer.getCorrectScrollSpeed();
	}

	private function getLane(noteIndex:Int)
	{
		return (notes.members[noteIndex].mustPress ? notes.members[noteIndex].noteData + NoteMovement.keyCount : notes.members[noteIndex].noteData);
	}

	// lol XD
	public function getNoteDist()
	{
		var noteDist = -0.55;
		if (ModchartUtil.getDownscroll(renderer.instance))
			noteDist *= -1;
		return noteDist;
	}

	// Todo: Find how to create arrow paths using strum notes and notes using this function to make both work (I.E Create NoteDataPositions for ArrowPath)
	private function getNotePositions()
	{
		var notePositions:Array<NotePositionData> = [];
		for (i => strum in strums.members)
			notePositions.push(getDataForStrum(i));
		for (i => note in notes.members)
		{
			var songSpeed = renderer.getCorrectScrollSpeed();

			var lane = getLane(i);
			var sustainTimeThingy:Float = 0;

			var noteDist = getNoteDist();
			var curPos = getNoteCurPos(i, sustainTimeThingy);

			noteDist = renderer.modifierTable.applyNoteDistMods(noteDist, lane, pfIndex);

			// this code was to make sustains end match their ACTUAL size on spritesheed, but as it tells you, it doesn't work (yet) lmao

			// just causes too many issues lol, might fix it at some point
			// if (notes.members[i].animation.curAnim.name.endsWith('end') && ClientPrefs.data.downScroll) //checking rn LMAO
			// {
			//     if (noteDist > 0)
			//         sustainTimeThingy = (ModchartUtil.getFakeCrochet()/4)/2; //fix stretched sustain ends (downscroll)
			//     //else
			//         //sustainTimeThingy = (-NoteMovement.getFakeCrochet()/4)/songSpeed;
			// }

			curPos = renderer.modifierTable.applyCurPosMods(lane, curPos, pfIndex);

			if ((notes.members[i].wasGoodHit || (notes.members[i].prevNote.wasGoodHit)) && curPos >= 0 && notes.members[i].isSustainNote)
				curPos = 0; // sustain clip

			var incomingAngle:Array<Float> = renderer.modifierTable.applyIncomingAngleMods(lane, curPos, pfIndex);
			if (noteDist < 0)
				incomingAngle[0] += 180; // make it match for both scrolls

			// get the general note path
			NoteMovement.setNotePath(notes.members[i], lane, songSpeed, curPos, noteDist, incomingAngle[0], incomingAngle[1]);

			// save the position data
			var noteData = createDataFromNote(i, curPos, noteDist, incomingAngle);

			// add offsets to data with modifiers
			renderer.modifierTable.applyNoteMods(noteData, lane, curPos, pfIndex);

			// add position data to list
			notePositions.push(noteData);
		}

		// sort by z before drawing
		notePositions.sort(function(a, b) return ((a.z < b.z) ? -1 : ((a.z > b.z) ? 1 : 0)));
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
		var strumNote = strums.members[noteData.index];

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
		// strumNote.applyNoteData(noteData);
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
			thisNotePos = ModchartUtil.calculatePerspective(new Vector3D(noteData.x
				+ (daNote.width / 2)
				+ ModchartUtil.getNoteOffsetX(daNote, renderer.instance), noteData.y
				+ (daNote.height / 2), noteData.z * 0.001),
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
		// daNote.applyNoteData(noteData);
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

		var songSpeed = renderer.getCorrectScrollSpeed();
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
			if (!ModchartUtil.getDownscroll(renderer.instance)) // fix reverse
				flipGraphic = true;
		}
		else
		{
			if (ModchartUtil.getDownscroll(renderer.instance))
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

		var strumNote = strums.members[noteData.index];

		var arrowPathLength:Float = noteData.arrowPathLength * 100;
		var arrowPathBackLength:Float = noteData.arrowPathBackwardsLength * 100;

		if (strumNote.arrowPath == null)
			strumNote.arrowPath = new SustainTrail(noteData.index, arrowPathLength, renderer);

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
		var songSpeed:Float = renderer.getCorrectScrollSpeed();
		var lane:Int = noteData.lane;

		var noteDist:Float = getNoteDist();
		var curPos:Float = getNoteCurPos(noteData.index, timeOffset);

		curPos = renderer.modifierTable.applyCurPosMods(lane, curPos, pfIndex);

		if ((daNote.wasGoodHit || (daNote.prevNote.wasGoodHit)) && curPos >= 0)
			curPos = 0; // so sustain does a "fake" clip

		noteDist = renderer.modifierTable.applyNoteDistMods(noteDist, lane, pfIndex);
		var incomingAngle:Array<Float> = renderer.modifierTable.applyIncomingAngleMods(lane, curPos, pfIndex);
		if (noteDist < 0)
			incomingAngle[0] += 180; // make it match for both scrolls
		// get the general note path for the next note
		NoteMovement.setNotePath(daNote, lane, songSpeed, curPos, noteDist, incomingAngle[0], incomingAngle[1]);
		// save the position data
		var noteData = createDataFromNote(noteData.index, curPos, noteDist, incomingAngle);
		// add offsets to data with modifiers
		renderer.modifierTable.applyNoteMods(noteData, lane, curPos, pfIndex);
		var yOffsetThingy = (NoteMovement.arrowSizes[lane] / 2);
		var finalNotePos = ModchartUtil.calculatePerspective(new Vector3D(noteData.x
			+ (daNote.width / 2)
			+ ModchartUtil.getNoteOffsetX(daNote, renderer.instance),
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
		var songSpeed:Float = renderer.getCorrectScrollSpeed();
		var lane:Int = noteData.lane;

		var noteDist:Float = getNoteDist();
		var curPos:Float = getNoteCurPos(noteData.index, timeOffset);

		curPos = renderer.modifierTable.applyCurPosMods(lane, curPos, pfIndex);

		noteDist = renderer.modifierTable.applyNoteDistMods(noteDist, lane, pfIndex);
		var incomingAngle:Array<Float> = renderer.modifierTable.applyIncomingAngleMods(lane, curPos, pfIndex);
		if (noteDist < 0)
			incomingAngle[0] += 180; // make it match for both scrolls
		// get the general note path for the next note
		NoteMovement.setNotePath(daNote, lane, songSpeed, curPos, noteDist, incomingAngle[0], incomingAngle[1]);
		// save the position data
		var noteData = createDataFromNote(noteData.index, curPos, noteDist, incomingAngle);
		// add offsets to data with modifiers
		renderer.modifierTable.applyNoteMods(noteData, lane, curPos, pfIndex);

		var changeX:Bool = noteData.z != 0;

		var finalNotePos;
		if (changeX)
		{
			finalNotePos = ModchartUtil.calculatePerspective(new Vector3D(noteData.x
				+ (daNote.width / 2)
				+ ModchartUtil.getNoteOffsetX(daNote, renderer.instance), noteData.y
				+ (daNote.height / 2), noteData.z * 0.001),
				ModchartUtil.defaultFOV * (Math.PI / 180));
		}
		else
		{
			finalNotePos = new Vector3D(noteData.x
				+ (daNote.width / 2)
				+ ModchartUtil.getNoteOffsetX(daNote, renderer.instance),
				noteData.y
				+ (daNote.height / 2), 0);
		}

		noteData.x = finalNotePos.x;
		noteData.y = finalNotePos.y;
		noteData.z = finalNotePos.z;

		return noteData;
	}

	override public function draw()
	{
		try
			drawStuff(getNotePositions())
		catch (e:haxe.Exception)
			trace(e.message, e.stack);
	}
}
