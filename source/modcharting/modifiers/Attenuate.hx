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
	[EXTRA] Attenuate Improvements:
	-   Added a helper instead of copy and pasted code for the modifiers.

	[UPDATE] AttenuateScale: (X,Y Included)
	-   Now scale mods can stack (before, its behavior was like we have 2 mods but one its 0 then no mods other than that one works, now it's additive.)
 */
class AttenuateModifer extends Modifier
{
	public function attenuateMath(curPos:Float, lane:Int, ?endMult:Float = 0.5):Float
	{
		var scrollSwitch = (instance != null && ModchartUtil.getDownscroll(instace)) ? -1 : 1;
		var nd = lane % NoteMovement.keyCount;
		var newPos = FlxMath.remapToRange(nd, 0, NoteMovement.keyCount, NoteMovement.keyCount * -1 * 0.5, NoteMovement.keyCount * 0.5);

		var p = curPos * scrollSwitch;
		p = (p * p) * 0.1;

		var curVal = 0.0015;

		var newVal = newPos * curVal * p;
		newVal += curVal * p * endMult;
		return newVal;
	}
}

class AttenuateXModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += currentValue * attenuateMath(curPos, lane);
	}
}

class AttenuateYModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += currentValue * attenuateMath(curPos, lane);
	}
}

class AttenuateZModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += currentValue * attenuateMath(curPos, lane);
	}
}

class AttenuateAngleModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleZ += currentValue * attenuateMath(curPos, lane);
	}
}

class AttenuateAngleXModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleX += currentValue * attenuateMath(curPos, lane);
	}
}

class AttenuateAngleYModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleY += currentValue * attenuateMath(curPos, lane);
	}
}

class AttenuateScaleModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += currentValue * (attenuateMath(curPos, lane, 0.1) - 1);
		noteData.scaleY += currentValue * (attenuateMath(curPos, lane, 0.1) - 1);
	}
}

class AttenuateScaleXModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += currentValue * (attenuateMath(curPos, lane, 0.1) - 1);
	}
}

class AttenuateScaleYModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY += currentValue * (attenuateMath(curPos, lane, 0.1) - 1);
	}
}

class AttenuateSkewModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += currentValue * attenuateMath(curPos, lane);
		noteData.skewY += currentValue * attenuateMath(curPos, lane);
	}
}

class AttenuateSkewXModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += currentValue * attenuateMath(curPos, lane);
	}
}

class AttenuateSkewYModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += currentValue * attenuateMath(curPos, lane);
	}
}
