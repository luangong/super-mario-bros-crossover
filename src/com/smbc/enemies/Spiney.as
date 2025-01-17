package com.smbc.enemies
{
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.data.EnemyInfo;
	import com.smbc.data.HealthValue;
	import com.smbc.data.ScoreValue;
	import com.smbc.ground.Ground;
	import com.smbc.main.LevObj;

	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.geom.Point;

//	[Embed(source="../assets/swfs/SmbcGraphics.swf", symbol="Spiney")]
	public class Spiney extends Goomba
	{
		public static const ENEMY_NUM:int = EnemyInfo.Spiney;
		private var lakitu:Lakitu;
		protected var throwPwr:int = 300;
		private const BOUNCE_AMT:int = 350;
		private static const BOUNCE_GRAVITY:int = 1500;
		private var bounced:Boolean;

		public function Spiney():void
		{
			super("null");
		}
		// SETSTATS sets statistics and initializes character
		override public function setStats():void
		{
			super.setStats();
			numColors = 1;
			stompable = false;
			vyMaxPsv = 325;
			onGround = false;
			if (lakitu)
			{
				setState("ball");
				nx = lakitu.nx;
				ny = lakitu.ny;
				x = nx;
				y = ny;
				vx = 0;
				vy = -throwPwr;
				setPlayFrame("ballStart");
				destroyOffScreen = true;
			}
		}
		override protected function overwriteInitialStats():void
		{
			super.overwriteInitialStats();
			_health = HealthValue.SPINEY;
			scoreAttack = ScoreValue.SPINEY_ATTACK;
			scoreBelow = ScoreValue.SPINEY_BELOW;
			scoreStar = ScoreValue.SPINEY_STAR;
			scoreStomp = ScoreValue.SPINEY_STOMP;
		}

		override protected function checkState():void
		{
			if (cState == "ball")
			{
				if (onGround)
				{
					setState("neutral");
					setPlayFrame("walkStart");
					if (nx > player.nx)
						vx = -xSpeed;
					else
						vx = xSpeed;
					updDirection();
				}
			}
			else if (cState != "ball" && !onGround)
			{
				falling = true;
			}
			else if (cState != "ball" && onGround)
			{
				if (falling && !bounced)
				{
					if (nx > player.nx)
						vx = -xSpeed;
					else
						vx = xSpeed;
				}
				else
				{
					bounced = false;
				}
				falling = false;
			}
//			else if ( vx == 0 && !getStatusEffect(STATFX_STOP) )
//				vx = xSpeed*scaleX;
			super.checkState();
		}
		override public function stomp():void
		{
			// nothing
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
			if (nx < g.hMidX)
				vx = -vx;
		}

		override public function checkFrame():void
		{
			if (cState == "ball" && currentFrame == getLabNum("ballEnd") + 1)
				setPlayFrame("ballStart");
			super.checkFrame();
		}
		override public function die(dmgSrc:LevObj = null):void
		{
			super.die(dmgSrc);
			setStopFrame("walkStart");
		}
		public function getLakitu(_lakitu:Lakitu):void
		{
			lakitu = _lakitu;
		}
		override public function cleanUp():void
		{
			super.cleanUp();
			if (lakitu)
				lakitu.SPINEY_DCT.removeItem(this);
		}
	}
}
