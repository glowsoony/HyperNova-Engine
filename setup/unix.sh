#!/bin/sh
# SETUP FOR MAC AND LINUX SYSTEMS!!!
# REMINDER THAT YOU NEED HAXE INSTALLED PRIOR TO USING THIS
# https://haxe.org/download
echo Makking the main haxelib and setuping folder in same time..
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib install openfl 9.4.1 --quiet --skip-dependencies
haxelib git flixel https://github.com/Psych-Slice/p-slice-1.0-flixel.git 9b1192a23fcfb456123efa14c63c8506ded20e5e --quiet --skip-dependencies
haxelib install lime 8.1.3 --quiet --skip-dependencies
haxelib install flixel-addons 3.3.2 --quiet --skip-dependencies
haxelib install flixel-tools 1.5.1 --quiet --skip-dependencies
haxelib install hscript-iris 1.1.3 --quiet
haxelib install tjson 1.4.0 --quiet
haxelib install hxdiscord_rpc 1.2.4 --quiet
haxelib git flxanimate https://github.com/Psych-Slice/FlxAnimate.git 82a720663f9ed6328d91a727c2b17501d91e3b11
haxelib git hxCodec https://github.com/polybiusproxy/hxCodec.git 0a51aed0d9523d22a83e453ce7b593ec7fed4742
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit 1906c4a96f6bb6df66562b3f24c62f4c5bba14a7
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666
haxelib git FlxPartialSound https://github.com/FunkinCrew/FlxPartialSound.git f986332ba5ab02abd386ce662578baf04904604a
haxelib git hscript-improved https://github.com/glowsoony/hscript-improved custom-classes
echo Finished!