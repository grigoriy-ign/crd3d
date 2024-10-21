package crd3d.render;

import Std;
import crd3d.debug.Debug;
import crd3d.display.*;
import crd3d.displayobjects.*;
import crd3d.geom.*;
import crd3d.scene.*;
import flash.Vector;
import flash.display.Graphics;
import flash.display.TriangleCulling;
import flash.geom.Matrix;
import haxe.Timer;

class Renderer
{

	private static inline var PI:Float = 3.14159265359;

	private static var curVp:Viewport;			// Current viewport
	private static var curCam:Camera;			// Current camera
	private static var curScene:Scene;			// Current scene

	// Sectors
	private static var cameraInSector:Int = 0;				     // Index of current sector
	private static var visibleSectors:Array<Int> = new Array();	 // Indices of sectors visible from current sector
	private static var visibleObjectsLen:Int = 0;

	// Visible objects
	private static var visibleObjects:Array<RenderObject> = new Array();

	// RenderFace pool
	private static var rfacePool:RFacePool = new RFacePool();
	private static var facesToDraw:Array<RFace> = new Array();

	// Fog layers
	private static var fogLayersLen:Int = 0;	// Fog layers length
	private static var curFogLayer:FogLayer;	// Current fog layer

	// Backface culling
	private static var va:V3d = new V3d();
	private static var vb:V3d = new V3d();
	private static var polyNormal:V3d = new V3d();
	private static var viewVec:V3d = new V3d();

	// Flat shading
	private static var normVec:V3d = new V3d();
	private static var lightVec:V3d = new V3d();

	// Sprites
	private static var currentSpriteCenterCopy:V3d = new V3d();
	private static var sprMatrix:Matrix = new Matrix(1, 0, 0, 1, 0, 0);

	// Sorting
	private static var zmiddles:Array<Float> = new Array();		// Distance from face middle points to projection plane. Used for z sorting
	private static var sortedIndexes:Array<Int> = new Array();	// Sorted faces indices
	private static var curFaceMidpoint:V3d; 					// Current object midpoint

	// Rendering calculations
	private static var ls0_static:V2d = new V2d(); // Current vertices
	private static var ls1_static:V2d = new V2d();
	private static var ls2_static:V2d = new V2d();
	private static var lv0c:V3d = new V3d();
	private static var lv1c:V3d = new V3d();
	private static var lv2c:V3d = new V3d();

	// Is projected vertices visible
	private static var projVert0Vis:Bool = true;
	private static var projVert1Vis:Bool = true;
	private static var projVert2Vis:Bool = true;
	private static var projTriCrossScr:Bool = false; 	// Is projected triangle cross screen
	private static var projTriVis:Bool = true; 			// Is projected triangle visible

	// Is projected vertices visible (second triangle)
	private static var projVert0VisTri2:Bool = true;
	private static var projVert1VisTri2:Bool = true;
	private static var projVert2VisTri2:Bool = true;
	private static var projTriCrossScr2:Bool = false; 	// Is projected triangle cross screen (second triangle)
	private static var projTriVis2:Bool = true; 		// Is projected triangle visible (second triangle)

	// z-clipping
	private static var lvs0c:V3d = new V3d();
	private static var lvs1c:V3d = new V3d();
	private static var lvs2c:V3d = new V3d();
	private static var ls0s:V2d = new V2d();
	private static var ls1s:V2d = new V2d();
	private static var ls2s:V2d = new V2d();

	private static var ext0:V3d = new V3d();
	private static var ext1:V3d = new V3d();

	private static var v0nzc:V2d = new V2d(); // Projected vertices before z clipping
	private static var v1nzc:V2d = new V2d();
	private static var v2nzc:V2d = new V2d();

	// draw triangles
	private static var projVerts:Vector<Float> = new Vector<Float>();
	private static var uvtdata:Vector<Float> = new Vector<Float>();
	private static var v0Proj:V2d = new V2d();
	private static var v1Proj:V2d = new V2d();
	private static var v2Proj:V2d = new V2d();

	// Matrices
	private static var finalDrawingMatrix:Matrix = new Matrix();	// Final drawing matrix to perform drawing
	private static var UVMatrix:Matrix = new Matrix();				// UV matrix
	private static var imgMatrix:Matrix = new Matrix();				// Image matrix (UV)

	// UV Mapping
	private static var curMatUVs:Vector<V2d>;		// Current UV coords
	private static var curUVFace:Face;				// Current UV-Face
	private static var uvind0:UInt = 0;				// UV coords indices
	private static var uvind1:UInt = 0;
	private static var uvind2:UInt = 0;
	private static var luv0:V2d;
	private static var luv1:V2d;
	private static var luv2:V2d;
	private static var uv0:V2d = new V2d();
	private static var uv1:V2d = new V2d();
	private static var uv2:V2d = new V2d();
	private static var uv0add:V2d = new V2d();
	private static var uv1add:V2d = new V2d();
	private static var uv2add:V2d = new V2d();
	private static var uv0c:V2d = new V2d();
	private static var uv1c:V2d = new V2d();
	private static var uv2c:V2d = new V2d();
	private static var uv0cadd:V2d = new V2d();
	private static var uv1cadd:V2d = new V2d();
	private static var uv2cadd:V2d = new V2d();

	private static var ma:Float = 0;				// Invert matrix helpers
	private static var mb:Float = 0;
	private static var mc:Float = 0;
	private static var md:Float = 0;
	private static var mtx:Float = 0;
	private static var mty:Float = 0;

	// Viewport parameters
	private static var vpPointLeftUp:V2d = new V2d();
	private static var vpPointLeftDown:V2d = new V2d();
	private static var vpPointRightUp:V2d = new V2d();
	private static var vpPointRightDown:V2d = new V2d();

	// Statistics
	private static var potentiallyVisibleObjects:Int = 0;	// Number of objects in visible sectors
	private static var frameBeginS:Float = 0;
	private static var frameEndS:Float = 0;
	private static var drawTime:Float = 0;
	private static var lastUpdateStatsTime:UInt = 0;

	private static var polyCounter:Int = 0;

	// Special
	private static inline var almostZero:Float = 0.000000000000001;	// "Division by zero"
	private static inline var tValueMult:Float = 1000000000000;

	public static var wireframeColor:UInt = 0xffffff; // Wireframe color
	public static var perspectiveCorrectMode:Bool = false;
	public static var drawColliderMode:Bool = false;

	public function new()
	{

	}

	public static function render(vp:Viewport):Void
	{
		Debug.rtracestr(Std.int(drawTime) + " - Frame Time ms.");

		frameBeginS = Timer.stamp();

		var i:Int = 0;
		var ilen:Int = 0;
		var j:Int = 0;
		var jlen:Int = 0;

		clearStats(); // Reset counters and stats

		curVp = vp;
		curCam = curVp.viewCamera;
		curScene = curVp.renderingScene;
		var curVpGraphics:Graphics = curVp.graphics;

		RenderUtils.curCam = curCam;
		RenderUtils.curScene = curScene;
		RenderUtils.curVp = curVp;

		// Create default sector
		if (curScene.sectorsArray.length == 0)
		{
			var sector:Sector = new Sector();
			curScene.addSector(sector);
		}

		// Viewport parameters refresh
		vpPointLeftUp.x = 0;
		vpPointLeftUp.y = 0;
		vpPointLeftDown.x = 0;
		vpPointLeftDown.y = curVp.viewportHeight;
		vpPointRightUp.x = curVp.viewportWidth;
		vpPointRightUp.y = 0;
		vpPointRightDown.x = curVp.viewportWidth;
		vpPointRightDown.y = curVp.viewportHeight;

		// Background rendering
		drawViewportBackground();

		// Draw wireframe
		if (curVp.drawWireframe)
		{
			curVp.graphics.lineStyle(0.1, wireframeColor, 1);
		}
		Debug.rtracestr("DrawWireframe: " + curVp.drawWireframe);
		Debug.rtracestr("PerspectiveCorrent: " + Render.perspectiveCorrectEnabled);
		Debug.rtracestr("drawColliderMode: " + Renderer.drawColliderMode);

		// If camera FOV changed - recalculate frustum pyramid and focal length
		var doRecalcFrustum:Bool = curVp.currentCameraFov != curCam.fov;
		if (doRecalcFrustum)
		{
			RenderUtils.recalcFrustum();
		}
		Debug.rtracestr("RecalcFrustum: " + doRecalcFrustum);

		// Find current sector for camera
		cameraInSector = RenderUtils.getCurrentSector();

		// Find visible sectors
		RenderUtils.determineVisibleSectors(cameraInSector, visibleSectors);

		// Find visible objects
		determineVisibleObjects();

		// Find visible faces
		makeFacesList();

		// z sort visible faces
		sortedIndexes = [];
		for (i in 0...zmiddles.length)
		{
			sortedIndexes.push(i);
		}
		sortedIndexes.sort(function(a, b) return Std.int(zmiddles[b] - zmiddles[a]));

		// Draw faces
		if (Render.perspectiveCorrectEnabled)
		{
			drawFacesListCorrect();
		}
		else
		{
			drawFacesList();
		}

		// Draw lines
		drawLines();

		frameEndS = Timer.stamp();
		drawTime = (frameEndS - frameBeginS) * 1000;
	}

	/**
	 * Find visible objects (Frustum and sectors test)
	 */
	private static function determineVisibleObjects():Void
	{
		var renderObjects:Array<RenderObject> = curScene.renderObjects;
		var curObject:RenderObject;
		var ilen:Int = renderObjects.length;
		var visibleSectorsLen:Int = visibleSectors.length;
		var sect:Sector;
		var OBJECT_ACCESSORY_ENTIRE:Int = Scene.OBJECT_ACCESSORY_ENTIRE;
		var OBJECT_ACCESSORY_DYNAMIC:Int = Scene.OBJECT_ACCESSORY_DYNAMIC;
		var OBJECT_TYPE_OBJECT3D:UInt = RenderObject.OBJECT_TYPE_OBJECT3D;
		var OBJECT_TYPE_SPRITE2D:UInt = RenderObject.OBJECT_TYPE_SPRITE2D;
		var OBJECT_TYPE_LINE3D:UInt = RenderObject.OBJECT_TYPE_LINE3D;
		var frustumCheck:Bool = false;
		var pointInSector:Bool = false;
		var objPosition:V3d = new V3d();
		var curObjectCenterPoint:V3d = new V3d();

		// For each object
		for (i in 0...ilen)
		{
			curObject = renderObjects[i];

			// If object not visible
			if (!curObject.visible)
			{
				continue;
			}

			// Check frustum culling
			frustumCheck = RenderUtils.isFrustumViewVisible(curObject, curObjectCenterPoint);
			if (!frustumCheck)
			{
				continue;
			}

			// Get object position (3D object or sprite)
			if (curObject.objectType == OBJECT_TYPE_OBJECT3D)
			{
				objPosition = curObject.objObject3d.position;

				if (drawColliderMode)
				{
					if (!curObject.objObject3d.isCollider)
					{
						continue;
					}
				}
				else
				{
					if (curObject.objObject3d.isCollider)
					{
						continue;
					}
				}
			}
			if (curObject.objectType == OBJECT_TYPE_SPRITE2D)
			{
				objPosition = curObject.objSprite2d.position;
			}
			if (curObject.objectType == OBJECT_TYPE_LINE3D)
			{
				objPosition = curObject.objLine3d.position;
			}

			// Check object accessibility
			// Add to visible objects list if object is global (not sector specific)
			if (curObject.accessory == OBJECT_ACCESSORY_ENTIRE)
			{
				visibleObjects[visibleObjectsLen] = renderObjects[i];
				visibleObjectsLen++;
				potentiallyVisibleObjects++;
				continue;
			}

			// If object dynamic and can move from one sector to another
			// Find current sector of object
			if (curObject.accessory == OBJECT_ACCESSORY_DYNAMIC)
			{
				for (j in 0...visibleSectorsLen)
				{
					sect = curScene.sectorsArray[visibleSectors[j]];

					pointInSector = sect.isPointInSector(objPosition);
					if (!pointInSector)
					{
						continue;
					}

					visibleObjects[visibleObjectsLen] = renderObjects[i];
					visibleObjectsLen++;
					potentiallyVisibleObjects++;
				}

			}

			// If object is static and located in specific sector
			// Check if located in one of visible sectors
			if (curObject.accessory >= 0)
			{
				for (j in 0...visibleSectorsLen)
				{
					if (curObject.accessory != visibleSectors[j])
					{
						continue;
					}

					visibleObjects[visibleObjectsLen] = renderObjects[i];
					visibleObjectsLen++;
					potentiallyVisibleObjects++;
				}
			}

		}

		Debug.rtracestr("Objects: " + renderObjects.length);
		Debug.rtracestr("Visible Objects: " + potentiallyVisibleObjects);
	}

	/**
	 * Creates array of visible faces to be rendered
	 */
	private static function makeFacesList():Void
	{
		var visibleObjectsLen:Int = visibleObjects.length;
		var objectFacesCount:Int;	 // Number of faces in current object
		var objectVerticesCount:Int; // Number of vertices in current object
		var curVertice:V3d;
		var curRface:RFace;
		var curFace:Face;
		var currentRenderObject:RenderObject;
		var currentSprite:Sprite2d;
		var currentSpriteCenter:V3d;
		var currentObject:Object3d;
		var lightingKoeff:Float = 0;
		var curFaceMidpointCopy:V3d = new V3d();

		var OBJECT_TYPE_OBJECT3D:UInt = RenderObject.OBJECT_TYPE_OBJECT3D;
		var OBJECT_TYPE_SPRITE2D:UInt = RenderObject.OBJECT_TYPE_SPRITE2D;
		var OBJECT_TYPE_FOG_LAYER:UInt = RenderObject.OBJECT_TYPE_FOG_LAYER;

		var renderTypeController:Int = Render.renderTypeController;
		var RENDER_TYPE_MANUAL:Int = Render.RENDER_TYPE_MANUAL;
		var perspectiveCorrectEnabled:Bool = Render.perspectiveCorrectEnabled;

		// Backface culling
		var vbc0:V3d;
		var vbc1:V3d;
		var vbc2:V3d;
		var backFaceResult:Float;
		var isBackFace:Bool = false;

		// For each visible object
		for (i in 0...visibleObjectsLen)
		{
			currentRenderObject = visibleObjects[i];

			if (currentRenderObject.objectType == OBJECT_TYPE_OBJECT3D)
			{
				currentObject = visibleObjects[i].objObject3d;

				objectFacesCount = currentObject.faces.length;

				// For each face
				for (j in 0...objectFacesCount)
				{
					curFace = currentObject.faces[j];

					// Backface culling
					// First 3 vertices of current face
					vbc0 = currentObject.vertices[curFace.indices[0]];
					vbc1 = currentObject.vertices[curFace.indices[1]];
					vbc2 = currentObject.vertices[curFace.indices[2]];

					// Vectors va, vb, 0-1 1-2
					va.x = vbc0.x - vbc1.x;
					va.y = vbc0.y - vbc1.y;
					va.z = vbc0.z - vbc1.z;
					vb.x = vbc1.x - vbc2.x;
					vb.y = vbc1.y - vbc2.y;
					vb.z = vbc1.z - vbc2.z;

					// Face normal, cross product
					polyNormal.x = (va.y * vb.z) - (va.z * vb.y);
					polyNormal.y = (va.z * vb.x) - (va.x * vb.z);
					polyNormal.z = (va.x * vb.y) - (va.y * vb.x);

					// Camera - surface point vector
					viewVec.x = curCam.position.x - vbc1.x;
					viewVec.y = curCam.position.y - vbc1.y;
					viewVec.z = curCam.position.z - vbc1.z;

					// Check backface
					backFaceResult = (polyNormal.x * viewVec.x) + (polyNormal.y * viewVec.y) + (polyNormal.z * viewVec.z);

					// Check backface
					isBackFace = backFaceResult <= 0;

					if (!currentObject.bfCulling)
					{
						isBackFace = false;
					}
					if (isBackFace)
					{
						continue;
					}

					// Flat shading
					if (currentObject.flatShading)
					{
						// Light - surface point vector
						lightVec.x = curVp.lightPosition.x - vbc1.x;
						lightVec.y = curVp.lightPosition.y - vbc1.y;
						lightVec.z = curVp.lightPosition.z - vbc1.z;

						// Normal vector
						normVec.x = vbc1.x - (vbc1.x + polyNormal.x);
						normVec.y = vbc1.y - (vbc1.y + polyNormal.y);
						normVec.z = vbc1.z - (vbc1.z + polyNormal.z);

						// Vectors length
						var lvLen:Float = Math.sqrt(lightVec.x * lightVec.x + lightVec.y * lightVec.y + lightVec.z * lightVec.z);
						var normLen:Float = Math.sqrt(normVec.x * normVec.x + normVec.y * normVec.y + normVec.z * normVec.z);

						// Normalize vectors
						lightVec.x /= lvLen;
						lightVec.y /= lvLen;
						lightVec.z /= lvLen;
						normVec.x /= normLen;
						normVec.y /= normLen;
						normVec.z /= normLen;

						// Dot product
						var vectorsCos:Float = (lightVec.x * normVec.x + lightVec.y * normVec.y + lightVec.z * normVec.z) * -1;

						// Lighting koefficient
						lightingKoeff = curVp.lightPower / lvLen * vectorsCos;

						// Clamp
						if (lightingKoeff > 0.999)
						{
							lightingKoeff = 0.999;
						}
						if (lightingKoeff < 0.001)
						{
							lightingKoeff = 0.001;
						}
					}
					else
					{
						lightingKoeff = 0.999;
					}

					// Render faces pool
					if (polyCounter < rfacePool.poolArray.length)
					{
						// Get render face from pool
						curRface = rfacePool.poolArray[polyCounter];
					}
					else
					{
						// Create new render face
						curRface = rfacePool.poolArray[polyCounter] = new RFace();
					}

					curFaceMidpoint = currentObject.facesMidpoints[j];
					curFaceMidpointCopy.x = curFaceMidpoint.x;
					curFaceMidpointCopy.y = curFaceMidpoint.y;
					curFaceMidpointCopy.z = curFaceMidpoint.z;

					// Get average face z distance and add to array
					curCam.viewTransform(curFaceMidpointCopy);

					zmiddles[polyCounter] = curFaceMidpointCopy.z;

					curRface.obj3dRef = currentObject;			// Object reference
					curRface.faceNumber = j;					// Face index
					curRface.type = OBJECT_TYPE_OBJECT3D;
					curRface.shade = 1 - lightingKoeff;
					facesToDraw[polyCounter] = curRface;		// Add face to draw faces array

					polyCounter++;
				}

			}

			if (currentRenderObject.objectType == OBJECT_TYPE_SPRITE2D)
			{
				currentSprite = currentRenderObject.objSprite2d;
				currentSpriteCenter = currentSprite.position;

				currentSpriteCenterCopy.x = currentSpriteCenter.x;
				currentSpriteCenterCopy.y = currentSpriteCenter.y;
				currentSpriteCenterCopy.z = currentSpriteCenter.z;

				// View transform
				curCam.viewTransform(currentSpriteCenterCopy);

				// Projection
				currentSprite.projected.x = currentSpriteCenterCopy.x * curVp.focusLength / currentSpriteCenterCopy.z + curVp.viewportWidth * 0.5;
				currentSprite.projected.y = currentSpriteCenterCopy.y * curVp.focusLength / currentSpriteCenterCopy.z + curVp.viewportHeight * 0.5;

				zmiddles[polyCounter] = currentSpriteCenterCopy.z;

				// Render face pool
				if (polyCounter < rfacePool.poolArray.length)
				{
					curRface = rfacePool.poolArray[polyCounter];
				}
				else
				{
					curRface = rfacePool.poolArray[polyCounter] = new RFace();
				}

				curRface.type = OBJECT_TYPE_SPRITE2D;
				curRface.zDist = currentSpriteCenterCopy.z;
				curRface.spriteRef = currentSprite;

				facesToDraw[polyCounter] = curRface;
				polyCounter++;
			}

		}

		// Fog layers
		fogLayersLen = curVp.fogLayersArray.length;
		for (i in 0...fogLayersLen)
		{
			curFogLayer = curVp.fogLayersArray[i];
			zmiddles[polyCounter] = curFogLayer.z;

			// Render face pool
			if (polyCounter < rfacePool.poolArray.length)
			{
				curRface = rfacePool.poolArray[polyCounter];
			}
			else
			{
				curRface = rfacePool.poolArray[polyCounter] = new RFace();
			}

			zmiddles[polyCounter] = curFogLayer.z;	// Distance to camera
			curRface.type = OBJECT_TYPE_FOG_LAYER;
			curRface.fogLayerRef = curFogLayer;
			facesToDraw[polyCounter] = curRface;

			polyCounter++;
		}

		Debug.rtracestr("Poly Counter: " + polyCounter);
	}

	/**
	 * Background rendering
	 */
	private static function drawViewportBackground():Void
	{
		var curVpLoc:Viewport = Renderer.curVp;
		var curDrw:Graphics = curVpLoc.graphics;
		curDrw.clear();

		if (curVpLoc.backgroundMode == Viewport.BACKGROUND_MODE_NONE)
		{

		}
		if (curVpLoc.backgroundMode == Viewport.BACKGROUND_MODE_COLOR)
		{
			curDrw.beginFill(curVpLoc.backgroundColor, curVpLoc.backgroundAlpha);
			curDrw.drawRect(0, 0, curVpLoc.viewportWidth, curVpLoc.viewportHeight);
			curDrw.endFill();
		}
		if (curVpLoc.backgroundMode == Viewport.BACKGROUND_MODE_BITMAP)
		{
			curDrw.beginBitmapFill(curVpLoc.backgroundBitmap, null, true, false);
			curDrw.drawRect(0, 0, curVpLoc.viewportWidth, curVpLoc.viewportHeight);
			curDrw.endFill();
		}
	}

	/**
	 * Draw visible faces
	 */
	private static function drawFacesList():Void
	{
		// Ref
		var ls0:V2d = ls0_static, ls1:V2d = ls1_static, ls2:V2d = ls2_static;
		var lv0:V3d, lv1:V3d, lv2:V3d;
		var v0ind:Int, v1ind:Int, v2ind:Int;
		var sortedIndex:Int = 0;
		var curRface:RFace;
		var curface:Face;
		var curObject3d:Object3d;
		var curFaceIndicesLength:Int = 0;
		var curMatUVs:Vector<V2d>;
		var OBJECT_TYPE_OBJECT3D:UInt = RenderObject.OBJECT_TYPE_OBJECT3D;
		var OBJECT_TYPE_SPRITE2D:UInt = RenderObject.OBJECT_TYPE_SPRITE2D;
		var OBJECT_TYPE_FOG_LAYER:UInt = RenderObject.OBJECT_TYPE_FOG_LAYER;
		var dvNearPlane:Float = curCam.nearPlane;
		var focusLen:Float = curVp.focusLength;
		var halfWidth:Float = curVp.viewportWidth * 0.5;
		var halfHeight:Float = curVp.viewportHeight * 0.5;
		var texWidth:Int = 1;
		var texHeight:Int = 1;

		// Counter
		var drawnTriangleCount:Int = 0;

		// Sprites
		var curSprite:Sprite2d;
		var zcoord:Float;

		// z-clipping
		var coordZ_v:Int = 0;
		var v0Vis:Bool = true;
		var v1Vis:Bool = true;
		var v2Vis:Bool = true;

		// For each face
		for (i in 0...polyCounter)
		{
			sortedIndex = sortedIndexes[i]; // Face index
			curRface = facesToDraw[sortedIndex]; // Current render face (z sorted)

			if (curRface.type == OBJECT_TYPE_OBJECT3D)
			{
				curObject3d = curRface.obj3dRef;
				curface = curObject3d.faces[curRface.faceNumber];

				texWidth = curObject3d.material.btmd.width;
				texHeight = curObject3d.material.btmd.height;

				// For each triangle
				curFaceIndicesLength = curface.indices.length - 2;	// Number of faces
				for (j in 0...curFaceIndicesLength)
				{
					// Find absolute vertices indices
					v0ind = curface.indices[0];
					if (j == 0)
					{
						v1ind = curface.indices[1 + j];
						v2ind = curface.indices[2 + j];
					}
					else
					{
						v1ind = curface.indices[2 + j];
						v2ind = curface.indices[1 + j];
					}

					// Vertices references
					lv0 = curObject3d.vertices[v0ind];
					lv1 = curObject3d.vertices[v1ind];
					lv2 = curObject3d.vertices[v2ind];

					// Copy vertices
					lv0c.x = lv0.x; lv0c.y = lv0.y; lv0c.z = lv0.z;
					lv1c.x = lv1.x; lv1c.y = lv1.y; lv1c.z = lv1.z;
					lv2c.x = lv2.x; lv2c.y = lv2.y; lv2c.z = lv2.z;

					// UV coords
					curMatUVs = curObject3d.uvVertices;
					curUVFace = curObject3d.uvFaces[curRface.faceNumber]; // Current UV face

					// UV-coord indices
					uvind0 = curUVFace.indices[0];
					if (j == 0)
					{
						uvind1 = curUVFace.indices[1 + j];
						uvind2 = curUVFace.indices[2 + j];
					}
					else
					{
						uvind1 = curUVFace.indices[2 + j];
						uvind2 = curUVFace.indices[1 + j];
					}

					// Current UV vertices references
					luv0 = curMatUVs[uvind0];
					luv1 = curMatUVs[uvind1];
					luv2 = curMatUVs[uvind2];

					// Copy UV vertices
					uv0.x = luv0.x; uv0.y = luv0.y;
					uv1.x = luv1.x; uv1.y = luv1.y;
					uv2.x = luv2.x; uv2.y = luv2.y;

					// Transform copied vertices to camera space
					curCam.viewTransform3v(lv0c, lv1c, lv2c);

					// z-clipping for lineTo method
					v0Vis = true; v1Vis = true; v2Vis = true;
					coordZ_v = 0;

					// Count number of vertices behind projection plane
					if (lv0c.z < dvNearPlane) { coordZ_v++; v0Vis = false; }
					if (lv1c.z < dvNearPlane) { coordZ_v++; v1Vis = false; }
					if (lv2c.z < dvNearPlane) { coordZ_v++; v2Vis = false; }

					// If all vertices clipped by near plane
					if (coordZ_v >= 3) { continue; }

					// If one vertex located before projection plane
					// Recalculate vertex coords
					if (coordZ_v == 2)
					{
						// Vertex projection before clipping
						v0nzc.x = lv0c.x * focusLen / lv0c.z + halfWidth; v0nzc.y = lv0c.y * focusLen / lv0c.z + halfHeight;
						v1nzc.x = lv1c.x * focusLen / lv1c.z + halfWidth; v1nzc.y = lv1c.y * focusLen / lv1c.z + halfHeight;
						v2nzc.x = lv2c.x * focusLen / lv2c.z + halfWidth; v2nzc.y = lv2c.y * focusLen / lv2c.z + halfHeight;

						if (v0Vis)
						{
							ZClipping.recalculateTwoVertices(lv0c, lv1c, lv2c, 1, uv0, uv1, uv2, false, dvNearPlane, ext0, ext1);
						}
						else if (v1Vis)
						{
							ZClipping.recalculateTwoVertices(lv0c, lv1c, lv2c, 2, uv0, uv1, uv2, false, dvNearPlane, ext0, ext1);
						}
						else if (v2Vis)
						{
							ZClipping.recalculateTwoVertices(lv0c, lv1c, lv2c, 3, uv0, uv1, uv2, false, dvNearPlane, ext0, ext1);
						}
					}

					// If 2 vertices located before projection plane
					// Recalculate vertex coords to draw two triangles
					if (coordZ_v == 1)
					{
						// Vertex projection before clipping
						v0nzc.x = lv0c.x * focusLen / lv0c.z + halfWidth; v0nzc.y = lv0c.y * focusLen / lv0c.z + halfHeight;
						v1nzc.x = lv1c.x * focusLen / lv1c.z + halfWidth; v1nzc.y = lv1c.y * focusLen / lv1c.z + halfHeight;
						v2nzc.x = lv2c.x * focusLen / lv2c.z + halfWidth; v2nzc.y = lv2c.y * focusLen / lv2c.z + halfHeight;

						if ((v0Vis) && (v1Vis)) // v2 not visible
						{
							ZClipping.recalculateTwoVertices_TwoFaces(lv0c, lv1c, lv2c, lvs0c, lvs1c, lvs2c, 3, dvNearPlane, ext0, ext1);
						}
						else if ((v0Vis) && (v2Vis)) // v1 not visible
						{
							ZClipping.recalculateTwoVertices_TwoFaces(lv0c, lv1c, lv2c, lvs0c, lvs1c, lvs2c, 1, dvNearPlane, ext0, ext1);
						}
						else if ((v1Vis) && (v2Vis)) // v0 not visible
						{
							ZClipping.recalculateTwoVertices_TwoFaces(lv0c, lv1c, lv2c, lvs0c, lvs1c, lvs2c, 2, dvNearPlane, ext0, ext1);
						}
					}

					// Project
					ls0.x = lv0c.x * focusLen / lv0c.z + halfWidth; ls0.y = lv0c.y * focusLen / lv0c.z + halfHeight;
					ls1.x = lv1c.x * focusLen / lv1c.z + halfWidth; ls1.y = lv1c.y * focusLen / lv1c.z + halfHeight;
					ls2.x = lv2c.x * focusLen / lv2c.z + halfWidth; ls2.y = lv2c.y * focusLen / lv2c.z + halfHeight;

					if (coordZ_v == 1)
					{
						ls0s.x = lvs0c.x * focusLen / lvs0c.z + halfWidth; ls0s.y = lvs0c.y * focusLen / lvs0c.z + halfHeight;
						ls1s.x = lvs1c.x * focusLen / lvs1c.z + halfWidth; ls1s.y = lvs1c.y * focusLen / lvs1c.z + halfHeight;
						ls2s.x = lvs2c.x * focusLen / lvs2c.z + halfWidth; ls2s.y = lvs2c.y * focusLen / lvs2c.z + halfHeight;
					}

					// To draw triangle or not
					projVert0Vis = true;
					projVert1Vis = true;
					projVert2Vis = true;
					projTriVis = false;
					projTriCrossScr = false;

					// Find visible vertices
					if (((ls0.x < 0) || (ls0.x > curVp.viewportWidth)) || ((ls0.y < 0) || (ls0.y > curVp.viewportHeight))) projVert0Vis = false;
					if (((ls1.x < 0) || (ls1.x > curVp.viewportWidth)) || ((ls1.y < 0) || (ls1.y > curVp.viewportHeight))) projVert1Vis = false;
					if (((ls2.x < 0) || (ls2.x > curVp.viewportWidth)) || ((ls2.y < 0) || (ls2.y > curVp.viewportHeight))) projVert2Vis = false;

					// Check if triangle intersects screen
					if (!(projVert0Vis || projVert1Vis || projVert2Vis))
					{
						projTriCrossScr = RenderUtils.isTriangleCrossScreen(vpPointLeftUp, vpPointRightUp, vpPointRightDown, vpPointLeftDown, ls0, ls1, ls2);
					}
					projTriVis = projTriCrossScr || projVert0Vis || projVert1Vis || projVert2Vis;

					// Same as above, but for different case: one trianle split into two due to z clipping
					if (coordZ_v == 1)
					{
						projVert0VisTri2 = true;
						projVert1VisTri2 = true;
						projVert2VisTri2 = true;
						projTriVis2 = false;
						projTriCrossScr2 = false;

						if (((ls0s.x < 0) || (ls0s.x > curVp.viewportWidth)) || ((ls0s.y < 0) || (ls0s.y > curVp.viewportHeight))) projVert0VisTri2 = false;
						if (((ls1s.x < 0) || (ls1s.x > curVp.viewportWidth)) || ((ls1s.y < 0) || (ls1s.y > curVp.viewportHeight))) projVert1VisTri2 = false;
						if (((ls2s.x < 0) || (ls2s.x > curVp.viewportWidth)) || ((ls2s.y < 0) || (ls2s.y > curVp.viewportHeight))) projVert2VisTri2 = false;

						if (!(projVert0VisTri2 || projVert1VisTri2 || projVert2VisTri2))
						{
							projTriCrossScr2 = RenderUtils.isTriangleCrossScreen(vpPointLeftUp, vpPointRightUp, vpPointRightDown, vpPointLeftDown, ls0s, ls1s, ls2s);
						}
						projTriVis2 = projTriCrossScr2 || projVert0VisTri2 || projVert1VisTri2 || projVert2VisTri2;

					}

					// Calculate matrices for object rendering if at least one triangle is visible
					if (projTriVis || projTriVis2)
					{

						// UV - Matrix
						UVMatrix.tx = (uv0.x * texWidth) + almostZero;
						UVMatrix.ty = (uv0.y * texHeight) + almostZero;
						UVMatrix.a = (uv1.x - uv0.x) + almostZero;
						UVMatrix.b = (uv1.y - uv0.y) + almostZero;
						UVMatrix.c = (uv2.x - uv0.x) + almostZero;
						UVMatrix.d = (uv2.y - uv0.y) + almostZero;

						// Find image matrix
						if ((coordZ_v == 1) || (coordZ_v == 2))
						{
							imgMatrix.tx = v0nzc.x;
							imgMatrix.ty = v0nzc.y;
							imgMatrix.a = (v1nzc.x - v0nzc.x) / texWidth;
							imgMatrix.b = (v1nzc.y - v0nzc.y) / texWidth;
							imgMatrix.c = (v2nzc.x - v0nzc.x) / texHeight;
							imgMatrix.d = (v2nzc.y - v0nzc.y) / texHeight;
						}
						else
						{
							imgMatrix.tx = ls0.x;
							imgMatrix.ty = ls0.y;
							imgMatrix.a = (ls1.x - ls0.x) / texWidth;
							imgMatrix.b = (ls1.y - ls0.y) / texWidth;
							imgMatrix.c = (ls2.x - ls0.x) / texHeight;
							imgMatrix.d = (ls2.y - ls0.y) / texHeight;
						}

						// Invert UV matrix
						RenderUtils.invertMatrix(finalDrawingMatrix, UVMatrix, almostZero);

						// Concat matrices
						finalDrawingMatrix.concat(imgMatrix);
					}

					// Triangle rendering
					if (projTriVis)
					{
						drawnTriangleCount = RenderUtils.drawTriangle(curObject3d, ls0, ls1, ls2, curRface, finalDrawingMatrix, drawnTriangleCount);
					}

					// Second triangle after z clipping
					if (coordZ_v == 1 && projTriVis2)
					{
						drawnTriangleCount = RenderUtils.drawTriangle(curObject3d, ls0s, ls1s, ls2s, curRface, finalDrawingMatrix, drawnTriangleCount);
					}

				}

			}

			// Draw sprite
			if (curRface.type == OBJECT_TYPE_SPRITE2D)
			{
				curSprite = curRface.spriteRef;
				drawnTriangleCount = RenderUtils.drawSprite(curSprite, curRface, sprMatrix, drawnTriangleCount);
			}

			// Draw fog layer
			if (curRface.type == OBJECT_TYPE_FOG_LAYER && curVp.doDraw)
			{
				curFogLayer = curRface.fogLayerRef;
				curVp.graphics.beginFill(curRface.fogLayerRef.color, curRface.fogLayerRef.alpha);
				curVp.graphics.drawRect(curVp.x, curVp.y, curVp.viewportWidth, curVp.viewportHeight);
				drawnTriangleCount++;
			}

		}

		Debug.rtracestr("drawnTriangleCount: " + drawnTriangleCount);
	}

	/**
	 * Draw visible faces - perspective correct method (darw triangles)
	 */
	private static function drawFacesListCorrect():Void
	{
		var lv0:V3d, lv1:V3d, lv2:V3d;
		var v0ind:Int, v1ind:Int, v2ind:Int;
		var sortedIndex:Int = 0;
		var curRface:RFace;
		var curface:Face;
		var focusLen:Float = curVp.focusLength;
		var halfWidth:Float = curVp.viewportWidth * 0.5;
		var halfHeight:Float = curVp.viewportHeight * 0.5;
		var curObject3d:Object3d;
		var OBJECT_TYPE_OBJECT3D:UInt = RenderObject.OBJECT_TYPE_OBJECT3D;
		var OBJECT_TYPE_SPRITE2D:UInt = RenderObject.OBJECT_TYPE_SPRITE2D;
		var OBJECT_TYPE_FOG_LAYER:UInt = RenderObject.OBJECT_TYPE_FOG_LAYER;
		var dvNearPlane:Float = curCam.nearPlane;
		var drawnTriangleCount:Int = 0;

		// Sprites
		var curSprite:Sprite2d;
		var zcoord:Float;

		// Perspective correct method (draw triangles)
		var curMatUVs:Vector<V2d>;
		var curUVfacePC:Face;
		var curUVFaceIndice:Int = 0;
		var tValue:Float = 0;

		// z-clipping
		var coordZ_v:Int = 0;
		var v0Vis:Bool = true;
		var v1Vis:Bool = true;
		var v2Vis:Bool = true;

		// Draw triangles indices vec3 vec4
		var vec3:Vector<Int> = new Vector<Int>(3);
		vec3[0] = 0; vec3[1] = 1; vec3[2] = 2;

		var vec4:Vector<Int> = new Vector<Int>(6);
		vec4[0] = 0; vec4[1] = 1; vec4[2] = 2;
		vec4[3] = 0; vec4[4] = 2; vec4[5] = 3;

		// For each face
		for (i in 0...polyCounter)
		{
			sortedIndex = sortedIndexes[i]; // Face index
			curRface = facesToDraw[sortedIndex]; // Current render face (z sorting)

			if (curRface.type == OBJECT_TYPE_OBJECT3D)
			{
				curObject3d = curRface.obj3dRef;
				curface = curObject3d.faces[curRface.faceNumber];

				curMatUVs = curObject3d.uvVertices;					    // UV coords
				var indLen:Int = curface.indices.length;				// Vertices count

				curUVfacePC = curObject3d.uvFaces[curRface.faceNumber];	// UV faces

				projVerts.length = 0;									// Number of projected vertices
				uvtdata.length = 0;										// Current face
				curface = curObject3d.faces[curRface.faceNumber];

				// z clip
				var isCurrentFaceVisible:Bool = true; // If face fully visible
				var curUVFaceIndice0:Int = 0;
				var curUVFaceIndice1:Int = 0;
				var curUVFaceIndice2:Int = 0;
				var currentFaceVisible:Bool = false;

				// For each face vertex
				for (j in 0...indLen)
				{
					v0ind = curface.indices[j]; 				// Vertex index
					lv0 = curObject3d.vertices[v0ind]; 			// Vertex reference
					curUVFaceIndice = curUVfacePC.indices[j];	// UV vertex

					// Vertex copy
					lv0c.x = lv0.x; lv0c.y = lv0.y; lv0c.z = lv0.z;

					// View transform copied vertex
					curCam.viewTransform(lv0c);

					// Check vertex and near plane coords
					if (lv0c.z < dvNearPlane)
					{
						isCurrentFaceVisible = false;
					}

					v0Proj.x = lv0c.x * focusLen / lv0c.z + halfWidth;
					v0Proj.y = lv0c.y * focusLen / lv0c.z + halfHeight;

					// Check visibility
					if (currentFaceVisible == false)
					{
						// If in screen bounds
						if (((v0Proj.x > 0) && (v0Proj.x < curVp.viewportWidth)) && ((v0Proj.y > 0) && (v0Proj.y < curVp.viewportHeight)))
						{
							currentFaceVisible = true;
						}

						// Second check
						if (currentFaceVisible == false)
						{

							if (j == indLen - 1) { v0ind = curface.indices[0]; }
							else { v0ind = curface.indices[j + 1]; }

							// Second vertex
							lv1 = curObject3d.vertices[v0ind];
							lv1c.x = lv1.x; lv1c.y = lv1.y; lv1c.z = lv1.z;

							// View transform copied vertex
							curCam.viewTransform(lv1c);

							// Project
							v1Proj.x = lv1c.x * focusLen / lv1c.z + halfWidth;
							v1Proj.y = lv1c.y * focusLen / lv1c.z + halfHeight;

							if (RenderUtils.crossingTestRectangle(vpPointLeftUp, vpPointRightUp, vpPointRightDown, vpPointLeftDown, v0Proj, v1Proj))
							{
								currentFaceVisible = true;
							}
						}
					}

					// Visibility check completed
					// currentFaceVisible means face fully visible and no z clipping needed

					// z-coord (t-value)
					tValue = lv0c.z;

					// Save projection
					projVerts[projVerts.length] = v0Proj.x;
					projVerts[projVerts.length] = v0Proj.y;

					// Calculate uvt data for drawTriangles method
					uvtdata[uvtdata.length] = curMatUVs[curUVFaceIndice].x;
					uvtdata[uvtdata.length] = curMatUVs[curUVFaceIndice].y;

					var finalTvalue:Float = curVp.focusLength / (curVp.focusLength + tValue * tValueMult);

					uvtdata[uvtdata.length] = finalTvalue;
				}

				// Default rendering if face fully visible
				if (isCurrentFaceVisible)
				{

					if (currentFaceVisible)
					{
						drawnTriangleCount = RenderUtils.drawTrianglesCorrect(curObject3d, curRface, indLen, projVerts, vec3, vec4, uvtdata, TriangleCulling.NONE, drawnTriangleCount);
					}
				}

				else // z clipping for draw triangles method
				{

					var trianglesCount:Int = indLen - 2;	// Number of triangles

					// For each triangle
					for (j in 0...trianglesCount)
					{
						projVerts.length = 0;
						uvtdata.length = 0;

						// Absolute vertex indices
						v0ind = curface.indices[0];
						if (j == 0)
						{
							v1ind = curface.indices[1 + j];
							v2ind = curface.indices[2 + j];
						}
						else
						{
							v1ind = curface.indices[2 + j];
							v2ind = curface.indices[1 + j];
						}

						// UV face absolute indices
						curUVFaceIndice0 = curUVfacePC.indices[0];
						if (j == 0)
						{
							curUVFaceIndice1 = curUVfacePC.indices[1 + j];
							curUVFaceIndice2 = curUVfacePC.indices[2 + j];
						}
						else
						{
							curUVFaceIndice1 = curUVfacePC.indices[2 + j];
							curUVFaceIndice2 = curUVfacePC.indices[1 + j];
						}

						// UV coords
						uv0add = curMatUVs[curUVFaceIndice0];
						uv1add = curMatUVs[curUVFaceIndice1];
						uv2add = curMatUVs[curUVFaceIndice2];

						// UV copy
						uv0c.x = uv0add.x; uv0c.y = uv0add.y;
						uv1c.x = uv1add.x; uv1c.y = uv1add.y;
						uv2c.x = uv2add.x; uv2c.y = uv2add.y;

						// Vertices
						lv0 = curObject3d.vertices[v0ind];
						lv1 = curObject3d.vertices[v1ind];
						lv2 = curObject3d.vertices[v2ind];

						// Vertex copies
						lv0c.x = lv0.x; lv0c.y = lv0.y; lv0c.z = lv0.z;
						lv1c.x = lv1.x; lv1c.y = lv1.y; lv1c.z = lv1.z;
						lv2c.x = lv2.x; lv2c.y = lv2.y; lv2c.z = lv2.z;

						// View transform
						curCam.viewTransform3v(lv0c, lv1c, lv2c);

						// Check if vertex visible
						v0Vis = true;
						v1Vis = true;
						v2Vis = true;
						coordZ_v = 0;

						// Number of vertices behind projection plane
						if (lv0c.z < dvNearPlane)
						{
							coordZ_v++;
							v0Vis = false;
						}

						if (lv1c.z < dvNearPlane)
						{
							coordZ_v++;
							v1Vis = false;
						}

						if (lv2c.z < dvNearPlane)
						{
							coordZ_v++;
							v2Vis = false;
						}

						if (coordZ_v < 3)
						{

							// If one vertex before projection plane
							if (coordZ_v == 2)
							{
								if (v0Vis)
								{
									ZClipping.recalculateTwoVertices(lv0c, lv1c, lv2c, 1, uv0c, uv1c, uv2c, true, dvNearPlane, ext0, ext1);
								}
								else if (v1Vis)
								{
									ZClipping.recalculateTwoVertices(lv0c, lv1c, lv2c, 2, uv0c, uv1c, uv2c, true, dvNearPlane, ext0, ext1);
								}
								else if (v2Vis)
								{
									ZClipping.recalculateTwoVertices(lv0c, lv1c, lv2c, 3, uv0c, uv1c, uv2c, true, dvNearPlane, ext0, ext1);
								}
							}

							// If 2 vertices before projection plane
							if (coordZ_v == 1)
							{
								if ((v0Vis) && (v1Vis)) // v2 is not visible
								{
									ZClipping.recalculateTwoVertices_TwoFacesUV(lv0c, lv1c, lv2c, lvs0c, lvs1c, lvs2c, 3, uv0c, uv1c, uv2c, uv0cadd, uv1cadd, uv2cadd, true, dvNearPlane, ext0, ext1);
								}
								else if ((v0Vis) && (v2Vis)) // v1 not visible
								{
									ZClipping.recalculateTwoVertices_TwoFacesUV(lv0c, lv1c, lv2c, lvs0c, lvs1c, lvs2c, 1, uv0c, uv1c, uv2c, uv0cadd, uv1cadd, uv2cadd, true, dvNearPlane, ext0, ext1);
								}
								else if ((v1Vis) && (v2Vis)) // v0 not visible
								{
									ZClipping.recalculateTwoVertices_TwoFacesUV(lv0c, lv1c, lv2c, lvs0c, lvs1c, lvs2c, 2, uv0c, uv1c, uv2c, uv0cadd, uv1cadd, uv2cadd, true, dvNearPlane, ext0, ext1);
								}
							}

							// Project
							v0Proj.x = lv0c.x * focusLen / lv0c.z + halfWidth;
							v0Proj.y = lv0c.y * focusLen / lv0c.z + halfHeight;

							v1Proj.x = lv1c.x * focusLen / lv1c.z + halfWidth;
							v1Proj.y = lv1c.y * focusLen / lv1c.z + halfHeight;

							v2Proj.x = lv2c.x * focusLen / lv2c.z + halfWidth;
							v2Proj.y = lv2c.y * focusLen / lv2c.z + halfHeight;

							// If triangle visible
							projVert0Vis = true;
							projVert1Vis = true;
							projVert2Vis = true;
							projTriVis = false;
							projTriCrossScr = false;

							// Find visible vertices
							if (((v0Proj.x < 0) || (v0Proj.x > curVp.viewportWidth)) || ((v0Proj.y < 0) || (v0Proj.y > curVp.viewportHeight))) projVert0Vis = false;
							if (((v1Proj.x < 0) || (v1Proj.x > curVp.viewportWidth)) || ((v1Proj.y < 0) || (v1Proj.y > curVp.viewportHeight))) projVert1Vis = false;
							if (((v2Proj.x < 0) || (v2Proj.x > curVp.viewportWidth)) || ((v2Proj.y < 0) || (v2Proj.y > curVp.viewportHeight))) projVert2Vis = false;

							// Check if triangle intersects screen
							projTriCrossScr = RenderUtils.isTriangleCrossScreen(vpPointLeftUp, vpPointRightUp, vpPointRightDown, vpPointLeftDown, v0Proj, v1Proj, v2Proj);

							projTriVis = projTriCrossScr || projVert0Vis || projVert1Vis || projVert2Vis;

							if (projTriVis)
							{

								// Projected vertices for drawTriangles method
								projVerts[projVerts.length] = v0Proj.x;
								projVerts[projVerts.length] = v0Proj.y;
								projVerts[projVerts.length] = v1Proj.x;
								projVerts[projVerts.length] = v1Proj.y;
								projVerts[projVerts.length] = v2Proj.x;
								projVerts[projVerts.length] = v2Proj.y;

								// uvt data for drawTriangles method
								tValue = lv0c.z;
								uvtdata[uvtdata.length] = uv0c.x;
								uvtdata[uvtdata.length] = uv0c.y;
								uvtdata[uvtdata.length] = curVp.focusLength / (curVp.focusLength + tValue * tValueMult);

								tValue = lv1c.z;
								uvtdata[uvtdata.length] = uv1c.x;
								uvtdata[uvtdata.length] = uv1c.y;
								uvtdata[uvtdata.length] = curVp.focusLength / (curVp.focusLength + tValue * tValueMult);

								tValue = lv2c.z;
								uvtdata[uvtdata.length] = uv2c.x;
								uvtdata[uvtdata.length] = uv2c.y;
								uvtdata[uvtdata.length] = curVp.focusLength / (curVp.focusLength + tValue * tValueMult);

								drawnTriangleCount = RenderUtils.drawTrianglesCorrect(curObject3d, curRface, 3, projVerts, vec3, vec4, uvtdata, TriangleCulling.NONE, drawnTriangleCount);

							}

							projVerts.length = 0;
							uvtdata.length = 0;

							// Draw second triangle
							if (coordZ_v == 1)
							{

								v0Proj.x = lvs0c.x * focusLen / lvs0c.z + halfWidth;
								v0Proj.y = lvs0c.y * focusLen / lvs0c.z + halfHeight;

								v1Proj.x = lvs1c.x * focusLen / lvs1c.z + halfWidth;
								v1Proj.y = lvs1c.y * focusLen / lvs1c.z + halfHeight;

								v2Proj.x = lvs2c.x * focusLen / lvs2c.z + halfWidth;
								v2Proj.y = lvs2c.y * focusLen / lvs2c.z + halfHeight;

								// If triangle visible
								projVert0Vis = true;
								projVert1Vis = true;
								projVert2Vis = true;
								projTriVis = false;
								projTriCrossScr = false;

								// Find visible vertices
								if (((v0Proj.x < 0) || (v0Proj.x > curVp.viewportWidth)) || ((v0Proj.y < 0) || (v0Proj.y > curVp.viewportHeight))) projVert0Vis = false;
								if (((v1Proj.x < 0) || (v1Proj.x > curVp.viewportWidth)) || ((v1Proj.y < 0) || (v1Proj.y > curVp.viewportHeight))) projVert1Vis = false;
								if (((v2Proj.x < 0) || (v2Proj.x > curVp.viewportWidth)) || ((v2Proj.y < 0) || (v2Proj.y > curVp.viewportHeight))) projVert2Vis = false;

								// Check if triangle intersects screen
								projTriCrossScr = RenderUtils.isTriangleCrossScreen(vpPointLeftUp, vpPointRightUp, vpPointRightDown, vpPointLeftDown, v0Proj, v1Proj, v2Proj);

								projTriVis = projTriCrossScr || projVert0Vis || projVert1Vis || projVert2Vis;

								if (projTriVis)
								{
									// Projected vertices for drawTriangles method
									projVerts[projVerts.length] = v0Proj.x;
									projVerts[projVerts.length] = v0Proj.y;
									projVerts[projVerts.length] = v1Proj.x;
									projVerts[projVerts.length] = v1Proj.y;
									projVerts[projVerts.length] = v2Proj.x;
									projVerts[projVerts.length] = v2Proj.y;

									// uvt data for drawTriangles method
									tValue = lvs0c.z;
									uvtdata[uvtdata.length] = uv0cadd.x;
									uvtdata[uvtdata.length] = uv0cadd.y;
									uvtdata[uvtdata.length] = curVp.focusLength / (curVp.focusLength + tValue * tValueMult);

									tValue = lvs1c.z;
									uvtdata[uvtdata.length] = uv1cadd.x;
									uvtdata[uvtdata.length] = uv1cadd.y;
									uvtdata[uvtdata.length] = curVp.focusLength / (curVp.focusLength + tValue * tValueMult);

									tValue = lvs2c.z;
									uvtdata[uvtdata.length] = uv2cadd.x;
									uvtdata[uvtdata.length] = uv2cadd.y;
									uvtdata[uvtdata.length] = curVp.focusLength / (curVp.focusLength + tValue * tValueMult);

									drawnTriangleCount = RenderUtils.drawTrianglesCorrect(curObject3d, curRface, 3, projVerts, vec3, vec4, uvtdata, TriangleCulling.NONE, drawnTriangleCount);

								}

							}// end Draw second triangle

						}

					}

				}// end z clipping draw

			}

			// Draw sprite
			if (curRface.type == OBJECT_TYPE_SPRITE2D)
			{
				curSprite = curRface.spriteRef;
				drawnTriangleCount = RenderUtils.drawSprite(curSprite, curRface, sprMatrix, drawnTriangleCount);
			}

			// Draw fog layer
			if (curRface.type == OBJECT_TYPE_FOG_LAYER && curVp.doDraw)
			{
				curFogLayer = curRface.fogLayerRef;
				curVp.graphics.beginFill(curRface.fogLayerRef.color, curRface.fogLayerRef.alpha);
				curVp.graphics.drawRect(curVp.x, curVp.y, curVp.viewportWidth, curVp.viewportHeight);
				drawnTriangleCount++;
			}

		}

		Debug.rtracestr("drawnTriangleCount: " + drawnTriangleCount);
	}

	private static function drawLines():Void
	{
		var ls0:V2d = ls0_static, ls1:V2d = ls1_static, ls2:V2d = ls2_static;
		var lv0:V3d, lv1:V3d, lv2:V3d;
		var v0ind:Int, v1ind:Int, v2ind:Int;
		var curObject:RenderObject;
		var curLine3d:Line3d;
		var dvNearPlane:Float = curCam.nearPlane;
		var focusLen:Float = curVp.focusLength;
		var halfWidth:Float = curVp.viewportWidth * 0.5;
		var halfHeight:Float = curVp.viewportHeight * 0.5;
		var rayEndP:V3d = new V3d();

		// z-clipping
		var coordZ_v:Int = 0;
		var v0Vis:Bool = true;
		var v1Vis:Bool = true;
		var v2Vis:Bool = true;

		for (i in 0...visibleObjects.length)
		{
			curObject = visibleObjects[i];
			if (curObject.objectType != RenderObject.OBJECT_TYPE_LINE3D)
			{
				continue;
			}

			curLine3d = curObject.objLine3d;

			// Line position
			lv0 = curLine3d.position;

			//Direction or end position
			lv1 = curLine3d.direction;

			// Copy positions
			lv0c.x = lv0.x; lv0c.y = lv0.y; lv0c.z = lv0.z;
			lv1c.x = lv1.x; lv1c.y = lv1.y; lv1c.z = lv1.z;

			// Calculate end point if line type is 1 (ray)
			if (curLine3d.lineType == 1)
			{
				// Ray length
				lv1c.x *= curLine3d.length;
				lv1c.y *= curLine3d.length;
				lv1c.z *= curLine3d.length;

				// Ray end point
				lv1c.x = lv0c.x + lv1c.x;
				lv1c.y = lv0c.y + lv1c.y;
				lv1c.z = lv0c.z + lv1c.z;
			}

			// Transform copied position to camera space
			curCam.viewTransform(lv0c);
			curCam.viewTransform(lv1c);

			// z-clipping for lines
			v0Vis = true; v1Vis = true; v2Vis = true;
			coordZ_v = 0;

			// Count number of vertices behind projection plane
			if (lv0c.z < dvNearPlane) { coordZ_v++; v0Vis = false; }
			if (lv1c.z < dvNearPlane) { coordZ_v++; v1Vis = false; }

			// If all vertices clipped by near plane
			if (coordZ_v >= 2) { continue; }

			// If one vertex located before projection plane
			// Recalculate vertex coords
			if (coordZ_v == 1)
			{
				// Vertex projection before clipping
				v0nzc.x = lv0c.x * focusLen / lv0c.z + halfWidth; v0nzc.y = lv0c.y * focusLen / lv0c.z + halfHeight;
				v1nzc.x = lv1c.x * focusLen / lv1c.z + halfWidth; v1nzc.y = lv1c.y * focusLen / lv1c.z + halfHeight;

				if (v0Vis)
				{
					ZClipping.recalculateLine(lv0c, lv1c, 1, dvNearPlane, ext0, ext1);
				}
				else
				{
					ZClipping.recalculateLine(lv0c, lv1c, 2, dvNearPlane, ext0, ext1);
				}
			}

			// Project
			ls0.x = lv0c.x * focusLen / lv0c.z + halfWidth; ls0.y = lv0c.y * focusLen / lv0c.z + halfHeight;
			ls1.x = lv1c.x * focusLen / lv1c.z + halfWidth; ls1.y = lv1c.y * focusLen / lv1c.z + halfHeight;

			curVp.graphics.lineStyle(1, curLine3d.color, 1);
			curVp.graphics.moveTo(ls0.x, ls0.y);
			curVp.graphics.lineTo(ls1.x, ls1.y);
			curVp.graphics.drawRect(ls0.x - 2, ls0.y - 2, 4, 4);
		}
	}

	/**
	 * Clears all statistics data
	 */
	private static function clearStats():Void
	{
		// Counters
		polyCounter = 0;
		potentiallyVisibleObjects = 0;

		// Arrays, vars
		visibleSectors = [];
		visibleObjects = [];
		facesToDraw = [];
		zmiddles = [];
		sortedIndexes = [];
		visibleObjectsLen = 0;
	}

}