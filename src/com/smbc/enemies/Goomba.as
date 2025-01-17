package com.smbc.enemies
{
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.data.EnemyInfo;
	import com.smbc.data.HealthValue;
	import com.smbc.data.MovieClipInfo;
	import com.smbc.data.ScoreValue;
	import com.smbc.level.TitleLevel;
	import com.smbc.main.LevObj;
	import com.smbc.managers.GraphicsManager;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;

	public class Goomba extends Enemy
	{
		public static const ENEMY_NUM:int = EnemyInfo.Goomba;
		private var destroyTmr:CustomTimer;
		private var destroyDur:Number;

		public function Goomba(fLab:String)
		{
			if (fLab.indexOf("enemyGoombaBrown") != -1)
				colorNum = 1;
			else if (fLab.indexOf("enemyGoombaBlue") != -1)
				colorNum = 2;
			else if (fLab.indexOf("enemyGoombaGray") != -1)
				colorNum = 3;
			super();
//			addProperty(PR_ARMORED);
//			removeProperty(PR_STALLABLE);
		}
		override protected function overwriteInitialStats():void
		{
			_health = HealthValue.GOOMBA;
			scoreAttack = ScoreValue.GOOMBA_ATTACK;
			scoreBelow = ScoreValue.GOOMBA_BELOW;
			scoreStar = ScoreValue.GOOMBA_STAR;
			scoreStomp = ScoreValue.GOOMBA_STOMP;
			super.overwriteInitialStats();
		}
		// SETSTATS sets statistics and initializes character
		override public function setStats():void
		{
			stompable = true;
			numColors = 3;
			destroyDur = 750;
			xSpeed = defaultWalkSpeed;
			//xSpeedStuck = 150;
			ySpeed = 400;
			gravity = 1400;
			vx = -xSpeed;
			setPlayFrame("walkStart");
			//gravity = 1000;
			super.setStats();
		}
		override public function updateObj():void
		{
			super.updateObj();

		}
		override public function stomp():void
		{
			super.stomp();
			if (cState == ST_DIE || !player.canStomp)
				return;
			if (level != TitleLevel.instance)
				STAT_MNGR.numEnemiesDefeated++;
			setStopFrame("die");
			destroyTmr = new CustomTimer(destroyDur,1);
			addTmr(destroyTmr);
			destroyTmr.addEventListener(TimerEvent.TIMER_COMPLETE,destroyTmrLsr);
			destroyTmr.start();
			stopUpdate = true;
			stopHit = true;
			defyGrav = true;
			ACTIVE_ANIM_TMRS_DCT.clear();
			mainAnimTmr = null;
			// stomp enemy
		}
		private function destroyTmrLsr(e:TimerEvent):void
		{
			destroy();
		}
		override public function die(dmgSrc:LevObj = null):void
		{
			super.die(dmgSrc);
			if (currentLabel == convLab("die") )
				setStopFrame("walkStart");
		}
		override public function checkFrame():void
		{
			super.checkFrame();
			var cfl:String = currentLabel;
			var cf:int = currentFrame;
			if (cf == convFrameToInt("walkEnd") + 1 && cState != ST_DIE)
				setPlayFrame("walkStart");
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
