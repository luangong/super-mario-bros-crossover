package com.smbc.enemies
{
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.characters.Mario;
	import com.smbc.characters.base.MarioBase;
	import com.smbc.data.Cheats;
	import com.smbc.data.EnemyInfo;
	import com.smbc.data.HealthValue;
	import com.smbc.data.ScoreValue;
	import com.smbc.level.FlyingCheepSpawner;
	import com.smbc.main.*;

	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.geom.Point;

	public class CheepFast extends Enemy
	{
		public static const ENEMY_NUM:int = EnemyInfo.CheepFast;
		protected var ranLocBuf:int = 5; // number of possible positions
		protected var color:String;
		protected var moveType:String;
		protected var yWaveMid:Number;
		protected var yWaveTop:Number;
		protected var yWaveBot:Number;
		public var flying:Boolean;
		private const MAX_HORZ_FLY_SPEED:int = 250;
		private const MIN_HORZ_FLY_SPEED:int = 50;
		private const FLYING_GRAVITY:int = 375;
		private const FLYING_GRAVITY_DIE:int = 650;
		private static const FLYING_JUMP_PWR:int = 555;
		private static const VY_BOUNCY_PITS:int = -FLYING_JUMP_PWR;
		protected var fcs:FlyingCheepSpawner;
		private var destroyTmr:CustomTimer;
		private var destroyTmrDur:int = 250;

		public function CheepFast(fLab:String,flyingCheepSpawner:FlyingCheepSpawner = null)
		{
			super();
			if (fLab.indexOf("enemyCheepRed") != -1)
			{
				colorNum = 1;
				color = "red";
				calcMovement();
			}
			else if (fLab.indexOf("enemyCheepGreen") != -1)
			{
				colorNum = 2;
				color = "gray";
				calcMovement();
			}
			else if (fLab.indexOf("enemyCheepGray") != -1)
			{
				colorNum = 3;
				color = "gray";
				calcMovement();
			}
			else if (fLab.indexOf("flying") != -1)
			{
				colorNum = 1;
				flying = true;
				fcs = flyingCheepSpawner;
			}
			removeAllHitTestableItems();
			addHitTestableItem(HT_CHARACTER);
			addHitTestableItem(HT_PROJECTILE_CHARACTER);
			bouncyPitsVy = VY_BOUNCY_PITS;
		}
		override protected function overwriteInitialStats():void
		{
			super.overwriteInitialStats();
			_health = HealthValue.CHEEP_SWIMMING;
			scoreAttack = ScoreValue.CHEEP_ATTACK;
			scoreBelow = ScoreValue.CHEEP_BELOW;
			scoreStar = ScoreValue.CHEEP_STAR;
			scoreStomp = ScoreValue.CHEEP_STOMP;
		}
		private function calcColor():void
		{
			if (Math.random() > .5)
			{
				color = "red";
				colorNum = 1;
			}
			else
			{
				color = "gray";
				colorNum = 3;
			}
		}
		private function calcMovement():void
		{
			if (Math.random() > .5)
			{
				moveType = "wave";
			}
			else
			{
				moveType = "straight";
			}
		}
		private function calcPosition():void
		{
			var i:int;
			var xRanNum:Number = Math.random();
			var yRanNum:Number = Math.random();
			var xNum:int;
			var yNum:int;
			for (i = 1; i < ranLocBuf+1; i++)
			{
				if (xNum == 0 && xRanNum < i/ranLocBuf) xNum = i;
				if (yNum == 0 && yRanNum < i/ranLocBuf) yNum = i;
			}
			//trace("xRan: "+xRanNum+" yRan: "+yRanNum+"xNum: "+xNum+" yNum: "+yNum);
			xNum -= 3;
			yNum -= 3;
			x = x + xNum*TILE_SIZE;
			y = y + yNum*TILE_SIZE;
			while (y > GLOB_STG_BOT - TILE_SIZE*3)
				y -= TILE_SIZE;
			while (y < GLOB_STG_TOP + TILE_SIZE*4)
				y += TILE_SIZE;
			if (moveType == "wave")
			{
				yWaveMid = y;
				yWaveTop = y - TILE_SIZE;
				yWaveBot = y + TILE_SIZE;
			}
		}
		// SETSTATS sets statistics and initializes character
		override public function setStats():void
		{
			if (flying)
			{
				gravity = FLYING_GRAVITY;
				ySpeed = FLYING_JUMP_PWR;
				stompable = true;
				vy = -ySpeed;
				y = GLOB_STG_BOT + height;
				destroyTmr = new CustomTimer(destroyTmrDur,1);
				updateOffScreen = true;
				addTmr(destroyTmr);
				destroyTmr.addEventListener(TimerEvent.TIMER_COMPLETE,destroyTmrLsr);
				destroyTmr.start();
				calcFlyingStats();
				//calcXSpeed();
			}
			else
			{
				stompable = false;
				if (color == "gray")
					xSpeed = 50;
				else if (color == "red")
					xSpeed = 100;
				defyGrav = true;
				ySpeed = 20;
				vyMaxPsv = 400;
				gravity = 500;
				vx = -xSpeed;
				if (moveType == "wave") vy = -ySpeed;
				else vy = 0;
				calcPosition();
			}
			numColors = 3;
			setPlayFrame("swimStart");
			super.setStats();

		}
		private function calcFlyingStats():void
		{
			var xLoc:int = Math.random()*GLOB_STG_RHT;
			var xMid:int = GlobVars.STAGE_WIDTH/2;
			var xPadding:int = 120;
			while (xLoc > xMid - xPadding && xLoc < xMid + xPadding)
			{
				xLoc = Math.random()*GLOB_STG_RHT;
			}
//			trace("cheep x: "+xLoc);
			var xLocPt:Point = new Point(xLoc,0);
			x = globalToLocal(xLocPt).x;
			var flySpeed:Number = Math.random()*(MAX_HORZ_FLY_SPEED - MIN_HORZ_FLY_SPEED) + MIN_HORZ_FLY_SPEED;

			if (player.vx > 0)
			{
				if ( !(player is MarioBase) || (player is MarioBase && player.vx <= MarioBase.MAX_WALK_SPEED) )
					vx = flySpeed;
				else
				{
					flySpeed = MAX_HORZ_FLY_SPEED;
					vx = flySpeed;
				}
			}
			else if (player.vx < 0)
			{
				if ( !(player is MarioBase) || (player is MarioBase && player.vx >= -MarioBase.MAX_WALK_SPEED) )
					vx = -flySpeed;
				else
				{
					flySpeed = MAX_HORZ_FLY_SPEED;
					vx = -flySpeed;
				}
				scaleX = -1;
			}
			else
			{
				if (x > player.nx)
				{
					vx = -flySpeed;
					scaleX = -1;
				}
				else
					vx = flySpeed;
			}
			if (!fcs.canReverseDirection && scaleX < 0)
			{
				scaleX = 1;
				vx = -vx;
			}
			if (Cheats.allHammerBros)
			{
				var hb:HammerBro = new HammerBro(null,true);
				hb.x = x;
				hb.y = y;
				hb.vx = vx;
				hb.scaleX = scaleX;
				level.addToLevel(hb);
				fcs.addHammerBro(hb);
				destroy();
			}
		}
		override protected function updateStats():void
		{
			super.updateStats();
			if (moveType == "wave" && cState != "die")
			{
				if (ny < yWaveTop)
				{
					ny = yWaveTop;
					vy = -vy;
				}
				else if (ny > yWaveBot)
				{
					ny = yWaveBot;
					vy = -vy;
				}
			}
		}
		override public function checkFrame():void
		{
			if (currentFrame == getLabNum("swimEnd") + 1 && !stopUpdate)
				setPlayFrame("swimStart");
		}
		override public function stomp():void
		{
			if (!stompable || !player.canStomp)
				return;
				super.stomp();
				die();
				vx = 0;
				vy = 0;
		}
		override public function die(dmgSrc:LevObj = null):void
		{
			super.die(dmgSrc);
			if (flying)
			{
				vx = 0;
				gravity = FLYING_GRAVITY_DIE;
			}
			STAT_MNGR.numCheepCheepsDefeated++;
		}
		private function destroyTmrLsr(e:TimerEvent):void
		{
			destroyTmr.stop();
			destroyTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,destroyTmrLsr);
			removeTmr(destroyTmr);
			destroyTmr = null;
			destroyOffScreen = true;
			updateOffScreen = false;
			if (!onScreen)
				destroy();
		}
		override public function cleanUp():void
		{
			super.cleanUp();
			if (fcs)
				fcs.ENEMY_DCT.removeItem(this);
		}
		override protected function removeListeners():void
		{
			super.removeListeners();
			if (destroyTmr && destroyTmr.hasEventListener(TimerEvent.TIMER_COMPLETE)) destroyTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,destroyTmrLsr);
		}
		override protected function reattachLsrs():void
		{
			super.reattachLsrs();
			if (destroyTmr && !destroyTmr.hasEventListener(TimerEvent.TIMER_COMPLETE)) destroyTmr.addEventListener(TimerEvent.TIMER_COMPLETE,destroyTmrLsr);
		}
	}
}
