package com.smbc.sound
{
	import flash.events.Event;
	import flash.utils.ByteArray;

	public class LoopingSoundEffect extends SoundEffect
	{
		public function LoopingSoundEffect(soundName:String, soundData:ByteArray = null)
		{
			super(soundName,soundData);
		}
		override protected function playSound():void
		{
			channel = sound.play(0,int.MAX_VALUE);
			if (channel && transform)
				channel.soundTransform = transform;
		}
		override protected function soundCompleteLsr(e:Event):void
		{
			playSound();
		}

	}
}
