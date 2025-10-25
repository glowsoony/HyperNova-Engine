package psychlua;

import Type.ValueType;
import backend.WeekData;
import flixel.FlxState;
import objects.Character;
import openfl.display.BlendMode;
import psychlua.FunkinLua.LuaCamera;
import substates.GameOverSubstate;

typedef LuaTweenOptions =
{
	type:FlxTweenType,
	startDelay:Float,
	onUpdate:Null<String>,
	onStart:Null<String>,
	onComplete:Null<String>,
	loopDelay:Float,
	ease:EaseFunction
}

class LuaUtils
{
	public static final Function_Stop:String = "##PSYCHLUA_FUNCTIONSTOP";
	public static final Function_Continue:String = "##PSYCHLUA_FUNCTIONCONTINUE";
	public static final Function_StopLua:String = "##PSYCHLUA_FUNCTIONSTOPLUA";
	public static final Function_StopHScript:String = "##PSYCHLUA_FUNCTIONSTOPHSCRIPT";
	public static final Function_StopAll:String = "##PSYCHLUA_FUNCTIONSTOPALL";

	public static function getLuaTween(options:Dynamic)
	{
		return (options != null) ? {
			type: getTweenTypeByString(options.type),
			startDelay: options.startDelay,
			onUpdate: options.onUpdate,
			onStart: options.onStart,
			onComplete: options.onComplete,
			loopDelay: options.loopDelay,
			ease: getTweenEaseByString(options.ease)
		} : null;
	}

	public static function setVarInArray(instance:Dynamic, variable:String, value:Dynamic, allowMaps:Bool = false):Any
	{
		var splitProps:Array<String> = variable.split('[');
		if (splitProps.length > 1)
		{
			var target:Dynamic = null;
			if (MusicBeatState.getVariables().exists(splitProps[0]))
			{
				var retVal:Dynamic = MusicBeatState.getVariables().get(splitProps[0]);
				if (retVal != null)
					target = retVal;
			}
			else
				target = Reflect.getProperty(instance, splitProps[0]);

			for (i in 1...splitProps.length)
			{
				var j:Dynamic = splitProps[i].substr(0, splitProps[i].length - 1);
				if (i >= splitProps.length - 1) // Last array
					target[j] = value;
				else // Anything else
					target = target[j];
			}
			return target;
		}

		if (allowMaps && isMap(instance))
		{
			// trace(instance);
			instance.set(variable, value);
			return value;
		}

		if (MusicBeatState.getVariables().exists(variable))
		{
			MusicBeatState.getVariables().set(variable, value);
			return value;
		}
		Reflect.setProperty(instance, variable, value);
		return value;
	}

	public static function getVarInArray(instance:Dynamic, variable:String, allowMaps:Bool = false):Any
	{
		var splitProps:Array<String> = variable.split('[');
		if (splitProps.length > 1)
		{
			var target:Dynamic = null;
			if (MusicBeatState.getVariables().exists(splitProps[0]))
			{
				var retVal:Dynamic = MusicBeatState.getVariables().get(splitProps[0]);
				if (retVal != null)
					target = retVal;
			}
			else
				target = Reflect.getProperty(instance, splitProps[0]);

			for (i in 1...splitProps.length)
			{
				var j:Dynamic = splitProps[i].substr(0, splitProps[i].length - 1);
				target = target[j];
			}
			return target;
		}

		if (allowMaps && isMap(instance))
		{
			// trace(instance);
			return instance.get(variable);
		}

		if (MusicBeatState.getVariables().exists(variable))
		{
			var retVal:Dynamic = MusicBeatState.getVariables().get(variable);
			if (retVal != null)
				return retVal;
		}
		return Reflect.getProperty(instance, variable);
	}

	public static function getModSetting(saveTag:String, ?modName:String = null)
	{
		#if MODS_ALLOWED
		if (FlxG.save.data.modSettings == null)
			FlxG.save.data.modSettings = new Map<String, Dynamic>();

		var settings:Map<String, Dynamic> = FlxG.save.data.modSettings.get(modName);
		var path:String = Paths.mods('$modName/data/settings.json');
		if (NativeFileSystem.exists(path))
		{
			if (settings == null || !settings.exists(saveTag))
			{
				if (settings == null)
					settings = new Map<String, Dynamic>();
				var data:String = NativeFileSystem.getContent(path);
				try
				{
					// FunkinLua.luaTrace('getModSetting: Trying to find default value for "$saveTag" in Mod: "$modName"');
					var parsedJson:Dynamic = tjson.TJSON.parse(data);
					for (i in 0...parsedJson.length)
					{
						var sub:Dynamic = parsedJson[i];
						if (sub != null && sub.save != null && !settings.exists(sub.save))
						{
							if (sub.type != 'keybind' && sub.type != 'key')
							{
								if (sub.value != null)
								{
									// FunkinLua.luaTrace('getModSetting: Found unsaved value "${sub.save}" in Mod: "$modName"');
									settings.set(sub.save, sub.value);
								}
							}
							else
							{
								// FunkinLua.luaTrace('getModSetting: Found unsaved keybind "${sub.save}" in Mod: "$modName"');
								settings.set(sub.save,
									{keyboard: (sub.keyboard != null ? sub.keyboard : 'NONE'), gamepad: (sub.gamepad != null ? sub.gamepad : 'NONE')});
							}
						}
					}
					FlxG.save.data.modSettings.set(modName, settings);
				}
				catch (e:Dynamic)
				{
					var errorTitle = 'Mod name: ' + Mods.currentModDirectory;
					var errorMsg = 'An error occurred: $e';
					CoolUtil.showPopUp(errorMsg, errorTitle);
					trace('$errorTitle - $errorMsg');
				}
			}
		}
		else
		{
			FlxG.save.data.modSettings.remove(modName);
			#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
			PlayState.instance.addTextToDebug('getModSetting: $path could not be found!', FlxColor.RED);
			#else
			FlxG.log.warn('getModSetting: $path could not be found!');
			#end
			return null;
		}

		if (settings.exists(saveTag))
			return settings.get(saveTag);
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		PlayState.instance.addTextToDebug('getModSetting: "$saveTag" could not be found inside $modName\'s settings!', FlxColor.RED);
		#else
		FlxG.log.warn('getModSetting: "$saveTag" could not be found inside $modName\'s settings!');
		#end
		#end
		return null;
	}

	public static function isMap(variable:Dynamic)
	{
		/*switch(Type.typeof(variable)){
			case ValueType.TClass(haxe.ds.StringMap) | ValueType.TClass(haxe.ds.ObjectMap) | ValueType.TClass(haxe.ds.IntMap) | ValueType.TClass(haxe.ds.EnumValueMap):
				return true;
			default:
				return false;
		}*/

		// trace(variable);//! FlxState implements iterator for Playstate, but we can't use them like MAPs
		if (variable.exists != null && variable.keyValueIterator != null && !Std.isOfType(variable, FlxState))
			return true;
		return false;
	}

	public static function setGroupStuff(leArray:Dynamic, variable:String, value:Dynamic, ?allowMaps:Bool = false)
	{
		var split:Array<String> = variable.split('.');
		if (split.length > 1)
		{
			var obj:Dynamic = Reflect.getProperty(leArray, split[0]);
			for (i in 1...split.length - 1)
				obj = Reflect.getProperty(obj, split[i]);

			leArray = obj;
			variable = split[split.length - 1];
		}
		if (allowMaps && isMap(leArray))
			leArray.set(variable, value);
		else
			Reflect.setProperty(leArray, variable, value);
		return value;
	}

	public static function getGroupStuff(leArray:Dynamic, variable:String, ?allowMaps:Bool = false)
	{
		var split:Array<String> = variable.split('.');
		if (split.length > 1)
		{
			var obj:Dynamic = Reflect.getProperty(leArray, split[0]);
			for (i in 1...split.length - 1)
				obj = Reflect.getProperty(obj, split[i]);

			leArray = obj;
			variable = split[split.length - 1];
		}

		if (allowMaps && isMap(leArray))
			return leArray.get(variable);
		return Reflect.getProperty(leArray, variable);
	}

	public static function getPropertyLoop(split:Array<String>, ?getProperty:Bool = true, ?allowMaps:Bool = false):Dynamic
	{
		var obj:Dynamic = getObjectDirectly(split[0]);
		var end = split.length;
		if (getProperty)
			end = split.length - 1;

		for (i in 1...end)
			obj = getVarInArray(obj, split[i], allowMaps);
		return obj;
	}

	public static function getObjectDirectly(objectName:String, ?allowMaps:Bool = false):Dynamic
	{
		switch (objectName)
		{
			case 'this' | 'instance' | 'game':
				return PlayState.instance;

			default:
				var obj:Dynamic = MusicBeatState.getVariables().get(objectName);
				if (obj == null)
					obj = getVarInArray(MusicBeatState.getState(), objectName, allowMaps);
				return obj;
		}
	}

	public static function isOfTypes(value:Any, types:Array<Dynamic>)
	{
		for (type in types)
		{
			if (Std.isOfType(value, type))
				return true;
		}
		return false;
	}

	public static function getTargetInstance()
	{
		if (PlayState.instance != null)
			return PlayState.instance.isDead ? GameOverSubstate.instance : PlayState.instance;
		return MusicBeatState.getState();
	}

	public static inline function getLowestCharacterGroup():FlxSpriteGroup
	{
		var group:FlxSpriteGroup = PlayState.instance.gfGroup;
		var pos:Int = PlayState.instance.members.indexOf(group);

		var newPos:Int = PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup);
		if (newPos < pos)
		{
			group = PlayState.instance.boyfriendGroup;
			pos = newPos;
		}

		newPos = PlayState.instance.members.indexOf(PlayState.instance.dadGroup);
		if (newPos < pos)
		{
			group = PlayState.instance.dadGroup;
			pos = newPos;
		}
		return group;
	}

	public static function addAnimByIndices(obj:String, name:String, prefix:String, indices:Any = null, framerate:Float = 24, loop:Bool = false)
	{
		var obj:FlxSprite = cast LuaUtils.getObjectDirectly(obj);
		if (obj != null && obj.animation != null)
		{
			if (indices == null)
				indices = [0];
			else if (Std.isOfType(indices, String))
			{
				var strIndices:Array<String> = cast(indices, String).trim().split(',');
				var myIndices:Array<Int> = [];
				for (i in 0...strIndices.length)
				{
					myIndices.push(Std.parseInt(strIndices[i]));
				}
				indices = myIndices;
			}

			if (prefix != null)
				obj.animation.addByIndices(name, prefix, indices, '', framerate, loop);
			else
				obj.animation.addByIndices(name, prefix, indices, '', framerate, loop);

			if (obj.animation.curAnim == null)
			{
				var dyn:Dynamic = cast obj;
				if (dyn.playAnim != null)
					dyn.playAnim(name, true);
				else
					dyn.animation.play(name, true);
			}
			return true;
		}
		return false;
	}

	public static function loadFrames(spr:FlxSprite, image:String, spriteType:String)
	{
		switch (spriteType.toLowerCase().replace(' ', ''))
		{
			// case "texture" | "textureatlas" | "tex":
			// spr.frames = AtlasFrameMaker.construct(image);

			// case "texture_noaa" | "textureatlas_noaa" | "tex_noaa":
			// spr.frames = AtlasFrameMaker.construct(image, null, true);

			case 'aseprite', 'ase', 'json', 'jsoni8':
				spr.frames = Paths.getAsepriteAtlas(image);

			case "packer", 'packeratlas', 'pac':
				spr.frames = Paths.getPackerAtlas(image);

			case 'sparrow', 'sparrowatlas', 'sparrowv2':
				spr.frames = Paths.getSparrowAtlas(image);

			default:
				spr.frames = Paths.getAtlas(image);
		}
	}

	public static function destroyObject(tag:String)
	{
		var variables = MusicBeatState.getVariables();
		var obj:FlxSprite = variables.get(tag);
		if (obj == null || obj.destroy == null)
			return;

		LuaUtils.getTargetInstance().remove(obj, true);
		obj.destroy();
		variables.remove(tag);
	}

	public static function cancelTween(tag:String)
	{
		if (!tag.startsWith('tween_'))
			tag = 'tween_' + LuaUtils.formatVariable(tag);
		var variables = MusicBeatState.getVariables();
		var twn:FlxTween = variables.get(tag);
		if (twn != null)
		{
			twn.cancel();
			twn.destroy();
			variables.remove(tag);
		}
	}

	public static function cancelTimer(tag:String)
	{
		if (!tag.startsWith('timer_'))
			tag = 'timer_' + LuaUtils.formatVariable(tag);
		var variables = MusicBeatState.getVariables();
		var tmr:FlxTimer = variables.get(tag);
		if (tmr != null)
		{
			tmr.cancel();
			tmr.destroy();
			variables.remove(tag);
		}
	}

	public static function formatVariable(tag:String)
		return tag.trim().replace(' ', '_').replace('.', '');

	public static function tweenPrepare(tag:String, vars:String)
	{
		if (tag != null)
			cancelTween(tag);
		var variables:Array<String> = vars.split('.');
		var sexyProp:Dynamic = LuaUtils.getObjectDirectly(variables[0]);
		if (variables.length > 1)
			sexyProp = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(variables), variables[variables.length - 1]);
		return sexyProp;
	}

	public static function getBuildTarget():String
	{
		#if windows
		#if x86_BUILD
		return 'windows_x86';
		#else
		return 'windows';
		#end
		#elseif linux
		return 'linux';
		#elseif mac
		return 'mac';
		#elseif hl
		return 'hashlink';
		#elseif (html5 || emscripten || nodejs || winjs || electron)
		return 'browser';
		#elseif android
		return 'android';
		#elseif webos
		return 'webos';
		#elseif tvos
		return 'tvos';
		#elseif watchos
		return 'watchos';
		#elseif air
		return 'air';
		#elseif flash
		return 'flash';
		#elseif (ios || iphonesim)
		return 'ios';
		#elseif neko
		return 'neko';
		#elseif switch
		return 'switch';
		#else
		return 'unknown';
		#end
	}

	// buncho string stuffs
	public static function getTweenTypeByString(?type:String = '')
	{
		switch (type.toLowerCase().trim())
		{
			case 'backward':
				return FlxTweenType.BACKWARD;
			case 'looping' | 'loop':
				return FlxTweenType.LOOPING;
			case 'persist':
				return FlxTweenType.PERSIST;
			case 'pingpong':
				return FlxTweenType.PINGPONG;
		}
		return FlxTweenType.ONESHOT;
	}

	public static function getTweenEaseByString(?ease:String = ''):Float->Float
	{
		switch (ease.toLowerCase().trim())
		{
			case 'backin':
				return ImprovedEases.backIn;
			case 'backinout':
				return ImprovedEases.backInOut;
			case 'backout':
				return ImprovedEases.backOut;
			case 'backoutin':
				return ImprovedEases.backOutIn;
			case 'bounce':
				return ImprovedEases.bounce;
			case 'bouncein':
				return ImprovedEases.bounceIn;
			case 'bounceinout':
				return ImprovedEases.bounceInOut;
			case 'bounceout':
				return ImprovedEases.bounceOut;
			case 'bounceoutin':
				return ImprovedEases.bounceOutIn;
			case 'bell':
				return ImprovedEases.bell;
			case 'circin':
				return ImprovedEases.circIn;
			case 'circinout':
				return ImprovedEases.circInOut;
			case 'circout':
				return ImprovedEases.circOut;
			case 'circoutin':
				return ImprovedEases.circOutIn;
			case 'cubein':
				return ImprovedEases.cubeIn;
			case 'cubeinout':
				return ImprovedEases.cubeInOut;
			case 'cubeout':
				return ImprovedEases.cubeOut;
			case 'cubeoutin':
				return ImprovedEases.cubeOutIn;
			case 'elasticin':
				return ImprovedEases.elasticIn;
			case 'elasticinout':
				return ImprovedEases.elasticInOut;
			case 'elasticout':
				return ImprovedEases.elasticOut;
			case 'elasticoutin':
				return ImprovedEases.elasticOutIn;
			case 'expoin':
				return ImprovedEases.expoIn;
			case 'expoinout':
				return ImprovedEases.expoInOut;
			case 'expoout':
				return ImprovedEases.expoOut;
			case 'expooutin':
				return ImprovedEases.expoOutIn;
			case 'inverse':
				return ImprovedEases.inverse;
			case 'instant':
				return ImprovedEases.instant;
			case 'pop':
				return ImprovedEases.pop;
			case 'popelastic':
				return ImprovedEases.popElastic;
			case 'pulse':
				return ImprovedEases.pulse;
			case 'pulseelastic':
				return ImprovedEases.pulseElastic;
			case 'quadin':
				return ImprovedEases.quadIn;
			case 'quadinout':
				return ImprovedEases.quadInOut;
			case 'quadout':
				return ImprovedEases.quadOut;
			case 'quadoutin':
				return ImprovedEases.quadOutIn;
			case 'quartin':
				return ImprovedEases.quartIn;
			case 'quartinout':
				return ImprovedEases.quartInOut;
			case 'quartout':
				return ImprovedEases.quartOut;
			case 'quartoutin':
				return ImprovedEases.quartOutIn;
			case 'quintin':
				return ImprovedEases.quintIn;
			case 'quintinout':
				return ImprovedEases.quintInOut;
			case 'quintout':
				return ImprovedEases.quintOut;
			case 'quintoutin':
				return ImprovedEases.quintOutIn;
			case 'sinein':
				return ImprovedEases.sineIn;
			case 'sineinout':
				return ImprovedEases.sineInOut;
			case 'sineout':
				return ImprovedEases.sineOut;
			case 'sineoutin':
				return ImprovedEases.sineOutIn;
			case 'spike':
				return ImprovedEases.spike;
			case 'smoothstepin':
				return ImprovedEases.smoothStepIn;
			case 'smoothstepinout':
				return ImprovedEases.smoothStepInOut;
			case 'smoothstepout':
				return ImprovedEases.smoothStepOut;
			case 'smootherstepin':
				return ImprovedEases.smootherStepIn;
			case 'smootherstepinout':
				return ImprovedEases.smootherStepInOut;
			case 'smootherstepout':
				return ImprovedEases.smootherStepOut;
			case 'tap':
				return ImprovedEases.tap;
			case 'tapelastic':
				return ImprovedEases.tapElastic;
			case 'tri':
				return ImprovedEases.tri;
		}
		return ImprovedEases.linear;
	}

	public static function blendModeFromString(blend:String):BlendMode
	{
		switch (blend.toLowerCase().trim())
		{
			case 'add':
				return ADD;
			case 'alpha':
				return ALPHA;
			case 'darken':
				return DARKEN;
			case 'difference':
				return DIFFERENCE;
			case 'erase':
				return ERASE;
			case 'hardlight':
				return HARDLIGHT;
			case 'invert':
				return INVERT;
			case 'layer':
				return LAYER;
			case 'lighten':
				return LIGHTEN;
			case 'multiply':
				return MULTIPLY;
			case 'overlay':
				return OVERLAY;
			case 'screen':
				return SCREEN;
			case 'shader':
				return SHADER;
			case 'subtract':
				return SUBTRACT;
		}
		return NORMAL;
	}

	public static function typeToString(type:Int):String
	{
		#if LUA_ALLOWED
		switch (type)
		{
			case Lua.LUA_TBOOLEAN:
				return "boolean";
			case Lua.LUA_TNUMBER:
				return "number";
			case Lua.LUA_TSTRING:
				return "string";
			case Lua.LUA_TTABLE:
				return "table";
			case Lua.LUA_TFUNCTION:
				return "function";
		}
		if (type <= Lua.LUA_TNIL)
			return "nil";
		#end
		return "unknown";
	}

	public static function cameraFromString(cam:String):FlxCamera
	{
		var camera:LuaCamera = getCameraByName(cam);
		if (camera == null)
		{
			trace('I am null!');
			switch (cam.toLowerCase())
			{
				case 'camhud' | 'hud':
					return PlayState.instance.camHUD;
				// case 'notecameras0' | 'notes0': return PlayState.instance.noteCameras0;
				// case 'notecameras1' | 'notes1': return PlayState.instance.noteCameras1;
				case 'camproxy' | 'proxy':
					return PlayState.instance.camProxy;
				case 'camother' | 'other':
					return PlayState.instance.camOther;
				case 'caminterfaz' | 'interfaz':
					return PlayState.instance.camInterfaz;
				case 'camvisuals' | 'visuals':
					return PlayState.instance.camVisuals;
			}

			// modded cameras
			if (Std.isOfType(PlayState.instance.variables.get(cam), FlxCamera))
			{
				return PlayState.instance.variables.get(cam);
			}
			return PlayState.instance.camGame;
		}
		return camera.cam;
	}

	public static function getCameraByName(id:String):LuaCamera
	{
		if (FunkinLua.lua_Cameras.exists(id))
			return FunkinLua.lua_Cameras.get(id);
		switch (id.toLowerCase())
		{
			case 'camhud' | 'hud':
				return FunkinLua.lua_Cameras.get("hud");
			case 'notecameras0' | 'notes0':
				return FunkinLua.lua_Cameras.get("notecameras0");
			case 'notecameras1' | 'notes1':
				return FunkinLua.lua_Cameras.get("notecameras1");
			case 'camproxy' | 'proxy':
				return FunkinLua.lua_Cameras.get("proxy");
			case 'camother' | 'other':
				return FunkinLua.lua_Cameras.get("other");
			case 'caminterfaz' | 'interfaz':
				return FunkinLua.lua_Cameras.get("interfaz");
			case 'camvisuals' | 'visuals':
				return FunkinLua.lua_Cameras.get("visuals");
			case 'camgame' | 'game':
				return FunkinLua.lua_Cameras.get('game');
		}
		return null;
	}

	public static function killShaders() // dead
	{
		for (cam in FunkinLua.lua_Cameras)
		{
			cam.shaders = [];
			cam.shaderNames = [];
		}
	}

	public static function getActorByName(id:String):Dynamic // kade to psych
	{
		if (FunkinLua.lua_Cameras.exists(id))
			return FunkinLua.lua_Cameras.get(id).cam;

		// pre defined names
		switch (id)
		{
			case 'boyfriend' | 'bf':
				return PlayState.instance.boyfriend;
		}

		if (Std.parseInt(id) == null)
			return Reflect.getProperty(getTargetInstance(), id);

		return PlayState.instance.strumLineNotes.members[Std.parseInt(id)];
	}

	public static function pushCustomCameras(name:String, camera:FlxCamera)
	{
		final camBool:Bool = (camera != null);
		trace('name for cam: ' + name + ', is camera not null: ' + camBool);
		FunkinLua.lua_Cameras.set(name, {cam: camera, shaders: [], shaderNames: []});
	}
}
