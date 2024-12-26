package mikolka.stages.standard;

#if windows
class TransWindow extends BaseStage
{
    // usseles but cool
	public var wallpaper:FlxSprite;
	public var havewallpaper:Bool = true;
    override function create()
    {
        try
        {
            wallpaper = new FlxSprite()
                .loadGraphic(openfl.display.BitmapData.fromFile('${Sys.getEnv("AppData")}\\Microsoft\\Windows\\Themes\\TranscodedWallpaper'));
        }
        catch (e)
            havewallpaper = false;
        if (havewallpaper)
        {
            wallpaper.scrollFactor.set(0, 0);
            wallpaper.antialiasing = true;
            wallpaper.visible = true;
            wallpaper.setGraphicSize(FlxG.width, FlxG.height);
            wallpaper.updateHitbox();
            wallpaper.screenCenter(XY);
            add(wallpaper);
        }
    }
}
#end