package crd3d.displayobjects;

import crd3d.geom.Face;
import crd3d.geom.V2d;
import crd3d.geom.V3d;
import crd3d.materials.Material;
import crd3d.math.MinMax;
import crd3d.math.VectorMath;
import crd3d.scene.Scene;
import flash.Vector;
import flash.geom.ColorTransform;

/**
 * 3D object data (vertices, faces, UV)
 */
class Object3d
{
	public var type:UInt = RenderObject.OBJECT_TYPE_OBJECT3D;

	public var position:V3d = new V3d(0, 0, 0);
	public var rotation:V3d = new V3d(0, 0, 0);

	public var vertices:Vector<V3d>;
	public var faces:Vector<Face>;
	public var facesMidpoints:Vector<V3d>;		// Faces midpoints for z sorting

	public var uvVertices:Vector<V2d>;
	public var uvFaces:Vector<Face>;

	public var material:Material;

	public var radiusSize:Float;			// Object size for frustum culling

	public var bfCulling:Bool = false;		// Is backface culling enabled
	public var flatShading:Bool = false;	// Is flat shading enabled

	public var objectAccessory:Int = Scene.OBJECT_ACCESSORY_ENTIRE;

	public var colorTf:ColorTransform = new ColorTransform();
	public var colorR:Float = 255;
	public var colorG:Float = 255;
	public var colorB:Float = 255;

	public var rendObjRef:RenderObject;
	public var id:Int = 0;

	public var isCollider:Bool = false;

	public function new()
	{
		vertices = new Vector<V3d>();
		uvVertices = new Vector<V2d>();
		faces = new Vector<Face>();
		uvFaces = new Vector<Face>();

		facesMidpoints = new Vector<V3d>();

		colorTf.color = 0xffffff;
	}

	/**
	 * Sets object color 0-255
	 */
	public inline function setColor(r:Float, g:Float, b:Float):Void
	{
		colorR = r;
		colorG = g;
		colorB = b;

		colorTf.redOffset = colorR;
		colorTf.greenOffset = colorG;
		colorTf.blueOffset = colorB;
	}

	/*
	 * Sets color shade 0-1
	 */
	public inline function shadeColor(shade:Float):Void
	{
		var colorMult:Float = 1 - shade;

		colorTf.redOffset = colorR * colorMult;
		colorTf.greenOffset = colorG * colorMult;
		colorTf.blueOffset = colorB * colorMult;
	}

	/**
	 * Loads model from other 3D object class (for example parsed object)
	 * @param src Instance of class containing 3D model data
	 * @param decreaseFaceIndex If True decreases each vertex index in polygon
	 */
	public function loadModel(src:Dynamic, decreaseFaceIndex:Bool):Void
	{
		// Load vertices
		for (i in 0...src.vertices.length)
		{
			var srcv:V3d = src.vertices[i];
			vertices[i] = new V3d(srcv.x, srcv.y, srcv.z);
		}

		// Load UV vertices
		for (i in 0...src.uvVertices.length)
		{
			var srcv:V2d = src.uvVertices[i];
			uvVertices[i] = new V2d(srcv.x, srcv.y);
		}

		// Calculate object size
		var minx:Float = MinMax.minX_VectorV3d(vertices);
		var miny:Float = MinMax.minY_VectorV3d(vertices);
		var minz:Float = MinMax.minZ_VectorV3d(vertices);
		var maxx:Float = MinMax.maxX_VectorV3d(vertices);
		var maxy:Float = MinMax.maxY_VectorV3d(vertices);
		var maxz:Float = MinMax.maxZ_VectorV3d(vertices);

		radiusSize = Math.sqrt((maxx - minx) * (maxx - minx) + (maxy - miny) * (maxy - miny) + (maxz - minz) * (maxz - minz));

		// Load faces
		for (i in 0...src.faces.length)
		{
			var newf:Face = new Face([]);
			var srcf:Face = src.faces[i];

			for (j in 0...srcf.indices.length)
			{

				if (decreaseFaceIndex)
				{
					newf.indices[j] = srcf.indices[j] - 1;
				}
				else
				{
					newf.indices[j] = srcf.indices[j];
				}
			}

			faces[i] = newf;
		}

		//Load UV faces
		for (i in 0...src.uvFaces.length)
		{
			var newf:Face = new Face([]);
			var srcf:Face = src.uvFaces[i];

			for (j in 0...srcf.indices.length)
			{

				if (decreaseFaceIndex)
				{
					newf.indices[j] = srcf.indices[j] - 1;
				}
				else
				{
					newf.indices[j] = srcf.indices[j];
				}
			}

			uvFaces[i] = newf;
		}

		// Calculate face midpoints for z sorting
		for (i in 0...faces.length)
		{
			var curFace:Face = faces[i];
			var curFacePoints:Array<V3d> = new Array();
			for (j in 0...curFace.indices.length)
			{

				curFacePoints[j] = vertices[curFace.indices[j]];
			}

			var sumx:Float = 0;
			var sumy:Float = 0;
			var sumz:Float = 0;
			for (j in 0...curFacePoints.length)
			{
				sumx += curFacePoints[j].x;
				sumy += curFacePoints[j].y;
				sumz += curFacePoints[j].z;
			}
			var facePointsLength:Int = curFacePoints.length;
			facesMidpoints[i] = new V3d(sumx / facePointsLength, sumy / facePointsLength, sumz / facePointsLength);
		}

	}

	/**
	 * Sets position of 3D object
	 */
	public function setPosition(px:Float, py:Float, pz:Float):Void
	{
		var curPoint:V3d;
		for (i in 0...vertices.length)
		{
			curPoint = vertices[i];
			curPoint.x = curPoint.x + (px - position.x);
			curPoint.y = curPoint.y + (py - position.y);
			curPoint.z = curPoint.z + (pz - position.z);
		}

		for (i in 0...facesMidpoints.length)
		{
			curPoint = facesMidpoints[i];
			curPoint.x = curPoint.x + (px - position.x);
			curPoint.y = curPoint.y + (py - position.y);
			curPoint.z = curPoint.z + (pz - position.z);
		}

		position.x = px;
		position.y = py;
		position.z = pz;
	}

	/**
	 * Sets rotation of 3D object
	 */
	public function setRotation(rx:Float = 0, ry:Float = 0, rz:Float = 0):Void
	{
		var cx:Float = position.x;
		var cy:Float = position.y;
		var cz:Float = position.z;

		var radx:Float = (rx - rotation.x) * Math.PI / 180;
		var rady:Float = (ry - rotation.y) * Math.PI / 180;
		var radz:Float = (rz - rotation.z) * Math.PI / 180;

		var sinx:Float = Math.sin(radx);
		var siny:Float = Math.sin(rady);
		var sinz:Float = Math.sin(radz);
		var cosx:Float = Math.cos(radx);
		var cosy:Float = Math.cos(rady);
		var cosz:Float = Math.cos(radz);

		// Vertex-matrix multiplication
		for (i in 0...vertices.length)
		{
			var resVec:V3d = vertices[i];
			var curVec:V3d = new V3d(0, 0, 0);
			curVec.x = resVec.x;
			curVec.y = resVec.y;
			curVec.z = resVec.z;

			var vx:Float = curVec.x;
			var vy:Float = curVec.y;
			var vz:Float = curVec.z;

			resVec.x = VectorMath.vertexRotationX(cx, cy, cz, vx, vy, vz, sinx, siny, sinz, cosx, cosy, cosz);
			resVec.y = VectorMath.vertexRotationY(cx, cy, cz, vx, vy, vz, sinx, siny, sinz, cosx, cosy, cosz);
			resVec.z = VectorMath.vertexRotationZ(cx, cy, cz, vx, vy, vz, sinx, siny, sinz, cosx, cosy, cosz);

		}

		// Vertex-matrix multiplication for mid. points
		for (i in 0...facesMidpoints.length)
		{
			var resVec:V3d = facesMidpoints[i];
			var curVec:V3d = new V3d(0, 0, 0);
			curVec.x = resVec.x;
			curVec.y = resVec.y;
			curVec.z = resVec.z;

			var vx:Float = curVec.x;
			var vy:Float = curVec.y;
			var vz:Float = curVec.z;
			
			resVec.x = VectorMath.vertexRotationX(cx, cy, cz, vx, vy, vz, sinx, siny, sinz, cosx, cosy, cosz);
			resVec.y = VectorMath.vertexRotationY(cx, cy, cz, vx, vy, vz, sinx, siny, sinz, cosx, cosy, cosz);
			resVec.z = VectorMath.vertexRotationZ(cx, cy, cz, vx, vy, vz, sinx, siny, sinz, cosx, cosy, cosz);

		}

		rotation.x = rx;
		rotation.y = ry;
		rotation.z = rz;
	}

	/**
	 * Sets scale of 3D object
	 */
	public function setScale(sx:Float, sy:Float, sz:Float, recalculateRadSize:Bool = false):Void
	{
		var objPosx:Float = position.x;
		var objPosy:Float = position.y;
		var objPosz:Float = position.z;

		setPosition(0, 0, 0);

		if ((sx == sy) && (sx == sz))
		{
			radiusSize *= sx;
		}
		else
		{
			if (recalculateRadSize) recalculateRadiusSize();
		}

		for (i in 0...vertices.length)
		{
			var curPoint:V3d = vertices[i];
			curPoint.x *= sx;
			curPoint.y *= sy;
			curPoint.z *= sz;
		}

		for (i in 0...facesMidpoints.length)
		{
			var curPoint:V3d = facesMidpoints[i];
			curPoint.x *= sx;
			curPoint.y *= sy;
			curPoint.z *= sz;
		}

		position.x *= sx;
		position.y *= sy;
		position.z *= sz;

		setPosition(objPosx, objPosy, objPosz);
	}

	/**
	 * Recalculates radius size of 3D object
	 */
	private function recalculateRadiusSize():Void
	{
		var minx:Float = MinMax.minX_VectorV3d(vertices);
		var miny:Float = MinMax.minY_VectorV3d(vertices);
		var minz:Float = MinMax.minZ_VectorV3d(vertices);
		var maxx:Float = MinMax.maxX_VectorV3d(vertices);
		var maxy:Float = MinMax.maxY_VectorV3d(vertices);
		var maxz:Float = MinMax.maxZ_VectorV3d(vertices);

		radiusSize = Math.sqrt((maxx - minx) * (maxx - minx) + (maxy - miny) * (maxy - miny) + (maxz - minz) * (maxz - minz));
	}

}