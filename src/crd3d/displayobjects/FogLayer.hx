package crd3d.displayobjects;

/**
 * Fog layer
 */
class FogLayer
{

	public var type:UInt = RenderObject.OBJECT_TYPE_FOG_LAYER;

	public var color:UInt = 0x0;
	public var alpha:Float = 1.0;
	public var z:Float = 0;

	public var rendObjRef:RenderObject;
	public var id:Int = 0;

	public function new()
	{

	}

}