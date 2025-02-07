package modcharting.modifiers;

import modcharting.PlayfieldRenderer.StrumNoteType;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import flixel.FlxG;
import modcharting.Modifier;
import objects.Note;
import modcharting.Modifier.ModifierSubValue;

class ConfusionModifier extends Modifier //note angle
{
    override function setupSubValues()
    {
        subValues.set('force', new ModifierSubValue(1.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var scrollSwitch = -1;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                scrollSwitch *= -1;

        if (subValues.get('force').value >= 0.5) noteData.angle += currentValue;
        else noteData.angle += currentValue * scrollSwitch; //forced as default now to fix upscroll and downscroll modcharts that uses angle (no need for z and x, just angle and y)
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class ConfusionXModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.angleX += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class ConfusionYModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.angleY += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}


class ConfusionConstantModifier extends Modifier //note angle
{
    override function setupSubValues()
    {
        subValues.set('forced', new ModifierSubValue(1.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var scrollSwitch = -1;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                scrollSwitch *= -1;

        var mathToUse = 0.0;
        if (subValues.get('forced').value >= 0.5) mathToUse = Modifier.beat;
        else mathToUse = Modifier.beat * scrollSwitch;

        noteData.angle += mathToUse * currentValue * 100; //forced as default now to fix upscroll and downscroll modcharts that uses angle (no need for z and x, just angle and y)
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class ConfusionConstantXModifier extends Modifier //note angle
{
    override function setupSubValues()
    {
        subValues.set('forced', new ModifierSubValue(1.0));
        subValues.set('useOld', new ModifierSubValue(0.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var scrollSwitch = -1;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                scrollSwitch *= -1;

        var mathToUse = 0.0;
        var result = 0.0;
        if (subValues.get('forced').value >= 0.5) mathToUse = Modifier.beat;
        else mathToUse = Modifier.beat * scrollSwitch;

        result = mathToUse * currentValue * 100;

        if (subValues.get('useOld').value >= 0.5) noteData.scaleX *= FlxMath.fastCos(result * (Math.PI / 180));
        else noteData.angleY += result;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class ConfusionConstantYModifier extends Modifier //note angle
{
    override function setupSubValues()
    {
        subValues.set('forced', new ModifierSubValue(1.0));
        subValues.set('useOld', new ModifierSubValue(0.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var scrollSwitch = -1;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                scrollSwitch *= -1;

        var mathToUse = 0.0;
        var result = 0.0;
        if (subValues.get('forced').value >= 0.5) mathToUse = Modifier.beat;
        else mathToUse = Modifier.beat * scrollSwitch;

        result = mathToUse * currentValue * 100;

        if (subValues.get('useOld').value >= 0.5) noteData.scaleY *= FlxMath.fastCos(result * (Math.PI / 180));
        else noteData.angleX += result;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}

class DizzyModifier extends Modifier
{
    override function setupSubValues()
    {
        subValues.set('forced', new ModifierSubValue(0.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        if (subValues.get('forced').value >= 0.5) noteData.angle += currentValue*(Conductor.songPosition*0.001);
        else noteData.angle += currentValue*curPos;
    }
}
class TwirlModifier extends Modifier
{
    override function setupSubValues()
    {
        subValues.set('forced', new ModifierSubValue(0.0));
        subValues.set('useOld', new ModifierSubValue(0.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var mathToUse = 0.0;
        var result = 0.0;
        if (subValues.get('forced').value >= 0.5) mathToUse = Conductor.songPosition*0.001;
        else mathToUse = curPos/2.0;

        result = mathToUse * currentValue;

        if (subValues.get('useOld').value >= 0.5) noteData.scaleX *= FlxMath.fastCos(result * (Math.PI / 180));
        else noteData.angleY += result;
    }
}
class RollModifier extends Modifier
{
    override function setupSubValues()
    {
        subValues.set('forced', new ModifierSubValue(0.0));
        subValues.set('useOld', new ModifierSubValue(0.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var mathToUse = 0.0;
        var result = 0.0;
        if (subValues.get('forced').value >= 0.5) mathToUse = Conductor.songPosition*0.001;
        else mathToUse = curPos/2.0;

        result = mathToUse * currentValue;

        if (subValues.get('useOld').value >= 0.5) noteData.scaleY *= FlxMath.fastCos(result * (Math.PI / 180));
        else noteData.angleX += result;
    }
}