package crd3d.display;

import crd3d.displayobjects.FogLayer;
import crd3d.geom.V3d;
import crd3d.scene.Camera;
import crd3d.scene.Scene;
import flash.display.BitmapData;
import flash.display.Sprite;

/**
 * Viewport to render 3D scene with individual render settings. Multiple instances supported.
 */
class Viewport extends Sprite
{

	public static inline var RENDER_MODE_BASIC:UInt = 0;		// Render mode

	public static inline var BACKGROUND_MODE_NONE:UInt = 0;		// Background type - transparent
	public static inline var BACKGROUND_MODE_COLOR:UInt = 1;	// Background type - color
	public static inline var BACKGROUND_MODE_BITMAP:UInt = 2;	// Background type - image

	// Rendering
	public var renderMode:UInt = RENDER_MODE_BASIC;			// Default render mode
	public var renderingScene:Scene;						// Viewport scene
	public var viewCamera:Camera;							// Viewport camera
	public var drawWireframe:Bool = false;					// Is wireframe mode enabled
	public var currentCameraFov:Float = 0;					// Camera FOV for frustum culling
	public var frustumCullingEnable:Bool = true;			// Is frustum culling enabled

	// Viewport parameters
	public var backgroundMode:UInt = BACKGROUND_MODE_NONE;	// Background mode
	public var backgroundColor:UInt = 0x000000;				// Background color
	public var backgroundBitmap:BitmapData;					// Background image
	public var backgroundAlpha:UInt = 1;					// Background alpha
	public var viewportWidth:Int = 640;						// Width
	public var viewportHeight:Int = 480;					// Height
	public var focusLength:Float = 0;						// Focal length

	public var lightPower:Float = 1;						// Light intensity
	public var lightPosition:V3d = new V3d(0, 0, 0);		// Light position

	// Fog
	public var fogLayersArray:Array<FogLayer> = new Array(); // Fog layers array

	public var ca:Float = 0;
	public var cb:Float = 0;
	public var cc:Float = 0;
	public var fc:Float = 0;

	public var doDraw:Bool = true;

	public function new(bm:UInt = 0)
	{
		super();
		backgroundBitmap = new BitmapData(1, 1, false, 0x101010);
		backgroundMode = bm;
	}

	/**
	 * Sets width and height of viewport
	 */
	public function setSize(swidth:Int, sheight:Int):Void
	{
		viewportWidth = swidth;
		viewportHeight = sheight;
	}

	/**
	 * Adds new fog layer
	 */
	public function addFogLayer(fogColor:UInt, fogAlpha:Float, distance:Float):Void
	{
		var newFogLayer:FogLayer = new FogLayer();
		newFogLayer.color = fogColor;
		newFogLayer.alpha = fogAlpha;
		newFogLayer.z = distance;
		fogLayersArray.push(newFogLayer);
	}

	/**
	 * Adds fog to viewport
	 */
	public function addFog(fogColor:UInt, fogAlpha:Float, fogStart:Float, fogEnd:Float, fogLayersCount:Int):Void
	{
		var distanceBetweenLayers:Float = (fogEnd - fogStart) / fogLayersCount;
		for (i in 0...fogLayersCount)
		{
			addFogLayer(fogColor, fogAlpha, fogStart + (i * distanceBetweenLayers));
		}
	}

	/**
	 * Removes fog
	 */
	public function removeFog():Void
	{
		for (i in 0...fogLayersArray.length)
		{
			fogLayersArray[i] = null;
		}
		fogLayersArray = [];
	}

	public function hasFog():Bool
	{
		return fogLayersArray.length != 0;
	}

}