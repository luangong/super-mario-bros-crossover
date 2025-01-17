package com.smbc.graphics
{
	import com.smbc.characters.Sophia;
	import com.smbc.level.Level;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.Socket;

	//[Embed(source="../assets/swfs/SmbcGraphics.swf", symbol="SophiaBase")]
	public class SophiaBase extends SubMc
	{
		private static const FL_BASE_TURN_END:String = "turnEnd";
		private static const FL_BASE_HORZ:String = Sophia.FL_BASE_HORZ;
		private var sophia:Sophia;
		private var level:Level;
		public function SophiaBase(sophia:Sophia,mc:MovieClip = null)
		{
			super(sophia);
			stop();
			hasPState2 = true;
			stopAnim = true;
//			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);
		}
		override protected function addedToStageHandler(event:Event):void
		{
//			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			super.addedToStageHandler(event);
			sophia = parent as Sophia;
			level = Level.levelInstance;
		}
		override public function checkFrame():void
		{
			if (currentFrameLabel === convLab(FL_BASE_TURN_END))
				setStopFrame(FL_BASE_HORZ);
		}
		override public function convLab(_fLab:String):String
		{
			return _fLab;
		}
	}
}
