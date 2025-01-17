package com.smbc.enemies
{
	import com.explodingRabbit.cross.gameplay.statusEffects.StatusProperty;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.data.EnemyInfo;
	import com.smbc.data.HealthValue;
	import com.smbc.data.ScoreValue;
	import com.smbc.main.*;

	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.geom.Point;


	public class PiranhaGreen extends Enemy
	{
		public static const RED:String = "Red";
		public static const GREEN:String = "Green";
		public static const UPSIDE_DOWN_STR:String = "UpsideDown";
		public var upsideDown:Boolean;
		public static const ENEMY_NUM:int = EnemyInfo.PiranhaGreen;
		private const WAIT_TMR:CustomTimer = new CustomTimer(1000,1);
		private var abovePipe:Boolean;
		private var inY:Number;
		public var outY:Number;
		private var verticalDirection:int = 1;
		protected var riseWhenNearPlayer:Boolean; // deprecated
		private var readyToRise:Boolean;
		private var stopRiseY:Number;
		protected var stopRiseRightX:Number;
		protected var stopRiseLeftX:Number;
		private const PIR_HEIGHT:int = 46;
		private var pipeLeft:Number;
		private var pipeRight:Number;
		public var originalX:Number;
		public var originalY:Number;

		public function PiranhaGreen(fLab:String)
		{
//			if (fLab.indexOf("enemyPiranhaGreen") != -1)
//				colorNum = 1;
//			else if (fLab.indexOf("enemyPiranhaBlue") != -1)
//				colorNum = 2;
			super();
			if (fLab.indexOf(UPSIDE_DOWN_STR) != -1)
				upsideDown = true;
			removeAllHitTestableItems();
			addHitTestableItem(HT_CHARACTER);
			addHitTestableItem(HT_PROJECTILE_CHARACTER);
			addProperty( new StatusProperty(StatusProperty.TYPE_KNOCK_BACK_PAS,10) );
		}
		override protected function overwriteInitialStats():void
		{
			_health = HealthValue.PIRANHA;
			scoreAttack = ScoreValue.PIRANHA_ATTACK;
			scoreBelow = ScoreValue.PIRANHA_BELOW;
			scoreStar = ScoreValue.PIRANHA_STAR;
			scoreStomp = ScoreValue.PIRANHA_STOMP;
			super.overwriteInitialStats();
		}
		// SETSTATS sets statistics and initializes character
		override public function setStats():void
		{
			originalX = x;
			originalY = y;
			if (!upsideDown)
			{
				outY = y;
				y += PIR_HEIGHT;
				inY = y;
				stopRiseY = outY - TILE_SIZE*12;
			}
			else
			{
				scaleY = -1;
				outY = y;
				y -= PIR_HEIGHT;
				inY = y;
				verticalDirection = -1;
				stopRiseY = outY + TILE_SIZE*10;
			}
			behindGround = true;
			numColors = 2;
			stompable = false;
			defyGrav = true;
			setPlayFrame("open");
			pipeLeft = x - TILE_SIZE;
			pipeRight = x + TILE_SIZE;
			stopRiseLeftX = x - TILE_SIZE*2;
			stopRiseRightX = x + TILE_SIZE*2;
			ySpeed = 75 * verticalDirection;
			vy = 0;
			readyToRise = true;
			setState("below");
			y = inY;
			ny = inY;
			abovePipe = false;
			super.setStats();
			addTmr(WAIT_TMR);
			WAIT_TMR.addEventListener(TimerEvent.TIMER,waitTmrLsr);
		}
		override public function rearm():void
		{
			super.rearm();
			setState("below");
			ny = inY;
			y = ny;
			abovePipe = false;
			readyToRise = true;
			vy = 0;
			WAIT_TMR.reset();

		}
		// UPDATELOC
		override protected function checkState():void
		{
			if (vy != 0)
			{
				if ( ( (!upsideDown && ny <= outY) || (upsideDown && ny >= outY) ) && cState == "rise")
				{
					setState("above");
					WAIT_TMR.start();
					ny = outY;
					vy = 0;
				}
				else if ( ( (!upsideDown && ny >= inY) || (upsideDown && ny <= inY) ) && cState == "lower")
				{
					setState("below");
					stopHit = true;
					WAIT_TMR.start();
					ny = inY;
					vy = 0;
				}
			}
			if (readyToRise && onScreen && !( player.nx > stopRiseLeftX && player.nx < stopRiseRightX && ( (!upsideDown && player.ny > stopRiseY) || (upsideDown && player.ny < stopRiseY) ) ) )
			{
				if ( !(player.hRht > pipeLeft && player.hLft < pipeRight && player.hBot <= outY && !upsideDown) ) // make sure player isn't above pipe
				{
					vy = -ySpeed;
					scaleX = (player.nx >= nx) ? 1 : -1;
					setState("rise");
					stopHit = false;
					readyToRise = false;
				}
			}
			super.checkState();
		}
		private function waitTmrLsr(e:TimerEvent):void
		{
			WAIT_TMR.reset();
			if (cState == "above")
			{
				vy = ySpeed;
				setState("lower");
			}
			else if (cState == "below")
			{
				readyToRise = true;
			}
		}
		override public function stomp():void
		{
			// nothing
		}
		override public function die(dmgSrc:LevObj = null):void
		{
			super.die(dmgSrc);
			destroy()
		}
		override public function checkFrame():void
		{
			if (currentFrame == getLabNum("close") + 1)
				setPlayFrame("open");
		}
		override protected function removeListeners():void
		{
			super.removeListeners();
			WAIT_TMR.removeEventListener(TimerEvent.TIMER,waitTmrLsr);
		}
		override protected function reattachLsrs():void
		{
			super.reattachLsrs();
			WAIT_TMR.addEventListener(TimerEvent.TIMER,waitTmrLsr);
		}
	}
}
