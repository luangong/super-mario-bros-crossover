package com.smbc.sound
{
	import com.explodingRabbit.utils.CustomDictionary;
	import com.smbc.data.SoundNames;
	import com.smbc.managers.SoundManager;

	public class BackgroundMusicSections
	{
		private static var done:Boolean = false;
		private static const SCT_DCT:CustomDictionary = SoundManager.SND_MNGR.BGM_SCT_DCT;
		private static const _A:String = "a";
		private static const _B:String = "b";
		private static const _C:String = "c";
		private static const _D:String = "d";
		private static const _E:String = "e";
		private static const _F:String = "f";
		private static const _G:String = "g";
		private static const _H:String = "h";
		public static function prepareSoundManager()
		{
			if (done)
				throw new Error("shit");
			var str:String = SoundNames.BGM_BILL_DUNGEON;
			SCT_DCT.addItem(str,[
				{"a":1,"b":1000,"c":4000},
				[_A,_B,_C],
				[_B,_C]
			]);
		}
	}
}
