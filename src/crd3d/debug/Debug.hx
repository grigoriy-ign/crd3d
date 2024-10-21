package crd3d.debug;

import flash.text.TextField;

class Debug
{

	public static var targetTF:TextField;
	public static var targetRealtimeTF:TextField;

	public static var realtimeStr:String = "";

	public static var cnt:Int = 0;
	public static var lim:Int = 100;

	/**
	 * Traces string into target textfield
	 */
	public static function tracestr(src:String):Void
	{
		if (targetTF != null)
		{
			targetTF.appendText(src + "\n");
			targetTF.scrollV = targetTF.maxScrollV;
		}
	}

	public static function rtracestr(src:String):Void
	{
		if (targetRealtimeTF != null)
		{
			realtimeStr += src + "\n";
			targetRealtimeTF.scrollV = targetRealtimeTF.maxScrollV;
		}
	}

	public static function updateRealtimeStr():Void
	{
		targetRealtimeTF.text = realtimeStr;
	}

	public static function rclear():Void
	{
		if (targetRealtimeTF != null)
		{
			targetRealtimeTF.text = "";
			realtimeStr = "";
		}
	}

	public static function clear():Void
	{
		if (targetTF != null)
		{
			targetTF.text = "";
		}
	}

}