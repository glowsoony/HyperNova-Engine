package modcharting.modifiers;

class ShakyNotesModifier extends Modifier
{
	override function setupSubValues()
	{
		subValues.set('speed', new ModifierSubValue(1.0));
	}

	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += FlxMath.fastSin(500)
			+ currentValue * (Math.cos(Conductor.songPosition * 4 * 0.2) + ((lane % NoteMovement.keyCount) * 0.2) - 0.002) * (Math.sin(100
				- (120 * subValues.get('speed').value * 0.4))) /** (BeatXModifier.getShift(noteData, lane, curPos, pf) / 2)*/;

		noteData.y += FlxMath.fastSin(500)
			+ currentValue * (Math.cos(Conductor.songPosition * 8 * 0.2) + ((lane % NoteMovement.keyCount) * 0.2) - 0.002) * (Math.sin(100
				- (120 * subValues.get('speed').value * 0.4))) /** (BeatXModifier.getShift(noteData, lane, curPos, pf) / 2)*/;
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}

class ShakeNotesModifier extends Modifier
{
	override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
	{
		noteData.x += FlxMath.fastSin(0.1) * (currentValue * FlxG.random.int(1, 20));
		noteData.y += FlxMath.fastSin(0.1) * (currentValue * FlxG.random.int(1, 20));
	}

	override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
	{
		noteMath(noteData, lane, 0, pf);
	}
}
