package com.smbc.projectiles
{
	import com.explodingRabbit.cross.gameplay.statusEffects.StatusProperty;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.characters.Bill;
	import com.smbc.data.AnimationTimers;
	import com.smbc.data.DamageValue;
	import com.smbc.data.PickupInfo;
	import com.smbc.data.SoundNames;
	import com.smbc.enemies.Enemy;
	import com.smbc.ground.Brick;
	import com.smbc.interfaces.IAttackable;
	import com.smbc.level.Level;

	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.display.MovieClip;

	public class BillBullet extends Projectile
	{
		private static const MAIN_ANIM_TMR:CustomTimer = AnimationTimers.ANIM_FAST_TMR;

		public static const OFS_ARR:Array = [];
		public static const OFS_CHAR_DEF_IND:int = 0;
		public static const OFS_CHAR_GB_IND:int = 1;
		public static const OFS_CHAR_LANCE_GB_IND:int = 2;
		public static const TYPE_FLARE:String = "flare";
		public static const TYPE_FLARE_CENTER:String = "flareCenter";
		public static const TYPE_NORMAL:String = "normal";
		public static const TYPE_LASER:String = "laser";
		public static const TYPE_MACHINE:String = "machine";
		public static const TYPE_SPREAD:String = "spread";
		private static const SPREAD_SEP:int = 60;
		private static const DIAG_SPR_SEP:int = 50;
		private static const SPREAD_OFS:int = 6;
		private static const ROT_INC:int = 45; // increment of rotation
		private static const FL_FLARE:String = "flare";
		private static const FL_NORMAL:String = "normal";
		private static const FL_RED:String = "red";
		private static const FL_END:String = "end";
		private static const FL_LASER:String = "laser";
		private var spreadSep:int = 0;
		private var diagSprSep:int = 0;
		private var spreadOffset:int = 0;
		private const DESTROY_TMR:CustomTimer = new CustomTimer(50,1);
		// assumes character is facing right
		private static var ctr:int = -1;
		private static const IND_OFS_PT_UP:int = ctr+= 1;
		private static const IND_OFS_PT_DIAG_UP:int = ctr+= 1;
		private static const IND_OFS_PT_STAND:int = ctr+= 1;
		private static const IND_OFS_PT_DIAG_DWN:int = ctr+= 1;
		private static const IND_OFS_PT_CROUCH:int = ctr+= 1;
		private static const IND_OFS_FLIP_TOP_Y:int = ctr+= 1;
		private static const IND_OFS_FLIP_TOP_DIAG_X_Y:int = ctr+= 1;
		private static const IND_OFS_FLIP_MID_VERT:int = ctr+= 1;
		private static const IND_OFS_FLIP_RIGHT:int = ctr+= 1;
		private static const IND_OFS_FLIP_BOT:int = ctr+= 1;
		private static const IND_OFS_FALL_TOP_Y:int = ctr+= 1;
		private static const IND_OFS_FALL_DIAG_UP_Y:int = ctr+= 1;
		private static const IND_OFS_FALL_RIGHT_X:int = ctr+= 1;
		private static const IND_OFS_FALL_BOT:int = ctr+= 1;
		private static const IND_OFS_FALL_MID_VERT:int = ctr+= 1;
		private static const RAPID_SPEED_MULT:Number = .1;
		private static const NORMAL_BULLET_SPEED:int = 320 - 320*RAPID_SPEED_MULT; // 340
		private static const MACHINE_GUN_BULLET_SPEED:int = 350 - 350*RAPID_SPEED_MULT; // 380
		private static const LASER_SPEED:int = 370 - 370*RAPID_SPEED_MULT; // 400
		private static const SPREAD_BULLET_SPEED:int = 370 - 370*RAPID_SPEED_MULT; // 400
		private static const FLARE_SPEED:int = 235 - 235*RAPID_SPEED_MULT; // 235
		private static const FLARE_RADIUS:int = 32;
		private static const FLARE_ROT_SPEED:int = 22;
		private var flareCenter:BillBullet;
		private var flareAngle:Number = -1;
		private var flareRotDir:int = 1;
		private static const LASER_APPEAR_OFS:int = 6;
		private static const LASER_SEP:int = 26;
		private static const LASER_SEP_ROTATED:int = 18;
		private static const LASER_NUM_SEGMENTS:int = 4;
		public var laserAppearPnt:Point;
		private var bill:Bill;
		private var type:String;
		{(function ():void
		{
			OFS_ARR[OFS_CHAR_DEF_IND] = [
				new Point(9,93), // OFS_PT_UP:Point = new Point(9,93);
				new Point(27,69), // OFS_PT_DIAG_UP:Point = new Point(27,69);
				new Point(35,45), // OFS_PT_STAND:Point = new Point(35,45);
				new Point(30,26), // OFS_PT_DIAG_DWN:Point = new Point(30,26);
				new Point(36,15), // OFS_PT_CROUCH:Point = new Point(36,15);
				45, // OFS_FLIP_TOP_Y:int = 45;
				6, // OFS_FLIP_TOP_DIAG_X_Y:int = 6;
				25, // OFS_FLIP_MID_VERT:int = 25;
				25, // OFS_FLIP_RIGHT:int = 25;
				0, // OFS_FLIP_BOT:int = 0;
				78, // OFS_FALL_TOP_Y:int = 78;
				61, // OFS_FALL_DIAG_UP_Y:int = 61;
				25, // OFS_FALL_RIGHT_X:int = 25;
				26, // OFS_FALL_BOT:int = OFS_PT_DIAG_DWN.y;
				45, // OFS_FALL_MID_VERT:int = OFS_PT_STAND.y;
			];
			OFS_ARR[OFS_CHAR_GB_IND] = [
				new Point(7,77), // OFS_PT_UP:Point = new Point(9,93);
				new Point(28,60), // OFS_PT_DIAG_UP:Point = new Point(27,69);
				new Point(33,34), // OFS_PT_STAND:Point = new Point(35,45);
				new Point(25,20), // OFS_PT_DIAG_DWN:Point = new Point(30,26);
				new Point(36,10), // OFS_PT_CROUCH:Point = new Point(36,15);
				45, // OFS_FLIP_TOP_Y:int = 45;
				6, // OFS_FLIP_TOP_DIAG_X_Y:int = 6;
				25, // OFS_FLIP_MID_VERT:int = 25;
				25, // OFS_FLIP_RIGHT:int = 25;
				0, // OFS_FLIP_BOT:int = 0;
				68, // OFS_FALL_TOP_Y:int = 78;
				61, // OFS_FALL_DIAG_UP_Y:int = 61;
				25, // OFS_FALL_RIGHT_X:int = 25;
				26, // OFS_FALL_BOT:int = OFS_PT_DIAG_DWN.y;
				45, // OFS_FALL_MID_VERT:int = OFS_PT_STAND.y;
			];
			/*OFS_ARR[OFS_CHAR_LANCE_GB_IND] = [
				new Point(9,93), // OFS_PT_UP:Point = new Point(9,93);
				new Point(27,69), // OFS_PT_DIAG_UP:Point = new Point(27,69);
				new Point(35,45), // OFS_PT_STAND:Point = new Point(35,45);
				new Point(30,26), // OFS_PT_DIAG_DWN:Point = new Point(30,26);
				new Point(36,15), // OFS_PT_CROUCH:Point = new Point(36,15);
				45, // OFS_FLIP_TOP_Y:int = 45;
				6, // OFS_FLIP_TOP_DIAG_X_Y:int = 6;
				25, // OFS_FLIP_MID_VERT:int = 25;
				25, // OFS_FLIP_RIGHT:int = 25;
				0, // OFS_FLIP_BOT:int = 0;
				78, // OFS_FALL_TOP_Y:int = 78;
				61, // OFS_FALL_DIAG_UP_Y:int = 61;
				25, // OFS_FALL_RIGHT_X:int = 25;
				26, // OFS_FALL_BOT:int = OFS_PT_DIAG_DWN.y;
				45, // OFS_FALL_MID_VERT:int = OFS_PT_STAND.y;
			];*/

		}() );
		}
		private static function getOfs(charInd:int,typeInd:int,xFromPnt:Boolean = true):int
		{
			var obj:Object = OFS_ARR[charInd][typeInd];
			if ( !(obj is Point) )
				return int(obj);
			var point:Point = obj as Point;
			if (xFromPnt)
				return point.x;
			return point.y;
		}
		// Private Properties:

		// Initialization:
		public function BillBullet(bill:Bill,type:String)
		{
			super(bill, SOURCE_TYPE_PLAYER);
			this.bill = bill;
			this.type = type;
//			BMD_CONT_VEC[0].bmp.bitmapData = bill.BMD_CONT_VEC[0].bmd;
			stopAnim = true;
			defyGrav = true;
			mainAnimTmr = MAIN_ANIM_TMR;
			xSpeed = 300;
			determineShotType();
			DESTROY_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,destroyTmrHandler,false,0,true);
			addTmr(DESTROY_TMR);
			mainAnimTmr = null;
			addProperty( new StatusProperty( PR_PASSTHROUGH_ALWAYS) );
		}
		override protected function removedLsr(e:Event):void
		{
			super.removedLsr(e);
		}
		private function determineShotType():void
		{
			switch(type)
			{
				case TYPE_FLARE_CENTER:
					flareCenterInit();
					break;
				case TYPE_FLARE:
					flare();
					break;
				case TYPE_LASER:
					laser();
					break;
				case TYPE_MACHINE:
					machineGun();
					break;
				case TYPE_NORMAL:
					normal();
					break;
				case TYPE_SPREAD:
					spread();
					break;
			}
		}
		private function getRealSpeed(value:int):int
		{
			var speedPercInc:Number = 0;
			if ( bill.upgradeIsActive(PickupInfo.BILL_RAPID_1) )
				speedPercInc += RAPID_SPEED_MULT;
			if ( bill.upgradeIsActive(PickupInfo.BILL_RAPID_2) )
				speedPercInc += RAPID_SPEED_MULT;
			return value + ( value*speedPercInc );
		}
		private function flareCenterInit():void
		{
			visible = false;
			stopHit = true;
			removeAllHitTestableItems();
			xSpeed = getRealSpeed(FLARE_SPEED);
			destroyOffScreen = false;
			setDir();
		}
		private function flare():void
		{
			flareCenter = new BillBullet(bill,TYPE_FLARE_CENTER);
			level.addToLevelNow(flareCenter);
			xSpeed = getRealSpeed(FLARE_SPEED);
			if (bill.scaleX < 0)
			{
				flareAngle *= Math.PI/2;
				flareRotDir = -flareRotDir;
			}
			gotoAndStop(FL_FLARE);
			SND_MNGR.playSound(SoundNames.SFX_BILL_FLARE);
			_damageAmt = DamageValue.BILL_FLARE;
			setDir();
			addProperty( new StatusProperty( PR_PIERCE_AGG, PIERCE_STR_ARMOR_PIERCING) );
		}

		private function laser():void
		{
			xSpeed = getRealSpeed(LASER_SPEED);
			gotoAndStop(FL_LASER);
			SND_MNGR.playSound(SoundNames.SFX_BILL_LASER);
			_damageAmt = DamageValue.BILL_LASER;
			laserActivate(true);
			setDir();
		}
		public function laserActivate(deactivate:Boolean = false):void
		{
			visible = !deactivate;
			stopHit = deactivate;
		}
		override public function updateObj():void
		{
			super.updateObj();
			if (type == TYPE_SPREAD)
			{
				scaleX +=.018;
				scaleY+=.018;
				if (scaleX > 1.6)
					scaleX = 1.6;
				if (scaleY > 1.6)
					scaleY = 1.6;
			}
			else if (type == TYPE_LASER && stopHit)
			{
				if (vx == 0 || vx > 0 && nx >= laserAppearPnt.x || vx < 0 && nx <= laserAppearPnt.x)
				{
					if (vy == 0 || vy > 0 && ny >= laserAppearPnt.y || vy < 0 && ny <= laserAppearPnt.y)
						laserActivate();
				}
			}
			else if (type == TYPE_FLARE)
			{
				nx = flareCenter.x + Math.cos(flareAngle) * FLARE_RADIUS;
				ny = flareCenter.y + Math.sin(flareAngle) * FLARE_RADIUS;
				flareAngle += FLARE_ROT_SPEED*dt*flareRotDir;
			}

		}
		private function normal():void
		{
			xSpeed = getRealSpeed(NORMAL_BULLET_SPEED);
			gotoAndStop(FL_NORMAL);
			SND_MNGR.playSound(SoundNames.SFX_BILL_NORMAL_SHOT);
			_damageAmt = DamageValue.BILL_NORMAL_SHOT;
			setDir();
		}
		private function machineGun():void
		{
			xSpeed = getRealSpeed(MACHINE_GUN_BULLET_SPEED);
			gotoAndStop(FL_RED);
			SND_MNGR.playSound(SoundNames.SFX_BILL_MACHINE_GUN);
			_damageAmt = DamageValue.BILL_MACHINE_GUN;
			setDir();
		}
		private function spread():void
		{
			xSpeed = getRealSpeed(SPREAD_BULLET_SPEED);
			type = TYPE_SPREAD;
			gotoAndStop(FL_RED);
			SND_MNGR.playSound(SoundNames.SFX_BILL_SPREAD);
			_damageAmt = DamageValue.BILL_SPREAD;
			spreadSep = SPREAD_SEP;
			diagSprSep = DIAG_SPR_SEP;
			spreadOffset = SPREAD_OFS;
		}
		public function setSpread(offset:Number):void
		{
			spreadSep *= offset;
			diagSprSep *= offset;
			spreadOffset *= Math.abs(offset);
			setDir();
		}
		public static function createLaser(bill:Bill):void
		{
			var level:Level = Level.levelInstance;
			for each (var proj:Projectile in level.PLAYER_PROJ_DCT)
			{
				proj.destroy();
			}
			var seg1:BillBullet = new BillBullet(bill,TYPE_LASER);
			seg1.laserActivate();
			level.addToLevel(seg1);
			var xDir:int = Math.abs(seg1.vx)/seg1.vx;
			var yDir:int = Math.abs(seg1.vy)/seg1.vy;
			var sepAmt:int = LASER_SEP;
			if (seg1.rotation != 0 && seg1.rotation != ROT_INC*2)
				sepAmt = LASER_SEP_ROTATED;
			var n:int = LASER_NUM_SEGMENTS - 1;
			for (var i:int = 0; i < n; i++)
			{
				var laser:BillBullet = new BillBullet(bill,TYPE_LASER);
				laser.x -= sepAmt*xDir*(i+1);
				laser.y -= sepAmt*yDir*(i+1);
				laser.laserAppearPnt = new Point(seg1.x - (xDir*LASER_APPEAR_OFS),seg1.y - (yDir*LASER_APPEAR_OFS) );
				level.addToLevel(laser);
			}
		}
		public function blowUp():void
		{
			gotoAndStop(FL_END);
			vx = 0;
			vy = 0;
			stopHit = true;
			stopAnim = true;
			stopUpdate = true;
			scaleX = 1;
			scaleY = 1;
			DESTROY_TMR.start();
		}
		override protected function setDir():void
		{
			var charInd:int = bill.getOfsCharInd();
			var xMult:Number = .75;
			var yMult:Number = .75;
			// UP only
			if (bill.upBtn && !bill.rhtBtn && !bill.lftBtn)
			{
				vy = -xSpeed;
				vx = spreadSep;
				if (!bill.onGround)
					x = bill.nx;
				else if (bill.scaleX > 0)
					x = bill.nx + getOfs( charInd, IND_OFS_PT_UP, true );
				else
					x = bill.nx - getOfs( charInd, IND_OFS_PT_UP, true );
				if (bill.onGround)
					y = bill.ny - getOfs( charInd, IND_OFS_PT_UP, false );
				else if (bill.jumped)
					y = bill.ny - getOfs( charInd, IND_OFS_FLIP_TOP_Y );
				else
					y = bill.ny - getOfs( charInd, IND_OFS_FALL_TOP_Y );
				y += spreadOffset;
			}
			// diagonal up
			else if (bill.upBtn && (bill.rhtBtn || bill.lftBtn))
			{
				if (bill.rhtBtn)
				{
					vx = xSpeed*xMult+diagSprSep;
					if (bill.onGround)
						x = bill.nx + getOfs( charInd, IND_OFS_PT_DIAG_UP, true );
					else if (bill.jumped)
						x = bill.nx + getOfs( charInd, IND_OFS_FLIP_RIGHT ) - getOfs( charInd, IND_OFS_FLIP_TOP_DIAG_X_Y );
					else
						x = bill.nx + getOfs( charInd, IND_OFS_FALL_RIGHT_X );
					x -= spreadOffset;
				}
				else if (bill.lftBtn)
				{
					vx = -xSpeed*xMult-diagSprSep;
					if (bill.onGround)
						x = bill.nx - getOfs( charInd, IND_OFS_PT_DIAG_UP, true );
					else if (bill.jumped)
						x = bill.nx - getOfs( charInd, IND_OFS_FLIP_RIGHT ) + getOfs( charInd, IND_OFS_FLIP_TOP_DIAG_X_Y );
					else
						x = bill.nx - getOfs( charInd, IND_OFS_FALL_RIGHT_X );
					x += spreadOffset;

				}
				vy = -xSpeed*yMult+diagSprSep;
				if (bill.onGround)
					y = bill.ny - getOfs( charInd, IND_OFS_PT_DIAG_UP, false );
				else if (bill.jumped)
					y = bill.ny - getOfs( charInd, IND_OFS_FLIP_TOP_Y ) + getOfs( charInd, IND_OFS_FLIP_TOP_DIAG_X_Y );
				else
					y = bill.ny - getOfs( charInd, IND_OFS_FALL_DIAG_UP_Y );
				y += spreadOffset;
			}
			// RIGHT only
			else if (!bill.upBtn && !bill.dwnBtn)
			{
				if (bill.scaleX > 0)
				{
					vx = xSpeed;
					if (bill.onGround)
						x = bill.nx + getOfs( charInd, IND_OFS_PT_STAND, true );
					else if (bill.jumped)
						x = bill.nx + getOfs( charInd, IND_OFS_FLIP_RIGHT );
					else
						x = bill.nx + getOfs( charInd, IND_OFS_FALL_RIGHT_X );
					x -= spreadOffset;
				}
				else
				{
					vx = -xSpeed;
					if (bill.onGround)
						x = bill.nx - getOfs( charInd, IND_OFS_PT_STAND, true );
					else if (bill.jumped)
						x = bill.nx - getOfs( charInd, IND_OFS_FLIP_RIGHT );
					else
						x = bill.nx - getOfs( charInd, IND_OFS_FALL_RIGHT_X );
					x += spreadOffset;

				}
				vy = spreadSep;
				if (bill.onGround)
					y = bill.ny - getOfs( charInd, IND_OFS_PT_STAND, false );
				else if (bill.jumped)
					y = bill.ny - getOfs( charInd, IND_OFS_FLIP_MID_VERT );
				else
					y = bill.ny - getOfs( charInd, IND_OFS_FALL_MID_VERT );
			}
			// diagonal down
			else if (bill.dwnBtn && (bill.rhtBtn || bill.lftBtn))
			{
				if (bill.rhtBtn)
				{
					vx = xSpeed*yMult-diagSprSep;
					if (bill.onGround)
						x = bill.nx + getOfs( charInd, IND_OFS_PT_DIAG_DWN, true );
					else if (bill.jumped)
						x = bill.nx + getOfs( charInd, IND_OFS_FLIP_RIGHT ) - getOfs( charInd, IND_OFS_FLIP_TOP_DIAG_X_Y );
					else
						x = bill.nx + getOfs( charInd, IND_OFS_FALL_RIGHT_X );
					x -= spreadOffset;
				}
				else if (bill.lftBtn)
				{
					vx = -xSpeed*yMult+diagSprSep;
					if (bill.onGround)
						x = bill.nx - getOfs( charInd, IND_OFS_PT_DIAG_DWN, true );
					else if (bill.jumped)
						x = bill.nx - getOfs( charInd, IND_OFS_FLIP_RIGHT ) + getOfs( charInd, IND_OFS_FLIP_TOP_DIAG_X_Y );
					else
						x = bill.nx - getOfs( charInd, IND_OFS_FALL_RIGHT_X );
					x += spreadOffset;
				}
				vy = xSpeed*xMult+diagSprSep;
				if (bill.onGround)
					y = bill.ny - getOfs( charInd, IND_OFS_PT_DIAG_DWN, false );
				else if (bill.jumped)
					y = bill.ny - getOfs( charInd, IND_OFS_FLIP_BOT ) - getOfs( charInd, IND_OFS_FLIP_TOP_DIAG_X_Y );
				else
					y = bill.ny - getOfs( charInd, IND_OFS_FALL_BOT );
				y -= spreadOffset;
			}
			// DOWN only
			else if (bill.dwnBtn && !bill.lftBtn && !bill.rhtBtn)
			{
				if (bill.onGround)
				{
					if (bill.scaleX > 0)
					{
						vx = xSpeed;
						vy = spreadSep;
						x = bill.nx + getOfs( charInd, IND_OFS_PT_CROUCH, true )  - spreadOffset;
						y = bill.ny - getOfs( charInd, IND_OFS_PT_CROUCH, false );
					}
					else
					{
						vx = -xSpeed;
						vy = spreadSep;
						x = bill.nx - getOfs( charInd, IND_OFS_PT_CROUCH, true );  + spreadOffset;
						y = bill.ny - getOfs( charInd, IND_OFS_PT_CROUCH, false );
					}
				}
				else if (bill.jumped)
				{
					vx = spreadSep;
					vy = xSpeed;
					x = bill.nx;
					y = bill.ny - getOfs( charInd, IND_OFS_FLIP_BOT ) - spreadOffset;
				}
				else // just like shooting right or left
				{
					if (bill.scaleX > 0)
					{
						vx = xSpeed;
						if (bill.onGround)
							x = bill.nx + getOfs( charInd, IND_OFS_PT_STAND, true );
						else if (bill.jumped)
							x = bill.nx + getOfs( charInd, IND_OFS_FLIP_RIGHT );
						else
							x = bill.nx + getOfs( charInd, IND_OFS_FALL_RIGHT_X );
						x -= spreadOffset;
					}
					else
					{
						vx = -xSpeed;
						if (bill.onGround)
							x = bill.nx - getOfs( charInd, IND_OFS_PT_STAND, true );
						else if (bill.jumped)
							x = bill.nx - getOfs( charInd, IND_OFS_FLIP_RIGHT );
						else
							x = bill.nx - getOfs( charInd, IND_OFS_FALL_RIGHT_X );
						x += spreadOffset;

					}
					vy = spreadSep;
					if (bill.onGround)
						y = bill.ny - getOfs( charInd, IND_OFS_PT_STAND, false );
					else if (bill.jumped)
						y = bill.ny - getOfs( charInd, IND_OFS_FLIP_MID_VERT );
					else
						y = bill.ny - getOfs( charInd, IND_OFS_FALL_MID_VERT );
				}
			}
			if (type == TYPE_LASER && vy != 0) // sets rotation
			{
				if (vx == 0)
					rotation = ROT_INC*2;
				else if (vx > 0)
				{
					if (vy < 0)
						rotation = ROT_INC*3;
					else
						rotation = ROT_INC;
				}
				else
				{
					if (vy < 0)
						rotation = ROT_INC;
					else
						rotation = ROT_INC*3;
				}
			}

		}
		override public function confirmedHit(mc:IAttackable,damaged:Boolean = true):void
		{
			super.confirmedHit(mc,damaged);
			blowUp();
		}

		override protected function attackObjPiercing(obj:IAttackable):void
		{
			super.attackObjPiercing(obj);
			if (obj is Enemy)
				SND_MNGR.playSound(SoundNames.SFX_BILL_SHOT_HIT);
		}

		override public function cleanUp():void
		{
			super.cleanUp();
			if (flareCenter)
				flareCenter.destroy();
		}


		private function destroyTmrHandler(e:TimerEvent):void
		{
			DESTROY_TMR.stop();
			destroy();
		}
		override protected function removeListeners():void
		{
			super.removeListeners();
			DESTROY_TMR.removeEventListener(TimerEvent.TIMER_COMPLETE,destroyTmrHandler);
		}
	}

}
