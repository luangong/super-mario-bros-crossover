package com.customClasses
{

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.text.*;

	public class FrameRateProfiler extends Sprite {

		private var _previousTime:int;
		private var _sampleSize:int = 30;
		private var _sample:Vector.<Number>;

		[Inspectable(defaultValue = 1,name = "Decimal Precision")]
		public var precision:uint = 1;

		public var textField:TextField;

		public function FrameRateProfiler() {
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage, false, 0, true);
			_sample = new Vector.<Number>();
			var tf:TextFormat = new TextFormat();
			tf.size = 20;
			textField.background = true;
			textField.defaultTextFormat = tf;
			textField.selectable = false;
			textField.autoSize = TextFieldAutoSize.LEFT;
		}

		[Inspectable(defaultValue = 30, name = "Sample Size")]
		public function set sampleSize(value:int):void {
			_sampleSize = Math.max(1, value);
		}

		public function get sampleSize():int { return _sampleSize; }

		[Inspectable(defaultValue = 0x000000, type = "Color", name = "Text Color")]
		public function set color(value:uint):void {
			textField.textColor = value;
		}

		public function get color():uint { return textField.textColor; }

		private function addedToStage(e:Event):void {
			addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			_previousTime = getTimer();
		}

		private function removedFromStage(e:Event):void {
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onEnterFrame(e:Event):void {
			var newTime:int = getTimer();
			var rate:Number = 1000/(newTime - _previousTime);
			_sample.push(rate);
			if (_sample.length > _sampleSize) _sample.shift();
			_previousTime = newTime;
			var avg:Number = 0;
			for each (var value:Number in _sample)
				avg += value;
			avg /= _sample.length;
			textField.text = avg.toFixed(precision);
		}

	}

}
