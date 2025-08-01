package modcharting.modifiers;

import modcharting.*;
import modcharting.Modifier.ModifierSubValue;
import modcharting.Modifier;
import modcharting.PlayfieldRenderer.StrumNoteType;
import lime.math.Vector2;

// EDWHAK SI VES ESTO ENTIENDE QUE NO SE SI FUNCIONA CORRECTAMENTE.
// CHANGE LOG (the changes to modifiers)
// [REWORK] = totally overhaul of a modifier
// [UPDATE] = changed something on the modifier
// [RENAME] = rename of a modifier
// [REMOVAL] = a removed modifier
// [NEW] = a new modifier
// [EXTRA] = has nothing to do with modifiers but MT's enviroment.
// HERE CHANGE LIST

/*
	[REWORK] Rotate:
	-   The math is now directly from WHAT IN THE FUNKIN!
	[EXTRA] Rotate Improvements:
	-   Added a helper instead of copy and pasted code for the modifiers.
 */

//PlayState.instance.strumLineNotes


class Rotate extends Modifier
{
	var pivotPoint:Vector2 = new Vector2(0, 0);
	var point:Vector2 = new Vector2(0, 0);

	function noteGetPivot(noteData:NotePositionData, lane:Int, type:String = "x")
	{
		switch (type)
		{
			case "x":
				return NoteMovement.defaultStrumX[lane];
			case "y":
				return (NoteMovement.defaultStrumY[lane] + (NoteMovement.arrowSizes[lane] / 2));
			case "z":
				return 0.0;
			default:
				return 0.0;
		}
	}

	function strumGetPivot(noteData:NotePositionData, lane:Int, type:String = "x")
	{
		switch (type)
		{
			case "x":
				return (NoteMovement.defaultStrumX[lane] + (NoteMovement.arrowSizes[lane] * 1.5)) + getSubMod("offset_x");
			case "y":
				return (FlxG.height / 2) - (NoteMovement.defaultHeight[lane] / 2) + getSubMod("offset_y");
			case "z":
				return 0.0 + getSubMod("offset_z");
			default:
				return 0.0;
		}
	}

	function noteRotatePivot(noteData:NotePositionData, lane:Int, type:String = "x", angle:Null<Float> = null)
	{
		if (angle == null) angle = currentValue;
		if (angle % 360 == 0) return;
		switch (type)
		{
			case "z":
				pivotPoint.x = noteGetPivot(noteData, lane, "x");
				pivotPoint.y = noteGetPivot(noteData, lane, "y");
				point.x = noteData.x;
				point.y = noteData.y;
				var output:Vector2 = ModchartUtil.rotateAround(pivotPoint, point, angle);
				noteData.x = output.x;
				noteData.y = output.y;
			case "y":
				pivotPoint.x = noteGetPivot(noteData, lane, "x");
				pivotPoint.y = noteGetPivot(noteData, lane, "z");
				point.x = noteData.x;
				point.y = noteData.z;
				var output:Vector2 = ModchartUtil.rotateAround(pivotPoint, point, angle);
				noteData.x = output.x;
				noteData.z = output.y;
			case "x":
				pivotPoint.x = noteGetPivot(noteData, lane, "z");
				pivotPoint.y = noteGetPivot(noteData, lane, "y");
				point.x = noteData.z;
				point.y = noteData.y;
				var output:Vector2 = ModchartUtil.rotateAround(pivotPoint, point, angle);
				noteData.z = output.x;
				noteData.y = output.y;
		}
	}

	function strumRotatePivot(noteData:NotePositionData, lane:Int, type:String = "x", angle:Null<Float> = null)
	{
		if (angle == null) angle = currentValue;
		if (angle % 360 == 0) return;
		switch (type)
		{
			case "z":
				pivotPoint.x = strumGetPivot(noteData, lane, "x");
				pivotPoint.y = strumGetPivot(noteData, lane, "y");
				point.x = noteData.x;
				point.y = noteData.y;
				var output:Vector2 = ModchartUtil.rotateAround(pivotPoint, point, angle);
				noteData.x = output.x;
				noteData.y = output.y;
			case "y":
				pivotPoint.x = strumGetPivot(noteData, lane, "x");
				pivotPoint.y = strumGetPivot(noteData, lane, "z");
				point.x = noteData.x;
				point.y = noteData.z;
				var output:Vector2 = ModchartUtil.rotateAround(pivotPoint, point, angle);
				noteData.x = output.x;
				noteData.z = output.y;
			case "x":
				pivotPoint.x = strumGetPivot(noteData, lane, "z");
				pivotPoint.y = strumGetPivot(noteData, lane, "y");
				point.x = noteData.z;
				point.y = noteData.y;
				var output:Vector2 = ModchartUtil.rotateAround(pivotPoint, point, angle);
				noteData.z = output.x;
				noteData.y = output.y;
		}
	}
}

class RotateXModifier extends Rotate
{
	override function setupSubValues()
	{
		setSubMod("offset_x", 1.0);
		setSubMod("offset_y", 1.0);
		setSubMod("offset_z", 0.0);
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteRotatePivot(noteData, lane, "x");
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		strumRotatePivot(noteData, lane, "x");
	}
}

class RotateYModifier extends Rotate
{
	override function setupSubValues()
	{
		setSubMod("offset_x", 1.0);
		setSubMod("offset_y", 1.0);
		setSubMod("offset_z", 0.0);
	}
	
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteRotatePivot(noteData, lane, "y");
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		strumRotatePivot(noteData, lane, "y");
	}
}

class RotateZModifier extends Rotate
{
	override function setupSubValues()
	{
		setSubMod("offset_x", 1.0);
		setSubMod("offset_y", 1.0);
		setSubMod("offset_z", 0.0);
	}
	
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteRotatePivot(noteData, lane, "z");
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		strumRotatePivot(noteData, lane, "z");
	}
}

class RotateNoteXModifier extends Rotate
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteRotatePivot(noteData, lane, "x");
	}
}

class RotateNoteYModifier extends Rotate
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteRotatePivot(noteData, lane, "y");
	}
}

class RotateNoteZModifier extends Rotate
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteRotatePivot(noteData, lane, "z");
	}
}

class RotateStrumXModifier extends Rotate
{
	override function setupSubValues()
	{
		setSubMod("offset_x", 1.0);
		setSubMod("offset_y", 1.0);
		setSubMod("offset_z", 0.0);
	}
	
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		strumRotatePivot(noteData, lane, "x");
	}
}

class RotateStrumYModifier extends Rotate
{
	override function setupSubValues()
	{
		setSubMod("offset_x", 1.0);
		setSubMod("offset_y", 1.0);
		setSubMod("offset_z", 0.0);
	}
	
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		strumRotatePivot(noteData, lane, "y");
	}
}

class RotateStrumZModifier extends Rotate
{
	override function setupSubValues()
	{
		setSubMod("offset_x", 1.0);
		setSubMod("offset_y", 1.0);
		setSubMod("offset_z", 0.0);
	}
	
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		strumRotatePivot(noteData, lane, "z");
	}
}

// here i add custom modifiers, why? well its to make some cool modcharts shits -Ed

class StrumAngleModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var multiply = -1;
		if (instance != null)
			if (ModchartUtil.getDownscroll(instance))
				multiply *= -1;
		noteData.angle += (currentValue * multiply);
		var laneShit = lane % NoteMovement.keyCount;
		var offsetThing = 0.5;
		var halfKeyCount = NoteMovement.keyCount / 2;
		if (lane < halfKeyCount)
		{
			offsetThing = -0.5;
			laneShit = lane + 1;
		}
		var distFromCenter = ((laneShit) - halfKeyCount) + offsetThing;
		noteData.x += -distFromCenter * NoteMovement.arrowSize;

		var q = SimpleQuaternion.fromEuler(90, 0, (currentValue * multiply)); // i think this is the right order???
		noteData.x += q.x * distFromCenter * NoteMovement.arrowSize;
		noteData.y += q.y * distFromCenter * NoteMovement.arrowSize;
		noteData.z += q.z * distFromCenter * NoteMovement.arrowSize;
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		// noteData.angle += (subValues.get('y').value/2);
		noteMath(noteData, lane, 0, pf);
	}

	override function incomingAngleMath(lane:Int, curPos:Float, pf:Int)
	{
		return [0, currentValue * -1];
	}

	override function reset()
	{
		super.reset();
		currentValue = 0; // the code that stop the mod from running gets confused when it resets in the editor i guess??
	}
}
