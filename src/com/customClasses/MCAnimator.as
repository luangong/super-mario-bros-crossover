package com.customClasses
{

	import com.explodingRabbit.display.CustomMovieClip;
	import com.smbc.ground.ItemBlock;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class MCAnimator
	{

		public function MCAnimator()
		{
			// whatever;
		}
		public function animate(object:DisplayObject):void
		{
			var mc:MovieClip;
			var cmc:CustomMovieClip;
			if (object is MovieClip)
			{
				mc = object as MovieClip;
				var cf:int = mc.currentFrame;
				if (cf != mc.totalFrames)
					mc.gotoAndStop(cf+1);
				else
					mc.gotoAndStop(1);
			}
			else
			{
				cmc = object as CustomMovieClip;
				var num:int = cmc.currentFrame;
				if (num != cmc.totalFrames)
					cmc.gotoAndStop(num+1);
				else
					cmc.gotoAndStop(1);
			}

		}

	}
}
