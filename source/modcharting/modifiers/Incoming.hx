package modcharting.modifiers;

import flixel.FlxG;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import modcharting.*;
import modcharting.Modifier.ModifierSubValue;
import modcharting.Modifier;
import modcharting.PlayfieldRenderer.StrumNoteType;
import objects.Note;

// CHANGE LOG (the changes to modifiers)
// [REWORK] = totally overhaul of a modifier
// [UPDATE] = changed something on the modifier
// [RENAME] = rename of a modifier
// [REMOVAL] = a removed modifier
// [NEW] = a new modifier
// [EXTRA] = has nothing to do with modifiers but MT's enviroment.
// HERE CHANGE LIST

/*
	[NEW] LinearModifier: (Includes X,Y,Z,Scale,Skew variants)
	-   New modifier to apply a linear incoming change on the scroll.
	-   Angle is not included as Dizzy, Twirl and Roll does same behaviour, making LinearAngleModifier useless.

	[NEW] CircModifier: (Includes X,Y,Z,Angle,Scale,Skew variants)
	-   New modifier similar to LinearModifier but with a circular incoming change on the scroll.
 */
class LinearXModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += curPos * currentValue; // don't mind me i just figured it out
	}
}

class LinearYModifier extends Modifier // Similar to speed but different, yk, weird Y behaviour
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var ud = false;
		if (instance != null)
			if (ModchartUtil.getDownscroll(instance))
				ud = true;
		noteData.y += (curPos * currentValue) * (ud ? -1 : 1);
	}
}

class LinearZModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += curPos * currentValue;
	}
}

class LinearScaleModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((curPos * currentValue) - 1);
		noteData.scaleY += ((curPos * currentValue) - 1);
	}
}

class LinearScaleXModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((curPos * currentValue) - 1);
	}
}

class LinearScaleYModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY += ((curPos * currentValue) - 1);
	}
}

class LinearSkewModifier extends Modifier // absurdely similar to angle xdxd
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += curPos * currentValue;
		noteData.skewY += curPos * currentValue;
	}
}

class LinearSkewXModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += curPos * currentValue;
	}
}

class LinearSkewYModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += curPos * currentValue;
	}
}

class CircXModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var ud = false;
		if (instance != null)
			if (ModchartUtil.getDownscroll(instance))
				ud = true;

		var curPos2 = Conductor.songPosition * 0.001 * (ud ? -1 : 1);
		noteData.x += curPos2 * curPos2 * currentValue * -0.001; // No idea why math is like that, hazard is the one who made it -Ed
	}
}

class CircYModifier extends Modifier // Similar to speed but different, yk, weird Y behaviour
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var ud = false;
		if (instance != null)
			if (ModchartUtil.getDownscroll(instance))
				ud = true;

		var curPos2 = Conductor.songPosition * 0.001 * (ud ? -1 : 1);

		noteData.y += curPos2 * curPos2 * (currentValue * (ud ? -1 : 1)) * -0.001;
	}
}

class CircZModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var ud = false;
		if (instance != null)
			if (ModchartUtil.getDownscroll(instance))
				ud = true;

		var curPos2 = Conductor.songPosition * 0.001 * (ud ? -1 : 1);
		noteData.z += curPos2 * curPos2 * currentValue * -0.001;
	}
}

class CircAngleModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var ud = false;
		if (instance != null)
			if (ModchartUtil.getDownscroll(instance))
				ud = true;

		var curPos2 = Conductor.songPosition * 0.001 * (ud ? -1 : 1);
		noteData.angleZ += curPos2 * curPos2 * currentValue * -0.001;
	}
}

class CircAngleXModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var ud = false;
		if (instance != null)
			if (ModchartUtil.getDownscroll(instance))
				ud = true;

		var curPos2 = Conductor.songPosition * 0.001 * (ud ? -1 : 1);
		noteData.angleX += curPos2 * curPos2 * currentValue * -0.001;
	}
}

class CircAngleYModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var ud = false;
		if (instance != null)
			if (ModchartUtil.getDownscroll(instance))
				ud = true;

		var curPos2 = Conductor.songPosition * 0.001 * (ud ? -1 : 1);
		noteData.angleY += curPos2 * curPos2 * currentValue * -0.001;
	}
}

class CircScaleModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var ud = false;
		if (instance != null)
			if (ModchartUtil.getDownscroll(instance))
				ud = true;

		var curPos2 = Conductor.songPosition * 0.001 * (ud ? -1 : 1);
		noteData.scaleX += curPos2 * curPos2 * currentValue * -0.001;
		noteData.scaleY += curPos2 * curPos2 * currentValue * -0.001;
	}
}

class CircScaleXModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var ud = false;
		if (instance != null)
			if (ModchartUtil.getDownscroll(instance))
				ud = true;

		var curPos2 = Conductor.songPosition * 0.001 * (ud ? -1 : 1);
		noteData.scaleX += curPos2 * curPos2 * currentValue * -0.001;
	}
}

class CircScaleYModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var ud = false;
		if (instance != null)
			if (ModchartUtil.getDownscroll(instance))
				ud = true;

		var curPos2 = Conductor.songPosition * 0.001 * (ud ? -1 : 1);
		noteData.scaleY += curPos2 * curPos2 * currentValue * -0.001;
	}
}

class CircSkewModifier extends Modifier // absurdely similar to angle xdxd
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var ud = false;
		if (instance != null)
			if (ModchartUtil.getDownscroll(instance))
				ud = true;

		var curPos2 = Conductor.songPosition * 0.001 * (ud ? -1 : 1);
		noteData.skewX += curPos2 * curPos2 * currentValue * -0.001;
		noteData.skewY += curPos2 * curPos2 * currentValue * -0.001;
	}
}

class CircSkewXModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var ud = false;
		if (instance != null)
			if (ModchartUtil.getDownscroll(instance))
				ud = true;

		var curPos2 = Conductor.songPosition * 0.001 * (ud ? -1 : 1);
		noteData.scaleX += curPos2 * curPos2 * currentValue * -0.001;
	}
}

class CircSkewYModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var ud = false;
		if (instance != null)
			if (ModchartUtil.getDownscroll(instance))
				ud = true;

		var curPos2 = Conductor.songPosition * 0.001 * (ud ? -1 : 1);
		noteData.scaleY += curPos2 * curPos2 * currentValue * -0.001;
	}
}

class IncomingAngleModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('x', new ModifierSubValue(0.0));
		subValues.set('y', new ModifierSubValue(0.0));
		currentValue = 1.0;
	}

	override function incomingAngleMath(lane:Int, curPos:Float, pf:Int)
	{
		return [subValues.get('x').value, subValues.get('y').value];
	}

	override function reset()
	{
		super.reset();
		currentValue = 1.0; // the code that stop the mod from running gets confused when it resets in the editor i guess??
	}
}
