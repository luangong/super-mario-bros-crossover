package com.smbc.ground
{
	import com.explodingRabbit.utils.CustomDictionary;
	import com.smbc.characters.*;
	import com.smbc.data.Difficulties;
	import com.smbc.data.GameSettings;
	import com.smbc.data.GameStates;
	import com.smbc.data.HRect;
	import com.smbc.data.ScoreValue;
	import com.smbc.enemies.*;
	import com.smbc.graphics.PullyRope;
	import com.smbc.graphics.Scenery;
	import com.smbc.main.*;
	import com.smbc.pickups.*;
	import com.smbc.projectiles.*;
	import com.smbc.sound.*;

	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.media.*;

	public class Platform extends Ground
	{
		protected var platWidth:int;
		protected var moveAmt:int;
		public var platType:String;
		public var dy:Number;
		public static const PT_CONSTANT_RISE:String = "ConstantRise";
		public static const PT_CONSTANT_FALL:String = "ConstantFall";
		public static const PT_STEP_CONSTANT_RIGHT:String = "StepConstantRight";
		public static const PT_WAVE_HORIZONTAL:String = "WaveHorizontal";
		public static const PT_WAVE_VERTICAL:String = "WaveVertical";
		public static const PT_STEP_FALL:String = "StepFall";
		public static const PT_PULLY:String = "Pully";
		public static const PT_FALLING:String = "PullyFalling";
		public static const PT_FLAG_JUMP:String = "FlagJump";
		protected var ySpeed:Number = 110;
		protected var fallSpeed:Number = 225; // 250;
		protected var ayPully:Number = 200; // 300;
		protected var ayPullyFall:Number = 500;
		protected var fyPully:Number = 0.0006;
		protected var vyMaxPully:Number = 275; // 325;
		protected var vyMaxPullyFall:Number = 350; // 400;
		protected var vyMinPully:Number = 20;
		private const CONSTANT_RIGHT_SPEED:int = 120;
		public var pullyCornerX:Number;
		private var partnerX:Number;
		private var partner:Platform;
		public var pullyLoc:String;
		public var moved:Boolean;
		public var yMin:Number;
		public var yMid:Number;
		public var yMax:Number;
		public var yMaxTemp:Number;
		protected var waveAngle:Number = 0;
		protected var waveSpeed:Number = 1;
		protected var waveRange:Number = 150;
		protected var hWaveSpeed:Number = 1.5;
		protected var hWaveRange:Number = 60;
		protected var centerX:int;
		protected var centerY:int;
		public var useVy:Boolean;
		public var dx:Number;
		private var nWaveAngle:Number;
		private var hRect:HRect;
		public var fall:Boolean;
		public var vertical:Boolean;
		public var charOnPlat:Boolean;
		public var pullyRope:PullyRope;
		private static const NORMAL_PREFIX:String = "normal-";
		private static const NORMAL_END_PREFIX:String = "normalEnd-";
//		private const CLOUD_PREFIX:String = "cloud-";
		private var resetPos:Number;
		private var active:Boolean;
		private const MIN_PLAT_WIDTH:int = 2;
		private var attachedObjectsDct:CustomDictionary;


		public function Platform(fStr:String = null,type:String = null,_platWidth:int = 0)
		{
			super(fStr);
			var stopFrameStr:String;
			offGrid = true;
			stopAnim = false;
			if (type)
				platType = type;
			level.ALWAYS_ANIM_DCT.addItem(this);
			if (_platWidth)
				this.platWidth = _platWidth;
			if (fStr)
			{
				var startTypeIndex:int = fStr.indexOf("&&type=")+7;
				var endTypeIndex:int = fStr.indexOf("&&",startTypeIndex);
				if (endTypeIndex == -1)
					endTypeIndex = fStr.length;
				platWidth = int(fStr.charAt(fStr.indexOf("&&width=")+8));
			}
			else
				stopFrameStr = NORMAL_PREFIX+platWidth.toString();
			var dif:int = GameSettings.difficulty;
			if (fStr && fStr.indexOf("Cloud") == -1)
			{
				if (dif == Difficulties.HARD)
					platWidth -= 2;
				else if (dif == Difficulties.VERY_HARD)
					platWidth = MIN_PLAT_WIDTH;
				if (platWidth < MIN_PLAT_WIDTH)
					platWidth = MIN_PLAT_WIDTH;
				stopFrameStr = NORMAL_PREFIX+platWidth.toString();
				platType = fStr.substring(startTypeIndex,endTypeIndex);
			}
			else if (fStr)
			{
				if (!platWidth)
					platWidth = 6;
				if (dif == Difficulties.HARD)
					platWidth -= 2;
				else if (dif == Difficulties.VERY_HARD)
					platWidth = MIN_PLAT_WIDTH;
				if (platWidth < MIN_PLAT_WIDTH)
					platWidth = MIN_PLAT_WIDTH;
				stopFrameStr = NORMAL_PREFIX+platWidth.toString();
				platType = PT_STEP_CONSTANT_RIGHT;
			}
			gotoAndStop(stopFrameStr);
//			trace("stopFrame: "+stopFrameStr+" currentLabel: "+currentLabel);
			if (numChildren > 0)
			{
				for (var i:uint = 0; i < numChildren; i++)
				{
					var mc:DisplayObject = DisplayObject(getChildAt(i));
					if (mc is HRect)
						hRect = HRect(mc);
				}
			}
			setColPoints();
			hitTestTypesDct.clear();
			hitTestTypesDct.addItem(HT_PLATFORM);

		}
		override public function initiate():void
		{
			super.initiate();
			setColPoints();
			setLastHitPoints();
			switch (platType)
			{

				case PT_CONSTANT_RISE:
				{
					vertical = true;
					useVy = true;
					if (level.levNum != 4)
						resetPos = GLOB_STG_TOP - hHeight;
					else
						resetPos = GLOB_STG_TOP + TILE_SIZE*2;
					//vy = -ySpeed;
					break;
				}
				case PT_CONSTANT_FALL:
				{
					vertical = true;
					useVy = true;
					//ySpeed;
					break;
				}
				case PT_STEP_CONSTANT_RIGHT:
				{
					vertical = false;
					useVy = false;
					break;
				}
				case PT_WAVE_HORIZONTAL:
				{
					vertical = false;
					useVy = false;
					centerX = x;
					centerY = y;
					break;
				}
				case PT_WAVE_VERTICAL:
				{
					vertical = true;
					useVy = false;
					centerX = x;
					centerY = y;
					break;
				}
				case PT_STEP_FALL:
				{
					vertical = true;
					useVy = true;
					dosBot = true;
					break;
				}
				case PT_PULLY:
				{
					//pullyCornerX = x - TILE_SIZE*.5;
					//pullyCornerY = y + TILE_SIZE*.5;
					//break;
				}
				default:
				{
					vertical = true;
					useVy = true;
					vy = 0;
					break;
				}
			}
		}

		override public function disarm():void
		{
			super.disarm();
			ny = y;
			nx = x;
		}

		public function getPartnerStep1():void
		{
			level.pullyCornerVec.forEach(function ff(elem:Scenery,ind:int,vec:Vector.<Scenery>):void
			{
				if (pullyCornerX == elem.x)
				{
					if (elem.currentFrameLabel.indexOf("Left") != -1)
					{
						pullyRope = new PullyRope(elem.currentFrameLabel);
						level.addToLevel(pullyRope);
						pullyRope.x = elem.x + TILE_SIZE*.5;
						pullyRope.y = elem.y + TILE_SIZE;
						pullyRope.height = y - pullyRope.y;
						yMin = elem.y + TILE_SIZE;
						yMaxTemp = y - yMin;
						partnerX = vec[ind+1].x;
					}
					else if (elem.currentFrameLabel.indexOf("Right") != -1)
					{
						pullyRope = new PullyRope(elem.currentFrameLabel);
						level.addToLevel(pullyRope);
						pullyRope.x = elem.x + TILE_SIZE*.5;
						pullyRope.y = elem.y + TILE_SIZE;
						pullyRope.height = y - pullyRope.y;
						yMin = elem.y + TILE_SIZE;
						yMaxTemp = y - yMin;
						partnerX = vec[ind-1].x;
					}
				}
			});
		}
		public function getPartnerStep2():void
		{
			level.pullyPlatVec.forEach(function matchPartnerX(elem:Platform,ind:int,vec:Vector.<Platform>):void
			{
				if (elem.pullyCornerX == partnerX)
				{
					partner = elem;
					yMax = yMin + yMaxTemp + partner.yMaxTemp;
					yMid = (yMin + yMax)*.5;
				}
			});
		}
		override public function updateGround():void
		{
			super.updateGround();
			if ( (platType != PT_STEP_FALL && platType != PT_PULLY) || ( !(player is Sophia) || Sophia(player).rotation == 0 ) )
				setLastHitPoints();
			if (platType == PT_CONSTANT_FALL)
			{
				vy = ySpeed;
				y += vy*dt;
				if (y > GLOB_STG_BOT && GS_MNGR.gameState != GameStates.CHARACTER_SELECT)
				{
					if (level.levNum != 4)
						y = GLOB_STG_TOP - hHeight;
					else
						y = GLOB_STG_TOP + TILE_SIZE*2;
				}
				//ny = y;
				//ny += ySpeed*dt;
			}
			// disappear
			else if (platType == PT_CONSTANT_RISE)
			{
				vy = ySpeed;
				y -= vy*dt;
				if (y < resetPos)
					y = GLOB_STG_BOT;
				//ny = y;
				//ny += -ySpeed*dt;
			}
			else if (platType == PT_STEP_CONSTANT_RIGHT)
			{
				if (active)
				{
					lx = x;
					x += CONSTANT_RIGHT_SPEED * dt;
					dx = x - lx;
					if (player.onPlatform && player.cloudPlatform && charOnPlat)
					{
						player.x += dx;
						player.dxPlatform = NaN;
					}
				}
			}
			//waves
			else if (platType == PT_WAVE_VERTICAL)
			{
				y = centerY + Math.sin(waveAngle) * waveRange;
				waveAngle += waveSpeed*dt;
				// calculate next position
				nWaveAngle = waveAngle;
				ny = centerY + Math.sin(nWaveAngle) * waveRange;
				nWaveAngle += waveSpeed*dt;

			}
			else if (platType == PT_WAVE_HORIZONTAL)
			{
				x = centerX + Math.sin(waveAngle) * hWaveRange;
				waveAngle += hWaveSpeed*dt;
				// calculate next position
				nWaveAngle = waveAngle;
				nx = centerX + Math.sin(nWaveAngle) * hWaveRange;
				nWaveAngle += hWaveSpeed*dt;
				dx = nx - x;
			}
			else if (platType == PT_FALLING)
			{
				vy += ayPullyFall*dt;
				if (vy > vyMaxPullyFall) vy = vyMaxPullyFall;
				y += vy*dt;
			}
			charOnPlat = false;
			moved = false;
			ly = y;
			if (platType != PT_STEP_FALL && platType != PT_PULLY)
				setColPoints()
			if (attachedObjectsDct)
				updateAttachedObjects();
		}
		private function updateAttachedObjects():void
		{
			for (var key:Object in attachedObjectsDct)
			{
				var ao:AnimatedObject = key as AnimatedObject;
				var xDif:Number = attachedObjectsDct[key];
				ao.ny = y;
				ao.nx = x + xDif;
				ao.drawObj();
			}
		}
		public function updatePully():void
		{
			if (!moved && !charOnPlat && !partner.charOnPlat)
			{
				if (vy != 0)
				{
					vy *= Math.pow(fyPully,dt);
					if (vy > vyMaxPully)
						vy = vyMaxPully;
					else if (vy < -vyMaxPully)
						vy = -vyMaxPully;
					else if (vy < vyMinPully && vy > -vyMinPully)
						vy = 0;
					setLastHitPoints();
					partner.setLastHitPoints();
					y += vy*dt;
					movePartner();
					partner.moved = true;
					if (attachedObjectsDct)
						updateAttachedObjects();
				}
			}
		}
		public function setCharOnPlat():void
		{
			charOnPlat = true;
			//partner.charOnPlat = true;
			if (charOnPlat && platType == PT_PULLY)
			{
				if (pullyLoc != "bottom")
				{
					vy += ayPully*dt;
					if (vy > vyMaxPully)
						vy = vyMaxPully;
					else if (vy < -vyMaxPully)
						vy = -vyMaxPully;
					setLastHitPoints();
					partner.setLastHitPoints();
					y += vy*dt;
					movePartner();
				}
				else
				{
					level.scorePop(ScoreValue.PULLY_FALL,player.hMidX,player.hMidY);
					pullyFall();
					partner.pullyFall();
				}
			}
			else if (platType == PT_STEP_FALL)
			{
				vy = fallSpeed;
				setLastHitPoints();
				y += vy*dt;
				setColPoints();
			}
			else if (platType == PT_STEP_CONSTANT_RIGHT)
			{
				if (!active)
				{
					active = true;
					x += CONSTANT_RIGHT_SPEED * dt;
					setColPoints();
				}
				player.cloudPlatform = true;
			}
		}
		public function movePartner():void
		{
			partner.vy = -vy;
			if (y < yMid)
				partner.y = yMid + (yMid - y);
			else if (y > yMid) partner.y = yMid - (y - yMid);
			else if (y == yMid) partner.y = yMid;
			if (y <= yMin || partner.y >= partner.yMax )
			{
				y = yMin;
				partner.y = partner.yMax;
				vy = 0;
				partner.vy = 0;
				pullyLoc = "top";
				partner.pullyLoc = "bottom";
			}
			else if (y >= yMax || partner.y <= partner.yMin)
			{
				y = yMax;
				partner.y = partner.yMin;
				vy = 0;
				partner.vy = 0;
				pullyLoc = "bottom";
				partner.pullyLoc = "top";
			}
			else
			{
				pullyLoc = "mid";
				partner.pullyLoc = "mid";
			}
			pullyRope.height = y - pullyRope.y;
			partner.pullyRope.height = partner.y - partner.pullyRope.y;
			setColPoints();
			if ( !level.contains(partner) )
				level.addChild(partner);
			partner.setColPoints();
			if (attachedObjectsDct)
				updateAttachedObjects();
		}
		public function pullyFall():void
		{
			platType = PT_FALLING;
			dosBot = true;
			vy = 0;
			if (level.pullyPlatVec.indexOf(this) != -1)
				level.pullyPlatVec.splice(level.pullyPlatVec.indexOf(this),1);
//			var pullyRopeEnd:PullyRopeEnd = new PullyRopeEnd(pullyRope.currentFrameLabel);
//			pullyRopeEnd.x = x;
//			pullyRopeEnd.y = y;
//			level.addToLevel(pullyRopeEnd);

		}
		public function attachObject(ao:AnimatedObject):void
		{
			var xDif:Number = ao.nx - x;
			if (!attachedObjectsDct)
				attachedObjectsDct = new CustomDictionary(true);
			attachedObjectsDct.addItem(ao,xDif);
			ao.platformAttachedTo = this;
		}
		public function detachObject(ao:AnimatedObject):void
		{
			attachedObjectsDct.removeItem(ao);
			if (ao.platformAttachedTo == this)
				ao.platformAttachedTo = null;
		}
		override public function setColPoints():void
		{
			var rect:Rectangle = hRect.getBounds(level);
			rect.width = Math.round(rect.width);
			rect.height = Math.round(rect.height);
			hTop = rect.top; // hits top
			hBot = rect.bottom; // hits bottom
			hLft = rect.left; // hits left side
			hRht = rect.right; // hits right side
			hMidX = this.x;
			hMidY = this.y + hHeight/2;
			hHeight = rect.height;
			hWidth = rect.width;
		}
		public function setLastHitPoints():void
		{
			lhTop = hTop;
			lhBot = hBot;
			lhLft = hLft;
			lhRht = hRht;
			lhMidX = hMidX;
			lhMidY = hMidY;
		}

		override public function checkFrame():void
		{
			if ( previousFrameLabelIs( NORMAL_END_PREFIX + platWidth ) )
				gotoAndStop(NORMAL_PREFIX + platWidth);
		}


		override public function cleanUp():void
		{
			super.cleanUp();
			var ind:int;
			if (level.platVec)
			{
				ind = level.platVec.indexOf(this);
				if (ind != -1)
					level.platVec.splice(ind,1);
			}
			if (level.pullyPlatVec)
			{
				ind = level.pullyPlatVec.indexOf(this);
				if (ind != -1)
					level.pullyPlatVec.splice(ind,1);
			}
			level.ALWAYS_ANIM_DCT.removeItem(this);
			if (attachedObjectsDct)
				attachedObjectsDct.clear();
		}
	}
}
