package demo.game;
import crd3d.geom.V2d;

class MathUtils
{

	/**
	 * Calculates 2D direction vector using rotation in radians
	 */
	public static function rotationYToVector(vector:V2d, rotationYRad:Float):Void
	{
		vector.x = Math.cos(rotationYRad);
		vector.y = Math.sin(rotationYRad);
	}

}