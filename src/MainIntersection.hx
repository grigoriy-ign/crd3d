package;

import crd3d.debug.Debug;
import crd3d.display.Viewport;
import crd3d.displayobjects.Line3d;
import crd3d.displayobjects.Object3d;
import crd3d.geom.V2d;
import crd3d.geom.V3d;
import crd3d.materials.Material;
import crd3d.math.Intersection;
import crd3d.parsing.EmbedObjParser;
import crd3d.render.Render;
import crd3d.render.Renderer;
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
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.utils.ByteArray;
import haxe.Timer;

@:file("../res/monkey.obj")
class TriangleObj extends ByteArray { }

/**
 * Demo showcasing ray-object intersection check
 */
class MainIntersection
{

	private static var vport:Viewport;
	public static var scene:Scene;
	private static var camera:Camera;

	private static var mouseX:Float = 0;
	private static var mouseY:Float = 0;

	public static var screenBitmapData:BitmapData;
	public static var screenBitmap:Bitmap;

	private static var updateTime:Timer;

	private static var resx:Int = 1280;
	private static var resy:Int = 720;

	private static var triangle:Object3d = new Object3d();
	private static var raycastRay:Line3d;

	static function main()
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.SHOW_ALL;
		stage.align = StageAlign.TOP_LEFT;
		stage.quality = StageQuality.LOW;

		DemoUtils.initDebugTextField(stage, 0xeeeeee);
		DemoUtils.initRealtimeTextField(stage, 0xeeeeee);

		// Create scene
		scene = new Scene();

		// Create camera
		camera = new Camera(0, 0, -350);
		camera.setFov(100);

		// Create viewport
		vport = new Viewport(Viewport.BACKGROUND_MODE_COLOR);
		vport.backgroundColor = 0x000000;
		vport.setSize(resx, resy);
		vport.renderingScene = scene;
		vport.viewCamera = camera;

		vport.drawWireframe = true;
		Renderer.wireframeColor = 0xffffff;
		Render.perspectiveCorrectEnabled = false;

		// Set light
		vport.lightPosition = new V3d(0, 0, 0);
		vport.lightPower = 2000;

		var objScale:Float = 100;

		// Object to test intersections (triangulation is required)
		var triObj:TriangleObj = new TriangleObj();
		var parsedtriObj:Object3d = EmbedObjParser.parse(triObj.toString());

		// Load model and setup
		triangle.loadModel(parsedtriObj, true);
		triangle.bfCulling = true;
		triangle.flatShading = false;
		triangle.setColor(128, 128, 128);
		triangle.setPosition(0, 0, 0);
		triangle.setScale(objScale, objScale, objScale);
		triangle.setRotation(90, 0, 0);

		// Add material
		var triMaterial = new Material();
		triMaterial.useTexture = false;
		triangle.material = triMaterial;

		scene.addObject(triangle);

		raycastRay = new Line3d( new V3d(0, 0, -100), new V3d(0, 0, 1), 1000, 1 );
		raycastRay.color = 0xffffff;
		scene.addObject(raycastRay);

		debugRay0 = new Line3d( new V3d(0, 0, 0), new V3d(0, 1, 0), 1, 1 );
		debugRay0.color = 0xffffff;
		scene.addObject(debugRay0);

		// Fixed resolution viewport
		screenBitmapData = new BitmapData(resx, resy);
		screenBitmap = new Bitmap();
		screenBitmap.bitmapData = screenBitmapData;
		stage.addChild(screenBitmap);

		stage.addEventListener(Event.ENTER_FRAME, 		enterFrame);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, 	keyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, 	keyUp);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, 	onMouseMove);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, 	onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, 	onMouseUp);

		stage.setChildIndex(DemoUtils.traceTF, stage.numChildren - 1);
		stage.setChildIndex(DemoUtils.traceTFRealtime, stage.numChildren - 1);

		updateTime = new Timer(16);
		updateTime.run = timerUpdate;

		DemoUtils.traceInfo("Intersection demo");
		DemoUtils.traceControls();
		Debug.tracestr("");
		Debug.tracestr("W, S - Rotate");
		Debug.tracestr("Mouse - Move");
		Debug.tracestr("");
	}

	private static var edge0:Line3d;
	private static var edge1:Line3d;
	private static var debugRay0:Line3d;

	/**
	 * Frame update
	 */
	private static function enterFrame(e:Event):Void
	{
		DemoUtils.statsBegin();

		var mouseRelativeX:Float = mouseX / resx - 0.5;
		var mouseRelativeY:Float = mouseY / resy - 0.5;
		var mouseDirectionX:Float = 1;

		if (mouseRelativeX < 0)
		{
			mouseDirectionX = -1;
		}

		// Update mesh position
		triangle.setPosition(mouseRelativeX * 500, mouseRelativeY * 500, 0);

		// Test intersection
		Intersection.getMeshIntersection(raycastRay.position, raycastRay.direction, triangle, intersection);

		if (intersection.isIntersect)
		{
			triangle.setColor(0, 128, 0);
		}
		else
		{
			triangle.setColor(128, 0, 0);
		}

		Render.renderViewport(vport);
		screenBitmapData.draw(vport);

		Debug.rtracestr("Mouse " + Std.int(mouseX) + " " + Std.int(mouseY));

		Debug.rtracestr("\n");
		Debug.rtracestr("=== Intersection ===");
		Debug.rtracestr( intersection.isIntersect + " isIntersect" );
		Debug.rtracestr( intersection.intersectionCount + " intersectionCount" );
		Debug.rtracestr( DemoUtils.formatFloat( intersection.intersectDistance, 2) + " intersectDistance");
		Debug.rtracestr( DemoUtils.formatFloat( intersection.intersectPoint.x, 2) + " Point x");
		Debug.rtracestr( DemoUtils.formatFloat( intersection.intersectPoint.y, 2) + " Point y");
		Debug.rtracestr( DemoUtils.formatFloat( intersection.intersectPoint.z, 2) + " Point z");

		DemoUtils.statsEnd();
	}

	// Object movement
	private static var moveVector:V2d = new V2d(0, 0);
	private static var moveSpeed:Float = 0;
	private static var camRotationSpeedMax:Float = 3;

	// Intersection result
	private static var intersection:Intersection = new Intersection();

	// Rotation
	private static var rx:Float = 0;
	private static var ry:Float = 0;
	private static var rz:Float = 0;

	private static function timerUpdate()
	{
		var mouseRelativeX:Float = mouseX / resx - 0.5;
		var mouseDirectionX:Float = 1;

		// Update object rotation

		moveSpeed = 0;
		if (isForwardPressed)
		{
			moveSpeed = 15;
		}
		if (isBackPressed)
		{
			moveSpeed = -15;
		}

		if (mouseRelativeX < 0)
		{
			mouseDirectionX = -1;
		}

		rx += -15 * DemoUtils.deltaTime;
		ry += 20 * DemoUtils.deltaTime;
		rz += 10 * DemoUtils.deltaTime;

		var triangleRot:Float = triangle.rotation.y + moveSpeed;
		triangle.setRotation(rx, triangleRot, rz);

		vport.lightPosition = camera.position;
	}

	private static function onMouseMove(e:MouseEvent):Void
	{
		mouseX = e.stageX;
		mouseY = e.stageY;
	}

	private static function onMouseDown(e:MouseEvent):Void
	{

	}

	private static function onMouseUp(e:MouseEvent):Void
	{

	}

	public static var isForwardPressed:Bool = false;
	public static var isBackPressed:Bool = false;

	/**
	 * Controls
	 */
	private static function keyDown(ke:KeyboardEvent):Void
	{
		DemoUtils.renderContolrs(ke, vport);

		if (ke.keyCode == Keyboard.W)
		{
			isForwardPressed = true;
		}
		if (ke.keyCode == Keyboard.S)
		{
			isBackPressed = true;
		}
	}

	/**
	 * Controls
	 */
	private static function keyUp(ke:KeyboardEvent):Void
	{

		if (ke.keyCode == Keyboard.W)
		{
			isForwardPressed = false;
		}
		if (ke.keyCode == Keyboard.S)
		{
			isBackPressed = false;
		}
	}

}