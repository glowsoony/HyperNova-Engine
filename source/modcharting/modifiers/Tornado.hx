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
	[EXTRA] Tornado Improvements:
	-   Added a halper instead of copy and pasted code for the modifiers.

	[UPDATE] TornadoScale && TanTornadoScale: (X,Y Included)
	-   Now scale mods can stack (before, its behavior was like we have 2 mods but one its 0 then no mods other than that one works, now it's additive.)
 */
class TornadoModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	// Tornado math
	public function tornadoMath(lane:Int, curPos:Float)
	{
		// thank you 4mbr0s3 & andromeda for the modifier lol -- LETS GOOOO FINALLY I FIGURED IT OUT
		var playerColumn = lane % NoteMovement.keyCount;
		var columnPhaseShift = playerColumn * Math.PI / 3;
		var phaseShift = (curPos / 135) * subValues.get('speed').value * 0.2;
		var returnReceptorToZeroOffsetX = (-Math.cos(-columnPhaseShift) + 1) / 2 * Note.swagWidth * 3;
		var offsetX = (-Math.cos((phaseShift - columnPhaseShift)) + 1) / 2 * Note.swagWidth * 3 - returnReceptorToZeroOffsetX;

		return offsetX;
	}

	public function tornadoTanMath(lane:Int, curPos:Float)
	{
		// thank you 4mbr0s3 & andromeda for the modifier lol -- LETS GOOOO FINALLY I FIGURED IT OUT
		var playerColumn = lane % NoteMovement.keyCount;
		var columnPhaseShift = playerColumn * Math.PI / 3;
		var phaseShift = (curPos / 135) * subValues.get('speed').value * 0.2;
		var returnReceptorToZeroOffsetX = (-Math.tan(-columnPhaseShift) + 1) / 2 * Note.swagWidth * 3;
		var offsetX = (-Math.tan((phaseShift - columnPhaseShift)) + 1) / 2 * Note.swagWidth * 3 - returnReceptorToZeroOffsetX;

		return offsetX;
	}
}

class TornadoXModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += tornadoMath(lane, curPos) * currentValue;
	}
}

class TornadoYModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += tornadoMath(lane, curPos) * currentValue;
	}
}

class TornadoZModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += tornadoMath(lane, curPos) * currentValue;
	}
}

class TornadoAngleModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleZ += tornadoMath(lane, curPos) * currentValue;
	}
}

class TornadoScaleModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += (((currentValue * 0.01) * tornadoMath(lane, curPos)) - 1);
		noteData.scaleY += (((currentValue * 0.01) * tornadoMath(lane, curPos)) - 1);
	}
}

class TornadoScaleXModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += (((currentValue * 0.01) * tornadoMath(lane, curPos)) - 1);
	}
}

class TornadoScaleYModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY += (((currentValue * 0.01) * tornadoMath(lane, curPos)) - 1);
	}
}

class TornadoSkewModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += tornadoMath(lane, curPos) * currentValue;
		noteData.skewY += tornadoMath(lane, curPos) * currentValue;
	}
}

class TornadoSkewXModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += tornadoMath(lane, curPos) * currentValue;
	}
}

class TornadoSkewYModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += tornadoMath(lane, curPos) * currentValue;
	}
}

class TanTornadoModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += tornadoTanMath(lane, curPos) * currentValue;
	}
}

class TanTornadoYModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += tornadoTanMath(lane, curPos) * currentValue;
	}
}

class TanTornadoZModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += tornadoTanMath(lane, curPos) * currentValue;
	}
}

class TanTornadoAngleModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleZ += tornadoTanMath(lane, curPos) * currentValue;
	}
}

class TanTornadoScaleModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += (((currentValue * 0.01) * tornadoTanMath(lane, curPos)) - 1);
		noteData.scaleY += (((currentValue * 0.01) * tornadoTanMath(lane, curPos)) - 1);
	}
}

class TanTornadoScaleXModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += (((currentValue * 0.01) * tornadoTanMath(lane, curPos)) - 1);
	}
}

class TanTornadoScaleYModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY += (((currentValue * 0.01) * tornadoTanMath(lane, curPos)) - 1)
	}
}

class TanTornadoSkewModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += tornadoTanMath(lane, curPos) * currentValue;
		noteData.skewY += tornadoTanMath(lane, curPos) * currentValue;
	}
}

class TanTornadoSkewXModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += tornadoTanMath(lane, curPos) * currentValue;
	}
}

class TanTornadoSkewYModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += tornadoTanMath(lane, curPos) * currentValue;
	}
}
