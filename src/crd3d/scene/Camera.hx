package crd3d.scene;

import crd3d.geom.V3d;
import Std;

class Camera
{

	public var position:V3d = new V3d(0, 0, 0);			// Camera position
	public var rotation:V3d = new V3d(0, 0, 0);			// Camera rotation
	public var fov:Int = 90;							// Field of view
	public var focusLen:Float = 100;					// Focal length

	// Rotation
	public static inline var PI:Float = 3.14159265359;  // PI
	public var radians:V3d = new V3d(0, 0, 0);			// Rotation (radians)
	public var s:V3d; // Sin
	public var c:V3d; // Cos

	private var cox:Float = 0;
	private var coy:Float = 0;
	private var coz:Float = 0;

	public var nearPlane:Float = 10;					// Near plane
	public var farPlane:Float = 10000;					// Far plane

	public function new(nx:Float = 0, ny:Float = 0, nz:Float = 0):Void
	{
		position.x = nx;
		position.y = ny;
		position.z = nz;

		s = new V3d(Math.sin(radians.x), Math.sin(radians.y), Math.sin(radians.z));
		c = new V3d(Math.cos(radians.x), Math.cos(radians.y), Math.cos(radians.z));
	}

	/**
	 * Sets camera position
	 */
	public function setPosition(px:Float = 0, py:Float = 0, pz:Float = 0):Void
	{
		position.x = px;
		position.y = py;
		position.z = pz;
	}

	/**
	 * Sets camera rotation
	 */
	public function setRotation(rx:Float = 0, ry:Float = 0, rz:Float = 0):Void
	{
		rotation.x = rx;
		rotation.y = ry;
		rotation.z = rz;
		calcMath();
	}

	/**
	 * Sets FOV
	 */
	public function setFov(fv:Float = 90):Void
	{
		fov = Std.int(fv);
	}

	/**
	 * Recalculates sin, cos for rotation
	 */
	private function calcMath():Void
	{
		radians.x = rotation.x * (PI / 180);
		radians.y = rotation.y * (PI / 180);
		radians.z = rotation.z * (PI / 180);
		s.x = Math.sin(radians.x);
		s.y = Math.sin(radians.y);
		s.z = Math.sin(radians.z);
		c.x = Math.cos(radians.x);
		c.y = Math.cos(radians.y);
		c.z = Math.cos(radians.z);
	}

	/**
	 * Performs view transform for a single vertex
	 */
	public inline function viewTransform(nv:V3d):Void
	{
		cox = nv.x - position.x;
		coy = nv.y - position.y;
		coz = nv.z - position.z;

		nv.x = (position.x + ((c.z * c.y) * (cox)) + (((-s.z * c.x) + (c.z * -s.y * -s.x)) * (coy)) + (((-s.z * s.x) + (c.z * -s.y * c.x)) * (coz))) - position.x;
		nv.y = (position.y + ((s.z * c.y) * (cox)) + (((c.z * c.x) + (s.z * -s.y * -s.x)) * (coy)) + (((c.z * s.x) + (s.z * -s.y * c.x)) * (coz))) - position.y;
		nv.z = (position.z + (s.y * (cox)) + ((c.y * -s.x) * (coy)) + ((c.y * c.x) * (coz))) - position.z;
	}

	/**
	 * Performs view transform for 3 vertices
	 */
	public inline function viewTransform3v(nv0:V3d, nv1:V3d, nv2:V3d):Void
	{
		cox = nv0.x - position.x;
		coy = nv0.y - position.y;
		coz = nv0.z - position.z;
		nv0.x = (position.x + ((c.z * c.y) * (cox)) + (((-s.z * c.x) + (c.z * -s.y * -s.x)) * (coy)) + (((-s.z * s.x) + (c.z * -s.y * c.x)) * (coz))) - position.x;
		nv0.y = (position.y + ((s.z * c.y) * (cox)) + (((c.z * c.x) + (s.z * -s.y * -s.x)) * (coy)) + (((c.z * s.x) + (s.z * -s.y * c.x)) * (coz))) - position.y;
		nv0.z = (position.z + (s.y * (cox)) + ((c.y * -s.x) * (coy)) + ((c.y * c.x) * (coz))) - position.z;

		cox = nv1.x - position.x;
		coy = nv1.y - position.y;
		coz = nv1.z - position.z;
		nv1.x = (position.x + ((c.z * c.y) * (cox)) + (((-s.z * c.x) + (c.z * -s.y * -s.x)) * (coy)) + (((-s.z * s.x) + (c.z * -s.y * c.x)) * (coz))) - position.x;
		nv1.y = (position.y + ((s.z * c.y) * (cox)) + (((c.z * c.x) + (s.z * -s.y * -s.x)) * (coy)) + (((c.z * s.x) + (s.z * -s.y * c.x)) * (coz))) - position.y;
		nv1.z = (position.z + (s.y * (cox)) + ((c.y * -s.x) * (coy)) + ((c.y * c.x) * (coz))) - position.z;

		cox = nv2.x - position.x;
		coy = nv2.y - position.y;
		coz = nv2.z - position.z;
		nv2.x = (position.x + ((c.z * c.y) * (cox)) + (((-s.z * c.x) + (c.z * -s.y * -s.x)) * (coy)) + (((-s.z * s.x) + (c.z * -s.y * c.x)) * (coz))) - position.x;
		nv2.y = (position.y + ((s.z * c.y) * (cox)) + (((c.z * c.x) + (s.z * -s.y * -s.x)) * (coy)) + (((c.z * s.x) + (s.z * -s.y * c.x)) * (coz))) - position.y;
		nv2.z = (position.z + (s.y * (cox)) + ((c.y * -s.x) * (coy)) + ((c.y * c.x) * (coz))) - position.z;
	}

}