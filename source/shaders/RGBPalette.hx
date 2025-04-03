package shaders;
import objects.Note;

class RGBPalette {
	public var shader(default, null):RGBPaletteShader = new RGBPaletteShader();
	public var r(default, set):FlxColor;
	public var g(default, set):FlxColor;
	public var b(default, set):FlxColor;
	public var mult(default, set):Float;

	public function copyValues(tempShader:RGBPalette)
		{
			if (tempShader != null)
			{
				for (i in 0...3)
				{
					shader.r.value[i] = tempShader.shader.r.value[i];
					shader.g.value[i] = tempShader.shader.g.value[i];
					shader.b.value[i] = tempShader.shader.b.value[i];
				}
				shader.mult.value[0] = tempShader.shader.mult.value[0];
			}
			else shader.mult.value[0] = 0.0;
		}
		
	private function set_r(color:FlxColor) {
		r = color;
		shader.r.value = [color.redFloat, color.greenFloat, color.blueFloat];
		return color;
	}

	private function set_g(color:FlxColor) {
		g = color;
		shader.g.value = [color.redFloat, color.greenFloat, color.blueFloat];
		return color;
	}

	private function set_b(color:FlxColor) {
		b = color;
		shader.b.value = [color.redFloat, color.greenFloat, color.blueFloat];
		return color;
	}
	
	private function set_mult(value:Float) {
		mult = Math.max(0, Math.min(1, value));
		shader.mult.value = [mult];
		return value;
	}

	private function set_stealthGlow(value:Float) {
		stealthGlow = value;
		shader._stealthGlow.value = [stealthGlow];
		return value;
	}
	private function set_stealthGlowRed(value:Float) {
		stealthGlowRed = value;
		shader._stealthR.value = [stealthGlowRed];
		return value;
	}
	private function set_stealthGlowGreen(value:Float) {
		stealthGlowGreen = value;
		shader._stealthG.value = [stealthGlowGreen];
		return value;
	}
	private function set_stealthGlowBlue(value:Float) {
		stealthGlowBlue = value;
		shader._stealthB.value = [stealthGlowBlue];
		return value;
	}

	private function set_enabled(value:Bool) {
		enabled = value;
		shader.enableRGB.value = [enabled];
		return value;
	}

	

	public function new()
	{
		r = 0xFFFF0000;
		g = 0xFF00FF00;
		b = 0xFF0000FF;
		mult = 1.0;

		stealthGlow = 0.0;
		stealthGlowRed = 1.0;
		stealthGlowGreen = 1.0;
		stealthGlowBlue = 1.0;

		enabled = true;
	}
}

// automatic handler for easy usability
class RGBShaderReference
{
	public var r(default, set):FlxColor;
	public var g(default, set):FlxColor;
	public var b(default, set):FlxColor;
	public var mult(default, set):Float;

	public var stealthGlow(default, set):Float;
	public var stealthGlowRed(default, set):Float;
	public var stealthGlowGreen(default, set):Float;
	public var stealthGlowBlue(default, set):Float;

	public var enabled(default, set):Bool = true;

	public var parent:RGBPalette;
	private var _owner:FlxSprite;
	private var _original:RGBPalette;
	public function new(owner:FlxSprite, ref:RGBPalette)
	{
		parent = ref;
		_owner = owner;
		_original = ref;
		owner.shader = ref.shader;

		@:bypassAccessor
		{
			r = parent.r;
			g = parent.g;
			b = parent.b;
			mult = parent.mult;

			stealthGlow = parent.stealthGlow;
			stealthGlowRed = parent.stealthGlowRed;
			stealthGlowGreen = parent.stealthGlowGreen;
			stealthGlowBlue = parent.stealthGlowBlue;
		}
	}
	
	private function set_r(value:FlxColor)
	{
		if(allowNew && value != _original.r) cloneOriginal();
		return (r = parent.r = value);
	}
	private function set_g(value:FlxColor)
	{
		if(allowNew && value != _original.g) cloneOriginal();
		return (g = parent.g = value);
	}
	private function set_b(value:FlxColor)
	{
		if(allowNew && value != _original.b) cloneOriginal();
		return (b = parent.b = value);
	}
	private function set_mult(value:Float)
	{
		if(allowNew && value != _original.mult) cloneOriginal();
		return (mult = parent.mult = value);
	}
	private function set_enabled(value:Bool)
	{
		if(allowNew && value != _original.enabled) cloneOriginal();
		return (enabled = parent.enabled = value);
	}

	private function set_stealthGlow(value:Float) {
		if(allowNew && value != _original.stealthGlow) cloneOriginal();
		return (stealthGlow = parent.stealthGlow = value);
	}
	private function set_stealthGlowRed(value:Float) {
		if(allowNew && value != _original.stealthGlowRed) cloneOriginal();
		return (stealthGlowRed = parent.stealthGlowRed = value);
	}
	private function set_stealthGlowGreen(value:Float) {
		if(allowNew && value != _original.stealthGlowGreen) cloneOriginal();
		return (stealthGlowGreen = parent.stealthGlowGreen = value);
	}
	private function set_stealthGlowBlue(value:Float) {
		if(allowNew && value != _original.stealthGlowBlue) cloneOriginal();
		return (stealthGlowBlue = parent.stealthGlowBlue = value);
	}

	public var allowNew = true;
	private function cloneOriginal()
	{
		if(allowNew)
		{
			allowNew = false;
			if(_original != parent) return;

			parent = new RGBPalette();
			parent.r = _original.r;
			parent.g = _original.g;
			parent.b = _original.b;
			parent.mult = _original.mult;

			parent.stealthGlow = _original.stealthGlow;
			parent.stealthGlowRed = _original.stealthGlowRed;
			parent.stealthGlowGreen = _original.stealthGlowGreen;
			parent.stealthGlowBlue = _original.stealthGlowBlue;

			parent.enabled = _original.enabled;
			_owner.shader = parent.shader;
			//trace('created new shader');
		}
	}
}

class RGBPaletteShader extends FlxShader {
	@:glFragmentHeader('
		#pragma header
		
		uniform vec3 r;
		uniform vec3 g;
		uniform vec3 b;
		uniform float mult;

		uniform float _stealthGlow;
		uniform float _stealthR;
		uniform float _stealthG;
		uniform float _stealthB;

		uniform bool enableRGB;

		vec4 flixel_texture2DCustom(sampler2D bitmap, vec2 coord) {
			vec4 color = flixel_texture2D(bitmap, coord);
			if (!hasTransform) {
				return color;
			}

			if(color.a == 0.0 || mult == 0.0) {
				return color * openfl_Alphav;
			}

			if(enableRGB){ //make sure this shit loads the "RGB" changes? but still able to use "stealth" (added for those mods who use stealth)
				vec4 newColor = color;
				newColor.rgb = min(color.r * r + color.g * g + color.b * b, vec3(1.0));
				newColor.a = color.a;
				
				color = mix(color, newColor, mult);
			}
				
			vec4 glow = vec4(_stealthR,_stealthG,_stealthB,1.0);
			glow *=  color.a;
			color = mix(color, glow, _stealthGlow);
			
			if(color.a > 0.0) {
				return vec4(color.rgb, color.a);
			}
			return vec4(0.0, 0.0, 0.0, 0.0);
		}')

	@:glFragmentSource('
		#pragma header

		void main() {
			gl_FragColor = flixel_texture2DCustom(bitmap, openfl_TextureCoordv);
		}')

	public function new()
	{
		super();
	}
}
