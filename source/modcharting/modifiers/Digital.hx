package modcharting.modifiers;

import flixel.math.FlxMath;
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
	[EXTRA] Digital Improvements:
	-   Added a halper instead of copy and pasted code for the modifiers.

	[UPDATE] DigitalScale: (X,Y Included)
	-   Now scale mods can stack (before, its behavior was like we have 2 mods but one its 0 then no mods other than that one works, now it's additive.)
 */
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
