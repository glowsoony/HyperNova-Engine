package states;

import mikolka.JoinedLuaVariables;
import substates.StickerSubState;
import mikolka.vslice.freeplay.FreeplayState;
import backend.Highscore;
import backend.StageData;
import backend.WeekData;
import backend.Song;
import backend.Rating;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.animation.FlxAnimationController;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import openfl.events.KeyboardEvent;
import haxe.Json;

import cutscenes.DialogueBoxPsych;

import states.StoryMenuState;

import lime.math.Matrix3;
import mikolka.funkin.Scoring;
import mikolka.funkin.custom.FunkinTools;
import mikolka.vslice.results.Tallies;
import mikolka.vslice.results.ResultState;
import openfl.media.Sound;
import openfl.system.System;
import openfl.Lib;

import states.editors.ChartingState;
import states.editors.CharacterEditorState;

import substates.PauseSubState;
import substates.GameOverSubstate;

#if !flash
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

import objects.VideoSprite;

import objects.Note.EventNote;
import objects.*;
import mikolka.stages.erect.*;
import mikolka.stages.standard.*;
import states.stages.objects.*;

#if LUA_ALLOWED
import psychlua.*;
#else
import psychlua.LuaUtils;
import psychlua.HScript;
#end

#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
#end

import modchart.Manager; //modchart stuff

typedef ThreadBeatList = {
	var beat:Float;
	var func:Void->Void;
}

typedef ThreadUpdateList = {
	var startbeat:Float;
	var endbeat:Float;
	var func:Void->Void;
	var oncompletefunc:Void->Void;
}

class CheckpointData{ //this shit should work ig??
	public var time:Float = 0;

	public var marvelouss:Int = 0;
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	public var highestCombo:Int = 0;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;
	public var BPM:Float = 160.0;
	public function new(){
	}
}

/**
 * This is where all the Gameplay stuff happens and is managed
 *
 * here's some useful tips if you are making a mod in source:
 *
 * If you want to add your stage to the game, copy states/stages/Template.hx,
 * and put your stage code there, then, on PlayState, search for
 * "switch (curStage)", and add your stage to that list.
 *
 * If you want to code Events, you can either code it on a Stage file or on PlayState, if you're doing the latter, search for:
 *
 * "function eventPushed" - Only called *one time* when the game loads, use it for precaching events that use the same assets, no matter the values
 * "function eventPushedUnique" - Called one time per event, use it for precaching events that uses different assets based on its values
 * "function eventEarlyTrigger" - Used for making your event start a few MILLISECONDS earlier
 * "function triggerEvent" - Called when the song hits your event's timestamp, this is probably what you were looking for
**/
class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	private var blockedHitmansSongs:Array<String> = ['c18h27no3-demo', 'forgotten', 'icebeat', 'hernameis', 'duality', 'hallucination', 'operating', 'sweet-dreams', 'mylove']; // Anti cheat system goes brrrrr

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['F', 0.4], //From 20% to 39%
		['E', 0.5], //From 40% to 49%
		['D', 0.6], //From 50% to 59%
		['C', 0.69], //From 60% to 68%
		['B', 0.7], //69%
		['A', 0.8], //From 70% to 79%
		['S', 0.9], //From 80% to 89%
		['S+', 1], //From 90% to 99%
		['H', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	public var boyfriendMap:Map<String, Character> = new Map<String, Character>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();

	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var stageUI:String = "normal";
	public static var isPixelStage(get, never):Bool;

	@:noCompletion
	static function get_isPixelStage():Bool
		return stageUI == "pixel" || stageUI.endsWith("-pixel");

	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	//! new shit P-Slice
	public static var storyCampaignTitle = "";
	public static var altInstrumentals:String = null;
	public static var storyDifficultyColor = FlxColor.GRAY;

	public var spawnTime:Float = 2000;

	public var inst:FlxSound;
	public var vocals:FlxSound;
	public var opponentVocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Character = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	public var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
	public var opponentStrums:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
	public var playerStrums:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash> = new FlxTypedGroup<NoteSplash>();
	public var grpHoldSplashes:FlxTypedGroup<SustainSplash> = new FlxTypedGroup<SustainSplash>();

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingFrequency:Float = 4;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var maxHealth:Float = 0; //Totally not stolen from Lullaby lol
	public var maxUsedHealth:Float = 2;
	private var healthLerp:Float = 1;
	public var combo:Int = 0;
	public var comboOp:Int = 0;
	public var maxCombo:Int = 0;
	public var separateCombo:Bool = false;

	public var songPercent:Float = 0;

	public var ratingsData:Array<Rating> = Rating.loadDefault();

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;

	public var guitarHeroSustains:Bool = false;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;
	public var pressMissDamage:Float = 0.05;
	public var notITGMod:Bool = true;

	public var iconP1(get, never):HealthIcon;
	function get_iconP1()
		return hitmansHud.iconP1;
	public var iconP2:HealthIcon;
	function get_iconP2()
		return hitmansHud.iconP2;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var luaTpadCam:FlxCamera;
	public var cameraSpeed:Float = 1;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt(get, never):FlxText;
	function get_scoreTxt():FlxText
		return hitmansHud.scoreTxt;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public static var campaignSaveData:SaveScoreData = FunkinTools.newTali();

	public var defaultCamZoom:Float = 1.05;
	public var defaultStageZoom:Float = 1.05;
	private static var zoomTween:FlxTween;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	public var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if DISCORD_ALLOWED
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Int> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	#if LUA_ALLOWED public var luaArray:Array<FunkinLua> = []; #end

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	private var luaDebugGroup:FlxTypedGroup<psychlua.DebugLuaText>;
	#end
	public var introSoundsSuffix:String = '';

	// Less laggy controls
	private var keysArray:Array<String>;
	public var songName:String;

	// Callbacks for stages
	public var startCallback:Void->Void = null;
	public var endCallback:Void->Void = null;

	public static var nextReloadAll:Bool = false;

	#if TOUCH_CONTROLS_ALLOWED
	public var luaTouchPad:TouchPad;
	#end

	// Death / Misc / Modifiers
	public static var forceMiddleScroll:Bool = false; //yeah
	public static var forceRightScroll:Bool = false; //so modcharts that NEED rightscroll will be forced (mainly for player vs enemy classic stuff like bf vs someone)
	public static var forcedAScroll:Bool = false; //if forced then it should disable "clientPrefs" stuff
	public var edwhakIsEnemy:Bool = false;
	public var allowEnemyDrain:Bool = false;
	var edwhakDrain:Float = 0.03; //0.03 or more if changed

	//Modchart stuff
	public var modchartRenderer:Manager;

	var staticDeath:FlxSprite;
    var offEffect:FlxSprite;
	var deathVariableTXT:String = 'Notes'; //game load the shit here too to make death screen works well lmao -Ed
	var deathTimer:FlxTimer;
	public var gameOver:Bool = false; //simple shit to allow or disable death screen variables when a special note was hit/miss
	public var drain:Bool = false;
	public var gain:Bool = false;
	public var sustainDivider:Float = 5; //simple shit to change how much sustains gives life lol

	// Hud / Camera
	public var hitmansHud:huds.Huds;
	public var camInterfaz:FlxCamera;
	public var camProxy:FlxCamera;
	public var camVisuals:FlxCamera;
	public var noteCameras0:FlxCamera;
	public var noteCameras1:FlxCamera;

	// Gameplay / Rating
	public var chaosMod:Bool = false;
	public var chaosDifficulty:Float = 1;
	public var randomizedNotes:Bool = false;

	public var marvelouss:Int = 0;
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	public var fantastics:Int = 0;
	public var excelents:Int = 0;
	public var greats:Int = 0;
	public var decents:Int = 0;
	public var wayoffs:Int = 0;

	public static var dasicks:Int = 0;
	public static var dagoods:Int = 0;
	public static var dabads:Int = 0;
	public static var dashits:Int = 0;
	public static var misses:Int = 0;
	public static var weekMisses:Int = 0;
	public static var wrongs:Int = 0;
	public static var maxc:Int = 0;
	public static var keym:Int = 0;
	public static var inp:Int = 0;

	// Checkpoint stuff (thanks hazard!)
	public static var checkpointsUsed:Int = 0;
	public static var checkpointHistory:Array<CheckpointData> = [];

	var checkpointSprite:FlxSprite;
	var passedCheckPoint:FlxText;

	//Tween
	public static var tweenManager:FlxTweenManager = null;
	public static var timerManager:FlxTimerManager = null;

	public function createTween(Object:Dynamic, Values:Dynamic, Duration:Float, ?Options:TweenOptions):FlxTween
	{
		var tween:FlxTween = tweenManager.tween(Object, Values, Duration, Options);
		tween.manager = tweenManager;
		return tween;
	}

	public function createTweenNum(FromValue:Float, ToValue:Float, Duration:Float = 1, ?Options:TweenOptions, ?TweenFunction:Float->Void):FlxTween
	{
		var tween:FlxTween = tweenManager.num(FromValue, ToValue, Duration, Options, TweenFunction);
		tween.manager = tweenManager;
		return tween;
	}

	public function createTweenColor(Object:Dynamic, Duration:Float, FromColor:FlxColor, ToColor:FlxColor, ?Options:TweenOptions):FlxTween
	{
		var tween:FlxTween = tweenManager.color(Object, Duration, FromColor, ToColor, Options);
		tween.manager = tweenManager;
		return tween;
	}

	public function createTimer(Time:Float = 1, ?OnComplete:FlxTimer->Void, Loops:Int = 1):FlxTimer
	{
		var timer:FlxTimer = new FlxTimer();
		timer.manager = timerManager;
		return timer.start(Time, OnComplete, Loops);
	}

	// public var aftBitmap:AFT_capture; //hazzy stuff :3
	public var camBackground:FlxCamera;

	override public function create()
	{
		this.variables = new JoinedLuaVariables();
		//trace('Playback Rate: ' + playbackRate);
		Paths.clearUnusedMemory();
		Paths.clearStoredMemory();
		if(nextReloadAll)
		{
			Paths.clearUnusedMemory();
			Language.reloadPhrases();
		}
		nextReloadAll = false;

		startCallback = startCountdown;
		endCallback = endSong;

		// for lua
		instance = this;

		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed');

		keysArray = [
			'note_left',
			'note_down',
			'note_up',
			'note_right'
		];

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();

		//hitmans gameOverShit ig lmao
		staticDeath = new FlxSprite();
		staticDeath.frames = Paths.getSparrowAtlas('Edwhak/Hitmans/newGameOver/Static');
		staticDeath.animation.addByPrefix('idle', 'Static Animated', 48, true);	
		staticDeath.antialiasing = ClientPrefs.data.antialiasing;
		staticDeath.scale.y = 3;
		staticDeath.scale.x = 3;	
		staticDeath.updateHitbox();	
		staticDeath.screenCenter();
		staticDeath.alpha =0 ;
		staticDeath.animation.play("idle");
		add(staticDeath);

		offEffect = new FlxSprite();
		offEffect.frames = Paths.getSparrowAtlas('Edwhak/Hitmans/newGameOver/tv-effect');
		offEffect.animation.addByPrefix('play', 'shutdown', 24, false);
		offEffect.scale.y = 1;
		offEffect.scale.x = 1;
		offEffect.alpha = 0;
		offEffect.updateHitbox();
		offEffect.screenCenter();
		offEffect.antialiasing = ClientPrefs.data.antialiasing;
		add(offEffect);

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain');
		healthLoss = ClientPrefs.getGameplaySetting('healthloss');
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill');
		practiceMode = ClientPrefs.getGameplaySetting('practice');
		cpuControlled = ClientPrefs.getGameplaySetting('botplay');
		guitarHeroSustains = ClientPrefs.data.guitarHeroSustains;
		notITGMod = ClientPrefs.getGameplaySetting('modchart');
		chaosMod = ClientPrefs.getGameplaySetting('chaosmode');
		chaosDifficulty = ClientPrefs.getGameplaySetting('chaosdifficulty');
		randomizedNotes = ClientPrefs.getGameplaySetting('randomnotes');

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = initPsychCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		luaTpadCam = new FlxCamera();
		camInterfaz = new FlxCamera();
		camVisuals = new FlxCamera();
		camProxy = new FlxCamera();
		camBackground = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		luaTpadCam.bgColor.alpha = 0;
		camInterfaz.bgColor.alpha = 0;
		camVisuals.bgColor.alpha = 0;
		camProxy.bgColor.alpha = 0;
		camBackground.bgColor.alpha = 0;
		noteCameras0 = new FlxCamera();
		noteCameras0.bgColor.alpha = 0;
		noteCameras0.visible = false;
		noteCameras1 = new FlxCamera();
		noteCameras1.bgColor.alpha = 0;
		noteCameras1.visible = false;

		FlxG.cameras.add(camBackground, false);
		FlxG.cameras.add(camInterfaz, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(noteCameras0, false);
		FlxG.cameras.add(noteCameras1, false);
		FlxG.cameras.add(camProxy, false);
		FlxG.cameras.add(camVisuals, false);
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.add(luaTpadCam, false);

		persistentUpdate = true;
		persistentDraw = true;

		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;

		#if DISCORD_ALLOWED
		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		storyDifficultyText = Difficulty.getString();

		if (isStoryMode)
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		else
			detailsText = "Freeplay";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		songName = Paths.formatToSongPath(SONG.song);
		if(SONG.stage == null || SONG.stage.length < 1)
			SONG.stage = StageData.vanillaSongStage(Paths.formatToSongPath(Song.loadedSongName));

		curStage = SONG.stage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		defaultCamZoom = stageData.defaultZoom;
		defaultStageZoom = defaultCamZoom;

		stageUI = "normal";
		if (stageData.stageUI != null && stageData.stageUI.trim().length > 0)
			stageUI = stageData.stageUI;
		else if (stageData.isPixelStage == true) //Backward compatibility
			stageUI = "pixel";

		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		checkpointSprite = new BGSprite('Huds/checkpoint/checkpointVignette', -600, -480, 0.5, 0.5);
		checkpointSprite.setGraphicSize(FlxG.width, FlxG.height);
		checkpointSprite.updateHitbox();
		checkpointSprite.cameras = [camOther]; //hud funny
		checkpointSprite.screenCenter();	
		checkpointSprite.alpha=0;
		add(checkpointSprite);

		switch (curStage)
		{
			case 'stage': new StageWeek1(); 						//Week 1
			case 'spooky': new Spooky();							//Week 2
			case 'philly': new Philly();							//Week 3
			case 'limo': new Limo();								//Week 4
			case 'mall': new Mall();								//Week 5 - Cocoa, Eggnog
			case 'mallEvil': new MallEvil();						//Week 5 - Winter Horrorland
			case 'school': new School();							//Week 6 - Senpai, Roses
			case 'schoolEvil': new SchoolEvil();					//Week 6 - Thorns
			case 'tank': new Tank();								//Week 7 - Ugh, Guns, Stress
			case 'phillyStreets': new PhillyStreets(); 				//Weekend 1 - Darnell, Lit Up, 2Hot
			case 'phillyBlazin': new PhillyBlazin();				//Weekend 1 - Blazin
			case 'mainStageErect': new MainStageErect();			//Week 1 Special 
			case 'spookyMansionErect': new SpookyMansionErect();	//Week 2 Special 
			case 'phillyTrainErect': new PhillyTrainErect();  		//Week 3 Special 
			case 'limoRideErect': new LimoRideErect();  			//Week 4 Special 
			case 'mallXmasErect': new MallXmasErect(); 				//Week 5 Special 
			case 'phillyStreetsErect': new PhillyStreetsErect(); 	//Weekend 1 Special 
			case 'hitmansPlaceHolder': new PlaceHolder();
			#if window case 'transwindow': new TransWindow(); #end
		}
		if(isPixelStage) introSoundsSuffix = '-pixel';

		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		luaDebugGroup = new FlxTypedGroup<psychlua.DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		if (!stageData.hide_girlfriend)
		{
			if(SONG.gfVersion == null || SONG.gfVersion.length < 1) SONG.gfVersion = 'gf'; //Fix for the Chart Editor
			gf = new Character(0, 0, SONG.gfVersion);
			startCharacterPos(gf);
			gfGroup.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);

		boyfriend = new Character(0, 0, SONG.player1, true);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		
		if(stageData.objects != null && stageData.objects.length > 0)
		{
			var list:Map<String, FlxSprite> = StageData.addObjectsToState(stageData.objects, !stageData.hide_girlfriend ? gfGroup : null, dadGroup, boyfriendGroup, this);
			for (key => spr in list)
				if(!StageData.reservedNames.contains(key))
					variables.set(key, spr);
		}
		else
		{
			add(gfGroup);
			add(dadGroup);
			add(boyfriendGroup);
		}

		// aftBitmap = new AFT_capture(camHUD);
		// aftBitmap.updateRate = 0.0;
		// aftBitmap.recursive = false;
		
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		// "SCRIPTS FOLDER" SCRIPTS
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/'))
			#if linux
			for (file in CoolUtil.sortAlphabetically(Paths.readDirectory(folder)))
			#else
			for (file in Paths.readDirectory(folder))
			#end
			{
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end
			
		var camPos:FlxPoint = FlxPoint.get(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}
		var edwhakVariable:Array<String> = ['Edwhak', 'he', 'edwhakBroken', 'edkbmassacre'];
		if (edwhakVariable.contains(boyfriend.curCharacter)){
			Note.canDamagePlayer = false;
			Note.edwhakIsPlayer = true;
		}else{
			Note.canDamagePlayer = true;
			Note.edwhakIsPlayer = false;
		}
			// i can't die to my own notes u dumb

			/*———————————No instakill?———————————
			⠀⣞⢽⢪⢣⢣⢣⢫⡺⡵⣝⡮⣗⢷⢽⢽⢽⣮⡷⡽⣜⣜⢮⢺⣜⢷⢽⢝⡽⣝
			⠸⡸⠜⠕⠕⠁⢁⢇⢏⢽⢺⣪⡳⡝⣎⣏⢯⢞⡿⣟⣷⣳⢯⡷⣽⢽⢯⣳⣫⠇
			⠀⠀⢀⢀⢄⢬⢪⡪⡎⣆⡈⠚⠜⠕⠇⠗⠝⢕⢯⢫⣞⣯⣿⣻⡽⣏⢗⣗⠏⠀
			⠀⠪⡪⡪⣪⢪⢺⢸⢢⢓⢆⢤⢀⠀⠀⠀⠀⠈⢊⢞⡾⣿⡯⣏⢮⠷⠁⠀⠀
			⠀⠀⠀⠈⠊⠆⡃⠕⢕⢇⢇⢇⢇⢇⢏⢎⢎⢆⢄⠀⢑⣽⣿⢝⠲⠉⠀⠀⠀⠀
			⠀⠀⠀⠀⠀⡿⠂⠠⠀⡇⢇⠕⢈⣀⠀⠁⠡⠣⡣⡫⣂⣿⠯⢪⠰⠂⠀⠀⠀⠀
			⠀⠀⠀⠀⡦⡙⡂⢀⢤⢣⠣⡈⣾⡃⠠⠄⠀⡄⢱⣌⣶⢏⢊⠂⠀⠀⠀⠀⠀⠀
			⠀⠀⠀⠀⢝⡲⣜⡮⡏⢎⢌⢂⠙⠢⠐⢀⢘⢵⣽⣿⡿⠁⠁⠀⠀⠀⠀⠀⠀⠀
			⠀⠀⠀⠀⠨⣺⡺⡕⡕⡱⡑⡆⡕⡅⡕⡜⡼⢽⡻⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
			⠀⠀⠀⠀⣼⣳⣫⣾⣵⣗⡵⡱⡡⢣⢑⢕⢜⢕⡝⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
			⠀⠀⠀⣴⣿⣾⣿⣿⣿⡿⡽⡑⢌⠪⡢⡣⣣⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
			⠀⠀⠀⡟⡾⣿⢿⢿⢵⣽⣾⣼⣘⢸⢸⣞⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
			⠀⠀⠀⠀⠁⠇⠡⠩⡫⢿⣝⡻⡮⣒⢽⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
			—————————————————————————————*/
		if (edwhakVariable.contains(dad.curCharacter))
			edwhakIsEnemy = true;
		else
			edwhakIsEnemy = false;
		
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		// STAGE SCRIPTS
		#if LUA_ALLOWED startLuasNamed('stages/' + curStage + '.lua'); #end
		#if HSCRIPT_ALLOWED startHScriptsNamed('stages/' + curStage + '.hx'); #end

		// CHARACTER SCRIPTS
		if(gf != null) startCharacterScripts(gf.curCharacter);
		startCharacterScripts(dad.curCharacter);
		startCharacterScripts(boyfriend.curCharacter);
		#end

		comboGroup = new FlxSpriteGroup();
		add(comboGroup);

		Conductor.songPosition = -Conductor.crochet * 5 + Conductor.offset;

		add(strumLineNotes);

		forceMiddleScroll = SONG.middleScroll;
		forceRightScroll = SONG.rightScroll;

		forcedAScroll = forceRightScroll || forceMiddleScroll; //so its forced to true

		generateSong();

		//Loading silly notes :D!!
		generateStaticArrows(0);
		generateStaticArrows(1);
		NoteMovement.getDefaultStrumPos(this);
		for (i in 0...playerStrums.length) {
			setOnScripts('defaultPlayerStrumX' + i, playerStrums.members[i].x);
			setOnScripts('defaultPlayerStrumY' + i, playerStrums.members[i].y);
		}
		for (i in 0...opponentStrums.length) {
			setOnScripts('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
			setOnScripts('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
			//if(ClientPrefs.data.middleScroll) opponentStrums.members[i].visible = false;
		}

		if (notITGMod){
			if (SONG.notITG && !SONG.newModchartTool)
			{
				playfieldRenderer = new PlayfieldRenderer(strumLineNotes, notes, this);
				playfieldRenderer.cameras = [camHUD];
				add(playfieldRenderer);
			}
			else if (SONG.notITG && SONG.newModchartTool){
				modchartRenderer = new Manager();
				add(modchartRenderer);
			}else{ //if notITG mod is used but none of this contidions are true it will just ignore the code and add the splashes!
				add(grpNoteSplashes);
				add(grpHoldSplashes);
			}
		}else{
			add(grpNoteSplashes);
			add(grpHoldSplashes);
		}

		camFollow = new FlxObject();
		camFollow.setPosition(camPos.x, camPos.y);
		camPos.put();

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.snapToTarget();

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		moveCameraSection();

		comboGroup.cameras = [camHUD];

		hitmansHud = new huds.Huds();
		add(hitmansHud);

		startingSong = true;

		strumLineNotes.cameras = notes.cameras = grpNoteSplashes.cameras = grpHoldSplashes.cameras = [camHUD];

		hitmansHud.healthBar.cameras = [camInterfaz];
		hitmansHud.healthBarBG.cameras = [camInterfaz];

		hitmansHud.ratings.cameras = [camVisuals];
		hitmansHud.ratingsOP.cameras = [camVisuals];
		hitmansHud.noteScore.cameras = [camVisuals];
		hitmansHud.noteScoreOp.cameras = [camVisuals];

		hitmansHud.iconP1.cameras = [camInterfaz];
		hitmansHud.iconP2.cameras = [camInterfaz];

		hitmansHud.scoreTxt.cameras = [camInterfaz];
		hitmansHud.botplayTxt.cameras = [camVisuals];
		hitmansHud.timeBar.cameras = [camInterfaz];
		hitmansHud.timeBarBG.cameras = [camInterfaz];
		hitmansHud.timeTxt.cameras = [camInterfaz];

		#if LUA_ALLOWED
		for (notetype in noteTypes)
			startLuasNamed('custom_notetypes/' + notetype + '.lua');
		for (event in eventsPushed)
			startLuasNamed('custom_events/' + event + '.lua');
		#end

		#if HSCRIPT_ALLOWED
		for (notetype in noteTypes)
			startHScriptsNamed('custom_notetypes/' + notetype + '.hx');
		for (event in eventsPushed)
			startHScriptsNamed('custom_events/' + event + '.hx');
		#end
		noteTypes = null;
		eventsPushed = null;

		if(eventNotes.length > 1)
		{
			for (event in eventNotes) event.strumTime -= eventEarlyTrigger(event);
			eventNotes.sort(sortByTime);
		}

		// SONG SPECIFIC SCRIPTS
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'data/$songName/'))
			#if linux
			for (file in CoolUtil.sortAlphabetically(Paths.readDirectory(folder)))
			#else
			for (file in Paths.readDirectory(folder))
			#end
			{
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end

		#if TOUCH_CONTROLS_ALLOWED
		addHitbox();
		hitbox.visible = true;
		hitbox.onHintDown.add(onHintPress);
		hitbox.onHintUp.add(onHintRelease);
		#end

		startCallback();
		RecalculateRating();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		//PRECACHING THINGS THAT GET USED FREQUENTLY TO AVOID LAGSPIKES
		if(ClientPrefs.data.hitsoundVolume > 0) Paths.sound('hitsound');
		if(!ClientPrefs.data.ghostTapping) for (i in 1...4) Paths.sound('missnote$i');
		Paths.image('alphabet');

		if (PauseSubState.songName != null)
			Paths.music(PauseSubState.songName);
		else if(Paths.formatToSongPath(ClientPrefs.data.pauseMusic) != 'none')
			Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic));

		resetRPC();

		stagesFunc(function(stage:BaseStage) stage.createPost());

		if (notITGMod && SONG.notITG && !SONG.newModchartTool)
			ModchartFuncs.loadLuaFunctions();

		callOnScripts('onCreatePost');
		callOnScripts('onModchart');
		
		var splash:NoteSplash = new NoteSplash();
		grpNoteSplashes.add(splash);
		splash.alpha = 0.000001; //cant make it invisible or it won't allow precaching

		SustainSplash.startCrochet = Conductor.stepCrochet;
		SustainSplash.frameRate = Math.floor(24 / 100 * SONG.bpm);
		var holdSplash:SustainSplash = new SustainSplash();
		holdSplash.alpha = 0.0001;

		#if (!android && TOUCH_CONTROLS_ALLOWED)
		addTouchPad('NONE', 'P');
		addTouchPadCamera();
		#end

		
		super.create();

		for (note in unspawnNotes) 
		{
			note.setCustomColor("quant",!ClientPrefs.get("quantization"));
			if (note.noteType == 'Custom Note')
			{
				note.customNoteMech = function(note:Note)
				{
					
				}
			}
			else {
				if (boyfriend.curCharacter.contains('boy'))
				{
					if (FlxG.random.bool(2))
					{
						note.allowCustomMech = FlxG.random.bool(2);
						note.customNoteMech = function(self:Note)
						{
							self.hitHealth = 0;
							self.extraData.set("constantHealth", true);
						}
					}else {
						note.extraData.set("constantHealth", false);
					}
				}
			}
		}

		Paths.clearUnusedMemory();

		cacheCountdown();
		cachePopUpScore();

		if(eventNotes.length < 1) checkEventNote();

		passedCheckPoint = new FlxText(0, 0, 0, "Player's current checkpoint spot is 0.", 20);
		passedCheckPoint.size = 40;
		passedCheckPoint.alpha = 0;
		add(passedCheckPoint);
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		songSpeed = value;
		noteKillOffset = Math.max(Conductor.stepCrochet, 350 / songSpeed * playbackRate);
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		#if FLX_PITCH
		if(generatedMusic)
		{
			vocals.pitch = value;
			opponentVocals.pitch = value;
			FlxG.sound.music.pitch = value;

			var ratio:Float = playbackRate / value; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		playbackRate = value;
		FlxG.animationTimeScale = value;
		Conductor.safeZoneOffset = (ClientPrefs.data.safeFrames / 60) * 1000 * value;
		setOnScripts('playbackRate', playbackRate);
		#else
		playbackRate = 1.0; // ensuring -Crow
		#end
		return playbackRate;
	}

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	public function addTextToDebug(text:String, color:FlxColor) {
		var newText:psychlua.DebugLuaText = luaDebugGroup.recycle(psychlua.DebugLuaText);
		newText.text = text;
		newText.color = color;
		newText.disableTime = 6;
		newText.alpha = 1;
		newText.setPosition(10, 8 - newText.height);

		luaDebugGroup.forEachAlive(function(spr:psychlua.DebugLuaText) {
			spr.y += newText.height + 2;
		});
		luaDebugGroup.add(newText);

		Sys.println(text);
	}
	#end

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Character = new Character(0, 0, newCharacter, true);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterScripts(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterScripts(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterScripts(newGf.curCharacter);
				}
		}
	}

	function startCharacterScripts(name:String)
	{
		// Lua
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/$name.lua';
		#if MODS_ALLOWED
		var replacePath:String = Paths.modFolders(luaFile);
		if(FileSystem.exists(replacePath))
		{
			luaFile = replacePath;
			doPush = true;
		}
		else
		{
			luaFile = Paths.getSharedPath(luaFile);
			if(FileSystem.exists(luaFile))
				doPush = true;
		}
		#else
		luaFile = Paths.getSharedPath(luaFile);
		if(Assets.exists(luaFile)) doPush = true;
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile)
				{
					doPush = false;
					break;
				}
			}
			if(doPush) new FunkinLua(luaFile);
		}
		#end

		// HScript
		#if HSCRIPT_ALLOWED
		var doPush:Bool = false;
		var scriptFile:String = 'characters/' + name + '.hx';
		#if MODS_ALLOWED
		var replacePath:String = Paths.modFolders(scriptFile);
		if(FileSystem.exists(replacePath))
		{
			scriptFile = replacePath;
			doPush = true;
		}
		else
		#end
		{
			scriptFile = Paths.getSharedPath(scriptFile);
			if(FileSystem.exists(scriptFile))
				doPush = true;
		}

		if(doPush)
		{
			if(Iris.instances.exists(scriptFile))
				doPush = false;

			if(doPush) initHScript(scriptFile);
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite
		return variables.get(tag);

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public var videoCutscene:VideoSprite = null;
	public function startVideo(name:String, forMidSong:Bool = false, canSkip:Bool = true, loop:Bool = false, playOnLoad:Bool = true)
	{
		#if VIDEOS_ALLOWED
		inCutscene = !forMidSong;
		canPause = forMidSong;

		var foundFile:Bool = false;
		var fileName:String = Paths.video(name);

		#if sys
		if (FileSystem.exists(fileName))
		#else
		if (OpenFlAssets.exists(fileName))
		#end
		foundFile = true;

		if (foundFile)
		{
			videoCutscene = new VideoSprite(fileName, forMidSong, canSkip, loop);

			// Finish callback
			if (!forMidSong)
			{
				function onVideoEnd()
				{
					if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
					{
						moveCameraSection();
						FlxG.camera.snapToTarget();
					}
					videoCutscene = null;
					canPause = false;
					inCutscene = false;
					startAndEnd();
				}
				videoCutscene.finishCallback = onVideoEnd;
				videoCutscene.onSkip = onVideoEnd;
			}
			add(videoCutscene);

			if (playOnLoad)
				videoCutscene.play();
			return videoCutscene;
		}
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		else addTextToDebug("Video not found: " + fileName, FlxColor.RED);
		#else
		else FlxG.log.error("Video not found: " + fileName);
		#end
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		#end
		return null;
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(DialogueBoxPsych.parseDialogue(Paths.json(songName + '/dialogue')))" and it should load dialogue.json
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			startAndEnd();
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownGet:FlxSprite;
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		var introImagesArray:Array<String> = switch(stageUI) {
			case "pixel": ['${stageUI}UI/ready-pixel', '${stageUI}UI/set-pixel', '${stageUI}UI/date-pixel'];
			case "normal": ["get", "ready", "set" ,"go"];
			default: ['${stageUI}UI/ready', '${stageUI}UI/set', '${stageUI}UI/go'];
		}
		introAssets.set(stageUI, introImagesArray);
		var introAlts:Array<String> = introAssets.get(stageUI);
		for (asset in introAlts) Paths.image(asset);

		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}

	public static var ignoreCheckpointOnStart:Bool = false;
	var startedFrom:Float = 0;
	var backwardsSkip:Bool = false;
	var checkPointVolume:FlxTween;

	public function startCountdown()
	{
		var startingfromCheckpoint:Bool = false;
		if(PlayState.checkpointHistory.length > 0 && !PlayState.ignoreCheckpointOnStart){
			startOnTime = PlayState.checkpointHistory[PlayState.checkpointHistory.length-1].time;
			startingfromCheckpoint=true;
			trace("Starting from checkpoint!");

			if (SONG.notITG && notITGMod){
				playfieldRenderer.modifierTable.clear();
				playfieldRenderer.modchart.loadModifiers();
				playfieldRenderer.tweenManager.completeAll();
				playfieldRenderer.eventManager.clearEvents();
				playfieldRenderer.modifierTable.resetMods();
				playfieldRenderer.modchart.loadEvents();
				playfieldRenderer.update(0);
				ModchartFuncs.loadLuaFunctions();
				callOnScripts('onModchart');
			}
		}
		if(startedCountdown) {
			callOnScripts('onStartCountdown');
			return false;
		}

		seenCutscene = true;
		inCutscene = false;
		var ret:Dynamic = callOnScripts('onStartCountdown', null, true);
		if(ret != LuaUtils.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			canPause = true;

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5 + Conductor.offset;
			setOnScripts('startedCountdown', true);
			callOnScripts('onCountdownStarted');

			var swagCounter:Int = 0;
			backwardsSkip=false;
			if (startOnTime > 0 && startingfromCheckpoint) {
				startedFrom = startOnTime;
				checkpointsUsed++;
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - Conductor.crochet * 20);
				for (i in 0...playerStrums.length) {
					playerStrums.members[i].alpha=1;
				}
				FlxG.sound.music.volume = 0;
				vocals.volume = 0;
				checkPointVolume = FlxTween.num(0, 1, (Conductor.crochet/1000) * 10, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween) {
					checkPointVolume = null;
				}}, function(v){
					vocals.volume = v;
					FlxG.sound.music.volume = v;
				});

				//return;
			}
			else if (skipCountdown || startOnTime > 0) {
				if(PlayState.ignoreCheckpointOnStart){
					for (i in 0...playerStrums.length) {
						playerStrums.members[i].alpha = 1;
						opponentStrums.members[i].alpha = 1;
					}
					backwardsSkip=true;
					PlayState.ignoreCheckpointOnStart = false;
					trace("Starting from skip time! " + startOnTime);
				}
				startedFrom = startOnTime;
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 500);
				return true;
			}
			moveCameraSection();

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				characterBopper(tmr.loopsLeft);

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				var introImagesArray:Array<String> = switch(stageUI) {
					case "pixel": ['${stageUI}UI/ready-pixel', '${stageUI}UI/set-pixel', '${stageUI}UI/date-pixel'];
					case "normal": ["get", "ready", "set" ,"go"];
					default: ['${stageUI}UI/ready', '${stageUI}UI/set', '${stageUI}UI/go'];
				}
				introAssets.set(stageUI, introImagesArray);

				var introAlts:Array<String> = introAssets.get(stageUI);
				var antialias:Bool = (ClientPrefs.data.antialiasing && !isPixelStage);
				var tick:Countdown = THREE;

				switch (swagCounter)
				{
					case 0:
						countdownGet = createCountdownSprite(introAlts[0], antialias);
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
						tick = THREE;
					case 1:
						countdownReady = createCountdownSprite(introAlts[1], antialias);
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
						tick = TWO;
					case 2:
						countdownSet = createCountdownSprite(introAlts[2], antialias);
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
						tick = ONE;
					case 3:
						countdownGo = createCountdownSprite(introAlts[3], antialias);
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
						tick = GO;
					case 4:
						tick = START;
				}

				if(!skipArrowStartTween)
				{
					notes.forEachAlive(function(note:Note) {
						if(ClientPrefs.data.opponentStrums || note.mustPress)
						{
							note.copyAlpha = false;
							note.alpha = note.multAlpha;
							if(ClientPrefs.data.middleScroll && !note.mustPress)
								note.alpha *= 0.35;
						}
					});
				}

				stagesFunc(function(stage:BaseStage) stage.countdownTick(tick, swagCounter));
				callOnLuas('onCountdownTick', [swagCounter]);
				callOnHScript('onCountdownTick', [tick, swagCounter]);

				swagCounter += 1;
			}, 5);
		}
		return true;
	}

	inline private function createCountdownSprite(image:String, antialias:Bool):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(image));
		spr.cameras = [camHUD];
		spr.scrollFactor.set();
		spr.updateHitbox();

		if (PlayState.isPixelStage)
			spr.setGraphicSize(Std.int(spr.width * daPixelZoom));

		spr.screenCenter();
		spr.antialiasing = antialias;
		insert(members.indexOf(strumLineNotes), spr);
		FlxTween.tween(spr, {/*y: spr.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				remove(spr);
				spr.destroy();
			}
		});
		return spr;
	}

	public function addBehindGF(obj:FlxBasic)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxBasic)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad(obj:FlxBasic)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				//if(!ClientPrefs.data.lowQuality || !ClientPrefs.data.popUpRating || !cpuControlled) daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;
				invalidateNote(daNote);
			}
			--i;
		}
	}

	public dynamic function fullComboFunction()
	{
		var sicks:Int = ratingsData[0].hits;
		var goods:Int = ratingsData[1].hits;
		var bads:Int = ratingsData[2].hits;
		var shits:Int = ratingsData[3].hits;

		ratingFC = "";
		if(songMisses == 0)
		{
			if (bads > 0 || shits > 0) ratingFC = 'FC';
			else if (goods > 0) ratingFC = 'GFC';
			else if (sicks > 0) ratingFC = 'SFC';
		}
		else {
			if (songMisses < 10) ratingFC = 'SDCB';
			else ratingFC = 'Clear';
		}
	}

	public function setSongTime(time:Float)
	{
		if (time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();
		opponentVocals.pause();

		FlxG.sound.music.time = time - Conductor.offset;
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		FlxG.sound.music.play();

		if (Conductor.songPosition < vocals.length)
		{
			vocals.time = time - Conductor.offset;
			#if FLX_PITCH vocals.pitch = playbackRate; #end
			vocals.play();
		}
		else vocals.pause();

		if (Conductor.songPosition < opponentVocals.length)
		{
			opponentVocals.time = time - Conductor.offset;
			#if FLX_PITCH opponentVocals.pitch = playbackRate; #end
			opponentVocals.play();
		}
		else opponentVocals.pause();
		Conductor.songPosition = time;
	}

	public function startNextDialogue() {
		dialogueCount++;
		callOnScripts('onNextDialogue', [dialogueCount]);
	}

	public function skipDialogue() {
		callOnScripts('onSkipDialogue', [dialogueCount]);
	}

	public var songTime:Float = 0;

	public var songStarted:Bool = false;

	public function startSong():Void
	{
		startingSong = false;
		canPause = true;

		@:privateAccess
		FlxG.sound.playMusic(inst._sound, 1, false);
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();
		opponentVocals.play();

		if(backwardsSkip){
			if(startOnTime > 0)
			{
				setSongTime(startOnTime - 500);
				trace("dumb: " + startOnTime);
			}
		}	
		else
			startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}

		stagesFunc(function(stage:BaseStage) stage.startSong());

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(hitmansHud.timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(hitmansHud.timeBarBG, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(hitmansHud.timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence (with Time Left)
		if(autoUpdateRPC) DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", hitmansHud.getDiscordRichName(), true, songLength);
		#end

		for (i in 0...checkpointQueueTimesArray.length) {
			hitmansHud.markCheckpointOnTimebar(checkpointQueueTimesArray[i]);
		}

		if(!(backwardsSkip || PlayState.ignoreCheckpointOnStart) && PlayState.checkpointHistory.length > 0){
			var checkpoint:CheckpointData = PlayState.checkpointHistory[PlayState.checkpointHistory.length-1];
			trace(checkpoint);
			//trace("Test for sicks: " + PlayState.checkpointMemory_sicks);
			marvelouss = checkpoint.marvelouss;
			sicks = checkpoint.sicks;
			goods = checkpoint.goods;
			bads = checkpoint.bads;
			shits = checkpoint.shits;
			maxCombo = checkpoint.highestCombo;
			songScore = checkpoint.songScore;
			songHits = checkpoint.songHits;
			songMisses = checkpoint.songMisses;

			// hitTimesDiff=checkpoint.hitTimeDiff;
			// hitTimesTime=checkpoint.hitTimesTime;
			// hitTimesJudge=checkpoint.hitTimesJudge;
			// healthSamples=checkpoint.healthSamples;

			totalPlayed = checkpoint.totalPlayed;
			totalNotesHit = checkpoint.totalNotesHit;

			//if(checkpoint.time > 359600 && SONG.song.toLowerCase() == "mindfuck")
			//	mindfuckCheckpointTestCheckThingIDFKANYMOREPLEASESAVEME = true;

			Conductor.bpm=checkpoint.BPM;

			skipIntro(checkpoint.time - Conductor.crochet * 5);

			if (SONG.notITG && notITGMod){
				playfieldRenderer.modifierTable.clear();
				playfieldRenderer.modchart.loadModifiers();
				playfieldRenderer.tweenManager.completeAll();
				playfieldRenderer.eventManager.clearEvents();
				playfieldRenderer.modifierTable.resetMods();
				playfieldRenderer.modchart.loadEvents();
				playfieldRenderer.update(0);
				ModchartFuncs.loadLuaFunctions();
				callOnScripts('onModchart');
			}
			
			trace("fixing modchart");
		}
		else{
		// 	if(introSkip>0 && deathCounter > 0) {
		// 		introSkipSprite.alpha=0;
		// 		add(introSkipSprite);
		// 		//Make introskipsprite fade in because it looks nicer
		// 		FlxTween.tween(introSkipSprite, {alpha: 0.49}, 1.25);
		// 		new FlxTimer().start(5, function(tmr:FlxTimer)
		// 		{
		// 			FlxTween.tween(introSkipSprite, {alpha:0.08}, 1.5, {ease: FlxEase.quadInOut });
		// 		});
		// 	}
		}

		songStarted = true;

		setOnScripts('songLength', songLength);
		callOnScripts('onSongStart');
	}

	var skippedIntro:Bool = false;
	var introSkip:Int = 0;
	function skipIntro(?songPosToGoTo:Float=0){
		trace((songPosToGoTo==0?"Skipped Intro!":("Went to position: " + songPosToGoTo)));
		skippedIntro = true;

		FlxG.sound.music.pause();
		vocals.pause();
		opponentVocals.pause();
		if(songPosToGoTo == 0) Conductor.songPosition = introSkip * 1000;
		else Conductor.songPosition = songPosToGoTo;
		notes.forEachAlive(function(daNote:Note)
		{
			if(daNote.strumTime + 800 < Conductor.songPosition) {
				daNote.active = false;
				daNote.visible = false;

				//if(daNote.trailShit!=null)
				//	arrowTrails.remove(daNote.trailShit);
				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
		});
		for (i in 0...unspawnNotes.length) {
			var daNote:Note = unspawnNotes[0];
			if(daNote.strumTime + 800 >= Conductor.songPosition) {
				break;
			}
			daNote.active = false;
			daNote.visible = false;
			daNote.kill();
			unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
			daNote.destroy();
		}
		FlxG.sound.music.time = Conductor.songPosition;
		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		vocals.time = Conductor.songPosition;
		vocals.play();
		vocals.pitch = playbackRate;
		opponentVocals.time = Conductor.songPosition;
		opponentVocals.play();
		opponentVocals.pitch = playbackRate;
		#if DISCORD_ALLOWED
		if (startTimer != null && startTimer.finished)
		{
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", hitmansHud.getDiscordRichName(), true, songLength - Conductor.songPosition - ClientPrefs.data.noteOffset);
		}
		else
		{
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", hitmansHud.getDiscordRichName());
		}
		#end
	}

	public static var threadbeat:Array<ThreadBeatList> = [];
	public static function threadBeat(setbeat:Float, complete:Void->Void)
	{
		threadbeat.push({
			beat: setbeat,
			func: complete,
		});
	}

	public static var threadupdate:Array<ThreadUpdateList> = [];
	public static function threadUpdate(startBeat:Float, endBeat:Float, funcAfter:Void->Void, onCompleteFunc:Void->Void)
	{
		threadupdate.push({
			startbeat: startBeat,
			endbeat: endBeat,
			func: funcAfter,
			oncompletefunc: onCompleteFunc
		});
	}

	private var noteTypes:Array<String> = [];
	private var eventsPushed:Array<String> = [];
	private var totalColumns: Int = 4;

	private function generateSong():Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeed = PlayState.SONG.speed;
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype');
		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed');
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed');
		}

		var songData = SONG;
		Conductor.bpm = songData.bpm;

		curSong = songData.song;
		final formattedSong:String = Paths.formatToSongPath(PlayState.SONG.song);

		vocals = new FlxSound();
		opponentVocals = new FlxSound();
		try
		{
			if (songData.needsVoices)
			{
				var sng_name = Paths.formatToSongPath(songData.song); //!
				var legacy_path = Paths.getPath('songs/${sng_name}/Voices.ogg');
				var opponent_path = Paths.getPath('songs/${sng_name}/Voices-Opponent.ogg');
				var is_base_legacy_path = legacy_path.startsWith("assets/shared/");
				var is_base_opponent_path = opponent_path.startsWith("assets/shared/");

				var legacyVoices = Paths.voices(songData.song);
				if (storyDifficulty == 1 && (formattedSong == "system-reloaded" || formattedSong == "metakill")) 
				{
					legacyVoices = Paths.voicesClassic(songData.song, (boyfriend.vocalsFile == null || boyfriend.vocalsFile.length < 1) ? 'Player' : boyfriend.vocalsFile);
					if (legacyVoices == null) legacyVoices = Paths.voicesClassic(songData.song);
				}
				if(legacyVoices == null){
					var playerVocals = Paths.voices(songData.song, (boyfriend.vocalsFile == null || boyfriend.vocalsFile.length < 1) ? 'Player' : boyfriend.vocalsFile);
					vocals.loadEmbedded(playerVocals);
				}
				else vocals.loadEmbedded(legacyVoices);

				if(legacyVoices == null || (is_base_legacy_path == is_base_opponent_path)){
					var oppVocals = Paths.voices(songData.song, (dad.vocalsFile == null || dad.vocalsFile.length < 1) ? 'Opponent' : dad.vocalsFile);
					if (storyDifficulty == 1 && (formattedSong == "system-reloaded" || formattedSong == "metakill")) 
					{
						oppVocals = Paths.voicesClassic(songData.song, (dad.vocalsFile == null || dad.vocalsFile.length < 1) ? 'Opponent' : dad.vocalsFile);
						if (oppVocals == null) oppVocals = Paths.voicesClassic(songData.song);
					}
					if (oppVocals != null && oppVocals.length > 0) opponentVocals.loadEmbedded(oppVocals);
				}
			}
		}
		catch (e:Dynamic) {}

		#if FLX_PITCH
		vocals.pitch = playbackRate;
		opponentVocals.pitch = playbackRate;
		#end
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(opponentVocals);

		inst = new FlxSound();
		try
		{
			inst.loadEmbedded(Paths.inst(altInstrumentals ?? songData.song));
			if (storyDifficulty == 1 && (formattedSong == "system-reloaded" || formattedSong == "metakill"))
				inst.loadEmbedded(Paths.instClassic(altInstrumentals ?? songData.song));
		}
		catch (e:Dynamic) {}
		FlxG.sound.list.add(inst);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		try
		{
			var eventsChart:SwagSong = Song.getChart('events', songName);
			if(eventsChart != null)
				for (event in eventsChart.events) //Event Notes
					for (i in 0...event[1].length)
						makeEvent(event, i);
		}
		catch(e:Dynamic) {}

		var oldNote:Note = null;
		var sectionsData:Array<SwagSection> = PlayState.SONG.notes;
		var ghostNotesCaught:Int = 0;
		var daBpm:Float = Conductor.bpm;
	
		for (section in sectionsData)
		{
			if (section.changeBPM != null && section.changeBPM && section.bpm != null && daBpm != section.bpm)
				daBpm = section.bpm;

			for (i in 0...section.sectionNotes.length)
			{
				final songNotes: Array<Dynamic> = section.sectionNotes[i];
				var spawnTime: Float = songNotes[0];
				var noteColumn: Int = Std.int(songNotes[1] % totalColumns);
				var holdLength: Float = songNotes[2];
				var noteType: String = songNotes[3];
				if (Math.isNaN(holdLength))
					holdLength = 0.0;

				var gottaHitNote:Bool = (songNotes[1] < totalColumns);

				if (i != 0) {
					// CLEAR ANY POSSIBLE GHOST NOTES
					for (evilNote in unspawnNotes) {
						var matches: Bool = (noteColumn == evilNote.noteData && gottaHitNote == evilNote.mustPress && evilNote.noteType == noteType);
						if (matches && Math.abs(spawnTime - evilNote.strumTime) < flixel.math.FlxMath.EPSILON) {
							if (evilNote.tail.length > 0)
								for (tail in evilNote.tail)
								{
									tail.destroy();
									unspawnNotes.remove(tail);
								}
							evilNote.destroy();
							unspawnNotes.remove(evilNote);
							ghostNotesCaught++;
							//continue;
						}
					}
				}

				var swagNote:Note = new Note(spawnTime, noteColumn, oldNote);
				var isAlt: Bool = section.altAnim && !gottaHitNote;
				swagNote.gfNote = (section.gfSection && gottaHitNote == section.mustHitSection);
				swagNote.animSuffix = isAlt ? "-alt" : "";
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = holdLength;
				swagNote.noteType = noteType;
	
				swagNote.scrollFactor.set();
				unspawnNotes.push(swagNote);

				var curStepCrochet:Float = 60 / daBpm * 1000 / 4.0;
				final roundSus:Int = Math.round(swagNote.sustainLength / curStepCrochet);
				if(roundSus > 0)
				{
					for (susNote in 0...roundSus)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(spawnTime + (curStepCrochet * susNote), noteColumn, oldNote, true);
						sustainNote.animSuffix = swagNote.animSuffix;
						sustainNote.mustPress = swagNote.mustPress;
						sustainNote.gfNote = swagNote.gfNote;
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
						swagNote.tail.push(sustainNote);

						sustainNote.correctionOffset = swagNote.height / 2;
						if(!PlayState.isPixelStage)
						{
							if(oldNote.isSustainNote)
							{
								oldNote.scale.y *= Note.SUSTAIN_SIZE / oldNote.frameHeight;
								oldNote.scale.y /= playbackRate;
								oldNote.resizeByRatio(curStepCrochet / Conductor.stepCrochet);
							}

							if(ClientPrefs.data.downScroll)
								sustainNote.correctionOffset = 0;
						}
						else if(oldNote.isSustainNote)
						{
							oldNote.scale.y /= playbackRate;
							oldNote.resizeByRatio(curStepCrochet / Conductor.stepCrochet);
						}

						if (sustainNote.mustPress) sustainNote.x += FlxG.width / 2; // general offset
						else if(ClientPrefs.data.middleScroll)
						{
							sustainNote.x += 310;
							if(noteColumn > 1) //Up and Right
								sustainNote.x += FlxG.width / 2 + 25;
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.data.middleScroll)
				{
					swagNote.x += 310;
					if(noteColumn > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}
				if(!noteTypes.contains(swagNote.noteType))
					noteTypes.push(swagNote.noteType);

				oldNote = swagNote;
			}
		}
		trace('["${SONG.song.toUpperCase()}" CHART INFO]: Ghost Notes Cleared: $ghostNotesCaught');
		for (event in songData.events) //Event Notes
			for (i in 0...event[1].length)
				makeEvent(event, i);

		unspawnNotes.sort(sortByTime);
		generatedMusic = true;
	}

	// called only once per different event (Used for precaching)
	function eventPushed(event:EventNote) {
		eventPushedUnique(event);
		if(eventsPushed.contains(event.event)) {
			return;
		}

		stagesFunc(function(stage:BaseStage) stage.eventPushed(event));
		eventsPushed.push(event.event);
	}

	// called by every event with the same name
	function eventPushedUnique(event:EventNote) {
		switch(event.event) {
			case "Change Character":
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						var val1:Int = Std.parseInt(event.value1);
						if(Math.isNaN(val1)) val1 = 0;
						charType = val1;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Play Sound':
				Paths.sound(event.value1); //Precache sound
		}
		stagesFunc(function(stage:BaseStage) stage.eventPushedUnique(event));
	}

	function eventEarlyTrigger(event:EventNote):Float {
		var returnedValue:Dynamic = callOnScripts('eventEarlyTrigger', [event.event, event.value1, event.value2, event.strumTime], true, [], [0]);
		returnedValue = Std.parseFloat(returnedValue);
		if(!Math.isNaN(returnedValue) && returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	public static function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function makeEvent(event:Array<Dynamic>, i:Int)
	{
		var subEvent:EventNote = {
			strumTime: event[0] + ClientPrefs.data.noteOffset,
			event: event[1][i][0],
			value1: event[1][i][1],
			value2: event[1][i][2]
		};
		eventNotes.push(subEvent);
		eventPushed(subEvent);
		callOnScripts('onEventPushed', [subEvent.event, subEvent.value1 != null ? subEvent.value1 : '', subEvent.value2 != null ? subEvent.value2 : '', subEvent.strumTime]);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		var strumLineY:Float = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 50;
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.data.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.data.middleScroll && !forceRightScroll || forceMiddleScroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(!forcedAScroll ? (ClientPrefs.data.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X) : 
			(if (forceRightScroll && !forceMiddleScroll) STRUM_X 
			else if (forceMiddleScroll && !forceRightScroll) STRUM_X_MIDDLESCROLL 
			else ClientPrefs.data.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X), strumLineY, i, player);
			babyArrow.downScroll = ClientPrefs.data.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else babyArrow.alpha = targetAlpha;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
			{
				if(!forcedAScroll ? (ClientPrefs.data.middleScroll) : (forceMiddleScroll && !forceRightScroll))
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.playerPosition();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		stagesFunc(function(stage:BaseStage) stage.openSubState(SubState));
		if (paused)
		{
			if (videoCutscene != null)
				videoCutscene.pause(); 
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				opponentVocals.pause();
			}
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = false);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = false);
		}

		super.openSubState(SubState);
	}

	public var canResync:Bool = true;
	override function closeSubState()
	{
		super.closeSubState();
		
		stagesFunc(function(stage:BaseStage) stage.closeSubState());
		if (PauseSubState.goToOptions){
			if (PauseSubState.goBack)
			{
				PauseSubState.goToOptions = false;

				openSubState(new PauseSubState());
				PauseSubState.goBack = false;
			}
			else
			{
				openSubState(new options.OptionsMenu(true));
			}
		}else if (PauseSubState.goToModifiers)
		{
			trace("pause thingyt");
			if (PauseSubState.goBackToPause)
			{
				trace("pause thingyt");
				PauseSubState.goToModifiers = false;

				openSubState(new PauseSubState());
				PauseSubState.goBackToPause = false;
			}
			else
			{
				openSubState(new options.GameplayChangersSubstate(true));
			}
		}
		else if (paused)
		{	
			if (FlxG.sound.music != null && !startingSong && canResync)
			{
				resyncVocals();
			}
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = true);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = true);

			paused = false;
			callOnScripts('onResume');
			resetRPC(startTimer != null && startTimer.finished);
		}

		if (videoCutscene != null && !paused && !PauseSubState.goToModifiers && !PauseSubState.goToOptions && !PauseSubState.goBack)
			videoCutscene.resume(); 
	}

	override public function onFocus():Void
	{	
		if (videoCutscene != null && !paused && !PauseSubState.goToModifiers && !PauseSubState.goToOptions && !PauseSubState.goBack)
			videoCutscene.resume(); 
		if (health > 0 && !paused) resetRPC(Conductor.songPosition > 0.0);
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		if (videoCutscene != null)
			videoCutscene.pause(); 
		#if DISCORD_ALLOWED
		if (health > 0 && !paused && autoUpdateRPC) DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", hitmansHud.getDiscordRichName());
		#end

		super.onFocusLost();
	}

	// Updating Discord Rich Presence.
	public var autoUpdateRPC:Bool = true; //performance setting for custom RPC things
	function resetRPC(?showTime:Bool = false)
	{
		#if DISCORD_ALLOWED
		if(!autoUpdateRPC) return;

		if (showTime)
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", hitmansHud.getDiscordRichName(), true, songLength - Conductor.songPosition - ClientPrefs.data.noteOffset);
		else
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", hitmansHud.getDiscordRichName());
		#end
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		trace('resynced vocals at ' + Math.floor(Conductor.songPosition));

		FlxG.sound.music.play();
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;

		var checkVocals = [vocals, opponentVocals];
		for (voc in checkVocals)
		{
			if (FlxG.sound.music.time < vocals.length)
			{
				voc.time = FlxG.sound.music.time;
				#if FLX_PITCH voc.pitch = playbackRate; #end
				voc.play();
			}
			else voc.pause();
		}
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = false;
	var freezeCamera:Bool = false;
	var allowDebugKeys:Bool = true;

	override public function update(elapsed:Float)
	{
		if(!inCutscene && !paused && !freezeCamera) {
			FlxG.camera.followLerp = 0.04 * cameraSpeed * playbackRate;
			if(!startingSong && !endingSong && boyfriend.getAnimationName().startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}
		else FlxG.camera.followLerp = 0;
		callOnScripts('onUpdate', [elapsed]);

		if (notITGMod && SONG.notITG && !SONG.newModchartTool)
			playfieldRenderer.speed = playbackRate; //LMAO IT LOOKS SOO GOOFY AS FUCK
		// if (aftBitmap != null) aftBitmap.update(elapsed); //if it fail this don't load

		if (drain){
			if (!ClientPrefs.data.casualMode){
				health -= 0.0035;
				new FlxTimer().start(3, function(subtmr2:FlxTimer)
					{
					drain = false;
				});
			}else if (ClientPrefs.data.casualMode){
				health -= 0.002;
				new FlxTimer().start(3, function(subtmr2:FlxTimer)
					{
					drain = false;
				});
			}
		}
		if (gain){
			if (!ClientPrefs.data.casualMode){
				health += 0.003;
				new FlxTimer().start(3, function(subtmr3:FlxTimer)
					{
					gain = false;
				});
			}else if (ClientPrefs.data.casualMode){
				health += 0.004;
				new FlxTimer().start(3, function(subtmr3:FlxTimer)
					{
					gain = false;
				});
			}
		}

		super.update(elapsed);

		setOnScripts('curDecStep', curDecStep);
		setOnScripts('curDecBeat', curDecBeat);

		if ((controls.PAUSE /*|| !Main.focused*/ #if android || FlxG.android.justReleased.BACK #end) && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnScripts('onPause', null, true);
			if(ret != LuaUtils.Function_Stop) {
				openPauseMenu();
			}
		}

		if(!endingSong && !inCutscene && allowDebugKeys)
		{
			if (controls.justPressed('debug_1'))
			{
				if (blockedHitmansSongs.contains(Paths.formatToSongPath(SONG.song)) && !ClientPrefs.data.edwhakMode && !ClientPrefs.data.developerMode){
					antiCheat();
				}
				else openChartEditor();
			}
			else if (controls.justPressed('debug_2'))
				openCharacterEditor();
			else if (controls.justPressed('debug_3'))
			{
				if (blockedHitmansSongs.contains(Paths.formatToSongPath(SONG.song)) && !ClientPrefs.data.edwhakMode && !ClientPrefs.data.developerMode){
					antiCheat();
				}
				else openModchartEditor();
			}
		}

		if (health <= 0)
			health = 0;
		else if (health >= maxUsedHealth)
			health = maxUsedHealth;

		if (startedCountdown && !paused)
		{
			Conductor.songPosition += elapsed * 1000 * playbackRate;
			if (Conductor.songPosition >= Conductor.offset)
			{
				Conductor.songPosition = FlxMath.lerp(FlxG.sound.music.time + Conductor.offset, Conductor.songPosition, Math.exp(-elapsed * 5));
				var timeDiff:Float = Math.abs((FlxG.sound.music.time + Conductor.offset) - Conductor.songPosition);
				if (timeDiff > 1000 * playbackRate)
					Conductor.songPosition = Conductor.songPosition + 1000 * FlxMath.signOf(timeDiff);
			}
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= Conductor.offset)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5 + Conductor.offset;
		}
		else if (!paused && updateTime)
		{
			var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.data.noteOffset);
			songPercent = (curTime / songLength);

			var songCalc:Float = (songLength - curTime);
			if(ClientPrefs.data.timeBarType == 'Time Elapsed') songCalc = curTime;

			var secondsTotal:Int = Math.floor(songCalc / 1000);
			if(secondsTotal < 0) secondsTotal = 0;

			hitmansHud.setTime(songLength);
		}

		
		while (threadbeat.length > 0 && threadbeat[0] != null && curDecBeat >= threadbeat[0].beat) {
			threadbeat[0].func();
			threadbeat.splice(0, 1);
		}

		while (threadupdate.length > 0 && threadupdate[0] != null) {
			if (curDecBeat >= threadupdate[0].startbeat && curDecBeat < threadupdate[0].endbeat)
				threadupdate[0].func();
			else if (curDecBeat >= threadupdate[0].endbeat){
				if (threadupdate[0].oncompletefunc != null) threadupdate[0].oncompletefunc();
				threadupdate.splice(0, 1);
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, Math.exp(-elapsed * 3.125 * camZoomingDecay * playbackRate));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, Math.exp(-elapsed * 3.125 * camZoomingDecay * playbackRate));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.data.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime * playbackRate;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned = true;

				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote, dunceNote.strumTime]);
				callOnHScript('onSpawnNote', [dunceNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if(!inCutscene)
			{
				if(!cpuControlled)
					keysCheck();
				else
					playerDance();

				if(notes.length > 0)
				{
					if(startedCountdown)
					{
						var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
						notes.forEachAlive(function(daNote:Note)
						{
							var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
							if(!daNote.mustPress) strumGroup = opponentStrums;

							var strum:StrumNote = strumGroup.members[daNote.noteData];
							daNote.followStrumNote(strum, fakeCrochet, songSpeed / playbackRate);

							if (daNote.extraData.get("constantHealth") != null)
							{
								addHealth = (daNote.extraData.get("constanHealth") == true);
							}

							if(daNote.mustPress)
							{
								if(cpuControlled && !daNote.blockHit && daNote.canBeHit && (daNote.isSustainNote || daNote.strumTime <= Conductor.songPosition))
									goodNoteHit(daNote);
							}
							else if (daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
								opponentNoteHit(daNote);

							if(daNote.isSustainNote && strum.sustainReduce) daNote.clipToStrumNote(strum);

							// Kill extremely late notes and cause misses
							if (Conductor.songPosition - daNote.strumTime > noteKillOffset)
							{
								if (daNote.mustPress && !cpuControlled && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit))
									noteMiss(daNote);

								daNote.active = daNote.visible = false;
								invalidateNote(daNote);
							}
						});
					}
					else
					{
						notes.forEachAlive(function(daNote:Note)
						{
							daNote.canBeHit = false;
							daNote.wasGoodHit = false;
						});
					}
				}
			}
			checkEventNote();
		}

		if (addHealth)
		{
			health += 0.007;
		}

		
		if (FunkinLua.lua_Shaders != null)
		{
			for(shaderKey in FunkinLua.lua_Shaders.keys())
			{
				if (FunkinLua.lua_Shaders.exists(shaderKey))
					FunkinLua.lua_Shaders.get(shaderKey).update(elapsed);
			}
		}

	 	hitmansHud.setHealth(health, elapsed, playbackRate);
		hitmansHud.setScore(songScore, songMisses, ratingName, ratingPercent, ratingFC, combo, comboOp, separateCombo);

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		setOnScripts('botPlay', cpuControlled);
		callOnScripts('onUpdatePost', [elapsed]);

		#if debug
		if(FlxG.keys.justPressed.F1) { 
			KillNotes();
			endSong();
		}
		#end

		if (ClientPrefs.data.quantization)
		{
			for (strum in playerStrums){
				if (strum.animation.curAnim.name == 'static'){
					strum.rgbShader.r = 0xFF808080;
					strum.rgbShader.b = 0xFFFFFFFF;
				}
			}
		}
	}

	var addHealth:Bool = false;

	
	function antiCheat()
	{
		if (FlxG.sound.music.playing)
			{
				FlxG.sound.music.pause();
				if(vocals != null) vocals.pause();
			}

			var edwhakBlack:BGSprite = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
			edwhakBlack.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.BLACK);
			edwhakBlack.scrollFactor.set(1);

			var edwhakBG:BGSprite = new BGSprite('Edwhak/Hitmans/unused/cheat-bg');
			edwhakBG.setGraphicSize(FlxG.width, FlxG.height);
			//edwhakBG.x += (FlxG.width/2); //Mmmmmm scuffed positioning, my favourite!
			//edwhakBG.y += (FlxG.height/2) - 20;
			edwhakBG.updateHitbox();
			edwhakBG.scrollFactor.set(1);
			edwhakBG.screenCenter();
			edwhakBG.x=0;

			var cheater:BGSprite = new BGSprite('Edwhak/Hitmans/unused/cheat', -600, -480, 0.5, 0.5);
			cheater.setGraphicSize(Std.int(cheater.width * 1.5));
			cheater.updateHitbox();
			cheater.scrollFactor.set(1);
			cheater.screenCenter();	
			cheater.x+=50;

			add(edwhakBlack);
			add(edwhakBG);
			add(cheater);
			FlxG.camera.shake(0.05,5);
			FlxG.sound.play(Paths.sound('Edwhak/cheatercheatercheater'), 1, true);
			#if desktop
			// Updating Discord Rich Presence
			DiscordClient.changePresence("CHEATER CHEATER CHEATER CHEATER CHEATER CHEATER ", StringTools.replace(SONG.song, '-', ' '));
			#end

			//Stolen from the bob mod LMAO
			new FlxTimer().start(0.01, function(tmr:FlxTimer)
				{
					Lib.application.window.move(Lib.application.window.x + FlxG.random.int( -10, 10),Lib.application.window.y + FlxG.random.int( -8, 8));
				}, 0);

			new FlxTimer().start(1.5, function(tmr:FlxTimer) 
			{
				//trace("Quit");
				System.exit(0);
			});
	}

	public static function resetPlayData()
	{
		PlayState.deathCounter = 0;
		PlayState.seenCutscene = false;
		PlayState.checkpointsUsed = 0;
		PlayState.checkpointHistory = [];
		PlayState.startOnTime = 0;
		PlayState.ignoreCheckpointOnStart = false;
	}

	function openModchartEditor(?old:Bool)
	{
		resetPlayData();
		persistentUpdate = false;
		paused = true;
		MusicBeatState.switchState(new modcharting.ModchartEditorState());
		chartingMode = true;
	
		#if desktop
		DiscordClient.changePresence("Modchart Editor", null, null, true);
		DiscordClient.resetClientID();
		#end
	}

	function openPauseMenu()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}
		if(!cpuControlled)
		{
			for (note in playerStrums)
				if(note.animation.curAnim != null && note.animation.curAnim.name != 'static')
				{
					note.playAnim('static');
					note.resetAnim = 0;
				}
		}
		openSubState(new PauseSubState());

		#if DISCORD_ALLOWED
		if(autoUpdateRPC) DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", hitmansHud.getDiscordRichName());
		#end
	}

	public function openChartEditor()
	{
		resetPlayData();
		canResync = false;
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		chartingMode = true;
		paused = true;

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		if(vocals != null)
			vocals.pause();
		if(opponentVocals != null)
			opponentVocals.pause();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Chart Editor", null, null, true);
		DiscordClient.resetClientID();
		#end

		MusicBeatState.switchState(new ChartingState());
	}

	function openCharacterEditor()
	{
		resetPlayData();
		canResync = false;
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		if(vocals != null)
			vocals.pause();
		if(opponentVocals != null)
			opponentVocals.pause();

		#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
		MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	public var diedPractice:Bool = false; //to fix all stuff since isDead bug all LMAO
	public var gameOverTimer:FlxTimer;
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead && gameOverTimer == null)
		{
			canPause = false;
			var ret:Dynamic = callOnScripts('onGameOver', null, true);
			if(ret != LuaUtils.Function_Stop)
			{
				FlxG.animationTimeScale = 1;
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;
				canResync = false;

				persistentUpdate = false;
				persistentDraw = false;
				FlxTimer.globalManager.clear();
				FlxTween.globalManager.clear();
				FlxG.camera.setFilters([]);

				if(GameOverSubstate.deathDelay > 0)
				{
					gameOverTimer = new FlxTimer().start(GameOverSubstate.deathDelay, function(_)
					{
						vocals.stop();
						opponentVocals.stop();
						FlxG.sound.music.stop();
						openSubState(new GameOverSubstate(boyfriend));
						gameOverTimer = null;
					});
				}
				else
				{
					vocals.stop();
					opponentVocals.stop();
					FlxG.sound.music.stop();
					openSubState(new GameOverSubstate(boyfriend));
				}

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if DISCORD_ALLOWED
				// Game Over doesn't get his its variable because it's only used here
				if(autoUpdateRPC) DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", hitmansHud.getDiscordRichName());
				#end
				isDead = true;
				return true;
			}
		} else if (((skipHealthCheck && instakillOnMiss) || health <= 0) && practiceMode && !diedPractice){
			diedPractice = true; //bro died in practice mode LMAO
			var youdied:huds.DiedHud = new huds.DiedHud(deathVariableTXT); //should work ig?
			youdied.cameras = [camOther];
        	add(youdied);
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				return;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEvent(eventNotes[0].event, value1, value2, leStrumTime);
			eventNotes.shift();
		}
	}

	public function triggerEvent(eventName:String, value1:String, value2:String, strumTime:Float) {
		var flValue1:Null<Float> = Std.parseFloat(value1);
		var flValue2:Null<Float> = Std.parseFloat(value2);
		if(Math.isNaN(flValue1)) flValue1 = null;
		if(Math.isNaN(flValue2)) flValue2 = null;

		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				if(flValue2 == null || flValue2 <= 0) flValue2 = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = flValue2;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = flValue2;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = flValue2;
				}

			case 'Set GF Speed':
				if(flValue1 == null || flValue1 < 1) flValue1 = 1;
				gfSpeed = Math.round(flValue1);

			case 'Add Camera Zoom':
				if(ClientPrefs.data.camZooms && FlxG.camera.zoom < 1.35) {
					if(flValue1 == null) flValue1 = 0.015;
					if(flValue2 == null) flValue2 = 0.03;

					FlxG.camera.zoom += flValue1;
					camHUD.zoom += flValue2;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						if(flValue2 == null) flValue2 = 0;
						switch(Math.round(flValue2)) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					isCameraOnForcedPos = false;
					if(flValue1 != null || flValue2 != null)
					{
						isCameraOnForcedPos = true;
						if(flValue1 == null) flValue1 = 0;
						if(flValue2 == null) flValue2 = 0;
						camFollow.x = flValue1;
						camFollow.y = flValue2;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType){
					case 1:
						switch(value2.toLowerCase()) {
							case 'edwhak' | 'he' | 'edwhakbroken' | 'edkbmassacre' | 'frontedwhak':
								edwhakIsEnemy = true;
							default:
								edwhakIsEnemy = false;
						}
					case 0:
						switch(value2.toLowerCase()) {
							case 'edwhak' | 'he' | 'edwhakbroken' | 'edkbmassacre' | 'frontedwhak':
								Note.canDamagePlayer = false;
								Note.edwhakIsPlayer = true;
							default:
								Note.canDamagePlayer = true;
								Note.edwhakIsPlayer = false;
						}
					
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							var edwhakVariable:Array<String> = ['Edwhak', 'he', 'edwhakBroken', 'edkbmassacre'];
							switch(edwhakVariable.contains(boyfriend.curCharacter)){
								case true:
									hitmansHud.iconP1.changeIcon('icon-edwhak-pl');
								case false:
									hitmansHud.iconP1.changeIcon(boyfriend.healthIcon);
								default:
									hitmansHud.iconP1.changeIcon(boyfriend.healthIcon); //if it crash for some reazon?
							}
						}
						setOnScripts('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf-') || dad.curCharacter == 'gf';
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf-') && dad.curCharacter != 'gf') {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							hitmansHud.iconP2.changeIcon(dad.healthIcon);
						}
						setOnScripts('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2)) {
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnScripts('gfName', gf.curCharacter);
						}
				}
				hitmansHud.reloadHealthBarColors();

			case 'Change Scroll Speed':
				if (songSpeedType != "constant")
				{
					if(flValue1 == null) flValue1 = 1;
					if(flValue2 == null) flValue2 = 0;

					var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed') * flValue1;
					if(flValue2 <= 0)
						songSpeed = newValue;
					else
						songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, flValue2 / playbackRate, {ease: FlxEase.linear, onComplete:
							function (twn:FlxTween)
							{
								songSpeedTween = null;
							}
						});
				}
			case 'Vslice Scroll Speed':
				if (songSpeedType != "constant")
				{
					if(flValue1 == null) flValue1 = 1;
					if(flValue2 == null) flValue2 = 0;

					var newValue:Float = ClientPrefs.getGameplaySetting('scrollspeed') * flValue1;
					if(flValue2 <= 0)
						songSpeed = newValue;
					else
						songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, flValue2 / playbackRate, {ease: FlxEase.quadInOut, onComplete:
							function (twn:FlxTween)
							{
								songSpeedTween = null;
							}
						});
				}
			case 'Set Property':
				try
				{
					var trueValue:Dynamic = value2.trim();
					if (trueValue == 'true' || trueValue == 'false') trueValue = trueValue == 'true';
					else if (flValue2 != null) trueValue = flValue2;
					else trueValue = value2;

					var split:Array<String> = value1.split('.');
					if(split.length > 1) {
						LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1], trueValue);
					} else {
						LuaUtils.setVarInArray(this, value1, trueValue);
					}
				}
				catch(e:Dynamic)
				{
					var len:Int = e.message.indexOf('\n') + 1;
					if(len <= 0) len = e.message.length;
					#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
					addTextToDebug('ERROR ("Set Property" Event) - ' + e.message.substr(0, len), FlxColor.RED);
					#else
					FlxG.log.warn('ERROR ("Set Property" Event) - ' + e.message.substr(0, len));
					#end
				}

			case 'Play Sound':
				if(flValue2 == null) flValue2 = 1;
				FlxG.sound.play(Paths.sound(value1), flValue2);
			case 'SetCameraBop': //P-slice event notes
				var val1 = Std.parseFloat(value1);
				var val2 = Std.parseFloat(value2);
				camZoomingMult = !Math.isNaN(val2) ? val2 : 1;
				camZoomingFrequency = !Math.isNaN(val1) ? val1 : 4;
			case 'ZoomCamera': //defaultCamZoom
				var keyValues = value1.split(",");
				if(keyValues.length != 2) {
					trace("INVALID EVENT VALUE");
					return;
				}
				var floaties = keyValues.map(s -> Std.parseFloat(s));
				if(mikolka.funkin.utils.ArrayTools.findIndex(floaties,s -> Math.isNaN(s)) != -1) {
					trace("INVALID FLOATIES");
					return;
				}
				var easeFunc = LuaUtils.getTweenEaseByString(value2);
				if(zoomTween != null) zoomTween.cancel();
				var targetZoom = floaties[1]*defaultStageZoom;
				zoomTween = FlxTween.tween(this,{ defaultCamZoom:targetZoom},(Conductor.stepCrochet/1000)*floaties[0],{
					onStart: (x) ->{
						//camZooming = false;
						camZoomingDecay = 7;
					},
					ease: easeFunc,
					onComplete: (x) ->{
						defaultCamZoom = targetZoom;
						camZoomingDecay = 1;
						//camZooming = true;
						zoomTween = null;
					}
				});
			case "Set CheckPoint":
				onCheckPoint(strumTime, (value1.toLowerCase() == "hide"));
			case "Sustain Divider":
				sustainDivider = Std.parseFloat(value1);
		}

		stagesFunc(function(stage:BaseStage) stage.eventCalled(eventName, value1, value2, flValue1, flValue2, strumTime));
		callOnScripts('onEvent', [eventName, value1, value2, strumTime]);
	}

	public function moveCameraSection(?sec:Null<Int>):Void {
		if(sec == null) sec = curSection;
		if(sec < 0) sec = 0;

		if(SONG.notes[sec] == null) return;

		if (gf != null && SONG.notes[sec].gfSection)
		{
			moveCameraToGirlfriend();
			callOnScripts('onMoveCamera', ['gf']);
			return;
		}

		var isDad:Bool = (SONG.notes[sec].mustHitSection != true);
		moveCamera(isDad);
		if (isDad)
			callOnScripts('onMoveCamera', ['dad']);
		else
			callOnScripts('onMoveCamera', ['boyfriend']);
	}
	
	public function moveCameraToGirlfriend()
	{
		camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
		camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
		camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
		tweenCamIn();
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			if(dad == null) return;
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
			if(boyfriend == null) return;
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (songName == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	public function tweenCamIn() {
		if (songName == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		hitmansHud.updateTime = false;
		FlxG.sound.music.volume = 0;

		vocals.volume = 0;
		vocals.pause();
		opponentVocals.volume = 0;
		opponentVocals.pause();

		if(ClientPrefs.data.noteOffset <= 0 || ignoreNoteOffset) {
			endCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.data.noteOffset / 1000, function(tmr:FlxTimer) {
				endCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong()
	{
		#if TOUCH_CONTROLS_ALLOWED
		hitbox.visible = #if !android touchPad.visible = #end false;
		#end
		//Should kill you if you tried to cheat
		if(!startingSong)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset)
					health -= 0.05 * healthLoss;
			});
			for (daNote in unspawnNotes)
			{
				if(daNote != null && daNote.strumTime < songLength - Conductor.safeZoneOffset)
					health -= 0.05 * healthLoss;
			}

			if(doDeathCheck()) {
				return false;
			}
		}

		hitmansHud.timeBarBG.visible = false;
		hitmansHud.timeBar.visible = false;
		hitmansHud.timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		hitmansHud.updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		var weekNoMiss:String = WeekData.getWeekFileName() + '_nomiss';
		checkForAchievement([weekNoMiss, 'ur_bad', 'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);
		#end

		var ret:Dynamic = callOnScripts('onEndSong', null, true);
		var accPts = ratingPercent * totalPlayed;
		if(ret != LuaUtils.Function_Stop && !transitioning)
		{
			var tempActiveTallises =
			{
          		score: songScore,
		  		accPoints: accPts,
				
          		sick: ratingsData[0].hits,
            	good: ratingsData[1].hits,
              	bad: ratingsData[2].hits,
          		shit: ratingsData[3].hits,
          		missed: songMisses,
          		combo: combo,
            	maxCombo: maxCombo,
              	totalNotesHit: totalPlayed,
              	totalNotes: 69,
            		
        	};

			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return false;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;
				campaignSaveData = FunkinTools.combineTallies(campaignSaveData,tempActiveTallises);

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					var prevScore =Highscore.getWeekScore(WeekData.weeksList[storyWeek],storyDifficulty);
					var wasFC = Highscore.getWeekFC(WeekData.weeksList[storyWeek],storyDifficulty);
					var prevAcc = Highscore.getWeekAccuracy(WeekData.weeksList[storyWeek],storyDifficulty);

					var prevRank = Scoring.calculateRankFromData(prevScore,prevAcc,wasFC);
					//FlxG.sound.playMusic(Paths.music('freakyMenu'));
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

					canResync = false;

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay')) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						var weekAccuracy = FlxMath.bound(campaignSaveData.accPoints/campaignSaveData.totalNotesHit,0,1);
						Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty,weekAccuracy,campaignMisses == 0);

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					zoomIntoResultsScreen(prevScore<campaignSaveData.score,campaignSaveData,prevRank);
					campaignSaveData = FunkinTools.newTali();

					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = Difficulty.getFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;
					
					#if !switch
					//!! We have to save the score for current song BEFORE loading the next one
					if(!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay')){
						var percent:Float = ratingPercent;
						if(Math.isNaN(percent)) percent = 0;
						Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent,songMisses == 0);
					}
					#end

					Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					canResync = false;
					LoadingState.prepareToSong();
					LoadingState.loadAndSwitchState(new PlayState(), false, false);
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				var wasFC = Highscore.getFCState(curSong,PlayState.storyDifficulty);
				var prevScore = Highscore.getScore(curSong,PlayState.storyDifficulty);
				var prevAcc = Highscore.getRating(curSong,PlayState.storyDifficulty);

				var prevRank = Scoring.calculateRankFromData(prevScore,prevAcc,wasFC);

				#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

				canResync = false;
				zoomIntoResultsScreen(prevScore<tempActiveTallises.score,tempActiveTallises,prevRank);
				changedDifficulty = false;

				#if !switch
				if(!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay')){
					var percent:Float = ratingPercent;
					if(Math.isNaN(percent)) percent = 0;
					Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent,songMisses == 0);
				}
				#end
			}

			

			transitioning = true;
		}
		return true;
	}

		/**
   * Play the camera zoom animation and then move to the results screen once it's done.
   */
   function zoomIntoResultsScreen(isNewHighscore:Bool,scoreData:SaveScoreData,prevScoreRank:ScoringRank):Void
	{
		var botplay = ClientPrefs.getGameplaySetting('botplay');
		if(!ClientPrefs.data.vsliceResults || botplay){
			var resultingAccuracy = Math.min(1,scoreData.accPoints/scoreData.totalNotesHit); 
			var fpRank = Scoring.calculateRankFromData(scoreData.score,resultingAccuracy,scoreData.missed == 0) ?? SHIT;
			if(isNewHighscore && !isStoryMode){
				
				camOther.fade(FlxColor.BLACK, 0.6,false,() -> {
					FlxTransitionableState.skipNextTransOut = true;
                FlxG.switchState(() -> FreeplayState.build(
                  {
                    {
                      fromResults:
                        {
                          oldRank: prevScoreRank,
                          newRank: fpRank,
                          songId: curSong,
                          difficultyId: Difficulty.getString(),
                          playRankAnim: !botplay
                        }
                    }
                  }));
				});
			}
			else if (!isStoryMode){
				openSubState(new StickerSubState(null, (sticker) -> FreeplayState.build(
					{
					  {
						fromResults:
						  {
							oldRank: null,
							playRankAnim: false,
							newRank: fpRank,
							songId: curSong,
                          	difficultyId: Difficulty.getString()
						  }
					  }
					}, sticker)));
			}
			else {
				openSubState(new StickerSubState(null, (sticker) -> new StoryMenuState(sticker)));
			}
			return;
		}
	  trace('WENT TO RESULTS SCREEN!');
	
	  // If the opponent is GF, zoom in on the opponent.
	  // Else, if there is no GF, zoom in on BF.
	  // Else, zoom in on GF.
	  var targetDad:Bool = dad != null && dad.curCharacter == 'gf';
	  var targetBF:Bool = gf == null && !targetDad;
  
	  if (targetBF)
	  {
		FlxG.camera.follow(boyfriend, null, 0.05);
	  }
	  else if (targetDad)
	  {
		FlxG.camera.follow(dad, null, 0.05);
	  }
	  else
	  {
		FlxG.camera.follow(gf, null, 0.05);
	  }
  
	  // TODO: Make target offset configurable.
	  // In the meantime, we have to replace the zoom animation with a fade out.
	  FlxG.camera.targetOffset.y -= 350;
	  FlxG.camera.targetOffset.x += 20;
  
	  // Replace zoom animation with a fade out for now.
	  FlxG.camera.fade(FlxColor.BLACK, 0.6);
  
	  FlxTween.tween(camHUD, {alpha: 0}, 0.6,
		{
		  onComplete: function(_) {
			moveToResultsScreen(isNewHighscore, scoreData,prevScoreRank);
		  }
		});
  
	  // Zoom in on Girlfriend (or BF if no GF)
	  new FlxTimer().start(0.8, function(_) {
		if (targetBF)
		{
			boyfriend.animation.play('hey');
		}
		else if (targetDad)
		{
		  dad.animation.play('cheer');
		}
		else
		{
		  gf.animation.play('cheer');
		}
  
		// Zoom over to the Results screen.
		// TODO: Re-enable this.
		/*
		  FlxTween.tween(FlxG.camera, {zoom: 1200}, 1.1,
			{
			  ease: FlxEase.expoIn,
			});
		 */
	  });
	}
  
	/**
	 * Move to the results screen right goddamn now.
	 */
	function moveToResultsScreen(isNewHighscore:Bool,scoreData:SaveScoreData,prevScoreRank:ScoringRank):Void
	{
	  persistentUpdate = false;

	  var modManifest = Mods.getPack();
	  var fpText = modManifest != null ? '${curSong} from ${modManifest.name}' : curSong;
	  //Mods.loadTopMod();

	  vocals.stop();
	  camHUD.alpha = 1;
  
	  var res:ResultState = new ResultState(
		{
		  storyMode: isStoryMode,
		  songId: curSong,
		  difficultyId: Difficulty.getString(),
		  title: isStoryMode ? ('${storyCampaignTitle}') : fpText,
		  scoreData:scoreData,
		  prevScoreRank: prevScoreRank,
		  isNewHighscore: isNewHighscore,
		  characterId: SONG.player1
		});
	  this.persistentDraw = false;
	  openSubState(res);
	}
////////////////////////////////////////
	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;
			invalidateNote(daNote);
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	// Stores Ratings and Combo Sprites in a group
	public var comboGroup:FlxSpriteGroup;

	private function cachePopUpScore()
	{
		var uiPrefix:String = '';
		var uiPostfix:String = '';
		if (stageUI != "normal")
		{
			uiPrefix = '${stageUI}UI/';
			if (PlayState.isPixelStage) uiPostfix = '-pixel';
		}

		if (ClientPrefs.data.popUpRating)
		{
			for (rating in ratingsData)
				Paths.image(uiPrefix + rating.image + uiPostfix);
			for (i in 0...10)
				Paths.image(uiPrefix + 'num' + i + uiPostfix);
		}
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset);
		vocals.volume = 1;

		if (!ClientPrefs.data.comboStacking && comboGroup.members.length > 0)
		{
			for (spr in comboGroup)
			{
				if(spr == null) continue;

				comboGroup.remove(spr);
				spr.destroy();
			}
		}

		var placement:Float = FlxG.width * 0.35;
		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(ratingsData, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.hits++;
		note.rating = daRating.name;
		score = daRating.score;

		if(daRating.noteSplash && !note.noteSplashData.disabled && !PlayState.SONG.notITG)
			spawnNoteSplashOnNote(note);

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{

		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(keysArray, eventKey);

		if (!controls.controllerMode)
		{
			#if debug
			//Prevents crash specifically on debug without needing to try catch shit
			@:privateAccess if (!FlxG.keys._keyListMap.exists(eventKey)) return;
			#end

			if(FlxG.keys.checkStatus(eventKey, JUST_PRESSED)) keyPressed(key);
		}
	}

	private function keyPressed(key:Int)
	{
		if(cpuControlled || paused || inCutscene || key < 0 || key >= playerStrums.length || !generatedMusic || endingSong || boyfriend.stunned) return;

		var ret:Dynamic = callOnScripts('onKeyPressPre', [key]);
		if(ret == LuaUtils.Function_Stop) return;

		// more accurate hit time for the ratings?
		var lastTime:Float = Conductor.songPosition;
		if(Conductor.songPosition >= 0) Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;

		// obtain notes that the player can hit
		var plrInputNotes:Array<Note> = notes.members.filter(function(n:Note):Bool {
			var canHit:Bool = n != null && !strumsBlocked[n.noteData] && n.canBeHit && n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit;
			return canHit && !n.isSustainNote && n.noteData == key;
		});
		plrInputNotes.sort(sortHitNotes);

		if (plrInputNotes.length != 0) { // slightly faster than doing `> 0` lol
			var funnyNote:Note = plrInputNotes[0]; // front note

			if (plrInputNotes.length > 1) {
				var doubleNote:Note = plrInputNotes[1];

				if (doubleNote.noteData == funnyNote.noteData) {
					// if the note has a 0ms distance (is on top of the current note), kill it
					if (Math.abs(doubleNote.strumTime - funnyNote.strumTime) < 1.0)
						invalidateNote(doubleNote);
					else if (doubleNote.strumTime < funnyNote.strumTime)
					{
						// replace the note if its ahead of time (or at least ensure "doubleNote" is ahead)
						funnyNote = doubleNote;
					}
				}
			}
			goodNoteHit(funnyNote);
		}
		else
		{
			if (ClientPrefs.data.ghostTapping)
				callOnScripts('onGhostTap', [key]);
			else
				noteMissPress(key);
		}

		// Needed for the  "Just the Two of Us" achievement.
		//									- Shadow Mario
		if(!keysPressed.contains(key)) keysPressed.push(key);

		//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
		Conductor.songPosition = lastTime;

		var spr:StrumNote = playerStrums.members[key];
		if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
		{
			spr.playAnim('pressed');
			spr.resetAnim = 0;
		}
		callOnScripts('onKeyPress', [key]);
	}

	public static function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(keysArray, eventKey);
		if(!controls.controllerMode && key > -1) keyReleased(key);
	}

	private function keyReleased(key:Int)
	{
		if(cpuControlled || !startedCountdown || paused || key < 0 || key >= playerStrums.length) return;

		var ret:Dynamic = callOnScripts('onKeyReleasePre', [key]);
		if(ret == LuaUtils.Function_Stop) return;

		var spr:StrumNote = playerStrums.members[key];
		if(spr != null)
		{
			spr.playAnim('static');
			spr.resetAnim = 0;
		}
		callOnScripts('onKeyRelease', [key]);
	}

	public static function getKeyFromEvent(arr:Array<String>, key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...arr.length)
			{
				var note:Array<FlxKey> = Controls.instance.keyboardBinds[arr[i]];
				for (noteKey in note)
					if(key == noteKey)
						return i;
			}
		}
		return -1;
	}

	#if TOUCH_CONTROLS_ALLOWED
	private function onHintPress(button:TouchButton):Void
	{
		var buttonCode:Int = (button.IDs[0].toString().startsWith('HITBOX')) ? button.IDs[0] : button.IDs[1];
		callOnScripts('onHintPressPre', [buttonCode]);
		if (button.justPressed) keyPressed(buttonCode);
		callOnScripts('onHintPress', [buttonCode]);
	}

	private function onHintRelease(button:TouchButton):Void
	{
		var buttonCode:Int = (button.IDs[0].toString().startsWith('HITBOX')) ? button.IDs[0] : button.IDs[1];
		callOnScripts('onHintReleasePre', [buttonCode]);
		if(buttonCode > -1) keyReleased(buttonCode);
		callOnScripts('onHintRelease', [buttonCode]);
	}
	#end

	// Hold notes
	private function keysCheck():Void
	{
		// HOLDING
		var holdArray:Array<Bool> = [];
		var pressArray:Array<Bool> = [];
		var releaseArray:Array<Bool> = [];
		for (key in keysArray)
		{
			holdArray.push(controls.pressed(key));
			pressArray.push(controls.justPressed(key));
			releaseArray.push(controls.justReleased(key));
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(controls.controllerMode && pressArray.contains(true))
			for (i in 0...pressArray.length)
				if(pressArray[i] && strumsBlocked[i] != true)
					keyPressed(i);

		if (startedCountdown && !inCutscene && !boyfriend.stunned && generatedMusic)
		{
			if (notes.length > 0) {
				for (n in notes) { // I can't do a filter here, that's kinda awesome
					var canHit:Bool = (n != null && !strumsBlocked[n.noteData] && n.canBeHit
						&& n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit);

					if (guitarHeroSustains)
						canHit = canHit && n.parent != null && n.parent.wasGoodHit;

					if (canHit && n.isSustainNote) {
						var released:Bool = !holdArray[n.noteData];

						if (!released)
							goodNoteHit(n);
					}
				}
			}

			if (!holdArray.contains(true) || endingSong)
				playerDance();

			#if ACHIEVEMENTS_ALLOWED
			else checkForAchievement(['oversinging']);
			#end
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if((controls.controllerMode || strumsBlocked.contains(true)) && releaseArray.contains(true))
			for (i in 0...releaseArray.length)
				if(releaseArray[i] || strumsBlocked[i] == true)
					keyReleased(i);
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1)
				invalidateNote(note);
		});

		final end:Note = daNote.isSustainNote ? daNote.parent.tail[daNote.parent.tail.length - 1] : daNote.tail[daNote.tail.length - 1];
		if (end != null && end.extraData['holdSplash'] != null) {
			end.extraData['holdSplash'].visible = false;
		}

		noteMissCommon(daNote.noteData, daNote);
		stagesFunc(function(stage:BaseStage) stage.noteMiss(daNote));
		var result:Dynamic = callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('noteMiss', [daNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.data.ghostTapping) return; //fuck it

		noteMissCommon(direction);
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		stagesFunc(function(stage:BaseStage) stage.noteMissPress(direction));
		callOnScripts('noteMissPress', [direction]);
	}

	function noteMissCommon(direction:Int, note:Note = null)
	{
		// score and data
		var subtract:Float = pressMissDamage;
		if(note != null) subtract = note.missHealth;

		// GUITAR HERO SUSTAIN CHECK LOL!!!!
		if (note != null && guitarHeroSustains && note.parent == null) {
			if(note.tail.length > 0) {
				note.alpha = 0.35;
				for(childNote in note.tail) {
					childNote.alpha = note.alpha;
					childNote.missed = true;
					childNote.canBeHit = false;
					childNote.ignoreNote = true;
					childNote.tooLate = true;
				}
				note.missed = true;
				note.canBeHit = false;

				//subtract += 0.385; // you take more damage if playing with this gameplay changer enabled.
				// i mean its fair :p -Crow
				subtract *= note.tail.length + 1;
				// i think it would be fair if damage multiplied based on how long the sustain is -Tahir
			}

			if (note.missed)
				return;
		}

		if (!edwhakIsEnemy && !SONG.versus){
			hitmansHud.ratingsBumpScaleOP();
			hitmansHud.ratingsOP.animation.play("miss");
		}
		hitmansHud.ratings.animation.play("miss");
		hitmansHud.ratingsBumpScale();

		if (note != null && guitarHeroSustains && note.parent != null && note.isSustainNote) {
			if (note.missed)
				return;

			var parentNote:Note = note.parent;
			if (parentNote.wasGoodHit && parentNote.tail.length > 0) {
				for (child in parentNote.tail) if (child != note) {
					child.missed = true;
					child.canBeHit = false;
					child.ignoreNote = true;
					child.tooLate = true;
				}
			}
		}

		if (!isDead){
			if (note != null)
			{
				switch (note.noteType){
					case '':
						deathVariableTXT = 'Notes';
					case 'HD Note':
						deathVariableTXT = 'HD';
				}
			}
		}

		if(instakillOnMiss)
		{
			vocals.volume = 0;
			opponentVocals.volume = 0;
			doDeathCheck(true);
		}

		var lastCombo:Int = combo;
		combo = 0;

		if (note != null)
		{
			switch(ClientPrefs.data.casualMode){
				case true:
					health -= ((subtract-0.15) * healthLoss)/(note.isSustainNote ? sustainDivider : 1); //now sustains gets 10 times less gain but still drain
				case false:
					health -= ((subtract) * healthLoss)/(note.isSustainNote ? sustainDivider : 1); //now sustains gets 10 times less gain but still drain
			}
		}
		else
		{
			if(ClientPrefs.data.casualMode){
				health -= subtract * healthLoss;
			}else if (!ClientPrefs.data.casualMode){
				health -= subtract * healthLoss;
			}
		}

		if(!practiceMode) songScore -= 10;
		if(!endingSong) songMisses++;
		totalPlayed++;
		RecalculateRating(true);

		// play character anims
		var char:Character = boyfriend;
		if((note != null && note.gfNote) || (SONG.notes[curSection] != null && SONG.notes[curSection].gfSection)) char = gf;

		if(char != null && (note == null || !note.noMissAnimation) && char.hasMissAnimations)
		{
			var postfix:String = '';
			if(note != null) postfix = note.animSuffix;

			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, direction)))] + 'miss' + postfix;
			char.playAnim(animToPlay, true);

			if(char != gf && lastCombo > 5 && gf != null && gf.hasAnimation('sad'))
			{
				gf.playAnim('sad');
				gf.specialAnim = true;
			}
		}
		vocals.volume = 0;
	}

	function opponentNoteHit(note:Note):Void
	{
		var result:Dynamic = callOnLuas('opponentNoteHitPre', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) result = callOnHScript('opponentNoteHitPre', [note]);

		if(result == LuaUtils.Function_Stop) return;

		edwhakDrain = note.hitHealth+0.007; //force game to make this be 0.007 higher than player (so basically 0.03 drain)
		// if (Paths.formatToSongPath(SONG.song) != 'tutorial')
		//Edwhak HealthDrain but in source so people can't nerf how his songs works!
		if (SONG.versus || edwhakIsEnemy){
			if (!note.isSustainNote){
				hitmansHud.ratingsBumpScaleOP();
				hitmansHud.setRatingImageOP(0);
				comboOp +=1;
				separateCombo = true;
				allowEnemyDrain = true;
			}
		}
		var noteStyle = note.noteType.toLowerCase();
		if (allowEnemyDrain){
			switch (ClientPrefs.data.casualMode){
				case false:
					if (edwhakIsEnemy){
						if(health - edwhakDrain - 0.17 > maxHealth){
							if (noteStyle == 'instakill note'){
								health -= ((edwhakDrain+0.02) * healthGain) / (note.isSustainNote ? sustainDivider : 1); //idfk if this even works LMAO
							}else{
								health -= ((edwhakDrain+0.005) * healthGain) / (note.isSustainNote ? sustainDivider : 1); //Added both because if i added only one it don't do shit idk why lmao
							}
						}
					}else{
						if(health - note.hitHealth - 0.05 > maxHealth){
							if (noteStyle != 'instakill note'){
								health -= (note.hitHealth * healthGain) / (note.isSustainNote ? sustainDivider : 1);			
							}
						}
					}
				case true:
					if (edwhakIsEnemy){
						if(health - edwhakDrain - 0.17 > maxHealth){
							if (noteStyle == 'instakill note'){
								health -= ((edwhakDrain+0.01) * healthGain) / (note.isSustainNote ? sustainDivider : 1); //Same as up
							}else{
								health -= ((edwhakDrain+0.003) * healthGain) / (note.isSustainNote ? sustainDivider : 1); //Added both because if i added only one it don't do shit idk why lmao
							}
						}
					}else{
						if(health - note.hitHealth - 0.05 > maxHealth){
							if (noteStyle != 'instakill note'){
								health -= (note.hitHealth * healthGain) / (note.isSustainNote ? sustainDivider : 1);
							}
						}
					}		
			}
		}

		if (songName != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.hasAnimation('hey'))
		{
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		}
		else if(!note.noAnimation)
		{
			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + note.animSuffix;
			if(note.gfNote) char = gf;

			if(char != null)
			{
				var canPlay:Bool = true;
				if(note.isSustainNote)
				{
					var holdAnim:String = animToPlay + '-hold';
					if(char.animation.exists(holdAnim)) animToPlay = holdAnim;
					if(char.getAnimationName() == holdAnim || char.getAnimationName() == holdAnim + '-loop') canPlay = false;
				}

				if(canPlay) char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if(opponentVocals.length <= 0) vocals.volume = 1;
		strumPlayAnim(true, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
		note.hitByOpponent = true;
		
		
		stagesFunc(function(stage:BaseStage) stage.opponentNoteHit(note));

		if (ClientPrefs.data.quantization)
		{
			opponentStrums.members[note.noteData].rgbShader.r = note.rgbShader.r;
			opponentStrums.members[note.noteData].rgbShader.b = note.rgbShader.b;
		}
		var result:Dynamic = callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('opponentNoteHit', [note]);

		spawnHoldSplashOnNote(note);

		if (!note.isSustainNote) invalidateNote(note);
	}

	public function goodNoteHit(note:Note):Void
	{
		if(note.wasGoodHit) return;
		if(cpuControlled && note.ignoreNote) return;

		var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
		var leData:Int = Math.round(Math.abs(note.noteData));
		var leType:String = note.noteType;

		var result:Dynamic = callOnLuas('goodNoteHitPre', [notes.members.indexOf(note), leData, leType, isSus]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) result = callOnHScript('goodNoteHitPre', [note]);

		if(result == LuaUtils.Function_Stop) return;

		note.wasGoodHit = true;

		if (note.hitsoundVolume > 0 && !note.hitsoundDisabled)
			FlxG.sound.play(Paths.sound(note.hitsound), note.hitsoundVolume);

		if(!note.hitCausesMiss) //Common notes
		{
			switch(note.noteType) {
				case 'Love Note': //agressive hurts that cause more damage
				if (!gameOver)
				{
					if (Note.edwhakIsPlayer){
						drain = true;
						deathVariableTXT = 'Love';
					}else{
						drain = false;
					}
				}
				case 'Fire Note': //agressive hurts that cause more damage
				if (!gameOver)
				{
					if (Note.edwhakIsPlayer){
						deathVariableTXT = 'Fire';
					}
					gain = Note.edwhakIsPlayer ? false : true;
				}
			}
			if(!note.noAnimation)
			{
				var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + note.animSuffix;

				var char:Character = boyfriend;
				var animCheck:String = 'hey';
				if(note.gfNote)
				{
					char = gf;
					animCheck = 'cheer';
				}

				if(char != null)
				{
					var canPlay:Bool = true;
					if(note.isSustainNote)
					{
						var holdAnim:String = animToPlay + '-hold';
						if(char.animation.exists(holdAnim)) animToPlay = holdAnim;
						if(char.getAnimationName() == holdAnim || char.getAnimationName() == holdAnim + '-loop') canPlay = false;
					}
	
					if(canPlay) char.playAnim(animToPlay, true);
					char.holdTimer = 0;

					if(note.noteType == 'Hey!')
					{
						if(char.hasAnimation(animCheck))
						{
							char.playAnim(animCheck, true);
							char.specialAnim = true;
							char.heyTimer = 0.6;
						}
					}
				}
			}

			if(!cpuControlled)
			{
				var spr = playerStrums.members[note.noteData];
				if(spr != null) spr.playAnim('confirm', true);
			}
			else strumPlayAnim(false, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				hitmansHud.ratingsBumpScale();
				setRatingImage(note.strumTime - Conductor.songPosition);
				if (!edwhakIsEnemy && !SONG.versus){
					hitmansHud.ratingsBumpScaleOP();
					hitmansHud.setRatingImageOP(note.strumTime - Conductor.songPosition);
				}
				combo++;
				maxCombo = FlxMath.maxInt(maxCombo,combo);
				if(combo > 9999) combo = 9999;
				popUpScore(note);
			}
			var gainHealth:Bool = true; // prevent health gain, *if* sustains are treated as a singular note
			if (guitarHeroSustains && note.isSustainNote) gainHealth = false;
			if (gainHealth)
			{
				switch(ClientPrefs.data.casualMode){
					case false:
						health += Note.edwhakIsPlayer ? ((note.hitHealth+0.012) * healthGain)/(note.isSustainNote ? sustainDivider : 1) : (note.hitHealth * healthGain)/(note.isSustainNote ? sustainDivider : 1); //now sustains gets 10 times less gain but still gain
					case true:
						health += Note.edwhakIsPlayer ? ((note.hitHealth+0.012) * healthGain)/(note.isSustainNote ? sustainDivider : 1) : ((note.hitHealth+0.007) * healthGain)/(note.isSustainNote ? sustainDivider : 1); //now sustains gets 10 times less gain but still gain
				}
			}
		}
		else //Notes that count as a miss if you hit them (Hurt notes for example)
		{
			if(!note.noMissAnimation)
			{
				var hasHurtAnim:Bool = boyfriend.hasAnimation('hurt');
				switch(note.noteType) {
					case 'Hurt Note' | 'HurtAgressive': //Hurt note
					if (!gameOver)
						{
						if(hasHurtAnim) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
						deathVariableTXT = 'Hurts';
					}
					case 'Invisible Hurt Note' : //what you can't see but still damages you
					if (!gameOver)
						{
						if(hasHurtAnim) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
						deathVariableTXT = 'InvisibleHurts';
					}
					case 'Mimic Note': //hurts but similar to notes
					if (!gameOver)
						{
						if(hasHurtAnim) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
						deathVariableTXT = 'Mimics';
					}
					case 'Mine Note': //similar to agressive but way more lethal
					if (!gameOver)
						{
						if(hasHurtAnim) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
						FlxG.sound.play(Paths.sound('Edwhak/Mine'));
						deathVariableTXT = 'Mine';
					}
					case 'Instakill Note': //ANNIHILATE.
					if (!gameOver)
					{
						if(hasHurtAnim) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
						deathVariableTXT = 'Instakill';
					}
				}
			}

			noteMiss(note);
			if(!note.noteSplashData.disabled && !note.isSustainNote && !PlayState.SONG.notITG) spawnNoteSplashOnNote(note);
		}

		if (ClientPrefs.data.quantization)
		{
			playerStrums.members[note.noteData].rgbShader.r = note.rgbShader.r;
			playerStrums.members[note.noteData].rgbShader.b = note.rgbShader.b;
		}
		stagesFunc(function(stage:BaseStage) stage.goodNoteHit(note));
		var result:Dynamic = callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('goodNoteHit', [note]);
		spawnHoldSplashOnNote(note);
		if(!note.isSustainNote) invalidateNote(note);
	}

	public function setRatingImage(rat:Float){
		if (rat >= 0){
			if (rat <= ClientPrefs.data.marvelousWindow){
				hitmansHud.setRatingAnimation(rat);
				fantastics += 1;
			} else if (rat <= ClientPrefs.data.sickWindow){
				hitmansHud.setRatingAnimation(rat);
				excelents += 1;
			}else if (rat >= ClientPrefs.data.sickWindow && rat <= ClientPrefs.data.goodWindow){
				hitmansHud.setRatingAnimation(rat);
				greats += 1;
			}else if (rat >= ClientPrefs.data.goodWindow && rat <= ClientPrefs.data.badWindow){
				hitmansHud.setRatingAnimation(rat);
				decents += 1;
			}else if (rat >= ClientPrefs.data.badWindow){
				hitmansHud.setRatingAnimation(rat);
				wayoffs += 1;
			}
		} else {
			if (rat >= ClientPrefs.data.marvelousWindow * -1){
				hitmansHud.setRatingAnimation(rat);
				fantastics += 1;
			} else if (rat >= ClientPrefs.data.sickWindow * -1){
				hitmansHud.setRatingAnimation(rat);
				excelents += 1;
			}else if (rat <= ClientPrefs.data.sickWindow * -1 && rat >= ClientPrefs.data.goodWindow * -1){
				hitmansHud.setRatingAnimation(rat);
				greats += 1;
			}else if (rat <= ClientPrefs.data.goodWindow * -1 && rat >= ClientPrefs.data.badWindow * -1){
				hitmansHud.setRatingAnimation(rat);
				decents += 1;
			}else if (rat <= ClientPrefs.data.badWindow * -1){
				hitmansHud.setRatingAnimation(rat);
				wayoffs += 1;
			}
		}
	}

	public function invalidateNote(note:Note):Void {
		//if(!ClientPrefs.data.lowQuality || !ClientPrefs.data.popUpRating || !cpuControlled) note.kill();
		notes.remove(note, true);
		note.destroy();
	}

	public function spawnHoldSplashOnNote(note:Note) {
		if (ClientPrefs.data.holdSplashAlpha <= 0)
			return;
		if (PlayState.SONG.notITG) return;

		if (note != null) {
			var strum:StrumNote = (note.mustPress ? playerStrums : opponentStrums).members[note.noteData];
			if(strum != null && note.tail.length > 1)
				spawnHoldSplash(note);
		}
	}

	public function spawnHoldSplash(note:Note) {
		var end:Note = note.isSustainNote ? note.parent.tail[note.parent.tail.length - 1] : note.tail[note.tail.length - 1];
		var splash:SustainSplash = grpHoldSplashes.recycle(SustainSplash);
		splash.setupSusSplash((note.mustPress ? playerStrums : opponentStrums).members[note.noteData], note, playbackRate);
		grpHoldSplashes.add(end.noteHoldSplash = splash);
	}

	public function spawnNoteSplashOnNote(note:Note) {
		if (PlayState.SONG.notITG) return;
		if(note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null)
				spawnNoteSplash(note, strum);
		}
	}

	public function spawnNoteSplash(note:Note, strum:StrumNote) {
		var splash:NoteSplash = new NoteSplash();
		splash.babyArrow = strum;
		splash.spawnSplashNote(note);
		grpNoteSplashes.add(splash);
	}

	override function destroy() {
		if (psychlua.CustomSubstate.instance != null)
		{
			closeSubState();
			resetSubState();
		}

		if (modchartRenderer != null) modchartRenderer.destroy();

		#if LUA_ALLOWED
		for (lua in luaArray)
		{
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = null;
		FunkinLua.customFunctions.clear();
		#end

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if(script != null)
			{
				script.executeFunction('onDestroy');
				script.destroy();
			}

		hscriptArray = null;
		#end
		stagesFunc(function(stage:BaseStage) stage.destroy());

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		FlxG.camera.setFilters([]);

		#if FLX_PITCH FlxG.sound.music.pitch = 1; #end
		FlxG.animationTimeScale = 1;

		Note.globalRgbShaders = [];
		backend.NoteTypesConfig.clearNoteTypesData();

		NoteSplash.configs.clear();
		instance = null;
		super.destroy();
	}

	var lastStepHit:Int = -1;
	var animSkins:Array<String> = ['ITHIT', 'MANIAHIT', 'STEPMANIA', 'NOTITG'];
	override function stepHit()
	{
		super.stepHit();

		if(curStep == lastStepHit) {
			return;
		}
		for (i in 0... animSkins.length){
			if (ClientPrefs.data.notesSkin[0].contains(animSkins[i])){
				if (curStep % 4 == 0){
					for (strum in opponentStrums)
					{
						if (strum.animation.curAnim.name == 'static'){
							strum.rgbShader.r = 0xFF808080;
							strum.rgbShader.b = 0xFF474747;
							strum.rgbShader.enabled = true;
						}
					}
					for (strum in playerStrums)
					{
						if (strum.animation.curAnim.name == 'static'){
							strum.rgbShader.r = 0xFF808080;
							strum.rgbShader.b = 0xFF474747;
							strum.rgbShader.enabled = true;
						}
					}
				}else if (curStep % 4 == 1){
					for (strum in opponentStrums)
					{
						if (strum.animation.curAnim.name == 'static'){ 
							strum.rgbShader.enabled = false;
						}
					}
					for (strum in playerStrums)
					{
						if (strum.animation.curAnim.name == 'static'){
							strum.rgbShader.enabled = false;
						}
					}
				}
			}
		}

		lastStepHit = curStep;
		setOnScripts('curStep', curStep);
		callOnScripts('onStepHit');
	}

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.data.camZooms && (curBeat % camZoomingFrequency) == 0)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
				
			}

		if (generatedMusic)
			notes.sort(FlxSort.byY, ClientPrefs.data.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

		characterBopper(curBeat);

		super.beatHit();
		lastBeatHit = curBeat;

		setOnScripts('curBeat', curBeat);
		callOnScripts('onBeatHit');
	}

	public function characterBopper(beat:Int):Void
	{
		if (gf != null && beat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.getAnimationName().startsWith('sing') && !gf.stunned)
			gf.dance();
		if (boyfriend != null && beat % boyfriend.danceEveryNumBeats == 0 && !boyfriend.getAnimationName().startsWith('sing') && !boyfriend.stunned)
			boyfriend.dance();
		if (dad != null && beat % dad.danceEveryNumBeats == 0 && !dad.getAnimationName().startsWith('sing') && !dad.stunned)
			dad.dance();
	}

	public function playerDance():Void
	{
		var anim:String = boyfriend.getAnimationName();
		if(boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 #if FLX_PITCH / FlxG.sound.music.pitch #end) * boyfriend.singDuration && anim.startsWith('sing') && !anim.endsWith('miss'))
			boyfriend.dance();
	}

	override function sectionHit()
	{
		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
				moveCameraSection();

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.bpm = SONG.notes[curSection].bpm;
				setOnScripts('curBpm', Conductor.bpm);
				setOnScripts('crochet', Conductor.crochet);
				setOnScripts('stepCrochet', Conductor.stepCrochet);
			}
			setOnScripts('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnScripts('altAnim', SONG.notes[curSection].altAnim);
			setOnScripts('gfSection', SONG.notes[curSection].gfSection);
		}
		super.sectionHit();

		setOnScripts('curSection', curSection);
		callOnScripts('onSectionHit');
	}

	#if LUA_ALLOWED
	public function startLuasNamed(luaFile:String)
	{
		#if MODS_ALLOWED
		var luaToLoad:String = Paths.modFolders(luaFile);
		if(!FileSystem.exists(luaToLoad))
			luaToLoad = Paths.getSharedPath(luaFile);

		if(FileSystem.exists(luaToLoad))
		#elseif sys
		var luaToLoad:String = Paths.getSharedPath(luaFile);
		if(OpenFlAssets.exists(luaToLoad))
		#end
		{
			for (script in luaArray)
				if(script.scriptName == luaToLoad) return false;

			new FunkinLua(luaToLoad);
			return true;
		}
		return false;
	}
	#end

	#if HSCRIPT_ALLOWED
	public function startHScriptsNamed(scriptFile:String)
	{
		#if MODS_ALLOWED
		var scriptToLoad:String = Paths.modFolders(scriptFile);
		if(!FileSystem.exists(scriptToLoad))
			scriptToLoad = Paths.getSharedPath(scriptFile);
		#else
		var scriptToLoad:String = Paths.getSharedPath(scriptFile);
		#end

		if(FileSystem.exists(scriptToLoad))
		{
			if (Iris.instances.exists(scriptToLoad)) return false;

			initHScript(scriptToLoad);
			return true;
		}
		return false;
	}

	public function initHScript(file:String)
	{
		var newScript:HScript = null;
		try
		{
			newScript = new HScript(null, file);
			newScript.executeFunction('onCreate');
			trace('initialized hscript interp successfully: $file');
			hscriptArray.push(newScript);
		}
		catch(e:Dynamic)
		{
			addTextToDebug('ERROR ON LOADING ($file) - $e', FlxColor.RED);
			var newScript:HScript = cast (Iris.instances.get(file), HScript);
			if(newScript != null)
				newScript.destroy();
		}
	}
	#end

	public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:String = LuaUtils.Function_Continue;
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var result:Dynamic = callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
		if(result == null || excludeValues.contains(result)) result = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
		return result;
	}

	public function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:String = LuaUtils.Function_Continue;
		#if LUA_ALLOWED
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var arr:Array<FunkinLua> = [];
		for (script in luaArray)
		{
			if(script.closed)
			{
				arr.push(script);
				continue;
			}

			if(exclusions.contains(script.scriptName))
				continue;

			var myValue:Dynamic = script.call(funcToCall, args);
			if((myValue == LuaUtils.Function_StopLua || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
			{
				returnVal = myValue;
				break;
			}

			if(myValue != null && !excludeValues.contains(myValue))
				returnVal = myValue;

			if(script.closed) arr.push(script);
		}

		if(arr.length > 0)
			for (script in arr)
				luaArray.remove(script);
		#end
		return returnVal;
	}

	public function callOnHScript(funcToCall:String, args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:String = LuaUtils.Function_Continue;

		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = new Array();
		if(excludeValues == null) excludeValues = new Array();
		excludeValues.push(LuaUtils.Function_Continue);

		var len:Int = hscriptArray.length;
		if (len < 1)
			return returnVal;

		for(script in hscriptArray)
		{
			@:privateAccess
			if(script == null || !script.exists(funcToCall) || exclusions.contains(script.origin))
				continue;

			try
			{
				var callValue = script.call(funcToCall, args);
				var myValue:Dynamic = callValue.returnValue;

				if((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
				{
					returnVal = myValue;
					break;
				}

				if(myValue != null && !excludeValues.contains(myValue))
					returnVal = myValue;
			}
			catch(e:Dynamic)
			{
				addTextToDebug('ERROR (${script.origin}: $funcToCall) - $e', FlxColor.RED);
			}
		}
		#end

		return returnVal;
	}

	public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		setOnLuas(variable, arg, exclusions);
		setOnHScript(variable, arg, exclusions);
	}

	public function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	public function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in hscriptArray) {
			if(exclusions.contains(script.origin))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	function strumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = opponentStrums.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnScripts('score', songScore);
		setOnScripts('misses', songMisses);
		setOnScripts('hits', songHits);
		setOnScripts('combo', combo);

		var ret:Dynamic = callOnScripts('onRecalculateRating', null, true);
		if(ret != LuaUtils.Function_Stop)
		{
			ratingName = '?';
			if(totalPlayed != 0) //Prevent divide by 0
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				if(ratingPercent < 1)
					for (i in 0...ratingStuff.length-1)
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
			}
			fullComboFunction();
		}
		setOnScripts('rating', ratingPercent);
		setOnScripts('ratingName', ratingName);
		setOnScripts('ratingFC', ratingFC);
		setOnScripts('totalPlayed', totalPlayed);
		setOnScripts('totalNotesHit', totalNotesHit);
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null)
	{
		if(chartingMode) return;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice') || ClientPrefs.getGameplaySetting('botplay'));
		if(cpuControlled) return;

		for (name in achievesToCheck) {
			if(!Achievements.exists(name)) continue;

			var unlock:Bool = false;
			if (name != WeekData.getWeekFileName() + '_nomiss') // common achievements
			{
				switch(name)
				{
					case 'ur_bad':
						unlock = (ratingPercent < 0.2 && !practiceMode);

					case 'ur_good':
						unlock = (ratingPercent >= 1 && !usedPractice);

					case 'oversinging':
						unlock = (boyfriend.holdTimer >= 10 && !usedPractice);

					case 'hype':
						unlock = (!boyfriendIdled && !usedPractice);

					case 'two_keys':
						unlock = (!usedPractice && keysPressed.length <= 2);

					case 'toastie':
						unlock = (!ClientPrefs.data.cacheOnGPU && !ClientPrefs.data.shaders && ClientPrefs.data.lowQuality && !ClientPrefs.data.antialiasing);

					case 'debugger':
						unlock = (songName == 'test' && !usedPractice);
				}
			}
			else // any FC achievements, name should be "weekFileName_nomiss", e.g: "week3_nomiss";
			{
				if(isStoryMode && campaignMisses + songMisses < 1 && Difficulty.getString().toUpperCase() == 'HARD'
					&& storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
					unlock = true;
			}

			if(unlock) Achievements.unlock(name);
		}
	}
	#end

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.data.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.data.shaders) return false;

		#if (MODS_ALLOWED && !flash && sys)
		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'shaders/'))
		{
			var frag:String = folder + name + '.frag';
			var vert:String = folder + name + '.vert';
			var found:Bool = false;
			if(FileSystem.exists(frag))
			{
				frag = File.getContent(frag);
				found = true;
			}
			else frag = null;

			if(FileSystem.exists(vert))
			{
				vert = File.getContent(vert);
				found = true;
			}
			else vert = null;

			if(found)
			{
				runtimeShaders.set(name, [frag, vert]);
				//trace('Found shader $name!');
				return true;
			}
		}
			#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
			addTextToDebug('Missing shader $name .frag AND .vert files!', FlxColor.RED);
			#else
			FlxG.log.warn('Missing shader $name .frag AND .vert files!');
			#end
		#else
		FlxG.log.warn('This platform doesn\'t support Runtime Shaders!');
		#end
		return false;
	}
	#end

	#if TOUCH_CONTROLS_ALLOWED
	public function makeLuaTouchPad(DPadMode:String, ActionMode:String) {
		if(members.contains(luaTouchPad)) return;

		if(!variables.exists("luaTouchPad"))
			variables.set("luaTouchPad", luaTouchPad);

		luaTouchPad = new TouchPad(DPadMode, ActionMode);
		luaTouchPad.alpha = ClientPrefs.data.controlsAlpha;
	}
	
	public function addLuaTouchPad() {
		if(luaTouchPad == null || members.contains(luaTouchPad)) return;

		var target = LuaUtils.getTargetInstance();
		target.insert(target.members.length + 1, luaTouchPad);
	}

	public function addLuaTouchPadCamera() {
		if(luaTouchPad != null)
			luaTouchPad.cameras = [luaTpadCam];
	}

	public function removeLuaTouchPad() {
		if (luaTouchPad != null) {
			luaTouchPad.kill();
			luaTouchPad.destroy();
			remove(luaTouchPad);
			luaTouchPad = null;
		}
	}

	public function luaTouchPadPressed(button:Dynamic):Bool {
		if(luaTouchPad != null) {
			if(Std.isOfType(button, String))
				return luaTouchPad.buttonPressed(MobileInputID.fromString(button));
			else if(Std.isOfType(button, Array)){
				var FUCK:Array<String> = button; // haxe said "You Can't Iterate On A Dyanmic Value Please Specificy Iterator or Iterable *insert nerd emoji*" so that's the only i foud to fix
				var idArray:Array<MobileInputID> = [];
				for(strId in FUCK)
					idArray.push(MobileInputID.fromString(strId));
				return luaTouchPad.anyPressed(idArray);
			} else
				return false;
		}
		return false;
	}

	public function luaTouchPadJustPressed(button:Dynamic):Bool {
		if(luaTouchPad != null) {
			if(Std.isOfType(button, String))
				return luaTouchPad.buttonJustPressed(MobileInputID.fromString(button));
			else if(Std.isOfType(button, Array)){
				var FUCK:Array<String> = button;
				var idArray:Array<MobileInputID> = [];
				for(strId in FUCK)
					idArray.push(MobileInputID.fromString(strId));
				return luaTouchPad.anyJustPressed(idArray);
			} else
				return false;
		}
		return false;
	}
	
	public function luaTouchPadJustReleased(button:Dynamic):Bool {
		if(luaTouchPad != null) {
			if(Std.isOfType(button, String))
				return luaTouchPad.buttonJustReleased(MobileInputID.fromString(button));
			else if(Std.isOfType(button, Array)){
				var FUCK:Array<String> = button;
				var idArray:Array<MobileInputID> = [];
				for(strId in FUCK)
					idArray.push(MobileInputID.fromString(strId));
				return luaTouchPad.anyJustReleased(idArray);
			} else
				return false;
		}
		return false;
	}

	public function luaTouchPadReleased(button:Dynamic):Bool {
		if(luaTouchPad != null) {
			if(Std.isOfType(button, String))
				return luaTouchPad.buttonJustReleased(MobileInputID.fromString(button));
			else if(Std.isOfType(button, Array)){
				var FUCK:Array<String> = button;
				var idArray:Array<MobileInputID> = [];
				for(strId in FUCK)
					idArray.push(MobileInputID.fromString(strId));
				return luaTouchPad.anyReleased(idArray);
			} else
				return false;
		}
		return false;
	}
	#end

	function createNoteEffect(note:Note, strum:StrumNote, isSustain:Bool){
		//var suffix = game.isPixelStage;
		var sustain = isSustain;
		var animOffset:Array<Float> = [10, 10];
		var ef = new StrumNote(strum.x + animOffset[0], strum.y + animOffset[1], strum.noteData, note.mustPress ? 1 : 0);
		add(ef);
		ef.reloadNote();
		if (!sustain){
			ef.rgbShader.r = strum.rgbShader.r;
			ef.rgbShader.g = strum.rgbShader.g;
			ef.rgbShader.b = strum.rgbShader.b;
		}else{
			ef.rgbShader.r = 0xFFFFFF00;
			ef.rgbShader.g = strum.rgbShader.g;
			ef.rgbShader.b = 0xFF7F7F00;
		}
		ef.alpha -= 0.3;
		ef.angle = strum.angle;
		ef.skew.x = strum.skew.x;
		ef.skew.y = strum.skew.y;
		ef.playAnim("confirm", true);
		// ef.offset.set(ef.offset.x + animOffset[0], ef.offset.y + animOffset[1]);
		ef.cameras = [camHUD];
		// if (!settings.get("highlight")) {
		ef.scale.set(strum.scale.x / 1.5, strum.scale.y / 1.5);
		ef.updateHitbox();
		FlxTween.tween(ef.scale, {x: strum.scale.x + 0.2, y: strum.scale.y + 0.2}, 0.15 / playbackRate - 0.01, {ease: FlxEase.quadOut});
		// ef.blend = 0;
		// } else if (settings.get("unholy")) ef.blend = 0;

		FlxTween.tween(ef, {alpha: 0}, 0.15 / playbackRate + 0.1, {ease: FlxEase.quadOut, startDelay: 0.1, onComplete: function (twn) {
			ef.destroy();
		}});
	}

	var checkpointQueueTimesArray:Array<Float> = [];
	//The song length is unknown at this current moment in time... soooooooo we wait until the song length is generated and THEN place the checkpoints.
	function markCheckpointQueue(time:Float, hidden:Bool=false){
		if(!hidden){ //Is it hidden? Don't create the marker in the first place then lol
			trace("Marking Checkpoint!");
			checkpointQueueTimesArray.push(time);
		}
	}

	var checkPointTween:FlxTween;
	public function onCheckPoint(strumTime:Float, hideTell:Bool = false, manual:Bool = false){
		
		var previousCheckpointTime:Float = 0;
		if(PlayState.checkpointHistory.length > 0){
			previousCheckpointTime = PlayState.checkpointHistory[PlayState.checkpointHistory.length-1].time;
		}
		
		if(strumTime > previousCheckpointTime){
			var newCheckpoint:CheckpointData = new CheckpointData();
			

			newCheckpoint.time = strumTime;
			trace("Checkpoint set to: " + newCheckpoint.time);

			newCheckpoint.BPM = Conductor.bpm;

			// newCheckpoint.hitTimeDiff = hitTimesDiff;
			// newCheckpoint.hitTimesTime = hitTimesTime;
			// newCheckpoint.hitTimesJudge = hitTimesJudge;
			// newCheckpoint.healthSamples = healthSamples;
			newCheckpoint.totalPlayed = totalPlayed;
			newCheckpoint.totalNotesHit = totalNotesHit;

			newCheckpoint.marvelouss = marvelouss;
			newCheckpoint.sicks = sicks;
			newCheckpoint.goods = goods;
			newCheckpoint.bads = bads;
			newCheckpoint.shits = shits;
			newCheckpoint.highestCombo = maxCombo;
			newCheckpoint.songScore = songScore;
			newCheckpoint.songHits = songHits;
			newCheckpoint.songMisses = songMisses;
			//trace("Checkpoint memory set!");
			//trace("Test for sicks: " + PlayState.checkpointMemory_sicks);

			PlayState.checkpointHistory.push(newCheckpoint);

			if(!hideTell){
				if (checkPointTween != null) checkPointTween.cancel();
				checkPointTween = FlxTween.tween(checkpointSprite, {alpha : 0.275}, 0.1, 
				{
					ease: FlxEase.linear,
					onComplete: function(twn:FlxTween) 
					{
						checkPointTween.cancel();
						checkPointTween = null;
						checkPointTween = FlxTween.tween(checkpointSprite, {alpha : 0.0}, 0.45, 
						{
							ease: FlxEase.linear,
							onComplete: function(twn:FlxTween) {
								checkPointTween.cancel();
								checkPointTween = null;
							}
						});
					}
				});
				
			}
		}
	}
}
