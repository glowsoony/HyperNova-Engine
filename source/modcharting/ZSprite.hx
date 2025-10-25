package modcharting;

import flixel.FlxSprite;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxGraphicAsset;
// import funkin.play.notes.Strumline;
import lime.math.Vector2;
import modcharting.*;

class ZSprite extends FlxSkewedSprite // class ZSprite extends FlxSprite
{
	// This sprites z position. Used for perspective math.
	public var z:Float = 0.0;

	// lol?
	public var z2:Float = 0.0;
	public var y2:Float = 0.0;
	public var x2:Float = 0.0;

	// Used for orient mod, but could be useful to use?
	public var lastKnownPosition:Vector2;

	// Sometimes orient mod just has a heart attack and dies. This should make the notes spazz out less in the event that happens. just a bandaid fix for the NaN problem from orient.
	public var lastKnownOrientAngle:Float;

	// Was a test so that when Z-Sort mod gets disabled, everything can get returned to their proper strums.
	// public var weBelongTo:Strumline = null;
	// some extra variables for stealthGlow
	// jank way of doing it but, too bad
	public var stealthGlow:Float; // 0 = not applied. 1 = fully lit.
	// the white glow of stealth's RED color value
	public var stealthGlowRed:Float;
	// the white glow of stealth's GREEN color value
	public var stealthGlowGreen:Float;
	// the white glow of stealth's BLUE color value
	public var stealthGlowBlue:Float;

	public var hueShift:Float;

	public function new(?x:Float = 0, ?y:Float = 0, ?simpleGraphic:FlxGraphicAsset)
	{
		super(x, y, simpleGraphic);
		lastKnownPosition = new Vector2(x, y);
		stealthGlow = 0.0;
		stealthGlowRed = 1.0;
		stealthGlowGreen = 1.0;
		stealthGlowBlue = 1.0;
	}

	// Feed a noteData into this function to apply all of it's parameters to this sprite!
	public function applyNoteData(data:NotePositionData, applyFake3D:Bool = false):Void
	{
		this.x = data.x + x2;
		this.y = data.y + y2;
		this.z = data.z + z2;

		this.angle = data.angleZ;

		this.scale.x = data.scaleX;
		this.scale.y = data.scaleY;

		// temp for now
		if (applyFake3D)
		{
			this.scale.x *= FlxMath.fastCos(data.angleY * (Math.PI / 180));
			this.scale.y *= FlxMath.fastCos(data.angleX * (Math.PI / 180));
		}

		this.alpha = data.alpha;

		this.stealthGlow = data.stealth;
		this.stealthGlowRed = data.stealthGlowRed;
		this.stealthGlowGreen = data.stealthGlowGreen;
		this.stealthGlowBlue = data.stealthGlowBlue;

		this.skew.x = data.skewX;
		this.skew.y = data.skewY;

		this.color.redFloat = data.red;
		this.color.greenFloat = data.green;
		this.color.blueFloat = data.blue;

		this.hueShift = data.hueShift;

		this.lastKnownPosition = data.lastKnownPosition;
		this.lastKnownOrientAngle = data.lastKnownOrientAngle;
	}

	// Call this to update last known position... lol?
	public function updateLastKnownPos():Void
	{
		if (lastKnownPosition == null)
			lastKnownPosition = new Vector2(this.x, this.y);
		else
		{
			lastKnownPosition.x = this.x;
			lastKnownPosition.y = this.y;
		}
	}
}
