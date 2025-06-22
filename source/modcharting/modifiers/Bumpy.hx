package modcharting.modifiers;

import modcharting.Modifier.ModifierSubValue;
import modcharting.Modifier;

// CHANGE LOG (the changes to modifiers)
// [REWORK] = totally overhaul of a modifier
// [UPDATE] = changed something on the modifier
// [RENAME] = rename of a modifier
// [REMOVAL] = a removed modifier
// [NEW] = a new modifier
// [EXTRA] = has nothing to do with modifiers but MT's enviroment.
// HERE CHANGE LIST

/*
	[EXTRA] Bumpy Improvements:
	-   Now instead of copy paste the math over and over, Bumpy has a main helper class with all math, making it easier to use Bumpy with its sin(cos)/tan(cosec) variants.

	[EXTRA & REWORK] Bumpy Helper class:
	-   Bumpy helper class has the basics of Bumpy with lot of new subValues (for both Bumpy and TanBumpy).
	- 	Changed the math of bumpy to a new cooler one (still allows using old math, i barely see any difference tho).
	-   Has 3 subValues:
		+   speed (changes Bumpy's speed)
		+	useAlt (changes Bumpy's math method, if using sin then it uses cos, if using tan it uses cosec, have in mind it will also move the strums (if enabled))
		+	oldMath (uses old  math for bumpy, added for backwards support)
		+ Methods (2):
			1. Use ModifiersMath.Bumpy(values) and set it to whatever you want to modify.
			2. Create a custom class (call it whatever u want (better if ends on "Modifier")) and extend it to this path (modcharting.modifiers.Bumpy)
				then call it inside any customMod (yourPath/yourModifier.hx) on any of these (songName/customMods/yourCustomMod.hx) OR (songName/yourLua.lua)
				check how to make a customMod (both hx and lua) for better information.

	[NEW]
	- BumpyAngleX, BumpyAngleY, TanBumpyAngleX, TanBumpyAngleY. Prespective Angle Mods.
*/

class Bumpy extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
		subValues.set('useAlt', new ModifierSubValue(0.0));
		subValues.set('oldMath', new ModifierSubValue(0.0));
	}

	function bumpyMath(curPos:Float):Float
	{
		var mathToUse:Float = 0.0;
		var scrollSpeed:Float = renderer.getCorrectScrollSpeed();
		var speed:Float = subValues.get("speed").value;
		var oldMath:Bool = (subValues.get("oldMath").value >= 0.5);
		var usesAlt:Bool = (subValues.get("useAlt").value >= 0.5);

		if (oldMath){
			if (!usesAlt) mathToUse = 40 * FlxMath.fastSin(curPos * 0.01 * speed);
			else mathToUse = 40 * FlxMath.fastCos(curPos * 0.01 * speed);
		}else{
			if (!usesAlt) mathToUse = FlxMath.fastSin(curPos / (NoteMovement.arrowSize / 3.0) / scrollSpeed * speed) * (NoteMovement.arrowSize / 2.0);
			else mathToUse = FlxMath.fastCos(curPos / (NoteMovement.arrowSize / 3.0) / scrollSpeed * speed) * (NoteMovement.arrowSize / 2.0);
		}
		return currentValue * mathToUse;
	}

	function tanBumpyMath(curPos:Float, speed:Float):Float
	{
		var mathToUse:Float = 0.0;
		var scrollSpeed:Float = renderer.getCorrectScrollSpeed();
		var speed:Float = subValues.get("speed").value;
		var oldMath:Bool = (subValues.get("oldMath").value >= 0.5);
		var usesAlt:Bool = (subValues.get("useAlt").value >= 0.5);

		if (oldMath){
			if (!usesAlt) mathToUse = 40 * Math.tan(curPos * 0.01 * speed);
			else mathToUse = 40 * (1 / Math.sin(curPos * 0.01 * speed));
		}else{
			if (!usesAlt) mathToUse = Math.tan(curPos / (NoteMovement.arrowSize / 3.0) / scrollSpeed * speed) * (NoteMovement.arrowSize / 2.0);
			else mathToUse = (1 / Math.sin(curPos / (NoteMovement.arrowSize / 3.0) / scrollSpeed * speed) * (NoteMovement.arrowSize / 2.0));
		}
		return currentValue * mathToUse;
	};
}

class BumpyModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += bumpyMath(curPos);
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.z += bumpyMath(curPos); // allows movement on notes ONLY when using alt (cos/cosec)
	}
}
class BumpyXModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += bumpyMath(curPos);
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.x += bumpyMath(curPos);
	}
}
class BumpyYModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += bumpyMath(curPos);
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.y += bumpyMath(curPos);
	}
}
class BumpyAngleModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angle += bumpyMath(curPos);
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.angle += bumpyMath(curPos);
	}
}
class BumpyAngleXModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleX += bumpyMath(curPos);
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.angleX += bumpyMath(curPos);
	}
}
class BumpyAngleYModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleY += bumpyMath(curPos);
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.angleY += bumpyMath(curPos);
	}
}
class BumpyScaleModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += bumpyMath(curPos) * 0.01;
		noteData.scaleY += bumpyMath(curPos) * 0.01;
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.scaleX += bumpyMath(curPos) * 0.01;
		if (subValues.get("useAlt").value >= 0.5) noteData.scaleY += bumpyMath(curPos) * 0.01;
	}
}
class BumpyScaleXModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += bumpyMath(curPos) * 0.01;
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.scaleX += bumpyMath(curPos) * 0.01;
	}
}
class BumpyScaleYModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY += bumpyMath(curPos) * 0.01;
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.scaleY += bumpyMath(curPos) * 0.01;
	}
}
class BumpySkewModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += bumpyMath(curPos);
		noteData.skewY += bumpyMath(curPos);
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.skewX += bumpyMath(curPos);
		if (subValues.get("useAlt").value >= 0.5) noteData.skewY += bumpyMath(curPos);
	}
}
class BumpySkewXModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += bumpyMath(curPos) * 0.01;
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.skewX += bumpyMath(curPos);
	}
}
class BumpySkewYModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += bumpyMath(curPos) * 0.01;
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.skewY += bumpyMath(curPos);
	}
}

class TanBumpyModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += tanBumpyMath(curPos);
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.z += tanBumpyMath(curPos); // allows movement on notes ONLY when using alt (cos/cosec)
	}
}
class TanBumpyXModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += tanBumpyMath(curPos);
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.x += tanBumpyMath(curPos);
	}
}
class TanBumpyYModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += tanBumpyMath(curPos);
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.y += tanBumpyMath(curPos);
	}
}
class TanBumpyAngleModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angle += tanBumpyMath(curPos);
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.angle += tanBumpyMath(curPos);
	}
}
class TanBumpyAngleXModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleX += tanBumpyMath(curPos);
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.angleX += tanBumpyMath(curPos);
	}
}
class TanBumpyAngleYModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleY += tanBumpyMath(curPos);
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.angleY += tanBumpyMath(curPos);
	}
}
class TanBumpyScaleModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += tanBumpyMath(curPos) * 0.01;
		noteData.scaleY += tanBumpyMath(curPos) * 0.01;
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.scaleX += tanBumpyMath(curPos) * 0.01;
		if (subValues.get("useAlt").value >= 0.5) noteData.scaleY += tanBumpyMath(curPos) * 0.01;
	}
}
class TanBumpyScaleXModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += tanBumpyMath(curPos) * 0.01;
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.scaleX += tanBumpyMath(curPos) * 0.01;
	}
}
class TanBumpyScaleYModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY += tanBumpyMath(curPos) * 0.01;
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.scaleY += tanBumpyMath(curPos) * 0.01;
	}
}
class TanBumpySkewModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += tanBumpyMath(curPos);
		noteData.skewY += tanBumpyMath(curPos);
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.skewX += tanBumpyMath(curPos);
		if (subValues.get("useAlt").value >= 0.5) noteData.skewY += tanBumpyMath(curPos);
	}
}
class TanBumpySkewXModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += tanBumpyMath(curPos) * 0.01;
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.skewX += tanBumpyMath(curPos);
	}
}
class TanBumpySkewYModifier extends Bumpy
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += tanBumpyMath(curPos) * 0.01;
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		if (subValues.get("useAlt").value >= 0.5) noteData.skewY += tanBumpyMath(curPos);
	}
}