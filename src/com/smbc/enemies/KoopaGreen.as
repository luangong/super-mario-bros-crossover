package com.smbc.enemies
{
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.characters.*;
	import com.smbc.data.AnimationTimers;
	import com.smbc.data.DamageValue;
	import com.smbc.data.EnemyInfo;
	import com.smbc.data.HealthValue;
	import com.smbc.data.HitTester;
	import com.smbc.data.ScoreValue;
	import com.smbc.data.SoundNames;
	import com.smbc.graphics.StarBurst;
	import com.smbc.ground.Brick;
	import com.smbc.ground.Ground;
	import com.smbc.interfaces.ICustomTimer;
	import com.smbc.main.LevObj;
	import com.smbc.projectiles.MarioFireBall;
	import com.smbc.sound.*;

	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.geom.Point;

	public class KoopaGreen extends Enemy
	{
		public static const ENEMY_NUM:int = EnemyInfo.KoopaGreen;
		private const FT_VERT:String = "vetical";
		private const FT_HORZ:String = "horizontal";
		private const FT_JUMP:String = "jump";
		protected const FL_SHELL:String = "shell";
		protected const FL_SHELL_FEET:String = "shellFeet";
		protected static const FL_SHELL_SPIN_END:String = "shellSpinEnd";
		protected static const FL_SHELL_SPIN_START:String = "shellSpinStart";
		protected const FL_WALK_END:String = "walkEnd";
		protected const FL_WALK_START:String = "walkStart";
		private const FL_WING_END:String = "wingEnd";
		private const FL_WING_START:String = "wingStart";
		public const ST_FLY:String = "fly";
		public const ST_WALK:String = "walk";
		public static const ST_KICKED:String = "kicked";
		protected const ST_SHELL:String = "shell";

		private static const HEALTH_WALKING:int = HealthValue.KOOPA_WALKING;
		private static const HEALTH_SHELL:int = 200;
//		private static const HEALTH_PER_LEVEL:int = 200;

		private const BOUNCE_AMT:int = 350;
		private static const BOUNCE_GRAVITY:int = 1500;
		private var bounced:Boolean;

		protected const KICK_SPEED_GROUND:int = 360;
		protected const KICK_SPEED_AIR:int = 190;
		private const HORZ_FLY_VERT_MOVEMENT_SPEED:int = 25;
		private var flyType:String;
		protected const SHELL_TMR_1:CustomTimer = new CustomTimer(3800,1); // legs start appearing
		protected const SHELL_TMR_2:CustomTimer = new CustomTimer(900,1); // bonus score becomes available
		protected const SHELL_TMR_3:CustomTimer = new CustomTimer(250,1); // starts walking
		private const SHOW_LEGS_ANIM_TMR:CustomTimer = AnimationTimers.ANIM_VERY_SLOW_TMR;
		public const NO_HIT_SHELL_TMR:CustomTimer = new CustomTimer(250,1);
		public var red:Boolean;
		public var groundInFront:Boolean = true;
		protected var numContEnemiesHit:int;
		private const HIT_WALL_SND_STR:String = SoundNames.SFX_GAME_HIT_CEILING;
		protected var waveAngle:Number = 0;
		protected var waveSpeed:Number = 1.5;
		protected var waveRange:Number = 85;
		private var yTop:Number;
		private var yBot:Number;
		protected var centerX:int;
		protected var centerY:int;

		public function KoopaGreen(fLab:String)
		{
			if (fLab.indexOf("enemyKoopaGreen") != -1)
					colorNum = 1;
			else if (fLab.indexOf("enemyKoopaRed") != -1)
			{
				red = true;
				colorNum = 2;
			}
			else if (fLab.indexOf("enemyKoopaBlue") != -1)
				colorNum = 3;
			else if (fLab.indexOf("enemyWingedKoopaGreen") != -1)
			{
				setState(ST_FLY);
				flyType = FT_JUMP;
				colorNum = 1;
			}
			else if (fLab.indexOf("enemyWingedKoopaHorizontalGreen") != -1)
			{
				setState(ST_FLY);
				flyType = FT_HORZ;
				defyGrav = true;
				colorNum = 1;
			}
			else if (fLab.indexOf("enemyWingedKoopaRed") != -1)
			{
				setState(ST_FLY);
				flyType = FT_VERT;
				red = true;
				defyGrav = true;
				colorNum = 2;
			}
			else if (fLab.indexOf("enemyWingedKoopaBlue") != -1)
			{
				setState(ST_FLY);
				flyType = FT_JUMP;
				colorNum = 3;
			}
			super();
			stompKills = false;
		}
		override protected function overwriteInitialStats():void
		{
			if (cState == ST_FLY)
			{
				_health = HealthValue.KOOPA_FLYING;
				scoreAttack = ScoreValue.KOOPA_FLYING_ATTACK;
				scoreBelow = ScoreValue.KOOPA_FLYING_BELOW;
				scoreStar = ScoreValue.KOOPA_FLYING_STAR;
				scoreStomp = ScoreValue.KOOPA_FLYING_STOMP;
			}
			else
			{
				_health = HealthValue.KOOPA_WALKING;
				scoreAttack = ScoreValue.KOOPA_ATTACK;
				scoreBelow = ScoreValue.KOOPA_BELOW;
				scoreStar = ScoreValue.KOOPA_STAR;
				scoreStomp = ScoreValue.KOOPA_STOMP;
			}
			super.overwriteInitialStats();
		}
		override protected function takeDamage(dmg:int,dmgSrc:LevObj = null):void
		{
			super.takeDamage(dmg,dmgSrc);
			if (cState != ST_DIE && !getStatusEffect(STATFX_FREEZE))
			{
				if ( _health <= HEALTH_SHELL && (cState == ST_FLY || cState == ST_WALK) )
					enterShell();
				else if (_health <= HEALTH_WALKING && cState == ST_FLY)
				{
					startWalk(scaleX);
					red = false;
				}
			}
		}
		override protected function activateBouncyPit():void
		{
			if (cState == ST_FLY)
				return;
			else
				super.activateBouncyPit();
		}
		// SETSTATS sets statistics and initializes character
		override public function setStats():void
		{
			stompable = true;
			numColors = 3;
			xSpeed = defaultWalkSpeed;
			//xSpeedStuck = 150;
			ySpeed = 400;
			gravity = enemyGravDef;
			vx = -xSpeed;
			vyMaxPsv = enemyVYMaxPsvDef;
			addTmr(NO_HIT_SHELL_TMR);
			NO_HIT_SHELL_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,noHitShellTmrHandler,false,0,true);
			addTmr(SHELL_TMR_1);
			SHELL_TMR_1.addEventListener(TimerEvent.TIMER_COMPLETE,shellTmr1Handler,false,0,true);
			addTmr(SHELL_TMR_2);
			SHELL_TMR_2.addEventListener(TimerEvent.TIMER_COMPLETE,shellTmr2Handler,false,0,true);
			addTmr(SHELL_TMR_3);
			SHELL_TMR_3.addEventListener(TimerEvent.TIMER_COMPLETE,shellTmr3Handler,false,0,true);

			if (cState == "fly")
			{
				if (flyType == FT_HORZ)
				{
					vx = 0;
					centerX = x;
					centerY = y;
					yTop = y - TILE_SIZE/2;
					yBot = y + TILE_SIZE/2;
					vy = -HORZ_FLY_VERT_MOVEMENT_SPEED;
					onGround = false;
				}
				else if (flyType == FT_VERT)
				{
					vx = 0;
					centerX = x;
					centerY = y;
					scaleX = -1;
					onGround = false;
				}
				setPlayFrame("wingStart");
			}
			else
			{
				setPlayFrame("walkStart");
				setState(ST_WALK);
			}
			//gravity = 1000;
			super.setStats();
			if (cState == ST_FLY)
				onGround = false;
		}
		override protected function updateStats():void
		{
			super.updateStats();
			// this overrides a bug that the turtle kept coming out of his shell while in kicked state
			var cfl:String = currentFrameLabel;
			if (cState == ST_KICKED)
			{
//				if (cfl != convLab(FL_SHELL))
//					setStopFrame(FL_SHELL);
				if (onGround)
				{
					if (vx > 0)
						vx = KICK_SPEED_GROUND;
					else
						vx = -KICK_SPEED_GROUND;
				}
				else
				{
					if (vx > 0)
						vx = KICK_SPEED_AIR;
					else
						vx = -KICK_SPEED_AIR;
				}
			}
			else if (cState == ST_SHELL && cfl != convLab(FL_SHELL) && cfl != convLab(FL_SHELL_FEET))
				setStopFrame(FL_SHELL);

			if (cState == ST_SHELL && onGround)
				vx = 0;
		}
		// STOMP
		override public function stomp():void
		{
			if (NO_HIT_SHELL_TMR.running || cState == ST_SHELL || !player.canStomp)
				return;
			super.stomp();
			if (cState == ST_FLY)
			{
				red = false;
				startWalk();
			}
			else if ((cState == ST_WALK || cState == ST_KICKED) && !NO_HIT_SHELL_TMR.running)
				enterShell();
		}
		override public function gBounceHit(g:Ground):void
		{
			vy = -BOUNCE_AMT;
			gravity = BOUNCE_GRAVITY;
			onGround = false;
			lastOnGround = false;
			bounced = true;
			updateLoc();
			setHitPoints();
			vx = defaultWalkSpeed;
			if (nx < g.hMidX)
				vx = -vx;
			enterShell();
		}
		private function enterShell():void
		{
			if (cState != ST_KICKED)
				hitTestTypesDct.removeItem(HT_CHARACTER);
			defyGrav = false;
			destroyOffScreen = false;
			setState(ST_SHELL);
			setStopFrame(FL_SHELL);
			stompable = false;
			SHELL_TMR_1.reset();
			SHELL_TMR_2.reset();
			SHELL_TMR_3.reset();
			SHELL_TMR_1.start();
			if (!bounced)
				vx = 0;
			bounced = false;
		}
		// legs start coming out
		protected function shellTmr1Handler(e:TimerEvent):void
		{
			SHELL_TMR_1.reset();
			if (cState != ST_SHELL)
				return;
			ACTIVE_ANIM_TMRS_DCT.addItem(SHOW_LEGS_ANIM_TMR);
			SHELL_TMR_2.start();
		}
		// starts kick shell bonus
		private function shellTmr2Handler(e:TimerEvent):void
		{
			SHELL_TMR_2.reset();
			if (cState != ST_SHELL)
				return;
			SHELL_TMR_3.start();
		}
		// SHELLTMRLSR
		private function shellTmr3Handler(e:TimerEvent):void
		{
			SHELL_TMR_3.reset();
			if (cState != ST_SHELL)
				return;
			if (mainAnimTmr != SHOW_LEGS_ANIM_TMR)
				ACTIVE_ANIM_TMRS_DCT.removeItem(SHOW_LEGS_ANIM_TMR);
			startWalk();
		}
		// NOTHITSHELLTMRLSR
		private function noHitShellTmrHandler(e:TimerEvent):void
		{
			NO_HIT_SHELL_TMR.reset();
		}
		private function startWalk(forceDir:int = 0):void
		{
			defyGrav = false;
			destroyOffScreen = false;
			setPlayFrame(FL_WALK_START);
			if (stopUpdate)
				stopAnim = true;
			setState(ST_WALK);
			stompable = true;
			if (forceDir == 1)
				vx = xSpeed;
			else if (forceDir == -1)
				vx = -xSpeed;
			else
			{
				if (scaleX > 0)
					vx = xSpeed;
				else
					vx = -xSpeed;
			}
			if (!onGround)
			{
				vy = 0;
				if (player.nx > nx)
					vx = xSpeed;
				else
					vx = -xSpeed;
			}
			if (vx > 0)
				scaleX = 1;
			else
				scaleX = -1;
		}
		override protected function checkState():void
		{
			if (!onGround)
			{
				if (cState == ST_FLY)
				{
					if (flyType == FT_VERT)
					{
						ny = centerY + Math.sin(waveAngle) * waveRange;
						waveAngle += waveSpeed*dt;
					}
					else if (flyType == FT_HORZ)
					{
						var lastNx:Number = nx;
						nx = centerX + Math.sin(waveAngle) * waveRange;
						waveAngle += waveSpeed*dt;
						if (nx > lastNx)
							scaleX = 1;
						else
							scaleX = -1;
						if (ny <= yTop)
							vy = HORZ_FLY_VERT_MOVEMENT_SPEED;
						else if (ny >= yBot)
							vy = -HORZ_FLY_VERT_MOVEMENT_SPEED;
					}
				}
				else
					falling = true;
			}
			else // onGround
			{
				if (cState == ST_FLY && flyType == FT_JUMP)
					vy = -ySpeed;
				else if (cState == ST_WALK)
				{
					if (falling)
					{
						if (player.nx >= nx) vx = xSpeed;
						else vx = -xSpeed;
					}
					if (red && !groundInFront)
					{
						vx = -vx;
						updDirection();
					}
				}
				falling = false;
			}
			groundInFront = false;
			super.checkState();
			// check state
		}
		private function kickShell(char:Character,side:String):void
		{
			var numPoints:int;
			if (SHELL_TMR_3.running)
				numPoints = ScoreValue.KICK_SHELL_RIGHT_BEFORE_WALK;
			else if (SHELL_TMR_2.running)
				numPoints = ScoreValue.KICK_SHELL_WHILE_LEGS_ARE_OUT;
			else if (player.numContStomps > 0)
				numPoints = ScoreValue.KICK_SHELL_AFTER_STOMP;
			else
				numPoints = ScoreValue.KICK_SHELL_NORMAL;
			SHELL_TMR_1.reset();
			SHELL_TMR_2.reset();
			SHELL_TMR_3.reset();
			stompable = true;
			level.scorePop(numPoints,nx,hTop-SP_Y_OFFSET);
			stopUpdate = false;
			if (char.nx >= nx)
				vx = -KICK_SPEED_GROUND;
			else
				vx = KICK_SPEED_GROUND;
			level.addToLevel( new StarBurst(this,StarBurst.TYPE_SHELL_KICK) );
			setState(ST_KICKED);
			numContEnemiesHit = 0;
			if (mainAnimTmr != SHOW_LEGS_ANIM_TMR)
				ACTIVE_ANIM_TMRS_DCT.removeItem(SHOW_LEGS_ANIM_TMR);
			SND_MNGR.playSound(SFX_GAME_KICK_SHELL);
			setPlayFrame(FL_SHELL_SPIN_START);
			NO_HIT_SHELL_TMR.start();
			destroyOffScreen = true;
			hitTestTypesDct.addItem(HT_CHARACTER);
		}
		override public function groundOnSide(g:Ground,side:String):void
		{
			super.groundOnSide(g,side);
			if (cState == "kicked" && !stopUpdate)
			{
				SND_MNGR.playSound(HIT_WALL_SND_STR);
				level.addToLevel( new StarBurst(this,StarBurst.TYPE_SHELL_WALL) );
			}
		}
		override public function hitEnemy(enemy:Enemy,side:String):void
		{
			if (enemy.cState == ST_DIE || cState == ST_SHELL)
				return;
			if (cState == ST_KICKED)
			{
				level.addToLevel( new StarBurst(this,StarBurst.TYPE_SHELL_ENEMY) );
				enemy.die();
				numContEnemiesHit++;
				var numPoints:int;
				switch (numContEnemiesHit)
				{
					case 1:
					{
						numPoints = ScoreValue.SHELL_KICK_SEQ_1;
						break;
					}
					case 2:
					{
						numPoints = ScoreValue.SHELL_KICK_SEQ_2;
						break;
					}
					case 3:
					{
						numPoints = ScoreValue.SHELL_KICK_SEQ_3;
						break;
					}
					case 4:
					{
						numPoints = ScoreValue.SHELL_KICK_SEQ_4;
						break;
					}
					case 5:
					{
						numPoints = ScoreValue.SHELL_KICK_SEQ_5;
						break;
					}
					case 6:
					{
						numPoints = ScoreValue.SHELL_KICK_SEQ_6;
						break;
					}
					case 7:
					{
						numPoints = ScoreValue.SHELL_KICK_SEQ_7;
						break;
					}
					default:
					{
						numPoints = ScoreValue.SHELL_KICK_SEQ_MAX;
						break;
					}
				}
				level.scorePop(numPoints,nx,hTop - SP_Y_OFFSET);
				return;
			}
			super.hitEnemy(enemy,side);
		}
		override public function checkFrame():void
		{
			var cf:int = currentFrame;
			if (cState == ST_WALK && cf == getLabNum("walkEnd") + 1)
				setPlayFrame("walkStart");
			else if (cState == "fly" && cf == getLabNum("wingEnd") + 1)
				setPlayFrame("wingStart");
			else if (cState == ST_KICKED && cf == getLabNum(FL_SHELL_SPIN_END) + 1)
				setPlayFrame(FL_SHELL_SPIN_START);
		}
		override public function hitCharacter(char:Character,side:String):void
		{
			if (cState == ST_SHELL)
				kickShell(char,side);
			super.hitCharacter(char,side);
		}
		override public function hitGround(mc:Ground, hType:String):void
		{
			if (cState == ST_KICKED && mc is Brick && (hType == HitTester.SIDE_LEFT || hType == HitTester.SIDE_RIGHT) )
			{
				var brick:Brick = mc as Brick;
				brick.breakBrick();
			}
			super.hitGround(mc, hType);
		}
		override public function die(dmgSrc:LevObj = null):void
		{
			setStopFrame(FL_SHELL);
			super.die(dmgSrc);
		}
		override public function animate(ct:ICustomTimer):Boolean
		{
			var bool:Boolean = super.animate(ct);
			if (ct == SHOW_LEGS_ANIM_TMR && (SHELL_TMR_2.running || SHELL_TMR_3.running) )
			{
				var cl:String = currentLabel;
				if (cl == convLab(FL_SHELL) )
					setStopFrame(FL_SHELL_FEET);
				else if (cl == convLab(FL_SHELL_FEET) )
					setStopFrame(FL_SHELL);
			}
			return bool;
		}
		override protected function removeListeners():void
		{
			super.removeListeners();
			SHELL_TMR_1.removeEventListener(TimerEvent.TIMER_COMPLETE,shellTmr1Handler);
			SHELL_TMR_2.removeEventListener(TimerEvent.TIMER_COMPLETE,shellTmr2Handler);
			SHELL_TMR_3.removeEventListener(TimerEvent.TIMER_COMPLETE,shellTmr3Handler);
			NO_HIT_SHELL_TMR.removeEventListener(TimerEvent.TIMER_COMPLETE,noHitShellTmrHandler);
		}
		override protected function reattachLsrs():void
		{
			super.reattachLsrs();
			SHELL_TMR_1.addEventListener(TimerEvent.TIMER_COMPLETE,shellTmr1Handler,false,0,true);
			SHELL_TMR_2.addEventListener(TimerEvent.TIMER_COMPLETE,shellTmr2Handler,false,0,true);
			SHELL_TMR_3.addEventListener(TimerEvent.TIMER_COMPLETE,shellTmr3Handler,false,0,true);
			NO_HIT_SHELL_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,noHitShellTmrHandler,false,0,true);
		}
	}
}
