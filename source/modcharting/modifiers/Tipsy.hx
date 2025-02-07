package modcharting.modifiers;

import modcharting.PlayfieldRenderer.StrumNoteType;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import flixel.FlxG;
import modcharting.Modifier;
import objects.Note;
import modcharting.Modifier.ModifierSubValue;

class Tipsy extends Modifier //My idea is clever, make this more simple to use
{
    override function setupSubValues()
    {
        subValues.set('period', new ModifierSubValue(1.0));
        subValues.set('offset', new ModifierSubValue(0.0));
        subValues.set('speed', new ModifierSubValue(1.0));
        subValues.set('timertype', new ModifierSubValue(0.0));
    }

    public static function Tipsy(lane:Int, speed:Float):Float
    {
        return (FlxMath.fastCos( (Conductor.songPosition*0.001 *(1.2) + 
        (lane%NoteMovement.keyCount)*(2.0)) * (5) * speed*0.2 ) * Note.swagWidth*0.4);
    }

    function tanTipsyMath(lane:Int, curPos:Float):Float
    {
        var time:Float = (subValues.get('timertype').value >= 0.5 ? Modifier.beat : Conductor.songPosition * 0.001 * 1.2);
        time *= subValues.get('speed').value;
        time += subValues.get('offset').value;
    
        return currentValue * (Math.tan((time + ((lane) % NoteMovement.keyCount) * subValues.get('period').value) * (5) * 1 * 0.2) * Note.swagWidth * 0.5);
    }

    function tipsyMath(lane:Int, curPos:Float):Float
    {
        var time:Float = (subValues.get('timertype').value >= 0.5 ? Modifier.beat : Conductor.songPosition * 0.001 * 1.2);
        time *= subValues.get('speed').value;
        time += subValues.get('offset').value;
    
        return currentValue * (FlxMath.fastCos((time + ((lane) % NoteMovement.keyCount) * subValues.get('period').value) * (5) * 1 * 0.2) * Note.swagWidth * 0.5);
    } 
}

class TipsyXModifier extends Tipsy
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.x += tipsyMath(lane, curPos);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class TipsyYModifier extends Tipsy
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.y += tipsyMath(lane, curPos);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class TipsyZModifier extends Tipsy 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.z += tipsyMath(lane, curPos);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf)
    }
}
class TipsyAngleModifier extends Tipsy 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.angle += tipsyMath(lane, curPos);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class TipsyScaleModifier extends Tipsy 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.scaleX *= tipsyMath(lane, curPos) * 0.001;
        noteData.scaleY *= tipsyMath(lane, curPos) * 0.001;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class TipsyScaleXModifier extends Tipsy 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.scaleX *= tipsyMath(lane, curPos) * 0.001;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class TipsyScaleYModifier extends Tipsy 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.scaleY *= tipsyMath(lane, curPos) * 0.001;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class TipsySkewModifier extends Tipsy 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.skewX += tipsyMath(lane, curPos);
        noteData.skewY += tipsyMath(lane, curPos);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class TipsySkewXModifier extends Tipsy 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.skewX += tipsyMath(lane, curPos);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class TipsySkewYModifier extends Tipsy 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.skewY += tipsyMath(lane, curPos);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}

class TanTipsyXModifier extends Tipsy
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.x += tanTipsyMath(lane, curPos);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class TanTipsyYModifier extends Tipsy
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.y += tanTipsyMath(lane, curPos);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class TanTipsyZModifier extends Tipsy
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.z += tanTipsyMath(lane, curPos);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class TanTipsyAngleModifier extends Tipsy
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.angle += tanTipsyMath(lane, curPos);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class TanTipsyScaleModifier extends Tipsy
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.scaleX *= tanTipsyMath(lane, curPos) * 0.001;
        noteData.scaleY *= tanTipsyMath(lane, curPos) * 0.001;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class TanTipsyScaleXModifier extends Tipsy
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.scaleX *= tanTipsyMath(lane, curPos) * 0.001;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class TanTipsyScaleYModifier extends Tipsy
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.scaleY *= tanTipsyMath(lane, curPos) * 0.001;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class TanTipsySkewModifier extends Tipsy
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.skewX += tanTipsyMath(lane, curPos);
        noteData.skewY += tanTipsyMath(lane, curPos);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class TanTipsySkewXModifier extends Tipsy
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.skewX += tanTipsyMath(lane, curPos);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class TanTipsySkewYModifier extends Tipsy
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.skewY += tanTipsyMath(lane, curPos);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}