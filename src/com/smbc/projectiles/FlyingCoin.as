package com.smbc.projectiles
{
	import com.explodingRabbit.display.CustomMovieClip;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.data.AnimationTimers;
	import com.smbc.graphics.CoinExplosion;
	import com.smbc.graphics.MasterObjects;
	import com.smbc.graphics.StarBurst;
	import com.smbc.ground.*;
	import com.smbc.pickups.*;
	import com.smbc.utils.GameLoopTimer;

	import flash.events.*;


	[Embed(source="../assets/swfs/SmbcGraphics.swf", symbol="FlyingCoin")]
	public class FlyingCoin extends Projectile
	{

		// Constants:
		// Public Properties:
		public var brickParent:Brick;
		public static const GRAVITY:int = 1550;
		public static const JUMP_PWR:int = 620;
		// Private Properties:
		private var endY:Number;
		private var bpy:Number;
		public static const MAIN_ANIM_TMR:CustomTimer = AnimationTimers.ANIM_FAST_TMR;
		public static const END_Y_OFFSET:int = 70;
		private static const EXPLODE_Y_OFS:int = 120;
		private const SCORE_VALUE:int = 200;
		private const SP_OFFSET:int = 8;
		private var explodeY:Number;
		private var explosion:CoinExplosion = new CoinExplosion();
		private var scorePopDelTmr:GameLoopTimer;
//		private static var FLYING_COIN_MASTER:CustomMovieClip;

		// Initialization:
		public function FlyingCoin()
		{
			super(null,SOURCE_TYPE_NEUTRAL);
			ySpeed = JUMP_PWR;
			gravity = GRAVITY;
			behindGround = true;
			stopHit = true;
			setDir();
			mainAnimTmr = MAIN_ANIM_TMR;
		}
		override protected function updateStats():void
		{
			if (behindGround && ny + height*.5 < bpy) behindGround = false;
			if (ny < explodeY && !explosion.frameIsEmpty(1) && !scorePopDelTmr)
				explode();
			if (ny >= endY && vy > 0)
				explode();
			else
				super.checkStgPos();
		}
		private function explode():void
		{
			explosion.explode(this);
			level.addToLevel(explosion);
			if (ny >= endY)
			{
				level.scorePop(SCORE_VALUE,nx,endY+SP_OFFSET,false,true);
				destroy();
			}
			else
			{
				visible = false;
				scorePopDelTmr = new GameLoopTimer(300,1);
				scorePopDelTmr.addEventListener(TimerEvent.TIMER_COMPLETE,scorePopDelTmrHandler,false,0,true);
				scorePopDelTmr.start();
			}
		}

		protected function scorePopDelTmrHandler(event:Event):void
		{
			scorePopDelTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,scorePopDelTmrHandler);
			level.scorePop(SCORE_VALUE,nx,endY+SP_OFFSET,false,true);
			destroy();
		}
		public function getFlyingCoinInfo(b:Brick):void
		{
			brickParent = b;
			x = b.x + TILE_SIZE/2;
			bpy = b.y;
			y = bpy + TILE_SIZE/2;
			endY = y - END_Y_OFFSET;
			explodeY = y - EXPLODE_Y_OFS;
			vy = -ySpeed;
		}
		public function getAlternateInfo(c:Coin):void
		{
			x = c.x;
			y = c.y;
			bpy = c.y - TILE_SIZE/2;
			endY = y - END_Y_OFFSET;
			explodeY = y - EXPLODE_Y_OFS;
			vy = -ySpeed;
		}
		override public function checkFrame():void
		{
			if (currentFrame >= totalFrames)
				gotoAndStop("coinStart");
		}
		// Public Methods:
		// Protected Methods:
	}

}
