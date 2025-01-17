package com.smbc.projectiles
{

	import com.customClasses.*;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatusProperty;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.characters.base.MegaManBase;
	import com.smbc.data.DamageValue;
	import com.smbc.data.SoundNames;
	import com.smbc.enemies.Enemy;
	import com.smbc.ground.Brick;
	import com.smbc.interfaces.IAttackable;
	import com.smbc.interfaces.ICustomTimer;
	import com.smbc.main.AnimatedObject;
	import com.smbc.main.LevObj;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;

	[Embed(source="../assets/swfs/SmbcGraphics.swf", symbol="BrickPiece")]
	public class BrickPiece extends Projectile
	{

		// Constants:
		private var bx:Number;
		private var by:Number;
		private var corner:String;
		private var ySpeedTop:Number;
		private var ySpeedBot:Number;
		// Public Properties:

		// Private Properties:
		// Initialization:
		public function BrickPiece(origin:Brick,color:String,_corner:String,_bx:Number,_by:Number,damageEnemies:Boolean = false)
		{
			var sourceType:String = SOURCE_TYPE_NEUTRAL;
			if (damageEnemies)
				sourceType = SOURCE_TYPE_PLAYER;
			super(origin,sourceType);
			bx = _bx;
			by = _by;
			corner = _corner;
			gotoAndStop(color);
			destroyOffScreen = true;
			xSpeed = 100;
			ySpeedTop = 600;
			ySpeedBot = 300;
			vyMaxPsv = 700;
			gravity = 1600;
			stopAnim = true;
			if (!damageEnemies)
				stopHit = true;
			else
			{
				_damageAmt = DamageValue.MEGA_MAN_SUPER_ARM_DEBRIS;
				for each (var prop:StatusProperty in MegaManBase.DEFAULT_PROPS_DCT)
				{
					addProperty(prop);
				}
			}
			setDir();
		}
		override protected function setDir():void
		{
			switch (corner)
			{
				case "top-left" :
				{
					x = bx + TILE_SIZE/4;
					y = by + TILE_SIZE/4;
					vx = -xSpeed;
					vy = -ySpeedTop;
					break;
				}
				case "top-right" :
				{
					x = bx + TILE_SIZE*.75
					y = by + TILE_SIZE/4;
					vx = xSpeed;
					vy = -ySpeedTop;
					break;
				}
				case "bottom-left" :
				{
					x = bx + TILE_SIZE/4;
					y = by + TILE_SIZE*.75;
					vx = -xSpeed;
					vy = -ySpeedBot;
					break;
				}
				case "bottom-right" :
				{
					x = bx + TILE_SIZE*.75;
					y = by + TILE_SIZE*.75;
					vx = xSpeed;
					vy = -ySpeedBot;
					break;
				}
				default :
				{
					break;
				}
			}
		}
		override protected function attackObjNonPiercing(obj:IAttackable):void
		{
			super.attackObjNonPiercing(obj);
			SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_DEFLECT);
		}

		override protected function attackObjPiercing(obj:IAttackable):void
		{
			if (obj is Enemy)
				SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_HIT_ENEMY);
		}
		override public function animate(ct:ICustomTimer):Boolean
		{
			if (ct == mainAnimTmr)
			{
				var cf:int = currentFrame;
				if (cf == 1)
					gotoAndStop(2);
				else
					gotoAndStop(1);
				return true;
			}
			return false;
		}
	}
}
