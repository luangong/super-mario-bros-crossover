package com.smbc.pickups
{
	import com.customClasses.*;
	import com.explodingRabbit.display.CustomMovieClip;
	import com.explodingRabbit.utils.CustomDictionary;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.characters.*;
	import com.smbc.data.AnimationTimers;
	import com.smbc.data.MapInfo;
	import com.smbc.data.PickupInfo;
	import com.smbc.data.SoundNames;
	import com.smbc.events.CustomEvents;
	import com.smbc.graphics.Palette;
	import com.smbc.ground.*;
	import com.smbc.interfaces.ICustomTimer;
	import com.smbc.level.Level;
	import com.smbc.managers.EventManager;
	import com.smbc.managers.GraphicsManager;

	import flash.events.Event;
	import flash.events.TimerEvent;

	public class BowserAxe extends Pickup
	{
		private static const FL_END:String = "end";
		private static const FL_START:String = "start";
		private static const FL_HIT_END:String = "hitEnd";
		private static const FL_HIT_START:String = "hitStart";
		private var killBridgeTmr:CustomTimer;
		private var killBridgeDur:int = 75;
		private var touched:Boolean;
		private const SFX_BRIDGE_BREAK_SND:String = SoundNames.SFX_GAME_BRIDGE_BREAK;
		private static var animEndFrameNum:int;
		private static var animEndFrameNumHit:int;
		private static const NUM_ANIM_FRAMES:int = 4;
		private static var animStartFrameDelay:int;
		protected var animDelCtr:int;
		private static const CHANGE_MAP_FCT_DCT:CustomDictionary = new CustomDictionary(true);
		{
			EventManager.EVENT_MNGR.addEventListener(CustomEvents.CHANGE_MAP_SKIN, changeMapSkinHandler, false, 0, true);
		}
		// Constants:
		// Public Properties:
		// Private Properties:
		// Initialization:
		public function BowserAxe()
		{
			super();
			defyGrav = true;
			bottomAo = true;
			mainAnimTmr = AnimationTimers.ANIM_SLOWEST_TMR;
			CHANGE_MAP_FCT_DCT.addItem(changeMapSkinLocalHandler);
			level.ALWAYS_ANIM_DCT.addItem(this);
			playsRegularSound = true;
		}

		protected static function changeMapSkinHandler(event:Event):void
		{
			var dct:CustomDictionary = Level.levelInstance.AO_DCT;
			var gm:GraphicsManager = GraphicsManager.INSTANCE;
			var axe:CustomMovieClip = new CustomMovieClip(null,null,"BowserAxe");
			animStartFrameDelay = gm.getFrameDelay( axe.getPaletteByRow(0) );
			animEndFrameNum = NUM_ANIM_FRAMES + axe.convFrameToInt(FL_START) - 1;
			animEndFrameNumHit = animEndFrameNum + NUM_ANIM_FRAMES;
			while ( animEndFrameNum > 0 && axe.frameIsEmpty( animEndFrameNum ) )
			{
				animEndFrameNum--;
			}
			for each (var fct:Function in CHANGE_MAP_FCT_DCT)
			{
				fct();
			}
		}

		private function changeMapSkinLocalHandler():void
		{
			if (!stopAnim)
				gotoAndStop(FL_START);
			animDelCtr = 0;
		}

		// called by initiate level
		public function setUpBridge():void
		{
			if (!level.bowser)
				return;
			level.bbVec.sort(sortBBVec);
			level.bowser.getXMaxMin(level.bbVec[0].x,level.bbVec[level.bbVec.length-1].x);
		}
		override public function touchPlayer(char:Character):void
		{
			if (touched)
				return;
			STAT_MNGR.stopTimeLeft();
//			visible = false;
			touched = true;
			if (level.bowser && level.bowser.cState != "die" && !level.bowser.destroyed)
			{
				killBridgeTmr = new CustomTimer(killBridgeDur,level.bbVec.length);
				level.bbVec.sort(sortBBVec);
				addTmr(killBridgeTmr);
				killBridgeTmr.addEventListener(TimerEvent.TIMER,killBridgeTmrLsr);
				killBridgeTmr.addEventListener(TimerEvent.TIMER_COMPLETE,killBridgeTmrCompLsr);
				killBridgeTmr.start();
				level.freezePlayer();
				level.bowser.breakBridgeStart();
				level.destroy(level.bbChain);
				stopHit = true;
				gotoAndStop(FL_HIT_START);
			}
			else
			{
				player.getAxe(this);
				stopHit = true;
//				destroy();
				axeEnd();
			}
		}
		private function killBridgeTmrLsr(e:TimerEvent):void
		{
			level.bbVec[0].startBreak();
			level.bbVec.shift();
//			level.destroy(level.bbVec[0]);
			SND_MNGR.playSound(SFX_BRIDGE_BREAK_SND);
			if (level.bowser)
				level.bowser.breakBridgeInc();
		}
		private function killBridgeTmrCompLsr(e:TimerEvent):void
		{
			if (killBridgeTmr)
			{

				killBridgeTmr.removeEventListener(TimerEvent.TIMER,killBridgeTmrLsr);
				killBridgeTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,killBridgeTmrCompLsr);
				removeTmr(killBridgeTmr);
				killBridgeTmr = null;
			}
			level.unfreezePlayer();
			player.getAxe(this);
			level.bowser.breakBridgeEnd();
//			destroy();
			axeEnd();

		}

		private function axeEnd():void
		{
			gotoAndStop(FL_HIT_START);
			if (level.bowserAxe == this)
				level.bowserAxe = null;
			level.keepPlayerOnRight = true;
			CHANGE_MAP_FCT_DCT.removeItem(changeMapSkinLocalHandler);
		}
		private function sortBBVec(bb1:BowserBridge,bb2:BowserBridge):int
		{
			if (bb1.x < bb2.x)
				return 1;
			else if (bb1.x > bb2.x)
				return -1;
			else
				return 0;
		}

		override public function animate(ct:ICustomTimer):Boolean
		{
			if (currentFrameLabel == FL_START && animDelCtr < animStartFrameDelay && mainAnimTmr == ct)
				animDelCtr ++;
			else
			{
				animDelCtr = 0;
				return super.animate(ct);
			}
			return false;
		}

		override public function checkFrame():void
		{
			if (!stopHit)
			{
				if (currentFrame == animEndFrameNum + 1)
					gotoAndStop(FL_START);
			}
			else
			{
				if (currentFrame == animEndFrameNumHit + 1)
					gotoAndStop(FL_HIT_START);
			}
		}
		override protected function removeListeners():void
		{
			super.removeListeners();
			if (killBridgeTmr)
			{
				if (killBridgeTmr.hasEventListener(TimerEvent.TIMER)) killBridgeTmr.removeEventListener(TimerEvent.TIMER,killBridgeTmrLsr);
				if (killBridgeTmr.hasEventListener(TimerEvent.TIMER_COMPLETE)) killBridgeTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,killBridgeTmrCompLsr);
			}
		}
		override public function rearm():void
		{
			super.rearm();
			if (!stopHit)
				level.bowserAxe = this;
			level.ALWAYS_ANIM_DCT.addItem(this);
		}
		override public function disarm():void
		{
			super.disarm();
			if (level)
				level.ALWAYS_ANIM_DCT.removeItem(this);
		}
		override protected function reattachLsrs():void
		{
			super.reattachLsrs();
			if (killBridgeTmr)
			{
				if (!killBridgeTmr.hasEventListener(TimerEvent.TIMER))
					killBridgeTmr.addEventListener(TimerEvent.TIMER,killBridgeTmrLsr);
				if (!killBridgeTmr.hasEventListener(TimerEvent.TIMER_COMPLETE))
					killBridgeTmr.addEventListener(TimerEvent.TIMER_COMPLETE,killBridgeTmrCompLsr);
			}
		}
		override public function cleanUp():void
		{
			if (level)
				level.ALWAYS_ANIM_DCT.removeItem(this);
			CHANGE_MAP_FCT_DCT.removeItem(changeMapSkinLocalHandler);
			super.cleanUp();
		}
	}

}
