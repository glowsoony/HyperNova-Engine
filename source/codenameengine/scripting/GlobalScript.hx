package codenameengine.scripting;

import Conductor;
import flixel.FlxState;
import Mods;
import flixel.FlxG;

#if HSCRIPT_ALLOWED
/**
 * Class for THE Global Script, aka script that runs in the background at all times.
 */
class GlobalScript {
	public static var scripts:ScriptPack;

	public static function init() {
		FlxG.signals.focusGained.add(function() {
			call("focusGained");
		});
		FlxG.signals.focusLost.add(function() {
			call("focusLost");
		});
		FlxG.signals.gameResized.add(function(w:Int, h:Int) {
			call("gameResized", [w, h]);
		});
		FlxG.signals.postDraw.add(function() {
			call("postDraw");
		});
		FlxG.signals.postGameReset.add(function() {
			call("postGameReset");
		});
		FlxG.signals.postGameStart.add(function() {
			call("postGameStart");
		});
		FlxG.signals.postStateSwitch.add(function() {
			call("postStateSwitch");
		});
		FlxG.signals.postUpdate.add(function() {
			call("postUpdate", [FlxG.elapsed]);
			if (FlxG.keys.justPressed.F12) {
				if (scripts != null && scripts.scripts.length > 0) {
					trace('Reloading global script...');
					scripts.reload();
					trace('Global script successfully reloaded.');
				} else {
					trace('Loading global script...');
				}
			}
		});
		FlxG.signals.preDraw.add(function() {
			call("preDraw");
		});
		FlxG.signals.preGameReset.add(function() {
			call("preGameReset");
		});
		FlxG.signals.preGameStart.add(function() {
			call("preGameStart");
		});
		FlxG.signals.preStateCreate.add(function(state:FlxState) {
			call("preStateCreate", [state]);
		});
		FlxG.signals.preStateSwitch.add(function() {
			call("preStateSwitch", []);
		});
		FlxG.signals.preUpdate.add(function() {
			call("preUpdate", [FlxG.elapsed]);
			call("update", [FlxG.elapsed]);
		});
	}

	public static function call(name:String, ?args:Array<Dynamic>) {
		if (scripts != null) scripts.call(name, args);
	}
}
#end