package modcharting.modifiers;

import modcharting.*;
import modcharting.Modifier.ModifierSubValue;
import modcharting.Modifier;
import modcharting.PlayfieldRenderer.StrumNoteType;

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
class RotateModifier extends Modifier
{
	var pivotPoint:Vector2 = new Vector2(0, 0);
	var point:Vector2 = new Vector2(0, 0);

	override function setupSubValues()
	{
		subValues.set('offset_x', new ModifierSubValue(1.0));
		subValues.set('offset_y', new ModifierSubValue(1.0));
		subValues.set('offset_z', new ModifierSubValue(0.0));
	}

	function noteRotatePivotMath(noteData:NotePositionData, lane:Int, type:String = "x")
	{
		switch (type)
		{
			case "x":
				var x:Float = PlayState.instance.strumLineNotes.members[lane % PlayState.instance.strumLineNotes.members.length].x;
				return x;
			case "y":
				var y:Float = PlayState.instance.strumLineNotes.members[lane % PlayState.instance.strumLineNotes.members.length].y;
				y += (NoteMovement.arrowSizes[lane] / 2);
				return y;
			case "z":
				return PlayState.instance.strumLineNotes.members[lane % PlayState.instance.strumLineNotes.members.length].z;
		}
	}

	function noteRotatePivot(noteData:NotePositionData, lane:Int, type:String = "x")
	{
		if (angle == null)
			angle = currentValue;
		if (angle % 360 == 0)
			return;
		switch (variant)
		{
			case "z":
				pivotPoint.x = noteRotatePivotMath(noteData, lane, "x");
				pivotPoint.y = noteRotatePivotMath(noteData, lane, "x");
				point.x = data.x;
				point.y = data.y;
				var output:Vector2 = ModchartUtil.rotateAround(pivotPoint, point, angle);
				data.x = output.x;
				data.y = output.y;
			case "y":
				pivotPoint.x = noteRotatePivotMath(noteData, lane, "y");
				pivotPoint.y = noteRotatePivotMath(noteData, lane, "y");
				point.x = data.x;
				point.y = data.z;
				var output:Vector2 = ModchartUtil.rotateAround(pivotPoint, point, angle);
				data.x = output.x;
				data.z = output.y;
			case "x":
				pivotPoint.x = noteRotatePivotMath(noteData, lane, "z");
				pivotPoint.y = noteRotatePivotMath(noteData, lane, "z");
				point.x = data.z;
				point.y = data.y;
				var output:Vector2 = ModchartUtil.rotateAround(pivotPoint, point, angle);
				data.z = output.x;
				data.y = output.y;
		}
	}

	function strumRotatePivot(noteData:NotePositionData, lane:Int, type:String = "x")
	{
		switch (type)
		{
			case "x":
				return noteData.x + subValues.get('offset_x') + NoteMovement.arrowSizes[lane] * 1.5;
			case "y":
				return (FlxG.height / 2)
					- (PlayState.instance.strumLineNotes.members[lane % PlayState.instance.strumLineNotes.members.length].height / 2)
					+ subValues.get('offset_y');
			case "z":
				return 0.0 + subValues.get('offset_z');
		}
	}
}

class RotateXModifier extends RotateModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteRotatePivot(noteData, lane, "x");
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		strumMathPivot(noteData, lane, "x");
	}
}

class RotateYModifier extends RotateModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteRotatePivot(noteData, lane, "y");
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		strumMathPivot(noteData, lane, "y");
	}
}

class RotateZModifier extends RotateModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteRotatePivot(noteData, lane, "z");
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		strumMathPivot(noteData, lane, "z");
	}
}

class RotateNoteXModifier extends RotateModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteRotatePivot(noteData, lane, "x");
	}
}

class RotateNoteYModifier extends RotateModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteRotatePivot(noteData, lane, "y");
	}
}

class RotateNoteZModifier extends RotateModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteRotatePivot(noteData, lane, "z");
	}
}

class RotateStrumXModifier extends RotateModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		strumRotatePivot(noteData, lane, "x");
	}
}

class RotateStrumYModifier extends RotateModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		strumRotatePivot(noteData, lane, "y");
	}
}

class RotateStrumZModifier extends RotateModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		strumRotatePivot(noteData, lane, "z");
	}
}
