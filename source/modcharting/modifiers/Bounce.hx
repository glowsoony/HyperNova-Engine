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

		if (!usesAlt)
			mathToUse = NoteMovement.arrowSize * Math.abs(FlxMath.fastSin(curPos * 0.005 * (speed * 2)));
		else
			mathToUse = NoteMovement.arrowSize * Math.abs(FlxMath.fastCos(curPos * 0.005 * (speed * 2)));

		return currentValue * mathToUse;
	}

	function tanBounce(curPos:Float):Float
	{
		var speed:Float = subValues.get("speed").value;
		var usesAlt:Bool = (subValues.get("useAlt").value >= 0.5);

		var mathToUse:Float = 0.0;

		if (!usesAlt)
			mathToUse = NoteMovement.arrowSize * Math.abs(Math.tan(curPos * 0.005 * (speed * 2)));
		else
			mathToUse = NoteMovement.arrowSize * Math.abs((1 / Math.sin(curPos * 0.005 * (speed * 2))));

		return currentValue * mathToUse;
	}
}

class BounceXModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += bounce(curPos);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.x += bounce(curPos); // Make sure this only happens if using cos
	}
}

class BounceYModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += bounce(curPos);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.y += bounce(curPos);
	}
}

class BounceZModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += bounce(curPos);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.z += bounce(curPos);
	}
}

class BounceAngleModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleZ += bounce(curPos);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.angleZ += bounce(curPos);
	}
}

class BounceAngleXModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleX += bounce(curPos);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.angleX += bounce(curPos);
	}
}

class BounceAngleYModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleY += bounce(curPos);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.angleY += bounce(curPos);
	}
}

class BounceScaleModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += bounce(curPos) * 0.01;
		noteData.scaleY += bounce(curPos) * 0.01;
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.scaleX += bounce(curPos) * 0.01;
		if (subValues.get("useAlt") >= 0.5)
			noteData.scaleY += bounce(curPos) * 0.01;
	}
}

class BounceScaleXModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += bounce(curPos) * 0.01;
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.scaleX += bounce(curPos) * 0.01;
	}
}

class BounceScaleYModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY += bounce(curPos) * 0.01;
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.scaleY += bounce(curPos) * 0.01;
	}
}

class BounceSkewModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += bounce(curPos);
		noteData.skewY += bounce(curPos);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.skewX += bounce(curPos);
		if (subValues.get("useAlt") >= 0.5)
			noteData.skewY += bounce(curPos);
	}
}

class BounceSkewXModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += bounce(curPos);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.skewX += bounce(curPos);
	}
}

class BounceSkewYModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += bounce(curPos);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.skewY += bounce(curPos);
	}
}

class TanBounceXModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += tanBounce(curPos);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.x += tanBounce(curPos); // Make sure this only happens if using cosec
	}
}

class TanBounceYModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += tanBounce(curPos);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.y += tanBounce(curPos);
	}
}

class TanBounceZModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += tanBounce(curPos);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.z += tanBounce(curPos);
	}
}

class TanBounceAngleModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleZ += tanBounce(curPos);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.angleZ += tanBounce(curPos);
	}
}

class TanBounceAngleXModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleX += tanBounce(curPos);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.angleX += tanBounce(curPos);
	}
}

class TanBounceAngleYModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleY += tanBounce(curPos);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.angleY += tanBounce(curPos);
	}
}

class TanBounceScaleModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += tanBounce(curPos) * 0.01;
		noteData.scaleY += tanBounce(curPos) * 0.01;
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.scaleX += tanBounce(curPos) * 0.01;
		if (subValues.get("useAlt") >= 0.5)
			noteData.scaleY += tanBounce(curPos) * 0.01;
	}
}

class TanBounceScaleXModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += tanBounce(curPos) * 0.01;
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.scaleX += tanBounce(curPos) * 0.01;
	}
}

class TanBounceScaleYModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY += tanBounce(curPos) * 0.01;
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.scaleY += tanBounce(curPos) * 0.01;
	}
}

class TanBounceSkewModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += tanBounce(curPos);
		noteData.skewY += tanBounce(curPos);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.skewX += tanBounce(curPos);
		if (subValues.get("useAlt") >= 0.5)
			noteData.skewY += tanBounce(curPos);
	}
}

class TanBounceSkewXModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += tanBounce(curPos);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.skewX += tanBounce(curPos);
	}
}

class TanBounceSkewYModifier extends Bounce
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += tanBounce(curPos);
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt") >= 0.5)
			noteData.skewY += tanBounce(curPos);
	}
}
