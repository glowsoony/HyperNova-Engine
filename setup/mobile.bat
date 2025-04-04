cd ..
echo Making the haxelib and setuping folder in same time...
haxelib newrepo
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib install openfl 9.3.3 --quiet
haxelib install flixel-addons 3.2.2 --quiet
haxelib install flixel-tools 1.5.1 --quiet
haxelib install hscript-iris 1.1.3 --quiet
haxelib install tjson 1.4.0 --quiet
haxelib install hxvlc 1.8.2 --quiet --skip-dependencies
haxelib install compiletime --quiet
haxelib install hscript --quiet
haxelib git hxcpp https://github.com/mcagabe19-stuff/hxcpp --quiet
haxelib git lime https://github.com/mcagabe19-stuff/lime 677f8b2878a9c35b74de0a91d6e6921e96ef5744 --quiet
haxelib git flixel https://github.com/Psych-Slice/p-slice-1.0-flixel 4cb4b8a51ef00abb4a7881bb869b13e399e82577 --quiet
haxelib git flxanimate https://github.com/Psych-Slice/FlxAnimate.git 18091dfeb629ba2805a5f3e10f5de80433080359 --quiet
haxelib git linc_luajit https://github.com/MobilePorting/linc_luajit --quiet
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc f9353b9edce10f4605d125dd1bda24ac36898bfb --quiet --skip-dependencies
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90 --quiet --skip-dependencies
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666 --quiet
haxelib git FlxPartialSound https://github.com/FunkinDroidTeam/FlxPartialSound.git 2b7943ba50eb41cf8f70e1f2089a5bd7ef242947 --quiet
haxelib git extension-androidtools https://github.com/MAJigsaw77/extension-androidtools --quiet --skip-dependencies
haxelib git hscript-improved https://github.com/glowsoony/hscript-improved custom-classes --quiet
echo Finished!
echo Now, get Android NDK: https://developer.android.com/ndk/downloads
echo Then, get Android SDK: https://developer.android.com/studio - And install the SDK Tools
echo And, get Java JDK Temurin: https://adoptium.net/es/temurin/releases/?version=17&os=windows
pause