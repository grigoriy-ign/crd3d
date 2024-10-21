package;

import crd3d.debug.Debug;
import crd3d.display.Viewport;
import crd3d.displayobjects.Object3d;
import crd3d.displayobjects.Sprite2d;
import crd3d.geom.V3d;
import crd3d.materials.Material;
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
import flash.utils.ByteArray;
import haxe.Timer;

// Textures
@:bitmap("../res/checker.png")
class CheckerTex extends BitmapData { }

@:bitmap("../res/terrain.png")
class TerrainTex extends BitmapData { }

@:bitmap("../res/snowflake.png")
class SnowflakeTex extends BitmapData { }

@:bitmap("../res/firework.png")
class FireworkTex extends BitmapData { }

@:bitmap("../res/fireworks_object.png")
class FireworksObjTex extends BitmapData { }

@:bitmap("../res/firework_anim.png")
class FireworkAnimTex extends BitmapData { }

// Objects
@:file("../res/terrain.obj")
class TerrainObj extends ByteArray { }

@:file("../res/fireworks_object.obj")
class FireworksObj extends ByteArray { }

/**
 * Animated sprite particles and fog rendering showcase
 */
class MainSprites
{
	private static var vport:Viewport;
	public static var scene:Scene;
	private static var camera:Camera;

	private static var terrain:Object3d;
	private static var terrainMaterial:Material;
	private static var fireworksObj3d:Object3d;
	private static var fireworksMaterial:Material;

	private static var snowflake:Sprite2d;

	private static var rx:Float = 0;
	private static var ry:Float = 0;
	private static var rz:Float = 180;

	private static var mouseX:Float = 0;
	private static var mouseY:Float = 0;

	private static var snowflakes:Array<Sprite2d> = new Array<Sprite2d>();

	public static var fireworkProjs:Array<FireworksProjectile> = new Array<FireworksProjectile>();
	private static var fireworkBitmapData:BitmapData;
	private static var fireworksBitmapData:BitmapData;
	private static var fireworkAnimBitmapData:BitmapData;

	private static var sceneSize:Float = 1000;

	private static var updateTime:Timer;

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

		DemoUtils.initDebugTextField(stage, 0x303030);
		DemoUtils.initRealtimeTextField(stage, 0x303030);

		// Parse objects
		var terrainObj:TerrainObj = new TerrainObj();
		var parsedTerrain3DObj:Object3d = EmbedObjParser.parse(terrainObj.toString());

		var fireworksObj:FireworksObj = new FireworksObj();
		var parsedFireworksObj3DObj:Object3d = EmbedObjParser.parse(fireworksObj.toString());

		// Load textures
		var terrainBitmap:Bitmap = new Bitmap(new TerrainTex(1024, 1024));
		var terrainBitmapData:BitmapData = terrainBitmap.bitmapData;

		var snowflakeBitmap:Bitmap = new Bitmap(new SnowflakeTex(32, 32));
		var snowflakeBitmapData:BitmapData = snowflakeBitmap.bitmapData;

		var fireworksBitmap:Bitmap = new Bitmap(new FireworksObjTex(512, 512));
		fireworksBitmapData = fireworksBitmap.bitmapData;

		var fireworkBitmap:Bitmap = new Bitmap(new FireworkTex(64, 64));
		fireworkBitmapData = fireworkBitmap.bitmapData;

		var fireworkAnimBitmap:Bitmap = new Bitmap(new FireworkAnimTex(192, 192));
		fireworkAnimBitmapData = fireworkAnimBitmap.bitmapData;

		// Create scene
		scene = new Scene();

		// Create camera
		camera = new Camera(0, 0, -350);
		camera.setFov(110);

		// Create viewport
		vport = new Viewport(Viewport.BACKGROUND_MODE_COLOR);
		vport.backgroundColor = 0xf2f1ed;
		vport.setSize( resx, resy);
		vport.renderingScene = scene;
		vport.viewCamera = camera;
		vport.addFog(0xe6f2ff, 0.1, 0, 2000, 20);

		vport.drawWireframe = false;
		Renderer.wireframeColor = 0x303030;
		Render.perspectiveCorrectEnabled = false;

		// Set light
		vport.lightPosition = new V3d(500, 0, 0);
		vport.lightPower = 2000;

		// Create terrain
		for (i in 0...2)
		{
			terrain = new Object3d();
			var objScale:Float = 1000;
			terrain.loadModel(parsedTerrain3DObj, true);
			terrain.bfCulling = false;
			terrain.flatShading = false;
			terrain.setColor(255, 128, 128);

			terrain.setPosition(-1000 + (i * 2000), 200, 400);
			terrain.setScale(objScale, objScale, objScale);
			terrain.setRotation(0, 0, 0);

			// Add material
			terrainMaterial = new Material();
			terrainMaterial.btmd = terrainBitmapData;
			terrainMaterial.useTexture = true;
			terrain.material = terrainMaterial;

			// Add object to scene
			scene.addObject(terrain);
		}

		// Create fireworks object
		fireworksObj3d = new Object3d();
		var objScale:Float = 30;
		fireworksObj3d.loadModel(parsedFireworksObj3DObj, true);
		fireworksObj3d.bfCulling = true;
		fireworksObj3d.flatShading = false;
		fireworksObj3d.setPosition(0, 150, 100);
		fireworksObj3d.setScale(objScale, objScale, objScale);
		fireworksObj3d.setRotation(0, 0, 180);

		// Add material
		fireworksMaterial = new Material();
		fireworksMaterial.btmd = fireworksBitmapData;
		fireworksMaterial.useTexture = true;
		fireworksObj3d.material = fireworksMaterial;

		// Add object to scene
		scene.addObject(fireworksObj3d);

		// Create snowflakes
		for (i in 0...1000)
		{
			snowflake = new Sprite2d();
			snowflake.bitmap = snowflakeBitmapData;
			snowflake.animated = false;
			snowflake.setPosition( -sceneSize + Math.random() * (sceneSize * 2), -sceneSize + Math.random() * (sceneSize * 2), -sceneSize + Math.random() * (sceneSize * 2));
			snowflake.setSize(32, 32);

			var snowflakeScale:Float = 0.15 + Math.random() * 0.15;
			snowflake.setScale(snowflakeScale, snowflakeScale);

			scene.addObject(snowflake);
			snowflakes.push(snowflake);
		}

		// Fixed resolution viewport
		screenBitmapData = new BitmapData(resx, resy);
		screenBitmap = new Bitmap();
		screenBitmap.bitmapData = screenBitmapData;
		stage.addChild(screenBitmap);

		// Events
		stage.addEventListener(Event.ENTER_FRAME, 		enterFrame);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, 	keyDown);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, 	onMouseMove);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, 	onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, 	onMouseUp);

		stage.setChildIndex(DemoUtils.traceTF, stage.numChildren - 1);
		stage.setChildIndex(DemoUtils.traceTFRealtime, stage.numChildren - 1);

		updateTime = new Timer(16);
		updateTime.run = timerUpdate;

		DemoUtils.traceInfo("Sprites demo");
		DemoUtils.traceControls();
		Debug.tracestr("");
		Debug.tracestr("Left mouse click - Fireworks");
	}

	/**
	 * Spawn new particle
	 */
	public static function spawnFirework(pos:V3d, isExplosive:Bool, newScale:Float = 1):FireworksProjectile
	{
		var fireworkSprite:Sprite2d = new Sprite2d();

		if (isExplosive)
		{
			// Main particle
			fireworkSprite.bitmap = fireworkAnimBitmapData;
			fireworkSprite.animated = true;
			fireworkSprite.skipFrames = 2;
			fireworkSprite.setSize(64, 64);
			fireworkSprite.setFullSize(192, 192);
		}
		else
		{
			// Child particle
			fireworkSprite.bitmap = fireworkBitmapData;
			fireworkSprite.animated = false;
			fireworkSprite.setSize(64, 64);
		}

		fireworkSprite.setPosition(pos.x, pos.y, pos.z);
		fireworkSprite.setScale(newScale, newScale);

		var proj:FireworksProjectile = new FireworksProjectile(fireworkSprite, isExplosive);

		fireworkProjs.push(proj);

		scene.addObject(fireworkSprite);

		return proj;
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

		var mouseRelativeX:Float = mouseX / resx - 0.5;
		var mouseRelativeY:Float = mouseY / resy - 0.5;

		camera.position.x = mouseRelativeX * 500;
		camera.position.z = -500 - mouseRelativeY * 100;
		camera.setRotation( 0, -mouseRelativeX * 40, 0);

		DemoUtils.statsEnd();
	}

	/**
	 * Update particles
	 */
	private static function timerUpdate()
	{
		var snowflakePos:V3d = snowflake.position;

		// Update snowflakes
		for (i in 0...snowflakes.length)
		{
			snowflake = snowflakes[i];
			snowflakePos = snowflake.position;

			snowflakePos.x += .2;
			snowflakePos.y += 20 * snowflake.scaleX;
			snowflakePos.z += -2;

			if (snowflakePos.y > 210)
			{
				snowflake.setPosition( -sceneSize + Math.random() * (sceneSize * 2), -500 - Math.random() * 200, -sceneSize + Math.random() * (sceneSize * 2));
			}
		}

		// Update fireworks
		var fireworkProj:FireworksProjectile;
		for (i in 0...fireworkProjs.length)
		{
			fireworkProj = fireworkProjs[i];
			if (fireworkProj == null)
			{
				continue;
			}

			fireworkProj.update();
		}
	}

	private static function onMouseMove(e:MouseEvent):Void
	{
		mouseX = e.stageX;
		mouseY = e.stageY;
	}

	/**
	 * Spawn new particle on mouse click
	 */
	private static function onMouseDown(e:MouseEvent):Void
	{
		var fireworkProj:FireworksProjectile;
		fireworkProj = spawnFirework(new V3d(0, 180, 100), true, 2);

		var speedSideX:Float = -5 + Math.random() * 10;
		var speedSideZ:Float = -5 + Math.random() * 10;
		var speedY:Float = -17 - Math.random() * 3;

		fireworkProj.setSpeed(speedSideX, speedY, speedSideZ);
	}

	private static function onMouseUp(e:MouseEvent):Void
	{

	}

	/**
	 * Controls
	 */
	private static function keyDown(ke:KeyboardEvent):Void
	{
		DemoUtils.renderContolrs(ke, vport);
	}

}

/**
 * Fireworks particle
 */
class FireworksProjectile
{

	public var spriteRef:Sprite2d;
	public var speedVector:V3d;
	public var isExplosive:Bool = false;
	public var explosionCounter:Float = 0;
	public var explosionLimit:Float = 0;

	/**
	 * Update particle
	 */
	public function update()
	{
		var spritePos:V3d = spriteRef.position;

		// Update position
		spritePos.x += speedVector.x;
		spritePos.y += speedVector.y;
		spritePos.z += speedVector.z;

		speedVector.y += 0.4;

		explosionCounter++;

		// Main particle explosion
		if (explosionCounter > explosionLimit && isExplosive)
		{

			var childrenCount:Int = 10;

			// Spawn children particles
			for (i in 0...childrenCount)
			{
				var fireworkProj:FireworksProjectile;
				var newScale:Float = 0.3 + Math.random() * 0.2;
				fireworkProj = MainSprites.spawnFirework(spriteRef.position, false, newScale);

				var speedSideX:Float = -5 + Math.random() * 10;
				var speedSideZ:Float = -5 + Math.random() * 10;
				var speedY:Float = -5 + Math.random() * 10;

				speedSideX += speedVector.x;
				speedSideZ += speedVector.z;
				speedY += speedVector.y;

				fireworkProj.setSpeed(speedSideX, speedY, speedSideZ);
			}

			remove();
		}

		if (spritePos.y > 200)
		{
			remove();
		}
	}

	public function new(newSprite:Sprite2d, explosive = false)
	{
		spriteRef = newSprite;
		speedVector = new V3d();
		isExplosive = explosive;

		explosionLimit = 30 + Math.random() * 30;
	}

	public function setSpeed(nx:Float, ny:Float, nz:Float)
	{
		speedVector.x = nx;
		speedVector.y = ny;
		speedVector.z = nz;
	}

	public function remove()
	{
		MainSprites.scene.removeObject(this.spriteRef);
		MainSprites.fireworkProjs.remove(this);
	}

}