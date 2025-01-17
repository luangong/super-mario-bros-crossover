package com.smbc.projectiles
{

	import com.customClasses.*;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatFxStop;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatusProperty;
	import com.explodingRabbit.utils.CustomDictionary;
	import com.smbc.characters.*;
	import com.smbc.data.AnimationTimers;
	import com.smbc.data.GameStates;
	import com.smbc.data.PickupInfo;
	import com.smbc.data.SoundNames;
	import com.smbc.enemies.*;
	import com.smbc.interfaces.IAttackable;
	import com.smbc.pickups.BowserAxe;
	import com.smbc.pickups.Pickup;
	import com.smbc.sound.SoundContainer;

	import flash.utils.Dictionary;

	public class LinkBoomerang extends Projectile
	{
		// Constants:
		private var boomType:String;
		private var totDist:Number;
		private var fDist:Number;
		public var followPlayer:Boolean;
		private var applyFric:Boolean;
		private var startX:Number;
		private var startY:Number;
		private var yDif:Number;
		private var axy:Number;
		private var fxy:Number;
		private const MIN_FRIC_DIST:int = 30;
		private const MIN_MOVE_DIST:int = MIN_FRIC_DIST + 50;
		private const ACCELERATION:int = 2500;
		private var accelerate:Boolean;
		private const CHANGE_DIR_SPEED:int = 100;
		private var link:Link;
		private const GRABBED_ITEMS_DCT:CustomDictionary = new CustomDictionary(true);
		private const SFX_LINK_BOOMERANG:String = SoundNames.SFX_LINK_BOOMERANG;
		// Public Properties:

		// Private Properties:
		// Initialization:
		public function LinkBoomerang(link:Link)
		{
			this.link = link;
			super(link,SOURCE_TYPE_PLAYER);
			addProperty( new StatusProperty(PR_STOP_AGG, 0, new StatFxStop(null,3000,false) ) );
			addProperty( new StatusProperty(PR_PIERCE_AGG, 10 ) );
//			BMD_CONT_VEC[0].bmp.bitmapData = link.BMD_CONT_VEC[0].bmd;
			link.boomerang = this;
			destroyOffScreen = true;
			speed = 500;
			fxy = .000001;
			axy = 500;
			mainAnimTmr = AnimationTimers.ANIM_FAST_TMR;
			fDist = 100;
			addProperty( new StatusProperty( PR_PASSTHROUGH_ALWAYS) );
			defyGrav = true;
			determineBoomType();
			setDir();
			SND_MNGR.playSound(SFX_LINK_BOOMERANG);
			hitTestTypesDct.addItem(HT_PROJECTILE_ENEMY);
			hitTestTypesDct.addItem(HT_CHARACTER);
			removeAllHitTestableItems();
			addHitTestableItem(HT_PICKUP);
			addHitTestableItem(HT_ENEMY);
		}
		private function determineBoomType():void
		{
			if ( !link.upgradeIsActive(PickupInfo.LINK_MAGIC_BOOMERANG) )
			{
				boomType = "yellow";
				gotoAndStop("yellowStart");
				fDist = 150;
				speed = 300;
				axy = 25;
			}
			else
			{
				boomType = "blue";
				gotoAndStop("blueStart");
				fDist = 270;
				speed = 400;
				axy = 60;
			}
			vxMax = speed;
			vyMax = speed;

		}
		override protected function setDir():void
		{
			var diagMult:Number = .75;
			// UP only
			if (link.upBtn && !link.rhtBtn && !link.lftBtn)
			{
				vy = -speed;
				x = link.nx;
				y = link.ny - link.hHeight;
			}
			// UP and RIGHT
			else if (link.upBtn && link.rhtBtn)
			{
				vy = -speed*diagMult;
				vx = speed*diagMult;
				x = link.nx + link.hWidth/2;
				y = link.ny - link.hHeight;
			}
			// UP and LEFT
			else if (link.upBtn && link.lftBtn)
			{
				vy = -speed*diagMult;
				vx = -speed*diagMult;
				x = link.nx - link.hWidth/2;
				y = link.ny - link.hHeight;
			}
			// RIGHT only
			else if (link.scaleX > 0 && !link.upBtn && !link.dwnBtn)
			{
				vx = speed;
				x = link.nx + link.hWidth/2;
				y = link.ny - link.hHeight/2;
			}
			// LEFT only
			else if (link.scaleX < 0 && !link.upBtn && !link.dwnBtn)
			{
				vx = -speed;
				x = link.nx - link.hWidth/2;
				y = link.ny - link.hHeight/2;
			}
			// DOWN and RIGHT
			else if (link.dwnBtn && link.rhtBtn)
			{
				vx = speed*diagMult;
				vy = speed*diagMult;
				x = link.nx + link.hWidth/2;
				y = link.ny;
			}
			// DOWN and LEFT
			else if (link.dwnBtn && link.lftBtn)
			{
				vx = -speed*diagMult;
				vy = speed*diagMult;
				x = link.nx - link.hWidth/2;
				y = link.ny;
			}
			// DOWN only
			else if (link.dwnBtn && !link.lftBtn && !link.rhtBtn)
			{
				vy = speed;
				x = link.nx;
				y = link.ny;
			}
			startX = x;
			startY = y;
		}
		override protected function updateStats():void
		{
			if (link.cState == "pipe")
			{
				stopHit = true;
				stopAnim = true;
				stopUpdate = true;
				return;
			}
			super.updateStats();
			checkDist();
		}
		override public function drawObj():void
		{
			super.drawObj();
			movePickups();
		}
		private function checkDist():void
		{
			/*if (!stopCircle)
			{
				nx = centerX + Math.sin(angle) * radiusX;
				ny = centerY + Math.cos(angle) * radiusY;
				angle += speed*dt;
				if (angle >= yMaxPt)
				{
					stopCircle = true;
					followPlayer = true;
					vx = -450;
				}
			}
			else if (followPlayer)
			{
				yDif = Math.abs(Math.abs(link.hMidY) - Math.abs(ny));
				if (link.ny > ny) vy = yDif*2;
				else vy = -yDif*2;
			}*/


			//if (ny > link.ny - 10) vy = -30;
			//if (ny < startY) vy = 0;
			if (level.getDistance(startX,startY,nx,ny) > fDist && !applyFric && !followPlayer && boomType == "yellow")
			{
				applyFric = true;
			}
			if (applyFric)
			{
				vx *= Math.pow(fxy,dt);
				vy *= Math.pow(fxy,dt);
				if (vx > 0 && vx < CHANGE_DIR_SPEED) changeDir();
				else if (vx < 0 && vx > -CHANGE_DIR_SPEED) changeDir();
				else if (vy > 0 && vy < CHANGE_DIR_SPEED) changeDir();
				else if (vy < 0 && vy > -CHANGE_DIR_SPEED) changeDir();
			}
			else if (accelerate)
			{
				// accelerate after direction changed
				if (vx > 0 && vx < vxMax) speedUp();
				else if (vx < 0 && vx > -vxMax) speedUp();
				else if (vy > 0 && vy < vyMax) speedUp();
				else if (vy < 0 && vy > -vyMax) speedUp();
			}
			if (followPlayer)
			{
				// follow the link
				var linkCPX:Number = link.hMidX;
				var linkCPY:Number = link.hMidY;
				var fricX:Boolean = false;
				var fricY:Boolean = false;

				var xDist:Number = nx - linkCPX;
				if (xDist < 0)
					xDist = -xDist;
				var yDist:Number = ny - linkCPY;
				if (yDist < 0)
					yDist = -yDist;
				if (nx > linkCPX)
					vx -= xDist*axy*dt;
				else if (nx < linkCPX)
					vx += xDist*axy*dt;
				if (ny > linkCPY)
					vy -= yDist*axy*dt;
				else if (ny < linkCPY)
					vy += yDist*axy*dt;
				if (xDist <= MIN_FRIC_DIST)
				{
					vx *= Math.pow(fxy,dt);
					fricX = true;
				}
				if (yDist <= MIN_FRIC_DIST)
				{
					vy *= Math.pow(fxy,dt);
					fricY = true;
				}
				if (level.getDistance(nx,ny,link.hMidX,link.hMidY) < MIN_MOVE_DIST)
				{
					if (nx > linkCPX)
						vx -= ACCELERATION*dt;
					else if (nx < linkCPX)
						vx += ACCELERATION*dt;
					if (ny > linkCPY)
						vy -= ACCELERATION*dt;
					else if (ny < linkCPY)
						vy += ACCELERATION*dt;
				}
			}
		}

		override public function confirmedHit(mc:IAttackable,damaged:Boolean = true):void
		{

		}

		private function movePickups():void
		{
			for each (var pickup:Pickup in GRABBED_ITEMS_DCT)
			{
				var ph:Number = pickup.height*.5;
				pickup.nx = nx;
				pickup.ny = ny + ph;
				pickup.x = nx;
				pickup.y = ny + ph;
			}
		}
		private function speedUp():void
		{
			vx /= Math.pow(fxy,dt);
			vy /= Math.pow(fxy,dt);
			accelerate = false;
		}
		public function changeDir():void
		{
			if (!followPlayer)
			{
				followPlayer = true;
				addHitTestableItem(HT_CHARACTER);
				applyFric = false;
				//accelerate = true;
				vx = -vx;
				vy = -vy;
			}
		}
		override public function checkLoc():void
		{
			// I'll have to add this to level
			if (globY - hHeight*.5 <= GLOB_STG_TOP)
				changeDir();
			else if (globY + hHeight*.5 >= GLOB_STG_BOT)
				changeDir();
			else if (globX + hWidth*.5 >= GLOB_STG_RHT)
				changeDir();
			else if (globX - hWidth*.5 <= GLOB_STG_LFT)
				changeDir();
		}
		override public function hitEnemy(enemy:Enemy,hType:String):void
		{
			if (enemy is Bowser)
				HIT_OBJS_DCT.addItem(enemy);
			changeDir();
			SND_MNGR.playSound(SoundNames.SFX_LINK_HIT_ENEMY);
			super.hitEnemy(enemy,hType);
		}
		override public function hitCharacter(char:Character,side:String):void
		{
			if (followPlayer)
			{
				destroy();
				for each (var pickup:Pickup in GRABBED_ITEMS_DCT)
				{
					link.hitPickup(pickup);
					GRABBED_ITEMS_DCT.removeItem(pickup);
				}
			}
			super.hitCharacter(char,side);
		}
		override public function checkFrame():void
		{
			if (boomType == "yellow" && currentFrame >= getLabNum("yellowEnd") + 1)
				gotoAndStop("yellowStart");
			else if (boomType == "blue" && currentFrame >= getLabNum("blueEnd") + 1)
				gotoAndStop("blueStart");
		}
		override public function hitPickup(pickup:Pickup,showAnimation:Boolean = true):void
		{
			if (pickup.boomerangGrabbable && !pickup.destroyed && !GRABBED_ITEMS_DCT[pickup])
			{
				GRABBED_ITEMS_DCT.addItem(pickup);
				pickup.stopHit = true;
			}
		}
		override public function cleanUp():void
		{
			super.cleanUp();
			link.boomerang = null;
			var boomSnd:SoundContainer = SND_MNGR.findSound(SFX_LINK_BOOMERANG);
			if (boomSnd)
			{
				boomSnd.pauseSound();
				SND_MNGR.removeSnd(boomSnd);
			}
			for each (var pickup:Pickup in GRABBED_ITEMS_DCT)
			{
				pickup.destroy();
			}
		}
	}
}
