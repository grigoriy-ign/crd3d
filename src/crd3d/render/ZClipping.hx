package crd3d.render;

import crd3d.geom.*;

class ZClipping
{

	/**
	 * Recalculates line for z clipping
	 */
	private static inline function recalculateVertexLine(zv0:V3d, zv1:V3d, dvNearPlane:Float, ext0:V3d, ext1:V3d):Void
	{
		var tprm:Float = 0;

		// 1-0
		tprm = Math.abs((zv0.z - dvNearPlane) / (zv1.z - zv0.z));
		ext0.x = zv0.x + (zv1.x - zv0.x) * tprm;
		ext0.y = zv0.y + (zv1.y - zv0.y) * tprm;

		ext0.z = ext1.z = dvNearPlane;

		// Set result
		zv0.x = zv0.x; zv0.y = zv0.y; zv0.z = zv0.z;
		zv1.x = ext0.x; zv1.y = ext0.y; zv1.z = ext0.z;
	}

	/**
	 * Recalculates triangle for z clipping
	 */
	private static inline function recalculateVertex(zv0:V3d, zv1:V3d, zv2:V3d, ext0:V3d, ext1:V3d, dvNearPlane:Float, calcUv:Bool, uvz0:V2d, uvz1:V2d, uvz2:V2d):Void
	{
		var tprm:Float = 0;

		// UV data calc
		if (calcUv)
		{
			uvz1.x = uvz0.x + (uvz1.x - uvz0.x) * (dvNearPlane - zv0.z) / (zv1.z - zv0.z);
			uvz1.y = uvz0.y + (uvz1.y - uvz0.y) * (dvNearPlane - zv0.z) / (zv1.z - zv0.z);
			uvz2.x = uvz0.x + (uvz2.x - uvz0.x) * (dvNearPlane - zv0.z) / (zv2.z - zv0.z);
			uvz2.y = uvz0.y + (uvz2.y - uvz0.y) * (dvNearPlane - zv0.z) / (zv2.z - zv0.z);
		}

		// 1-0
		tprm = Math.abs((zv0.z - dvNearPlane) / (zv1.z - zv0.z));
		ext0.x = zv0.x + (zv1.x - zv0.x) * tprm;
		ext0.y = zv0.y + (zv1.y - zv0.y) * tprm;

		// 2-0
		tprm = Math.abs((zv0.z - dvNearPlane) / (zv2.z - zv0.z));
		ext1.x = zv0.x + (zv2.x - zv0.x) * tprm;
		ext1.y = zv0.y + (zv2.y - zv0.y) * tprm;
		//
		ext0.z = ext1.z = dvNearPlane;

		// Set result
		zv0.x = zv0.x; zv0.y = zv0.y; zv0.z = zv0.z;
		zv1.x = ext0.x; zv1.y = ext0.y; zv1.z = ext0.z;
		zv2.x = ext1.x; zv2.y = ext1.y; zv2.z = ext1.z;
	}

	/**
	 * Recalculates two triangles for z clipping
	 */
	private static inline function recalculateVertex_TwoFaces(zv0:V3d, zv1:V3d, zv2:V3d, szv0:V3d, szv1:V3d, szv2:V3d, variant:Int, uvz0:V2d, uvz1:V2d, uvz2:V2d, uvz0ext:V2d, uvz1ext:V2d, uvz2ext:V2d, calcUv:Bool = false, dvNearPlane:Float, ext0:V3d, ext1:V3d):Void
	{
		var tprm:Float = 0;

		var origUV:V2d = new V2d();
		var origUVadd:V2d = new V2d();

		if (calcUv)
		{
			origUV.x = uvz1.x;
			origUV.y = uvz1.y;

			// 2 nd triangle
			if (variant != 1)
			{
				origUVadd.x = uvz0.x;
				origUVadd.y = uvz0.y;
				uvz0ext.x = uvz0.x;
				uvz0ext.y = uvz0.y;
			}

			uvz2ext.x = uvz2.x;
			uvz2ext.y = uvz2.y;

			// 1st triangle
			uvz1.x = uvz0.x + (uvz1.x - uvz0.x) * (dvNearPlane - zv0.z) / (zv1.z - zv0.z);
			uvz1.y = uvz0.y + (uvz1.y - uvz0.y) * (dvNearPlane - zv0.z) / (zv1.z - zv0.z);
			uvz2.x = uvz2.x + (origUV.x - uvz2.x) * (dvNearPlane - zv2.z) / (zv1.z - zv2.z);
			uvz2.y = uvz2.y + (origUV.y - uvz2.y) * (dvNearPlane - zv2.z) / (zv1.z - zv2.z);

			if (variant != 1)
			{
				uvz0.x = origUVadd.x;
				uvz0.y = origUVadd.y;
			}

			// 2nd triangle
			uvz0ext.x = uvz0.x;
			uvz0ext.y = uvz0.y;
			uvz1ext.x = uvz2.x;
			uvz1ext.y = uvz2.y;
		}

		// 0-1
		tprm = Math.abs((zv0.z - dvNearPlane) / (zv1.z - zv0.z));
		ext0.x = zv0.x + (zv1.x - zv0.x) * tprm;
		ext0.y = zv0.y + (zv1.y - zv0.y) * tprm;

		// 0-2
		tprm = Math.abs((zv2.z - dvNearPlane) / (zv1.z - zv2.z));
		ext1.x = zv2.x + (zv1.x - zv2.x) * tprm;
		ext1.y = zv2.y + (zv1.y - zv2.y) * tprm;

		ext0.z = ext1.z = dvNearPlane;

		// Set coords second triangle
		szv0.x = zv0.x; szv0.y = zv0.y; szv0.z = zv0.z;
		szv1.x = ext1.x; szv1.y = ext1.y; szv1.z = ext1.z;
		szv2.x = zv2.x; szv2.y = zv2.y; szv2.z = zv2.z;

		// Set coords
		zv0.x = zv0.x; zv0.y = zv0.y; zv0.z = zv0.z;
		zv1.x = ext0.x; zv1.y = ext0.y; zv1.z = ext0.z;
		zv2.x = ext1.x; zv2.y = ext1.y; zv2.z = ext1.z;
	}

	/**
	 * Recalculate z-clipping for line
	 */
	public static inline function recalculateLine(zv0:V3d, zv1:V3d, variant:Int, dvNearPlane:Float, ext0:V3d, ext1:V3d):Void
	{
		if (variant == 1)
		{
			// v0 — visible
			recalculateVertexLine(zv0, zv1, dvNearPlane, ext0, ext1);
		}
		else
		{
			// v1 — visible
			recalculateVertexLine(zv1, zv0, dvNearPlane, ext0, ext1);
		}
	}

	/**
	 * z clipping - two vertices, one triangle
	 */
	public static inline function recalculateTwoVertices(zv0:V3d, zv1:V3d, zv2:V3d, variant:Int, uvz0:V2d, uvz1:V2d, uvz2:V2d, calcUv:Bool = false, dvNearPlane:Float, ext0:V3d, ext1:V3d):Void
	{

		if (variant == 1)
		{
			// v0 — visible
			recalculateVertex(zv0, zv1, zv2, ext0, ext1, dvNearPlane, calcUv, uvz0, uvz1, uvz2);
		}
		else if (variant == 2)
		{
			// v1 — visible
			recalculateVertex(zv1, zv0, zv2, ext0, ext1, dvNearPlane, calcUv, uvz1, uvz0, uvz2);
		}
		else if (variant == 3)
		{
			// v2 - visible
			recalculateVertex(zv2, zv0, zv1, ext0, ext1, dvNearPlane, calcUv, uvz2, uvz0, uvz1);
		}

	}

	/**
	 * z clipping - two faces, two triangles
	 */
	public static inline function recalculateTwoVertices_TwoFaces(zv0:V3d, zv1:V3d, zv2:V3d, szv0:V3d, szv1:V3d, szv2:V3d, variant:Int, dvNearPlane:Float, ext0:V3d, ext1:V3d):Void
	{
		var tprm:Float = 0;

		if (variant == 1)
		{
			// Vertex 1 is not visible
			recalculateVertex_TwoFaces(zv0, zv1, zv2, szv0, szv1, szv2, variant, null, null, null, null, null, null, false, dvNearPlane, ext0, ext1);
		}
		else if (variant == 2)
		{
			// Vertex 0 is not visible
			recalculateVertex_TwoFaces(zv2, zv0, zv1, szv1, szv0, szv2, variant, null, null, null, null, null, null, false, dvNearPlane, ext0, ext1);
		}
		else if (variant == 3)
		{
			// vertice 2 is not visible
			recalculateVertex_TwoFaces(zv1, zv2, zv0, szv2, szv0, szv1, variant, null, null, null, null, null, null, false, dvNearPlane, ext0, ext1);
		}
	}

	/**
	 * z-clipping recalculate two triangles with UV coords
	 */
	public static inline function recalculateTwoVertices_TwoFacesUV(zv0:V3d, zv1:V3d, zv2:V3d, szv0:V3d, szv1:V3d, szv2:V3d, variant:Int, uvz0:V2d, uvz1:V2d, uvz2:V2d, uvz0ext:V2d, uvz1ext:V2d, uvz2ext:V2d, calcUv:Bool = false, dvNearPlane:Float, ext0:V3d, ext1:V3d):Void
	{
		if (variant == 1)
		{
			// Vertex 1 is not visible
			recalculateVertex_TwoFaces(zv0, zv1, zv2, szv0, szv1, szv2, variant, uvz0, uvz1, uvz2, uvz0ext, uvz1ext, uvz2ext, calcUv, dvNearPlane, ext0, ext1);
		}
		else if (variant == 2)
		{
			// Vertex 0 is not visible
			recalculateVertex_TwoFaces(zv2, zv0, zv1, szv1, szv0, szv2, variant, uvz2, uvz0, uvz1, uvz1ext, uvz0ext, uvz2ext, calcUv, dvNearPlane, ext0, ext1);
		}
		else if (variant == 3)
		{
			// vertice 2 is not visible
			recalculateVertex_TwoFaces(zv1, zv2, zv0, szv2, szv0, szv1, variant, uvz1, uvz2, uvz0, uvz2ext, uvz0ext, uvz1ext, calcUv, dvNearPlane, ext0, ext1);
		}
	}

}