package com.smbc.projectiles
{
	import com.explodingRabbit.cross.gameplay.statusEffects.StatusProperty;
	import com.smbc.characters.Mario;
	import com.smbc.characters.base.MarioBase;
	import com.smbc.data.AnimationTimers;
	import com.smbc.data.CharacterInfo;
	import com.smbc.data.DamageValue;
	import com.smbc.data.SoundNames;
	import com.smbc.enemies.Enemy;
	import com.smbc.ground.*;
	import com.smbc.interfaces.IAttackable;

	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class MarioFireBall extends Projectile
	{
		private const FL_BLOW_UP:String = "blowUp";
		private const FL_DESTROY:String = "destroy";
		private const FL_END:String = "end";
		private const FL_START:String = "start";
		private const ST_NORMAL:String = "normal";
		private const ST_DESTROY:String = "destroy";
		private const BOUNCE_AMT:Number = 270;
		private const GRAVITY:int = 1350;
		private const VY_MAX_PSV:int = 300;
		private const X_SPEED:int = 475;
		private const X_OFFSET:int = 10;
		private const Y_OFFSET:int = 42;

		// Initialization:
		public function MarioFireBall(mario:MarioBase):void
		{
			inheritedForceShortClassName = CharacterInfo.CHAR_ARR[mario.charNum][CharacterInfo.IND_CHAR_NAME_CLASS]+"FireBall";
			super(mario,SOURCE_TYPE_PLAYER);
			needsAccurateGroundHits = true;
			doesntHitBricks = true;
//			BMD_CONT_VEC[0].bmp.bitmapData = mario.BMD_CONT_VEC[0].bmd;
			mainAnimTmr = AnimationTimers.ANIM_MIN_FAST_TMR;
			_damageAmt = DamageValue.MARIO_FIRE_BALL;
			stopAnim = false;
			dosTop = false;
			xSpeed = X_SPEED;
			jumpPwr = 700;
			vyMaxPsv = VY_MAX_PSV;
			gravity = GRAVITY;
			setState(ST_NORMAL);
			setDir();
			SND_MNGR.playSound(SoundNames.SFX_MARIO_FIREBALL);
			addProperty( new StatusProperty( PR_PASSTHROUGH_ALWAYS) );
			addHitTestableItem(HT_GROUND_NON_BRICK);
			addHitTestableItem(HT_PLATFORM);
		}
		override protected function setDir():void
		{
			if (player.scaleX > 0)
			{
				vx = xSpeed;
				x = player.nx + X_OFFSET
			}
			else
			{
				vx = -xSpeed;
				scaleX = -1;
				x = player.nx - X_OFFSET
			}
			vy = vyMaxPsv;
			y = player.ny - Y_OFFSET;
		}
		private function bounce(ground:Ground):void
		{
			ny = ground.hTop - hHeight/2;
			vy = -BOUNCE_AMT;
			setHitPoints();
		}
		private function blowUp():void
		{
			gotoAndStop(FL_BLOW_UP);
			setState(ST_DESTROY);
			vy = 0;
			vx = 0;
			stopUpdate = true;
			stopHit = true;
			noAnimThisCycle = true;
		}
		override public function hitGround(ground:Ground,side:String):void
		{
			if (!ground.visible)
				return;
			if (side == "bottom")
				bounce(ground);
			else
			{
				blowUp();
				SND_MNGR.playSound(SoundNames.SFX_GAME_HIT_CEILING);
			}
		}

		override protected function attackObjPiercing(obj:IAttackable):void
		{
			super.attackObjPiercing(obj);
			blowUp();
		}

		override protected function attackObjNonPiercing(obj:IAttackable):void
		{
			blowUp();
			SND_MNGR.playSound(SoundNames.SFX_GAME_HIT_CEILING);
		}

		override public function checkFrame():void
		{
			var cl:String = currentLabel;
			if (cState == ST_NORMAL && cl == FL_END)
				gotoAndStop(FL_START);
			else if (cState == ST_DESTROY && cl == FL_DESTROY)
				destroy();
		}
	}

}
