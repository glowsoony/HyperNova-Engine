package modcharting.modifiers;

import modcharting.*;
import modcharting.Modifier.ModifierSubValue;
import modcharting.Modifier;
import modcharting.PlayfieldRenderer.StrumNoteType;

// CHANGE LOG (the changes to modifiers)
// [REWORK] = totally overhaul of a modifier
// [UPDATE] = changed something on the modifier
// [RENAME] = rename of a modifier
// [REMOVAL] = a removed modifier
// [NEW] = a new modifier
// [EXTRA] = has nothing to do with modifiers but MT's enviroment.
// HERE CHANGE LIST

/*
	[EXTRA] HourGlass && Digital Improvements:
	-   Added a helper instead of copy and pasted code for the modifiers.

	[UPDATE] HourGlassScale && Digital: (X,Y Included)
	-   Now scale mods can stack (before, its behavior was like we have 2 mods but one its 0 then no mods other than that one works, now it's additive.)
 */
class HourGlassModifer extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('start', 420.0);
		subValues.set('end', 135.0);
		subValues.set('offset', 0.0);
	}

	public function hourGlassMath():Float
	{
		var scrollSwitch = (instance != null && ModchartUtil.getDownscroll(instance)) ? -1 : 1;
		var pos = (Conductor.songPosition * 0.001) * scrollSwitch;

		// Copy of Sudden math
		var a:Float = FlxMath.remapToRange(pos, subValuse.get("start") + subValues.get("offset"), subValues.get("end") + subValuse.get("offset"), 1, 0);
		a = FlxMath.bound(a, 0, 1); // clamp

		var b:Float = 1 - a;
		var c:Float = (FlxMath.fastCos(b * Math.PI) / 2) + 0.5;

		return c;
	}
}

class HourGlassXModifier extends HourGlassModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += NoteMovement.arrowSizes[lane] * hourGlassMath() * (lane - 1.5) * -2 * currentValue;
	}
}

class HourGlassYModifier extends HourGlassModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += NoteMovement.arrowSizes[lane] * hourGlassMath() * (lane - 1.5) * -2 * currentValue;
	}
}

class HourGlassZModifier extends HourGlassModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += NoteMovement.arrowSizes[lane] * hourGlassMath() * (lane - 1.5) * -2 * currentValue;
	}
}

class HourGlassAngleModifier extends HourGlassModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleZ += hourGlassMath() * (currentValue * -1);
	}
}

class HourGlassAngleXModifier extends HourGlassModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleX += hourGlassMath() * (currentValue * -1);
	}
}

class HourGlassAngleYModifier extends HourGlassModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleY += hourGlassMath() * (currentValue * -1);
	}
}

class HourGlassScaleModifier extends HourGlassModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((hourGlassMath() * (currentValue * -1)) - 1);
		noteData.scaleY += ((hourGlassMath() * (currentValue * -1)) - 1);
	}
}

class HourGlassScaleXModifier extends HourGlassModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((hourGlassMath() * (currentValue * -1)) - 1);
	}
}

class HourGlassScaleYModifier extends HourGlassModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY += ((hourGlassMath() * (currentValue * -1)) - 1);
	}
}

class HourGlassSkewModifier extends HourGlassModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += hourGlassMath() * (currentValue * -1);
		noteData.skewY += hourGlassMath() * (currentValue * -1);
	}
}

class HourGlassSkewXModifier extends HourGlassModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += hourGlassMath() * (currentValue * -1);
	}
}

class HourGlassSkewYModifier extends HourGlassModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += hourGlassMath() * (currentValue * -1);
	}
}

class DigitalModifer extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('mult', 1.0);
		subValues.set('steps', 4.0);
	}

	public function digitalMath(curPos:Float):Float
	{
		// Copy of Sudden math
		var s = subValues.get('steps') / 2;

		var funny:Float = FlxMath.fastSin((curPos * 0.45) * Math.PI * subValues.get("mult") / 250) * s;
		// trace("1: " + funny);
		funny = Math.floor(funny);
		// funny = Math.round(funny); //Why does this not work? no idea :(
		// trace("2: " + funny);
		// funny = funny;
		funny /= s;
		// trace("3: " + funny);
		return funny;
	}
}

class DigitalXModifier extends DigitalModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += (digitalMath(curPos) * currentValue) * (NoteMovement.arrowSize / 2.0);
	}
}

class DigitalYModifier extends DigitalModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += (digitalMath(curPos) * currentValue) * (NoteMovement.arrowSize / 2.0);
	}
}

class DigitalZModifier extends DigitalModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += (digitalMath(curPos) * currentValue) * (NoteMovement.arrowSize / 2.0);
	}
}

class DigitalAngleModifier extends DigitalModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleZ += digitalMath(curPos) * currentValue;
	}
}

class DigitalAngleXModifier extends DigitalModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleX += digitalMath(curPos) * currentValue;
	}
}

class DigitalAngleYModifier extends DigitalModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleY += digitalMath(curPos) * currentValue;
	}
}

class DigitalScaleModifier extends DigitalModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((digitalMath(curPos) * currentValue) - 1);
		noteData.scaleY += ((digitalMath(curPos) * currentValue) - 1);
	}
}

class DigitalScaleXModifier extends DigitalModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((digitalMath(curPos) * currentValue) - 1);
	}
}

class DigitalScaleYModifier extends DigitalModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY += ((digitalMath(curPos) * currentValue) - 1);
	}
}

class DigitalSkewModifier extends DigitalModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += (digitalMath(curPos) * currentValue);
		noteData.skewY += (digitalMath(curPos) * currentValue);
	}
}

class DigitalSkewXModifier extends DigitalModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += (digitalMath(curPos) * currentValue);
	}
}

class DigitalSkewYModifier extends DigitalModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += (digitalMath(curPos) * currentValue);
	}
}

class InvertModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += ModifierMath.Invert(lane) * currentValue;
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class FlipModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += NoteMovement.arrowSizes[lane] * ModifierMath.Flip(lane) * currentValue;
		noteData.x -= NoteMovement.arrowSizes[lane] * currentValue;
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class InvertSineModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += ModifierMath.InvertSine(lane, curPos, pf, currentValue); // silly ah math
	}
}
