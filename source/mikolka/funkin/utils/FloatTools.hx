package mikolka.funkin.utils;

class FloatTools
{
	public static function clamp(value:Float, min:Float, max:Float):Float
		return Math.max(min, Math.min(max, value));
}
