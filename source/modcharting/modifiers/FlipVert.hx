package modcharting.modifiers;

import modcharting.*;
import modcharting.Modifier.ModifierSubValue;
import modcharting.Modifier;
import modcharting.PlayfieldRenderer.StrumNoteType;

// CHANGE LOG (the changes to modifiers)
// [REWORK] = totally overhaul of a modifier
// [UPDATE] = changed something on the modifier
// [RENAME] = rename of a modifier
// [REMOVAL] = a removed modifier
// [NEW] = a new modifier
// [EXTRA] = has nothing to do with modifiers but MT's enviroment.
// HERE CHANGE LIST

/*
	[EXTRA] HourGlass && Digital Improvements:
	-   Added a halper instead of copy and pasted code for the modifiers.

	[UPDATE] HourGlassScale && Digital: (X,Y Included)
	-   Now scale mods can stack (before, its behavior was like we have 2 mods but one its 0 then no mods other than that one works, now it's additive.)
 */
class FlipVert extends Modifier
{
	// subValues are called on the modifiers for less use of classes but same method of creation
	public function hourGlassMath():Float
	{
		var scrollSwitch = (instance != null && ModchartUtil.getDownscroll(instance)) ? -1 : 1;
		var pos = (Conductor.songPosition * 0.001) * scrollSwitch;

		// Copy of Sudden math
		var a:Float = FlxMath.remapToRange(pos, subValues.get("start").value + subValues.get("offset").value,
			subValues.get("end").value + subValues.get("offset").value, 1, 0);
		a = FlxMath.bound(a, 0, 1); // clamp

		var b:Float = 1 - a;
		var c:Float = (FlxMath.fastCos(b * Math.PI) / 2) + 0.5;

		return c;
	}

	public function digitalMath(curPos:Float):Float
	{
		// Copy of Sudden math
		var s = subValues.get('steps').value / 2;

		var funny:Float = FlxMath.fastSin((curPos * 0.45) * Math.PI * subValues.get("mult").value / 250) * s;
		// trace("1: " + funny);
		funny = Math.floor(funny);
		// funny = Math.round(funny); //Why does this not work? no idea :(
		// trace("2: " + funny);
		// funny = funny;
		funny /= s;
		// trace("3: " + funny);
		return funny;
	}
}

class FlipModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var nd = lane % NoteMovement.keyCount;
		var newPos = FlxMath.remapToRange(nd, 0, NoteMovement.keyCount, NoteMovement.keyCount, -NoteMovement.keyCount);

		noteData.x += NoteMovement.arrowSizes[lane] * newPos * currentValue;
		noteData.x -= NoteMovement.arrowSizes[lane] * currentValue;
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class InvertModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += NoteMovement.arrowSizes[lane] * (lane % 2 == 0 ? 1 : -1) * currentValue;
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class VideoGamesModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var laneThing = lane % NoteMovement.keyCount;

		if (laneThing > 0 && laneThing < 3) // down and up notes
			noteData.x += NoteMovement.arrowSizes[lane] * (laneThing == 1 ? 1 : -1) * currentValue;

		// if its 1 then it adds, otherwise it subtracts
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class InvertSineModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += FlxMath.fastSin(0 + (curPos * 0.004)) * (NoteMovement.arrowSizes[lane] * (lane % 2 == 0 ? 1 : -1) * currentValue * 0.5); // silly ah math
	}
}

class BlackSphereInvertModifier extends Modifier
{
	override public function setupSubValues()
	{
		baseValue = 1.0; // default set to skip math if value is default (1.0)
		currentValue = 1.0;
		subValues.set("variant", new ModifierSubValue(0.0));
		subValues.set("speedaffect", new ModifierSubValue(1.0));
	}

	// speed = curpos * currentValue (you could use noteDistToo but its a little more complex)
	override function curPosMath(lane:Int, curPos:Float, pf:Int):Float
	{
		var ud = false;
		if (instance != null)
			if (ModchartUtil.getDownscroll(instance))
				ud = true;

		var value = currentValue % 360; // make sure to always use 0-360 values

		var retu_val:Float = 1;
		var speedAffectM:Float = subValues.get("speedaffect").value;
		var yValue:Float = FlxMath.fastSin(value * Math.PI / 180);

		var variant:Bool = (subValues.get("variant").value >= 0.5);

		var laneThing = lane % NoteMovement.keyCount;

		if (variant) // make sure variant only gets applied when 1 or higger
		{
			if (laneThing % 4 == 1 || laneThing % 4 == 2)
				yValue *= -1;
		}
		else
		{
			if (laneThing % 2 == 1)
				yValue *= -1;
		}

		if (!ud)
			yValue *= -1;

		retu_val += yValue * 0.125 * speedAffectM;

		return curPos * retu_val;
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var value = currentValue % 360;

		var invertValue:Float = 0;
		var yValue:Float = 0;

		invertValue = 50 - 50 * FlxMath.fastCos(value * Math.PI / 180);
		invertValue /= 100;

		yValue = 0.5 * FlxMath.fastSin(value * Math.PI / 180);

		var variant:Bool = (subValues.get("variant").value >= 0.5);

		var laneThing = lane % NoteMovement.keyCount;

		if (variant) // make sure variant only gets applied when 1 or higger
		{
			if (laneThing % 4 == 1 || laneThing % 4 == 2)
				yValue *= -1;
		}
		else
		{
			if (laneThing % 2 == 1)
				yValue *= -1;
		}

		noteData.x += NoteMovement.arrowSizes[lane] * (laneThing % 2 == 0 ? 1 : -1) * invertValue;
		noteData.y += NoteMovement.arrowSizes[lane] * yValue;
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class BlackSphereFlipModifier extends Modifier
{
	override public function setupSubValues()
	{
		baseValue = 1.0; // default set to skip math if value is default (1.0)
		currentValue = 1.0;
		subValues.set("variant", new ModifierSubValue(0.0));
		subValues.set("speedaffect", new ModifierSubValue(1.0));
	}

	// speed = curpos * currentValue (you could use noteDistToo but its a little more complex)
	override function curPosMath(lane:Int, curPos:Float, pf:Int):Float
	{
		var ud = false;
		if (instance != null)
			if (ModchartUtil.getDownscroll(instance))
				ud = true;

		var value = currentValue % 360; // make sure to always use 0-360 values

		var retu_val:Float = 1;
		var speedAffectM:Float = subValues.get("speedaffect").value;
		var yValue:Float = FlxMath.fastSin(value * Math.PI / 180);

		var variant:Bool = (subValues.get("variant").value >= 0.5);

		var laneThing = lane % NoteMovement.keyCount;

		if (variant) // make sure variant only gets applied when 1 or higger
		{
			if (laneThing % 4 == 1 || laneThing % 4 == 2)
				yValue *= -1;
		}
		else
		{
			if (laneThing % 2 == 1)
				yValue *= -1;
		}

		if (!ud)
			yValue *= -1;

		retu_val += yValue * 0.125 * speedAffectM;

		return curPos * retu_val;
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var value = currentValue % 360;

		var invertValue:Float = 0;
		var yValue:Float = 0;

		invertValue = 50 - 50 * FlxMath.fastCos(value * Math.PI / 180);
		invertValue /= 100;

		yValue = 0.5 * FlxMath.fastSin(value * Math.PI / 180);

		var variant:Bool = (subValues.get("variant").value >= 0.5);

		var laneThing = lane % NoteMovement.keyCount;

		if (variant) // make sure variant only gets applied when 1 or higger
		{
			if (laneThing % 4 == 1 || laneThing % 4 == 2)
				yValue *= -1;
		}
		else
		{
			if (laneThing % 2 == 1)
				yValue *= -1;
		}

		var newPos = FlxMath.remapToRange(laneThing, 0, NoteMovement.keyCount, NoteMovement.keyCount, -NoteMovement.keyCount);
		noteData.x += NoteMovement.arrowSizes[lane] * newPos * invertValue;
		noteData.y += NoteMovement.arrowSizes[lane] * yValue;
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class HourGlassXModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('start', new ModifierSubValue(420.0));
		subValues.set('end', new ModifierSubValue(135.0));
		subValues.set('offset', new ModifierSubValue(0.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += NoteMovement.arrowSizes[lane] * hourGlassMath() * (lane - 1.5) * -2 * currentValue;
	}
}

class HourGlassYModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('start', new ModifierSubValue(420.0));
		subValues.set('end', new ModifierSubValue(135.0));
		subValues.set('offset', new ModifierSubValue(0.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += NoteMovement.arrowSizes[lane] * hourGlassMath() * (lane - 1.5) * -2 * currentValue;
	}
}

class HourGlassZModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('start', new ModifierSubValue(420.0));
		subValues.set('end', new ModifierSubValue(135.0));
		subValues.set('offset', new ModifierSubValue(0.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += NoteMovement.arrowSizes[lane] * hourGlassMath() * (lane - 1.5) * -2 * currentValue;
	}
}

class HourGlassAngleModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('start', new ModifierSubValue(420.0));
		subValues.set('end', new ModifierSubValue(135.0));
		subValues.set('offset', new ModifierSubValue(0.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angle += hourGlassMath() * (currentValue * -1);
	}
}

class HourGlassAngleXModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('start', new ModifierSubValue(420.0));
		subValues.set('end', new ModifierSubValue(135.0));
		subValues.set('offset', new ModifierSubValue(0.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleX += hourGlassMath() * (currentValue * -1);
	}
}

class HourGlassAngleYModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('start', new ModifierSubValue(420.0));
		subValues.set('end', new ModifierSubValue(135.0));
		subValues.set('offset', new ModifierSubValue(0.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleY += hourGlassMath() * (currentValue * -1);
	}
}

class HourGlassScaleModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('start', new ModifierSubValue(420.0));
		subValues.set('end', new ModifierSubValue(135.0));
		subValues.set('offset', new ModifierSubValue(0.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((hourGlassMath() * (currentValue * -1)) - 1);
		noteData.scaleY += ((hourGlassMath() * (currentValue * -1)) - 1);
	}
}

class HourGlassScaleXModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('start', new ModifierSubValue(420.0));
		subValues.set('end', new ModifierSubValue(135.0));
		subValues.set('offset', new ModifierSubValue(0.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((hourGlassMath() * (currentValue * -1)) - 1);
	}
}

class HourGlassScaleYModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('start', new ModifierSubValue(420.0));
		subValues.set('end', new ModifierSubValue(135.0));
		subValues.set('offset', new ModifierSubValue(0.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY += ((hourGlassMath() * (currentValue * -1)) - 1);
	}
}

class HourGlassSkewModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('start', new ModifierSubValue(420.0));
		subValues.set('end', new ModifierSubValue(135.0));
		subValues.set('offset', new ModifierSubValue(0.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += hourGlassMath() * (currentValue * -1);
		noteData.skewY += hourGlassMath() * (currentValue * -1);
	}
}

class HourGlassSkewXModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('start', new ModifierSubValue(420.0));
		subValues.set('end', new ModifierSubValue(135.0));
		subValues.set('offset', new ModifierSubValue(0.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += hourGlassMath() * (currentValue * -1);
	}
}

class HourGlassSkewYModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('start', new ModifierSubValue(420.0));
		subValues.set('end', new ModifierSubValue(135.0));
		subValues.set('offset', new ModifierSubValue(0.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += hourGlassMath() * (currentValue * -1);
	}
}

class DigitalXModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('steps', new ModifierSubValue(4.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += (digitalMath(curPos) * currentValue) * (NoteMovement.arrowSize / 2.0);
	}
}

class DigitalYModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('steps', new ModifierSubValue(4.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += (digitalMath(curPos) * currentValue) * (NoteMovement.arrowSize / 2.0);
	}
}

class DigitalZModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('steps', new ModifierSubValue(4.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += (digitalMath(curPos) * currentValue) * (NoteMovement.arrowSize / 2.0);
	}
}

class DigitalAngleModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('steps', new ModifierSubValue(4.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angle += digitalMath(curPos) * currentValue;
	}
}

class DigitalAngleXModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('steps', new ModifierSubValue(4.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleX += digitalMath(curPos) * currentValue;
	}
}

class DigitalAngleYModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('steps', new ModifierSubValue(4.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleY += digitalMath(curPos) * currentValue;
	}
}

class DigitalScaleModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('steps', new ModifierSubValue(4.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((digitalMath(curPos) * currentValue) - 1);
		noteData.scaleY += ((digitalMath(curPos) * currentValue) - 1);
	}
}

class DigitalScaleXModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('steps', new ModifierSubValue(4.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((digitalMath(curPos) * currentValue) - 1);
	}
}

class DigitalScaleYModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('steps', new ModifierSubValue(4.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY += ((digitalMath(curPos) * currentValue) - 1);
	}
}

class DigitalSkewModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('steps', new ModifierSubValue(4.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += (digitalMath(curPos) * currentValue);
		noteData.skewY += (digitalMath(curPos) * currentValue);
	}
}

class DigitalSkewXModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('steps', new ModifierSubValue(4.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += (digitalMath(curPos) * currentValue);
	}
}

class DigitalSkewYModifier extends FlipVert
{
	override function setupSubValues()
	{
		subValues.set('mult', new ModifierSubValue(1.0));
		subValues.set('steps', new ModifierSubValue(4.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += (digitalMath(curPos) * currentValue);
	}
}
