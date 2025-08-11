package backend;

import haxe.CallStack;
import mikolka.vslice.components.crash.CrashState;
import openfl.events.UncaughtErrorEvent;

using StringTools;
using flixel.util.FlxArrayUtil;

#if sys
import sys.io.File;
#end

/**
 * Crash Handler.
 * @author YoshiCrafter29, Ne_Eo, MAJigsaw77 and Lily Ross (mcagabe19)
 */
class CrashHandler
{
	public static function init():Void
	{
		trace("hooking openfl crash handler");
		openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
		#if cpp 
		trace("hooking hxcpp crash handler");
		untyped __global__.__hxcpp_set_critical_error_handler(onError);
		#elseif hl
		trace("hooking hashlink crash handler");
		hl.Api.setErrorHandler(onError);
		#end
		trace("done with crash handler");
	}

	private static function onUncaughtError(e:UncaughtErrorEvent):Void
	{
		var crashState = new CrashState(e.error, CallStack.exceptionStack(true));
		e.preventDefault();
		FlxG.switchState(crashState);
	}

	#if (cpp || hl)
	private static function onError(message:Dynamic):Void
	{
		final log:Array<String> = [];

		if (message != null && message.length > 0)
			log.push(message);

		log.push(haxe.CallStack.toString(haxe.CallStack.exceptionStack(true)));

		#if sys
		saveErrorMessage(log.join('\n'));
		#end

		CoolUtil.showPopUp(log.join('\n'), "Critical Error!");
		#if DISCORD_ALLOWED DiscordClient.shutdown(); #end
		lime.system.System.exit(1);
	}
	#end

	#if sys
	private static function saveErrorMessage(message:String):Void
	{
		try
		{
			if (!NativeFileSystem.exists('logs'))
				NativeFileSystem.createDirectory('logs');

			File.saveContent('logs/' + Date.now().toString().replace(' ', '-').replace(':', "'") + '.txt', message);
		}
		catch (e:haxe.Exception)
			trace('Couldn\'t save error message. (${e.message})');
	}
	#end
}
