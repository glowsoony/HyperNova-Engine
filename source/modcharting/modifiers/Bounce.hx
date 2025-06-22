package modcharting.modifiers;

import flixel.FlxG;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import modcharting.Modifier.ModifierSubValue;
import modcharting.Modifier;
import modcharting.PlayfieldRenderer.StrumNoteType;
import modcharting.*;
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
	[EXTRA] Bounce Improvements:
	-   Now instead of copy paste the math over and over, Bounce has a main helper class with all math, making it easier to use Bounce with its sin(cos)/tan(cosec) variants.

	[EXTRA & REWORK] Bounce Helper class:
	-   Bounce helper class has the basics of Bounce with lot of new subValues (for both Bounce and TanBounce).
	- 	Some changes to the math, nothing too agressive to force people to redo a modchart, just some adjustments.
	-   Has 2 subValues:
		+   speed (changes Bounce's speed)
		+	useAlt (changes Bounce's math method, if using sin then it uses cos, if using tan it uses cosec, have in mind it will also move the strums (if enabled))
		+ Methods (2):
			1. Use ModifiersMath.Bounce(values) and set it to whatever you want to modify.
			2. Create a custom class (call it whatever u want (better if ends on "Modifier")) and extend it to this path (modcharting.modifiers.Bounce)
				then call it inside any customMod (yourPath/yourModifier.hx) on any of these (songName/customMods/yourCustomMod.hx) OR (songName/yourLua.lua)
				check how to make a customMod (both hx and lua) for better information.

	[NEW]
	- BounceAngleX, BounceAngleY, TanBounceAngleX, TanBounceAngleY. Prespective Angle Mods.
*/

class Bounce extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
		subValues.set('useAlt', new ModifierSubValue(0.0));
	}
	function bounce(curPos:Float):Float
	{
		var speed:Float = subValues.get("speed").value;
		var usesAlt:Bool = (subValues.get("useAlt").value >= 0.5);

		var mathToUse:Float = 0.0;

		if (!usesAlt) mathToUse = NoteMovement.arrowSize * Math.abs(FlxMath.fastSin(curPos * 0.005 * (speed*2)));
		else mathToUse = NoteMovement.arrowSize * Math.abs(FlxMath.fastCos(curPos * 0.005 * (speed*2)));

		return currentValue * mathToUse;
	}
	function tanBounce(curPos:Float):Float
	{
		var speed:Float = subValues.get("speed").value;
		var usesAlt:Bool = (subValues.get("useAlt").value >= 0.5);

		var mathToUse:Float = 0.0;

		if (!usesAlt) mathToUse = NoteMovement.arrowSize * Math.abs(Math.tan(curPos * 0.005 * (speed*2)));
		else mathToUse = NoteMovement.arrowSize * Math.abs((1/Math.sin(curPos * 0.005 * (speed*2))));

		return currentValue * mathToUse;
	}
}
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
		noteData.scaleX += (1
			+ ((currentValue * 0.01) * NoteMovement.arrowSizes[lane] * Math.abs(FlxMath.fastSin(curPos * 0.005 * subValues.get('speed').value))));
		noteData.scaleY += (1
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