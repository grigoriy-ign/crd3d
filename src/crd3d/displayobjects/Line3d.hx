package crd3d.displayobjects;

import crd3d.geom.V3d;
import crd3d.scene.Scene;

/**
 * 3D Line/ray object
 */
class Line3d
{

	public var type:UInt = RenderObject.OBJECT_TYPE_LINE3D;

	public var position:V3d;

	// End point position for line type or
	// direction for ray type
	public var direction:V3d;
	public var length:Float = 0;

	public var lineType:Int = 0; // Line type, 0 - line, 1 - ray

	public var rendObjRef:RenderObject;
	public var id:Int = 0;

	public var color:UInt = 0xffffff;

	public var objectAccessory:Int = Scene.OBJECT_ACCESSORY_ENTIRE;

	public function new( newPos:V3d = null, newDir:V3d = null, newLen:Float = 0, newLineType:Int = 0 )
	{
		position = newPos;
		direction = newDir;
		length = newLen;

		lineType = newLineType;
	}

}