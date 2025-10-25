package backend.crashHandler;

import flixel.FlxGame;
import flixel.FlxState;

/*
 * This class is the base game, the FlxGame, modified to make the in-game crash handler.
 *
 * This file is modified for specific use in Hypernova Engine
 *
 * Authors: Edwhak_KillBot, Niz, and Slushi
 */
class MainGame extends FlxGame
{
	public static var oldState:FlxState;
	public static var crashHandlerAlredyOpen:Bool = false;

	override public function switchState():Void
	{
		try
		{
			oldState = _state;
			super.switchState();

			FlxG.autoPause = false;
			crashHandlerAlredyOpen = false;
		}
		catch (error)
		{
			if (!crashHandlerAlredyOpen)
			{
				CrashHandler.symbolPrevent(error, 0);
				crashHandlerAlredyOpen = true;
			}
		}
	}

	override public function update()
	{
		try
		{
			super.update();
		}
		catch (error)
		{
			if (!crashHandlerAlredyOpen)
			{
				CrashHandler.symbolPrevent(error, 1);
				crashHandlerAlredyOpen = true;
			}
		}
	}

	override function draw():Void
	{
		try
		{
			super.draw();
			crashHandlerAlredyOpen = false;
		}
		catch (error)
		{
			if (!crashHandlerAlredyOpen)
			{
				CrashHandler.symbolPrevent(error, 2);
				crashHandlerAlredyOpen = true;
			}
		}
	}
}
