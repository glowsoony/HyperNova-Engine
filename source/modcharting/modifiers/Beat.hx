package modcharting.modifiers;

import modcharting.Modifier;
import modcharting.Modifier.ModifierSubValue;

/*
	[NEW]	
	- BeatAngleX, BeatAngleY. Prespective Angle Mods.
*/

class BeatXModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += currentValue * ModifierMath.Beat(curPos, subValues.get('speed').value, subValues.get('mult').value);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class BeatYModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += currentValue * ModifierMath.Beat(curPos, subValues.get('speed').value, subValues.get('mult').value);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class BeatZModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += currentValue * ModifierMath.Beat(curPos, subValues.get('speed').value, subValues.get('mult').value);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class BeatAngleModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angle += currentValue * ModifierMath.Beat(curPos, subValues.get('speed').value, subValues.get('mult').value);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class BeatAngleXModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleX += currentValue * ModifierMath.Beat(curPos, subValues.get('speed').value, subValues.get('mult').value);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class BeatAngleYModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleY += currentValue * ModifierMath.Beat(curPos, subValues.get('speed').value, subValues.get('mult').value);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class BeatScaleModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX *= (1 + ((currentValue * 0.01) * ModifierMath.Beat(curPos, subValues.get('speed').value, subValues.get('mult').value)));
		noteData.scaleY *= (1 + ((currentValue * 0.01) * ModifierMath.Beat(curPos, subValues.get('speed').value, subValues.get('mult').value)));
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class BeatScaleXModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX *= (1 + ((currentValue * 0.01) * ModifierMath.Beat(curPos, subValues.get('speed').value, subValues.get('mult').value)));
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class BeatScaleYModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY *= (1 + ((currentValue * 0.01) * ModifierMath.Beat(curPos, subValues.get('speed').value, subValues.get('mult').value)));
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class BeatSkewModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += currentValue * ModifierMath.Beat(curPos, subValues.get('speed').value, subValues.get('mult').value);
		noteData.skewY += currentValue * ModifierMath.Beat(curPos, subValues.get('speed').value, subValues.get('mult').value);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class BeatSkewXModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += currentValue * ModifierMath.Beat(curPos, subValues.get('speed').value, subValues.get('mult').value);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class BeatSkewYModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += currentValue * ModifierMath.Beat(curPos, subValues.get('speed').value, subValues.get('mult').value);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}