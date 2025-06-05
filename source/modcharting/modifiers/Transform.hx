package modcharting.modifiers;

import modcharting.PlayfieldRenderer.StrumNoteType;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import flixel.FlxG;
import modcharting.Modifier;
import objects.Note;
import modcharting.Modifier.ModifierSubValue;

//BASE MODS //doesn't use anything else than 1 single value

//Transform: New method to apply basic visuals to notes (Such as X,Y,Z,ANGLE,ALPHA,SCALE,SKEW)

//About ANGLE and ALPHA

//i know "ConfusionModifier" & "stealthModifier" exist, but with the new MT rework i preffer make basic movement mods (most common things) on transform
//As confusion will be reworked to work like notITG (constant) and confusion offset will use radians (angle uses well degrees ofc)

//while for alpha
//alpha and stealth does same thing, stealth uses white fade tho which makes it separated as "Stealth, Dark, Flash" mods exist

//CHANGE LOG (the changes to modifiers)

//[REWORK] = totally overhaul of a modifier
//[UPDATE] = changed something on the modifier
//[RENAME] = rename of a modifier
//[REMOVAL] = a removed modifier
//[NEW] = a new modifier
//[EXTRA] = has nothing to do with modifiers but MT's enviroment.

//HERE CHANGE LIST
/*
    [NEW] MoveModifier: (X,Y,YD,Z)
    -   Modifier ported from notITG, uses percent to move notes instead of value (so 1, would mean a WHOLE note move, not 1 pixel).

    [EXTRA] Backwards Support:
    -   X,Y,YD,Z,ANGLE(X,Y Included),SCALE(X,Y Included),SKEW(X,Y Included),ALPHA modifiers are now on the Backwards Support list.

    [REWORK & RENAME] TransformModifier: (Previously known as StrumsModifier)
    -   Replaces StrumModifier (for better syntaxis) with the removal of "Invert and Flip" since it made those modifiers useless.
    -   Uses all basic mods (X,Y,YD,Z,ANGLE,ANGLED,SCALE,SKEW) as subValues.

    [REWORK & RENAME] NoteOffsetModifier: (Previously known as NotesModifier)
    -   Replaces NotesModifier (for better syntaxis) with the removal of "Invert and Flip" since it made those modifiers useless.
    -   Uses all basic mods (X,Y,YD,Z,ANGLE,ANGLED,SCALE,SKEW) as subValues.

    [REWORK & RENAME] StrumOffsetModifier: (Previously known as LanesModifier)
    -   Replaces LanesModifier (for better syntaxis) with the removal of "Invert and Flip" since it made those modifiers useless.
    -   Uses all basic mods (X,Y,YD,Z,ANGLE,ANGLED,SCALE,SKEW) as subValues.

    [NEW] SkewFieldModifier:
    -   New modifier ported from notITG. (Includes X,Y variants ONLY).
    -   Has 1 subValue:
        + CenterOffset (This one changes the offset of where the skew should take it's base of)

    [REMOVAL] MISC MODS:
    -   MISC MODS were all those mods that were helpers from others (skewOffsetX) as new 3D render does not use them.
*/


class TransformModifier extends Modifier
{
    var daswitch = 1;
    override function setupSubValues()
    {
        baseValue = 0.0;
        currentValue = 1.0; //By default enabled (can be turned off but won't work until turned back on)
        subValues.set('x', new ModifierSubValue(0.0));
        subValues.set('y', new ModifierSubValue(0.0));
        subValues.set('yD', new ModifierSubValue(0.0)); //Controls scroll movement (if downscroll, goes up, otherwise it goes down like normal Y)
        subValues.set('z', new ModifierSubValue(0.0));

        subValues.set('angle', new ModifierSubValue(0.0));
        subValues.set('angleD', new ModifierSubValue(0.0)); //similar to yD, this one changes angle bettwen scrolls for more proper visuals (intros and etc)
        subValues.set('anglex', new ModifierSubValue(0.0));
        subValues.set('angley', new ModifierSubValue(0.0));

        subValues.set('alpha', new ModifierSubValue(0.0));

        subValues.set('scale', new ModifierSubValue(1.0)); //scale is set to 1 by default (so notes does not start fucking invisible)
        subValues.set('scalex', new ModifierSubValue(1.0));
        subValues.set('scaley', new ModifierSubValue(1.0));

        subValues.set('skew', new ModifierSubValue(0.0));
        subValues.set('skewx', new ModifierSubValue(0.0));
        subValues.set('skewy', new ModifierSubValue(0.0));
    }

    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        if (instance != null) if (ModchartUtil.getDownscroll(instance)) daswitch = -1;

        noteData.x += subValues.get('x').value;
        noteData.y += subValues.get('y').value + (subValues.get('yD').value * daswitch);
        noteData.z += subValues.get('z').value;

        noteData.angle += subValues.get('angle').value + (subValues.get('angleD').value * daswitch);
        noteData.angleX += subValues.get('anglex').value;
        noteData.angleY += subValues.get('angley').value;

        noteData.alpha *= 1 - subValues.get('alpha').value; //alpha to 1 means it's invisible, otherwise it's visible

        noteData.scaleX += (subValues.get('scalex').value-1) + (subValues.get('scale').value-1);
        noteData.scaleY += (subValues.get('scaley').value-1) + (subValues.get('scale').value-1);
        
        noteData.skewX += subValues.get('skewx').value + subValues.get('skew').value;
        noteData.skewY += subValues.get('skewy').value + subValues.get('skew').value;
    }

    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }

    override function reset()
    {
        super.reset();
        baseValue = 0.0;
        currentValue = 1.0;
    }
}

//Same as Transform but exclusive for notes
class NoteOffsetModifier extends Modifier
{
    var daswitch = 1;
    override function setupSubValues()
    {
        baseValue = 0.0;
        currentValue = 1.0; //By default enabled (can be turned off but won't work until turned back on)
        subValues.set('x', new ModifierSubValue(0.0));
        subValues.set('y', new ModifierSubValue(0.0));
        subValues.set('yD', new ModifierSubValue(0.0)); //Controls scroll movement (if downscroll, goes up, otherwise it goes down like normal Y)
        subValues.set('z', new ModifierSubValue(0.0));

        subValues.set('angle', new ModifierSubValue(0.0));
        subValues.set('angleD', new ModifierSubValue(0.0)); //similar to yD, this one changes angle bettwen scrolls for more proper visuals (intros and etc)
        subValues.set('anglex', new ModifierSubValue(0.0));
        subValues.set('angley', new ModifierSubValue(0.0));

        subValues.set('alpha', new ModifierSubValue(0.0));

        subValues.set('scale', new ModifierSubValue(1.0)); //scale is set to 1 by default (so notes does not start fucking invisible)
        subValues.set('scalex', new ModifierSubValue(1.0));
        subValues.set('scaley', new ModifierSubValue(1.0));

        subValues.set('skew', new ModifierSubValue(0.0));
        subValues.set('skewx', new ModifierSubValue(0.0));
        subValues.set('skewy', new ModifierSubValue(0.0));
    }

    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        if (instance != null) if (ModchartUtil.getDownscroll(instance)) daswitch = -1;

        noteData.x += subValues.get('x').value;
        noteData.y += subValues.get('y').value + (subValues.get('yD').value * daswitch);
        noteData.z += subValues.get('z').value;

        noteData.angle += subValues.get('angle').value + (subValues.get('angleD').value * daswitch);
        noteData.angleX += subValues.get('anglex').value;
        noteData.angleY += subValues.get('angley').value;

        noteData.alpha *= 1 - subValues.get('alpha').value; //alpha to 1 means it's invisible, otherwise it's visible

        noteData.scaleX += (subValues.get('scalex').value-1) + (subValues.get('scale').value-1);
        noteData.scaleY += (subValues.get('scaley').value-1) + (subValues.get('scale').value-1);
        
        noteData.skewX += subValues.get('skewx').value + subValues.get('skew').value;
        noteData.skewY += subValues.get('skewy').value + subValues.get('skew').value;
    }

    override function reset()
    {
        super.reset();
        baseValue = 0.0;
        currentValue = 1.0;
    }
}

//Same as Transform but exclusive for strums
class StrumOffsetModifier extends Modifier
{
    var daswitch = 1;
    override function setupSubValues()
    {
        baseValue = 0.0;
        currentValue = 1.0; //By default enabled (can be turned off but won't work until turned back on)
        subValues.set('x', new ModifierSubValue(0.0));
        subValues.set('y', new ModifierSubValue(0.0));
        subValues.set('yD', new ModifierSubValue(0.0)); //Controls scroll movement (if downscroll, goes up, otherwise it goes down like normal Y)
        subValues.set('z', new ModifierSubValue(0.0));

        subValues.set('angle', new ModifierSubValue(0.0));
        subValues.set('angleD', new ModifierSubValue(0.0)); //similar to yD, this one changes angle bettwen scrolls for more proper visuals (intros and etc)
        subValues.set('anglex', new ModifierSubValue(0.0));
        subValues.set('angley', new ModifierSubValue(0.0));

        subValues.set('alpha', new ModifierSubValue(0.0));

        subValues.set('scale', new ModifierSubValue(1.0)); //scale is set to 1 by default (so notes does not start fucking invisible)
        subValues.set('scalex', new ModifierSubValue(1.0));
        subValues.set('scaley', new ModifierSubValue(1.0));

        subValues.set('skew', new ModifierSubValue(0.0));
        subValues.set('skewx', new ModifierSubValue(0.0));
        subValues.set('skewy', new ModifierSubValue(0.0));
    }

    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        if (instance != null) if (ModchartUtil.getDownscroll(instance)) daswitch = -1;

        noteData.x += subValues.get('x').value;
        noteData.y += subValues.get('y').value + (subValues.get('yD').value * daswitch);
        noteData.z += subValues.get('z').value;

        noteData.angle += subValues.get('angle').value + (subValues.get('angleD').value * daswitch);
        noteData.angleX += subValues.get('anglex').value;
        noteData.angleY += subValues.get('angley').value;

        noteData.alpha *= 1 - subValues.get('alpha').value; //alpha to 1 means it's invisible, otherwise it's visible

        noteData.scaleX += (subValues.get('scalex').value-1) + (subValues.get('scale').value-1);
        noteData.scaleY += (subValues.get('scaley').value-1) + (subValues.get('scale').value-1);
        
        noteData.skewX += subValues.get('skewx').value + subValues.get('skew').value;
        noteData.skewY += subValues.get('skewy').value + subValues.get('skew').value;
    }

    override function reset()
    {
        super.reset();
        baseValue = 0.0;
        currentValue = 1.0;
    }
}

class MoveXModifier extends Modifier 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.x += NoteMovement.arrowSizes[lane] * currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class MoveYModifier extends Modifier 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.y += NoteMovement.arrowSizes[lane] * currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class MoveYDModifier extends Modifier //similar to Y but this one changes on default scroll (down/up)
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var daswitch = 1;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                daswitch = -1;
        noteData.y += NoteMovement.arrowSizes[lane] * currentValue * daswitch;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}
class MoveZModifier extends Modifier 
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.z += NoteMovement.arrowSizes[lane] * currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}

//STORAGE OF OLDER MODS (as i said, MT rework won't add these on modchart editor's list, but they will be kept for backwards support.)

//If any modchart breaks due a modifier removal or change (Confusion's case), just fix it, change the modifier and thats it.


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

        noteData.skewX += subValues.get('x').value;
        noteData.skewY += subValues.get('y').value;

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
        noteData.skewX += currentValue;
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
        noteData.skewY += currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf);
    }
}


//NEW MODIFIERS

//SkewField: skews the whole field, looking like you just skewed the camera, silly.

//(fun fact: skewfield recreates "IncomingAngle" math on noteMath, ik i can just use incoming angle, but its silly :b)

//SkewFieldModifier itself doesn't exist as it breaks the whole lane
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

/*

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
*/