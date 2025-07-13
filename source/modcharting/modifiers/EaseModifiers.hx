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

class EaseXModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += currentValue * ModifierMath.Ease(lane, subValues.get('speed').value);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseYModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += currentValue * ModifierMath.Ease(lane, subValues.get('speed').value);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseZModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += currentValue * ModifierMath.Ease(lane, subValues.get('speed').value);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseAngleModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleZ += currentValue * ModifierMath.Ease(lane, subValues.get('speed').value);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseScaleModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += (1 + ((currentValue * 0.01) * ModifierMath.Ease(lane, subValues.get('speed').value)));
		noteData.scaleY *= (1 + ((currentValue * 0.01) * ModifierMath.Ease(lane, subValues.get('speed').value)));
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseScaleXModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX *= (1 + ((currentValue * 0.01) * ModifierMath.Ease(lane, subValues.get('speed').value)));
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseScaleYModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY *= (1 + ((currentValue * 0.01) * ModifierMath.Ease(lane, subValues.get('speed').value)));
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseSkewModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += currentValue * ModifierMath.Ease(lane, subValues.get('speed').value);

		noteData.skewY += currentValue * ModifierMath.Ease(lane, subValues.get('speed').value);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseSkewXModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += currentValue * ModifierMath.Ease(lane, subValues.get('speed').value);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf); // just reuse same thing
	}
}

class EaseSkewYModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += currentValue * ModifierMath.Ease(lane, subValues.get('speed').value);
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
