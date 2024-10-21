package crd3d.render;

import crd3d.display.Viewport;

class Render
{

	public static var renderTypeController:Int = 1;

	public static var RENDER_TYPE_MANUAL:Int = 1;

	public static var perspectiveCorrectEnabled:Bool = false;

	/**
	 * Renders viewport
	 */
	public static function renderViewport(vp:Viewport):Void
	{
		if (vp.renderMode == Viewport.RENDER_MODE_BASIC)
		{
			Renderer.render(vp);
		}

	}

}