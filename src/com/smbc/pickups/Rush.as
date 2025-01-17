package com.smbc.pickups
{
	import com.explodingRabbit.utils.CustomDictionary;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.characters.Character;
	import com.smbc.characters.MegaMan;
	import com.smbc.characters.base.MegaManBase;
	import com.smbc.data.AnimationTimers;
	import com.smbc.data.GameStates;
	import com.smbc.data.PickupInfo;
	import com.smbc.data.SoundNames;
	import com.smbc.ground.Ground;
	import com.smbc.ground.Platform;
	import com.smbc.level.Level;
	import com.smbc.main.GlobVars;

	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.geom.Point;

	public class Rush extends Pickup
	{
		private static const FL_STAND_START:String = "standStart";
		private static const FL_STAND_END:String = "standEnd";
		private static const FL_LAND_START:String = "landStart";
		private static const FL_LAND_END:String = "landEnd";
		private static const FL_SPRING:String = "spring";
		private static const FL_EXIT_START:String = "exitStart";
		private static const FL_EXIT_END:String = "exitEnd";
		private static const FL_FLY:String = "fly";
		private static const ST_FALL:String = "fall";
		private static const ST_TRANSITION:String = "transition";
		private static const ST_FIRST_TRANSITION:String = "firstTransition";
		public static const ST_WAIT:String = "wait";
		private static const ST_EXIT:String = "exit";
		private static const FLIGHT_ACCEL:int = 2300;
		private static const FLASH_ALPHA:Number = .75;
		private static const LAND_ON_SIDE_OFFSET:int = 40; //40
		private static const LAND_ON_SIDE_OFFSET_SHORT:int = 20; // 20
		private static const VY_MAX:int = 1000;
		private static const SPRING_PWR:int = 800;
		private var ts:int = GlobVars.TILE_SIZE;
		private var landOnSide:Boolean = true;
		private var startHitTestY:Number;
		private var playerGridX:int;
		private var playerGridY:int;
		private var useShortDist:Boolean;
		private const START_FLASH_TMR:CustomTimer = new CustomTimer(2000,1);
		private const FLASH_EXIT_TMR:CustomTimer = new CustomTimer(2000,1);
		private const SPRING_EXIT_TMR:CustomTimer = new CustomTimer(400,1);
		private const WAIT_ANIM_TMR:CustomTimer = AnimationTimers.ANIM_VERY_SLOW_TMR;
		private const TRANSITION_ANIM_TMR:CustomTimer = AnimationTimers.ANIM_FAST_TMR;
		private const GRND_GRID_DCT:CustomDictionary = new CustomDictionary();
		public function Rush(megaMan:MegaManBase)
		{
			super(PickupInfo.RUSH);
//			BMD_CONT_VEC[0].bmp.bitmapData = megaMan.BMD_CONT_VEC[0].bmd;
			stopAnim = true;
			updateOffScreen = true;
			mainAnimTmr = TRANSITION_ANIM_TMR;
			dosBot = true;
			dosLft = true;
			dosRht = true;
			playerGridX = calcPlayerGridLoc(player.nx);
			playerGridY = calcPlayerGridLoc(player.ny);
			if (player.upBtn)
				landOnSide = false;
			else
				determineTargetLocation();
			defyGrav = true;
			vyMax = VY_MAX;
			if (landOnSide)
			{
				if (player.scaleX > 0)
				{
					if (useShortDist)
						x = player.nx + LAND_ON_SIDE_OFFSET_SHORT;
					else
						x = player.nx + LAND_ON_SIDE_OFFSET;
				}
				else
				{
					if (useShortDist)
						x = player.nx - LAND_ON_SIDE_OFFSET_SHORT;
					else
						x = player.nx - LAND_ON_SIDE_OFFSET;
				}
			}
			else
				x = player.nx;
			if (player.scaleX > 0)
				scaleX = 1;
			else
				scaleX = -1;
			startHitTestY = playerGridY - ts*2;
			if (player.onPlatform)
				startHitTestY -= TILE_SIZE*2;
			stopHit = false;
			setState(ST_FALL);
			gotoAndStop(FL_FLY);
			addTmr(START_FLASH_TMR);
			addTmr(FLASH_EXIT_TMR);
			addTmr(SPRING_EXIT_TMR);
			START_FLASH_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,startFlashTmrHandler,false,0,true);
			FLASH_EXIT_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,flashExitTmrHandler,false,0,true);
			SPRING_EXIT_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,springExitTmrHandler,false,0,true);
		}
		override public function initiate():void
		{
			super.initiate();
			ACTIVE_ANIM_TMRS_DCT.addItem(TRANSITION_ANIM_TMR);
			ACTIVE_ANIM_TMRS_DCT.addItem(WAIT_ANIM_TMR);
		}
		private function determineTargetLocation():void
		{
			var columnToCheck:int;
			var columnToCheck2:int;
			if (player.scaleX > 0)
			{
				if (playerGridX < player.nx)
					columnToCheck = playerGridX + ts;
				else
					columnToCheck = playerGridX;
				columnToCheck2 = columnToCheck + ts;
			}
			else
			{
				if (playerGridX < player.nx)
					columnToCheck = playerGridX - ts;
				else
					columnToCheck = playerGridX - ts*2;
				columnToCheck2 = columnToCheck - ts;
			}
			var sameLevel:Boolean = false;
			var oneAbove:Boolean = false;
			var oneBelow:Boolean = false;
			for each (var g:Ground in level.GROUND_STG_DCT)
			{
				if (!(g is Platform) && !g.disabled)
				{
					if (g.x == columnToCheck)
					{
						if (g.y == playerGridY - ts)
							sameLevel = true;
						else if (g.y == playerGridY - ts*2)
							oneAbove = true;
						else if (g.y == playerGridY + ts)
							oneBelow = true;
					}
					else if (g.x == columnToCheck2 && g.y == playerGridY - ts)
						useShortDist = true;
				}
			}
			if (sameLevel)
				landOnSide = false;
		}
		private function calcPlayerGridLoc(locToTest:Number):int
		{
			var num:int;
			var bigNum:int;
			var smallNum:int;
			var bigNumDif:Number;
			var smallNumDif:Number;
			while (locToTest > num)
			{
				num += ts;
			}
			bigNum = num;
			smallNum = num - ts;
			bigNumDif = bigNum - locToTest;
			smallNumDif = locToTest - smallNum;
			if (bigNumDif < 0)
				bigNumDif = -bigNumDif;
			if (smallNumDif < 0)
				smallNumDif = -smallNumDif;
			if (bigNumDif > smallNumDif)
				return smallNum;
			else
				return bigNum;
		}
		override protected function updateStats():void
		{
			super.updateStats();
			if (!destroyOffScreen && y > GLOB_STG_TOP)
			{
				destroyOffScreen = true;
				updateOffScreen = false;
				dosTop = true;
			}
			if (cState == ST_FALL)
			{
				vy += FLIGHT_ACCEL*dt;
				if (!hitTestAgainstGroundDct[HT_GROUND_NON_BRICK] && ny >= startHitTestY)
				{
					addAllGroundToHitTestables();
				}
			}
			else if (cState == ST_EXIT)
			{
				vy -= FLIGHT_ACCEL*dt;
				if (y < GLOB_STG_TOP)
					destroy();
			}
		}
		override public function groundBelow(g:Ground):void
		{
			vy = 0;
			onGround = true;
			ny = g.hTop;
			setHitPoints();
			hBot = g.hTop;
			if (cState == ST_FALL)
			{
				gotoAndStop(FL_LAND_START);
				stopAnim = false;
				setState(ST_FIRST_TRANSITION);
				setHitPoints();
				noAnimThisCycle = true;
			}
			if (g is Platform)
				Platform(g).attachObject(this);
		}
		private function beginWaitPhase():void
		{
			gotoAndStop(FL_STAND_START);
			setState(ST_WAIT);
			mainAnimTmr = WAIT_ANIM_TMR;
			START_FLASH_TMR.start();
		}
		private function startFlashTmrHandler(event:TimerEvent):void
		{
			START_FLASH_TMR.reset();
			alpha = FLASH_ALPHA;
			FLASH_EXIT_TMR.start();
		}
		private function flashExitTmrHandler(event:TimerEvent):void
		{
			FLASH_EXIT_TMR.reset();
			alpha = 1;
			gotoAndStop(FL_EXIT_START);
			mainAnimTmr = TRANSITION_ANIM_TMR;
			setState(ST_TRANSITION);
			noAnimThisCycle = true;
			stopHit = true;
		}
		private function springExitTmrHandler(event:TimerEvent):void
		{
			SPRING_EXIT_TMR.reset();
			gotoAndStop(FL_EXIT_START);
			stopAnim = false;
			mainAnimTmr = TRANSITION_ANIM_TMR;
			setState(ST_TRANSITION);
			noAnimThisCycle = true;
			stopHit = true;
		}

		public function get isWaitingForMegaMan():Boolean
		{
			return cState == ST_WAIT;
		}

		private function exit():void
		{
			gotoAndStop(FL_FLY);
			stopAnim = true;
			defyGrav = true;
			setState(ST_EXIT);
			if (platformAttachedTo)
				platformAttachedTo.detachObject(this);
		}
		public function forceExit():void
		{
			FLASH_EXIT_TMR.reset();
			SPRING_EXIT_TMR.reset();
			gotoAndStop(FL_EXIT_START);
			stopAnim = false;
			mainAnimTmr = TRANSITION_ANIM_TMR;
			setState(ST_TRANSITION);
			noAnimThisCycle = true;
			stopHit = true;
		}
		override public function checkFrame():void
		{
			var cfl:String = currentFrameLabel;
			if (cfl == FL_LAND_END)
				beginWaitPhase();
			else if (cfl == FL_STAND_END)
				gotoAndStop(FL_STAND_START);
			else if (cfl == FL_EXIT_END)
				exit();

			super.checkFrame();
		}
		override public function hitCharacter(char:Character,side:String):void
		{
			if ( (cState == ST_WAIT || cState == ST_FIRST_TRANSITION) && !char.onGround && char.vy > 0 && GS_MNGR.gameState == GameStates.PLAY)
			{
				char.ny = hTop;
				char.vy = -SPRING_PWR;
				char.jumped = true;
				if (char is MegaMan)
				{
					MegaMan(char).releasedJumpBtn = true;
					MegaMan(char).frictionY = false;
					SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_LAND);
					MegaMan(char).rushCoilBounce();
				}
				gotoAndStop(FL_SPRING);
				stopAnim = true;
				START_FLASH_TMR.reset();
				FLASH_EXIT_TMR.reset();
				alpha = 1;
				setState(ST_TRANSITION);
				SPRING_EXIT_TMR.start();
				stopHit = true;
			}
		}

		override public function touchPlayer(char:Character):void
		{

		}


		override protected function removeListeners():void
		{
			super.removeListeners();
			START_FLASH_TMR.removeEventListener(TimerEvent.TIMER_COMPLETE,startFlashTmrHandler);
			FLASH_EXIT_TMR.removeEventListener(TimerEvent.TIMER_COMPLETE,flashExitTmrHandler);
			SPRING_EXIT_TMR.removeEventListener(TimerEvent.TIMER_COMPLETE,springExitTmrHandler);
		}
		override protected function reattachLsrs():void
		{
			super.reattachLsrs();
			START_FLASH_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,startFlashTmrHandler,false,0,true);
			FLASH_EXIT_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,flashExitTmrHandler,false,0,true);
			SPRING_EXIT_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,springExitTmrHandler,false,0,true);
		}
		override public function cleanUp():void
		{
			super.cleanUp();
			if (player is MegaMan)
				if (MegaMan(player).rush == this)
					MegaMan(player).rush = null;
		}
	}
}
