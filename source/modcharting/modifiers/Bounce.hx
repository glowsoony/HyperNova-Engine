package modcharting.modifiers;

import modcharting.Modifier;
import modcharting.Modifier.ModifierSubValue;

/*
	[REWORK]
	- Make the changes to allow, COS AND TAN Bounce Mods.
 */

class BounceXModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += currentValue * ModifierMath.Bounce(lane, curPos, subValues.get('speed').value);
	}
}

class BounceYModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var daswitch = 1;
		if (instance != null)
			if (ModchartUtil.getDownscroll(instance))
				daswitch = -1;
		noteData.y += (currentValue * daswitch) * ModifierMath.Bounce(lane, curPos, subValues.get('speed').value);
	}
}

class BounceZModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += currentValue * ModifierMath.Bounce(lane, curPos, subValues.get('speed').value);
	}
}

class BounceAngleModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angle += currentValue * ModifierMath.Bounce(lane, curPos, subValues.get('speed').value);
	}
}

class BounceScaleModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX *= (1
			+ ((currentValue * 0.01) * NoteMovement.arrowSizes[lane] * Math.abs(FlxMath.fastSin(curPos * 0.005 * subValues.get('speed').value))));
		noteData.scaleY *= (1
			+ ((currentValue * 0.01) * NoteMovement.arrowSizes[lane] * Math.abs(FlxMath.fastSin(curPos * 0.005 * subValues.get('speed').value))));
	}
}

class BounceScaleXModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX *= (1
			+ ((currentValue * 0.01) * NoteMovement.arrowSizes[lane] * Math.abs(FlxMath.fastSin(curPos * 0.005 * subValues.get('speed').value))));
	}
}

class BounceScaleYModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY *= (1
			+ ((currentValue * 0.01) * NoteMovement.arrowSizes[lane] * Math.abs(FlxMath.fastSin(curPos * 0.005 * subValues.get('speed').value))));
	}
}

class BounceSkewModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += currentValue * ModifierMath.Bounce(lane, curPos, subValues.get('speed').value);
		noteData.skewY += currentValue * ModifierMath.Bounce(lane, curPos, subValues.get('speed').value);
	}
}

class BounceSkewXModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += currentValue * ModifierMath.Bounce(lane, curPos, subValues.get('speed').value);
	}
}

class BounceSkewYModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += currentValue * ModifierMath.Bounce(lane, curPos, subValues.get('speed').value);
	}
}