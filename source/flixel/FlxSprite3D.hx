package flixel;

import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame.FlxFrameType;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.util.Flx3DTransforms;
import haxe.ds.Vector as HaxeVector;
import openfl.geom.Vector3D;

/**
 * `FlxSprite3D` extends `FlxSprite` to simulate 3D transformations
 * using perspective projection and rotation. This class allows
 * sprites to have depth (`z` axis), rotation in 3D space, and 
 * movement with acceleration, velocity, and drag in all three axes.
 * This also works as a normal FlxSprite, you can add offsets,
 * modify the origin, scale, velocity, or whatever and it wont break
 * or look different to a normal sprite.
 * Note: `graphic` doesnt represent the rotated graphic so functions
 * like `FlxCollision.pixelPerfectCheck` won't work when using depth.
 * 
 * Features:
 * - 3D position (`x`, `y`, `z`) with velocity and acceleration.
 * - 3D rotation (`angle3D`) with angular velocity and drag.
 * - Perspective projection to simulate depth.
 * - Integration with `FlxCamera.drawTriangles()` for rendering.
 *
 * `WARNING`: Sprites should be sorted by `z` for correct depth view.
 */
@:access(flixel.FlxCamera)
class FlxSprite3D extends FlxSprite
{
	static var DEPTH_SCALE:Float = 0.001;
	/**
	 * Represents the depth (Z-axis position) of the sprite in 3D space.
	 * 
	 * This value determines how far the sprite is positioned along the Z-axis,
	 * affecting perspective calculations.
	 */
	public var z(default, set):Float;

	/**
	 * The basic speed of this object (in pixels per second) in the z axis.
 	 */
	public var velocityZ:Float = 0;

	/**
	 * How fast the speed of this object is changing (in pixels per second) in the z axis.
	 * Useful for smooth movement and gravity.
	 */
	public var accelerationZ:Float = 0;

	/**
	 * This isn't drag exactly, more like deceleration that is only applied
	 * when `accelerationZ` is not affecting the sprite.
	 */
	public var dragZ:Float = 0;

	/**
	 * If you are using `accelerationZ`, you can use `maxVelocityZ` with it
	 * to cap the speed automatically (very useful!).
	 */
	public var maxVelocityZ:Float = 0;
	
	/**
	 * Represents the 3D rotation angles of the sprite.
	 * This vector holds the rotation values along the X, Y, and Z axes,
	 * which are used to transform the sprite in 3D space.
	 * 
	 * - X: Rotation around the horizontal axis (tilt up/down).
	 * - Y: Rotation around the vertical axis (turn left/right).
	 * - Z: Rotation around the depth axis (roll clockwise/counterclockwise).
	 * 
	 * The values in this vector directly affect the sprite's orientation
	 * when applying transformations in `__drawSprite3D`.
	 */
	public var angle3D(default, null):Vector3D = new Vector3D();

	/**
	 * This represents the angular velocity in 3D space,
	 * defining the rotation speed around the X, Y, and Z axes (degrees per second).
	 */
	public var angularVelocity3D:Vector3D = new Vector3D();

	/**
	 * Controls the rate of change of angular velocity (angular acceleration)
	 * in 3D space, affecting rotation speed along the X, Y, and Z axes.
	 */
	public var angularAcceleration3D:Vector3D = new Vector3D();

	/**
	 * Acts like drag but for rotation, slowing down the angular velocity
	 * over time in 3D space.
	 */
	public var angularDrag3D:Vector3D = new Vector3D();

	/**
	 * Limits the maximum angular velocity for smooth rotation control
	 * along each axis in 3D space.
	 */
	public var maxAngular3D:Vector3D = new Vector3D(10000, 10000, 10000);

	@:noCompletion private var depthFactor:Float = 1;

	@:noCompletion private var __position3D:Vector3D = new Vector3D();
	@:noCompletion private var __angle3D:Vector3D = new Vector3D();

	override function draw()
	{
		checkEmptyFrame();

		if (alpha == 0 || _frame.type == FlxFrameType.EMPTY)
			return;

		if (dirty) // rarely
			calcFrame(useFramePixels);

		if (colorTransform == null)
			updateColorTransform();
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
				continue;

			__drawSprite3D(camera);
		}
	}
	override function updateMotion(elapsed:Float):Void
	{
		// updates 2D motion
		super.updateMotion(elapsed);

		// Updates 3d angle motion
		var velocityDelta3D = new Vector3D(
			0.5 * (FlxVelocity.computeVelocity(angularVelocity3D.x, angularAcceleration3D.x, angularDrag3D.x, maxAngular3D.x, elapsed) - angularVelocity3D.x),
			0.5 * (FlxVelocity.computeVelocity(angularVelocity3D.y, angularAcceleration3D.y, angularDrag3D.y, maxAngular3D.y, elapsed) - angularVelocity3D.y),
			0.5 * (FlxVelocity.computeVelocity(angularVelocity3D.z, angularAcceleration3D.z, angularDrag3D.z, maxAngular3D.z, elapsed) - angularVelocity3D.z)
		);
		
		angularVelocity3D.x += velocityDelta3D.x;
		angularVelocity3D.y += velocityDelta3D.y;
		angularVelocity3D.z += velocityDelta3D.z;
		
		angle3D.x += angularVelocity3D.x * elapsed;
		angle3D.y += angularVelocity3D.y * elapsed;
		angle3D.z += angularVelocity3D.z * elapsed;
		
		angularVelocity3D.x += velocityDelta3D.x;
		angularVelocity3D.y += velocityDelta3D.y;
		angularVelocity3D.z += velocityDelta3D.z;

		// Updates depth motion
		var velocityDelta = 0.5 * (FlxVelocity.computeVelocity(velocityZ, accelerationZ, dragZ, maxVelocityZ, elapsed) - velocityZ);
		velocityZ += velocityDelta;
		var delta = velocityZ * elapsed;
		velocityZ += velocityDelta;
		z += delta;
	}

	inline function set_z(value:Float):Float
	{
		return z = Math.max(value, -1000);
	}

	/**
	 * Generates the vertex positions for a rectangular plane, 
	 * taking into account `flipX` and `flipY` transformations.
	 * 
	 * The function returns the four corner points of a 2D plane 
	 * centered at (0,0), where `planeWidth` and `planeHeight` define 
	 * its dimensions. If `flipX` or `flipY` are enabled, the 
	 * corresponding axis values are inverted.
	 * 
	 * @param planeWidth The half-width of the plane.
	 * @param planeHeight The half-height of the plane.
	 * @return An array of Float values representing the vertex positions.
	 */
	private function getGraphicVertices(planeWidth:Float, planeHeight:Float)
	{
		var x1 = flipX ? planeWidth : -planeWidth;
		var x2 = flipX ? -planeWidth : planeWidth;
		var y1 = flipY ? planeHeight : -planeHeight;
		var y2 = flipY ? -planeHeight : planeHeight;

		return [
			// top left
			x1,
			y1,
			// top right
			x2,
			y1,
			// bottom left
			x1,
			y2,
			// bottom right
			x2,
			y2
		];
	}

	/**
	 * Renders a 3D-like sprite using triangles (using `FlxCamera.drawTriangles()`). 
	 * This function applies perspective projection and rotation transformations 
	 * to a flat sprite to simulate depth, keeping all the sprite's and cameras's
	 * transformations.
	 * @param camera The `FlxCamera` instance used to render the sprite.
	 */
	private function __drawSprite3D(camera:FlxCamera):Void
	{
		final projectionDepth = z;
		final depth = 1 + (projectionDepth * 0.001);

		var depthScale = 1 / depth;
		var planeWidth = frame.frame.width * scale.x * .5;
		var planeHeight = frame.frame.height * scale.y * .5;

		// plane vertices
		var planeVertices = getGraphicVertices(planeWidth, planeHeight);

		var view3D:Bool = camera is FlxCamera3D;
		var viewCamera:Null<FlxCamera3D> = view3D ? cast camera : null;

		var projectionZ:HaxeVector<Float> = new HaxeVector(Math.ceil(planeVertices.length / 2));

		var vertPointer:Int = 0;
		do
		{
			__position3D.setTo(planeVertices[vertPointer], planeVertices[vertPointer + 1], 0);
			__angle3D.setTo(angle3D.x, angle3D.y, angle + angle3D.z);

			final relativeOffset = FlxPoint.get(offset.x - (frameWidth - width) * 0.5, offset.y - (frameHeight - height) * 0.5);

			// The result of the vert rotation
			var rotation = Flx3DTransforms.rotation3D(__position3D, __angle3D);

			getScreenPosition(_point, camera).subtract(x, y).subtract(-relativeOffset.x, -relativeOffset.y);

			rotation.x -= _point.x;
			rotation.y -= _point.y;

			var graphicPos = new Vector3D(x + planeWidth, y + planeHeight);
			var absVector = rotation.add(graphicPos);

			if (view3D)
			{
				absVector.z += projectionDepth;
				absVector = viewCamera.applyViewTo(absVector);
				absVector.z -= 1;
				absVector.z *= 0.001;
			}

			// The result of the perspective projection of rotation
			final projection = Flx3DTransforms.project3D(absVector);
			__position3D.copyFrom(projection);

			planeVertices[vertPointer] = projection.x;
			planeVertices[vertPointer + 1] = projection.y;

			// Stores depth from this vert to use it for perspective correction on uv's
			projectionZ[Math.floor(vertPointer / 2)] = Math.max(0.0001, projection.z);

			relativeOffset.put();

			vertPointer += 2;
		}
		while (vertPointer < planeVertices.length);

		// this is confusing af
		var vertices = new DrawData<Float>(12, true, [
			// triangle 1
			planeVertices[0], planeVertices[1], // top left
			planeVertices[2], planeVertices[3], // top right
			planeVertices[6], planeVertices[7], // bottom left
			// triangle 2
			planeVertices[0], planeVertices[1], // top right
			planeVertices[4], planeVertices[5], // top left
			planeVertices[6], planeVertices[7] // bottom right
		]);
		final uvRectangle = this.frame.uv;
		var uvData = new DrawData<Float>(18, true, [
			// uv for triangle 1
			uvRectangle.x,      uvRectangle.y,      1 / projectionZ[0], // top left
			uvRectangle.width,  uvRectangle.y,      1 / projectionZ[1], // top right
			uvRectangle.width,  uvRectangle.height, 1 / projectionZ[3], // bottom left
			// uv for triangle 2
			uvRectangle.x,      uvRectangle.y,      1 / projectionZ[0], // top right
			uvRectangle.x,      uvRectangle.height, 1 / projectionZ[2], // top left
			uvRectangle.width,  uvRectangle.height, 1 / projectionZ[3]  // bottom right
		]);


		camera.drawTriangles(
			graphic, vertices,
			new DrawData<Int>(vertices.length, true, [for (i in 0...vertices.length) i]),
			uvData, new DrawData<Int>(),
			camera._point, blend, false,
			antialiasing, colorTransform, shader
		);
	}
}