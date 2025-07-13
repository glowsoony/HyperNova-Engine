package modcharting.modifiers;

import modcharting.*;
import modcharting.Modifier.ModifierSubValue;
import modcharting.Modifier;

// CHANGE LOG (the changes to modifiers)
// [REWORK] = totally overhaul of a modifier
// [UPDATE] = changed something on the modifier
// [RENAME] = rename of a modifier
// [REMOVAL] = a removed modifier
// [NEW] = a new modifier
// [EXTRA] = has nothing to do with modifiers but MT's enviroment.
// HERE CHANGE LIST

/*
	[EXTRA] HourGlass Improvements:
	-   Added a halper instead of copy and pasted code for the modifiers.

	[UPDATE] HourGlassScale: (X,Y Included)
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
