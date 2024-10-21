package crd3d.render;

import crd3d.displayobjects.FogLayer;
import crd3d.displayobjects.Object3d;
import crd3d.displayobjects.Sprite2d;
import crd3d.geom.V2d;
import crd3d.geom.V3d;
import Std;

/**
 * RenderFace
 * Used to represent Face at rendering stage
 */

class RFace
{

	public var type:UInt = 0;			// Face type

	// 3D Object
	public var obj3dRef:Object3d;		// Object reference
	public var faceNumber:Int = -1;		// Face number
	public var zDist:Float = 0;			// Distance to camera
	public var shade:Float = 0;

	public var perspectiveCorrect:Bool = true;

	// 2D sprite
	public var spriteRef:Sprite2d;	// Sprite reference

	// Fog layer
	public var fogLayerRef:FogLayer; // Layer fog reference

	// Debug
	public var color:UInt = Std.int(Math.random() * 0xffffff);

	public function new():Void
	{

	}

}