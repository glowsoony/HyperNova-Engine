package modcharting.modifiers;

import modcharting.Modifier;
import modcharting.Modifier.ModifierSubValue;
import flixel.math.FlxMath;

//CHANGE LOG (the changes to modifiers)

//[REWORK] = totally overhaul of a modifier
//[UPDATE] = changed something on the modifier
//[RENAME] = rename of a modifier
//[REMOVAL] = a removed modifier
//[NEW] = a new modifier
//[EXTRA] = has nothing to do with modifiers but MT's enviroment.

//HERE CHANGE LIST
/*
    [RENAME] StrumAlphaModifier: (Previously known as TargetAlphaModifier)
    -   Rename to fit more the standard names along the other mods.

	[NEW] FlashModifier:
	-	FlashModifier is a merge of both StealthModifier and DarkModifier to make easier use of them in case you want to use them together.

	[RENAME] FlashColorModifier: (Previously known as SDColorModifier)
	-	Same basics as StealthColor and DarkColor in one modifier, renamed to fit the new "FlashModifier" info.

*/

class AlphaModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.alpha *= 1 - currentValue;
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class NoteAlphaModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.alpha *= 1 - currentValue;
	}
}

class StrumAlphaModifier extends Modifier
{
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteData.alpha *= 1 - currentValue;
	}
}

class StealthModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var stealthGlow:Float = currentValue * 2;
		noteData.stealthGlow += FlxMath.bound(stealthGlow, 0, 1); // clamp

		var substractAlpha:Float = currentValue - 0.5;
		substractAlpha = FlxMath.bound(substractAlpha * 2, 0, 1);
		noteData.alpha *= 1 - substractAlpha;
	}
}

class DarkModifier extends Modifier
{
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		var stealthGlow:Float = currentValue * 2;
		noteData.stealthGlow += FlxMath.bound(stealthGlow, 0, 1); // clamp

		var substractAlpha:Float = currentValue - 0.5;
		substractAlpha = FlxMath.bound(substractAlpha * 2, 0, 1);
		noteData.alpha *= 1 - substractAlpha;
	}
}

class FlashModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var stealthGlow:Float = currentValue * 2;
		noteData.stealthGlow += FlxMath.bound(stealthGlow, 0, 1); // clamp

		var substractAlpha:Float = currentValue - 0.5;
		substractAlpha = FlxMath.bound(substractAlpha * 2, 0, 1);
		noteData.alpha *= 1 - substractAlpha;
	}
	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class StealthColorModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('r', new ModifierSubValue(255.0));
		subValues.set('g', new ModifierSubValue(255.0));
		subValues.set('b', new ModifierSubValue(255.0));
		currentValue = 1.0;
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		var red = subValues.get('r').value / 255; // so i can get exact values instead of 0.7668676767676768
		var green = subValues.get('g').value / 255;
		var blue = subValues.get('b').value / 255;

		noteData.glowRed *= red;
		noteData.glowGreen *= green;
		noteData.glowBlue *= blue;
	}

	override public function reset()
	{
		super.reset();
		currentValue = 1.0;
	}
}

class DarkColorModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('r', new ModifierSubValue(255.0));
		subValues.set('g', new ModifierSubValue(255.0));
		subValues.set('b', new ModifierSubValue(255.0));
		currentValue = 1.0;
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		var red = subValues.get('r').value / 255; // so i can get exact values instead of 0.7668676767676768
		var green = subValues.get('g').value / 255;
		var blue = subValues.get('b').value / 255;

		noteData.glowRed *= red;
		noteData.glowGreen *= green;
		noteData.glowBlue *= blue;
	}

	override public function reset()
	{
		super.reset();
		currentValue = 1.0;
	}
}

class FlashColorModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('r', new ModifierSubValue(255.0));
		subValues.set('g', new ModifierSubValue(255.0));
		subValues.set('b', new ModifierSubValue(255.0));
		currentValue = 1.0;
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		var red = subValues.get('r').value / 255; // so i can get exact values instead of 0.7668676767676768
		var green = subValues.get('g').value / 255;
		var blue = subValues.get('b').value / 255;

		noteData.glowRed *= red;
		noteData.glowGreen *= green;
		noteData.glowBlue *= blue;
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		strumMath(noteData, lane, pf);
	}

	override public function reset()
	{
		super.reset();
		currentValue = 1.0;
	}
}

class SuddenModifier extends Modifier {
	override function setupSubValues() {
		subValues.set('noglow', new ModifierSubValue(1.0)); // by default 1
		subValues.set('start', new ModifierSubValue(5.0));
		subValues.set('end', new ModifierSubValue(3.0));
		subValues.set('offset', new ModifierSubValue(0.0));
	}
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var a:Float = FlxMath.remapToRange(curPos, (subValues.get('start').value * -100) + (subValues.get('offset').value * -100),
			(subValues.get('end').value * -100) + (subValues.get('offset').value * -100), 1, 0);
		a = FlxMath.bound(a, 0, 1);

		if (subValues.get('noglow').value >= 1.0) {
			noteData.alpha -= a * currentValue;
			return;
		}

		a *= currentValue;

		if (subValues.get('noglow').value < 0.5) {
			var stealthGlow:Float = a * 2;
			noteData.stealthGlow += FlxMath.bound(stealthGlow, 0, 1); // clamp
		}

		var substractAlpha:Float = FlxMath.bound((a - 0.5) * 2, 0, 1);
		noteData.alpha -= substractAlpha;
    }
}

class HiddenModifier extends Modifier {
	override function setupSubValues() {
		subValues.set('noglow', new ModifierSubValue(1.0)); // by default 1
		subValues.set('start', new ModifierSubValue(5.0));
		subValues.set('end', new ModifierSubValue(3.0));
		subValues.set('offset', new ModifierSubValue(0.0));
	}
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int) {
		var a:Float = FlxMath.remapToRange(curPos, (subValues.get('start').value * -100) + (subValues.get('offset').value * -100),
			(subValues.get('end').value * -100) + (subValues.get('offset').value * -100), 0, 1);
		a = FlxMath.bound(a, 0, 1);

		if (subValues.get('noglow').value >= 1.0) {
			noteData.alpha -= a * currentValue;
			return;
		}

		a *= currentValue;

		if (subValues.get('noglow').value < 0.5) {
			var stealthGlow:Float = a * 2;
			noteData.stealthGlow += FlxMath.bound(stealthGlow, 0, 1); // clamp
		}

		var substractAlpha:Float = FlxMath.bound((a - 0.5) * 2, 0, 1);
		noteData.alpha -= substractAlpha;

		// if (curPos > ((subValues.get('offset').value*-100)-100))
		// {
		//     var hmult = (curPos-(subValues.get('offset').value*-100))/200;
		//     noteData.alpha *=(1-hmult);
		// }
	}
}

class VanishModifier extends Modifier {
	override function setupSubValues() {
		subValues.set('noglow', new ModifierSubValue(1.0)); // by default 1
		subValues.set('start', new ModifierSubValue(4.75));
		subValues.set('end', new ModifierSubValue(1.25));
		subValues.set('offset', new ModifierSubValue(0.0));
		subValues.set('size', new ModifierSubValue(1.95));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int) {
		var midPoint:Float = (subValues.get('start').value * -100) + (subValues.get('offset').value * -100);
		midPoint /= 2;

		var sizeThingy:Float = (subValues.get('size').value * 100) / 2;

		var a:Float = FlxMath.remapToRange(curPos, (subValues.get('start').value * -100)
			+ (subValues.get('offset').value * -100),
			midPoint
			+ sizeThingy
			+ (subValues.get('offset').value * -100), 0, 1);

		a = FlxMath.bound(a, 0, 1);

		var b:Float = FlxMath.remapToRange(curPos, midPoint
			- sizeThingy
			+ (subValues.get('offset').value * -100),
			(subValues.get('end').value * -100)
			+ (subValues.get('offset').value * -100), 0, 1);

		b = FlxMath.bound(b, 0, 1);

		var result:Float = a - b;

		if (subValues.get('noglow').value >= 1.0) {
			noteData.alpha -= result * currentValue;
			return;
		}

		result *= currentValue;

		if (subValues.get('noglow').value < 0.5) {
			var stealthGlow:Float = result * 2;
			noteData.stealthGlow += FlxMath.bound(stealthGlow, 0, 1); // clamp
		}

		var substractAlpha:Float = FlxMath.bound((result - 0.5) * 2, 0, 1);
		noteData.alpha -= substractAlpha;
	}
}

class BlinkModifier extends Modifier {
	override function setupSubValues() {
		subValues.set('noglow', new ModifierSubValue(1.0)); // by default 1
		subValues.set('offset', new ModifierSubValue(0.0));
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int) {
		var a:Float = FlxMath.fastSin((Modifier.beat + (subValues.get('offset').value * -100)) * subValues.get('speed').value * Math.PI) * 2;
		a = FlxMath.bound(a, 0, 1);

		if (subValues.get('noglow').value >= 1.0) {
			noteData.alpha -= a * currentValue;
			return;
		}

		a *= currentValue;

		if (subValues.get('noglow').value < 0.5) {
			var stealthGlow:Float = a * 2;
			noteData.stealthGlow += FlxMath.bound(stealthGlow, 0, 1); // clamp
		}

		var substractAlpha:Float = FlxMath.bound((a - 0.5) * 2, 0, 1);
		noteData.alpha -= substractAlpha;
	}
}
