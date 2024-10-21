package demo.game;

import crd3d.displayobjects.Object3d;
import crd3d.materials.Material;
import crd3d.parsing.EmbedObjParser;
import crd3d.scene.Scene;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.utils.ByteArray;

// Objects
@:file("../res/game/room1.obj")
class Room1Obj extends ByteArray { }
@:file("../res/game/room1_collider.obj")
class Room1ColliderObj extends ByteArray { }

// Textures
@:bitmap("../res/game/room1.png")
class Room1Tex extends BitmapData { }

class SceneBuilder
{

	public static var room1collider:Object3d;

	public static function buildScene(scene:Scene, rooms:Array<Object3d>):Void
	{
		var objScale:Float = 100;

		// Room 1
		var roomObj:Room1Obj = new Room1Obj();
		var roomColliderObj:Room1ColliderObj = new Room1ColliderObj();

		var parsedRoomObj:Object3d = EmbedObjParser.parse(roomObj.toString());
		var parsedRoomColliderObj:Object3d = EmbedObjParser.parse(roomColliderObj.toString());

		var room1Bitmap:Bitmap = new Bitmap(new Room1Tex(512, 512));
		var room1BitmapData:BitmapData = room1Bitmap.bitmapData;

		var room1:Object3d = new Object3d();
		room1.loadModel(parsedRoomObj, true);
		room1.bfCulling = true;
		room1.flatShading = false;
		room1.setColor(128, 128, 128);
		room1.setPosition(0, 100, 0);
		room1.setScale(objScale, objScale, objScale);
		room1.setRotation(0, 0, 180);

		room1collider = new Object3d();
		room1collider.loadModel(parsedRoomColliderObj, true);
		room1collider.bfCulling = true;
		room1collider.flatShading = false;
		room1collider.setColor(128, 200, 128);
		room1collider.setPosition(0, 100, 0);
		room1collider.setScale(objScale, objScale, objScale);
		room1collider.setRotation(0, 0, 180);
		room1collider.isCollider = true;

		// Add material
		var roomMaterial = new Material();
		roomMaterial.btmd = room1BitmapData;
		roomMaterial.useTexture = true;
		room1.material = roomMaterial;

		var roomMaterialCollider = new Material();
		//roomMaterialCollider.btmd = room1BitmapData;
		roomMaterialCollider.useTexture = false;
		room1collider.material = roomMaterialCollider;

		// Add object to scene
		scene.addObject(room1);
		scene.addObject(room1collider);

		rooms.push(room1);
	}

}