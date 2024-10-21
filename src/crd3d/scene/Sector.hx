package crd3d.scene;

import crd3d.geom.V3d;

/**
 * Scene sector
 * 3D Box
 */
class Sector
{

	// Sector borders
	public var x1:Float;
	public var x2:Float;
	public var y1:Float;
	public var y2:Float;
	public var z1:Float;
	public var z2:Float;

	public var visibleSectors:Array<Int>; // Indices of sectors visible from this sector

	public function new(sx1:Int = -1000, sx2:Int = 1000, sy1:Int = -1000, sy2:Int = 1000, sz1:Int = -1000, sz2:Int = 1000)
	{
		x1 = sx1; x2 = sx2;
		y1 = sy1; y2 = sy2;
		z1 = sz1; z2 = sz2;
		visibleSectors = new Array();
	}

	/**
	 * Checks if 3D point is inside sector
	 */
	public inline function isPointInSector(p:V3d):Bool
	{
		return (p.x > x1) && (p.x < x2) && (p.y > y1) && (p.y < y2) && (p.z > z1) && (p.z < z2);
	}

}