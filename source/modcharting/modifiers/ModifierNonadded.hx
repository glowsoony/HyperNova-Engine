package modcharting.modifiers;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import haxe.ds.List;
import lime.math.Vector4;
import modcharting.PlayfieldRenderer.StrumNoteType;
import modcharting.modifiers.*; // so this should work?
import objects.Note;
import openfl.geom.Vector3D;
import states.PlayState;

enum ModifierType
{
	ALL;
	PLAYERONLY;
	OPPONENTONLY;
	LANESPECIFIC;
}

class TimeVector extends Vector4
{
	public var startDist:Float;
	public var endDist:Float;
	public var next:TimeVector;

	public function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 0)
	{
		super(x, y, z, w);
		startDist = 0.0;
		endDist = 0.0;
		next = null;
	}
}

class ModifierSubValue
{
	public var value:Float = 0.0;
	public var baseValue:Float = 0.0;

	public function new(value:Float)
	{
		this.value = value;
		baseValue = value;
	}
}

class Modifier
{
	public var baseValue:Float = 0;
	public var currentValue:Float = 0;
	public var subValues:Map<String, ModifierSubValue> = new Map<String, ModifierSubValue>();
	public var tag:String = '';
	public var type:ModifierType = ALL;
	public var playfield:Int = -1;
	public var targetLane:Int = -1;
	public var instance:ModchartMusicBeatState = null;
	public var renderer:PlayfieldRenderer = null;

	public static var beat:Float = 0;
	public static var step:Float = 0;
	public static var curBeat:Int = 0;
	public static var curStep:Int = 0;

	public var notes:FlxTypedGroup<Note>;

	public function new(tag:String, ?type:ModifierType = ALL, ?playfield:Int = -1)
	{
		this.tag = tag;
		this.type = type;
		this.playfield = playfield;

		setupSubValues();
	}

	public function getNotePath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		if (currentValue != baseValue)
			noteMath(noteData, lane, curPos, pf);
	}

	public function getStrumPath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (currentValue != baseValue)
			strumMath(noteData, lane, pf);
	}

	public function getIncomingAngle(lane:Int, curPos:Float, pf:Int):Array<Float>
	{
		if (currentValue != baseValue)
			return incomingAngleMath(lane, curPos, pf);
		return [0, 0];
	}

	// cur pos is how close the note is to the strum, need to edit for boost and accel
	public function getNoteCurPos(lane:Int, curPos:Float, pf:Int)
	{
		if (currentValue != baseValue)
			curPos = curPosMath(lane, curPos, pf);
		return curPos;
	}

	// usually fnf does *0.45 to slow the scroll speed a little, thats what this is
	// kinda just called it notedist cuz idk what else to call it,
	// using it for reverse/scroll speed changes ig
	public function getNoteDist(noteDist:Float, lane:Int, curPos:Float, pf:Int)
	{
		if (currentValue != baseValue)
			noteDist = noteDistMath(noteDist, lane, curPos, pf);

		return noteDist;
	}

	public dynamic function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
	} // for overriding (and for custom mods with hscript)

	public dynamic function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
	}

	public dynamic function incomingAngleMath(lane:Int, curPos:Float, pf:Int):Array<Float>
	{
		return [0, 0];
	}

	public dynamic function curPosMath(lane:Int, curPos:Float, pf:Int)
	{
		return curPos;
	}

	public dynamic function noteDistMath(noteDist:Float, lane:Int, curPos:Float, pf:Int):Float
	{
		return noteDist;
	}

	public dynamic function setupSubValues()
	{
	}

	public function checkPlayField(pf:Int):Bool // returns true if should display on current playfield
	{
		return (playfield == -1) || (pf == playfield);
	}

	public function checkLane(lane:Int):Bool // returns true if should display on current lane
	{
		switch (type)
		{
			case LANESPECIFIC:
				return lane == targetLane;
			case PLAYERONLY:
				return lane >= NoteMovement.keyCount;
			case OPPONENTONLY:
				return lane < NoteMovement.keyCount;
			default: // so haxe shuts the fuck up
		}
		return true;
	}

	public function reset() // for the editor
	{
		currentValue = baseValue;
		for (subMod in subValues)
			subMod.value = subMod.baseValue;
	}

	public function copy()
	{
		// for custom mods to copy from the stored ones in the map
		var mod:Modifier = new Modifier(this.tag, this.type, this.playfield);
		mod.noteMath = this.noteMath;
		mod.strumMath = this.strumMath;
		mod.incomingAngleMath = this.incomingAngleMath;
		mod.curPosMath = this.curPosMath;
		mod.noteDistMath = this.noteDistMath;
		mod.currentValue = this.currentValue;
		mod.baseValue = this.currentValue;
		mod.subValues = this.subValues;
		mod.targetLane = this.targetLane;
		mod.instance = this.instance;
		mod.renderer = this.renderer;
		return mod;
	}

	public function createSubMod(name:String, startVal:Float)
	{
		subValues.set(name, new ModifierSubValue(startVal));
	}
}

class ModifierMath
{
	// Dunk math
	public static function Drunk(lane:Int, curPos:Float, speed:Float):Float
	{
		return (FlxMath.fastCos(((Conductor.songPosition * 0.001) + ((lane % NoteMovement.keyCount) * 0.2) +
			(curPos * 0.45) * (10 / FlxG.height)) * (speed * 0.2)) * Note.swagWidth * 0.5);
	};

	// TanDrunk math
	public static function TanDrunk(lane:Int, curPos:Float, period:Float, offset:Float, spacing:Float, speed:Float, size:Float)
	{
		return (Math.tan(((Conductor.songPosition * (0.001 * period))
			+ ((lane % NoteMovement.keyCount) * 0.2)
			+ (curPos * (0.225 * offset)) * ((spacing * 10) / FlxG.height)) * (speed * 0.2)) * Note.swagWidth * (0.5 * size));
	}

	// Tipsy math
	public static function Tipsy(lane:Int, speed:Float):Float
	{
		return (FlxMath.fastCos((Conductor.songPosition * 0.001 * (1.2) + (lane % NoteMovement.keyCount) * (2.0)) * (5) * speed * 0.2) * Note.swagWidth * 0.4);
	}

	// TanTipsy math
	public static function TanTipsy(lane:Int, speed:Float):Float
	{
		return (Math.tan((Conductor.songPosition * 0.001 * (1.2) + (lane % NoteMovement.keyCount) * (2.0)) * (5) * speed * 0.2) * Note.swagWidth * 0.4);
	};

	// Reverse Math
	public static function Reverse(noteData:NotePositionData, lane:Int, usingDownscroll:Bool) // no clue how would this be useful but ok??
	{
		var scrollSwitch = 520;
		if (usingDownscroll)
			scrollSwitch *= -1;

		return scrollSwitch;
	}

	public static function Centered(noteData:NotePositionData, lane:Int)
	{
		var screenCenter:Float = (FlxG.height / 2) - (NoteMovement.arrowSizes[lane] / 2);
		var differenceBetween:Float = noteData.y - screenCenter;
		return differenceBetween * -1;
	}

	/*public static function Rotate(noteData:NotePositionData, lane:Int) --until i figure it out
		{
			var xPos = NoteMovement.defaultStrumX[lane];
			var yPos = NoteMovement.defaultStrumY[lane];
			var rotX = ModchartUtil.getCartesianCoords3D(subValues.get('x').value, 90, xPos-subValues.get('rotatePointX').value);
			noteData.x += rotX.x+subValues.get('rotatePointX').value-xPos;
			var rotY = ModchartUtil.getCartesianCoords3D(90, subValues.get('y').value, yPos-subValues.get('rotatePointY').value);
			noteData.y += rotY.y+subValues.get('rotatePointY').value-yPos;
			noteData.z += rotX.z + rotY.z;

			var notePos = ModchartUtil.getCartesianCoords3D(rotX.x, rotY.x, rotX.y);
			return 
	}*/
	/*public static function StrumLineRotate(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
		{
			var laneShit = lane%NoteMovement.keyCount;
			var offsetThing = 0.5;
			var halfKeyCount = NoteMovement.keyCount/2;
			if (lane < halfKeyCount)
			{
				offsetThing = -0.5;
				laneShit = lane+1;
			}
			var distFromCenter = ((laneShit)-halfKeyCount)+offsetThing; //theres probably an easier way of doing this
			//basically
			//0 = 1.5
			//1 = 0.5
			//2 = -0.5
			//3 = -1.5
			//so if you then multiply by the arrow size, all notes should be in the same place
			noteData.x += -distFromCenter*NoteMovement.arrowSize;

			var upscroll = true;
			if (instance != null)
				if (ModchartUtil.getDownscroll(instance))
					upscroll = false;

			//var rot = ModchartUtil.getCartesianCoords3D(subValues.get('x').value, subValues.get('y').value, distFromCenter*NoteMovement.arrowSize);
			var q = SimpleQuaternion.fromEuler(subValues.get('z').value, subValues.get('x').value, (upscroll ? -subValues.get('y').value : subValues.get('y').value)); //i think this is the right order???
			//q = SimpleQuaternion.normalize(q); //dont think its too nessessary???
			noteData.x += q.x * distFromCenter*NoteMovement.arrowSize;
			noteData.y += q.y * distFromCenter*NoteMovement.arrowSize;
			noteData.z += q.z * distFromCenter*NoteMovement.arrowSize;
	}*/
	// Bumpy math
	public static function Bumpy(curPos:Float, speed:Float):Float
	{
		return 40 * FlxMath.fastSin(curPos * 0.01 * speed);
	}

	// TanBumpy math
	public static function TanBumpy(curPos:Float, speed:Float):Float
	{
		return 40 * Math.tan(curPos * 0.01 * speed);
	};

	// Beat math
	public static function Beat(curPos:Float, speed:Float, mult:Float):Float
	{
		var fAccelTime = 0.2;
		var fTotalTime = 0.5;

		/* If the song is really fast, slow down the rate, but speed up the
		 * acceleration to compensate or it'll look weird. */
		// var fBPM = Conductor.bpm * 60;
		// var fDiv = Math.max(1.0, Math.floor( fBPM / 150.0 ));
		// fAccelTime /= fDiv;
		// fTotalTime /= fDiv;

		var time = Modifier.beat * speed;
		var posMult = mult;
		/* offset by VisualDelayEffect seconds */
		var fBeat = time + fAccelTime;
		// fBeat /= fDiv;

		var bEvenBeat = (Math.floor(fBeat) % 2) != 0;

		/* -100.2 -> -0.2 -> 0.2 */
		if (fBeat < 0)
			return 0;

		fBeat -= Math.floor(fBeat);
		fBeat += 1;
		fBeat -= Math.floor(fBeat);

		if (fBeat >= fTotalTime)
			return 0;

		var fAmount:Float;
		if (fBeat < fAccelTime)
		{
			fAmount = FlxMath.remapToRange(fBeat, 0.0, fAccelTime, 0.0, 1.0);
			fAmount *= fAmount;
		}
		else
			/* fBeat < fTotalTime */ {
			fAmount = FlxMath.remapToRange(fBeat, fAccelTime, fTotalTime, 1.0, 0.0);
			fAmount = 1 - (1 - fAmount) * (1 - fAmount);
		}

		if (bEvenBeat)
			fAmount *= -1;

		var fShift = 20.0 * fAmount * FlxMath.fastSin((curPos * 0.01 * posMult) + (Math.PI / 2.0));
		return fShift;
	}

	// Invert math
	public static function Invert(lane:Int)
	{
		return NoteMovement.arrowSizes[lane] * (lane % 2 == 0 ? 1 : -1);
	}

	// Flip math
	public static function Flip(lane:Int)
	{
		var nd = lane % NoteMovement.keyCount;
		var newPos = FlxMath.remapToRange(nd, 0, NoteMovement.keyCount, NoteMovement.keyCount, -NoteMovement.keyCount);
		return newPos;
	}

	// Bounce math
	public static function Bounce(lane:Int, curPos:Float, speed:Float):Float
	{
		return NoteMovement.arrowSizes[lane] * Math.abs(FlxMath.fastSin(curPos * 0.005 * speed));
	}

	// InvertSine math
	public static function InvertSine(lane:Int, curPos:Float, pf:Int, currentValue:Float) // first mod mad that uses currentVal damn...
	{
		return FlxMath.fastSin(0 + (curPos * 0.004)) * (NoteMovement.arrowSizes[lane] * (lane % 2 == 0 ? 1 : -1) * currentValue * 0.5);
	}

	// Wave math
	public static function Wave(lane:Int, speed:Float)
	{
		return FlxMath.fastSin(((Conductor.songPosition) * (speed) * 0.0008) +
			(lane / 4)) * 0.2; // the 260 used in wave its just for it to look big, idk if you really need it in custom mods tho.
	}

	// TanWave math
	public static function TanWave(lane:Int, speed:Float)
	{
		return Math.tan(((Conductor.songPosition) * (speed) * 0.0008) +
			(lane / 4)) * 0.2; // the 260 used in wave its just for it to look big, idk if you really need it in custom mods tho.
	}

	// Ease math
	public static function Ease(lane:Int, speed:Float)
	{
		return (FlxMath.fastCos(((Conductor.songPosition * 0.001) +
			((lane % NoteMovement.keyCount) * 0.2) * (10 / FlxG.height)) * (speed * 0.2)) * Note.swagWidth * 0.5);
	}

	// Tornado math
	public static function Tornado(lane:Int, curPos:Float, speed:Float)
	{
		// thank you 4mbr0s3 & andromeda for the modifier lol -- LETS GOOOO FINALLY I FIGURED IT OUT
		var playerColumn = lane % NoteMovement.keyCount;
		var columnPhaseShift = playerColumn * Math.PI / 3;
		var phaseShift = (curPos / 135) * speed * 0.2;
		var returnReceptorToZeroOffsetX = (-Math.cos(-columnPhaseShift) + 1) / 2 * Note.swagWidth * 3;
		var offsetX = (-Math.cos((phaseShift - columnPhaseShift)) + 1) / 2 * Note.swagWidth * 3 - returnReceptorToZeroOffsetX;

		return offsetX;
	}

	// TanTornado math
	public static function TanTornado(lane:Int, curPos:Float, speed:Float)
	{
		var playerColumn = lane % NoteMovement.keyCount;
		var columnPhaseShift = playerColumn * Math.PI / 3;
		var phaseShift = (curPos / 135) * speed * 0.2;
		var returnReceptorToZeroOffsetZ = (-Math.tan(-columnPhaseShift) + 1) / 2 * Note.swagWidth * 3;
		var offsetX = (-Math.tan((phaseShift - columnPhaseShift)) + 1) / 2 * Note.swagWidth * 3 - returnReceptorToZeroOffsetZ;

		return offsetX;
	}

	// ZigZag math
	public static function ZigZag(lane:Int, curPos:Float, multVal:Float)
	{
		var mult:Float = NoteMovement.arrowSizes[lane] * multVal;
		var mm:Float = mult * 2;
		var ppp:Float = Math.abs(curPos * 0.45) + (mult / 2);
		var funny:Float = (ppp + mult) % mm;
		var result:Float = funny - mult;

		if (ppp % mm * 2 >= mm)
			result *= -1;
		result -= mult / 2;

		return result;
	}

	// Sawtooth math
	public static function Sawtooth(lane:Int, curPos:Float, multVal:Float)
	{
		var mult:Float = NoteMovement.arrowSizes[lane] * multVal;
		return ((curPos * 0.45) % mult / 2);
	}

	// Square math
	public static function SquareMath(lane:Int, curPos:Float, mult:Float, timeOffset:Float, xOffset:Float):Float
	{
		var mult:Float = (mult / (NoteMovement.arrowSizes[lane] * 2));
		var timeOffset:Float = timeOffset;
		var xOffset:Float = xOffset;
		var xVal:Float = FlxMath.fastSin(((curPos * 0.45) + timeOffset) * Math.PI * mult);
		xVal = Math.floor(xVal) + 0.5 + xOffset;

		return xVal;
	}

	// Cosecant math
	public static function Cosecant(lane:Int, curPos:Float, period:Float, offset:Float, spacing:Float, speed:Float, size:Float):Float
	{
		return (1 / Math.sin(((Conductor.songPosition * (0.001 * period))
			+ ((lane % NoteMovement.keyCount) * 0.2)
			+ (curPos * (0.225 * offset)) * ((spacing * 10) / FlxG.height)) * (speed * 0.2)) * Note.swagWidth * (0.5 * size));
	}

	/**
	 * Performs a modulo operation to calculate the remainder of `a` divided by `b`.
	 *
	 * The definition of "remainder" varies by implementation;
	 * this one is similar to GLSL or Python in that it uses Euclidean division, which always returns positive,
	 * while Haxe's `%` operator uses signed truncated division.
	 *
	 * For example, `-5 % 3` returns `-2` while `FlxMath.mod(-5, 3)` returns `1`.
	 *
	 * @param a The dividend.
	 * @param b The divisor.
	 * @return `a mod b`.
	 *
	 * SOURCE: https://github.com/HaxeFlixel/flixel/pull/3341/files
	 */
	public static inline function mod(a:Float, b:Float):Float
	{
		b = Math.abs(b);
		return a - b * Math.floor(a / b);
	}
}

class Rotate3DModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('x', new ModifierSubValue(0.0));
		subValues.set('y', new ModifierSubValue(0.0));

		subValues.set('rotatePointX', new ModifierSubValue((FlxG.width / 2) - (NoteMovement.arrowSize / 2)));
		subValues.set('rotatePointY', new ModifierSubValue((FlxG.height / 2) - (NoteMovement.arrowSize / 2)));
		currentValue = 1.0;
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var xPos = NoteMovement.defaultStrumX[lane];
		var yPos = NoteMovement.defaultStrumY[lane];
		var rotX = ModchartUtil.getCartesianCoords3D(-subValues.get('x').value, 90, xPos - subValues.get('rotatePointX').value);
		noteData.x += rotX.x + subValues.get('rotatePointX').value - xPos;
		var rotY = ModchartUtil.getCartesianCoords3D(90, subValues.get('y').value, yPos - subValues.get('rotatePointY').value);
		noteData.y += rotY.y + subValues.get('rotatePointY').value - yPos;
		noteData.z += rotX.z + rotY.z;

		noteData.angleY += -subValues.get('x').value;
		noteData.angleX += -subValues.get('y').value;
	}

	override function incomingAngleMath(lane:Int, curPos:Float, pf:Int)
	{
		var multiply:Bool = subValues.get('y').value % 180 != 0; // so it calculates the stuff ONLY if angle its not 180/360 base
		var valueToUse:Float = multiply ? 90 : 0;
		return [valueToUse, subValues.get('y')
			.value]; // ik this might cause problems at some point with some modifiers but eh, there is nothing i could do about it- (i can LMAO)
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}

	override function reset()
	{
		super.reset();
		currentValue = 1.0;
	}
}

// class LongHoldsModifier extends Modifier //unused
// {
//     override function setupSubValues()
//     {
//         baseValue = 1.0;
//         currentValue = 1.0;
//     }
//     override function curPosMath(lane:Int, curPos:Float, pf:Int)
//     {
//         if (notes.members[lane].isSustainNote)
//             return curPos * currentValue;
//         else
//             return curPos;
//         //if else then nothing??
//     }
// }
/*
	class MegaMindModifier extend Modifier
	trace("
	......................................................................................................................................................                                                                                             
	......................................................................................................................................................                                                                                          
	......................................................................................................................................................
	......................................................................................................................................................
	......................................................................................................................................................
	:::::.................................................................................................................................................
	::::::................................................................................................................................................
	::::::::::.......................................::::::...............................................................................................
	:::::::::::::................................:::::::..................................................................................................
	::::::::::::::::...........................:::::......................................................................................................
	::::::::::::::::::......................:::::..::::::...........................................::....................................................
	:::::::::::::::::::::................::::::::::::::::.............................................::..................................................
	:::::::::::::::::::::::::..........::::::::::::::::.............................................::::::................................................
	:::::::::::::::::::::::::::::::::::::::::::::::::::............................................:::::::::..............................................
	:::::::::::::::::::::::::::::::::::::::::::::::::::::..........................................::::::::::.............................................
	:::::::::::::::::::::::::::::::::::::::::::::::::::::::.................................:::...::::::::::::............................................
	::::::::::::::::::::::::::::::::::::::::::::::::::::::::................................:::::::::::::::::::...........................................
	:::::::::::::::::::::::::::::::::::::-::::::::::::::::::::..............................::::::::::::::::::::..........................................
	:::::::::::::::::::::::::::::::::::::--:::::::::::::::::::::::::........................:::::::::::::::::::::.........................................
	::::::::::::::::::::::::::::::::::::----::::::::::::::::::::::::::...................:::::::::::::::::::::::::........................................
	:::::::::::::::::::::::::::::::::::-------:::::::::::::::::::::::::::................:::::::::::::::::::::::::........................................
	::::::::::::::::::::::::::::::::::--------:::::::::::::::::::::::::::::::............:::::::::::::::::-::::::::.......................................
	::::::::::::::::::::::::::::::::::--------::::::::::::::::::::::::::::::::::::::::...:::::::::::::::::--:::::-::......................................
	:::::::::::::::::::::::::::::::::---------::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::---:::::-:.................::::::::.............
	:::::::::::::::::::::::::::::::::----------:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::----::::-::::::...........::::::::::::::::::::::
	:::::::::::::::::::::::::::::::::----------:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::------::=:::::::::::::::::::::::::::::::::::::::
	:::::::::::::::::::::::::::::::::-----------:::::::::::::::::::::::::::::::::::::::::::::::::::::::::-------:-=:::::::::::::::::::::::::::::::::::::::
	::::::::::::::::::::::::::::::::::-------=---::::::::::::::::::::::::::::::::::::::::::::::::::::::::-------:-=:::::::::::::::::::::::::::::::::::::::
	::::::::::::::::::::::::::::::::::------------::::::::::::::::::::::::::::::::::::::::::::::::::::::--------:-=:::::::::::::::::::::::::::::::::::::::
	::::::::::::::::::::::::::::::::::------===----:::::::::::::::::::::::::::::::::::::::::::::::::::::-==------==:::::::::::::::::::::::::::::::::::::::
	::::::::::::::::::::::::::::::::::---=---==------:::::::::::::::::::::::::::::::::::::::::::::::::::-==------+=:::::::::::::::::::::::::::::::::::::::
	:::::::::::::::::::::::::::::::::----==---=-------:::::::::::::::::::::::::::::::::::::::::::::::::--==------*-:::::::::::::::::::::::::::::::::::::::
	:::::::::::::::::::::::::::::::::-----==--=---------::::::::::::::::::::::::::::::::::::::::::::::--===-----=+::::::::::::::::::::::::::::::::::::::::
	:::::::::::::::::::::::::::::::::-----=====-----------:::::::::::::::::::::::::::::::::::::::-:::--=====---=++::::::::::::::::::::::::::::::::::::::::
	::::::::::::::::::::::::::--------==--=======----------:::::::::::::::::::::::::::::::::::--------=+====---=*-::::::::::::::::::::::::::::::::::::::::
	:::::::::::::::-:::---------==++**#*--====+===-----=----:::::::::::::::::::::::::::::::::---------=+====--=++--=--::::::::::::::::::::::::::::::::::::
	:::::::::::-----------===++++++++*##======+++====--------:::::::::::::::::::::::::::::::----------=++===-=+#**+==----==--:::::::::::::::::::::::::::::
	::::::--------========++++**++**###%%===+++++====--------::::::::::::::::::::::::::::::----====--===+====+#****+==---=--===---::::::::::::::::::::::::
	--------============++++++++*+***###%*==+++++======---------::::::::::::::::::::::::::-----======++=====+*#****+======-==--------:::::::::::::::::::::
	======-==-=========+++++++++****####%@*==++++===+=====----------::::::::::::::::::::::--============+==++%#****+===--==--------------:::::::::::::::::
	====================++++++++*##*##%#%@%===+++++++=======--------:::::::::::::::::::::---=========++++=+*%#####*+=------------------===---:::::::::::::
	=====================++++++****####+*%@*-=++++++==-----===-------::--:::::::------:-:-----=====+++*+=+*%@##%#*++==-------------------=------::::::::::
	======================++++******##====+#+=++++=++=====---------------------------------=++****==++++=+%@%*+##*++====-------------------=====----::::::
	===++================++++***#*#**++**#*+*+=*++*#%%%#####*++==----------------------=++*#%%%##%%#*+*+=*@#+=-+***++====-=-----------------========---:::
	====++================+++****#***==++#%%*+++++**+===+*#%%%%%%#*+=-=---------=++***%%%%##*+====++++*++++***=-***+++=====---==-------------===========--
	========================++++*****+===+*##++====----+*##***#%%%%%##*+=-----==*%@@%%%#%#**#%##*+====+*+=***+*=++++++======---=-----=====----====+==++++=
	=========================++++****#==--=++++===-----=+***+==+++=*#*#*=--::-=+*###*==-==++*#**+=--==+*==++===+=+++++=====--=--=------===================
	---======================++++++***#=----==*+==-------===--==++++++**+-:::-=+*+=--===-=====+=----==*#===---=--+++=+===========----------===============
	-------===================+*+++***##*===*%#*++=------------------=++=-::-==*++--::---------::--===**===-----=++++=============-==---==================
	--------==================++*+++****##+==*#**+++=---------------==++=----=++++=-::::::::::::---==+%*=+---==**+++==============-=======================
	----------======++======+++++**+****#%%+==+%#*++++=-------------=++++=---=*+++==--------:-----==+#%*#*===*###*++====================-------====++=====
	-------=====-=====+++====+*+++*+****##%%#+*@@%#*+++==----------==++++=---+**++==-------------=+*#%*=--=*##****+=++===============----------------=+**+
	-----------==+++===++++===++**+++****##%#%@@@%%%#*+++=---------=++**+=-==+***++===---------==+*%%%==**##******++=======-======-----------------------+
	----------------=++++++++++=++++++***#####%@%%%%%#*++++====--==++***+=-==+***++====-------=+*#%%#%#*####***#*++=============--------------------------
	--------------------==++++++==++*****####%%%###%%##*+++++=======+*##+----++**#+====-----==+*###**%%###***##*+++===========----------------------------
	=====------------------=++++++++*##**###%#%%##*####**++++=======*+**+===+**+++*==--=====++*###*+*%%%#*##***++++========-------------------------------
	==-----------------------=+++++++**#*##%%#%@#****##***+++====---+**#****####**+==-=====+***##+++*%%#*#%#*+++++===+===---------------------------------
	=------=========-----------=++++++**###%##%@%#*+++*****++++====--===--=++=============++*###+==+*%%#**#***++++=+==+=----------------------------------
	===================---------=+++++++*#%##%%@%#**+==+*#**++++========--=======++=======+*##*++==+*%%###**#**++++=++=-----------------------------------
	========================-----=+*++***##%#%@@%***+===+###*++++=======++==+++++++===+===*###*++==+*%%%%###****+++*+=------------------------------------
	===============================+#*+**#%%@@@%*%**++==+*%%*++++++++*#######%#******+*++=*%#*+++=+*#@%%%%#****++**+=-------------------------------------
	=================================#*+**%@@@@%*%%**+===+#%#*+++*#%%%%%%%%%%%%##%#%%@%*==*%#*++++*##@%%%%#***++**====------------------------------------
	==================================#**#%%@@@%+*#%#+++==*##**++++**+++===+++++**##**==-+#%*+=+**%%#@%###*#**+**========--------------------------------=
	==================================+#*##%%@@%+*##%%*++++###*++++++*****##*****++++++=+###+++*#%#*%@%%###*+***==========----======---------------------=
	===================================*##%#%%@#+****#%#**#####*+++++++==*#%@*=+++++++++*##*+*#%%#**%@%#%##*+*#+==========================================
	====================================###%%@@#+*****#%@###%%#*++++++===+@@@+======++++#####%%#****%@%%##***#*===========================================
	====================================*%#%%@@#*********%@%%%%*++++++===+@@@+=====+++*#%%%%%#******%@%%#***#*+===========================================
	====================================+%##%@@#**********#@%#%#**++++===*@@@+=====++*#%@@@#+******#%@%%***#%*+===========================================
	=====================================##*%@@#************%@%##***++===*@@@*+++++***%@@%*+++*****##@###**#%*+===========================================
	====================================+*#**%@%*##**+++**+++*@%##**+++++#@@@%+++***#%@@#*+++++****##%%%##*#%*+===========================================
	=============================++++++=+##*#*#@**#***+***+++++#%##****#%@@@@@%####%%@%***++++++***##@@####*#%+===========================================
	++++++++++++++++++++++=======+#++++++%***##%#*****+****++++++*#%%%%@@@@@@@@@@%%%%*****++++++***#%@%***%**%#+==========================================
	++++++++++++++++++++++++++++++#%#*+*#%###***%***********++++++++*#######***##********+++++++****@@#***#***#%*========++===============================
	+++++++++++++++++++++++++++++++####**#####**#%**********+++++++++=========++++******++++++++++*#%#***##***+#%#++=++++#*++++++++++++++++++===+++++++===
	+++++++++++++++++++*+++++++*#*##********###**#%****+***+++++++++++++++++++*********+++++++++++#@#****##*++++*****++++##+++++++++#*++++++++++++++++++++
	+++++*#++++++++++++##*+++**#%#***+++*%***##***#%#******++++++++++++++++************++++++++++*%#*****#****+++****##**%%++++++++**#+++++#*+++++++++++++
	++++++##*++++++#*++*%%#%#****#****++*@@#*******#%#******++++++++++++++*************++++++++**%#*****#**************#####+++++++#*#++++#%#+++++++++++++
	+++++++##**++++*****#%##*************%%%*****#***%#*******++++++++++++++**********+++++++**#%#*****#****************##****++++*##%*+*%%#%*++++++++++++
	+++++++*##**+**++++******************%*%#*********%#********++++++++++++***#*****++++++***#%#*********************##***###******##**+++****+++++++++++
	++++++++*%#*#*++++**#****+************##**********#%#*********++++++*****##*************##%#********************##****#%*#*****###****+++**+++++++++++
	+++++++++*#+**+++++*%*********#********************#%%*********+++********************##%%#*********************##****#%*#****#%##***++++#**++++++++++
	+++++++++++++***++++*%********#**********#*****##***#%%#*****************************##%%**********************###****####*****##****+++#%**++++++++++
	++++++++++++++#**++++***++****#%###*****##***********#%%#***************************####****#******************%%*#***#********#%#++++++*##*++++++++++
	++++++++++++++###%#+++++++++************%#************#%%#*************************#%%#**###*******************%%##**##********%#%*+++++++++++++++++++
	*+++++++++++++****++++*#*+++*************%###******###*##%#****#*******************#%#*####**************************%##***++*#@#%*+++++++++++++++++++
	****++++++++++++++++++*#***************************#######%%#*********************#%#*#############******************%###*+++++##*++++++++++++++++++++
	***********+++++++++++*##%***************************###%%%%%#*******************%@##%#############******************##**+++++++++++++********++++++++
	*****************************************###**##*****#####%@%%##**********#####%@@##%#*##########*****************************************************
	*****************************************############*####%%@%@%#***######%%%%%@@%%##*###############*************************************************
	*******************************************################%@@@@%####*##*##%@#%@%%##**####%###########************************************************
	************************************************#############%%%@%############%%%#####################******************#*****************************
	***************************************************########**###%%#########**##%###**#########*********************#**##******************************
	**************************************************************#############################*******************#*##*#%%###*****************************
	*********************************************************###*******####################*********************#%#*#%%%@#********************************
	****************************************************#####*****##****##################**********************######%#****########**********************
	************************************************************##########################*************************#####**********************************
	*************************************************************################*************************************************************************
	******************************************************************************************************************************************************
	")
 */
