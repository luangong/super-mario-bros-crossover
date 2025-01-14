package com.smbc.enemies
{
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.data.EnemyInfo;
	import com.smbc.data.HealthValue;
	import com.smbc.data.ScoreValue;
	import com.smbc.data.SoundNames;
	import com.smbc.interfaces.ICustomTimer;
	import com.smbc.main.GlobVars;

	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.geom.Point;

	[Embed(source="../assets/swfs/SmbcGraphics.swf", symbol="Bloopa")]
	public class Bloopa extends Enemy
	{
		public static const ENEMY_NUM:int = EnemyInfo.Bloopa;

		protected var fxy:Number;
		protected var axy:Number;
		protected var yMaxDist:Number;
		protected var yStartLoc:Number;
		protected var goRight:Boolean;
		protected var applyFric:Boolean;
		protected var moveDelTmr:CustomTimer;
		protected var moveDelTmrDur:int;
		private const MAX_BOTTOM_Y:int = GlobVars.STAGE_HEIGHT - GlobVars.TILE_SIZE*3.5;

		public function Bloopa()
		{
			super();
			removeAllHitTestableItems();
			addHitTestableItem(HT_CHARACTER);
			addHitTestableItem(HT_PROJECTILE_CHARACTER);

		}
		override protected function overwriteInitialStats():void
		{
			_health = HealthValue.BLOOPA;
			scoreAttack = ScoreValue.BLOOPA_ATTACK;
			scoreBelow = ScoreValue.BLOOPA_BELOW;
			scoreStar = ScoreValue.BLOOPA_STAR;
			scoreStomp = ScoreValue.BLOOPA_STOMP;
			super.overwriteInitialStats();
		}
		// SETSTATS sets statistics and initializes character
		override public function setStats():void
		{
			if (level.waterLevel)
				stompable = false;
			else
				stompable = true;
			numColors = 1;
			axy = 700;
			fxy = .000001;
			yMaxDist = 50;
			//vxMax = 500;
			//vyMaxNgv = 500;
			defyGrav = true;
			//xSpeedStuck = 150;
			ySpeed = 80;
			gravity = 500;
			vyMaxPsv = 400;
			vx = 0;
			vy = ySpeed;
			moveDelTmrDur = 200;
			setState("wait");
			setStopFrame("smushed");
			moveDelTmr = new CustomTimer(moveDelTmrDur,1);
			moveDelTmr.addEventListener(TimerEvent.TIMER_COMPLETE,moveDelTmrLsr);
			addTmr(moveDelTmr);
			moveDelTmr.start();

			//gravity = 1000;
			super.setStats();
		}

		override public function stomp():void
		{
			if (!stompable || !player.canStomp)
				return;
			super.stomp();
			die();
			SND_MNGR.removeStoredSound(SoundNames.SFX_GAME_KICK_SHELL);
			vx = 0;
			vy = 0;
		}

		override protected function updateStats():void
		{
			super.updateStats();
			if (cState == "ready" && (player.ny < ny || ny > MAX_BOTTOM_Y))
			{
				setState("chase");
				setStopFrame("stretched");
				yStartLoc = ny;
				if
					(player.nx > nx) goRight = true;
				else
					goRight = false;
				vx = 0;
				vy = 0;
			}
			if (cState == "chase")
			{
				vy -= axy*dt;
				if (goRight)
					vx += axy*dt;
				else
					vx -= axy*dt;
				if (yStartLoc - ny > yMaxDist || ny < GLOB_STG_TOP + TILE_SIZE*4) applyFric = true;
				if (applyFric)
				{
					vx *= Math.pow(fxy,dt);
					vy *= Math.pow(fxy,dt);
					if (vy < 50 && vy > -50)
					{
						vx = 0;
						vy = ySpeed;
						applyFric = false;
						setState("wait");
						setStopFrame("smushed");
						moveDelTmr.start();
					}
				}
			}
		}
		private function moveDelTmrLsr(e:TimerEvent):void
		{
			if (cState != "die")
				setState("ready");
			moveDelTmr.reset();
		}
		override public function animate(ct:ICustomTimer):Boolean
		{
			stopAnim = true;
			return super.animate(ct);
		}
		override protected function removeListeners():void
		{
			super.removeListeners();
			if (moveDelTmr && moveDelTmr.hasEventListener(TimerEvent.TIMER_COMPLETE))
				moveDelTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,moveDelTmrLsr);

		}
		override protected function reattachLsrs():void
		{
			super.reattachLsrs();
			if (moveDelTmr && !moveDelTmr.hasEventListener(TimerEvent.TIMER_COMPLETE))
				moveDelTmr.addEventListener(TimerEvent.TIMER_COMPLETE,moveDelTmrLsr);
		}
	}
}
