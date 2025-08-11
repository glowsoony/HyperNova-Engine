package backend.crashHandler;

import flixel.group.FlxGroup;
import flixel.system.scaleModes.*;
import mikolka.vslice.freeplay.FreeplayState;
import mikolka.vslice.ui.MainMenuState;
import mikolka.vslice.ui.StoryMenuState;

class GameplayCrashHandler
{
	static var camCrashHandler:FlxCamera;

	public static var assetGrp:FlxGroup;

	public static function crashHandlerTerminal(text:String = "")
	{
		if (!CrashHandler.createdCrashInGame)
		{
			CrashHandler.createdCrashInGame = true;
		}
		else
		{
			return;
		}

		// Stop the PlayState, to avoid a loop if the crash occurred in an update function
		if (Type.getClass(FlxG.state) == PlayState)
		{
			PlayState.instance.paused = true;
		}

		if (Main.fpsVar != null)
			Main.fpsVar.visible = false;
		FlxG.mouse.useSystemCursor = false;
		FlxG.mouse.visible = false;
		Application.current.window.resizable = true;

		camCrashHandler = new FlxCamera();
		camCrashHandler.bgColor.alpha = 0;
		FlxG.cameras.add(camCrashHandler, false);

		assetGrp = new FlxGroup();
		FlxG.state.add(assetGrp);

		assetGrp.camera = camCrashHandler;

		var contents:String = text;

		var split:Array<String> = contents.split("\n");

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width + 100, FlxG.height + 100, FlxColor.BLACK);
		bg.scrollFactor.set();
		assetGrp.add(bg);
		bg.alpha = 0.7;

		var watermark = new FlxText(10, 0, 0, "Slushi Engine Crash Handler [v1.4.0] by Slushi");
		watermark.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		watermark.scrollFactor.set();
		watermark.borderSize = 1.25;
		watermark.antialiasing = true;
		assetGrp.add(watermark);

		var text0 = new FlxText(10, watermark.y + 20, 0, "Hypernova Engine [" + MainMenuState.hypernovaVersion + "]");
		text0.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text0.scrollFactor.set();
		text0.borderSize = 1.25;
		assetGrp.add(text0);
		text0.visible = false;

		var text1 = new FlxText(10, text0.y + 30, 0, "SYSTEM CRASH.\nCrash log:");
		text1.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text1.scrollFactor.set();
		text1.color = FlxColor.RED;
		text1.borderSize = 1.25;
		assetGrp.add(text1);
		text1.visible = false;

		var crashtext = new FlxText(10, text1.y + 37, 0, '');
		crashtext.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		crashtext.scrollFactor.set();
		crashtext.borderSize = 1.25;
		crashtext.antialiasing = true;
		crashtext.visible = false;
		for (i in 0...split.length - 0)
		{
			if (i == split.length - 18)
				crashtext.text += split[i];
			else
				crashtext.text += split[i] + "\n";
		}
		assetGrp.add(crashtext);

		var text2 = new FlxText(10, crashtext.height + 115, 0, "");
		text2.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text2.scrollFactor.set();
		text2.borderSize = 1.25;
		text2.text = "LOADING PREVIOUS STATE: [" + Type.getClassName(Type.getClass(MainGame.oldState)) + "]...";
		assetGrp.add(text2);
		text2.visible = false;

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			text0.visible = true;
			FlxG.sound.play(Paths.sound("Edwhak/beep"));
		});

		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			text1.visible = true;
			FlxG.sound.play(Paths.sound("Edwhak/beep2"));
		});

		new FlxTimer().start(5, function(tmr:FlxTimer)
		{
			crashtext.visible = true;
			text2.visible = true;
			new FlxTimer().start(5, function(tmr:FlxTimer)
			{
				if (Main.fpsVar != null)
					Main.fpsVar.visible = ClientPrefs.data.showFPS;
				Application.current.window.resizable = true;
				Application.current.window.title = Application.current.meta.get('name');

				if (Type.getClass(FlxG.state) == PlayState)
				{
					if (PlayState.isStoryMode)
					{
						MainGame.crashHandlerAlredyOpen = false;
						MusicBeatState.switchState(new StoryMenuState());
						CrashHandler.inCrash = false;
						CrashHandler.createdCrashInGame = false;
						CrashHandler.crashes = 0;
					}
					else
					{
						MainGame.crashHandlerAlredyOpen = false;
						// Freeplay has its own custom transition
						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;
						FlxG.state.openSubState(new FreeplayState());
						CrashHandler.inCrash = false;
						CrashHandler.createdCrashInGame = false;
						CrashHandler.crashes = 0;
					}
				}
				else
				{
					MainGame.crashHandlerAlredyOpen = false;
					FlxG.switchState(Type.createInstance(Type.getClass(MainGame.oldState), []));
					CrashHandler.inCrash = false;
					CrashHandler.createdCrashInGame = false;
					CrashHandler.crashes = 0;
				}

				for (obj in assetGrp)
				{
					if (obj != null)
					{
						obj.destroy();
					}
				}

				if (camCrashHandler != null)
				{
					camCrashHandler.destroy();
				}

				Paths.clearUnusedMemory();
			});
		});
	}
}
