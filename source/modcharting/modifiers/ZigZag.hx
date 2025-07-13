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
	[EXTRA] ZigZag Improvements:
	-   Added a halper instead of copy and pasted code for the modifiers.

	[UPDATE] ZigZagScale: (X,Y Included)
	-   Now scale mods can stack (before, its behavior was like we have 2 mods but one its 0 then no mods other than that one works, now it's additive.)
 */
class ZigZagModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
	}

	function zigZagMath(lane:Int, curPos:Float)
	{
		var mult:Float = NoteMovement.arrowSizes[lane] * subValues.get('mult');
		var mm:Float = mult * 2;
		var p:Float = curPos * 0.45;
		if (p < 0)
		{
			p *= -1;
			p += mult;
		}

		var ppp:Float = p + (mult / 2);
		var funny:Float = (ppp + mult) % mm;
		var result:Float = funny - mult;

		if (ppp % mm * 2 >= mm)
			result *= -1;
		result -= mult / 2;
		return result;
	}
}

class ZigZagXModifier extends ZigZagModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += zigZagMath(lane, curPos) * currentValue;
	}
}

class ZigZagYModifier extends ZigZagModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += zigZagMath(lane, curPos) * currentValue;
	}
}

class ZigZagZModifier extends ZigZagModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += zigZagMath(lane, curPos) * currentValue;
	}
}

class ZigZagAngleModifier extends ZigZagModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleZ += zigZagMath(lane, curPos) * currentValue;
	}
}

class ZigZagAngleXModifier extends ZigZagModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleX += zigZagMath(lane, curPos) * currentValue;
	}
}

class ZigZagAngleYModifier extends ZigZagModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleY += zigZagMath(lane, curPos) * currentValue;
	}
}

class ZigZagScaleModifier extends ZigZagModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((zigZagMath(lane, curPos) * (currentValue * 0.01)) - 1);
		noteData.scaleY += ((zigZagMath(lane, curPos) * (currentValue * 0.01)) - 1);
	}
}

class ZigZagScaleXModifier extends ZigZagModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((zigZagMath(lane, curPos) * (currentValue * 0.01)) - 1);
	}
}

class ZigZagScaleYModifier extends ZigZagModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY += ((zigZagMath(lane, curPos) * (currentValue * 0.01)) - 1);
	}
}

class ZigZagSkewModifier extends ZigZagModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += zigZagMath(lane, curPos) * currentValue;
		noteData.skewY += zigZagMath(lane, curPos) * currentValue;
	}
}

class ZigZagSkewXModifier extends ZigZagModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += zigZagMath(lane, curPos) * currentValue;
	}
}

class ZigZagSkewYModifier extends ZigZagModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += zigZagMath(lane, curPos) * currentValue;
	}
}
