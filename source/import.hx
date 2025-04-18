#if !macro
// Discord API
#if DISCORD_ALLOWED
import backend.Discord;
#end
// Psych
#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end
// import HazardAFT as AFT_capture;
import backend.BaseStage;
import backend.ClientPrefs;
import backend.Conductor;
import backend.Controls;
import backend.CoolUtil;
import backend.CustomFadeTransition;
import backend.Difficulty;
import backend.Highscore;
import backend.Language;
import backend.Mods;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.Paths;
import backend.ui.*; // Psych-UI
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;
import lime.app.Application;
import lime.system.System;
import mikolka.funkin.*;
import mikolka.funkin.custom.*;
import mikolka.funkin.players.*;
import mikolka.funkin.utils.*;
import mobile.backend.StorageUtil;
import mobile.backend.SwipeUtil;
import mobile.backend.TouchUtil;
import mobile.input.MobileInputID;
import modcharting.*;
import objects.Alphabet;
import objects.BGSprite;
import openfl.Lib;
import shaders.flixel.system.FlxShader;
import states.LoadingState;
import states.MainMenuState;
import states.PlayState;
import states.StoryMenuState;
import states.stages.objects.*;

using StringTools;

#if ACHIEVEMENTS_ALLOWED
import backend.Achievements;
#end
// Mobile Controls
#if TOUCH_CONTROLS_ALLOWED
import mobile.backend.MobileData;
import mobile.input.MobileInputManager;
import mobile.objects.Hitbox;
import mobile.objects.TouchButton;
import mobile.objects.TouchPad;
#end
// Android
#if android
import android.Permissions as AndroidPermissions;
import android.Settings as AndroidSettings;
import android.Tools as AndroidTools;
import android.content.Context as AndroidContext;
import android.os.BatteryManager as AndroidBatteryManager;
import android.os.Build.VERSION as AndroidVersion;
import android.os.Build.VERSION_CODES as AndroidVersionCode;
import android.os.Environment as AndroidEnvironment;
import android.widget.Toast as AndroidToast;
#end
#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end
// P-Slice
// Stage imports (for compatibility)
#if flxanimate
import flxanimate.*;
import flxanimate.PsychFlxAnimate as FlxAnimate;
#end

// Mod libs
// Flixel
// Modcharting
#end
