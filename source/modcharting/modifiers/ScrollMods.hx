package modcharting.modifiers;

import modcharting.PlayfieldRenderer.StrumNoteType;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import flixel.FlxG;
import modcharting.Modifier;
import objects.Note;
import modcharting.Modifier.ModifierSubValue;

//CHANGE LOG (the changes to modifiers)

//[REWORK] = totally overhaul of a modifier
//[UPDATE] = changed something on the modifier
//[RENAME] = rename of a modifier
//[REMOVAL] = a removed modifier
//[NEW] = a new modifier
//[EXTRA] = has nothing to do with modifiers but MT's enviroment.

//HERE CHANGE LIST
/*
    [RENAME] WaveModifier: (Previously known as WaveingModifier)
    -   Renamed to make a cleaner look bettwen notITG and MT.

    [RENAME] JumpStrumsModifier: (Previously known as JumpTargetModifier)
    -   Renamed to keep order with other mods (as other uses strum and not target)
*/

class LinearXModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    { 
        noteData.x += curPos * currentValue; //don't mind me i just figured it out
    }
}
class LinearYModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var ud = false;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                ud = true;
        noteData.y += (curPos * currentValue) * (ud ? -1 : 1);
    }
}
class LinearZModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    { 
        noteData.z += curPos * currentValue; //don't mind me i just figured it out
    }
}

class IncomingAngleModifier extends Modifier 
{
    override function setupSubValues()
    {
        subValues.set('x', new ModifierSubValue(0.0));
        subValues.set('y', new ModifierSubValue(0.0));
        currentValue = 1.0;
    }
    override function incomingAngleMath(lane:Int, curPos:Float, pf:Int)
    {
        return [subValues.get('x').value, subValues.get('y').value];
    }
    override function reset()
    {
        super.reset();
        currentValue = 1.0; //the code that stop the mod from running gets confused when it resets in the editor i guess??
    }
}

class SpeedModifier extends Modifier
{
    override function setupSubValues()
    {
        baseValue = 1.0;
        currentValue = 1.0;
    }
    override function curPosMath(lane:Int, curPos:Float, pf:Int)
    {
        return curPos * currentValue;
    }
}

class BoostModifier extends Modifier
{
    override function setupSubValues()
    {
        subValues.set('offset', new ModifierSubValue(1.0));
    }
    override function curPosMath(lane:Int, curPos:Float, pf:Int)
    {
        var yOffset:Float = 0;

        var speed = renderer.getCorrectScrollSpeed() * subValues.get('offset').value;

        var fYOffset = -curPos / speed;
        var fEffectHeight = FlxG.height;
        var fNewYOffset = fYOffset * 1.5 / ((fYOffset+fEffectHeight/1.2)/fEffectHeight);
        var fBrakeYAdjust = (currentValue) * (fNewYOffset - fYOffset);
        fBrakeYAdjust = FlxMath.bound(fBrakeYAdjust, -400, 400 ); //clamp
        
        yOffset -= fBrakeYAdjust*speed;

        return curPos+yOffset;
    }
}

class BrakeModifier extends Modifier
{
    override function setupSubValues()
    {
        subValues.set('offset', new ModifierSubValue(1.0));
    }
    override function curPosMath(lane:Int, curPos:Float, pf:Int)
    {
        var yOffset:Float = 0;

        var speed = renderer.getCorrectScrollSpeed() * subValues.get('offset').value;

        var fYOffset = -curPos / speed;
		var fEffectHeight = FlxG.height;
		var fScale = FlxMath.remapToRange(fYOffset, 0, fEffectHeight, 0, 1); //scale
		var fNewYOffset = fYOffset * fScale; 
		var fBrakeYAdjust = currentValue * (fNewYOffset - fYOffset);
		fBrakeYAdjust = FlxMath.bound( fBrakeYAdjust, -400, 400 ); //clamp
        
		yOffset -= fBrakeYAdjust*speed;

        return curPos+yOffset;
    }
}
class BoomerangModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    { 
        var scrollSwitch = -1;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                scrollSwitch *= -1;

        noteData.y += (FlxMath.fastSin((curPos/-700)) * 400 + (curPos/3.5))*scrollSwitch * (-currentValue);
        noteData.alpha *= FlxMath.bound(1-(curPos/-600-3.5), 0, 1);
    }
    override function curPosMath(lane:Int, curPos:Float, pf:Int)
    {
        return curPos * 0.75;
    }
}
class WaveModifier extends Modifier
{
    override function setupSubValues()
    {
        subValues.set('multiplier', new ModifierSubValue(1.0));
    }
    // override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    // { 
    //     var distance = curPos;
    //     noteData.y += (FlxMath.fastSin(distance / 38 * subValues.get('multiplier').value * 0.2)*50) * currentValue; //don't mind me i just figured it out
    // }
    // override function noteDistMath(noteDist:Float, lane:Int, curPos:Float, pf:Int)
    // {
    //     return noteDist * (0.4+((FlxMath.fastSin(curPos*0.007)*0.1) * currentValue));
    // }
    override function curPosMath(lane:Int, curPos:Float, pf:Int)
    {
        curPos += (FlxMath.fastSin(-curPos / 38.0 * (subValues.get('multiplier').value*0.75) * 0.2)*100) * (currentValue*2);
    
        return curPos*0.75;
    }
}

class JumpModifier extends Modifier //custom thingy i made //ended just being driven OMG LMAO
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        strumMath(noteData, lane, pf);
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        var beatVal = Modifier.beat - Math.floor(Modifier.beat); //should give decimal

        var scrollSwitch = 1;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                scrollSwitch = -1;

        

        noteData.y += (beatVal*(Conductor.stepCrochet*currentValue))*renderer.getCorrectScrollSpeed()*0.45*scrollSwitch;
    }
}
class JumpStrumsModifier extends Modifier
{
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        var beatVal = Modifier.beat - Math.floor(Modifier.beat); //should give decimal

        var scrollSwitch = 1;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                scrollSwitch = -1;

        

        noteData.y += (beatVal*(Conductor.stepCrochet*currentValue))*renderer.getCorrectScrollSpeed()*0.45*scrollSwitch;
    }
}
class JumpNotesModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var beatVal = Modifier.beat - Math.floor(Modifier.beat); //should give decimal

        var scrollSwitch = 1;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                scrollSwitch = -1;

        

        noteData.y += (beatVal*(Conductor.stepCrochet*currentValue))*renderer.getCorrectScrollSpeed()*0.45*scrollSwitch;
    }
}
class DrivenModifier extends Modifier
{
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        var scrollSpeed = renderer.getCorrectScrollSpeed();

        var scrollSwitch = 1;
        if (instance != null)
            if (ModchartUtil.getDownscroll(instance))
                scrollSwitch = -1;

        
        noteData.y += 0.45 * scrollSpeed * scrollSwitch * currentValue;
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}

class TimeStopModifier extends Modifier
{
    override function setupSubValues()
    {
        subValues.set('stop', new ModifierSubValue(0.0));
        subValues.set('speed', new ModifierSubValue(1.0));
        subValues.set('continue', new ModifierSubValue(0.0));
    }
    override function curPosMath(lane:Int, curPos:Float, pf:Int)
    {
        if (curPos <= (subValues.get('stop').value*-1000))
            {
                curPos = (subValues.get('stop').value*-1000) + (curPos*(subValues.get('speed').value/100));
            }
        return curPos;
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        if (curPos <= (subValues.get('stop').value*-1000))
        {
            curPos = (subValues.get('stop').value*-1000) + (curPos*(subValues.get('speed').value/100));
        } 
        else if (curPos <= (subValues.get('continue').value*-100))
        {
            var a = ((subValues.get('continue').value*100)-Math.abs(curPos))/((subValues.get('continue').value*100)+(subValues.get('stop').value*-1000));
        }else{
            //yep, nothing here lmao
        }
    }
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {
        noteMath(noteData, lane, 0, pf); //just reuse same thing
    }
}

class ParalysisModifier extends Modifier
{
    override function setupSubValues()
    {
        subValues.set('amplitude', new ModifierSubValue(1.0));
    }
    override function curPosMath(lane:Int, curPos:Float, pf:Int)
    {
        var beat = (Conductor.songPosition/Conductor.crochet/2);
        var fixedperiod = (Math.floor(beat)*Conductor.crochet*2);
        var strumTime = (Conductor.songPosition - (curPos / PlayState.SONG.speed));
        return ((fixedperiod - strumTime)*PlayState.SONG.speed/4)*subValues.get('amplitude').value;
    }  
}

class CenterModifier extends Modifier
{
    var differenceBetween:Float = 0;
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {  
        var screenCenter:Float = (FlxG.height/2) - (NoteMovement.arrowSizes[lane]/2);
       differenceBetween = noteData.y - screenCenter;
       noteData.y -= currentValue * differenceBetween;
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        noteData.y -= currentValue * differenceBetween;  
    }
}
class Center2Modifier extends Modifier
{
    override function strumMath(noteData:NotePositionData, lane:Int, pf:Int)
    {  
        var screenCenter:Float = (FlxG.height/2) - (NoteMovement.arrowSizes[lane]/2);
        var differenceBetween:Float = noteData.y - screenCenter;
       noteData.y -= currentValue * differenceBetween;
    }
    override function noteMath(noteData:NotePositionData, lane:Int, curPos:Float, pf:Int)
    {
        strumMath(noteData, lane, pf);
    }
}