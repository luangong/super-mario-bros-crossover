package com.smbc.enemies
{
	import com.explodingRabbit.cross.gameplay.statusEffects.StatusProperty;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.data.Cheats;
	import com.smbc.data.EnemyInfo;
	import com.smbc.data.HealthValue;
	import com.smbc.data.LevelTypes;
	import com.smbc.data.MusicType;
	import com.smbc.data.ScoreValue;
	import com.smbc.data.SoundNames;
	import com.smbc.events.CustomEvents;
	import com.smbc.ground.*;
	import com.smbc.level.Level;
	import com.smbc.main.*;
	import com.smbc.messageBoxes.MenuBoxItems;
	import com.smbc.projectiles.*;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;

	[Embed(source="../assets/swfs/SmbcGraphics.swf", symbol="HammerBro")]
	public class HammerBro extends Enemy
	{
		public static const ENEMY_NUM:int = EnemyInfo.HammerBro;
		private static const CHASE_LABEL_STRING:String = "Chase";
		private const HAMMER_COLOR_BLACK:String = Hammer.TYPE_NORMAL;
//		private const HAMMER_COLOR_GRAY:String = Hammer.TYPE_BOWSER;
		private const JUMP_TMR:CustomTimer = new CustomTimer(1,1);
		private const JUMP_TMR_DUR_MIN:int = 600;
		private const JUMP_TMR_DUR_MAX:int = 2000;
		private const HAMMER_TMR:CustomTimer = new CustomTimer(1,1);
		private const HAMMER_TMR_DUR_MIN:int = 300;
		private const HAMMER_TMR_DUR_MAX:int = 1200;
		private const HAMMER_DEL_TMR:CustomTimer = new CustomTimer(250,1);
		private const CHASE_TMR_DUR:int = 27000; // 27000
		private var chaseSpeed:int = ENEMY_WALK_SPEED_NORMAL;
		private const WALK_SPEED:int = 30;
		private const ST_CHASE:String = "chase";
		private const ST_NORMAL:String = "normal";
		private static const FLY_SPEED:int = 1000;
		private var hammerColor:String;
		private var chase:Boolean;
		private var chaseTmr:CustomTimer;
		private var smallJumpPwr:int;
		public var passThroughGround:Boolean;
		private var jumpedHigh:Boolean;
		private var jumped:Boolean;
		private var cannotPassThroughGround:Boolean;
		private var impassableGroundBelow:Boolean;
		private var startJumpLoc:Number;
		private var xWaveLeft:Number;
		private var xWaveRight:Number;
		private var evil:Boolean;
		private var flying:Boolean;

		public function HammerBro(fLab:String = null,flying:Boolean = false):void
		{
			hammerColor = HAMMER_COLOR_BLACK;
			if (fLab && fLab.indexOf("enemyHamBroBlue") != -1)
			{
				colorNum = 2;
//				hammerColor = HAMMER_COLOR_GRAY;
			}
			else
			{
				colorNum = 1;
//				hammerColor = HAMMER_COLOR_BLACK;
			}
			var levType:String = Level.levelInstance.type;
			if (levType == LevelTypes.UNDER_GROUND || levType == LevelTypes.CASTLE)
			{
				cannotPassThroughGround = true;
				colorNum = 2;
//				hammerColor = HAMMER_COLOR_GRAY;
			}
			super();
			if (fLab != null && fLab.indexOf(CHASE_LABEL_STRING) != -1)
				chase = true;
			this.flying = flying;
			stompable = true;
			numColors = 2;
			jumpPwr = 625;
			smallJumpPwr = 200;
			gravity = 1250;
			vyMaxPsv = 500;
			scaleX = -1;
			vx = WALK_SPEED;
			if (flying)
			{
				vy = -FLY_SPEED;
				removeHitTestableItem(HT_ENEMY);
			}
			else
				vy = 0;
			addTmr(HAMMER_TMR);
			HAMMER_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,hammerTmrLsr);
			addTmr(HAMMER_DEL_TMR);
			HAMMER_DEL_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,hammerDelTmrLsr);
			JUMP_TMR.delay = int(Math.random()*(JUMP_TMR_DUR_MAX-JUMP_TMR_DUR_MIN)+JUMP_TMR_DUR_MIN);
			addTmr(JUMP_TMR);
			JUMP_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,jumpTmrLsr);
			JUMP_TMR.start();
			if (!chase)
			{
				chaseTmr = new CustomTimer(CHASE_TMR_DUR,1);
				addTmr(chaseTmr);
				chaseTmr.addEventListener(TimerEvent.TIMER_COMPLETE,chaseTmrHandler,false,0,true);
				chaseTmr.start();
			}
			setPlayFrame("walk-1");
			setState(ST_NORMAL);
			addProperty( new StatusProperty(StatusProperty.TYPE_KNOCK_BACK_PAS,10) );
			var str:String = CustomEvents.MSG_BX_CHOOSE_ITEM + MenuBoxItems.EVIL_HAMMER_BROS;
			EVENT_MNGR.addEventListener(str,evilHammerBrosHandler,false,0,true);
			evilHammerBrosHandler(new Event(str));
		}

		override protected function updDirection():void
		{

		}

		override protected function overwriteInitialStats():void
		{
			_health = HealthValue.HAMMER_BRO;
			scoreAttack = ScoreValue.HAMMER_BRO_ATTACK;
			scoreBelow = ScoreValue.HAMMER_BRO_BELOW;
			scoreStar = ScoreValue.HAMMER_BRO_STAR;
			scoreStomp = ScoreValue.HAMMER_BRO_STOMP;
			super.overwriteInitialStats();
			chaseSpeed = defaultWalkSpeed;
		}
		override public function initiate():void
		{
			super.initiate();
			xWaveLeft = x - TILE_SIZE*.5;
			xWaveRight = x + TILE_SIZE*.5;
			if (flying)
			{
				onGround = false;
				dosLft = true;
			}
		}
		override public function stomp():void
		{
			if (cState == ST_DIE)
				return;
			player.hit(this,"bottom"); // hardcodes this because player wasn't bouncing
			super.stomp();
			if (!player.canStomp)
				return;
			die();
			SND_MNGR.removeStoredSound(SoundNames.SFX_GAME_KICK_SHELL);
			vx = 0;
			vy = 0;
		}
		override protected function updateStats():void
		{
			super.updateStats();
			if (flying && onGround && vy == 0) // for first time land on ground
			{
				xWaveLeft = nx - TILE_SIZE*.5;
				xWaveRight = nx + TILE_SIZE*.5;
				flying = false;
				addHitTestableItem(HT_ENEMY);
			}
			if (cState != ST_DIE)
			{
				if (onGround)
				{
					stopAnim = false;
					jumped = false;
					if(!JUMP_TMR.running)
					{
						JUMP_TMR.delay = int(Math.random()*(JUMP_TMR_DUR_MAX-JUMP_TMR_DUR_MIN)+JUMP_TMR_DUR_MIN);
						JUMP_TMR.start();
					}
				}
				else
					stopAnim = true;
				if (!HAMMER_TMR.running && !HAMMER_DEL_TMR.running)
				{
					var hammerTmrDelay:int = int(Math.random()*(HAMMER_TMR_DUR_MAX-HAMMER_TMR_DUR_MIN)+HAMMER_TMR_DUR_MIN);
					HAMMER_TMR.delay = hammerTmrDelay;
					HAMMER_TMR.start();
				}
				if (!flying)
				{
					if (player.hRht < nx)
					{
						if (chase || evil)
						{
							vx = -chaseSpeed;
							setState(ST_CHASE);
						}
						else
							setState(ST_NORMAL);
						if (player.hRht < nx)
							scaleX = -1;
					}
					else if (player.hLft > nx)
					{
						if (evil)
						{
							vx = chaseSpeed;
							setState(ST_CHASE);
						}
						else if (cState == ST_CHASE)
						{
							setState(ST_NORMAL);
							xWaveLeft = nx - TILE_SIZE*.5;
							xWaveRight = nx + TILE_SIZE*.5;
						}
						if (player.hRht > nx)
							scaleX = 1;
					}
					else
					{
						if (evil)
						{
							vx = 0;
							setState(ST_CHASE);
						}
						else if (cState == ST_CHASE)
						{
							setState(ST_NORMAL);
							xWaveLeft = nx - TILE_SIZE*.5;
							xWaveRight = nx + TILE_SIZE*.5;
						}
						if (player.nx < nx)
							scaleX = -1;
						else
							scaleX = 1;
					}
					if (cState == ST_NORMAL)
					{
						if (vx < -WALK_SPEED)
							vx = -WALK_SPEED;
						else if (vx > WALK_SPEED)
							vx = WALK_SPEED;
						if (nx < xWaveLeft)
						{
							nx = xWaveLeft;
							vx = -vx;
						}
						else if (nx > xWaveRight)
						{
							nx = xWaveRight;
							vx = -vx;
						}
					}
					if (jumpedHigh && vy < 0)
						passThroughGround = true;
					else if (!jumpedHigh && jumped && vy > 0)
						passThroughGround = true;
					else
						passThroughGround = false;
					if (ny - startJumpLoc > TILE_SIZE*2 || ny > GLOB_STG_BOT - TILE_SIZE*2.9)
						passThroughGround = false;
					if (cannotPassThroughGround)
						passThroughGround = false;
				}
				else // (if flying)
				{
					if (vy < 0)
						passThroughGround = true;
					else
						passThroughGround = false;
					if (JUMP_TMR.running)
						JUMP_TMR.reset();
				}
			}
			if (wallOnLeft || wallOnRight)
				passThroughGround = false;
			if (passThroughGround)
			{
				removeHitTestableItem(HT_GROUND_NON_BRICK);
				removeHitTestableItem(HT_BRICK);
			}
			else
			{
				addHitTestableItem(HT_GROUND_NON_BRICK);
				addHitTestableItem(HT_BRICK);
			}
		}
		private function hammerTmrLsr(e:TimerEvent):void
		{
			HAMMER_TMR.reset();
			HAMMER_DEL_TMR.start();
			if (currentFrameLabel == convLab("walk-1"))
				setStopFrame("throw-1");
			else if (currentFrameLabel == convLab("walk-2"))
				setStopFrame("throw-2");
		}
		private function hammerDelTmrLsr(e:TimerEvent):void
		{
			HAMMER_DEL_TMR.reset();
			if (cState != ST_DIE)
			{
				if (currentFrameLabel == convLab("throw-1"))
					setStopFrame("walk-1");
				else if (currentFrameLabel == convLab("throw-2"))
					setStopFrame("walk-2");
				level.addToLevel(new Hammer(hammerColor,this));
			}
		}

		private function jumpTmrLsr(e:TimerEvent):void
		{
			if (onGround)
				jump();
			JUMP_TMR.reset();
		}
		private function jump():void
		{

			if (ny == GLOB_STG_BOT - TILE_SIZE*2 || cannotPassThroughGround || impassableGroundBelow)
				highJump();
			else if (ny == GLOB_STG_TOP + TILE_SIZE*5)
				lowJump();
			else
			{
				if (Math.random() >= .5)
					highJump();
				else
					lowJump();
			}
			function highJump():void
			{
				vy = -jumpPwr;
				onGround = false;
				jumpedHigh = true;
				jumped = true;
			}
			function lowJump():void
			{
				vy = -smallJumpPwr;
				onGround = false;
				jumpedHigh = false;
				jumped = true;
			}
			startJumpLoc = ny;
		}
		private function chaseTmrHandler(event:TimerEvent):void
		{
			chaseTmr.stop();
			chaseTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,chaseTmrHandler);
			removeTmr(chaseTmr);
			chaseTmr = null;
			chase = true;
		}
		override public function groundBelow(g:Ground):void
		{
			super.groundBelow(g);
			if (g is Brick)
				impassableGroundBelow = false;
			else
				impassableGroundBelow = true;
		}
		override public function checkFrame():void
		{
			if (!stopAnim)
			{
				if (currentFrame == getLabNum("walk-2") + 1)
					setPlayFrame("walk-1");
				else if (currentFrame == getLabNum("throw-2") + 1)
					setPlayFrame("throw-1");
			}
		}
		override public function die(dmgSrc:LevObj=null):void
		{
			super.die(dmgSrc);
			STAT_MNGR.numHammerBrosDefeated++;
		}
		private function evilHammerBrosHandler(event:Event):void
		{
			evil = Cheats.evilHammerBros;
			if (evil)
				setState(ST_CHASE);
			else if (chaseTmr)
			{
				setState(ST_NORMAL);
				xWaveLeft = nx - TILE_SIZE*.5;
				xWaveRight = nx + TILE_SIZE*.5;
			}
		}
		override protected function removeListeners():void
		{
			super.removeListeners();
			if (JUMP_TMR && JUMP_TMR.hasEventListener(TimerEvent.TIMER_COMPLETE)) JUMP_TMR.removeEventListener(TimerEvent.TIMER_COMPLETE,jumpTmrLsr);
			if (HAMMER_TMR && HAMMER_TMR.hasEventListener(TimerEvent.TIMER_COMPLETE)) HAMMER_TMR.removeEventListener(TimerEvent.TIMER_COMPLETE,hammerTmrLsr);
			if (HAMMER_DEL_TMR && HAMMER_DEL_TMR.hasEventListener(TimerEvent.TIMER_COMPLETE)) HAMMER_DEL_TMR.removeEventListener(TimerEvent.TIMER_COMPLETE,hammerDelTmrLsr);
			if (chaseTmr)
				chaseTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,chaseTmrHandler);
			EVENT_MNGR.removeEventListener(CustomEvents.MSG_BX_CHOOSE_ITEM + MenuBoxItems.EVIL_HAMMER_BROS,evilHammerBrosHandler);
		}
		override protected function reattachLsrs():void
		{
			super.reattachLsrs();
			if (JUMP_TMR && !JUMP_TMR.hasEventListener(TimerEvent.TIMER_COMPLETE))
				JUMP_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,jumpTmrLsr);
			if (HAMMER_TMR && !HAMMER_TMR.hasEventListener(TimerEvent.TIMER_COMPLETE))
				HAMMER_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,hammerTmrLsr);
			if (HAMMER_DEL_TMR && !HAMMER_DEL_TMR.hasEventListener(TimerEvent.TIMER_COMPLETE))
				HAMMER_DEL_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,hammerDelTmrLsr);
			if (chaseTmr)
				chaseTmr.addEventListener(TimerEvent.TIMER_COMPLETE,chaseTmrHandler,false,0,true);
			var str:String = CustomEvents.MSG_BX_CHOOSE_ITEM + MenuBoxItems.EVIL_HAMMER_BROS;
			EVENT_MNGR.addEventListener(str,evilHammerBrosHandler,false,0,true);
			evilHammerBrosHandler(new Event(str));
		}
	}

}
