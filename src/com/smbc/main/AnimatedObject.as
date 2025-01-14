package com.smbc.main
{

	import com.adobe.fileformats.vcard.Address;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatFxKnockBack;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatusEffect;
	import com.explodingRabbit.utils.CustomDictionary;
	import com.smbc.characters.*;
	import com.smbc.data.*;
	import com.smbc.enemies.*;
	import com.smbc.ground.*;
	import com.smbc.interfaces.IAttackable;
	import com.smbc.pickups.*;
	import com.smbc.projectiles.*;
	import com.smbc.sound.*;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Point;
	import flash.media.*;
	import flash.utils.*;

	public class AnimatedObject extends LevObj
	{
		private static const COORDINATE_PRECISION:int = 2;
		private static const VY_BOUNCY_PITS_DEF:int = -1000;
		protected var bouncyPitsVy:Number = VY_BOUNCY_PITS_DEF;
		public var onGround:Boolean = true;
		public var lastOnGround:Boolean;
		public var onPlatform:Platform;
		public var onSpring:Boolean;
		public var lastOnSpring:Boolean;
		public var gravity:Number = 500;
		// last hit rectangle start
		// last hit rectangle end
		// attack hit rectangle start
		public var ahTop:Number;
		public var ahBot:Number;
		public var ahLft:Number;
		public var ahRht:Number;
		public var ahMidX:Number;
		public var ahMidY:Number;
		public var ahWidth:Number;
		public var ahHeight:Number;
		// attack hit rectangle end
		public var hitCeiling:Boolean;
		public var behindGround:Boolean;
		public var afterGround:Boolean;
		public var bottomAo:Boolean;
		public var vyMax:Number;
		public var vyMaxPsv:Number;
		public var vyMaxNgv:Number;
		public var vyMaxNgvDef:Number;
		public var vxMax:Number;
		public var vxMaxDef:Number;
		public var vxMin:int;
		public var vyMin:int;
		public var ax:Number = 400;
		public var fx:Number = .8;
		public var fy:Number = .8;
		public var sx:Number;
		public var sy:Number;
		public var xSpeed:Number;
		public var ySpeed:Number;
		public var speed:Number;
		public var defyGrav:Boolean;
		public var projLoc:Point;
		public var wallOnRight:Boolean;
		public var wallOnLeft:Boolean;
		public var jumpPwr:uint = 400;
		public var hRect:HRect;
		public var ahRect:ARect;
		public var hRect2:SecondaryHRect;
		public var lastStuckInWall:Boolean;
		public var checkAtkRect:Boolean;
		public var stuckInEnemy:Boolean;
		public var lvx:Number;
		public var lvy:Number;
		public var sortInt:int = 0;
		public var nyPlatform:Number;
		public var dxPlatform:Number;
		public var sprVX:Number;
		public var sprNX:Number;
		public var onFallingPlatform:Boolean;
		public var changeColorThisCycle:Boolean;
		public var platformAttachedTo:Platform;
		public var skinMask2:Sprite;
		// hit test

		public function AnimatedObject()
		{
			super();
		}
		override public function initiate():void
		{
			super.initiate();
			getRects();
			setStats();
			setSortInt();
			drawObj();
		}
		override protected function addedToStageHandler(e:Event):void
		{
			level.AO_STG_DCT.addItem(this);
			super.addedToStageHandler(e);
		}
		override protected function removedLsr(e:Event):void
		{
			level.AO_STG_DCT.removeItem(this);
			super.removedLsr(e);
		}
		/*override public function get height():Number
		{
			if (hHeight)
				return hHeight;
			else
				return super.height;
		}
		override public function get width():Number
		{
			if (hWidth)
				return hWidth;
			else
				return super.width;
		}*/
		public function setStats():void
		{
			lvx = 0;
			lvy = 0;
			if (hRect)
			{
				hRect.getHitPoints(lx,ly,scaleX);
				lhTop = hRect.hTop;
				lhBot = hRect.hBot;
				lhLft = hRect.hLft;
				lhRht = hRect.hRht;
				lhMidX = hRect.hMidX;
				lhMidY = hRect.hMidY;
				lhWidth = hRect.hWidth;
				lhHeight = hRect.hHeight;
				hTop = lhTop;
				hBot = lhBot;
				hLft = lhLft;
				hRht = lhRht;
				hMidX = lhMidX;
				hMidY = lhMidY;
				hWidth = lhWidth;
				hHeight = lhHeight;
			}
			nx = x;
			ny = y;
		}
		// GETRECTS
		private function getRects():void
		{
			if (numChildren > 0)
			{
				for (var i:uint = 0; i < numChildren; i++)
				{
					var mc:DisplayObject = DisplayObject(getChildAt(i));
					if (mc is ARect)
						ahRect = ARect(mc);
					else if (mc is SecondaryHRect)
						hRect2 = SecondaryHRect(mc);
					else if (mc is HRect && !(mc is ARect) && !(mc is SecondaryHRect))
						hRect = HRect(mc);
					if (this is FlagPole)
						trace(mc);
				}
			}
		}
		// SETSORTINT
		private function setSortInt():void
		{
			if (this is Character) sortInt = 9;
		}
		override public function updateObj():void
		{
			super.updateObj();
			updateStats();
			updateStatusEffects();
//			if ( !defyGrav && !getStatusEffect(STATFX_STOP) && !getStatusEffect(STATFX_KNOCK_BACK))
			if ( !defyGrav )
				gravityPull();
			updateLoc();
			setHitPoints();
			lastStuckInWall = stuckInWall;
			stuckInWall = false;
			hitCeiling = false;
			wallOnLeft = false;
			wallOnRight = false;
			onPlatform = null;
			onFallingPlatform = false;
			lastOnSpring = onSpring;
			onSpring = false;
		}
		protected function updateStats():void
		{
			lvx = vx;
			lvy = vy;
			if (onFallingPlatform)
				ny += 8;
			if (hRect)
			{
				lhTop = hRect.hTop;
				lhBot = hRect.hBot;
				lhLft = hRect.hLft;
				lhRht = hRect.hRht;
				lhMidX = hRect.hMidX;
				lhMidY = hRect.hMidY;
				lhWidth = hRect.hWidth;
				lhHeight = hRect.hHeight;
			}
		}
		override protected function prepareSkins():void
		{
//			needsTrueSize = true;
			super.prepareSkins();
		}
		protected function changeLastStatsToCurrent():void
		{
			lvx = vx;
			lvy = vy;
			if (hRect)
			{
				lhTop = hRect.hTop;
				lhBot = hRect.hBot;
				lhLft = hRect.hLft;
				lhRht = hRect.hRht;
				lhMidX = hRect.hMidX;
				lhMidY = hRect.hMidY;
				lhWidth = hRect.hWidth;
				lhHeight = hRect.hHeight;
			}
		}
		protected function copyLastStatsFromObject(obj:AnimatedObject):void
		{
			lvx = obj.lvx;
			lvy = obj.lvy;
			if (hRect && obj.hRect)
			{
				lhTop = obj.hRect.hTop;
				lhBot = obj.hRect.hBot;
				lhLft = obj.hRect.hLft;
				lhRht = obj.hRect.hRht;
				lhMidX = obj.hRect.hMidX;
				lhMidY = obj.hRect.hMidY;
				lhWidth = obj.hRect.hWidth;
				lhHeight = obj.hRect.hHeight;
			}
		}
		public function updateLoc():void
		{
			// check that speed isn't over max
			if (vxMax)
			{
				if (vx > vxMax) vx = vxMax;
				if (vx < -vxMax) vx = -vxMax;
			}
			if (vxMin && vx < vxMin && vx > -vxMin)
				vx = 0;
			if (vyMin && vy < vyMin && vy > -vyMin)
				vy = 0;
			if (vyMaxPsv && vy > vyMaxPsv) vy = vyMaxPsv;
			if (vyMaxNgv && vy < -vyMaxNgv) vy = -vyMaxNgv;
			if (vyMax)
			{
				if (vy > vyMax) vy = vyMax;
				else if (vy < -vyMax) vy = -vyMax;
			}
			// set future position
			nx += vx*dt;
			ny += vy*dt;
		}
		public function gravityPull():void
		{
			if (!onGround)
			{
				vy += gravity*dt;
			}
			lastOnGround = onGround;
			onGround = false;
		}
		protected function getPreciseCoordinates(num:Number):Number
		{
			var str:String = num.toString();
			var ind:int = str.indexOf(".");
			if (ind < 0)
				return num;
			str = str.substr();
			if (str.length <= COORDINATE_PRECISION)
				return num;
			return correctFloatingPointError(num,ind + COORDINATE_PRECISION);
		}
		public function setHitPoints():void
		{
			//globX = projLoc.localToGlobal(zeroPt).x;
			//globY = projLoc.localToGlobal(zeroPt).y;
			// Mario height = 32, width = 32
			nx = getPreciseCoordinates(nx);
			ny = getPreciseCoordinates(ny);
			if (hRect)
			{
				hRect.getHitPoints(nx,ny,scaleX);
				hTop = hRect.hTop;
				hBot = hRect.hBot;
				hLft = hRect.hLft;
				hRht = hRect.hRht;
				hMidX = hRect.hMidX;
				hMidY = hRect.hMidY;
				hWidth = hRect.hWidth;
				hHeight = hRect.hHeight;
			}
			else if (this is Projectile)
			{
				hMidX = nx;
				hMidY = ny;
			}
			else
			{
				hTop = ny - this.height;// hits top
				hBot = ny; // hits bottom
				hLft = nx - width/2;// hits left side
				hRht = nx + width/2;// hits right side
			}
			if (hRect2)
				hRect2.getHitPoints(nx,ny,scaleX);
			if (checkAtkRect)
			{
				ahRect.getHitPoints(nx,ny,scaleX);
				ahTop = ahRect.hTop;
				ahBot = ahRect.hBot;
				ahLft = ahRect.hLft;
				ahRht = ahRect.hRht;
				ahMidX = ahRect.hMidX;
				ahMidY = ahRect.hMidY;
				ahWidth = ahRect.hWidth;
				ahHeight = ahRect.hHeight;
				if (this is SamusBomb)
				{
					hTop = ahRect.hTop;
					hBot = ahRect.hBot;
					hLft = ahRect.hLft;
					hRht = ahRect.hRht;
					hMidX = ahRect.hMidX;
					hMidY = ahRect.hMidY;
					hWidth = ahRect.hWidth;
					hHeight = ahRect.hHeight;
				}
			}

			//verticalCollisionLeft = globX - cVertBuffer;// hits vertically left
			//verticalCollisionRight = globX + cVertBuffer;// hits vertically right
			//sideCollisionTop = globY - (this.height * .75);// hits side top
			//sideCollisionBottom = globY - (this.height * .25); // hits side bottom
		}
		// HIT
		override public function hit(mc:LevObj,hType:String):void
		{
			super.hit(mc,hType);
			if (mc is Ground)
				hitGround(mc as Ground,hType);
			else if (mc is Projectile)
				hitProj(mc as Projectile);
			else if (mc is Enemy)
				hitEnemy(mc as Enemy,hType);
			else if (mc is Pickup)
				hitPickup(mc as Pickup);
			else if (hType == "attack")
				hitAttack();
			else if (mc is Character)
				hitCharacter(mc as Character,hType);
		}
		public function hitAttack():void
		{
			// for Enemy class
		}
		public function hitCharacter(char:Character,side:String):void
		{
			// for enemy class
		}
		public function hitPickup(pickup:Pickup,showAnimation:Boolean = true):void
		{
			// for character class
		}
		public function hitProj(proj:Projectile):void
		{
			// blah
		}
		public function hitGround(mc:Ground,hType:String):void
		{
			if (!(this is Projectile) || (this as Projectile).needsAccurateGroundHits)
				switch (hType)
			{
				case "top":
					groundAbove(mc);
					break;
				case "bottom":
				if (mc.visible)
					groundBelow(mc);
					break;
				case "left":
				if (mc.visible)
					groundOnSide(mc,hType);
					break;
				case "right":
				if (mc.visible)
					groundOnSide(mc,hType);
					break;
				case "neutral":
					// nothing
				default:
//					trace("ground hit error");
					break;
			}
		}
		/*override public function gotoAndStop(frame:Object, scene:String=null):void
		{
			super.gotoAndStop(frame, scene);
			var rectDct:Dictionary = rectVec[currentFrame];
			for each (var hitRect:HitRectangle in rectDct)
			{
				if (hitRect.type == HitRectangle.TYPE_HIT)
					hRect =	hitRect;
				else if (hitRect.type == HitRectangle.TYPE_ATTACK)
					ahRect = hitRect;
				else if (hitRect.type == HitRectangle.TYPE_HIT_SECONDARY)
					hRect2 = hitRect;
			}
		}*/
		public function hitEnemy(enemy:Enemy,hType:String):void
		{
			//trace("hit enemy side: "+hType);
		}
		public function gBounceHit(g:Ground):void
		{
			// for Enemy and Mushroom
		}
		public function groundBelow(g:Ground):void
		{
			if (!(g is SpringRed) || !(this is Character) )
				onGround = true;
			vy = 0;
			if (g is Platform)
			{
				onPlatform = g as Platform;
				if (onPlatform.platType != "pully")
				{
					if (onPlatform.useVy)
						vy = onPlatform.vy;
					else if (onPlatform.vertical)
						nyPlatform = onPlatform.ny;
					else if (!onPlatform.vertical)
						dxPlatform = onPlatform.dx;
				}
				if (onPlatform.platType == "falling" || onPlatform.platType == "constantFall")
					onFallingPlatform = true;
				if (this is Character)
					onPlatform.setCharOnPlat();
			}
			else if (g is SpringRed && this is Character)
			{
				if (!lastOnSpring)
				{
					sprVX = vx;
					sprNX = nx;
				}
				vx = 0;
				nx = sprNX;
				SpringRed(g).sprBounce();
				SpringRed(g).SPRING_OBJS_DCT.addItem(this);
				onSpring = true;
			}
			ny = g.hTop;
			setHitPoints();
			hBot = g.hTop;
		}
		public function groundAbove(g:Ground):void
		{
			setHitPoints()
			// when object hits a cieling
		}
		public function groundOnSide(g:Ground,side:String):void
		{
			setHitPoints();
//			var statFxKnockBack:StatFxKnockBack = getStatusEffect(STATFX_KNOCK_BACK) as StatFxKnockBack;
//			if (statFxKnockBack)
//				statFxKnockBack.hitWall(g,side);
		}

		protected function checkState():void
		{
			// for subclasses
		}
		override public function rearm():void
		{
			super.rearm();
			setHitPoints();
		}
		// Projectile and FireBar override this
		override public function checkStgPos():void
		{
			if (Cheats.bouncyPits && ny > GLOB_STG_BOT && vy >= 0 && cState != ST_DIE)
				activateBouncyPit();
			if (nx > level.locStgLft - TILE_SIZE*2 && nx < level.locStgRht + TILE_SIZE*2)
			{
				if (dosTop || dosBot)
					checkDosSides();
				if (parent != level)
					level.addChild(this);
			}
			else if (parent == level && !updateOffScreen)
				level.removeChild(this);
			if (destroyOffScreen || dosTop || dosBot || dosLft || dosRht)
				checkDosSides();
		}

		protected function activateBouncyPit():void
		{
			ny = GLOB_STG_BOT;
			y = ny;
			setHitPoints();
			vy = bouncyPitsVy;
		}

		override public function cleanUp():void
		{
			super.cleanUp();
			if (level)
			{
				level.AO_DCT.removeItem(this);
				level.AO_STG_DCT.removeItem(this);
			}
		}
		override protected function checkDosSides():void
		{
			//if (onScreen || updateOffScreen)
			//	return;
			if (dosBot)
			{
				if (scaleY > 0 && ny - height > locStgBot)
					destroy();
				else if (scaleY < 0 && ny > locStgBot)
					destroy();
			}
			if (dosTop)
			{
				if (scaleY > 0 && ny < locStgTop)
					destroy();
				else if (scaleY < 0 && ny + height < locStgTop)
					destroy();
			}
			if (dosLft && nx + width*.5 < level.locStgLft)
				destroy();
			if (dosRht && nx - width*.5 > level.locStgRht)
				destroy();
		}
		protected function attackObjNonPiercing(obj:IAttackable):void
		{
		}
		protected function attackObjPiercing(obj:IAttackable):void
		{

		}
		protected function hitIsAllowed(mc:IAttackable):Boolean
		{
			return false;
		}
	}
}
