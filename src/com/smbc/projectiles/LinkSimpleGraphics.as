package com.smbc.projectiles
{
	import com.smbc.characters.Link;
	import com.smbc.data.AnimationTimers;
	import com.smbc.data.PaletteTypes;
	import com.smbc.data.SoundNames;
	import com.smbc.main.LevObj;
	import com.smbc.main.SimpleAnimatedObject;
	import com.smbc.utils.GameLoopTimer;

	public final class LinkSimpleGraphics extends SimpleAnimatedObject
	{
		public static const TYPE_ENEMY_EXPLOSION:String = "enemyExplosion";
		public static const TYPE_SWORD_EXPLOSION:String = "swordExplosion";
		private static const FL_ENEMY_EXPLOSION_END:String = "enemyExplosionEnd";
		private static const FL_ENEMY_EXPLOSION_START:String = "enemyExplosionStart";
		private static const FL_SWORD_EXPLOSION_END:String = "swordExplosionEnd";
		private static const FL_SWORD_EXPLOSION_START:String = "swordExplosionStart";
		private static const ENEMY_EXP_TMR_DEL:int = 85; // 60
		private static const ENEMY_EXP_FLASH_TMR_DEL:int = 30;
		private const SPEED:int = 115;
		private const START_POS_OFFSET:int = 10;
		private const MAX_Y_DIST:int = 40;
		private var swordExpEndY:Number;
		private var swordExpDirUp:Boolean;
		private var type:String;
		private var source:LevObj;
		private var link:Link;

		public function LinkSimpleGraphics(source:LevObj,type:String,dir:String = null)
		{
			super();
			this.type = type;
			this.source = source;
			switch(type)
			{
				case TYPE_ENEMY_EXPLOSION:
				{
					stopAnim = false;
					accurateAnimTmr = new GameLoopTimer(ENEMY_EXP_TMR_DEL);
					flashTmr = new GameLoopTimer(ENEMY_EXP_FLASH_TMR_DEL);
					paletteObjectName = "LinkEnemyExplosion";
					palOrderArr = [ PaletteTypes.FLASH_GENERAL ];
					gotoAndStop(FL_ENEMY_EXPLOSION_START);
					x = source.hMidX;
					y = source.hMidY;
					SND_MNGR.playSound(SoundNames.SFX_LINK_KILL_ENEMY);
					source.destroy();
					break;
				}
				case TYPE_SWORD_EXPLOSION:
				{
					stopAnim = false;
					stopUpdate = false;
					mainAnimTmr = AnimationTimers.ANIM_FAST_TMR;
					gotoAndStop(FL_SWORD_EXPLOSION_START);
					x = source.nx;
					y = source.ny;
					setUpSwordExplosionPosition(dir);
					break;
				}
			}
		}
		private function setUpSwordExplosionPosition(dir:String):void
		{
			if (dir.indexOf("up") != -1)
			{
				y -= START_POS_OFFSET;
				vy = -SPEED;
				swordExpEndY = y - MAX_Y_DIST;
				swordExpDirUp = true;
			}
			else if (dir.indexOf("dwn") != -1)
			{
				y += START_POS_OFFSET;
				vy = SPEED;
				scaleY = -scaleY;
				swordExpEndY = y + MAX_Y_DIST;
			}
			if (dir.indexOf("lft") != -1)
			{
				x -= START_POS_OFFSET;
				vx = -SPEED;
				scaleX = -scaleX;
			}
			else if (dir.indexOf("rht") != -1)
			{
				x += START_POS_OFFSET;
				vx = SPEED;
			}
		}
		override public function updateObj():void
		{
			super.updateObj();
			if (type == TYPE_SWORD_EXPLOSION)
			{
				if (swordExpDirUp)
				{
					if (y <= swordExpEndY)
						destroy();
				}
				else if (y >= swordExpEndY)
					destroy();
				x += vx*dt;
				y += vy*dt;
			}
		}
		override public function checkFrame():void
		{
			if (type == TYPE_SWORD_EXPLOSION && currentFrame == convFrameToInt(FL_SWORD_EXPLOSION_END) + 1)
				gotoAndStop(FL_SWORD_EXPLOSION_START);
			else if (type == TYPE_ENEMY_EXPLOSION && currentFrame == convFrameToInt(FL_ENEMY_EXPLOSION_END) + 1)
				destroy();
		}

		override public function cleanUp():void
		{
			super.cleanUp();
			if (type == TYPE_SWORD_EXPLOSION)
				Link( LinkProjectile(source).source).canShootSword = true;
		}


	}
}
