package crd3d.displayobjects;

import crd3d.displayobjects.*;
import crd3d.scene.Scene;

class RenderObject
{

	// Object types
	public static inline var OBJECT_TYPE_EMPTY:UInt = 0;
	public static inline var OBJECT_TYPE_FOG_LAYER:UInt = 1;
	public static inline var OBJECT_TYPE_SPRITE2D:UInt = 2;
	public static inline var OBJECT_TYPE_OBJECT3D:UInt = 3;
	public static inline var OBJECT_TYPE_LINE3D:UInt = 4;

	public var objectType:UInt = OBJECT_TYPE_EMPTY; // Object type

	// Object references
	public var objObject3d:Object3d;
	public var objLine3d:Line3d;
	public var objSprite2d:Sprite2d;
	public var objFogLayer:FogLayer;

	public var visible:Bool = true; // Is object visible
	public var accessory:Int = Scene.OBJECT_ACCESSORY_ENTIRE; // Type of object accessibility - entire scene by default

	public var rendObjRef:RenderObject;
	public var id:Int = 0;

	public function new(type:UInt)
	{
		objectType = type;

		if (type == OBJECT_TYPE_FOG_LAYER)
		{
			objFogLayer = new FogLayer();
		}

		if (type == OBJECT_TYPE_SPRITE2D)
		{
			objSprite2d = new Sprite2d();
		}

		if (type == OBJECT_TYPE_OBJECT3D)
		{
			objObject3d = new Object3d();
		}

		if (type == OBJECT_TYPE_LINE3D)
		{
			objLine3d = new Line3d();
		}
	}

	/**
	 * Size of the object for frustum culling
	 */
	public inline function getRadiusSize():Float
	{
		var radiusSize:Float = 0;

		if (objectType == OBJECT_TYPE_OBJECT3D)
		{
			radiusSize = objObject3d.radiusSize;
		}

		return radiusSize;
	}

}