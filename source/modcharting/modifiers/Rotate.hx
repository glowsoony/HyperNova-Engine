package modcharting.modifiers;

import modcharting.*;
import modcharting.Modifier.ModifierSubValue;
import modcharting.Modifier;
import modcharting.PlayfieldRenderer.StrumNoteType;
import lime.math.Vector2;
import openfl.geom.Vector3D;

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

	override function setupSubValues()
	{
		setSubMod("offset_x", 0.0);
		setSubMod("offset_y", 0.0);
		setSubMod("offset_z", 0.0);
	}

	function getPivot(noteData:NotePositionData, lane:Int, type:String = "x")
	{
		switch (type)
		{
			case "x":
				var r:Float = 0;
					
				//1 should return oponent's midPoint, while 2 should return player's
				var downStrumPosition:Float = NoteMovement.defaultStrumX[
					(lane < NoteMovement.keyCount ? (Std.int(NoteMovement.totalKeyCount/2)) : (NoteMovement.totalKeyCount)) - Std.int((NoteMovement.keyCount/2)) - 1
				];
				var upStrumPosition:Float = NoteMovement.defaultStrumX[
					(lane < NoteMovement.keyCount ? (Std.int(NoteMovement.totalKeyCount/2)) : (NoteMovement.totalKeyCount)) - Std.int((NoteMovement.keyCount/2))
				];

				var midPosition = (upStrumPosition - downStrumPosition) / 2;
				r += downStrumPosition + midPosition;
				r += getSubMod("offset_x");
				return r;
			case "y":
				return (FlxG.height/2) + getSubMod("offset_y");
			case "z":
				return 0.0 + getSubMod("offset_z");
			default:
				return 0.0;
		}
	}

	function rotatePivot(noteData:NotePositionData, lane:Int, pf:Int, type:String = "x")
	{
		var angle:Float = currentValue;

		switch (type)
		{
			case "z":
				pivotPoint.x = getPivot(noteData, lane, "x");
				pivotPoint.y = getPivot(noteData, lane, "y");
				point.x = noteData.x;
				point.y = noteData.y;
				var output:Vector2 = ModchartUtil.rotateAround(pivotPoint, point, angle);
				noteData.x = output.x;
				noteData.y = output.y;
			case "y":
				pivotPoint.x = getPivot(noteData, lane, "x");
				pivotPoint.y = getPivot(noteData, lane, "z");
				point.x = noteData.x;
				point.y = noteData.z;
				var output:Vector2 = ModchartUtil.rotateAround(pivotPoint, point, angle);
				noteData.x = output.x;
				noteData.z = output.y;
			case "x":
				pivotPoint.x = getPivot(noteData, lane, "z");
				pivotPoint.y = getPivot(noteData, lane, "y");
				point.x = noteData.z;
				point.y = noteData.y;
				var output:Vector2 = ModchartUtil.rotateAround(pivotPoint, point, angle);
				noteData.z = output.x;
				noteData.y = output.y;
		}
	}
}

class RotateModifier extends Modifier
{
	override function setupSubValues()
	{
		baseValue = 0.0;
		currentValue = 1.0;

		setSubMod("x", 0.0);
		setSubMod("y", 0.0);
		setSubMod("z", 0.0);
	}

	public function getOrigin(noteData:NotePositionData):Vector3D {
		var fixedLane = Math.round(NoteMovement.totalKeyCount / 2);
		return new Vector3D(NoteMovement.defaultStrumX[fixedLane], FlxG.height / 2);
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var angleX = getSubMod("x");
		var angleY = getSubMod("y");
		var angleZ = getSubMod("z");

		var curData:Vector3D = new Vector3D(noteData.x, noteData.y, noteData.z);
		var data:Vector3D = getOrigin(noteData);
		curData.decrementBy(data);

		var finalData = ModchartUtil.rotate3DVector(curData, angleX, angleY, angleZ);

		noteData.x += finalData.x;
		noteData.y += finalData.y;
		noteData.z += finalData.z;
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class RotateXModifier extends Rotate
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		rotatePivot(noteData, lane, pf, "x");
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		rotatePivot(noteData, lane, pf, "x");
	}
}

class RotateYModifier extends Rotate
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		rotatePivot(noteData, lane, pf, "y");
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		rotatePivot(noteData, lane, pf, "y");
	}
}

class RotateZModifier extends Rotate
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		rotatePivot(noteData, lane, pf, "z");
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		rotatePivot(noteData, lane, pf, "z");
	}
}

class RotateNoteXModifier extends Rotate
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		rotatePivot(noteData, lane, pf, "x");
	}
}

class RotateNoteYModifier extends Rotate
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		rotatePivot(noteData, lane, pf, "y");
	}
}

class RotateNoteZModifier extends Rotate
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		rotatePivot(noteData, lane, pf, "z");
	}
}

class RotateStrumXModifier extends Rotate
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		rotatePivot(noteData, lane, pf, "x");
	}
}

class RotateStrumYModifier extends Rotate
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		rotatePivot(noteData, lane, pf, "y");
	}
}

class RotateStrumZModifier extends Rotate
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		rotatePivot(noteData, lane, pf, "z");
	}
}

// class RotatingYModifier extends Rotate
// {
// 	override function setupSubValues()
// 	{
// 		setSubMod("affects_strum", 0.0);
// 	}
	
// 	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
// 	{
// 		var curVal:Float = currentValue * curPos / 180;
// 		noteRotatePivot(noteData, lane, "y", curVal);
// 	}

// 	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
// 	{
// 		if (currentValue % 360 == 0 || getSubMod("affects_strum") == 0) return;
// 		var curVal:Float = currentValue * 1 / 180;
// 		strumRotatePivot(noteData, lane, "y", curVal);
// 	}
// }

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
