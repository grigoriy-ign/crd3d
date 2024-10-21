package crd3d.displayobjects;

import crd3d.geom.V2d;
import crd3d.geom.V3d;
import crd3d.scene.Scene;
import flash.display.BitmapData;
import Std;

class Sprite2d
{

	public var type:UInt = RenderObject.OBJECT_TYPE_SPRITE2D;

	public var position:V3d = new V3d(0, 0, 0);
	public var projected:V2d = new V2d(0, 0);

	public var bitmap:BitmapData;

	// Animation data
	public var animated:Bool = false;
	public var skipFrames:UInt = 0;
	public var curFrame:UInt = 0;

	public var scaleX:Float = 1;
	public var scaleY:Float = 1;

	// Frame size
	public var sizeX:Float = 128;
	public var sizeY:Float = 128;

	// Atlas size
	public var fullSizeX:Float = 256;
	public var fullSizeY:Float = 256;

	public var offsetX:Float = -64;
	public var offsetY:Float = -64;

	// Animation offsets
	public var stepX:UInt = 0;
	public var stepY:UInt = 0;

	private var stepXMax:UInt = 0;
	private var stepYMax:UInt = 0;

	private var i:UInt = 0;
	private var j:UInt = 0;

	public var rendObjRef:RenderObject;
	public var id:Int = 0;

	public var objectAccessory:Int = Scene.OBJECT_ACCESSORY_ENTIRE;

	public function new()
	{
		init();
	}

	public function init():Void
	{
		stepXMax = Std.int(fullSizeX / sizeX);
		stepYMax = Std.int(fullSizeY / sizeY);
	}

	/**
	 * Sets sprite size
	 */
	public function setSize(newSizeX:Float, newSizeY:Float)
	{
		sizeX = newSizeX;
		sizeY = newSizeY;
		offsetX = -newSizeX / 2;
		offsetY = -newSizeY / 2;
		setFullSize(newSizeX, newSizeY);
	}

	/**
	 * Sets atlas size
	 */
	public function setFullSize(newSizeX:Float, newSizeY:Float)
	{
		fullSizeX = newSizeX;
		fullSizeY = newSizeY;
	}

	/**
	 * Switches to random frame
	 */
	public function randomFrame():Void
	{
		stepX = Std.int(Math.random() * stepXMax);
		stepY = Std.int(Math.random() * stepYMax);
	}

	/**
	 * Sets sprite position
	 */
	public function setPosition(px:Float, py:Float, pz:Float):Void
	{
		position.x = px;
		position.y = py;
		position.z = pz;
	}

	/**
	 * Sets sprite scale
	 */
	public function setScale(newScaleX:Float, newScaleY:Float)
	{
		scaleX = newScaleX;
		scaleY = newScaleY;
	}

	/**
	 * Animates sprite
	 */
	public inline function animate():Void
	{
		if (curFrame >= skipFrames)
		{
			if (stepX < stepXMax - 1)
			{
				stepX++;
			}
			else
			{
				stepX = 0;
				if (stepY < stepYMax - 1)
				{
					stepY++;
				}
				else
				{
					stepY = 0;
				}
			}
			curFrame = 0;
		}
		curFrame++;
	}

}