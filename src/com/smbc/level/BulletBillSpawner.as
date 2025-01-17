package com.smbc.level
{
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.data.Cheats;
	import com.smbc.data.GameStates;
	import com.smbc.data.SoundNames;
	import com.smbc.enemies.BulletBill;
	import com.smbc.enemies.Enemy;
	import com.smbc.enemies.HammerBro;
	import com.smbc.events.CustomEvents;

	import flash.events.Event;
	import flash.events.TimerEvent;

	public class BulletBillSpawner extends EnemySpawner
	{
		private static const DEL_DEFAULT:int = 250;
		private static const DEL_HB:int = 2000;
		private const RESPAWN_DELAY_TMR:CustomTimer = new CustomTimer(DEL_DEFAULT,1);
		private const BULLET_BILL_WIDTH:int = BulletBill.WIDTH;
		private var curBulBill:Enemy;
		private const NUM_Y_POSITIONS:int = 5; // number y positions possible for random location generator
		private var bulBillColor:String;
		private const GS_PLAY:String = GameStates.PLAY;

		public function BulletBillSpawner(enemyStartPosTmp:Number, enemyEndPosTmp:Number, bullBillColorTmp:String)
		{
			bulBillColor = bullBillColorTmp;
			super(enemyStartPosTmp, enemyEndPosTmp);
			if (Cheats.allHammerBros)
				RESPAWN_DELAY_TMR.delay = DEL_HB;
			RESPAWN_DELAY_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,respawnTmrHandler,false,0,true);
			addTmr(RESPAWN_DELAY_TMR);
		}
		override public function updateSpawner():void
		{
			super.updateSpawner();
			if (inSpawnZone && !curBulBill && !RESPAWN_DELAY_TMR.running)
				RESPAWN_DELAY_TMR.start();
		}
		private function respawnTmrHandler(event:TimerEvent):void
		{
			RESPAWN_DELAY_TMR.reset();
			if (GS_MNGR.gameState != GS_PLAY || !inSpawnZone)
				return;
			var rNum:Number = Math.random();
			var yNum:int;
			for (var i:int = 1; i < NUM_Y_POSITIONS+1; i++)
			{
				if (rNum < i/NUM_Y_POSITIONS)
				{
					yNum = i;
					break;
				}
			}
			yNum -= 3; // makes possible numbers -2, -1, 0, 1, 2
			var xPos:Number = level.locStgRht + BULLET_BILL_WIDTH/2;
			var yPos:Number = level.getNearestGrid(player.ny) + yNum*TILE_SIZE;
			while (yPos > GLOB_STG_BOT - TILE_SIZE*1)
				yPos -= TILE_SIZE;
			while (yPos < GLOB_STG_TOP + TILE_SIZE*3)
				yPos += TILE_SIZE;
			if (!Cheats.allHammerBros)
				curBulBill = new BulletBill(xPos,yPos,false,this,bulBillColor);
			else
			{
				curBulBill = new HammerBro(null,true);
				curBulBill.scaleX = -1;
				curBulBill.x = xPos;
				curBulBill.y = GLOB_STG_TOP + TILE_SIZE*3;
				curBulBill.vx = -BulletBill.SPEED;
				curBulBill.vy = 0;
				curBulBill.destroyOffScreen = true;
				curBulBill.addEventListener(CustomEvents.CLEAN_UP,enemyCleanUpHandler,false,0,true);
				SND_MNGR.playSound(SoundNames.SFX_GAME_CANON);
			}
			level.addToLevel(curBulBill);
		}
		private function enemyCleanUpHandler(event:Event):void
		{
			var enemy:Enemy = event.target as Enemy;
			enemy.removeEventListener(CustomEvents.CLEAN_UP,enemyCleanUpHandler);
			bulletBillDestroyed(enemy);
		}
		public function bulletBillDestroyed(bulBill:Enemy):void
		{
			if (bulBill != curBulBill)
				return;
			if (RESPAWN_DELAY_TMR.running)
				RESPAWN_DELAY_TMR.reset();
			RESPAWN_DELAY_TMR.start();
			curBulBill = null;
		}
		override protected function removeListeners():void
		{
			super.removeListeners();
			RESPAWN_DELAY_TMR.removeEventListener(TimerEvent.TIMER_COMPLETE,respawnTmrHandler);
		}
		override protected function reattachLsrs():void
		{
			super.reattachLsrs();
			RESPAWN_DELAY_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,respawnTmrHandler,false,0,true);
		}
	}
}
