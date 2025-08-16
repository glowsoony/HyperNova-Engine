package modcharting;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;
// import funkin.graphics.ZSprite;
// import funkin.play.modchartSystem.ModchartUtil;
import lime.math.Vector2;
import modcharting.*;
import openfl.Vector;
import openfl.display.TriangleCulling;
import openfl.geom.Matrix;
import openfl.geom.Vector3D;
import flixel.addons.effects.FlxSkewedSprite;

class NewModchartArrow extends FlxSkewedSprite
{
	// Makes the mesh all wobbly!
	public var vibrateEffect:Float = 0.0;

	public var vertOffsetX:Array<Float> = [];
	public var vertOffsetY:Array<Float> = [];
	public var vertOffsetZ:Array<Float> = [];

	public var z:Float = 0.0;

	public var z2:Float = 0.0;
	public var y2:Float = 0.0;
	public var x2:Float = 0.0;

	// Offset the perspective math center by this amount!
	public var perspectiveCenterOffset:Vector2 = new Vector2(0, 0);

	override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
	{
		var output:FlxPoint = super.getScreenPosition(result, camera);
		output.x += this.x2;
		output.y += this.y2;
		return output;
	}

	// If enabled, will apply 3D projection to this sprite. If disabled, renders like a normal sprite.
	public var projectionEnabled:Bool = true;

	// If true, will correct the texture distortion created when transforming in 3D
	public var doPerspectiveCorrection:Bool = true;

	// If true, will repeat the texture in the draw call. Otherwise texture will be clamped
	public var textureRepeat:Bool = false;

	// When scaling the UV, will only show the current active frame (instead of showing the entire atlas)
	public var frameBorderCut:Bool = false;

	// The culling this sprite will use (positive, negative, always_positive, always_negative, always, never)
	public var cullMode:String = "none";

	public var angleX:Float = 0;
	public var angleY:Float = 0;

	var angleZ(get, set):Float;

	function get_angleZ():Float
	{
		return this.angle ?? 0;
	}

	function set_angleZ(n:Float):Float
	{
		this.angle = n;
		return this.angle;
	}

	// for group shit
	public var angleX2:Float = 0;
	public var angleY2:Float = 0;
	public var angleZ2:Float = 0;

	public var scaleZ:Float = 1;

	var scaleX(get, set):Float;

	function get_scaleX():Float
	{
		return this.scale?.x ?? 1;
	}

	function set_scaleX(n:Float):Float
	{
		this.scale.x = n;
		return this.scale.x;
	}

	var scaleY(get, set):Float;

	function get_scaleY():Float
	{
		return this.scale?.y ?? 1;
	}

	function set_scaleY(n:Float):Float
	{
		this.scale.y = n;
		return this.scale.y;
	}

	var skewY(get, set):Float;

	function get_skewY():Float
	{
		return this.skew?.y ?? 0;
	}

	function set_skewY(n:Float):Float
	{
		this.skew.y = n;
		return this.skew.y;
	}

	var skewX(get, set):Float;

	function get_skewX():Float
	{
		return this.skew?.x ?? 0;
	}

	function set_skewX(n:Float):Float
	{
		this.skew.x = n;
		return this.skew.x;
	}

	public var skewZ:Float = 0;

	// in %
	public var skewX_offset:Float = 0.5;
	public var skewY_offset:Float = 0.5;
	public var skewZ_offset:Float = 0.5;


	public var fovOffsetX:Float = 0;
	public var fovOffsetY:Float = 0;

	public var pivotOffsetX:Float = 0;
	public var pivotOffsetY:Float = 0;
	public var pivotOffsetZ:Float = 0;

	public var fov:Float = 90;

	// custom setter to prevent values below 0, cuz otherwise we'll devide by 0!
	public var subdivisions(default, set):Int = 2;

	function set_subdivisions(value:Int):Int
	{
		if (subdivisions == value) return subdivisions;

		if (value < 0) value = 0;
		subdivisions = value;
		setUp();
		return subdivisions;
	}

	/**
	 * A `Vector` of floats where each pair of numbers is treated as a coordinate location (an x, y pair).
	 */
	public var vertices:DrawData<Float> = new DrawData<Float>();

	/**
	 * A `Vector` of integers or indexes, where every three indexes define a triangle.
	 */
	public var indices:DrawData<Int> = new DrawData<Int>();

	/**
	 * A `Vector` of normalized coordinates used to apply texture mapping.
	 */
	public var uvtData:DrawData<Float> = new DrawData<Float>();

	public function new(?x:Float = 0, ?y:Float = 0, ?simpleGraphic:FlxGraphicAsset)
	{
		super(x, y, simpleGraphic);
		if (simpleGraphic != null) setUp();
		this.active = true;
	}

	public function setUp():Void
	{
		var nextRow:Int = (subdivisions + 1 + 1);
		updateColorTransform();
		var noteIndices:Array<Int> = [];
		for (x in 0...subdivisions + 1)
		{
			for (y in 0...subdivisions + 1)
			{
				// indices are created from top to bottom, going along the x axis each cycle.
				var funny:Int = y + (x * nextRow);
				noteIndices.push(0 + funny);
				noteIndices.push(nextRow + funny);
				noteIndices.push(1 + funny);

				noteIndices.push(nextRow + funny);
				noteIndices.push(nextRow + 1 + funny);
				noteIndices.push(1 + funny);
			}
		}
		indices = new DrawData<Int>(noteIndices.length, true, noteIndices);

		for (x in 0...subdivisions + 2) // x
		{
			for (y in 0...subdivisions + 2) // y
			{
				vertOffsetX.push(0);
				vertOffsetY.push(0);
				vertOffsetZ.push(0);
			}
		}
		updateTris();
	}

	public var uvScale:Vector2 = new Vector2(1.0, 1.0);
	public var uvScaleOffset:Vector2 = new Vector2(0.5, 0.5); // scale from center
	public var uvOffset:Vector2 = new Vector2(0.0, 0.0);

	var destroying:Bool = false;

	/**
   * The function which will update all the vertex and UV data.
   */
	public function updateTris():Void
	{
		if (destroying) return;
		
    	// TODO: Improve how this gets applied!
		var wasAlreadyFlipped_X:Bool = flipX;
		var wasAlreadyFlipped_Y:Bool = flipY;

		var needsFlipX:Bool = false;
		var needsFlipY:Bool = false;
		switch (cullMode)
		{
			case "always_positive" | "always_negative":
				needsFlipX = cullMode == "always_positive" ? true : false;
				needsFlipY = cullMode == "always_positive" ? true : false;

				var xFlipCheck_vertTopLeftX = vertices[0];
				var xFlipCheck_vertBottomRightX = vertices[vertices.length - 1 - 1];
				if (!wasAlreadyFlipped_X)
				{
					if (xFlipCheck_vertTopLeftX >= xFlipCheck_vertBottomRightX)
					{
						needsFlipX = !needsFlipX;
					}
				}
				else
				{
					if (xFlipCheck_vertTopLeftX < xFlipCheck_vertBottomRightX)
					{
						needsFlipX = !needsFlipX;
					}
				}
				// y check
				if (!wasAlreadyFlipped_Y)
				{
					xFlipCheck_vertTopLeftX = vertices[1];
					xFlipCheck_vertBottomRightX = vertices[vertices.length - 1];
					if (xFlipCheck_vertTopLeftX >= xFlipCheck_vertBottomRightX)
					{
						needsFlipY = !needsFlipY;
					}
				}
				else
				{
					xFlipCheck_vertTopLeftX = vertices[1];
					xFlipCheck_vertBottomRightX = vertices[vertices.length - 1];
					if (xFlipCheck_vertTopLeftX < xFlipCheck_vertBottomRightX)
					{
						needsFlipY = !needsFlipY;
					}
				}
		}

		var w:Float = this.frame.frame.width;
    	var h:Float = this.frame.frame.height;

		var offsetX:Float = this.frame.offset.x * scaleX;
		var offsetScaledX:Float = (frameWidth - w) * (scaleX - 1) / 2;

		var offsetY:Float = this.frame.offset.y * scaleY;
		var offsetScaledY:Float = (frameHeight - h) * (scaleY - 1) / 2;

		culled = false;

		var i:Int = 0;
		for (x in 0...subdivisions + 2) // x
		{
			for (y in 0...subdivisions + 2) // y
			{
				// Setup point
				var point3D:Vector3D = new Vector3D(0, 0, 0);
				point3D.x = (w / (subdivisions + 1)) * x;
				point3D.y = (h / (subdivisions + 1)) * y;

				// Animation frame offset stuff
				point3D.x += offsetX - offsetScaledX;
				point3D.y += offsetY - offsetScaledY;

				// skew funny
				var xPercent:Float = x / (subdivisions + 1);
				var yPercent:Float = y / (subdivisions + 1);

				var newWidth:Float = (scaleX - 1) * (xPercent - 0.5);
				var newHeight:Float = (scaleY - 1) * (yPercent - 0.5);

				// Apply vibrate effect
				if (vibrateEffect != 0)
				{
					point3D.x += FlxG.random.float(-1, 1) * vibrateEffect;
					point3D.y += FlxG.random.float(-1, 1) * vibrateEffect;
					point3D.z += FlxG.random.float(-1, 1) * vibrateEffect;
				}

				// Apply curVertOffsets
				var curVertOffsetX:Float = 0;
				var curVertOffsetY:Float = 0;
				var curVertOffsetZ:Float = 0;

				if (i < vertOffsetX.length)
				{
					curVertOffsetX = vertOffsetX[i];
				}
				if (i < vertOffsetY.length)
				{
					curVertOffsetY = vertOffsetY[i];
				}
				if (i < vertOffsetZ.length)
				{
					curVertOffsetZ = vertOffsetZ[i];
				}

				point3D.x += curVertOffsetX;
				point3D.y += curVertOffsetY;
				point3D.z += curVertOffsetZ;

				// scale
				point3D.x += (newWidth) * w;
				point3D.y += (newHeight) * h;

				point3D = applyFlip(point3D, xPercent, yPercent);
				point3D = applyRotation(point3D, xPercent, yPercent);

				point3D = applySkew(point3D, xPercent, yPercent, w, h);

				// Apply offset here before it gets affected by z projection!
				point3D.x -= offset.x;
				point3D.y -= offset.y;
				point3D = applyPerspective(point3D, xPercent, yPercent);

				vertices[i * 2] = point3D.x;
				vertices[i * 2 + 1] = point3D.y;

				if (needsFlipX)
				{
				xPercent = 1 - xPercent;
				}
				if (needsFlipY)
				{
				yPercent = 1 - yPercent;
				}

				/* Updating the UV mapping! */
				var uvX:Float = xPercent;
				var uvY:Float = yPercent;

				var curFrame = this.frame;
				uvX = FlxMath.remapToRange(xPercent, 0, 1, curFrame.uv.x, curFrame.uv.width);
				uvY = FlxMath.remapToRange(yPercent, 0, 1, curFrame.uv.y, curFrame.uv.height);

				// todo: add repeat texture to here instead so that we can use frameBorderCut to determine if we repeat the entire atlas, or just the current frame

				// uv scale
				uvX -= uvScaleOffset.x;
				uvY -= uvScaleOffset.y;

				uvX *= uvScale.x;
				uvY *= uvScale.y;

				uvX += uvScaleOffset.x;
				uvY += uvScaleOffset.y;

				// uv offset
				uvX += uvOffset.x;
				uvY += uvOffset.y;

				// map it
				uvtData[i * 3] = uvX; // u
				uvtData[i * 3 + 1] = uvY; // v
				uvtData[i * 3 + 2] = (doPerspectiveCorrection ? 1 / Math.max(0.0001, -point3D.z) : 1.0); // t

				i++;
			}
		}
	}

	override public function loadGraphic(graphic:FlxGraphicAsset, animated = false, frameWidth = 0, frameHeight = 0, unique = false, ?key:String):FlxSprite
	{
		super.loadGraphic(graphic, animated, frameWidth, frameHeight, unique, key);
		setUp();
		return this;
	}

	override function set_frames(Frames:FlxFramesCollection):FlxFramesCollection
	{
		super.set_frames(Frames);
		setUp();
		return Frames;
	}
	
	/**
	* A `Vector` representing each vertex colour. Doesn't do anything though but is needed to avoid a crash when changing colors
	*/
  	public var colors:DrawData<Int> = new DrawData<Int>();

	var culled:Bool = false;

	@:access(flixel.FlxCamera)
	override public function draw():Void
	{
		if (destroying) return;
		if (!projectionEnabled)
		{
			super.draw();
		}
		else
		{
			var culling = TriangleCulling.NONE;
			switch (cullMode)
			{
				case "positive" | "front":
					culling = TriangleCulling.POSITIVE;
				case "negative" | "back":
					culling = TriangleCulling.NEGATIVE;
				case "always":
					culled = true;
			}
	
      		if (dirty) this.updateTris();

			if (culled || alpha < 0 || vertices == null || indices == null || graphic == null || uvtData == null || _point == null || offset == null)
			{
				return;
			}
			var alphaMemory:Float = this.alpha;
			for (camera in cameras)
			{
				if (!camera.visible || !camera.exists) continue;
				// if (!isOnScreen(camera)) continue; // TODO: Update this code to make it work properly.
				alpha = alphaMemory * camera.alpha; // Fix for drawTriangles not fading with camera
				// getScreenPosition(_point, camera).subtractPoint(offset);
				getScreenPosition(_point, camera);
				camera.drawTriangles(graphic, vertices, indices, uvtData, colors, _point, blend, textureRepeat, antialiasing, colorTransform, shader, culling);
			}
			this.alpha = alphaMemory;

			#if FLX_DEBUG
			if (FlxG.debugger.drawDebug) drawDebug();
			#end
		}
	}

	override public function destroy():Void
	{
		destroying = true;
		vertices = null;
		indices = null;
		uvtData = null;
		super.destroy();
	}

	// Feed a noteData into this function to apply all of it's parameters to this sprite!
	// public function applyNoteData(data:NotePositionData, applyFake3D:Bool = false):Void
	// {
	// 	super.applyNoteData(data, applyFake3D);
	// 	this.skewZ = data.skewZ;
	// 	// this.skewX_playfield = data.skewX_playfield;
	// 	// this.skewY_playfield = data.skewY_playfield;
	// 	// this.skewZ_playfield = data.skewZ_playfield;

	// 	this.angleX = data.angleX;
	// 	this.angleY = data.angleY;

	// 	this.scaleZ = 1;
	// }

	public var offsetBeforeRotation:FlxPoint = new FlxPoint(0, 0);

	public var preRotationMoveX:Float = 0;
	public var preRotationMoveY:Float = 0;
	public var preRotationMoveZ:Float = 0;

	var skewOffsetFix:Float = 0.5;

	public function applySkew(pos:Vector3D, xPercent:Float, yPercent:Float, w:Float, h:Float):Vector3D
	{
		var point3D:Vector3D = new Vector3D(pos.x, pos.y, pos.z);

		var skewPosX:Float = this.x + this.x2 - offset.x;
		var skewPosY:Float = this.y + this.y2 - offset.y;

		skewPosX += (w) / 2;
		skewPosY += (h) / 2;

		var rotateModPivotPoint:Vector2 = new Vector2(0.5, 0.5); // to skew from center
		var thing:Vector2 = ModchartUtil.rotateAround(rotateModPivotPoint, new Vector2(xPercent, yPercent), angleZ); // to fix incorrect skew when rotated

		// For some reason, we need a 0.5 offset for this for it to be centered???????????????????
		var xPercent_SkewOffset:Float = thing.x - skewY_offset - skewOffsetFix;
		var yPercent_SkewOffset:Float = thing.y - skewX_offset - skewOffsetFix;
		// Keep math the same as skewedsprite for parity reasons.
		if (skewX != 0) // Small performance boost from this if check to avoid the tan math lol?
			point3D.x += yPercent_SkewOffset * Math.tan(skewX * FlxAngle.TO_RAD) * h * scaleY;
		if (skewY != 0) //
			point3D.y += xPercent_SkewOffset * Math.tan(skewY * FlxAngle.TO_RAD) * w * scaleX;

		// z SKEW //hazard did an oppsie (put skewX instead of skewZ)

		if (skewZ != 0) point3D.z += yPercent_SkewOffset * Math.tan(skewZ * FlxAngle.TO_RAD) * h * scaleY;

		return point3D;
	}

	function applyRotX(pos:Vector3D, xPercent, yPercent, w:Float, h:Float, degrees:Float):Vector3D
	{
		var rotateModPivotPoint:Vector2 = new Vector2(0, h / 2);
		rotateModPivotPoint.x += pivotOffsetZ;
		rotateModPivotPoint.y += pivotOffsetY;
		var thing:Vector2 = ModchartUtil.rotateAround(rotateModPivotPoint, new Vector2(pos.z, pos.y), degrees);
		pos.z = thing.x;
		pos.y = thing.y;
		return pos;
	}

	function applyRotY(pos:Vector3D, xPercent, yPercent, w:Float, h:Float, degrees:Float):Vector3D
	{
		var rotateModPivotPoint:Vector2 = new Vector2(w / 2, 0);
		rotateModPivotPoint.x += pivotOffsetX;
		rotateModPivotPoint.y += pivotOffsetZ;
		var thing:Vector2 = ModchartUtil.rotateAround(rotateModPivotPoint, new Vector2(pos.x, pos.z), degrees);
		pos.x = thing.x;
		pos.z = thing.y;
		return pos;
	}

	function applyRotZ(pos:Vector3D, xPercent, yPercent, w:Float, h:Float, degrees:Float):Vector3D
	{
		var rotateModPivotPoint:Vector2 = new Vector2(w / 2, h / 2);
		rotateModPivotPoint.x += pivotOffsetX;
		rotateModPivotPoint.y += pivotOffsetY;
		var thing:Vector2 = ModchartUtil.rotateAround(rotateModPivotPoint, new Vector2(pos.x, pos.y), degrees);
		pos.x = thing.x;
		pos.y = thing.y;
		return pos;
	}

	public function applyFlip(pos:Vector3D, xPercent:Float = 0, yPercent:Float = 0):Vector3D
	{
		var w:Float = frameWidth;
		var h:Float = frameHeight;

		if (flipX)
		{
			pos = applyRotY(pos, xPercent, yPercent, w, h, 180);
		}
		if (flipY)
		{
			pos = applyRotX(pos, xPercent, yPercent, w, h, 180);
		}

		return pos;
	}

	// EDIT THIS ARRAY TO CHANGE HOW ROTATION IS APPLIED!
	public var rotationOrder:Array<String> = ["z", "y", "x"];

	//var whatWasTheZBefore:Float = 0;

	public function applyRotation(pos:Vector3D, xPercent:Float = 0, yPercent:Float = 0):Vector3D
	{
		var w:Float = frameWidth;
		var h:Float = frameHeight;

		var pos_modified:Vector3D = new Vector3D(pos.x, pos.y, pos.z);

		pos_modified.x -= offsetBeforeRotation.x;
		pos_modified.y -= offsetBeforeRotation.y;
		pos_modified.x += preRotationMoveX;
		pos_modified.y += preRotationMoveY;
		pos_modified.z += preRotationMoveZ;

		//whatWasTheZBefore = pos_modified.z;

		for (i in 0...rotationOrder.length)
		{
			switch (rotationOrder[i])
			{
				case "x":
					pos_modified = applyRotX(pos_modified, xPercent, yPercent, w, h, angleX);
				case "y":
					pos_modified = applyRotY(pos_modified, xPercent, yPercent, w, h, angleY);
				case "z":
					pos_modified = applyRotZ(pos_modified, xPercent, yPercent, w, h, angleZ);

				case "x2":
					pos_modified = applyRotX(pos_modified, xPercent, yPercent, w, h, angleX2);
				case "y2":
					pos_modified = applyRotY(pos_modified, xPercent, yPercent, w, h, angleY2);
				case "z2":
					pos_modified = applyRotZ(pos_modified, xPercent, yPercent, w, h, angleZ2);
			}
		}

		return pos_modified;
	}

	public function applyPerspective(pos:Vector3D, xPercent:Float = 0, yPercent:Float = 0):Vector3D
	{
		var pos_modified:Vector3D = new Vector3D(pos.x, pos.y, pos.z);

		//var zDifference:Float = pos_modified.z - whatWasTheZBefore;

		if (projectionEnabled)
		{
			pos_modified.x += this.x + this.x2;
			pos_modified.y += this.y + this.y2;
			pos_modified.z += this.z + this.z2;
			pos_modified.x += fovOffsetX;
			pos_modified.y += fovOffsetY;
			pos_modified.z *= 0.001;

			//pos_modified.z = zDifference * 0.001;
			pos_modified = perspectiveMath(pos_modified, 0, 0, perspectiveCenterOffset);

			pos_modified.x -= this.x + this.x2;
			pos_modified.y -= this.y + this.y2;
			pos_modified.z -= (this.z + this.z2) * 0.001;

			pos_modified.x -= fovOffsetX;
			pos_modified.y -= fovOffsetY;
		}
		return pos_modified;
	}

	public var zNear:Float = 0.0;
	public var zFar:Float = 100.0;

	// https://github.com/TheZoroForce240/FNF-Modcharting-Tools/blob/main/source/modcharting/ModchartUtil.hx
	public function perspectiveMath(pos:Vector3D, offsetX:Float = 0, offsetY:Float = 0, ?perspectiveOffset:Vector2):Vector3D
	{
		// Math isn't perfect (mainly with lack of FOV support), but it's good enough. -Haz
		try
		{
			var _FOV = Math.PI / 2;

			/*
				math from opengl lol
				found from this website https://ogldev.org/www/tutorial12/tutorial12.html
			*/

			var newz:Float = pos.z;
			newz *= FlxMath.lerp(0, 1, _FOV / 90); // very very fucking stupid work-around for no proper FOV support  -Haz
			// Too close to camera!
			if (newz > zNear + 0.975)
			{
				newz = zNear + 0.975;
			}
			// else if (newz < (zFar * -1)) // Too far from camera!
			// {
			// culled = true;
			// }

			newz = newz - 1;

			var zRange:Float = zNear - zFar;
			var tanHalfFOV:Float = Math.tan(_FOV * 0.5);

			var screenCenterX:Float = (FlxG.width * 0.5) + (perspectiveOffset?.x ?? 0.0);
			var screenCenterY:Float = (FlxG.height * 0.5) + (perspectiveOffset?.y ?? 0.0);

			var xOffsetToCenter:Float = pos.x - screenCenterX; // so the perspective focuses on the center of the screen
			var yOffsetToCenter:Float = pos.y - screenCenterY;

			var zPerspectiveOffset:Float = (newz + (2 * zFar * zNear / zRange));

			if (zPerspectiveOffset == 0) zPerspectiveOffset = 0.001; // divide by zero check  -Haz

			xOffsetToCenter += (offsetX * -zPerspectiveOffset);
			yOffsetToCenter += (offsetY * -zPerspectiveOffset);

			var xPerspective:Float = xOffsetToCenter * (1 / tanHalfFOV);
			var yPerspective:Float = yOffsetToCenter * tanHalfFOV;
			xPerspective /= -zPerspectiveOffset;
			yPerspective /= -zPerspectiveOffset;

			pos.x = xPerspective + screenCenterX; // offset it back to normal
			pos.y = yPerspective + screenCenterY;
			pos.z = zPerspectiveOffset;

			return pos;
		}
		catch (e)
		{
			trace("FUCK. NEARLY DIED CUZ OF: \n" + e.toString());
			return pos;
		}
	}
}
