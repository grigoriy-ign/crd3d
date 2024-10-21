package demo;

import crd3d.debug.Debug;
import crd3d.display.Viewport;
import crd3d.render.Render;
import crd3d.render.Renderer;
import flash.events.KeyboardEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.ui.Keyboard;
import haxe.Timer;

class DemoUtils
{

	public static var traceTF:TextField;
	public static var traceTFRealtime:TextField;

	public static var stampCurrent:Float = 0;
	public static var stampPrev:Float = 0;
	public static var stampLast:Float = 0;
	public static var fps:Float = 0;
	public static var fpsCounter = 0;
	public static var deltaTime:Float = 0;

	/*
	 * Demo stats and counters
	 */
	public static function statsBegin():Void
	{
		stampPrev = Timer.stamp();

		Debug.rclear();
		Debug.rtracestr(Std.int(fps) + " - FPS");

		deltaTime = (stampPrev - stampCurrent);

		if ( stampCurrent - stampLast >= 1.0 )
		{
			stampLast = Timer.stamp();
			fps = fpsCounter;
			fpsCounter = 0;
		}
	}

	/*
	 * Demo stats and counters
	 */
	public static function statsEnd():Void
	{
		stampCurrent = Timer.stamp();
		fpsCounter++;

		Debug.updateRealtimeStr();
	}

	/*
	 * Toggles render settings
	 */
	public static function renderContolrs(ke:KeyboardEvent, vport:Viewport):Void
	{
		if (ke.keyCode == Keyboard.F1)
		{
			traceTF.visible = !traceTF.visible;
			traceTFRealtime.visible = !traceTFRealtime.visible;
		}
		if (ke.keyCode == Keyboard.F2)
		{
			vport.drawWireframe = !vport.drawWireframe;
		}
		if (ke.keyCode == Keyboard.F3)
		{
			Render.perspectiveCorrectEnabled = !Render.perspectiveCorrectEnabled;
		}
		if (ke.keyCode == Keyboard.F4)
		{
			Renderer.drawColliderMode = ! Renderer.drawColliderMode;
		}
	}

	/*
	 * Traces info
	 */
	public static function traceInfo(title:String):Void
	{
		Debug.tracestr(title);
		Debug.tracestr("");
	}

	/*
	 * Traces controls info
	 */
	public static function traceControls():Void
	{
		Debug.tracestr("F1 - GUI");
		Debug.tracestr("F2 - Wireframe");
		Debug.tracestr("F3 - Rendering method");
		Debug.tracestr("F4 - Draw Colliders");
	}

	/**
	 * Formats float number
	 */
	public static function formatFloat(number:Float, precision:Int):String
	{
		var strNumber:String = Std.string(number);
		var strNumSplit:Array<String> = strNumber.split(".");
		var strResult:String = strNumSplit[0];

		if (strNumSplit.length > 1)
		{
			strResult += "." + strNumSplit[1].substr(0, precision);
		}

		return strResult;
	}

	/*
	 * Demo debug text field
	 */
	public static function initDebugTextField(stage, textColor = 0xffffff):TextField
	{
		traceTF = new TextField();
		traceTF.width = 300;
		traceTF.height = 720;
		traceTF.textColor = textColor;
		traceTF.border = false;
		traceTF.borderColor = 0x30ff30;
		traceTF.selectable = false;
		var tf:TextFormat = new TextFormat("verdana", 10);
		traceTF.defaultTextFormat = tf;
		traceTF.setTextFormat(tf);
		traceTF.mouseEnabled = false;
		traceTF.selectable = false;
		stage.addChild(traceTF);
		Debug.targetTF = traceTF;

		return traceTF;
	}

	/*
	 * Demo debug text field
	 */
	public static function initRealtimeTextField(stage, textColor = 0xffffff):TextField
	{
		traceTFRealtime = new TextField();
		traceTFRealtime.width = 300;
		traceTFRealtime.height = 720;
		traceTFRealtime.x = 1280 - 300;
		traceTFRealtime.textColor = textColor;
		traceTFRealtime.border = false;
		traceTFRealtime.borderColor = 0x30ff30;
		traceTFRealtime.selectable = false;
		var tf:TextFormat = new TextFormat("verdana", 10);
		tf.align = TextFormatAlign.RIGHT;
		traceTFRealtime.defaultTextFormat = tf;
		traceTFRealtime.setTextFormat(tf);
		traceTFRealtime.mouseEnabled = false;
		traceTFRealtime.selectable = false;
		stage.addChild(traceTFRealtime);
		Debug.targetRealtimeTF = traceTFRealtime;

		return traceTFRealtime;
	}

}