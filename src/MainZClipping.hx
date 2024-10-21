package;

import crd3d.display.Viewport;
import crd3d.displayobjects.Object3d;
import crd3d.displayobjects.RenderObject;
import crd3d.geom.V3d;
import crd3d.materials.Material;
import crd3d.parsing.EmbedObjParser;
import crd3d.render.Render;
import crd3d.scene.Camera;
import crd3d.scene.Scene;
import demo.DemoUtils;
import flash.Lib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.utils.ByteArray;

// Texture
@:bitmap("../res/checker.png")
class CheckerTex extends BitmapData { }

// Cube .obj
@:file("../res/cube.obj")
class CubeObj extends ByteArray { }

// Torus .obj
@:file("../res/torus.obj")
class TorusObj extends ByteArray { }

/**
 * Demo showcasing camera near plane clipping (z clipping)
 */
class MainZClipping
{
	private static var vport:Viewport;
	private static var scene:Scene;
	private static var camera:Camera;

	private static var object:Object3d;
	private static var torus:Object3d;
	private static var material:Material;
	private static var torusMaterial:Material;

	private static var rx:Float = 0;
	private static var ry:Float = 0;
	private static var rz:Float = 180;

	public static var screenBitmapData:BitmapData;
	public static var screenBitmap:Bitmap;

	private static var resx:Int = 1280;
	private static var resy:Int = 720;

	static function main()
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.SHOW_ALL;
		stage.align = StageAlign.TOP_LEFT;
		stage.quality = StageQuality.LOW;

		DemoUtils.initDebugTextField(stage);
		DemoUtils.initRealtimeTextField(stage);

		// Parse cube .obj
		var cubeObj:CubeObj = new CubeObj();
		var parsedCube3DObj:Object3d = EmbedObjParser.parse( cubeObj.toString() );

		// Parse torus .obj
		var torusObj:TorusObj = new TorusObj();
		var parsedTorus3DObj:Object3d = EmbedObjParser.parse( torusObj.toString() );

		// Load texture
		var checkerBitmap:Bitmap = new Bitmap(new CheckerTex(256, 256));
		var checkerBitmapData:BitmapData = checkerBitmap.bitmapData;

		// Create scene
		scene = new Scene();

		// Create camera
		camera = new Camera(0, 0, -350);
		camera.nearPlane = 950;

		// Create viewport
		vport = new Viewport(Viewport.BACKGROUND_MODE_COLOR);
		//stage.addChild(vport);
		vport.backgroundColor = 0x505050;
		vport.setSize(resx, resy);
		vport.renderingScene = scene;
		vport.viewCamera = camera;

		vport.drawWireframe = true;
		Render.perspectiveCorrectEnabled = true;

		// Add light
		vport.lightPosition = new V3d(500, 0, 0);
		vport.lightPower = 2000;

		// Create cube
		object = new Object3d();
		var objScale:Float = 200;
		object.loadModel(parsedCube3DObj, true);
		object.bfCulling = false;
		object.flatShading = true;
		object.setColor(255, 128, 128);

		object.setPosition(0, 50, 800);
		object.setScale(objScale, objScale, objScale);
		object.setRotation(0, 0, 0);

		// Add material
		material = new Material();
		material.btmd = checkerBitmapData;
		material.useTexture = true;
		object.material = material;

		// Add object to scene
		scene.addObject(object);

		// Create torus
		torus = new Object3d();
		var objScale:Float = 250;
		torus.loadModel(parsedTorus3DObj, true);
		torus.bfCulling = false;
		torus.flatShading = true;
		torus.setColor(50, 255, 50);

		torus.setPosition(0, 50, 800);
		torus.setScale(objScale, objScale, objScale);
		torus.setRotation(0, 0, 0);

		// Add material
		torusMaterial = new Material();
		torusMaterial.btmd = checkerBitmapData;
		torusMaterial.useTexture = false;
		torus.material = torusMaterial;

		// Add object to scene
		scene.addObject(torus);

		// Fixed resolution viewport
		screenBitmapData = new BitmapData(resx, resy);
		screenBitmap = new Bitmap();
		screenBitmap.bitmapData = screenBitmapData;
		stage.addChild(screenBitmap);

		stage.addEventListener(Event.ENTER_FRAME, enterFrame);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);

		stage.setChildIndex(DemoUtils.traceTF, stage.numChildren - 1);
		stage.setChildIndex(DemoUtils.traceTFRealtime, stage.numChildren - 1);

		DemoUtils.traceInfo("z clipping demo");
		DemoUtils.traceControls();
	}

	/**
	 * Rotate objects and render
	 */
	private static function enterFrame(e:Event):Void
	{
		DemoUtils.statsBegin();

		Render.renderViewport(vport);
		screenBitmapData.draw(vport);

		for (i in 0...scene.renderObjects.length)
		{
			var iobj:RenderObject = scene.renderObjects[i];
			var iobj3d = iobj.objObject3d;

			iobj3d.setRotation(rx, ry, rz);
		}

		rx += -15 * DemoUtils.deltaTime;
		ry += 20 * DemoUtils.deltaTime;
		rz += 10 * DemoUtils.deltaTime;

		DemoUtils.statsEnd();
	}

	/**
	 * Controls
	 */
	private static function keyDown(ke:KeyboardEvent):Void
	{
		DemoUtils.renderContolrs(ke, vport);
	}

}