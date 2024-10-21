package crd3d.math;
import crd3d.displayobjects.Object3d;
import crd3d.geom.Face;
import crd3d.geom.V3d;

class Intersection
{

	// Is intersection found
	public var isIntersect:Bool = false;

	// Point of intersection
	public var intersectPoint:V3d = new V3d();

	// Distance to intersection from ray position
	public var intersectDistance:Float = 0;

	// Total number of intersections
	public var intersectionCount:Int = 0;

	public var debug:String = "";

	private static var edge0:V3d = new V3d();
	private static var edge1:V3d = new V3d();
	private static var rayDirEdge1Cross:V3d = new V3d();
	private static var rayPosDist:V3d = new V3d();
	private static var u:Float;
	private static var v:Float;
	private static var t:Float;

	private static var closestIntersection:Float = Math.POSITIVE_INFINITY;

	private static var tempIntersection:Intersection = new Intersection();

	public function new()
	{
		
	}

	/**
	 * Tests if ray intersects mesh and stores nearest intersection point in intersection object
	 */
	public static inline function getMeshIntersection(rayPos:V3d, rayDir:V3d, mesh:Object3d, intersection:Intersection):Void
	{
		closestIntersection = Math.POSITIVE_INFINITY;

		// Reset
		intersection.isIntersect = false;
		intersection.intersectDistance = Math.POSITIVE_INFINITY;
		intersection.intersectPoint.x = 0;
		intersection.intersectPoint.y = 0;
		intersection.intersectPoint.z = 0;
		intersection.intersectionCount = 0;
		intersection.debug = "";

		// Check intersection for each mesh face
		for (i in 0...mesh.faces.length)
		{
			var iface:Face = mesh.faces[i];

			// Vertex indices
			var ind0 = iface.indices[0];
			var ind1 = iface.indices[1];
			var ind2 = iface.indices[2];

			// Vertices
			var v0:V3d = mesh.vertices[ind0];
			var v1:V3d = mesh.vertices[ind1];
			var v2:V3d = mesh.vertices[ind2];

			// Check intersection
			getIntersection(rayPos, rayDir, v0, v1, v2);

			// Check intersection distance
			if ( tempIntersection.intersectDistance < closestIntersection
			&& tempIntersection.isIntersect
			&& tempIntersection.intersectDistance > 0)
			{
				// Save nearest intersection
				intersection.isIntersect = tempIntersection.isIntersect;
				intersection.intersectDistance = tempIntersection.intersectDistance;
				intersection.intersectPoint.x = tempIntersection.intersectPoint.x;
				intersection.intersectPoint.y = tempIntersection.intersectPoint.y;
				intersection.intersectPoint.z = tempIntersection.intersectPoint.z;
				intersection.intersectionCount++;
				closestIntersection = tempIntersection.intersectDistance;
			}
		}
	}

	/**
	 * Tests if ray intersects triangle, calculates intersection point
	 * Implementation of Möller–Trumbore intersection algorithm with backface culling
	 */
	public static inline function getIntersection(rayPos:V3d, rayDir:V3d, v0:V3d, v1:V3d, v2:V3d):Void
	{
		tempIntersection.isIntersect = false;
		tempIntersection.intersectDistance = 0;
		tempIntersection.intersectPoint.x = 0;
		tempIntersection.intersectPoint.y = 0;
		tempIntersection.intersectPoint.z = 0;

		// 1-0 triangle edge
		edge0.x = v1.x - v0.x;
		edge0.y = v1.y - v0.y;
		edge0.z = v1.z - v0.z;

		// 2-0 triangle edge
		edge1.x = v2.x - v0.x;
		edge1.y = v2.y - v0.y;
		edge1.z = v2.z - v0.z;

		// Ray direction and edge1 cross product
		VectorMath.crossProductV3(rayDir, edge1, rayDirEdge1Cross);

		var edge0RayDirEdge0Dot:Float = VectorMath.dotProductV3(edge0, rayDirEdge1Cross);

		if (edge0RayDirEdge0Dot > 0.001)
		{
			tempIntersection.isIntersect = true;
		}
		else
		{
			// Parallel or backface - no intersection
			tempIntersection.isIntersect = false;
		}

		var edge0RayDirEdge0DotInv:Float = 1 / edge0RayDirEdge0Dot;

		// Position ray - v0
		rayPosDist.x = rayPos.x - v0.x;
		rayPosDist.y = rayPos.y - v0.y;
		rayPosDist.z = rayPos.z - v0.z;

		u = VectorMath.dotProductV3(rayPosDist, rayDirEdge1Cross) * edge0RayDirEdge0DotInv;

		if (u < 0 || u > 1)
		{
			// Test u, no intersection
			tempIntersection.isIntersect = false;
		}

		// rayPosDist, edge0
		var qvec:V3d = new V3d();
		VectorMath.crossProductV3(rayPosDist, edge0, qvec);

		v = VectorMath.dotProductV3(rayDir, qvec) * edge0RayDirEdge0DotInv;

		if (v < 0 || u + v > 1)
		{
			// Test v, no intersection
			tempIntersection.isIntersect = false;
		}

		// Intersection distance
		t = VectorMath.dotProductV3(edge1, qvec) * edge0RayDirEdge0DotInv;

		// Intersection point
		tempIntersection.intersectPoint.x = rayPos.x + rayDir.x * t;
		tempIntersection.intersectPoint.y = rayPos.y + rayDir.y * t;
		tempIntersection.intersectPoint.z = rayPos.z + rayDir.z * t;

		tempIntersection.intersectDistance = t;
	}

}