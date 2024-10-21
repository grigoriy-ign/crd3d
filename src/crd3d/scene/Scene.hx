package crd3d.scene;

import crd3d.displayobjects.RenderObject;

class Scene
{

	public static inline var OBJECT_ACCESSORY_DYNAMIC:Int = -1;	// Objects accessibility type - dynamic
	public static inline var OBJECT_ACCESSORY_ENTIRE:Int = -2;	// Objects accessibility type - entire scene

	public var renderObjects:Array<RenderObject>; // Objects array
	public var sectorsArray:Array<Sector>;	// Sectors array

	public var lastId:Int = 0;

	public function new()
	{
		renderObjects = new Array();
		sectorsArray = new Array();
	}

	/**
	 * Adds an object to the scene (Object3d, Sprite2d or FogLayer)
	 */
	public function addObject(obj:Dynamic, accessory:Int = Scene.OBJECT_ACCESSORY_ENTIRE):Void
	{
		var rendObj:RenderObject = new RenderObject(obj.type);

		rendObj.id = lastId;

		if (obj.type == RenderObject.OBJECT_TYPE_FOG_LAYER)
		{
			rendObj.objFogLayer = obj;
			rendObj.objFogLayer.id = lastId;
			rendObj.objFogLayer.rendObjRef = rendObj;
		}
		if (obj.type == RenderObject.OBJECT_TYPE_SPRITE2D)
		{
			rendObj.objSprite2d = obj;
			rendObj.objSprite2d.id = lastId;
			rendObj.objSprite2d.rendObjRef = rendObj;
		}
		if (obj.type == RenderObject.OBJECT_TYPE_OBJECT3D)
		{
			rendObj.objObject3d = obj;
			rendObj.objObject3d.id = lastId;
			rendObj.objObject3d.rendObjRef = rendObj;
		}
		if (obj.type == RenderObject.OBJECT_TYPE_LINE3D)
		{
			rendObj.objLine3d = obj;
			rendObj.objLine3d.id = lastId;
			rendObj.objLine3d.rendObjRef = rendObj;
		}

		rendObj.accessory = obj.objectAccessory;
		renderObjects.push(rendObj);
		rendObj.rendObjRef = rendObj;

		lastId++;
	}

	/**
	 * Removes object from scene
	 */
	public function removeObject(obj:Dynamic)
	{
		var curObj:Dynamic;
		for (i in 0...renderObjects.length)
		{
			curObj = renderObjects[i];

			if (curObj == null)
			{
				continue;
			}

			if (curObj.id != obj.id)
			{
				continue;
			}

			renderObjects.remove(obj.rendObjRef);
		}
	}

	/**
	 * Adds sector to the scene
	 */
	public function addSector(sc:Sector):Void
	{
		sectorsArray.push(sc);
	}

}