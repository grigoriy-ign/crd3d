package crd3d.render;

import Std;
import crd3d.display.Viewport;
import crd3d.scene.Camera;
import crd3d.scene.Scene;
import crd3d.scene.Sector;
import flash.Vector;
import flash.geom.Matrix;

import crd3d.debug.Debug;
import crd3d.geom.*;
import crd3d.displayobjects.*;

class RenderUtils
{

	private static inline var PI:Float = 3.14159265359;

	// Frustum view culling
	///private static var curObjectCenterPoint:V3d = new V3d();
	private static var curObjectRadiusSize:Float = 0;

	public static var curVp:Viewport;			// Current viewport
	public static var curCam:Camera;			// Current camera
	public static var curScene:Scene;			// Current scene

	// Frustum pyramid
	private static var frstA:V3d = new V3d(0, 1, 0);
	private static var frstB:V3d = new V3d(0, 0, 0);
	private static var frstC:V3d = new V3d(0, 0, 0);
	private static var frstBn:V3d = new V3d(1, 0, 0);

	private static var lv1c:V3d = new V3d();

	/**
	 * Checks if line intersects rectangle (2d)
	 */
	public static inline function crossingTestRectangle(r1:V2d, r2:V2d, r3:V2d, r4:V2d, p1:V2d, p2:V2d):Bool
	{
		var zn:Float = 0;
		var ca:Float = 0;
		var cb:Float = 0;
		var ua:Float = 0;
		var ub:Float = 0;
		var result:Bool = false;

		// 1	// p11 = r1 	p12 = r2	p21 = p1	p22 = p2
		zn = (r2.y - r1.y) * (p1.x - p2.x) - (p1.y - p2.y) * (r2.x - r1.x);
		ca = (r2.y - r1.y) * (p1.x - r1.x) - (p1.y - r1.y) * (r2.x - r1.x);
		cb = (p1.y - r1.y) * (p1.x - p2.x) - (p1.y - p2.y) * (p1.x - r1.x);
		if ((zn == 0) && (ca == 0) && (cb == 0)) result = true;
		ua = ca / zn;
		ub = cb / zn;
		if ((0 <= ua) && (ua <= 1) && (0 <= ub) && (ub <= 1)) return true;

		// 2	// p11 = r2 	p12 = r3	p21 = p1	p22 = p2
		zn = (r3.y - r2.y) * (p1.x - p2.x) - (p1.y - p2.y) * (r3.x - r2.x);
		ca = (r3.y - r2.y) * (p1.x - r2.x) - (p1.y - r2.y) * (r3.x - r2.x);
		cb = (p1.y - r2.y) * (p1.x - p2.x) - (p1.y - p2.y) * (p1.x - r2.x);
		if ((zn == 0) && (ca == 0) && (cb == 0)) result = true;
		ua = ca / zn;
		ub = cb / zn;
		if ((0 <= ua) && (ua <= 1) && (0 <= ub) && (ub <= 1)) return true;

		// 3	// p11 = r3 	p12 = r4	p21 = p1	p22 = p2
		zn = (r4.y - r3.y) * (p1.x - p2.x) - (p1.y - p2.y) * (r4.x - r3.x);
		ca = (r4.y - r3.y) * (p1.x - r3.x) - (p1.y - r3.y) * (r4.x - r3.x);
		cb = (p1.y - r3.y) * (p1.x - p2.x) - (p1.y - p2.y) * (p1.x - r3.x);
		if ((zn == 0) && (ca == 0) && (cb == 0)) result = true;
		ua = ca / zn;
		ub = cb / zn;
		if ((0 <= ua) && (ua <= 1) && (0 <= ub) && (ub <= 1)) return true;

		// 4	// p11 = r4 	p12 = r1	p21 = p1	p22 = p2
		zn = (r1.y - r4.y) * (p1.x - p2.x) - (p1.y - p2.y) * (r1.x - r4.x);
		ca = (r1.y - r4.y) * (p1.x - r4.x) - (p1.y - r4.y) * (r1.x - r4.x);
		cb = (p1.y - r4.y) * (p1.x - p2.x) - (p1.y - p2.y) * (p1.x - r4.x);
		if ((zn == 0) && (ca == 0) && (cb == 0)) result = true;
		ua = ca / zn;
		ub = cb / zn;
		if ((0 <= ua) && (ua <= 1) && (0 <= ub) && (ub <= 1)) result = true;

		return result;
	}

	/**
	 * Inverts UV matrix
	 */
	public static inline function invertMatrix(finalDrawingMatrix:Matrix, UVMatrix:Matrix, almostZero:Float)
	{
		finalDrawingMatrix.a = 1;
		finalDrawingMatrix.b = almostZero;
		finalDrawingMatrix.c = almostZero;
		finalDrawingMatrix.d = 1;
		finalDrawingMatrix.tx = almostZero;
		finalDrawingMatrix.ty = almostZero;

		var ma:Float = UVMatrix.a;
		UVMatrix.a /= ma;
		UVMatrix.c /= ma;
		UVMatrix.tx /= ma;
		finalDrawingMatrix.a /= ma;
		finalDrawingMatrix.c /= ma;
		finalDrawingMatrix.tx /= ma;

		var mb:Float = UVMatrix.b;
		UVMatrix.b -= (UVMatrix.a * mb);
		UVMatrix.d -= (UVMatrix.c * mb);
		UVMatrix.ty -= (UVMatrix.tx * mb);
		finalDrawingMatrix.b -= (finalDrawingMatrix.a * mb);
		finalDrawingMatrix.d -= (finalDrawingMatrix.c * mb);
		finalDrawingMatrix.ty -= (finalDrawingMatrix.tx * mb);

		var md:Float = UVMatrix.d;
		UVMatrix.b /= md;
		UVMatrix.d /= md;
		UVMatrix.ty /= md;
		finalDrawingMatrix.b /= md;
		finalDrawingMatrix.d /= md;
		finalDrawingMatrix.ty /= md;

		var mty:Float = UVMatrix.ty;
		UVMatrix.ty -= (mty);
		finalDrawingMatrix.ty -= (mty);

		var mtx:Float = UVMatrix.tx;
		UVMatrix.tx -= (mtx);
		finalDrawingMatrix.tx -= (mtx);
		var mc:Float = UVMatrix.c;

		finalDrawingMatrix.a -= (finalDrawingMatrix.b * mc);
		finalDrawingMatrix.c -= (finalDrawingMatrix.d * mc);
		finalDrawingMatrix.tx -= (finalDrawingMatrix.ty * mc);
	}

	/**
	 * Frustum culling check
	 */
	public static inline function isFrustumViewVisible(curCheckObj:RenderObject, curObjectCenterPoint:V3d):Bool
	{
		if (curCheckObj.objectType == RenderObject.OBJECT_TYPE_OBJECT3D)
		{
			curObjectCenterPoint.x = curCheckObj.objObject3d.position.x;
			curObjectCenterPoint.y = curCheckObj.objObject3d.position.y;
			curObjectCenterPoint.z = curCheckObj.objObject3d.position.z;
		}
		if (curCheckObj.objectType == RenderObject.OBJECT_TYPE_SPRITE2D)
		{
			curObjectCenterPoint.x = curCheckObj.objSprite2d.position.x;
			curObjectCenterPoint.y = curCheckObj.objSprite2d.position.y;
			curObjectCenterPoint.z = curCheckObj.objSprite2d.position.z;
		}
		if (curCheckObj.objectType == RenderObject.OBJECT_TYPE_LINE3D)
		{
			return true;
		}
		curObjectRadiusSize = curCheckObj.getRadiusSize();

		curCam.viewTransform(curObjectCenterPoint);

		var fcres:Float = 0;

		if (curObjectCenterPoint.z < curCam.nearPlane - curObjectRadiusSize)
		{
			return false;
		}

		if (curObjectCenterPoint.z > curCam.farPlane + curObjectRadiusSize)
		{
			return false;
		}

		fcres = curVp.ca * curObjectCenterPoint.x + curVp.cc * curObjectCenterPoint.z + curObjectRadiusSize;
		if (fcres <= 0)
		{
			return false;
		}

		fcres = -curVp.ca * curObjectCenterPoint.x + curVp.cc * curObjectCenterPoint.z + curObjectRadiusSize;
		if (fcres <= 0)
		{
			return false;
		}

		fcres = curVp.ca * curObjectCenterPoint.y + curVp.cc * curObjectCenterPoint.z + curObjectRadiusSize;
		if (fcres <= 0)
		{
			return false;
		}

		fcres = -curVp.ca * curObjectCenterPoint.y + curVp.cc * curObjectCenterPoint.z + curObjectRadiusSize;
		if (fcres <= 0)
		{
			return false;
		}

		return true;
	}

	/**
	 * Returns index of sector where camera located
	 */
	public static inline function getCurrentSector():Int
	{
		var i:Int;
		var ilen:Int = curScene.sectorsArray.length;
		var curSector:Sector;
		var curSectorIndex:Int = 0;

		for (i in 0...ilen)
		{
			curSector = curScene.sectorsArray[i];
			if (curSector.isPointInSector(curCam.position))
			{
				curSectorIndex = i;
			}
		}

		Debug.rtracestr("Sector: " + curSectorIndex);
		return curSectorIndex;
	}

	/**
	 * Fill visible sectors array with indices
	 */
	public static inline function determineVisibleSectors(cameraInSector:Int, visibleSectors:Array<Int>):Void
	{
		var i:Int;
		var sect:Sector = curScene.sectorsArray[cameraInSector];	// Current sector (camera)
		var ilen:Int = sect.visibleSectors.length;
		for (i in 0...ilen)
		{
			visibleSectors[i] = sect.visibleSectors[i];
		}
		visibleSectors[ilen] = cameraInSector;

		Debug.rtracestr("Visible Sectors: " + visibleSectors.length);
	}

	/**
	 * Recalculates frustum pyramid and focus length
	 */
	public static inline function recalcFrustum():Void
	{
		var viewportSize:Float = 0;
		if (curVp.viewportWidth > curVp.viewportHeight)
		{
			viewportSize = curVp.viewportWidth;
		}
		else
		{
			viewportSize = curVp.viewportHeight;
		}

		// Recalculate focus length
		curVp.focusLength = curCam.fov * PI / 180;
		curVp.focusLength = (viewportSize / 2) / Math.tan(curVp.focusLength * 0.5);
		curVp.currentCameraFov = curCam.fov;

		// Recalculate frustum pyramid
		var A:V3d = frstA;
		var bn:V3d = frstBn;
		var B:V3d = frstB;
		var ang:Float = curCam.fov + (90 - (curCam.fov * 0.5));
		var ar:Float = ang * PI / 180;

		B.x = bn.x * Math.cos(ar) - bn.z * Math.sin(ar);
		B.z = bn.x * Math.sin(ar) + bn.z * Math.cos(ar);

		// Cross product
		var C:V3d = frstC;
		C.x = A.y * B.z - A.z * B.y;
		C.y = A.z * B.x - A.x * B.z;
		C.z = A.x * B.y - A.y * B.x;

		var fovv:Float = curCam.fov * PI / 180;
		var foclen:Float = (viewportSize * 0.5) / Math.tan(fovv * 0.5);
		var dst:Float = foclen * Math.sin(fovv * 0.5);

		curVp.ca = C.x;
		curVp.cb = C.y;
		curVp.cc = C.z;
		curVp.fc = (curVp.ca * -B.x) + (curVp.cb * -B.y) + (curVp.cc * -B.z) + dst;
	}

	/**
	 * Draws textured or solid triangle with shading using lineTo method
	 */
	public static inline function drawTriangle(curObject3d:Object3d, ls0:V2d, ls1:V2d, ls2:V2d, curRface:RFace, finalDrawingMatrix:Matrix, drawnTriangleCount:Int):Int
	{
		if (!curVp.doDraw)
		{
			return drawnTriangleCount;
		}

		if (curObject3d.material.useTexture)
		{
			// Texture fill
			curVp.graphics.beginBitmapFill(curObject3d.material.btmd, finalDrawingMatrix, true, false);
		}
		else
		{
			// Color fill
			curObject3d.shadeColor( curRface.shade );
			curVp.graphics.beginFill(curObject3d.colorTf.color);
		}

		// Draw triangle
		curVp.graphics.moveTo(ls0.x, ls0.y);
		curVp.graphics.lineTo(ls1.x, ls1.y);
		curVp.graphics.lineTo(ls2.x, ls2.y);
		curVp.graphics.endFill();
		drawnTriangleCount++;

		// Flat shading for textured triangle
		if (curObject3d.flatShading && curObject3d.material.useTexture)
		{
			curVp.graphics.beginFill(0x000000, curRface.shade);

			curVp.graphics.moveTo(ls0.x, ls0.y);
			curVp.graphics.lineTo(ls1.x, ls1.y);
			curVp.graphics.lineTo(ls2.x, ls2.y);
			curVp.graphics.endFill();
			drawnTriangleCount++;
		}

		return drawnTriangleCount;
	}

	/**
	 * Draws triangles using drawTriangles method (perspective correct)
	 */
	public static inline function drawTrianglesCorrect(curObject3d:Object3d, curRface:RFace, indLen:Int, projectedVertices:Vector<Float>, vec3:Vector<Int>, vec4:Vector<Int>, uvtdata:Vector<Float>, bfCullingMode:Dynamic, drawnTriangleCount:Int):Int
	{
		if (!curVp.doDraw)
		{
			return drawnTriangleCount;
		}

		if (curObject3d.material.useTexture)
		{
			curVp.graphics.beginBitmapFill(curObject3d.material.btmd, null, true, false);

			if (indLen == 3)
			{
				curVp.graphics.drawTriangles(projectedVertices, vec3, uvtdata, bfCullingMode);
				drawnTriangleCount++;
			}
			else
			{
				curVp.graphics.drawTriangles(projectedVertices, vec4, uvtdata, bfCullingMode);
				drawnTriangleCount+=2;
			}
		}
		else
		{
			curObject3d.shadeColor( curRface.shade );
			curVp.graphics.beginFill(curObject3d.colorTf.color);

			if (indLen == 3)
			{
				curVp.graphics.drawTriangles(projectedVertices, vec3, null, bfCullingMode);
				drawnTriangleCount++;
			}
			else
			{
				curVp.graphics.drawTriangles(projectedVertices, vec4, null, bfCullingMode);
				drawnTriangleCount += 2;
			}

		}

		curVp.graphics.endFill();

		if (curObject3d.flatShading && curObject3d.material.useTexture)
		{
			curVp.graphics.beginFill(0x000000, curRface.shade);

			if (indLen == 3)
			{
				curVp.graphics.drawTriangles(projectedVertices, vec3, null, bfCullingMode);
				drawnTriangleCount++;
			}
			else
			{
				curVp.graphics.drawTriangles(projectedVertices, vec4, null, bfCullingMode);
				drawnTriangleCount += 2;
			}

			curVp.graphics.endFill();
		}

		return drawnTriangleCount;
	}

	/**
	 * Draws sprite
	 */
	public static inline function drawSprite(curSprite:Sprite2d, curRface:RFace, sprMatrix:Matrix, drawnTriangleCount:Int):Int
	{
		if (!curVp.doDraw)
		{
			return drawnTriangleCount;
		}

		curSprite = curRface.spriteRef;
		var lv0:V3d = curSprite.position;

		var zcoord:Float = curRface.zDist / curVp.focusLength;

		// Sprite matrix
		sprMatrix.a = curSprite.scaleX / zcoord;
		sprMatrix.b = 0;
		sprMatrix.c = 0;
		sprMatrix.d = curSprite.scaleY / zcoord;
		sprMatrix.tx = curSprite.projected.x - (curSprite.sizeX * curSprite.stepX * curSprite.scaleX / zcoord) + (curSprite.offsetX * curSprite.scaleX / zcoord);
		sprMatrix.ty = curSprite.projected.y - (curSprite.sizeY * curSprite.stepY * curSprite.scaleY / zcoord) + (curSprite.offsetY * curSprite.scaleY / zcoord);

		// Animate sprite
		if (curSprite.animated)
		{
			curSprite.animate();
		}

		// Draw rect
		curVp.graphics.beginBitmapFill(curSprite.bitmap, sprMatrix, false, false);

		var rect_sx:Float = curSprite.projected.x + (curSprite.offsetX * curSprite.scaleX) / zcoord;
		var rect_sy:Float = curSprite.projected.y + (curSprite.offsetY * curSprite.scaleY) / zcoord;
		var rect_w:Float = curSprite.sizeX * curSprite.scaleX / zcoord;
		var rect_h:Float = curSprite.sizeY * curSprite.scaleY / zcoord;

		curVp.graphics.drawRect(rect_sx, rect_sy, rect_w, rect_h);
		drawnTriangleCount++;

		return drawnTriangleCount;
	}

	/**
	 * Tests if projected triangle cross screen using viewport points and projected triangle coords
	 */
	public static inline function isTriangleCrossScreen(vpPointLeftUp:V2d, vpPointRightUp:V2d, vpPointRightDown:V2d, vpPointLeftDown:V2d, ls0:V2d, ls1:V2d, ls2:V2d ):Bool
	{
		var result:Bool = (RenderUtils.crossingTestRectangle(vpPointLeftUp, vpPointRightUp, vpPointRightDown, vpPointLeftDown, ls0, ls1)
		|| RenderUtils.crossingTestRectangle(vpPointLeftUp, vpPointRightUp, vpPointRightDown, vpPointLeftDown, ls1, ls2)
		|| RenderUtils.crossingTestRectangle(vpPointLeftUp, vpPointRightUp, vpPointRightDown, vpPointLeftDown, ls2, ls0));

		return result;
	}

}