package crd3d.math;

import crd3d.geom.V3d;
import flash.Vector;

class MinMax
{

	public static function minX_VectorV3d(vct:Vector<V3d>):Float
	{
		var min:Float = vct[0].x;
		for (i in 0...vct.length)
		{
			if (vct[i].x < min) min = vct[i].x;
		}
		return min;
	}

	public static function minY_VectorV3d(vct:Vector<V3d>):Float
	{
		var min:Float = vct[0].y;
		for (i in 0...vct.length)
		{
			if (vct[i].y < min) min = vct[i].y;
		}
		return min;
	}

	public static function minZ_VectorV3d(vct:Vector<V3d>):Float
	{
		var min:Float = vct[0].z;
		for (i in 0...vct.length)
		{
			if (vct[i].z < min) min = vct[i].z;
		}
		return min;
	}

	public static function maxX_VectorV3d(vct:Vector<V3d>):Float
	{
		var max:Float = vct[0].x;
		for (i in 0...vct.length)
		{
			if (vct[i].x > max) max = vct[i].x;
		}
		return max;
	}

	public static function maxY_VectorV3d(vct:Vector<V3d>):Float
	{
		var max:Float = vct[0].y;
		for (i in 0...vct.length)
		{
			if (vct[i].y > max) max = vct[i].y;
		}
		return max;
	}

	public static function maxZ_VectorV3d(vct:Vector<V3d>):Float
	{
		var max:Float = vct[0].z;
		for (i in 0...vct.length)
		{
			if (vct[i].z > max) max = vct[i].z;
		}
		return max;
	}

}