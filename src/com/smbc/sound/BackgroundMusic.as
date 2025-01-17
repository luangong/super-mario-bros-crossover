package com.smbc.sound {

	import com.smbc.data.SoundNames;
	import com.smbc.errors.SingletonError;
	import com.smbc.main.GlobVars;
	import com.smbc.managers.SoundManager;

	import flash.events.*;
	import flash.media.*;
	import flash.utils.ByteArray;


	public class BackgroundMusic extends SoundContainer
	{

		public static var instance:BackgroundMusic;
		protected var loopNum:int;
		// Private Properties:

		// Initialization:
		public function BackgroundMusic(soundName:String, soundData:ByteArray = null)
		{
			//stopPos = length - FOOTER;
			super(soundName,soundData);
			if (instance != null)
				throw new SingletonError();
			if (!SND_MNGR.muteMusic)
			{
				checkLoopNum();
				playSound();
			}
			else
				cleanUp();

		}
		override protected function soundCompleteLsr(e:Event):void
		{
			if (channel)
			{
				if (channel.hasEventListener(Event.SOUND_COMPLETE))
					channel.removeEventListener(Event.SOUND_COMPLETE,soundCompleteLsr);
				channel.stop();
			}
			if (loopNum)
				channel = sound.play(loopNum,int.MAX_VALUE);
			else
				channel = sound.play(0,int.MAX_VALUE);
			if (channel && transform)
				channel.soundTransform = transform;

		}
		protected function originalSoundCompleteLsr(e:Event):void
		{
			super.soundCompleteLsr(e);
		}
		public function playAtLoopNum():void
		{
			if (loopNum)
				soundCompleteLsr(new Event(Event.SOUND_COMPLETE) );
		}
		public function fakePause(newCPos:Number):void
		{
			if (newCPos < 0)
				throw new Error("can't pause background music at negative position");
			_cPos = newCPos;
			_paused = true;
		}
		private function checkLoopNum():void
		{
			if (soundName == SoundNames.BGM_BILL_UNDER_GROUND)
				loopNum = 6390;
			else if (soundName == SoundNames.BGM_BILL_DUNGEON)
				loopNum = 11182;
			else if (soundName == SoundNames.BGM_BILL_OVER_WORLD)
				loopNum = 1589;
			else if (soundName == SoundNames.BGM_BILL_WATER)
				loopNum = 1197;
			else if (soundName == SoundNames.BGM_LINK_OVER_WORLD)
				loopNum = 6391; // took away 47 ms
			else if (soundName == SoundNames.BGM_LINK_UNDER_GROUND)
				loopNum = 3193;
			else if (soundName == SoundNames.BGM_MEGA_MAN_DUNGEON)
				loopNum = 6390; // 6.390181
			else if (soundName == SoundNames.BGM_MEGA_MAN_UNDER_GROUND)
				loopNum = 25561;
			else if (soundName == SoundNames.BGM_MEGA_MAN_OVER_WORLD)
				loopNum = 30121; // 30.120680
			else if (soundName == SoundNames.BGM_MEGA_MAN_WATER)
				loopNum = 10651;
			else if (soundName == SoundNames.BGM_RYU_DUNGEON)
				loopNum = 1865;
			else if (soundName == SoundNames.BGM_RYU_OVER_WORLD)
				loopNum = 12789;
			else if (soundName == SoundNames.BGM_RYU_UNDER_GROUND)
				loopNum = 1599;
			else if (soundName == SoundNames.BGM_RYU_WATER)
				loopNum = 881;
			else if (soundName == SoundNames.BGM_SIMON_WATER)
				loopNum = 22630;
		}
		override protected function setUpSoundTransform():void
		{
			var volInt:int = SND_MNGR.SND_LEV_DCT[this.soundName] - SND_MNGR.musicVolMinusNum;
			if (volInt < 0)
				volInt = 0;
			var volDec:Number = 0;
			if (volInt > 0)
				volDec = volInt / SND_MNGR.SND_LEV_DIVISOR;
			transform = new SoundTransform(volDec);
			super.setUpSoundTransform();
		}
		override protected function playSound():void
		{
			if (loopNum)
			{
				channel = sound.play();
				if (channel)
				{
					channel.addEventListener(Event.SOUND_COMPLETE,soundCompleteLsr,false,0,true);
					if (transform)
						channel.soundTransform = transform;
				}
			}
			else
			{
				channel = sound.play(0,int.MAX_VALUE);
				if (channel && transform)
					channel.soundTransform = transform;
			}
		}
		override public function pauseSound():void
		{
			if (_paused)
				return;
			if (channel)
			{
				_cPos = channel.position;
				if (channel.hasEventListener(Event.SOUND_COMPLETE))
					channel.removeEventListener(Event.SOUND_COMPLETE,soundCompleteLsr);
				channel.stop();
				_paused = true;
			}
		}
		override public function resumeSound():void
		{
			if (!_paused)
				return;
			_paused = false;
			if (_cPos)
				channel = sound.play(_cPos);
			else
				channel = sound.play();
			if (channel)
			{
				channel.addEventListener(Event.SOUND_COMPLETE,soundCompleteLsr,false,0,true);
				if (transform)
					channel.soundTransform = transform;
			}
		}
		override public function cleanUp():void
		{
			instance = null;
			super.cleanUp();
		}
	}

}
