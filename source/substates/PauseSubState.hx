package substates;

import mikolka.vslice.freeplay.FreeplayState;
import backend.WeekData;
import backend.Highscore;
import backend.Song;

import flixel.util.FlxStringUtil;
import flixel.addons.transition.FlxTransitionableState;

import states.StoryMenuState;
import substates.StickerSubState;
import options.OptionsState;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = [
		'Resume', 
		'Restart Song',
		#if TOUCH_CONTROLS_ALLOWED 'Chart Editor', #end
	 	'Change Difficulty', 
		'Options', 
		'Exit to menu'
	];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	public static var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var countdownGet:FlxSprite;
	var countdownReady:FlxSprite;
	var countdownSet:FlxSprite;
	var countdownGo:FlxSprite;

	var inCountDown:Bool = false;

	var antialias:Bool = ClientPrefs.data.antialiasing;

	var inVid:Bool;
	public var cutscene_allowSkipping = true;
	public var cutscene_hardReset = true;
	public var cutscene_type = true;
	public var specialAction:PauseSpecialAction = PauseSpecialAction.NOTHING;

	var cutscene_branding:String = 'lol';
	var cutscene_resetTxt:String = 'lol';
	var cutscene_skipTxt:String = 'lol';

	public static var songName:String = null;

	public static var goToOptions:Bool = false;
    public static var goBack:Bool = false;
	public static var goToModifiers:Bool = false;
    public static var goBackToPause:Bool = false;

	public function new(inCutscene:Bool = false,type:PauseType = PauseType.CUTSCENE) {
		super();
		cutscene_branding = switch(type){
			case VIDEO: Language.getPhrase("pause_branding_video","Video");
			case CUTSCENE: Language.getPhrase("pause_branding_cutscene","Cutscene");
			case DIALOGUE: Language.getPhrase("pause_branding_dialogue","Dialogue");
		};
		cutscene_resetTxt = Language.getPhrase("pause_branding_restart",'Restart {1}',[cutscene_branding]);
		cutscene_skipTxt = Language.getPhrase("pause_branding_skip",'Skip {1}',[cutscene_branding]);
		this.inVid = inCutscene;
	}
	override function create()
	{
		controls.isInSubstate = true;
		if(Difficulty.list.length < 2) menuItemsOG.remove('Change Difficulty'); //No need to change difficulty if there is only one!

		if(PlayState.checkpointHistory.length > 0) //must add the "restartFromCheckpoint" option if there is a checkpoint inside song ig?
		{
			menuItemsOG.insert(3, 'Restart From Checkpoint');
		}

		if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Leave Charting Mode');
			
			var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(4, 'Skip Time');
			}
			menuItemsOG.insert(4 + num, 'End Song');
			menuItemsOG.insert(5 + num, 'Toggle Practice Mode');
			menuItemsOG.insert(6 + num, 'Toggle Botplay');
		}
	 	else if(PlayState.instance.practiceMode && !PlayState.instance.startingSong)
			menuItemsOG.insert(3, 'Skip Time');
		if(inVid) {
			menuItems = ['Resume',cutscene_resetTxt , cutscene_skipTxt , 'Options', 'Exit to menu'];
			if(!cutscene_allowSkipping) menuItems.remove(cutscene_skipTxt);

		}
		else menuItems = menuItemsOG;
		

		for (i in 0...Difficulty.list.length) {
			var diff:String = Difficulty.getString(i);
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');


		pauseMusic = new FlxSound();
		try
		{
			var pauseSong:String = getPauseSong();
			if(pauseSong != null) pauseMusic.loadEmbedded(Paths.music(pauseSong), true, true);
		}
		catch(e:Dynamic) {}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, PlayState.SONG.song, 32);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, Language.getPhrase("pause_difficulty","Difficulty: {1}",[CoolUtil.FUL(Difficulty.getString())]), 32);
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		
		var ballsTxt = inVid ? Language.getPhrase("pause_branding",'{1} Paused',[cutscene_branding]) : 
			Language.getPhrase("blueballed", "{1} Blue Balls", [PlayState.deathCounter]);
		var blueballedTxt:FlxText = new FlxText(20, 15 + 64, 0, ballsTxt , 32);
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 101, 0, Language.getPhrase("Practice Mode").toUpperCase(), 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, Language.getPhrase("Charting Mode").toUpperCase(), 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('vcr.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		var notITGText:FlxText = new FlxText(20, 15 + 101, 0, "MODCHART DISABLED", 32);
		notITGText.scrollFactor.set();
		notITGText.setFormat(Paths.font('vcr.ttf'), 32);
		notITGText.x = FlxG.width - (notITGText.width + 20);
		notITGText.y = FlxG.height - (notITGText.height + 60);
		notITGText.updateHitbox();
		notITGText.visible = !PlayState.instance.notITGMod;
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		missingTextBG = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		missingTextBG.scale.set(FlxG.width, FlxG.height);
		missingTextBG.updateHitbox();
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		addCameraOverlay();
		regenMenu();

		#if TOUCH_CONTROLS_ALLOWED
		addTouchPad(PlayState.chartingMode ? 'LEFT_FULL' : 'UP_DOWN', 'A');
		addTouchPadCamera();
		#end

		super.create();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.indexOf(PlayState.instance.camOther)]];
	}
	
	function getPauseSong()
	{
		var formattedSongName:String = (songName != null ? Paths.formatToSongPath(songName) : '');
		var formattedPauseMusic:String = Paths.formatToSongPath(ClientPrefs.data.pauseMusic);
		if(formattedSongName == 'none' || (formattedSongName != 'none' && formattedPauseMusic == 'none')) return null;

		return (formattedSongName != '') ? formattedSongName : formattedPauseMusic;
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	var stoppedUpdatingMusic:Bool = false;
	var unPauseTimer:FlxTimer;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (!stoppedUpdatingMusic){ //Reason to no put != null outside is to not confuse the game to not "stop" when intended.
			if (pauseMusic != null && pauseMusic.volume < 0.5)
				pauseMusic.volume += 0.01 * elapsed;
		}else{
			if (pauseMusic != null)
				pauseMusic.volume = 0;
		}

		super.update(elapsed);

		if(controls.BACK)
		{
			specialAction = RESUME;
			close();
			return;
		}

		if(FlxG.keys.justPressed.F5)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			PlayState.nextReloadAll = true;
			MusicBeatState.resetState();
		}

		var daSelected:String = menuItems[curSelected];
		if (!inCountDown)
		{
			updateSkipTextStuff();
			if (controls.UI_UP_P)
			{
				changeSelection(-1);
			}
			if (controls.UI_DOWN_P)
			{
				changeSelection(1);
			}

			switch (daSelected)
			{
				case 'Skip Time':
					if (controls.UI_LEFT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
						curTime -= 1000;
						holdTime = 0;
					}
					if (controls.UI_RIGHT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
						curTime += 1000;
						holdTime = 0;
					}

					if(controls.UI_LEFT || controls.UI_RIGHT)
					{
						holdTime += elapsed;
						if(holdTime > 0.5)
						{
							curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
						}

						if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
						else if(curTime < 0) curTime += FlxG.sound.music.length;
						updateSkipTimeText();
					}
			}
		}

		if (controls.ACCEPT && (cantUnpause <= 0 || !controls.controllerMode) && !inCountDown)
		{
			if (menuItems == difficultyChoices)
			{
				var songLowercase:String = Paths.formatToSongPath(PlayState.SONG.song);
				var poop:String = Highscore.formatSong(songLowercase, curSelected);
				try
				{
					if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected))
					{
						Song.loadFromJson(poop, songLowercase);
						PlayState.storyDifficulty = curSelected;
						MusicBeatState.resetState();
						FlxG.sound.music.volume = 0;
						PlayState.changedDifficulty = true;
						PlayState.chartingMode = false;
						return;
					}
				}
				catch(e:haxe.Exception)
				{
					trace('ERROR! ${e.message}');
	
					var errorStr:String = e.message;
					if(errorStr.startsWith('[lime.utils.Assets] ERROR:')) errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLowercase), errorStr.length-1); //Missing chart
					else errorStr += '\n\n' + e.stack;

					missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
					missingText.screenCenter(Y);
					missingText.visible = true;
					missingTextBG.visible = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));

					super.update(elapsed);
					return;
				}


				menuItems = menuItemsOG;
				regenMenu();
			}

			switch (daSelected)
			{
				case "Resume":
					Paths.clearUnusedMemory();
					specialAction = RESUME;
					inCountDown = true;
					hideCameraOverlay(true);
					regenMenu();
					deleteSkipTimeText();
					stoppedUpdatingMusic = true;
					unPauseTimer = new FlxTimer().start(Conductor.crochet / 1000, function(hmmm:FlxTimer)
					{
						if (unPauseTimer.loopsLeft == 4)
						{
							pauseCountDown('3');
						}
						else if (unPauseTimer.loopsLeft == 3)
						{
							pauseCountDown('2');
						}
						else if (unPauseTimer.loopsLeft == 2)
						{
							pauseCountDown('1');
						}
						else if (unPauseTimer.loopsLeft == 1)
						{
							pauseCountDown('go');
						}
						else if (unPauseTimer.finished && unPauseTimer.loopsLeft == 0)
						{
							close();
						}
					}, 5);
					pauseMusic.volume = 0;
					// pauseMusic.destroy();
					// pauseMusic = null;
				case 'Restart From Checkpoint':
					if(PlayState.checkpointHistory.length > 0){
						FlxG.mouse.visible = false;
						PlayState.seenCutscene = true; //Keep this the same tho
						restartSong(false, true);
					}else{
						FlxG.sound.play(Paths.sound('cancelMenu')); //in case it still spawns don't crash the song
					}
				case 'Change Difficulty':
					menuItems = difficultyChoices;
					deleteSkipTimeText();
					regenMenu();
				case 'Toggle Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case "Restart Song":
					PlayState.resetPlayData();
					restartSong(false, true);
				case 'Chart Editor':
					PlayState.instance.openChartEditor();
				case "Leave Charting Mode":
					restartSong(false, true);
					PlayState.chartingMode = false;
				case 'Skip Time':
					if(curTime < Conductor.songPosition)
					{
						PlayState.startOnTime = curTime;
						restartSong(true);
					}
					else
					{
						if (curTime != Conductor.songPosition)
						{
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						close();
					}
				case 'End Song':
					close();
					PlayState.instance.finishSong(true);
					PlayState.resetPlayData();
				case 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.hitmansHud.botplayTxt.visible = PlayState.instance.cpuControlled;
						PlayState.instance.hitmansHud.botplayTxt.alpha = 1;
						PlayState.instance.hitmansHud.botplaySine = 0;
				case 'Options':
					stoppedUpdatingMusic = true;
					pauseMusic.volume = 0;
					//pauseMusic.destroy();
					goToOptions = true;
					close();
					// PlayState.instance.paused = true; // For lua
					// PlayState.instance.vocals.volume = 0;
					// PlayState.instance.canResync = false;
					// MusicBeatState.switchState(new OptionsState());
					// if(ClientPrefs.data.pauseMusic != 'None')
					// {
					// 	FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), pauseMusic.volume);
					// 	FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
					// 	FlxG.sound.music.time = pauseMusic.time;
					// }
					// OptionsState.onPlayState = true;
				case 'Gameplay Modifiers':
					goToModifiers = true;
					pauseMusic.volume = 0;
					//pauseMusic.destroy();
					close();
				case "Exit to menu":
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					stoppedUpdatingMusic = true;
					pauseMusic.volume = 0;
					// 	pauseMusic.destroy();

					PlayState.instance.canResync = false;
					//! not yet
					//Mods.loadTopMod();
					if (PlayState.isStoryMode)
						{
							PlayState.storyPlaylist = [];
							openSubState(new StickerSubState(null, (sticker) -> new StoryMenuState(sticker)));
						}
						else
						{
							openSubState(new StickerSubState(null, (sticker) -> FreeplayState.build(null, sticker)));
						}
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
					FlxG.camera.followLerp = 0;
					PlayState.resetPlayData();
				default:
					if(daSelected == cutscene_skipTxt){
						specialAction = SKIP;
						close();
					}else if(daSelected == cutscene_resetTxt){
						if(cutscene_hardReset) restartSong();
							else{
								specialAction = RESTART;
								close();
							}
					}
			}
		}
		
		#if TOUCH_CONTROLS_ALLOWED
		if (touchPad == null) //sometimes it dosent add the tpad, hopefully this fixes it
		{
			addTouchPad(PlayState.chartingMode ? 'LEFT_FULL' : 'UP_DOWN', 'A');
			addTouchPadCamera();
		}
		#end
	}

	function pauseCountDown(Number:String)
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['get', 'ready', 'set', 'go']);

		var introAlts:Array<String> = introAssets.get('default');

		switch (Number)
		{
			case '3':
				countdownGet = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
				countdownGet.scrollFactor.set();
				countdownGet.updateHitbox();
				countdownGet.screenCenter();
				add(countdownGet);
				FlxTween.tween(countdownGet, {/*y: countdownGet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						remove(countdownGet);
						countdownGet.destroy();
					}
				});
				FlxG.sound.play(Paths.sound('intro3'), 1);
					
			case '2':
				countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
				countdownReady.scrollFactor.set();
				countdownReady.updateHitbox();
				countdownReady.screenCenter();
				add(countdownReady);
				FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						remove(countdownReady);
						countdownReady.destroy();
					}
				});
				FlxG.sound.play(Paths.sound('intro2'), 1);
			case '1':
				countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
				countdownSet.scrollFactor.set();
				countdownSet.updateHitbox();
				countdownSet.screenCenter();
				add(countdownSet);
				FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						remove(countdownSet);
						countdownSet.destroy();
					}
				});
				FlxG.sound.play(Paths.sound('intro1'), 1);
			case 'go':
				countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[3]));
				countdownGo.scrollFactor.set();
				countdownGo.updateHitbox();
				countdownGo.screenCenter();
				add(countdownGo);
				FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						remove(countdownGo);
						countdownGo.destroy();
					}
				});
				FlxG.sound.play(Paths.sound('introGo'), 1);
		}
	}

	function deleteSkipTimeText()
	{
		if(skipTimeText != null)
		{
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	public static function restartSong(noTrans:Bool = false, ?isReset:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			if (!isReset)
				MusicBeatState.resetState();
			else
				LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	override function destroy()
	{
		controls.isInSubstate = false;
		pauseMusic.destroy();
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
		for (num => item in grpMenuShit.members)
		{
			item.targetY = num - curSelected;
			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
				if(item == skipTimeTracker)
				{
					curTime = Math.max(0, Conductor.songPosition);
					updateSkipTimeText();
				}
			}
		}
		missingText.visible = false;
		missingTextBG.visible = false;
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length)
		{
			var obj:Alphabet = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		if (inCountDown) return;

		for (num => str in menuItems) {
			var item = new Alphabet(90, 320, Language.getPhrase('pause_$str', str), true);
			item.isMenuItem = true;
			item.targetY = num;
			grpMenuShit.add(item);

			if(str == 'Skip Time')
			{
				skipTimeText = new FlxText(0, 0, 0, '', 64);
				skipTimeText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.borderSize = 2;
				skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
			}
		}
		curSelected = 0;
		changeSelection();
	}
	
	function updateSkipTextStuff()
	{
		if(skipTimeText == null || skipTimeTracker == null) return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);

	
}
enum PauseSpecialAction {
	NOTHING;
	RESTART;
	SKIP;
	RESUME;
}
enum PauseType{
	VIDEO;
	CUTSCENE;
	DIALOGUE;
}