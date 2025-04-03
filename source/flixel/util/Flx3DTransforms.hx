package flixel.util;

import flixel.math.FlxPoint;
import openfl.geom.Matrix3D;
import openfl.geom.Vector3D;

/**
 * Flx3DTransforms provides utility functions for working with 3D transformations, including rotation
 * and projection operations for 3D vectors. The primary focus of this class is to apply 3D rotations 
 * around the X, Y, and Z axes and to project 3D coordinates into 2D space, simulating perspective.
 * 
 * It includes the following functionalities:
 * - Applying 3D rotation to vectors using angle data for each axis.
 * - Performing 2D rotation of points.
 * - Projecting 3D points into 2D space based on perspective projection.
 * 
 * This class operates using mathematical concepts such as radians, trigonometry, and the tangent function
 * to simulate depth and perspective in 3D space.
 */
class Flx3DTransforms {
    static var RADEANS:Float = Math.PI / 180;
	static var FOV:Float = Math.PI / 2;
    static var near:Int = 0;
	static var far:Int = 1;
	static var range:Int = -1;

	/**
	 * We will no longer use the Euler angles rotation,
	 * butrotation matrix !! (NO MORE GIMBAL LOCK !!)
	 */
	@:noCompletion static final __rotationMatrix:Matrix3D = new Matrix3D();
    
    /**
     * Applies a 3D rotation to a vector using rotations around the X, Y, and Z axes.
     * 
     * @param input  The input vector (`Vector3D`) that will be rotated.
     * @param angle  A vector (`Vector3D`) representing the rotation angles in degrees for each axis (X, Y, Z).
     * @return       The same `input` vector, modified with the applied rotation.
     */
    inline static public function rotation3D(input:Vector3D, angle:Vector3D)
    {
		if (angle.x == 0 || angle.y == 0 || angle.z == 0)
			return input;

		__rotationMatrix.identity();
		// this should be fine
		__rotationMatrix.appendRotation(angle.z, Vector3D.Z_AXIS);
		__rotationMatrix.appendRotation(angle.y, Vector3D.Y_AXIS);
		__rotationMatrix.appendRotation(angle.x, Vector3D.X_AXIS);

		return __rotationMatrix.transformVector(input);
    }
    
    /**
     * Rotates a 2D point by a given angle.
     * 
     * @param x      The X coordinate of the point to rotate.
     * @param y      The Y coordinate of the point to rotate.
     * @param angle  The rotation angle in radians.
     * @param point  (Optional) A `FlxPoint` to store the result. If null, a weak `FlxPoint` is used.
     * @return       A `FlxPoint` representing the rotated coordinates.
     */
    inline static function rotate2D(x:Float, y:Float, angle:Float, ?point:FlxPoint):FlxPoint {
        if (point == null)
            point = FlxPoint.weak();

		if ((angle % 360) == 0)
			return point.set(x, y);

        // in this case, sin doesnt need to be negated
		final sin = Math.sin(angle);
		final cos = Math.cos(angle);

		return point.set(x * cos - y * sin, x * sin + y * cos);
	};

    /**
     * Projects a 3D point into 2D space based on a perspective projection, and updates the given origin point.
     * 
     * @param pos     The 3D position (`Vector3D`) to project.
     * @param origin  (Optional) A `Vector3D` representing the origin point for the projection. If null, it defaults to the center of the screen.
     * @return        The `origin` vector updated with the 2D projection coordinates and depth value. (Reusing `origin` for memory saving)
     */
    inline static public function project3D(pos:Vector3D, ?origin:Vector3D) {
		if (origin == null)
			origin = new Vector3D(FlxG.width * .5, FlxG.height * .5);

		pos.decrementBy(origin);

        // Bound Z to 1000
		final worldZ = Math.min(pos.z - 1, 0);

		final halfFovTan = 1 / Math.tan(FOV * .5);
		final rangeDivision = 1 / range;

        // Compute the projection
		final projectionScale = (near + far) * rangeDivision;
		final projectionOffset = 2 * near * (far * rangeDivision);
		final projectionZ = projectionScale * worldZ + projectionOffset;

        final projectedX = pos.x * halfFovTan;
        final projectedY = pos.y * halfFovTan;
        final depthFactor = 1 / projectionZ;

        // Update the origin vector with the 2D projected position, adjusting for depth.
        // This avoids creating new objects by reusing the origin vector.
        origin.setTo(
            origin.x + (projectedX * depthFactor),
            origin.y + (projectedY * depthFactor),
            projectionZ
        );
		return origin;
	}
}