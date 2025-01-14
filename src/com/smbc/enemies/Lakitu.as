package com.smbc.enemies
{
	import com.explodingRabbit.cross.gameplay.statusEffects.StatusProperty;
	import com.explodingRabbit.utils.CustomDictionary;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.characters.Samus;
	import com.smbc.data.Cheats;
	import com.smbc.data.EnemyInfo;
	import com.smbc.data.GameSettings;
	import com.smbc.data.HealthValue;
	import com.smbc.data.MapDifficulty;
	import com.smbc.data.MusicType;
	import com.smbc.data.ScoreValue;
	import com.smbc.data.ScreenSize;
	import com.smbc.data.SoundNames;
	import com.smbc.events.CustomEvents;
	import com.smbc.interfaces.ICustomTimer;
	import com.smbc.level.LakituSpawner;
	import com.smbc.level.Level;
	import com.smbc.main.LevObj;
	import com.smbc.managers.GameStateManager;

	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;

	[Embed(source="../assets/swfs/SmbcGraphics.swf", symbol="Lakitu")]
	public class Lakitu extends Enemy
	{
		public static const ENEMY_NUM:int = EnemyInfo.Lakitu;
		private static const MIDDLE_Y:Number = ScreenSize.SCREEN_HEIGHT/2;
		protected var lakSpwnr:LakituSpawner;
		protected var throwTmrDur:int = 250;
		protected var throwTmr:CustomTimer;
		protected var hideTmrDur:int = 1500;
		protected var hideTmr:CustomTimer;
		private const FL_HIDE:String = "hide";
		private const FL_NORMAL:String = "normal";
		public const SPINEY_DCT:CustomDictionary = new CustomDictionary();
//		private const MAX_SPINEYS:int = 4;
		private var maxSpinyDifficulty:int = 4;
		private const DEF_VX_MAX:int = 200;
		private const VX_MAX_INCREASE_NUM:int = 100;
//		private const STUN_DUR:int = 1000;
		private const EXIT_SPEED:int = 100;
		private const START_FOLLOW_DEL_TMR:CustomTimer = new CustomTimer(800,1);
		private var withinBoundaries:Boolean;
		private var edgeBuffer:Number;
		private var exiting:Boolean;
		private var followDir:String;
		private const FD_RHT:String = "right";
		private const FD_LFT:String = "left";
		private var followPlayer:Boolean;
		private var MIN_CHANGE_DIR_DIST:int;

		public function Lakitu(lakituSpawner:LakituSpawner, middlePosition:Boolean)
		{
			super();
			this.lakSpwnr = lakituSpawner;
			MIN_CHANGE_DIR_DIST = Level.levelInstance.TILE_SIZE;
//			for each (var es:Object in level.ENEMY_SPAWNER_DCT)
//			{
//				if (es is LakituSpawner)
//					lakSpwnr = es as LakituSpawner;
//			}
			addProperty( new StatusProperty(PR_STOP_PAS,10) );
			addProperty( new StatusProperty(PR_FREEZE_PAS,10) );
			addProperty( new StatusProperty(StatusProperty.TYPE_KNOCK_BACK_PAS,10) );
			edgeBuffer = TILE_SIZE*2;
			y = GLOB_STG_TOP + TILE_SIZE*3;
			if (middlePosition)
				y = MIDDLE_Y;
			x = locStgRht + width*.5;
			updateOffScreen = true;
			addTmr(START_FOLLOW_DEL_TMR);
			START_FOLLOW_DEL_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,startFollowDelTmrHandler,false,0,true);
//			BOOM_STUN_TMR.delay = STUN_DUR;
			removeAllHitTestableItems();
			addHitTestableItem(HT_CHARACTER);
			addHitTestableItem(HT_PROJECTILE_CHARACTER);
			//if (player is Samus)
			//	ATK_STUN_TMR.delay /= 6;
		}
		override protected function overwriteInitialStats():void
		{
			_health = HealthValue.LAKITU;
			scoreAttack = ScoreValue.LAKITU_ATTACK;
			scoreBelow = ScoreValue.LAKITU_BELOW;
			scoreStar = ScoreValue.LAKITU_STAR;
			scoreStomp = ScoreValue.LAKITU_STOMP;
			super.overwriteInitialStats();
		}
		// SETSTATS sets statistics and initializes character
		override public function setStats():void
		{
			stompable = true;
			numColors = 1;
			ax = 200;
			fx = .00000000001;
			vx = 0;
			vy = 0;
			vxMax = DEF_VX_MAX;
			defyGrav = true;
			setStopFrame(FL_NORMAL);
			setState("neutral");
			//gravity = 1000;
			super.setStats();
			onGround = false;
			vx = 0;
			throwTmr = new CustomTimer(throwTmrDur,1);
			addTmr(throwTmr);
			throwTmr.addEventListener(TimerEvent.TIMER_COMPLETE,throwTmrLsr);
			hideTmr = new CustomTimer(hideTmrDur,1);
			addTmr(hideTmr);
			hideTmr.addEventListener(TimerEvent.TIMER_COMPLETE,hideTmrLsr);
			hideTmr.start();
		}
		/*override protected function updateStats():void
		{
			returnFromFlashFrame();
			super.updateStats();
		}*/
		/*override protected function stall(flash:Boolean):void
		{
			super.stall(flash);
			if (BOOM_STUN_TMR.running)
				return;
			stopUpdate = false;
			stunned = false;
			resumeTimers();
		}*/
		override protected function checkState():void
		{
			vxMax = DEF_VX_MAX;
			if (player.nx > lakSpwnr.enemyEndPos)
			{
				vx = -EXIT_SPEED;
				setStopFrame(FL_NORMAL);
				destroyOffScreen = true;
				updateOffScreen = false;
				if (!exiting)
				{
					stopTimers();
					exiting = true;
				}
				return;
			}
			else
			{
				if (exiting)
				{
					resumeTimers();
					destroyOffScreen = false;
					updateOffScreen = true;
				}
				exiting = false;
			}
			if (withinBoundaries && nx < locStgLft + edgeBuffer)
			{
				if (player.vx > 0 && vx < player.vx)
					vx = player.vx;
				nx = locStgLft + edgeBuffer;
				if (stunned)
				{
					stunned = false;
					stopUpdate = false;
					stopHit = false;
				}
			}
			else if (withinBoundaries && nx > locStgRht - edgeBuffer)
			{
				if (player.vx < 0 && vx > player.vx)
					vx = player.vx;
				nx = locStgRht - edgeBuffer;
				if (stunned)
				{
					stunned = false;
					stopUpdate = false;
					stopHit = false;
				}
			}
			if ((followDir == FD_LFT && (player.rhtBtn || !player.lftBtn)) || (followDir == FD_RHT && (player.lftBtn || !player.rhtBtn)))
				cancelFollow();
			if (!withinBoundaries)
			{
				vx = -vxMax;
				if (nx < locStgRht - edgeBuffer)
					withinBoundaries = true;
			}
			if (followPlayer)
			{
				if (followDir == FD_RHT)
				{
					vx += ax*dt;
					if (player.vx > DEF_VX_MAX - VX_MAX_INCREASE_NUM)
						vxMax = player.vx + VX_MAX_INCREASE_NUM;
				}
				else if (followDir == FD_LFT)
				{
					vx -= ax*dt;
					if (player.vx < -DEF_VX_MAX + VX_MAX_INCREASE_NUM)
						vxMax = -(player.vx - VX_MAX_INCREASE_NUM);
				}
				else
					cancelFollow();
			}
			else // if (!followPlayer)
			{
				if (player.rhtBtn)
				{
					if (!START_FOLLOW_DEL_TMR.running)
					{
						START_FOLLOW_DEL_TMR.start();
						followDir = FD_RHT;
					}
				}
				else if (player.lftBtn)
				{
					if (!START_FOLLOW_DEL_TMR.running)
					{
						START_FOLLOW_DEL_TMR.start();
						followDir = FD_LFT;
					}
				}
				var playerDist:int = nx - player.nx;
				if (playerDist < 0)
					playerDist = -playerDist;
				if (nx > player.nx)
				{
					if (playerDist < MIN_CHANGE_DIR_DIST && vx > 50)
						vx += ax*dt;
					else
						vx -= ax*dt;
				}
				else
				{
					if (playerDist < MIN_CHANGE_DIR_DIST && vx < -50)
						vx -= ax*dt;
					else
						vx += ax*dt;
				}
			}

			switch(GameSettings.mapDifficulty)
			{
				case MapDifficulty.EASY:
					maxSpinyDifficulty = 2;
					break;
				case MapDifficulty.NORMAL:
					maxSpinyDifficulty = 4;
					break;
				case MapDifficulty.HARD:
					maxSpinyDifficulty = 6;
					break;
				default:
					break;
			}

			if (cState == "wait" && SPINEY_DCT.length < maxSpinyDifficulty)
				throwSpiney();
			super.checkState();
		}
		private function cancelFollow():void
		{
			START_FOLLOW_DEL_TMR.reset();
			followPlayer = false;
			followDir = null;
		}
		private function startFollowDelTmrHandler(e:TimerEvent):void
		{
			START_FOLLOW_DEL_TMR.reset();
			followPlayer = true;
		}
		private function hideTmrLsr(e:TimerEvent):void
		{
			hideTmr.reset();
			setStopFrame(FL_HIDE);
			throwTmr.start();
		}
		private function throwTmrLsr(e:TimerEvent):void
		{
			if (cState != ST_DIE)
			{
				throwTmr.reset();
				if (SPINEY_DCT.length < maxSpinyDifficulty)
					throwSpiney();
				else setState("wait");
			}
		}
		private function throwSpiney():void
		{
			if (cState != ST_DIE)
			{
				if (Cheats.allHammerBros)
				{
					var hb:HammerBro = new HammerBro(null);
					hb.x = nx;
					hb.y = ny;
					hb.addEventListener(CustomEvents.CLEAN_UP,enemyCleanUpHandler,false,0,true);
					level.addToLevel(hb);
					hb.dosLft = true;
					SPINEY_DCT.addItem(hb);
				}
				else
				{
					var spiney:Spiney = new Spiney();
					spiney.getLakitu(this);
					level.addToLevel(spiney);
					SPINEY_DCT.addItem(spiney);
				}
				setStopFrame(FL_NORMAL);
				setState("neutral");
				hideTmr.start();
			}
		}
		override public function stomp():void
		{
			if (!player.canStomp)
				return;
			super.stomp();
			die();
			SND_MNGR.removeStoredSound(SoundNames.SFX_GAME_KICK_SHELL);
			vx = 0;
			vy = 0;
		}
		override public function die(dmgSrc:LevObj = null):void
		{
			super.die(dmgSrc);
			updateOffScreen = false;
		}
		override public function animate(ct:ICustomTimer):Boolean
		{
			stopAnim = true;
			return super.animate(ct);
		}
		private function enemyCleanUpHandler(event:Event):void
		{
			var enemy:Enemy = event.target as Enemy;
			enemy.removeEventListener(CustomEvents.CLEAN_UP,enemyCleanUpHandler);
			SPINEY_DCT.removeItem(enemy);
		}

		override public function cleanUp():void
		{
			super.cleanUp();
			if (lakSpwnr)
				lakSpwnr.ENEMY_DCT.removeItem(this);
		}
		override protected function removeListeners():void
		{
			super.removeListeners();
			if (throwTmr && throwTmr.hasEventListener(TimerEvent.TIMER_COMPLETE)) throwTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,throwTmrLsr);
			if (hideTmr && hideTmr.hasEventListener(TimerEvent.TIMER_COMPLETE)) hideTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,hideTmrLsr);
			START_FOLLOW_DEL_TMR.removeEventListener(TimerEvent.TIMER_COMPLETE,startFollowDelTmrHandler);
		}
		override protected function reattachLsrs():void
		{
			super.reattachLsrs();
			if (throwTmr && !throwTmr.hasEventListener(TimerEvent.TIMER_COMPLETE)) throwTmr.addEventListener(TimerEvent.TIMER_COMPLETE,throwTmrLsr);
			if (hideTmr && !hideTmr.hasEventListener(TimerEvent.TIMER_COMPLETE)) hideTmr.addEventListener(TimerEvent.TIMER_COMPLETE,hideTmrLsr);
			START_FOLLOW_DEL_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,startFollowDelTmrHandler,false,0,true);
		}
	}
}
