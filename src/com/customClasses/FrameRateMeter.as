package com.customClasses
{
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.text.*;
	public class FrameRateMeter extends Sprite {
		private var lastFrameTime:Number;
		private var output:TextField;
		public function FrameRateMeter() {
			output = new TextField();
			output.autoSize = TextFieldAutoSize.LEFT;
			output.textColor = 0xFF0000;
			//output.border     = true;
			//output.background = true;
			output.selectable = false;
			addChild(output);
			addEventListener(Event.ENTER_FRAME, enterFrameListener);
		}
		private function enterFrameListener(e:Event):void {
			var now:Number = getTimer();
			var elapsed:Number = now - lastFrameTime;
			var framesPerSecond:Number = Math.round(1000/elapsed);
			output.text = String(framesPerSecond )
			            // + "\nDesignated frame rate: " + stage.frameRate;"Time since last frame: " + elapsed
			lastFrameTime = now;
		}
	}
}
