package com.smbc.pickups
{
	import com.explodingRabbit.cross.gameplay.statusEffects.StatusProperty;
	import com.explodingRabbit.utils.CustomDictionary;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.characters.*;
	import com.smbc.data.AnimationTimers;
	import com.smbc.data.PickupInfo;
	import com.smbc.enemies.*;
	import com.smbc.ground.*;
	import com.smbc.main.*;

	import flash.display.MovieClip;

	public class Mushroom extends Pickup
	{

		// Constants:
		// Public Properties:
		// Private Properties:
		private const MAIN_ANIM_TMR:CustomTimer = AnimationTimers.ANIM_SLOW_TMR;
		public var color:String;
		private static const FL_RED_START:String = "redStart";
		private static const FL_RED_END:String = "redEnd";
		private static const FL_POISON_START:String = "poisonStart";
		private static const FL_POISON_END:String = "poisonEnd";
		private static const FL_GREEN_START:String = "greenStart";
		private static const FL_GREEN_END:String = "greenEnd";
		public static const ST_RED:String = "redStart";
		public static const ST_POISON:String = "poisonStart";
		public static const ST_GREEN:String = "greenStart";
		private const BOUNCE_AMT:int = 350;
		private const FALL_SPEED:int = 340;
		private static const BOUNCE_GRAVITY:int = 1500;
		private static const FALL_GRAVITY:int = 5000;
		private var subType:String;

//		upgrade stuff
		private var storedUpgrades:CustomDictionary;
		private var viewedUpgrades:CustomDictionary;
		private var charNumUpgrades:int;
		private var tierOnDamage:int;


		// Initialization:
		public function Mushroom(subType:String):void
		{
			this.subType = subType;
			if (subType == ST_RED)
				type = PickupInfo.MUSHROOM;
			else if (subType == ST_POISON)
				type = PickupInfo.POISON_MUSHOOM;
			else if (subType == ST_GREEN)
				type = PickupInfo.GREEN_MUSHROOM;
			super(type);
			playsRegularSound = true;
			gotoAndStop(subType);
			_boomerangGrabbable = true;
			stopAnim = false;
			xSpeed = DEFAULT_X_SPEED;
			addHitTestableItem(HT_GROUND_NON_BRICK);
			addHitTestableItem(HT_BRICK);
			addHitTestableItem(HT_PLATFORM);

//			upgrade stuff
			if (subType == ST_RED)
			{
				var curCharNum:int = STAT_MNGR.curCharNum;
				tierOnDamage = STAT_MNGR.storedTierVec[curCharNum];
				STAT_MNGR.storedTierVec[curCharNum] = null;
				storedUpgrades = STAT_MNGR.getStoredUpgrades();
				if (storedUpgrades)
				{
					viewedUpgrades = STAT_MNGR.storedViewedUpgradesVec[curCharNum].clone();
					STAT_MNGR.storedViewedUpgradesVec[curCharNum] = null;
				}
				charNumUpgrades = curCharNum;
			}
			else if (subType == ST_POISON)
			{
				addProperty( new StatusProperty(PR_DAMAGES_PLAYER_AGG) );
			}
		}
		override public function setStats():void
		{
			super.setStats();
			gravity = FALL_GRAVITY;
			vyMaxPsv = FALL_SPEED;
		}
		override protected function updateStats():void
		{
			super.updateStats();
			if (vy < 0)
				gravity = BOUNCE_GRAVITY;
			touchedWall = false;
		}
		override protected function exitBrickEnd():void
		{
			super.exitBrickEnd();
			vx = xSpeed;
			defyGrav = false;
		}
		override public function gBounceHit(g:Ground):void
		{
			vy = -BOUNCE_AMT;
			gravity = BOUNCE_GRAVITY;
			onGround = false;
			lastOnGround = false;
			updateLoc();
			setHitPoints();
			if (nx < g.hMidX)
				vx = -vx;
		}

		override public function groundOnSide(g:Ground,side:String):void
		{
			if (!touchedWall)
			{
				if (side == "left")
				{
					if (vx < 0)
						vx = -vx;
					nx = g.hRht + hWidth/2;
					wallOnLeft = true;
				}
				else if (side == "right")
				{
					if (vx > 0)
						vx = -vx;
					wallOnRight = true;
					nx = g.hLft - hWidth/2;
				}
				super.groundOnSide(g,side);
			}
			touchedWall = true;
		}
		override public function groundBelow(g:Ground):void
		{
			if (onGround || lastOnGround)
				gravity = FALL_GRAVITY;
			super.groundBelow(g);
		}

		public function transferStoredUpgrades():void
		{
			if (!storedUpgrades)
				return;
			var dct:CustomDictionary = storedUpgrades;
//			if (STAT_MNGR.curCharNum == Bass.CHAR_NUM || STAT_MNGR.curCharNum == MegaMan.CHAR_NUM)
//				dct = getHalfRandomUpgrades();
			STAT_MNGR.addStoredUpgrades(charNumUpgrades, dct, tierOnDamage, viewedUpgrades);
		}

		private function getHalfRandomUpgrades():CustomDictionary
		{
			var num:int = Math.ceil( storedUpgrades.length / 2 );
			var vec:Vector.<String> = new Vector.<String>();
			for each( var upg:String in storedUpgrades)
			{
				vec.push(upg);
			}
			var dct:CustomDictionary = new CustomDictionary();
//			var i:int = num - 1;
			while (dct.length < num)
			{
				var str:String = vec[ int(Math.random()*num) ];
				if ( dct[str] == undefined )
					dct.addItem(str,str);
			}
			return dct;
		}

		override public function checkFrame():void
		{
			var cfl:String = currentFrameLabel;
			if ( type == PickupInfo.MUSHROOM )
			{
				if (cfl == FL_RED_END)
					gotoAndStop(FL_RED_START);
			}
			else if ( type == PickupInfo.POISON_MUSHOOM )
			{
				if (cfl == FL_POISON_END)
					gotoAndStop(FL_POISON_START);
			}
			else if ( type == PickupInfo.GREEN_MUSHROOM )
			{
				if (cfl == FL_GREEN_END)
					gotoAndStop(FL_GREEN_START);
			}
		}
	}

}
