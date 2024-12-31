package objects;

import backend.animation.PsychAnimationController;

import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;
import flixel.addons.effects.FlxSkewedSprite;

class StrumNote extends FlxSkewedSprite
{
	public var arrowMesh:modcharting.NewModchartArrow;
	public var z:Float = 0;
	public var arrowPath:SustainTrail = null;
	public var rgbShader:RGBShaderReference;
	public var resetAnim:Float = 0;
	public var noteData:Int = 0;
	public var direction:Float = 90;
	public var downScroll:Bool = false;
	public var sustainReduce:Bool = true;

	private var player:Int;

	public var notITGStrums:Bool = false;
	
	public var texture(default, set):String = null;
	private function set_texture(value:String):String {
		if(texture != value) {
			texture = value;
			reloadNote();
		}
		return value;
	}

	// Call this to create a mesh
	public function setupMesh():Void
	{
		if (arrowMesh == null)
		{
			arrowMesh = new modcharting.NewModchartArrow();
			arrowMesh.spriteGraphic = this;
			arrowMesh.doDraw = false;
			arrowMesh.copySpriteGraphic = false;
		}
		arrowMesh.setUp();
	}

	public var useRGBShader:Bool = true;
	var rgb9:Bool = false;
	public var myLibrary:String = "shared";
	public var loadShader:Bool = true;
	public function new(x:Float, y:Float, leData:Int, player:Int, ?daTexture:String, ?library:String = 'shared', ?quantizedNotes:Bool = false, ?loadShader:Bool = true) {
		animation = new PsychAnimationController(this);
		notITGStrums = (PlayState.SONG != null && PlayState.SONG.notITG && ClientPrefs.getGameplaySetting('modchart'));

		if (loadShader)
		{
			rgb9 = (player < 0);
			rgbShader = new RGBShaderReference(this, !quantizedNotes ? Note.initializeGlobalRGBShader(leData, rgb9) : 
				Note.initializeGlobalQuantRBShader(leData));
			rgbShader.enabled = false;
			if(PlayState.SONG != null && PlayState.SONG.disableNoteRGB) useRGBShader = false;
			var arr:Array<FlxColor> = !quantizedNotes ? (rgb9 ? ClientPrefs.data.arrowRGB9[leData] : ClientPrefs.data.arrowRGB[leData]) : ClientPrefs.data.arrowRGBQuantize[leData];
			if (!quantizedNotes && !rgb9 && PlayState.isPixelStage) ClientPrefs.data.arrowRGBPixel[leData];

			if(leData <= arr.length)
			{
				@:bypassAccessor
				{
					rgbShader.r = arr[0];
					rgbShader.g = arr[1];
					rgbShader.b = arr[2];
				}
			}
		}
		if(PlayState.SONG != null && PlayState.SONG.disableNoteRGB) useRGBShader = false;

		noteData = leData;
		this.player = player;
		this.noteData = leData;
		this.ID = noteData;
		this.loadShader = loadShader;
		super(x, y);

		myLibrary = library;
		var skin = 'Skins/Notes/'+ClientPrefs.data.notesSkin[0]+'/NOTE_assets';
		daTexture = daTexture != null ? daTexture : skin;
		if(!Paths.fileExists('images/$skin.png', IMAGE))
		{
			if(PlayState.SONG != null && PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1) skin = PlayState.SONG.arrowSkin;
			else skin = Note.defaultNoteSkin;

			var customSkin:String = skin + Note.getNoteSkinPostfix();
			if(Paths.fileExists('images/$customSkin.png', IMAGE)) skin = customSkin;
		}
		if (daTexture != null) texture = daTexture else texture = skin;

		scrollFactor.set();
		playAnim('static');
	}

	// override function updateColorTransform():Void
	// {
	// 	if (arrowMesh != null) arrowMesh.updateCol();
	// 	super.updateColorTransform();
	// }

	public function reloadNote()
	{
		var lastAnim:String = null;
		if(animation.curAnim != null) lastAnim = animation.curAnim.name;

		var notesAnim:Array<String> = rgb9 ? ["UP", "UP", "UP", "UP", "UP", "UP", "UP", "UP", "UP"] : ['LEFT', 'DOWN', 'UP', 'RIGHT'];
		var pressAnim:Array<String> = rgb9 ? ["up", "up", "up", "up", "up", "up", "up", "up", "up"] : ['left', 'down', 'up', 'right'];
		var colorAnims:Array<String> = rgb9 ? ["green", "green", "green", "green", "green", "green", "green", "green", "green"] : ['purple', 'blue', 'green', 'red'];

		var daNoteData:Int = Std.int(Math.abs(noteData) % 4);

		if(PlayState.isPixelStage)
		{
			var testingGraphic = Paths.image('pixelUI/' + texture, null, !notITGStrums);
			if (testingGraphic == null)
			{
				texture = "noteSkins/NOTE_assets" + Note.getNoteSkinPostfix();
				testingGraphic = Paths.image('pixelUI/' + texture, null, !notITGStrums);
				if (testingGraphic == null) texture = "NOTE_assets";
			}
			loadGraphic(Paths.image('pixelUI/' + texture, null, !notITGStrums));
			width = width / 4;
			height = height / 5;
			loadGraphic(Paths.image('pixelUI/' + texture, null, !notITGStrums), true, Math.floor(width), Math.floor(height));

			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));

			animation.add('green', [6]);
			animation.add('red', [7]);
			animation.add('blue', [5]);
			animation.add('purple', [4]);

			animation.add('static', [0 + daNoteData]);
			animation.add('pressed', [4 + daNoteData, 8 + daNoteData], 12, false);
			animation.add('confirm', [12 + daNoteData, 16 + daNoteData], 24, false);
		}
		else
		{
			frames = Paths.getSparrowAtlas(texture, null, !notITGStrums);
			animation.addByPrefix('green', 'arrowUP');
			animation.addByPrefix('blue', 'arrowDOWN');
			animation.addByPrefix('purple', 'arrowLEFT');
			animation.addByPrefix('red', 'arrowRIGHT');

			antialiasing = ClientPrefs.data.antialiasing;
			setGraphicSize(Std.int(width * 0.7));

			animation.addByPrefix(colorAnims[daNoteData], 'arrow' + notesAnim[daNoteData]);

			animation.addByPrefix('static', 'arrow' + notesAnim[daNoteData]);
			animation.addByPrefix('pressed', pressAnim[daNoteData] + ' press', 24, false);
			animation.addByPrefix('confirm', pressAnim[daNoteData] + ' confirm', 24, false);
		}
		updateHitbox();

		if(lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
		if (arrowMesh != null) arrowMesh.updateCol();
	}

	public function playerPosition()
	{
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		if(animation.curAnim != null)
		{
			centerOffsets();
			centerOrigin();
		}
		if(loadShader && useRGBShader) rgbShader.enabled = (animation.curAnim != null && animation.curAnim.name != 'static');
	}

	public override function kill():Void
	{
		super.kill();
	}
	
	public override function revive():Void
	{
		super.revive();
		if (arrowMesh != null) arrowMesh.updateCol();
	}
	
	override public function destroy():Void
	{
		super.destroy();
		}
}
