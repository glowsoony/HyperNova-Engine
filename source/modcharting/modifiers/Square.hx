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
	[EXTRA] Square Improvements:
	-   Added a halper instead of copy and pasted code for the modifiers.
	-	Chanegd the math somewhat to hazard's (math it visually the same, not direct behavior changes)

	[UPDATE] Square: (X,Y Included)
	-   Now scale mods can stack (before, its behavior was like we have 2 mods but one its 0 then no mods other than that one works, now it's additive.)
 */
class SquareModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('yoffset', new ModifierSubValue(0.0));
		subValues.set('xoffset', new ModifierSubValue(0.0));
	}

	public function squareMath(lane:Int, curPos:Float):Float
	{
		var mult:Float = (subValues.get('mult').value / (NoteMovement.arrowSizes[lane] * 2));
		var timeOffset:Float = subValues.get('yoffset').value;
		var xOffset:Float = subValues.get('xoffset').value;
		var xVal:Float = FlxMath.fastSin(((curPos * 0.45) + timeOffset) * Math.PI * mult);
		xVal = Math.floor(xVal) + 0.5 + xOffset;
		return xVal;
	}
}

class SquareXModifier extends SquareModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += squareMath(lane, curPos) * currentValue;
	}
}

class SquareYModifier extends SquareModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += squareMath(lane, curPos) * currentValue;
	}
}

class SquareZModifier extends SquareModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += squareMath(lane, curPos) * currentValue;
	}
}

class SquareAngleModifier extends SquareModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleZ += squareMath(lane, curPos) * currentValue;
	}
}

class SquareAngleXModifier extends SquareModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleX += squareMath(lane, curPos) * currentValue;
	}
}

class SquareAngleYModifier extends SquareModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleY += squareMath(lane, curPos) * currentValue;
	}
}

class SquareScaleModifier extends SquareModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((squareMath(lane, curPos) * (currentValue * 0.01)) - 1);
		noteData.scaleY += ((squareMath(lane, curPos) * (currentValue * 0.01)) - 1);
	}
}

class SquareScaleXModifier extends SquareModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((squareMath(lane, curPos) * (currentValue * 0.01)) - 1);
	}
}

class SquareScaleYModifier extends SquareModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY += ((squareMath(lane, curPos) * (currentValue * 0.01)) - 1);
	}
}

class SquareSkewModifier extends SquareModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += squareMath(lane, curPos) * currentValue;
		noteData.skewY += squareMath(lane, curPos) * currentValue;
	}
}

class SquareSkewXModifier extends SquareModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += squareMath(lane, curPos) * currentValue;
	}
}

class SquareSkewYModifier extends SquareModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += squareMath(lane, curPos) * currentValue;
	}
}
