package com.smbc.pickups
{
	import com.explodingRabbit.utils.CustomDictionary;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.characters.*;
	import com.smbc.data.AnimationTimers;
	import com.smbc.data.GameSettings;
	import com.smbc.data.MusicType;
	import com.smbc.data.PickupInfo;
	import com.smbc.data.SoundNames;
	import com.smbc.enemies.*;
	import com.smbc.events.CustomEvents;
	import com.smbc.graphics.BmdInfo;
	import com.smbc.ground.*;
	import com.smbc.main.*;
	import com.smbc.managers.EventManager;
	import com.smbc.sound.BackgroundMusic;

	import flash.display.MovieClip;
	import flash.events.Event;

	public class FireFlower extends Pickup
	{

		// Constants:
		// Public Properties:
		// Private Properties:
		private static const MAIN_ANIM_TMR:CustomTimer = AnimationTimers.ANIM_FAST_TMR;
		private static const SLOWER_ANIM_TMR:CustomTimer = AnimationTimers.ANIM_MIN_FAST_TMR;
		private const CT_NORMAL:String = "normal";
		private const CT_UNDER_GROUND:String = "underGround";
		private const FL_END:String = "end";
		private const FL_START:String = "start";
		private var colorType:String;

		private static var fireFlowersDct:CustomDictionary = new CustomDictionary(true);
		{
			EventManager.EVENT_MNGR.addEventListener(CustomEvents.CHANGE_MAP_SKIN, changeMapSkinHandler, false, 0, true);
		}

		// Initialization:
		public function FireFlower():void
		{
			super(PickupInfo.MARIO_FIRE_FLOWER);
			playsRegularSound = true;
			_boomerangGrabbable = true;
			var bgt:int = level.bgmType;
			stopAnim = false;
			mainAnimTmr = getAnimTmr();
			fireFlowersDct.addItem(this);
		}

		private static function getAnimTmr():CustomTimer
		{
			if (GameSettings.mapSkin != BmdInfo.SKIN_NUM_SMW)
				return MAIN_ANIM_TMR;
			return SLOWER_ANIM_TMR;
		}
		override public function cleanUp():void
		{
			super.cleanUp();
			fireFlowersDct.removeItem(this);
		}

		protected static function changeMapSkinHandler(event:Event):void
		{
			var newTmr:CustomTimer = getAnimTmr();

			for each (var flower:FireFlower in fireFlowersDct)
			{
				flower.ACTIVE_ANIM_TMRS_DCT.removeItem(flower.mainAnimTmr);
				flower.mainAnimTmr = newTmr;
				flower.ACTIVE_ANIM_TMRS_DCT.addItem(flower.mainAnimTmr);
			}

		}
		override public function checkFrame():void
		{
			var cfl:String = currentFrameLabel;
			if (cfl == FL_END)
				gotoAndStop(FL_START);
		}
	}

}
