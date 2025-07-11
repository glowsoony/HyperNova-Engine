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
	[EXTRA] SawTooth Improvements:
	-   Added a halper instead of copy and pasted code for the modifiers.
	-   Changed the math to be hazard's

	[UPDATE] SawTootahScale: (X,Y Included)
	-   Now scale mods can stack (before, its behavior was like we have 2 mods but one its 0 then no mods other than that one works, now it's additive.)
 */
class SawToothModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
	}

	// Sawtooth math
	public function sawToothMath(lane:Int, curPos:Float)
	{
		return Modifier.mod(curPos * 0.45, NoteMovement.arrowSizes[lane] * subValues.get('mult'));
	}
}

class SawToothXModifier extends SawToothModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += sawToothMath(lane, curPos) * currentValue;
	}
}

class SawToothYModifier extends SawToothModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += sawToothMath(lane, curPos) * currentValue;
	}
}

class SawToothZModifier extends SawToothModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += sawToothMath(lane, curPos) * currentValue;
	}
}

class SawToothAngleModifier extends SawToothModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angle += sawToothMath(lane, curPos) * currentValue;
	}
}

class SawToothScaleModifier extends SawToothModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += (((sawToothMath(lane, curPos)) * (currentValue * 0.01)) - 1);
		noteData.scaleY += (((sawToothMath(lane, curPos)) * (currentValue * 0.01)) - 1);
	}
}

class SawToothScaleXModifier extends SawToothModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += (((sawToothMath(lane, curPos)) * (currentValue * 0.01)) - 1);
	}
}

class SawToothScaleYModifier extends SawToothModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY += (((sawToothMath(lane, curPos)) * (currentValue * 0.01)) - 1);
	}
}

class SawToothSkewModifier extends SawToothModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += sawToothMath(lane, curPos) * currentValue;
		noteData.skewY += sawToothMath(lane, curPos) * currentValue;
	}
}

class SawToothSkewXModifier extends SawToothModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += sawToothMath(lane, curPos) * currentValue;
	}
}

class SawToothSkewYModifier extends SawToothModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += sawToothMath(lane, curPos) * currentValue;
	}
}
