package com.smbc.projectiles
{

	import com.customClasses.*;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatusProperty;
	import com.explodingRabbit.utils.CustomDictionary;
	import com.smbc.characters.*;
	import com.smbc.data.Cheats;
	import com.smbc.enemies.*;
	import com.smbc.ground.*;
	import com.smbc.interfaces.IAttackable;
	import com.smbc.main.*;

	import flash.utils.getTimer;

	public class Projectile extends AnimatedObject
	{
		public static const SOURCE_TYPE_PLAYER:String = "player";
		public static const SOURCE_TYPE_ENEMY:String = "enemy";
		public static const SOURCE_TYPE_NEUTRAL:String = "neutral";
		public const HIT_OBJS_DCT:CustomDictionary = new CustomDictionary(true);
		protected var C_HIT_DCT:CustomDictionary = new CustomDictionary(true);
		protected var L_HIT_DCT:CustomDictionary = new CustomDictionary(true);
		protected var alwaysAllowHits:Boolean;
		internal var newX:Number;
		internal var newY:Number;
		public var vertPwr:Number;
		public var sourceType:String;
		public var source:LevObj;
		public var needsAccurateGroundHits:Boolean; // returns side when hits ground
		public var doesntHitBricks:Boolean;
		protected var _damageAmt:int;
		// Initialization:
		public function Projectile(source:LevObj,sourceType:String)
		{
			this.source = source;
			this.sourceType = sourceType;
			destroyOffScreen = true;
			if (sourceType == SOURCE_TYPE_PLAYER)
			{
				hitTestTypesDct.addItem(HT_PROJECTILE_CHARACTER);
				addProperty( new StatusProperty(PR_PIERCE_AGG) );
				addHitTestableItem(HT_ENEMY);
				addHitTestableItem(HT_BRICK);
			}
			else if (sourceType == SOURCE_TYPE_ENEMY)
			{
				hitTestTypesDct.addItem(HT_PROJECTILE_ENEMY);
				addHitTestableItem(HT_CHARACTER);
				addProperty( new StatusProperty(PR_DAMAGES_PLAYER_AGG) );
				addProperty( new StatusProperty(PR_STOP_PAS) );
			}
		}
		override public function initiate():void
		{
			super.initiate();
			if (!stopHit)
				level.checkCollisions(this);
			if ( getProperty(PR_PASSTHROUGH_ALWAYS) )
			{
				C_HIT_DCT = new CustomDictionary(true);
				L_HIT_DCT = new CustomDictionary(true);
			}
		}

		override public function updateObj():void
		{
			super.updateObj();
			if ( getProperty(PR_PASSTHROUGH_ALWAYS) )
			{
				L_HIT_DCT.clear();
				var key:Object;
				if (clearHitsAfterTime)
				{
					for (key in C_HIT_DCT)
					{
						trace("time: "+(getTimer() - C_HIT_DCT[key]));
						if ( getTimer() - C_HIT_DCT[key] >= clearHitsAfterTime)
							C_HIT_DCT.removeItem(key);
					}
				}
				for (key in C_HIT_DCT)
				{
					L_HIT_DCT.addItem(key,C_HIT_DCT[key]);
				}
				C_HIT_DCT.clear();
			}
		}


		protected function setDir():void
		{
			// blah
		}
		override public function hitGround(ground:Ground,side:String):void
		{
			if (needsAccurateGroundHits)
				super.hitGround(ground,side);
			if ( getProperty(PR_PASSTHROUGH_ALWAYS) )
				ground.confirmedHitProj(this);
		}
		override public function hitEnemy(enemy:Enemy,hType:String):void
		{
			if ( getProperty(PR_PASSTHROUGH_ALWAYS) )
				enemy.confirmedHitProj(this);
		}
		override public function hit(mc:LevObj,hType:String):void
		{
			if ( hitIsAllowed(mc as IAttackable) )
				super.hit(mc,hType);
		}
		override protected function hitIsAllowed(mc:IAttackable):Boolean
		{
			if (alwaysAllowHits)
				return true;
			if (L_HIT_DCT[mc])
			{
				if (!clearHitsAfterTime)
					C_HIT_DCT.addItem(mc);
				else
					C_HIT_DCT.addItem(mc, L_HIT_DCT[mc]);
				return false;
			}
			else if (C_HIT_DCT[mc])
				return false;
			if (!clearHitsAfterTime)
				C_HIT_DCT.addItem(mc);
			else
				C_HIT_DCT.addItem(mc,getTimer());
			return true;
		}
		public function confirmedHit(mc:IAttackable,damaged:Boolean = true):void
		{
			HIT_OBJS_DCT.addItem(mc);
			if ( !mc.isSusceptibleToProperty( getProperty(PR_PIERCE_AGG) ) && !Cheats.allWeaponsPierce )
				attackObjNonPiercing(mc);
			else
			{
				if ( damaged )
					attackObjPiercing(mc);
				if ( !getProperty(PR_PASSTHROUGH_ALWAYS) && !( mc.health <= 0 && getProperty(PR_PASSTHROUGH_DEFEAT) ) )
					destroy();
			}
		}
		override protected function attackObjNonPiercing(obj:IAttackable):void
		{
			if ( !getProperty(PR_PASSTHROUGH_ALWAYS) )
				destroy();
		}
		override public function cleanUp():void
		{
			super.cleanUp();
			level.PLAYER_PROJ_DCT.removeItem(this);
			level.PROJ_DCT.removeItem(this);
		}
		override public function checkStgPos():void
		{
			if (nx > level.locStgLft - TILE_SIZE*2 && nx < level.locStgRht + TILE_SIZE)
			{
				if (parent != level) level.addChild(this);
			}
			else if (parent == level && !updateOffScreen)
				level.removeChild(this);
			if (destroyOffScreen || dosTop || dosBot || dosLft || dosRht)
				checkDosSides();
		}
		override protected function checkDosSides():void
		{
			if (dosTop && ny + height*.5 < locStgTop) destroy();
			else if (dosBot && ny - height*.5 > locStgBot) destroy();
			else if (dosLft && nx + width*.5 < locStgLft) destroy();
			else if (dosRht && nx - width*.5 > locStgRht) destroy();
			else if (destroyOffScreen)
			{
				if (ny + height*.5 < locStgTop
				|| ny - height*.5 > locStgBot
				|| nx + width*.5 < locStgLft
				|| nx - width*.5 > locStgRht) destroy();
			}
		}
		public function get damageAmt():int
		{
			return _damageAmt;
		}
	}

}
