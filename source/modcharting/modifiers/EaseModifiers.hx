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

class EaseMod extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	function easeMath(lane:Int)
	{
		return currentValue * (FlxMath.fastCos(((Conductor.songPosition * 0.001) +
			((lane % NoteMovement.keyCount) * 0.2) * (10 / FlxG.height)) * (subValues.get('speed')
			.value * 0.2)) * Note.swagWidth * 0.5);
	}
}

class EaseXModifier extends EaseMod
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += easeMath(lane);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseYModifier extends EaseMod
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += easeMath(lane);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseZModifier extends EaseMod
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += easeMath(lane);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseAngleModifier extends EaseMod
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleZ += easeMath(lane);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseScaleModifier extends EaseMod
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((0.01 * easeMath(lane)) - 1);
		noteData.scaleY += ((0.01 * easeMath(lane)) - 1);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseScaleXModifier extends EaseMod
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((0.01 * easeMath(lane)) - 1);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseScaleYModifier extends EaseMod
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY += ((0.01 * easeMath(lane)) - 1);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseSkewModifier extends EaseMod
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += easeMath(lane);
		noteData.skewY += easeMath(lane);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseSkewXModifier extends EaseMod
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += easeMath(lane);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseSkewYModifier extends EaseMod
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += easeMath(lane);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseCurveModifier extends Modifier
{
	public var easeFunc = FlxEase.linear;

	public function setEase(ease:String)
	{
		easeFunc = ModchartUtil.getFlxEaseByString(ease);
	}
}

class EaseCurveXModifier extends EaseCurveModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += (easeFunc(curPos * 0.01) * currentValue * 0.2);
	}
}

class EaseCurveYModifier extends EaseCurveModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += (easeFunc(curPos * 0.01) * currentValue * 0.2);
	}
}

class EaseCurveZModifier extends EaseCurveModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += (easeFunc(curPos * 0.01) * currentValue * 0.2);
	}
}

class EaseCurveAngleModifier extends EaseCurveModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleZ += (easeFunc(curPos * 0.01) * currentValue * 0.2);
	}
}

class EaseCurveScaleModifier extends EaseCurveModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((easeFunc(curPos * 0.01) * currentValue * 0.2) - 1);
		noteData.scaleY += ((easeFunc(curPos * 0.01) * currentValue * 0.2) - 1);
	}
}

class EaseCurveScaleXModifier extends EaseCurveModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((easeFunc(curPos * 0.01) * currentValue * 0.2) - 1);
	}
}

class EaseCurveScaleYModifier extends EaseCurveModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY += ((easeFunc(curPos * 0.01) * currentValue * 0.2) - 1);
	}
}

class EaseCurveSkewModifier extends EaseCurveModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += (easeFunc(curPos * 0.01) * currentValue * 0.2);
		noteData.skewY += (easeFunc(curPos * 0.01) * currentValue * 0.2);
	}
}

class EaseCurveSkewXModifier extends EaseCurveModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += (easeFunc(curPos * 0.01) * currentValue * 0.2);
	}
}

class EaseCurveSkewYModifier extends EaseCurveModifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += (easeFunc(curPos * 0.01) * currentValue * 0.2);
	}
}
