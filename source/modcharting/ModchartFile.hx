package modcharting;

import flixel.math.FlxMath;
import haxe.Exception;
import haxe.Json;
import haxe.format.JsonParser;
import hscript.*;
import lime.utils.Assets;

using StringTools;

#if LEATHER
import game.Conductor;
import game.Note;
import states.PlayState;
#if polymod
import polymod.backends.PolymodAssets;
#end
#end
#if sys
import sys.FileSystem;
import sys.io.File;
#end

typedef ModchartJson =
{
	var modifiers:Array<Array<Dynamic>>;
	var events:Array<Array<Dynamic>>;
	var playfields:Int;
	var proxiefields:Int;
}

class ModchartFile
{
	// used for indexing
	public static final MOD_NAME = 0; // the modifier name
	public static final MOD_CLASS = 1; // the class/custom mod it uses
	public static final MOD_TYPE = 2; // the type, which changes if its for the player, opponent, a specific lane or all
	public static final MOD_PF = 3; // the playfield that mod uses
	public static final MOD_LANE = 4; // the lane the mod uses

	public static final EVENT_TYPE = 0; // event type (set or ease)
	public static final EVENT_DATA = 1; // event data
	public static final EVENT_REPEAT = 2; // event repeat data

	public static final EVENT_TIME = 0; // event time (in beats)
	public static final EVENT_SETDATA = 1; // event data (for sets)
	public static final EVENT_EASETIME = 1; // event ease time
	public static final EVENT_EASE = 2; // event ease
	public static final EVENT_EASEDATA = 3; // event data (for eases)

	public static final EVENT_REPEATBOOL = 0; // if event should repeat
	public static final EVENT_REPEATCOUNT = 1; // how many times it repeats
	public static final EVENT_REPEATBEATGAP = 2; // how many beats in between each repeat

	public var data:ModchartJson = null;

	private var renderer:PlayfieldRenderer;

	public var scriptListen:Bool = false;
	public var customModifiers:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var hasDifficultyModchart:Bool = false; // so it loads false as default!
	public var hasImproved:Bool = false;

	public function new(renderer:PlayfieldRenderer)
	{
		final possibleDiff = Difficulty.list[PlayState.storyDifficulty];
		data = loadFromJson(Paths.formatToSongPath(PlayState.SONG.song),
			possibleDiff == null ? Difficulty.defaultList[PlayState.storyDifficulty] : possibleDiff);
		this.renderer = renderer;
		renderer.modchart = this;
		// if (!ClientPrefs.getGameplaySetting('chaosmode')){
		loadPlayfields();
		loadProxiefields();
		loadModifiers();
		loadEvents();
		//  }
	}

	public function loadFromJson(folder:String, difficulty:String):ModchartJson // load da shit
	{
		var rawJson = null;
		var folderShit:String = "";

		var files = ['data/$folder/modchart-$difficulty.json', 'data/$folder/modchart.json'];

		// find modchart file
		for (f in files)
		{
			final fileContent = Paths.getTextFromFile(f).trim();

			if (fileContent != null)
			{
				rawJson = fileContent;
				break;

				trace('found file: $f');
			}
			trace('tried with: $f');
		}

		folderShit = Paths.getPath('data/$folder/customMods/');

		var json:ModchartJson = null;
		if (rawJson != null)
		{
			json = cast Json.parse(rawJson); // idk why but if i remove this it don't works
			// trace('loaded json');
			trace(folderShit);
			#if sys
			if (FileSystem.isDirectory(folderShit))
			{
				// trace("folder le exists");
				for (file in FileSystem.readDirectory(folderShit))
				{
					// trace(file);
					if (file.endsWith('.hx')) // custom mods!!!!
					{
						var scriptStr = null;
						var script = null;
						// #if HScriptImproved
						// var justFilePlace = folderShit + file;
						// script = codenameengine.scripting.Script.create(justFilePlace);
						// if (PlayState.instance == flixel.FlxG.state)
						//     PlayState.instance.scripts.add(script);
						// script.load();
						// hasImproved = true;
						// #else
						scriptStr = File.getContent(folderShit + file);
						script = new CustomModifierScript(scriptStr);
						// #end
						customModifiers.set(file.replace(".hx", ""), script);
						trace('loaded custom mod: ' + file);
					}
				}
			}
			#end
		}
		else
		{
			json = {
				modifiers: [],
				events: [],
				playfields: 1,
				proxiefields: 1
			};
		}
		return json;
	}

	public function loadEmpty()
	{
		data.modifiers = [];
		data.events = [];
		data.playfields = 1;
		data.proxiefields = 1;
	}

	public function loadModifiers()
	{
		if (data == null || renderer == null)
			return;
		renderer.modifierTable.clear();
		for (i in data.modifiers)
		{
			ModchartFuncs.startMod(i[MOD_NAME], i[MOD_CLASS], i[MOD_TYPE], Std.parseInt(i[MOD_PF]), renderer.instance);
			if (i[MOD_LANE] != null)
				ModchartFuncs.setModTargetLane(i[MOD_NAME], i[MOD_LANE], renderer.instance);
		}
		renderer.modifierTable.reconstructTable();
	}

	public function loadPlayfields()
	{
		if (data == null || renderer == null)
			return;

		renderer.playfields = [];
		for (i in 0...data.playfields)
			renderer.addNewPlayfield(0, 0, 0, 1);
	}

	public function loadProxiefields()
	{
		if (data == null || renderer == null)
			return;

		renderer.proxiefields = [];
		for (i in 0...data.proxiefields)
			renderer.addNewProxiefield(new Proxiefield.Proxie());
	}

	public function loadEvents()
	{
		if (data == null || renderer == null)
			return;
		renderer.eventManager.clearEvents();
		for (i in data.events)
		{
			if (i[EVENT_REPEAT] == null) // add repeat data if it doesnt exist
				i[EVENT_REPEAT] = [false, 1, 0];

			if (i[EVENT_REPEAT][EVENT_REPEATBOOL])
			{
				for (j in 0...(Std.int(i[EVENT_REPEAT][EVENT_REPEATCOUNT]) + 1))
				{
					addEvent(i, (j * i[EVENT_REPEAT][EVENT_REPEATBEATGAP]));
				}
			}
			else
			{
				addEvent(i);
			}
		}
	}

	private function addEvent(i:Array<Dynamic>, ?beatOffset:Float = 0)
	{
		switch (i[EVENT_TYPE])
		{
			case "ease":
				ModchartFuncs.ease(Std.parseFloat(i[EVENT_DATA][EVENT_TIME]) + beatOffset, Std.parseFloat(i[EVENT_DATA][EVENT_EASETIME]),
					i[EVENT_DATA][EVENT_EASE], i[EVENT_DATA][EVENT_EASEDATA], renderer.instance);
			case "set":
				ModchartFuncs.set(Std.parseFloat(i[EVENT_DATA][EVENT_TIME]) + beatOffset, i[EVENT_DATA][EVENT_SETDATA], renderer.instance);
			case "hscript":
				// maybe just run some code???
		}
	}

	public function createDataFromRenderer() // a way to convert script modcharts into json modcharts
	{
		if (renderer == null)
			return;

		data.playfields = renderer.playfields.length;
		data.proxiefields = renderer.proxiefields.length;
		scriptListen = true;
	}
}

class CustomModifierScript
{
	public var interp:Interp = null;

	var script:Expr;
	var parser:Parser;

	public function new(scriptStr:String)
	{
		parser = new Parser();
		parser.allowTypes = true;
		parser.allowMetadata = true;
		parser.allowJSON = true;

		try
		{
			interp = new Interp();
			script = parser.parseString(scriptStr); // load da shit
			interp.execute(script);
		}
		catch (e)
		{
			lime.app.Application.current.window.alert(e.message, 'Error on custom mod .hx!');
			return;
		}
		init();
	}

	private function init()
	{
		if (interp == null)
			return;

		interp.variables.set('Math', Math);
		interp.variables.set('PlayfieldRenderer', PlayfieldRenderer);
		interp.variables.set('ModchartUtil', ModchartUtil);
		interp.variables.set('Modifier', Modifier);
		interp.variables.set('ModifierSubValue', Modifier.ModifierSubValue);
		interp.variables.set('BeatXModifier', Modifier.BeatXModifier);
		interp.variables.set('ModifierMath', Modifier.ModifierMath);
		interp.variables.set('NoteMovement', NoteMovement);
		interp.variables.set('NotePositionData', NotePositionData);
		interp.variables.set('ModchartFile', ModchartFile);
		interp.variables.set('FlxG', flixel.FlxG);
		interp.variables.set('FlxSprite', flixel.FlxSprite);
		interp.variables.set('FlxMath', FlxMath);
		interp.variables.set('FlxCamera', flixel.FlxCamera);
		interp.variables.set('FlxTimer', flixel.util.FlxTimer);
		interp.variables.set('FlxTween', flixel.tweens.FlxTween);
		interp.variables.set('FlxEase', flixel.tweens.FlxEase);
		interp.variables.set('PlayState', states.PlayState);
		interp.variables.set('game', states.PlayState.instance);
		interp.variables.set('Paths', backend.Paths);
		interp.variables.set('Conductor', backend.Conductor);
		interp.variables.set('StringTools', StringTools);
		interp.variables.set('Note', objects.Note);

		#if PSYCH
		interp.variables.set('ClientPrefs', backend.ClientPrefs);
		interp.variables.set('ColorSwap', shaders.ColorSwap);
		#end
	}

	public function call(event:String, args:Array<Dynamic>)
	{
		if (interp == null)
			return;
		if (interp.variables.exists(event)) // make sure it exists
		{
			try
			{
				if (args.length > 0)
					Reflect.callMethod(null, interp.variables.get(event), args);
				else
					interp.variables.get(event)(); // if function doesnt need an arg
			}
			catch (e)
			{
				lime.app.Application.current.window.alert(e.message, 'Error on custom mod .hx!');
			}
		}
	}

	public function initMod(mod:Modifier)
	{
		call("initMod", [mod]);
	}

	public function destroy()
	{
		interp = null;
	}
}
