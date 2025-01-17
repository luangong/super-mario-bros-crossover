package com.smbc.data
{
	import com.customClasses.*;
	import com.smbc.characters.*;
	import com.smbc.characters.base.MarioBase;
	import com.smbc.characters.base.MegaManBase;
	import com.smbc.enemies.*;
	import com.smbc.graphics.*;
	import com.smbc.ground.*;
	import com.smbc.interfaces.IAttackable;
	import com.smbc.level.Level;
	import com.smbc.main.*;
	import com.smbc.managers.StatManager;
	import com.smbc.pickups.*;
	import com.smbc.projectiles.*;

	public class HitTester
	{

		// Constants:
		// Public Properties:
		public static const SIDE_TOP:String = "top";
		public static const SIDE_BOTTOM:String = "bottom";
		public static const SIDE_LEFT:String = "left";
		public static const SIDE_RIGHT:String = "right";
		private var cHit:Boolean;
		private var maxDist:int;
		public static const MAX_DIST_DEF:int = 125;
		private const STOMP_PADDING:int = 15;
		private const level:Level = GlobVars.level;
		private var attackedEnemy:Boolean;

		private static const CORNER_ROUNDING_AMOUNT:Number = 9;
		// Private Properties:

		// Initialization:
		public function HitTester():void
		{
			// nothing
		}
		public function hTest(mc1:LevObj,mc2:LevObj):void
		{
			cHit = false;
			if (mc1 is Ground)
				groundHitTest(mc2 as AnimatedObject,mc1 as Ground);
			else if (mc2 is Ground)
				groundHitTest(mc1 as AnimatedObject,mc2 as Ground);
			else if (mc1 is Character)
			{
				if (mc2 is FireBar)
					FireBarHitTest(mc1 as Character,mc2 as FireBar);
				else
					animObjHitTest(mc1 as AnimatedObject,mc2 as AnimatedObject);
			}
			else if (mc2 is Character)
			{
				if (mc1 is FireBar)
					FireBarHitTest(mc2 as Character,mc1 as FireBar);
				else
					animObjHitTest(mc2 as AnimatedObject,mc1 as AnimatedObject);
			}
			else
				animObjHitTest(mc1 as AnimatedObject,mc2 as AnimatedObject)
			// checks for secondary hRect
			if (mc1 is AnimatedObject && (mc1 as AnimatedObject).hRect2 && !(mc2 is Ground))
				multipleHRectHitTest(mc1 as AnimatedObject,mc2 as AnimatedObject);
			else if (mc2 is AnimatedObject && (mc2 as AnimatedObject).hRect2 && !(mc1 is Ground))
				multipleHRectHitTest(mc2 as AnimatedObject,mc1 as AnimatedObject);
		}
		// FIREBARHITTEST
		private function FireBarHitTest(char:Character,ao:FireBar):void
		{
			if(ao.bmd2.hitTest(ao.bRect.topLeft,255,char.hRect.getBounds(level),null,255))
			{
				char.hit(ao,"neutral");
			}
		}
		private function multipleHRectHitTest(mc1:AnimatedObject,mc2:AnimatedObject):void
		{
			if (mc1.hRect2)
			{
				if (mc2 is Character)
				{
					if (Character(mc2).checkAtkRect && !attackedEnemy && mc1 is IAttackable && Character(mc2).ahTop <= mc1.hRect2.hBot && Character(mc2).ahBot >= mc1.hRect2.hTop && Character(mc2).ahLft <= mc1.hRect2.hRht && Character(mc2).ahRht >= mc1.hRect2.hLft)
						(mc2 as Character).landAttack(mc1 as IAttackable);
					if (mc1 is KoopaGreen)
						return;
				}
				if (mc1.hRect2.hTop <= mc2.hBot && mc1.hRect2.hBot >= mc2.hTop && mc1.hRect2.hLft <= mc2.hRht && mc1.hRect2.hRht >= mc2.hLft) // penetrating ground
				{
					if (mc1 is Enemy && (mc1 as Enemy).stompable)
						checkLastHitPoints(mc1,true,mc2,true,true);
					else
					{
						mc1.hit(mc2,"neutral");
						mc2.hit(mc1,"neutral");
					}
				}
			}
			if (mc2.hRect2)
			{
				if (mc1 is Character)
				{
					if (Character(mc1).checkAtkRect && !attackedEnemy && mc2 is IAttackable && Character(mc1).ahTop <= mc2.hRect2.hBot && Character(mc1).ahBot >= mc2.hRect2.hTop && Character(mc1).ahLft <= mc2.hRect2.hRht && Character(mc1).ahRht >= mc2.hRect2.hLft)
						(mc1 as Character).landAttack(mc2 as IAttackable);
					if (mc2 is KoopaGreen)
						return;
				}
				if (mc2.hRect2.hTop <= mc1.hBot && mc2.hRect2.hBot >= mc1.hTop && mc2.hRect2.hLft <= mc1.hRht && mc2.hRect2.hRht >= mc1.hLft)
				{
					if (mc2 is Enemy && (mc2 as Enemy).stompable)
						checkLastHitPoints(mc2,true,mc1,true,true);
					else
					{
						mc2.hit(mc1,"neutral");
						mc1.hit(mc2,"neutral");
					}
				}
			}
		}
		// ANIM_OBJ_HIT_TEST
		private function animObjHitTest(mc1:AnimatedObject,mc2:AnimatedObject):void
		{
			attackedEnemy = false;
			if (mc1.hTop <= mc2.hBot && mc1.hBot >= mc2.hTop && mc1.hLft <= mc2.hRht && mc1.hRht >= mc2.hLft) // penetrating ground
			{
				if (mc1 is Character && mc2 is Enemy && Enemy(mc2).stunned)
					checkLastHitPoints(mc1,true,mc2,false);
				else
					checkLastHitPoints(mc1,true,mc2,true);
			}
			if (mc1 is Character && Character(mc1).checkAtkRect && mc2 is IAttackable && Character(mc1).ahTop <= mc2.hBot && Character(mc1).ahBot >= mc2.hTop && Character(mc1).ahLft <= mc2.hRht && Character(mc1).ahRht >= mc2.hLft)
			{
				(mc1 as Character).landAttack(mc2 as IAttackable);
				attackedEnemy = true;
			}
		}
		private function checkNextTile(koopa:KoopaGreen,ground:Ground):void
		{
			if (!ground.visible)
				return;
			if (koopa.hBot >= ground.hTop && koopa.hBot <= ground.hBot)
			{
				var ofs:int = 2;
				if (koopa.vx > 0 && koopa.nx + ofs >= ground.hLft && koopa.nx + ofs <= ground.hRht)
				{
					koopa.groundInFront = true;
				}
				else if (koopa.vx < 0 && koopa.nx - ofs >= ground.hLft && koopa.nx - ofs <= ground.hRht)
				{
					koopa.groundInFront = true;
				}
			}
		}
		private function groundHitTest(mc1:AnimatedObject,ground:Ground):void
		{
			if (mc1 is Character)
			{
				var char:Character = mc1 as Character;
				if (char.checkAtkRect && ground is Brick && !ground.disabled && char.ahTop <= ground.hBot && char.ahBot >= ground.hTop && char.ahLft <= ground.hRht && char.ahRht >= ground.hLft)
				{
					char.landAttack(ground as IAttackable);
				}
			}
			if (mc1.hTop <= ground.hBot && mc1.hBot >= ground.hTop && mc1.hLft <= ground.hRht && mc1.hRht >= ground.hLft) // penetrating ground
			{
				if (!(mc1 is Projectile) || (mc1 as Projectile).needsAccurateGroundHits )
				{
					if (!(ground is Platform))
					{
						checkLastHitPoints(mc1,true,ground,false);
					}
					else
					{
						if (mc1 is Sophia)
						{
							var sophia:Sophia = mc1 as Sophia;
							var plat:Platform = ground as Platform;
						}
						checkLastHitPoints(mc1,true,ground,true);
					}
				}
				else
				{
					mc1.hit(ground,"neutral");
					ground.hit(mc1,"neutral");
				}

			}
			if (mc1 is KoopaGreen && KoopaGreen(mc1).red && mc1.cState == "walk" && mc1.vy == 0)
				checkNextTile(mc1 as KoopaGreen,ground);
		}
		private function checkLastHitPoints(mc1:LevObj,mc1Last:Boolean,mc2:LevObj,mc2Last:Boolean,mc1HRect2:Boolean = false):void
		{
			var mc1Top:Number;
			var mc1Bot:Number;
			var mc1Lft:Number;
			var mc1Rht:Number;
			var mc2Top:Number;
			var mc2Bot:Number;
			var mc2Lft:Number;
			var mc2Rht:Number;
			var dy:Number;
			if (mc1HRect2)
			{
				var ao:AnimatedObject = mc1 as AnimatedObject;
				mc1Top = ao.hRect2.lhTop;
				mc1Bot = ao.hRect2.lhBot;
				mc1Lft = ao.hRect2.lhLft;
				mc1Rht = ao.hRect2.lhRht;
			}
			else if (mc1Last) // check last hitPoints
			{
				mc1Top = mc1.lhTop;
				mc1Bot = mc1.lhBot;
				mc1Lft = mc1.lhLft;
				mc1Rht = mc1.lhRht;
			}
			else
			{
				mc1Top = mc1.hTop;
				mc1Bot = mc1.hBot;
				mc1Lft = mc1.hLft;
				mc1Rht = mc1.hRht;
			}
			if (mc2Last) // check last hitPoints
			{
				mc2Top = mc2.lhTop;
				mc2Bot = mc2.lhBot;
				mc2Lft = mc2.lhLft;
				mc2Rht = mc2.lhRht;
			}
			else
			{
				mc2Top = mc2.hTop;
				mc2Bot = mc2.hBot;
				mc2Lft = mc2.hLft;
				mc2Rht = mc2.hRht;
			}
			if (mc1Bot <= mc2Top) // was above ground
			{
				if (mc1Rht <= mc2Lft) // was above and to left of ground
				{
					if (mc1 is Character)
					{
						if (mc2 is Ground)
						{
							if (!Character(mc1).fallBtwn)
								calcAxis(mc1,mc2,true,true);
							else
							{
								mc1.hit(mc2,"right");
								mc2.hit(mc1,"left");
							}
						}
						else if (mc2 is Enemy)
						{
							mc1.hit(mc2,"bottom");
							mc2.hit(mc1,"top");
						}
						else
							calcAxis(mc1,mc2,true,true);
					}
					else if (mc1 is AnimatedObject
					&& !(mc1 is Projectile)
					&& ( !(mc1 is KoopaGreen) || (mc1 is KoopaGreen && KoopaGreen(mc1).cState != KoopaGreen(mc1).ST_FLY) )
					&& mc2 is Ground
					&& !(AnimatedObject(mc1).onGround || AnimatedObject(mc1).lastOnGround) )
					{
						// this is a very stupid way to make sure the mushroom doesn't go through the block on 1-2b
						if (mc1 is Mushroom && mc2.x == 544 && GameSettings.mapPack == MapPack.Smb && StatManager.STAT_MNGR.currentLevelID.fullName == "1-2b")
						{
							mc1.hit(mc2,"right");
							mc2.hit(mc1,"left");
						}
					}
					else
						calcAxis(mc1,mc2,true,true);
					cHit = true;
				}
				else if (mc1Lft >= mc2Rht) // was above and to right of ground
				{
					if (mc1 is Character)
					{
						if (mc2 is Ground)
						{
							if (!Character(mc1).fallBtwn)
								calcAxis(mc1,mc2,true,false);
							else
							{
								mc1.hit(mc2,"left");
								mc2.hit(mc1,"right");
							}
						}
						else if (mc2 is Enemy)
						{
							mc1.hit(mc2,"bottom");
							mc2.hit(mc1,"top");
						}
						else
							calcAxis(mc1,mc2,true,false);
					}
					else if (mc1 is AnimatedObject
					&& !(mc1 is Projectile)
					&& ( !(mc1 is KoopaGreen) || (mc1 is KoopaGreen && KoopaGreen(mc1).cState != KoopaGreen(mc1).ST_FLY) )
					&& mc2 is Ground
					&& !(AnimatedObject(mc1).onGround || AnimatedObject(mc1).lastOnGround)
					)
					{
						//mc1.hit(mc2,"left");
						//mc2.hit(mc1,"right");
					}
					else
						calcAxis(mc1,mc2,true,false);
					cHit = true;
				}
				else // above ground only
				{
					mc1.hit(mc2,"bottom");
					mc2.hit(mc1,"top");
					cHit = true;
				}
			}
			// this is really weird. I don't know what this is. (I think it stops the crouch move bug)
			else if (mc1Top >= mc2Bot &&
			(
			!(mc1 is Character)
			|| (mc1 is Character && !(mc2 is Ground))
			|| mc1 is MarioBase
			|| (mc1 is Character && mc2 is Ground && (mc1 as Character).lState != Character.ST_CROUCH && (mc1 as Character).lState != Samus.ST_BALL && (mc1 as Character).lState != MegaManBase.ST_SLIDE)
			)) // was below ground
			{
				if (mc1 is Character && mc2 is Ground) // this was added for corner rounding
				{
					if (mc1Rht <= mc2Lft) // was below and to left of ground or was below and to right of ground
					{
						if (level.getGroundAt(mc2.x - GlobVars.TILE_SIZE,mc2.y) == null) // if nothing on the left, do corner rounding
						{
							mc1.hit(mc2,"right");
							mc2.hit(mc1,"left");
						}
						else
							calcAxis(mc1,mc2,false,true);
						cHit = true;
					}
					else if (mc1Lft >= mc2Rht) // was below and to right of ground
					{
						if (level.getGroundAt(mc2.x + GlobVars.TILE_SIZE,mc2.y) == null) // if nothing on the right, do corner rounding
						{
							mc1.hit(mc2,"left");
							mc2.hit(mc1,"right");
						}
						else
							calcAxis(mc1,mc2,false,false);
						cHit = true;
					}
					else // below ground only
					{
						var player:Character = mc1 as Character;
						if ( (mc1.hRht - mc2.hLft) < CORNER_ROUNDING_AMOUNT && level.getGroundAt(mc2.x - GlobVars.TILE_SIZE,mc2.y) == null && ( !(player is Sophia) || level.getGroundAt(mc2.x - GlobVars.TILE_SIZE*2, mc2.y) == null ) ) // left side corner rounding
						{
							mc1.hit(mc2,"right");
							mc2.hit(mc2,"left");
						}
						else if ( (mc2.hRht - mc1.hLft) < CORNER_ROUNDING_AMOUNT && level.getGroundAt(mc2.x + GlobVars.TILE_SIZE,mc2.y) == null && ( !(player is Sophia) || level.getGroundAt(mc2.x + GlobVars.TILE_SIZE*2, mc2.y) == null ) )
						{
							mc1.hit(mc2,"left");
							mc2.hit(mc2,"right");
						}
						else
						{
							mc1.hit(mc2,"top");
							mc2.hit(mc1,"bottom");
						}
						cHit = true;
					}
				}
				else
				{
					if (mc1Rht <= mc2Lft) // was below and to left of ground
					{
						calcAxis(mc1,mc2,false,true);
						cHit = true;
					}
					else if (mc1Lft >= mc2Rht) // was below and to right of ground
					{
						calcAxis(mc1,mc2,false,false);
						cHit = true;
					}
					else // below ground only
					{
						mc1.hit(mc2,"top");
						mc2.hit(mc1,"bottom");
						cHit = true;
					}
				}
			}
			else if (mc1Rht <= mc2Lft) // mc1 was left of mc2 only
			{
				if (mc1 is Character && mc2 is Enemy)
				{
					dy = (mc1 as Character).hBot - (mc2 as Enemy).hTop;
					if (!(mc1 as Character).onGround && dy >= 0 && dy <= STOMP_PADDING)
					{
						mc1.hit(mc2,"bottom");
						mc2.hit(mc1,"top");
					}
				}
				else
				{
					mc1.hit(mc2,"right");
					mc2.hit(mc1,"left");
				}
				cHit = true;
			}
			else if (mc1Lft >= mc2Rht) // mc1 was right of mc2 only
			{
				if (mc1 is Character && mc2 is Enemy)
				{
					dy = (mc1 as Character).hBot - (mc2 as Enemy).hTop;
					if (!(mc1 as Character).onGround && dy >= 0 && dy <= STOMP_PADDING)
					{
						mc1.hit(mc2,"bottom");
						mc2.hit(mc1,"top");
					}
				}
				else
				{
					mc1.hit(mc2,"left");
					mc2.hit(mc1,"right");
				}
				cHit = true;
			}
			else if (mc2 is Ground && mc2.visible) // mc1 is inside mc2 and was inside it last time
			{
				mc1.stuckInWall = true;
//				trace("stuck in wall");
				if (mc1 is Character)
				{
					// did this to prevent weird crap happening when platform goes offscreen with character on it
					if (mc2 is Platform && (mc1 as Character).hTop <= 0)
					{
						mc1.stuckInWall = false;
						mc1.hit(mc2,"bottom");
						mc2.hit(mc1,"top");
					}
				}
				else if (mc1 is Enemy || (mc1 is Pickup && (mc1 is Mushroom || mc1 is Star) ) )
				{
					if (mc1.hRht >= mc2.hLft && mc1.hLft <= mc2.hLft)
					{
						mc1.yPenAmt = mc1.hRht - mc2.hLft;
						mc1.shiftHit(mc2,"right",mc1.yPenAmt);
					}
					else if (mc1.hLft <= mc2.hRht && mc1.hRht >= mc2.hRht)
					{
						mc1.yPenAmt = mc2.hRht - mc1.hLft;
						mc1.shiftHit(mc2,"left",mc1.yPenAmt);
					}
				}
				else if (mc1 is Projectile)
				{
					mc1.hit(mc2,"neutral");
					mc2.hit(mc1,"neutral");
				}
			}
			/*else if (mc1 is Projectile || mc2 is Projectile)
			{
				mc1.hit(mc2,"neutral");
				mc2.hit(mc1,"neutral");
			}*/
			else if (mc1 is Enemy && mc2 is Enemy)
			{
				if (mc1.hRht >= mc2.hLft && mc1.hLft <= mc2.hLft)
				{
					mc1.yPenAmt = mc1.hRht - mc2.hLft;
					mc2.yPenAmt = mc1.yPenAmt;
					mc1.shiftHit(mc2,"right",mc1.yPenAmt);
					mc2.shiftHit(mc1,"left",mc2.yPenAmt);
				}
				else if (mc1.hLft <= mc2.hRht && mc1.hRht >= mc2.hRht)
				{
					mc1.yPenAmt = mc2.hRht - mc1.hLft;
					mc2.yPenAmt = mc1.yPenAmt;
					mc1.shiftHit(mc2,"left",mc1.yPenAmt);
					mc2.shiftHit(mc1,"right",mc2.yPenAmt);
				}
			}
			/*else if (mc1 is Character && !(mc2 is Ground))
			{
				mc1.hit(mc2,"neutral");
				mc2.hit(mc1,"neutral");
			}*/
			if ( !(mc1 is MarioFireBall && mc2 is Ground) )
			{
				if (!mc1.hitDct[mc2])
					mc1.hit(mc2,"neutral");
				if (!mc2.hitDct[mc1])
					mc2.hit(mc1,"neutral");
			}
		}
		private function calcAxis(mc1:LevObj,mc2:LevObj,top:Boolean,left:Boolean):void
		{
			var xSide:String;
			var xSideOpp:String;
			var ySide:String;
			var ySideOpp:String;
			if (top)
			{
				xSide = "bottom";
				xSideOpp = "top";
				mc2.xPenAmt = mc1.hBot - mc2.hTop;
			}
			else
			{
				xSide = "top";
				xSideOpp = "bottom";
				mc2.xPenAmt = mc2.hBot - mc1.hTop;
			}
			if (left)
			{
				ySide = "right";
				ySideOpp = "left";
				mc2.yPenAmt = mc1.hRht - mc2.hLft;
			}
			else
			{
				ySide = "left";
				ySideOpp = "right";
				mc2.yPenAmt = mc2.hRht - mc1.hLft;
			}
			if (mc2 is Ground)
			{
				if (mc1.vx == 0 && mc1.vy == 0)
					{ /*do nothing*/ }
				else if (mc1.vx == 0)
				{
					mc1.hit(mc2,ySide);
					mc2.hit(mc1,ySideOpp);
				}
				else if (mc1 is MarioFireBall && mc1.vy <= 0)
					mc1.hit(mc2,xSide);
				else if (mc1.vy == 0)
				{
					mc1.hit(mc2,xSide);
					mc2.hit(mc1,xSideOpp);
				}
				else if (level.gHitArr.indexOf(mc2) == -1)
				{
					level.gHitArr.push(mc2);
				}
				else
				{
					//level.gHitArr.push(mc2);
					//trace("fuck"+" mc2.xPenAmt: "+mc2.xPenAmt+" mc2.yPenAmt: "+mc2.yPenAmt);
					if (mc2.xPenAmt <= mc2.yPenAmt)
					{
						mc1.hit(mc2,xSide);
						mc2.hit(mc1,xSideOpp);
					} // if penetrating top of ground less
					else
					{
						mc1.hit(mc2,ySide);
						mc2.hit(mc1,ySideOpp);
					}
				}
			}
			else // if mc2 is not ground
			{
				if (mc2.xPenAmt <= mc2.yPenAmt) // if mc1 is penetrating top of mc2 less
				{
					mc1.hit(mc2,xSide);
					mc2.hit(mc1,xSideOpp);
				}
				else
				{
					mc1.hit(mc2,ySide);
					mc2.hit(mc1,ySideOpp);
				}
			}
		}
		private function getDistance(x1:Number,y1:Number,x2:Number,y2:Number):Number
		{
			var dx:Number = x1 - x2;
			var dy:Number = y1 - y2;
			return Math.sqrt(dx * dx + dy * dy);
		}

		// Public Methods:
		// Protected Methods:
	}

}
