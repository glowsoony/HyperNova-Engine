package mikolka.stages.standard;

import objects.BGSprite;
import flixel.util.FlxAxes;

class PlaceHolder extends BaseStage
{
    override function create()
    {
        final bg:BGSprite = new BGSprite('DefaultBackGround', -605, -150, 0.5, 0.5);
        bg.scale.x = 0.7;
        bg.scale.y = 0.7;
        bg.screenCenter(Y);
        add(bg);
    }
}