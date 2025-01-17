package com.customClasses
{

	import flash.display.MovieClip;
	import flash.utils.*;
	import flash.events.TimerEvent;

	public class TDCalculator extends MovieClip
	{
		public var now:int;// The current time
		internal var then:int;// The last screen-update time
		internal var dt:Number;
		internal var elapsed:int;
		public var offSet:int;

		public function TDCalculator():void
		{
			dt = .05;
			// Initialize timestamps
			then = getTimer();
			now  = then;
			//getTD();
		}
		public function getTD():Number {
			// Calculate how much time has passed since the last move
			then = now;
			now = getTimer();
			dt = (now - then)/1000;
			return dt;
			// Calculate the amount move based on the amount of time that
			// has passed since the last move
			//moveAmount = distancePerSecond * dt;
		}
	}
}
