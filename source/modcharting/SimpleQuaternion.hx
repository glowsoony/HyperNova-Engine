package modcharting;

import modcharting.ModchartUtil;
import flixel.math.FlxAngle;
import openfl.geom.Vector3D;
import flixel.math.FlxMath;

@:structInit
@:publicFields
class Quaternion { //new class (used for 3D perspective rotation stuff)
	var x:Float;
	var y:Float;
	var z:Float;
	var w:Float;

	function new(x:Float, y:Float, z:Float, w:Float) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	function multiply(q:Quaternion):Quaternion {
		return new Quaternion(w * q.x
			+ x * q.w
			+ y * q.z
			- z * q.y, w * q.y
			- x * q.z
			+ y * q.w
			+ z * q.x, w * q.z
			+ x * q.y
			- y * q.x
			+ z * q.w,
			w * q.w
			- x * q.x
			- y * q.y
			- z * q.z);
	}

	function rotateVector(v:Vector3D):Vector3D {
		var qVec = new Quaternion(v.x, v.y, v.z, 0);
		var qConj = new Quaternion(-x, -y, -z, w);
		var result = this.multiply(qVec).multiply(qConj);
		return new Vector3D(result.x, result.y, result.z);
	}

	static function fromAxisAngle(axis:Vector3D, angleRad:Float):Quaternion {
		var sinHalfAngle = FlxMath.fastSin(angleRad * .5);
		var cosHalfAngle = FlxMath.fastCos(angleRad * .5);
		return new Quaternion(axis.x * sinHalfAngle, axis.y * sinHalfAngle, axis.z * sinHalfAngle, cosHalfAngle);
	}
}

@:publicFields
@:structInit
class BaseQuaternion //renamed class for some MT utility shit (it might break if i use the class with the extend)
{
    var x:Float;
    var y:Float;
    var z:Float;
    var w:Float;
}
//me whenthe
class SimpleQuaternion
{
    //no more gimbal lock fuck you
    public static function fromEuler(roll:Float, pitch:Float, yaw:Float) : BaseQuaternion
    {
        //https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
        var cr = Math.cos(roll * FlxAngle.TO_RAD);
        var sr = Math.sin(roll * FlxAngle.TO_RAD);
        var cp = Math.cos(pitch * FlxAngle.TO_RAD);
        var sp = Math.sin(pitch * FlxAngle.TO_RAD);
        var cy = Math.cos(yaw * FlxAngle.TO_RAD);
        var sy = Math.sin(yaw * FlxAngle.TO_RAD);
    
        var q:BaseQuaternion = {x: 0, y: 0, z: 0, w:0 };
        q.w = cr * cp * cy + sr * sp * sy;
        q.x = sr * cp * cy - cr * sp * sy;
        q.y = cr * sp * cy + sr * cp * sy;
        q.z = cr * cp * sy - sr * sp * cy;
        return q;
    }
    public static function transformVector(v:Vector3D, q:BaseQuaternion) : Vector3D
    {
        

        return v;
    }
    public static function normalize(q:BaseQuaternion) : BaseQuaternion
    {
        var length = Math.sqrt(q.w*q.w + q.x*q.x + q.y*q.y + q.z*q.z);
        q.w = q.w / length;
        q.x = q.x / length;
        q.y = q.y / length;
        q.z = q.z / length;

        return q;
    }
    public static function conjugate(q:BaseQuaternion) : BaseQuaternion
    {
        q.y = -q.y;
        q.z = -q.z;
        q.w = -q.w;
        return q;
    }
    public static function multiply(q1:BaseQuaternion, q2:BaseQuaternion) : BaseQuaternion
    {
        var x = q1.x * q2.x - q1.y * q2.y - q1.z * q2.z - q1.w * q2.w;
        var y = q1.x * q2.y + q1.y * q2.x + q1.z * q2.w - q1.w * q2.z;
        var z = q1.x * q2.z - q1.y * q2.w + q1.z * q2.x + q1.w * q2.y;
        var w = q1.x * q2.w + q1.y * q2.z - q1.z * q2.y + q1.w * q2.x;

        q1.x = x;
        q1.y = y;
        q1.z = z;
        q1.w = w;

        return q1;
    }
}