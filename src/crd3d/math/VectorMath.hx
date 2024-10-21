package crd3d.math;
import crd3d.geom.V3d;

class VectorMath 
{
	
	/**
	 * V3d Dot product
	 */
	public static inline function dotProductV3(v0:V3d, v1:V3d):Float
	{
		return v0.x * v1.x + v0.y * v1.y + v0.z * v1.z;
	}
	
	/**
	 * V3d Cross product
	 */
	public static inline function crossProductV3(v0:V3d, v1:V3d, res:V3d):Void
	{
		res.x = v0.y * v1.z - v0.z * v1.y;
		res.y = v0.z * v1.x - v0.x * v1.z;
		res.z = v0.x * v1.y - v0.y * v1.x;
	}
	
	/**
	 * Vertex-matrix mul for X rotation
	 */
	public static inline function vertexRotationX(cx:Float, cy:Float, cz:Float, vx:Float, vy:Float, vz:Float,
	sinx:Float, siny:Float, sinz:Float, cosx:Float, cosy:Float, cosz:Float):Float
	{
		return cx + ((cosz * cosy) * (vx - cx)) + ((( -sinz * cosx) + (cosz * -siny * -sinx)) * (vy - cy)) + ((( -sinz * sinx) + (cosz * -siny * cosx)) * (vz - cz));
	}
	
	/**
	 * Vertex-matrix mul for Y rotation
	 */
	public static inline function vertexRotationY(cx:Float, cy:Float, cz:Float, vx:Float, vy:Float, vz:Float,
	sinx:Float, siny:Float, sinz:Float, cosx:Float, cosy:Float, cosz:Float):Float
	{
		return cy + ((sinz * cosy) * (vx - cx)) + (((cosz * cosx) + (sinz * -siny * -sinx)) * (vy - cy)) + (((cosz * sinx) + (sinz * -siny * cosx)) * (vz - cz));
	}
	
	/**
	 * Vertex-matrix mul for Z rotation
	 */
	public static inline function vertexRotationZ(cx:Float, cy:Float, cz:Float, vx:Float, vy:Float, vz:Float,
	sinx:Float, siny:Float, sinz:Float, cosx:Float, cosy:Float, cosz:Float):Float
	{
		return cz + (siny * (vx - cx)) + ((cosy * -sinx) * (vy - cy)) + ((cosy * cosx) * (vz - cz));
	}
	
}