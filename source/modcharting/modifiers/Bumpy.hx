package modcharting.modifiers;

import modcharting.Modifier;
import modcharting.Modifier.ModifierSubValue;

/*
	[NEW]	
	- BumpyAngleX, BumpyAngleY, TanBumpyAngleX, TanBumpyAngleY. Prespective Angle Mods.
*/


class BumpyModifier extends Modifier
{
    override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += currentValue * ModifierMath.Bumpy(curPos, subValues.get('speed').value);
	}
}

class BumpyXModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += currentValue * ModifierMath.Bumpy(curPos, subValues.get('speed').value);
	}
}

class BumpyYModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += currentValue * ModifierMath.Bumpy(curPos, subValues.get('speed').value);
	}
}

class BumpyAngleModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angle += currentValue * ModifierMath.Bumpy(curPos, subValues.get('speed').value);
	}
}

class BumpyAngleXModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleX += currentValue * ModifierMath.Bumpy(curPos, subValues.get('speed').value);
	}
}

class BumpyAngleYModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleY += currentValue * ModifierMath.Bumpy(curPos, subValues.get('speed').value);
	}
}

class BumpyScaleModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX *= (1 + ((currentValue * 0.01) * ModifierMath.Bumpy(curPos, subValues.get('speed').value)));
		noteData.scaleY *= (1 + ((currentValue * 0.01) * ModifierMath.Bumpy(curPos, subValues.get('speed').value)));
	}
}

class BumpyScaleXModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX *= (1 + ((currentValue * 0.01) * ModifierMath.Bumpy(curPos, subValues.get('speed').value)));
	}
}

class BumpyScaleYModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY *= (1 + ((currentValue * 0.01) * ModifierMath.Bumpy(curPos, subValues.get('speed').value)));
	}
}

class BumpySkewModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += currentValue * ModifierMath.Bumpy(curPos, subValues.get('speed').value);
		noteData.skewY += currentValue * ModifierMath.Bumpy(curPos, subValues.get('speed').value);
	}
}

class BumpySkewXModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += currentValue * ModifierMath.Bumpy(curPos, subValues.get('speed').value);
	}
}

class BumpySkewYModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += currentValue * ModifierMath.Bumpy(curPos, subValues.get('speed').value);
	}
}

class TanBumpyXModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += currentValue * ModifierMath.TanBumpy(curPos, subValues.get('speed').value);
	}
}

class TanBumpyYModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += currentValue * ModifierMath.TanBumpy(curPos, subValues.get('speed').value);
	}
}

class TanBumpyModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += currentValue * ModifierMath.TanBumpy(curPos, subValues.get('speed').value);
	}
}

class TanBumpyAngleModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angle += currentValue * ModifierMath.TanBumpy(curPos, subValues.get('speed').value);
	}
}

class TanBumpyAngleXModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleX += currentValue * ModifierMath.TanBumpy(curPos, subValues.get('speed').value);
	}
}

class TanBumpyAngleYModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angle += currentValue * ModifierMath.TanBumpy(curPos, subValues.get('speed').value);
	}
}

class TanBumpyScaleModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX *= (1 + ((currentValue * 0.01) * ModifierMath.TanBumpy(curPos, subValues.get('speed').value)));
		noteData.scaleY *= (1 + ((currentValue * 0.01) * ModifierMath.TanBumpy(curPos, subValues.get('speed').value)));
	}
}

class TanBumpyScaleXModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX *= (1 + ((currentValue * 0.01) * ModifierMath.TanBumpy(curPos, subValues.get('speed').value)));
	}
}

class TanBumpyScaleYModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY *= (1 + ((currentValue * 0.01) * ModifierMath.TanBumpy(curPos, subValues.get('speed').value)));
	}
}

class TanBumpySkewModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += currentValue * ModifierMath.TanBumpy(curPos, subValues.get('speed').value);
		noteData.skewY += currentValue * ModifierMath.TanBumpy(curPos, subValues.get('speed').value);
	}
}

class TanBumpySkewXModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += currentValue * ModifierMath.TanBumpy(curPos, subValues.get('speed').value);
	}
}

class TanBumpySkewYModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += currentValue * ModifierMath.TanBumpy(curPos, subValues.get('speed').value);
	}
}