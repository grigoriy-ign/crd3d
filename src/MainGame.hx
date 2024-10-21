package;

import crd3d.debug.Debug;
import crd3d.display.Viewport;
import crd3d.displayobjects.Line3d;
import crd3d.displayobjects.Object3d;
import crd3d.geom.V2d;
import crd3d.geom.V3d;
import crd3d.math.Intersection;
import crd3d.render.Render;
import crd3d.render.Renderer;
import crd3d.scene.Camera;
import crd3d.scene.Scene;
import demo.DemoUtils;
import demo.game.MathUtils;
import demo.game.SceneBuilder;
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
import haxe.Timer;

/**
 * Room with FPS character and collision detection
 */
class MainGame
{

	private static var vport:Viewport;
	public static var scene:Scene;
	private static var camera:Camera;

	private static var mouseX:Float = 0;
	private static var mouseY:Float = 0;

	public static var screenBitmapData:BitmapData;
	public static var screenBitmap:Bitmap;

	private static var updateTime:Timer;

	// Array of room 3d objects
	private static var rooms:Array<Object3d> = new Array<Object3d>();

	private static var resx:Int = 1280;
	private static var resy:Int = 720;

	// Player camera direction ray
	private static var playerRay:Line3d;

	// Player movement data
	private static var moveVector:V2d = new V2d(0, 0);
	private static var moveSpeed:Float = 0;
	private static var camRotationSpeedMax:Float = 3;

	// Intersection result
	private static var intersection:Intersection = new Intersection();

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
		camera.nearPlane = 10;

		// Create viewport
		vport = new Viewport(Viewport.BACKGROUND_MODE_COLOR);
		vport.backgroundColor = 0x000000;
		vport.setSize(resx, resy);
		vport.renderingScene = scene;
		vport.viewCamera = camera;
		//vport.addFog(0x000000, 0.1, 0, 2000, 20);

		vport.drawWireframe = true;
		Renderer.wireframeColor = 0x000000;
		Render.perspectiveCorrectEnabled = false;

		// Set light
		vport.lightPosition = new V3d(0, 0, 0);
		vport.lightPower = 2000;

		//for (i in 0...100)
		//{
			//var line1:Line3d;
			//
			//line1 = new Line3d( new V3d( -400 + Math.random()*800, -100 + Math.random()*200, -400 + Math.random()*800),
			//new V3d(-400 + Math.random()*800, -100 + Math.random()*200, -400 + Math.random()*800), 1, 0 );
			//line1.color = Std.int( Math.random() * 0xffffff );
			//scene.addObject(line1);
		//}

		// Player camera direction ray
		playerRay = new Line3d( new V3d(0, 0, 0), new V3d(0, 0, 0), 1000, 1 );
		playerRay.color = 0xff0000;
		//scene.addObject(playerRay);

		// Create scene objects
		SceneBuilder.buildScene(scene, rooms);

		// Fixed resolution viewport
		screenBitmapData = new BitmapData(resx, resy);
		screenBitmap = new Bitmap();
		screenBitmap.bitmapData = screenBitmapData;
		stage.addChild(screenBitmap);

		// Events
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

		DemoUtils.traceInfo("Room demo");
		DemoUtils.traceControls();
		Debug.tracestr("");
		Debug.tracestr("WASD - Move");
		Debug.tracestr("Mouse - Look");
		Debug.tracestr("");
	}

	/**
	 * Frame update
	 */
	private static function enterFrame(e:Event):Void
	{
		DemoUtils.statsBegin();

		Render.renderViewport(vport);
		screenBitmapData.draw(vport);

		Debug.rtracestr("Mouse " + Std.int(mouseX) + " " + Std.int(mouseY));

		Debug.rtracestr("rz " + DemoUtils.formatFloat( camera.rotation.y, 2));

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

	/**
	 * Timer update
	 */
	private static function timerUpdate()
	{
		var mouseRelativeX:Float = mouseX / resx - 0.5;
		var mouseDirectionX:Float = 1;
		var newRotationY:Float = camera.rotation.y;
		var moveDirection:Float = 1;
		var moveDirRadians:Float = 0;
		moveSpeed = 0;

		if (isForwardPressed || isBackPressed || isLeftPressed || isRightPressed)
		{
			moveSpeed = 15;
		}

		// Movement direction
		if (isForwardPressed)
		{
			if (isLeftPressed) moveDirRadians -= Math.PI / 4;
			if (isRightPressed) moveDirRadians += Math.PI / 4;
		}
		else
		{
			if (isLeftPressed) moveDirRadians -= Math.PI / 2;
			if (isRightPressed) moveDirRadians += Math.PI / 2;
		}

		if (isBackPressed)
		{
			moveDirection = -1;
			moveDirRadians = Math.PI;

			if (isLeftPressed) moveDirRadians += Math.PI / 4;
			if (isRightPressed) moveDirRadians -= Math.PI / 4;
		}

		if (mouseRelativeX < 0)
		{
			mouseDirectionX = -1;
		}

		// Camera rotation
		var camRotationSpeed:Float = 0;
		if (Math.abs(mouseRelativeX) > 0.15)
		{
			camRotationSpeed = Math.abs(6 * (Math.abs(mouseRelativeX) - 0.15));

			if (camRotationSpeed > camRotationSpeedMax)
			{
				camRotationSpeed = camRotationSpeedMax;
			}

			newRotationY = camera.rotation.y + (camRotationSpeed * mouseDirectionX);
		}

		camera.setRotation(0, newRotationY, 0);

		MathUtils.rotationYToVector(moveVector, camera.radians.y + moveDirRadians);

		playerRay.direction.x = moveVector.y;
		playerRay.direction.y = 0;
		playerRay.direction.z = moveVector.x;

		// Check intersection with walls
		Intersection.getMeshIntersection(playerRay.position, playerRay.direction, SceneBuilder.room1collider, intersection);

		// Stop moving
		if (intersection.intersectDistance <= 100)
		{
			if (moveSpeed > 0) moveSpeed = 0;
		}

		// Push back
		if (intersection.intersectDistance <= 90)
		{
			if (moveSpeed > 0) moveSpeed = -1;
		}

		// Camera position
		var newCamX:Float = camera.position.x + (moveVector.y * moveSpeed);
		var newCamY:Float = camera.position.y;
		var newCamZ:Float = camera.position.z + (moveVector.x * moveSpeed);

		// Move camera
		camera.setPosition(newCamX, newCamY, newCamZ);

		playerRay.position.x = newCamX;
		playerRay.position.y = newCamY;
		playerRay.position.z = newCamZ;

		// Move light
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

	// Controls data
	public static var isForwardPressed:Bool = false;
	public static var isBackPressed:Bool = false;
	public static var isLeftPressed:Bool = false;
	public static var isRightPressed:Bool = false;

	/**
	 * Controls - key down
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
		if (ke.keyCode == Keyboard.A)
		{
			isLeftPressed = true;
		}
		if (ke.keyCode == Keyboard.D)
		{
			isRightPressed = true;
		}
	}

	/**
	 * Controls - key up
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
		if (ke.keyCode == Keyboard.A)
		{
			isLeftPressed = false;
		}
		if (ke.keyCode == Keyboard.D)
		{
			isRightPressed = false;
		}
	}

}