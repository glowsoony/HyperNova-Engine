package modcharting.modifiers;

import modcharting.PlayfieldRenderer.StrumNoteType;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import flixel.FlxG;
import modcharting.Modifier;
import objects.Note;
import modcharting.Modifier.ModifierSubValue;

//BASE MODS //doesn't use anything else than "currentValue"
class XModifier extends Modifier 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.x += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class YModifier extends Modifier 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.y += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class YDModifier extends Modifier //similar to Y but this one changes on default scroll (down/up)
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var daswitch = 1;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                daswitch = -1;
        noteData.y += currentValue * daswitch;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class ZModifier extends Modifier 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.z += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}

class ScaleModifier extends Modifier
{
    override function setupSubValues()
    {
        baseValue = 1.0;
        currentValue = 1.0;
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.scaleX *= currentValue;
        noteData.scaleY *= currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class ScaleXModifier extends Modifier
{
    override function setupSubValues()
    {
        baseValue = 1.0;
        currentValue = 1.0;
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.scaleX *= currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class ScaleYModifier extends Modifier
{
    override function setupSubValues()
    {
        baseValue = 1.0;
        currentValue = 1.0;
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.scaleY *= currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}

class SkewModifier extends Modifier
{
    override function setupSubValues()
    {
        subValues.set('x', new ModifierSubValue(0.0));
        subValues.set('y', new ModifierSubValue(0.0));
        subValues.set('xDmod', new ModifierSubValue(0.0));
        subValues.set('yDmod', new ModifierSubValue(0.0));
        currentValue = 1.0;
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var daswitch = -1;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                daswitch = 1;

        noteData.skewX += subValues.get('x').value * daswitch;
        noteData.skewY += subValues.get('y').value * daswitch;

        noteData.skewX += subValues.get('xDmod').value * daswitch;
        noteData.skewY += subValues.get('yDmod').value * daswitch;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
    override function reset()
    {
        super.reset();
        currentValue = 1.0;
    }
}
class SkewXModifier extends Modifier
{
    override function setupSubValues()
    {
        baseValue = 0.0;
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var daswitch = -1;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                daswitch = 1;
        noteData.skewX += currentValue * daswitch;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}
class SkewYModifier extends Modifier
{
    override function setupSubValues()
    {
        baseValue = 0.0;
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var daswitch = -1;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                daswitch = 1;
        noteData.skewY += currentValue * daswitch;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}
class SkewFieldXModifier extends Modifier
{
    override function setupSubValues()
    {
        baseValue = 0.0;
        subValues.set('centerOffset', new ModifierSubValue(0.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int){
        var centerPoint:Float = (FlxG.height / 2) + subValues.get('centerOffset').value;

        var offsetY:Float = NoteMovement.arrowSizes[lane]/2;

        var finalPos:Float = (noteData.y + offsetY) - centerPoint;
        
        noteData.x += finalPos * Math.tan(currentValue * FlxAngle.TO_RAD);

        noteData.skewX += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int){
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class SkewFieldYModifier extends Modifier
{
    override function setupSubValues()
    {
        baseValue = 0.0;
        subValues.set('centerOffset', new ModifierSubValue(0.0));
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int){
        var centerPoint:Float = (FlxG.width / 2) + subValues.get('centerOffset').value;

        var offsetX:Float = NoteMovement.arrowSizes[lane]/2;

        var finalPos:Float = (noteData.x + offsetX) - centerPoint;
        
        noteData.y += finalPos * Math.tan(currentValue * FlxAngle.TO_RAD);

        noteData.skewY += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int){
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}

//HELPERS //these mods are just made to make "laneSpecific" mods way easier than making each mod for every note.

class NotesModifier extends Modifier
{
    override function setupSubValues()
    {
        baseValue = 0.0;
        currentValue = 1.0;
        subValues.set('x', new ModifierSubValue(0.0));
        subValues.set('y', new ModifierSubValue(0.0));
        subValues.set('yD', new ModifierSubValue(0.0));
        subValues.set('angle', new ModifierSubValue(0.0));
        subValues.set('z', new ModifierSubValue(0.0));
        subValues.set('skewx', new ModifierSubValue(0.0));
        subValues.set('skewy', new ModifierSubValue(0.0));
        subValues.set('invert', new ModifierSubValue(0.0));
        subValues.set('flip', new ModifierSubValue(0.0));
    }

    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var daswitch = 1;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                daswitch = -1;

        noteData.x += subValues.get('x').value;
        noteData.y += subValues.get('y').value;
        noteData.y += subValues.get('yD').value * daswitch;
        noteData.angle += subValues.get('angle').value;
        noteData.z += subValues.get('z').value;
        noteData.skewX += subValues.get('skewx').value * -daswitch;
        noteData.skewY += subValues.get('skewy').value * -daswitch;

        noteData.x += Modifier.ModifierMath.Invert(lane) * subValues.get('invert').value;

        noteData.x += NoteMovement.arrowSizes[lane] * Modifier.ModifierMath.Flip(lane) * subValues.get('flip').value;
        noteData.x -= NoteMovement.arrowSizes[lane] * subValues.get('flip').value;
    }

    override function reset()
    {
        super.reset();
        baseValue = 0.0;
        currentValue = 1.0;
    }
}
class LanesModifier extends Modifier
{
    override function setupSubValues()
    {
        baseValue = 0.0;
        currentValue = 1.0;
        subValues.set('x', new ModifierSubValue(0.0));
        subValues.set('y', new ModifierSubValue(0.0));
        subValues.set('yD', new ModifierSubValue(0.0));
        subValues.set('angle', new ModifierSubValue(0.0));
        subValues.set('z', new ModifierSubValue(0.0));
        subValues.set('skewx', new ModifierSubValue(0.0));
        subValues.set('skewy', new ModifierSubValue(0.0));
    }

    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        var daswitch = 1;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                daswitch = -1;

        noteData.x += subValues.get('x').value;
        noteData.y += subValues.get('y').value;
        noteData.y += subValues.get('yD').value * daswitch;
        noteData.angle += subValues.get('angle').value;
        noteData.z += subValues.get('z').value;
        noteData.skewX += subValues.get('skewx').value * -daswitch;
        noteData.skewY += subValues.get('skewy').value * -daswitch;
    }

    override function reset()
    {
        super.reset();
        baseValue = 0.0;
        currentValue = 1.0;
    }
}
class StrumsModifier extends Modifier
{
    override function setupSubValues()
    {
        baseValue = 0.0;
        currentValue = 1.0;
        subValues.set('x', new ModifierSubValue(0.0));
        subValues.set('y', new ModifierSubValue(0.0));
        subValues.set('yD', new ModifierSubValue(0.0));
        subValues.set('angle', new ModifierSubValue(0.0));
        subValues.set('z', new ModifierSubValue(0.0));
        subValues.set('skewx', new ModifierSubValue(0.0));
        subValues.set('skewy', new ModifierSubValue(0.0));
        subValues.set('invert', new ModifierSubValue(0.0));
        subValues.set('flip', new ModifierSubValue(0.0));
    }

    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var daswitch = 1;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                daswitch = -1;

        noteData.x += subValues.get('x').value;
        noteData.y += subValues.get('y').value;
        noteData.y += subValues.get('yD').value * daswitch;
        noteData.angle += subValues.get('angle').value;
        noteData.z += subValues.get('z').value;
        noteData.skewX += subValues.get('skewx').value * -daswitch;
        noteData.skewY += subValues.get('skewy').value * -daswitch;

        noteData.x += Modifier.ModifierMath.Invert(lane) * subValues.get('invert').value;

        noteData.x += NoteMovement.arrowSizes[lane] * Modifier.ModifierMath.Flip(lane) * subValues.get('flip').value;
        noteData.x -= NoteMovement.arrowSizes[lane] * subValues.get('flip').value;
    }

    override function reset()
    {
        super.reset();
        baseValue = 0.0;
        currentValue = 1.0;
    }
    
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}


//MISC MODS //mods that don't change anything by themselves, but helps other mods to change their visuals

class PivotXOffsetModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.pivotOffsetX += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}
class PivotYOffsetModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.pivotOffsetY += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}
class PivotZOffsetModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.pivotOffsetZ += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}

class SkewXOffsetModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.skewX_offset += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}
class SkewYOffsetModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.skewY_offset += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}
class SkewZOffsetModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.skewZ_offset += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}

class FovXOffsetModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.fovOffsetX += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}
class FovYOffsetModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.fovOffsetY += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}

class CullNTModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        if (currentValue == 0){
            noteData.cullMode = "none";
        }else if (currentValue > 0){
            noteData.cullMode = "positive";
        }else if (currentValue < 0){
            noteData.cullMode = "negative";
        }else if (currentValue >= 2){
            noteData.cullMode = "always_positive";
        }else if (currentValue <= -2){
            noteData.cullMode = "always_negative";
        }
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}

class CullNotesModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        if (currentValue == 0){
            noteData.cullMode = "none";
        }else if (currentValue > 0){
            noteData.cullMode = "positive";
        }else if (currentValue < 0){
            noteData.cullMode = "negative";
        }else if (currentValue >= 2){
            noteData.cullMode = "always_positive";
        }else if (currentValue <= -2){
            noteData.cullMode = "always_negative";
        }
    }
}

class CullTargetsModifier extends Modifier
{
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        if (currentValue == 0){
            noteData.cullMode = "none";
        }else if (currentValue > 0){
            noteData.cullMode = "positive";
        }else if (currentValue < 0){
            noteData.cullMode = "negative";
        }else if (currentValue >= 2){
            noteData.cullMode = "always_positive";
        }else if (currentValue <= -2){
            noteData.cullMode = "always_negative";
        }
    }
}