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
	[EXTRA] HourGlass Improvements:
	-   Now instead of copy paste the math over and over, HourGlass has a main helper class with all math, making it easier to use HourGlass.

	[EXTRA & REWORK] HourGlass Helper class:
	-   HourGlass helper class has the basics of HourGlass with new subValues.
	-   Added 2 subValues:
		+   mult (changes HourGlass's period)
		+   steps (changes HourGlass's offset)
	-   HourGlass helper class can be called via custom mods (so you can create any custom HourGlassMod, such as idk, HourGlassDadX. yet you are the one who defines how to use it).
		+ Methods (2):
			1. Use ModifiersMath.HourGlass(values) and set it to whatever you want to modify.
			2. Create a custom class (call it whatever u want (better if ends on "Modifier")) and extend it to this path (modcharting.modifiers.HourGlass)
				then call it inside any customMod (yourPath/yourModifier.hx) on any of these (songName/customMods/yourCustomMod.hx) OR (songName/yourLua.lua)
				check how to make a customMod (both hx and lua) for better information.

	[NEW] 
	- HourGlassAngleX, HourGlassAngleY. Prespective Angles added!
 */

class HourGlass extends Modifier
{
	override function setupSubValues()
	{
		setSubMod("start", 420.0);
		setSubMod("end", 135.0);
		setSubMod("offset", 0.0);
	}

	public function hourGlassMath():Float
	{
		var scrollSwitch = (instance != null && ModchartUtil.getDownscroll(instance)) ? -1 : 1;
		var pos = (Conductor.songPosition * 0.001) * scrollSwitch;

		// Copy of Sudden math
		var a:Float = FlxMath.remapToRange(pos, getSubMod("start") + getSubMod("offset"),
			getSubMod("end") + getSubMod("offset"), 1, 0);
		a = FlxMath.bound(a, 0, 1); // clamp

		var b:Float = 1 - a;
		var c:Float = (FlxMath.fastCos(b * Math.PI) / 2) + 0.5;

		return c;
	}
}

class HourGlassXModifier extends HourGlass
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += NoteMovement.arrowSizes[lane] * hourGlassMath() * (lane - 1.5) * -2 * currentValue;
	}
}

class HourGlassYModifier extends HourGlass
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.y += NoteMovement.arrowSizes[lane] * hourGlassMath() * (lane - 1.5) * -2 * currentValue;
	}
}

class HourGlassZModifier extends HourGlass
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.z += NoteMovement.arrowSizes[lane] * hourGlassMath() * (lane - 1.5) * -2 * currentValue;
	}
}

class HourGlassAngleModifier extends HourGlass
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angle += hourGlassMath() * (currentValue * -1);
	}
}

class HourGlassAngleXModifier extends HourGlass
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleX += hourGlassMath() * (currentValue * -1);
	}
}

class HourGlassAngleYModifier extends HourGlass
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.angleY += hourGlassMath() * (currentValue * -1);
	}
}

class HourGlassScaleModifier extends HourGlass
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((hourGlassMath() * (currentValue * -1)) - 1);
		noteData.scaleY += ((hourGlassMath() * (currentValue * -1)) - 1);
	}
}

class HourGlassScaleXModifier extends HourGlass
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleX += ((hourGlassMath() * (currentValue * -1)) - 1);
	}
}

class HourGlassScaleYModifier extends HourGlass
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.scaleY += ((hourGlassMath() * (currentValue * -1)) - 1);
	}
}

class HourGlassSkewModifier extends HourGlass
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += hourGlassMath() * (currentValue * -1);
		noteData.skewY += hourGlassMath() * (currentValue * -1);
	}
}

class HourGlassSkewXModifier extends HourGlass
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewX += hourGlassMath() * (currentValue * -1);
	}
}

class HourGlassSkewYModifier extends HourGlass
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.skewY += hourGlassMath() * (currentValue * -1);
	}
}