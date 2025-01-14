package com.smbc.sound
{
	import com.smbc.errors.SingletonError;

	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;

	[Embed(source="../assets/swfs/SmbcSounds.swf", symbol="RepeatingSilenceSnd")]
	public class RepeatingSilenceOverrideSnd extends Sound
	{
		public static var instance:RepeatingSilenceOverrideSnd;
		public static var instantiated:Boolean;
		private var channel:SoundChannel = new SoundChannel();
		private const TRANSFORM:SoundTransform = new SoundTransform(0);
		public function RepeatingSilenceOverrideSnd(stream:URLRequest=null, context:SoundLoaderContext=null)
		{
			super(stream, context);
			if (instance)
				throw new SingletonError();
			instance = this;
		}
		public function playSound():void
		{
			if (channel)
				channel.stop();
			channel = play(0,int.MAX_VALUE,TRANSFORM);
		}
	}
}
