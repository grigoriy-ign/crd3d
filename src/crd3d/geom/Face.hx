package crd3d.geom;

import flash.Vector;

class Face
{
	
	public var indices:Vector<UInt>;
	
	public function new(inds:Array<Int>):Void
	{
		
		indices = new Vector<UInt>();
		for (i in 0...inds.length)
		{
			indices[i] = inds[i];
		}
	}

}