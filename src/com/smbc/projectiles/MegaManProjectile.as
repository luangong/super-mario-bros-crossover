package com.smbc.projectiles
{

	import com.customClasses.*;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatFxFreeze;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatFxTransparent;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatusProperty;
	import com.explodingRabbit.cross.games.Game;
	import com.explodingRabbit.utils.CustomDictionary;
	import com.explodingRabbit.utils.CustomTimer;
	import com.explodingRabbit.utils.Enum;
	import com.smbc.characters.Bass;
	import com.smbc.characters.MegaMan;
	import com.smbc.characters.base.MegaManBase;
	import com.smbc.data.AnimationTimers;
	import com.smbc.data.CharacterInfo;
	import com.smbc.data.DamageValue;
	import com.smbc.data.PickupInfo;
	import com.smbc.data.SoundNames;
	import com.smbc.enemies.Enemy;
	import com.smbc.events.CustomEvents;
	import com.smbc.graphics.MegaManSimpleGraphics;
	import com.smbc.ground.Brick;
	import com.smbc.ground.Ground;
	import com.smbc.interfaces.IAttackable;
	import com.smbc.level.Level;
	import com.smbc.level.LevelData;
	import com.smbc.main.LevObj;
	import com.smbc.utils.GameLoopTimer;

	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;

	public class MegaManProjectile extends Projectile
	{
		private static const FL_BASS_BUSTER:String = "bassBuster";
		private static const FL_FLAME_BLAST_BULLET:String = "flameBlastBullet";
		private static const FL_FLAME_BLAST_FLAME_END:String = "flameBlastFlameEnd";
		private static const FL_FLAME_BLAST_FLAME_START:String = "flameBlastFlameStart";
		private static const FL_HARD_KNUCKLE_START:String = "hardKnuckleStart";
		private static const FL_HARD_KNUCKLE_END:String = "hardKnuckleEnd";
		private static const FL_HARD_KNUCKLE_APPEAR_START:String = "hardKnuckleAppearStart";
		private static const FL_HARD_KNUCKLE_APPEAR_END:String = "hardKnuckleAppearEnd";
		private static const FL_MAGMA_BAZOOKA_START:String = "magmaBazookaStart";
		private static const FL_MAGMA_BAZOOKA_END:String = "magmaBazookaEnd";
		private static const FL_MAGMA_BAZOOKA_CHARGE_START:String = "magmaBazookaChargeStart";
		private static const FL_MAGMA_BAZOOKA_CHARGE_END:String = "magmaBazookaChargeEnd";
		private static const FL_MEGA_BUSTER_END:String = "megaBusterEnd";
		private static const FL_MEGA_BUSTER_START:String = "megaBusterStart";
		private static const FL_METAL_BLADE_END:String = "metalBladeEnd";
		private static const FL_METAL_BLADE_START:String = "metalBladeStart";
//		private static const FL_MEGA_BUSTER:String = "megaBuster";
		private static const FL_PHARAOH_BALLOON_START:String = "pharaohBalloonStart";
		private static const FL_PHARAOH_BALLOON_END:String = "pharaohBalloonEnd";
		private static const FL_PHARAOH_BIG_END:String = "pharaohBigEnd";
		private static const FL_PHARAOH_BIG_START:String = "pharaohBigStart";
		private static const FL_PHARAOH_CHARGE_LEVEL_2:String = "pharaohChargeLevel2";
		private static const FL_PHARAOH_MEDIUM:String = "pharaohMedium";
		private static const FL_PHARAOH_SMALL:String = "pharaohSmall";
		private static const FL_SCREW_CRUSHER_END:String = "screwCrusherEnd";
		private static const FL_SCREW_CRUSHER_START:String = "screwCrusherStart";
		private static const FL_STRONG_CHARGE_END:String = "strongChargeEnd";
		private static const FL_STRONG_CHARGE_START:String = "strongChargeStart";
		private static const FL_WATER_SHIELD:String = "waterShield";
		private static const FL_WATER_SHIELD_EXPLOSION:String = "waterShieldExplosion";
		private static const FL_WEAK_CHARGE_END:String = "weakChargeEnd";
		private static const FL_WEAK_CHARGE_START:String = "weakChargeStart";
		public static const TYPE_BASS_BUSTER:String = "bassBuster";
		public static const TYPE_CHARGE_STRONG:String = "chargeStrong";
		public static const TYPE_CHARGE_WEAK:String = "chargeWeak";
		public static const TYPE_FLAME_BLAST:String = "flameBlast";
		public static const TYPE_HARD_KNUCKLE:String = "hardKnuckle";
		public static const TYPE_MAGMA_BAZOOKA:String = "magmaBazooka";
		public static const TYPE_MAGMA_BAZOOKA_CHARGE:String = "magmaBazookaCharge";
		public static const TYPE_MEGA_BUSTER:String = "megaBuster";
		public static const TYPE_METAL_BLADE:String = "metalBlade";
		public static const TYPE_PHARAOH_SHOT:String = "pharaohShot";
		public static const TYPE_PHARAOH_BALLOON:String = "pharaohBalloon";
		public static const TYPE_SCREW_CRUSHER:String = "screwCrusher";
		public static const TYPE_SUPER_ARM:String = PickupInfo.MEGA_MAN_SUPER_ARM;
		public static const TYPE_WATER_SHIELD:String = "waterShield";
		public static const MB_UP:String = "up";  // types of magma bazooka projectiles
		public static const MB_MID:String = "mid";
		public static const MB_DOWN:String = "down";
		public static const FL_SUPER_ARM:String = "superArm";
		private static const X_OFS:int = 38;
		public static const Y_PAD_BOT_ON_GROUND:int = 26;
		public static const Y_PAD_BOT_OFF_GROUND:int = 34;
		public static const Y_PAD_BOT_ON_GROUND_PROTO:int = 19;
		public static const Y_PAD_BOT_OFF_GROUND_PROTO:int = 31;
		public static const Y_PAD_BOT_ON_GROUND_ROKKO:int = 22;
		public static const Y_PAD_BOT_OFF_GROUND_ROKKO:int = 32;
		private static const ANIM_FAST_TMR:CustomTimer = AnimationTimers.ANIM_FAST_TMR;
		public var type:String;
		private var subType:String;
		private var superArmBrick:Brick;
		private var megaMan:MegaManBase;
		private static const SPEED:int = 450;
		private static const BASS_BUSTER_SPEED:int = 580;
		private static const VY_DEFLECT:int = 350;
		private static const FLAME_BLAST_SPEED:int = 450;
		private static const FLAME_BLAST_GRAVITY:int = 1300;
		private static const METAL_BLADE_SPEED:int = 450;
		private static const HARD_KNUCKLE_AX:int = 450;
		private static const HARD_KNUCKLE_VX_MAX:int = 350;
		private static const HARD_KNUCKLE_VY:int = 50;
		private static const MAGMA_BAZOOKA_SPEED:int = 450;
		private static const SCREW_CRUSHER_SPEED:int = 450;
		private static const WATER_SHIELD_RADIUS_DEF:int = 45;
		private static const WATER_SHIELD_EXPAND_SPEED:int = 5;
		private static const WATER_SHIELD_ROTATE_SPEED:Number = 4;
		public static const WATER_SHIELD_NUM:int = 8;
		public static const WATER_SHIELD_TMR_INT:int = WATER_SHIELD_ROTATE_SPEED*48;
		private static const WATER_SHIELD_SPACE_BTW:Number = 2;
		private static const ANGLE_FULL_CIRCLE:Number = Math.PI*2;
		private var waterShieldAngle:Number = 0;
		private var waterShieldRadius:Number = WATER_SHIELD_RADIUS_DEF;
		private var waterShieldExpandPnt:Point;
		private var waterShieldDir:int;
		public var pharaohChargeLevel:int;
		private var pharaohBalloonDelTmr:GameLoopTimer;
		private static const PHARAOH_BALLOON_APPEAR_DEL:int = 250;
		public static const PHARAOH_CHARGE_LOW:int = 0;
		public static const PHARAOH_CHARGE_MED:int = 1;
		public static const PHARAOH_CHARGE_FULL:int = 2;
		private static const PHARAOH_BALLOON_Y_OFS:int = 30;
		private static const PHARAOH_BALLOON_SPEED:int = 75;
		private static const PHARAOH_BALLOON_MAX_X_OFS:int = 20;
		private static const PHARAOH_ANIM_TMR_DEL:int = AnimationTimers.DEL_SLOW;

		// Public Properties:

		// Private Properties:
		// Initialization:
		public function MegaManProjectile(megaMan:MegaManBase,type:String,other:Object = null)
		{
			this.megaMan = megaMan;
			this.type = type;
			if (type == TYPE_SUPER_ARM)
				superArmBrick = other as Brick;
			else if (type == TYPE_MAGMA_BAZOOKA)
				subType = other as String;
			else if (type == TYPE_MAGMA_BAZOOKA_CHARGE)
				subType = other as String;
			else if (type == TYPE_WATER_SHIELD)
				waterShieldAngle = other as Number;
			else if (type == TYPE_PHARAOH_SHOT)
				pharaohChargeLevel = other as int;
			inheritedForceShortClassName = CharacterInfo.CHAR_ARR[megaMan.charNum][CharacterInfo.IND_CHAR_NAME_CLASS]+"Projectile";
			super(megaMan,SOURCE_TYPE_PLAYER);
			for each (var prop:StatusProperty in MegaManBase.DEFAULT_PROPS_DCT)
			{
				addProperty(prop);
			}
			determineShotType();
		}

		public function get isPharoahShot():Boolean
		{
			return type == TYPE_PHARAOH_BALLOON || type == TYPE_PHARAOH_SHOT;
		}

		public function get isDefaultWeapon():Boolean
		{
			return type == TYPE_BASS_BUSTER || type == TYPE_MEGA_BUSTER || type == TYPE_CHARGE_WEAK || type == TYPE_CHARGE_STRONG;
		}

		private function determineShotType():void
		{
			switch (type)
			{
				case TYPE_MEGA_BUSTER :
					megaBusterShot();
					break;
				case TYPE_BASS_BUSTER :
					bassBuster();
					break;
				case TYPE_CHARGE_WEAK :
					weakChargeShot();
					break;
				case TYPE_CHARGE_STRONG :
					strongChargeShot();
					break;
				case TYPE_SUPER_ARM:
				{
					gotoAndStop(FL_SUPER_ARM);
					stopAnim = true;
					visible = false;
					vx = 280*megaMan.scaleX;
					vy = -320;
					gravity = 1600;
					x = superArmBrick.x + TILE_SIZE/2;
					y = superArmBrick.y + TILE_SIZE/2;
					defyGrav = false;
					addAllGroundToHitTestables();
					_damageAmt = DamageValue.MEGA_MAN_SUPER_ARM;
					addProperty( new StatusProperty(PR_PIERCE_AGG) );
					break;
				}
				case TYPE_METAL_BLADE:
				{
					gotoAndStop(FL_METAL_BLADE_START);
					metalBladeSetDir();
					defyGrav = true;
					stopAnim = false;
					addProperty( new StatusProperty( PR_PASSTHROUGH_DEFEAT) );
					mainAnimTmr = AnimationTimers.ANIM_MODERATE_TMR;
					_damageAmt = DamageValue.MEGA_MAN_METAL_BLADE;
					SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_METAL_BLADE);
					break;
				}
				case TYPE_HARD_KNUCKLE:
				{
					hardKnuckle();
					break;
				}
				case TYPE_PHARAOH_BALLOON:
				{
					pharaohBalloon();
					break;
				}
				case TYPE_PHARAOH_SHOT:
				{
					pharaohShot();
					break;
				}
				case TYPE_FLAME_BLAST:
				{
					flameBlast();
					break;
				}
				case TYPE_MAGMA_BAZOOKA:
				{
					magmaBazooka();
					break;
				}
				case TYPE_MAGMA_BAZOOKA_CHARGE:
				{
					magmaBazookaCharge();
					break;
				}
				case TYPE_WATER_SHIELD:
				{
					waterShield();
					break;
				}
				case TYPE_SCREW_CRUSHER:
				{
					gotoAndStop(FL_SCREW_CRUSHER_START);
					screwCrusher();
					gravity = 1500;
					defyGrav = false;
					stopAnim = false;
					mainAnimTmr = AnimationTimers.ANIM_MODERATE_TMR;
					_damageAmt = DamageValue.MEGA_MAN_SCREW_CRUSHER;
					SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_SCREW_CRUSHER);
					break;
				}

				/*case 4 :
					fireShot();
					break;
				case 5 :
					weakChargeFireShot();
					break;
				case 6 :
					strongChargeFireShot();
					break;*/
				default :
					break;
			}
		}

		private function hardKnuckle():void
		{
			setDir();
			vx = 0;
			defyGrav = true;
			stopAnim = false;
			vxMax = HARD_KNUCKLE_VX_MAX;
			addProperty( new StatusProperty(PR_PIERCE_AGG, 10) );
			EVENT_MNGR.addEventListener(CustomEvents.LEVEL_SET_INDEXES,levelSetIndexesHandler,false,0,true);
			stopHit = true;
			accurateAnimTmr = new GameLoopTimer(MegaManSimpleGraphics.EXPLOSION_ANIM_TMR_DEL);
			gotoAndStop(FL_HARD_KNUCKLE_APPEAR_START);
			_damageAmt = DamageValue.MEGA_MAN_HARD_KNUCKLE;
			SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_SHOOT);
		}

		protected function levelSetIndexesHandler(event:Event):void
		{
			if (type == TYPE_HARD_KNUCKLE && parent)
				parent.setChildIndex(this,parent.numChildren - 1);
		}

		private function metalBladeSetDir():void
		{
			x = megaMan.hMidX;
			y = megaMan.hMidY;
			var upBtn:Boolean = megaMan.upBtn;
			var lftBtn:Boolean = megaMan.lftBtn;
			var rhtBtn:Boolean = megaMan.rhtBtn;
			var dwnBtn:Boolean = megaMan.dwnBtn
			var speed:int = METAL_BLADE_SPEED;

			if (upBtn)
				vy = -speed;
			else if (dwnBtn)
				vy = speed;
			if ( (rhtBtn || lftBtn) || (!upBtn && !dwnBtn) )
				vx = speed*megaMan.scaleX;
			if (vx != 0 && vy != 0)
			{
				vx *= .75;
				vy *= .75;
			}
		}
		private function screwCrusher():void
		{
			x = megaMan.hMidX + (48 * megaMan.scaleX);
			y = megaMan.hMidY;
			var speed:int = SCREW_CRUSHER_SPEED;

			vx = speed * megaMan.scaleX * (1/3);
			vy = -speed * 1.25;
		}
		private function bassBusterSetDir():void
		{
			var upBtn:Boolean = megaMan.upBtn;
			var lftBtn:Boolean = megaMan.lftBtn;
			var rhtBtn:Boolean = megaMan.rhtBtn;
			var dwnBtn:Boolean = megaMan.dwnBtn
			var speed:int = xSpeed;
			if (upBtn && !(rhtBtn || lftBtn) )
			{
				vy = -speed;
				x -= 28*scaleX;
				y -= 20;
				if (scaleX > 0)
					rotation = 270;
				else
					rotation = 90;
			}
			else if (upBtn && (rhtBtn || lftBtn) )
			{
				vx = speed*megaMan.scaleX;
				vy = -speed;
				x -= 6*scaleX;
				y -= 14;
				if (scaleX > 0)
					rotation = 315;
				else
					rotation = 45;
			}
			else if (dwnBtn)
			{
				vx = speed*megaMan.scaleX;
				vy = speed;
				y += 14;
				x -= 6*scaleX;
				if (scaleX > 0)
					rotation = 45;
				else
					rotation = 315;
			}
			else
				vx = speed*megaMan.scaleX;
			if (vx != 0 && vy != 0)
			{
				vx *= .75;
				vy *= .75;
			}
			if (!megaMan.rotateBassBuster)
				rotation = 0;
		}
		private function flameBlastExplode(ground:Ground,side:String):void
		{
			L_HIT_DCT.clear();
			C_HIT_DCT.clear();
			needsAccurateGroundHits = false;
			vx = 0;
			vy = 0;
			gotoAndStop(FL_FLAME_BLAST_FLAME_START);
			stopAnim = false;
			defyGrav = true;
			removeHitTestableItem(HT_GROUND_NON_BRICK);
			removeHitTestableItem(HT_PLATFORM);
			_damageAmt = DamageValue.MEGA_MAN_FLAME_BLAST_FLAME;
			if (side == Ground.HT_BOTTOM)
				ny = ground.hTop;
			else if (side == Ground.HT_TOP)
			{
				ny = ground.hBot;
				rotation = 180;
			}
			else if (side == Ground.HT_LEFT)
			{
				nx = ground.hRht;
				rotation = 90;
			}
			else if (side == Ground.HT_RIGHT)
			{
				nx = ground.hLft;
				rotation = 270;
			}
		}

		private function bassBuster():void
		{
			stopAnim = true;
			gotoAndStop(FL_BASS_BUSTER);
			SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_SHOOT);
			_damageAmt = DamageValue.MEGA_MAN_BASS_BUSTER;
			defyGrav = true;
			xSpeed = BASS_BUSTER_SPEED;
			setDir();
			vx = 0;
			bassBusterSetDir();
			addAllGroundToHitTestables();
			mainAnimTmr = null;
		}
		private function megaBusterShot():void
		{
//			var shiftBullet:Boolean = megaMan.shiftBullet;

			// Set passthrough property
			if ( megaMan.skinNum == MegaMan.SKIN_CUT_MAN_NES || megaMan.skinNum == MegaMan.SKIN_CUT_MAN_SNES )
				addProperty( new StatusProperty( PR_PASSTHROUGH_ALWAYS) );

			// Set damage value
			if ( megaMan.skinNum == MegaMan.SKIN_CUT_MAN_NES || megaMan.skinNum == MegaMan.SKIN_CUT_MAN_SNES || megaMan.skinNum == MegaMan.SKIN_FIRE_MAN_NES )
				_damageAmt = DamageValue.MEGA_MAN_MEGA_BUSTER * 1.25;
			else if ( megaMan.skinNum == MegaMan.SKIN_ICE_MAN_NES )
				_damageAmt = DamageValue.MEGA_MAN_MEGA_BUSTER * 0.75;
			else
				_damageAmt = DamageValue.MEGA_MAN_MEGA_BUSTER;

//			if (shiftBullet)
//				vy = -20;
//			else
//				vy = 20;

			stopAnim = false;
			this.gotoAndStop(FL_MEGA_BUSTER_START);
			SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_SHOOT);
			defyGrav = true;
			xSpeed = SPEED;
			setDir();
		}
		private function weakChargeShot():void
		{
			stopAnim = false;

			// Set passthrough property
			if ( megaMan.skinNum == MegaMan.SKIN_CUT_MAN_NES || megaMan.skinNum == MegaMan.SKIN_CUT_MAN_SNES )
				addProperty( new StatusProperty( PR_PASSTHROUGH_ALWAYS) );

			// Set damage value
			if ( megaMan.skinNum == MegaMan.SKIN_CUT_MAN_NES || megaMan.skinNum == MegaMan.SKIN_CUT_MAN_SNES )
				_damageAmt = DamageValue.MEGA_MAN_WEAK_CHARGE_NORMAL * 1.25;
			else
				_damageAmt = DamageValue.MEGA_MAN_WEAK_CHARGE_NORMAL;

			this.gotoAndStop(FL_WEAK_CHARGE_START);
			SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_CHARGE_SHOT_WEAK);
			defyGrav = true;
			xSpeed = SPEED;
			setDir();
		}
		private function strongChargeShot():void
		{
			stopAnim = false;

			// Set passthrough property
			if ( megaMan.skinNum == MegaMan.SKIN_CUT_MAN_NES || megaMan.skinNum == MegaMan.SKIN_CUT_MAN_SNES )
				addProperty( new StatusProperty( PR_PASSTHROUGH_ALWAYS) );
			else
				addProperty( new StatusProperty( PR_PASSTHROUGH_DEFEAT) );

			// Set freeze property
			if ( megaMan.skinNum == MegaMan.SKIN_ICE_MAN_NES )
				addProperty( new StatusProperty(StatusProperty.TYPE_FREEZE_AGG,0,new StatFxFreeze(null,MegaMan.FREEZE_DUR) ) );

			// Set SFX
			if ( megaMan.skinNum == MegaMan.SKIN_ICE_MAN_NES )
				SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_ICE_SLASHER);
			else
				SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_CHARGE_SHOT);
			this.gotoAndStop(FL_STRONG_CHARGE_START);
			_damageAmt = DamageValue.MEGA_MAN_FULL_CHARGE_NORMAL;
			defyGrav = true;
			xSpeed = SPEED;
			setDir();
			mainAnimTmr = ANIM_FAST_TMR;
			megaMan.chargeShot = this;
		}
		/*private function fireShot():void
		{
			stopAnim = false;
			this.gotoAndStop("fireStart");
			_damageAmt = DamageValue.MEGA_MAN_SHOT_FIRE;
			mainAnimTmr = ANIM_FAST_TMR;
			defyGrav = true;
			xSpeed = SPEED;
			setDir();
			SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_FIRE);
		}*/
		private function pharaohBalloon():void
		{
			megaMan.pharaohBalloon = this;
			destroyOffScreen = false;
			pharaohChargeLevel = PHARAOH_CHARGE_LOW;
			addProperty( new StatusProperty( PR_PASSTHROUGH_DEFEAT) );
			_damageAmt = DamageValue.MEGA_MAN_PHARAOH_SHOT_BIG;
			x = megaMan.nx;
			y = megaMan.ny - megaMan.height - PHARAOH_BALLOON_Y_OFS;
			defyGrav = true;
			visible = false;
			stopHit = true;
			accurateAnimTmr = new GameLoopTimer(PHARAOH_ANIM_TMR_DEL);
			stopAnim = true;
			pharaohBalloonDelTmr = new GameLoopTimer(PHARAOH_BALLOON_APPEAR_DEL,1);
			pharaohBalloonDelTmr.addEventListener(TimerEvent.TIMER_COMPLETE,pharaohBallonDelTmrHandler,false,0,true);
			pharaohBalloonDelTmr.start();
		}

		protected function pharaohBallonDelTmrHandler(event:Event):void
		{
			gotoAndStop(FL_PHARAOH_BALLOON_START);
			visible = true;
			stopHit = false;
			stopAnim = false;
			pharaohBalloonDelTmr.stop();
			pharaohBalloonDelTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,pharaohBallonDelTmrHandler);
			pharaohBalloonDelTmr = null;
		}
		private function pharaohBalloonUpdPos():void
		{
			if (stopHit)
				return;
			var megaManDir:int = 0;
			if (megaMan.vx > 0)
				megaManDir = 1;
			else if (megaMan.vx < 0)
				megaManDir = -1;
			var maxXLft:Number = megaMan.nx - PHARAOH_BALLOON_MAX_X_OFS;
			var maxXRht:Number = megaMan.nx + PHARAOH_BALLOON_MAX_X_OFS;
			vx = -megaManDir*PHARAOH_BALLOON_SPEED;
			if (megaManDir == 0)
			{
				if (megaMan.scaleX > 0)
				{
					if (nx < megaMan.nx)
						vx = PHARAOH_BALLOON_SPEED*2;
					else if (nx > megaMan.nx && vx < 0)
						nx = megaMan.nx;
				}
				else
				{
					if (nx > megaMan.nx)
						vx = -PHARAOH_BALLOON_SPEED*2;
					else if (nx < megaMan.nx && vx > 0)
						nx = megaMan.nx;
				}
			}
			if (nx < maxXLft)
				nx = maxXLft;
			else if (nx > maxXRht)
				nx = maxXRht;
			ny = megaMan.hTop - PHARAOH_BALLOON_Y_OFS;
		}
		private function pharaohShot():void
		{
			stopAnim = true;
			if (pharaohChargeLevel == PHARAOH_CHARGE_LOW)
			{
				gotoAndStop(FL_PHARAOH_SMALL);
				_damageAmt = DamageValue.MEGA_MAN_PHARAOH_SHOT_SMALL;
				SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_PHARAOH_SHOT_SMALL);
			}
			else if (pharaohChargeLevel == PHARAOH_CHARGE_MED)
			{
				gotoAndStop(FL_PHARAOH_MEDIUM);
				_damageAmt = DamageValue.MEGA_MAN_PHARAOH_SHOT_MEDIUM;
				SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_PHARAOH_SHOT_SMALL);
			}
			else
			{
				gotoAndStop(FL_PHARAOH_BIG_START);
				_damageAmt = DamageValue.MEGA_MAN_PHARAOH_SHOT_BIG;
				addProperty( new StatusProperty( PR_PASSTHROUGH_DEFEAT) );
				stopAnim = false;
				accurateAnimTmr = new GameLoopTimer(PHARAOH_ANIM_TMR_DEL);
				SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_PHARAOH_SHOT_BIG);
			}
			defyGrav = true;
			xSpeed = SPEED;
			setDir();
			if (megaMan.upBtn)
				vy = -xSpeed;
			else if (megaMan.dwnBtn)
				vy = xSpeed;
			if (vx != 0 && vy != 0)
			{
				vx *= .75;
				vy *= .75;
			}
		}
		private function flameBlast():void
		{
			gotoAndStop(FL_FLAME_BLAST_BULLET);
			stopAnim = true;
			_damageAmt = DamageValue.MEGA_MAN_FLAME_BLAST_BULLET;
			addAllGroundToHitTestables();
			setDir();
			vx = FLAME_BLAST_SPEED*scaleX;
			gravity = FLAME_BLAST_GRAVITY;
			needsAccurateGroundHits = true;
			accurateAnimTmr = new GameLoopTimer(AnimationTimers.DEL_MIN_FAST);
			SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_SHOOT);
		}
		private function magmaBazooka():void
		{
			setDir();
			magmaBazookaSetDir();
			defyGrav = true;
			SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_MAGMA_BAZOOKA);
			gotoAndStop(FL_MAGMA_BAZOOKA_START);
			_damageAmt = DamageValue.MEGA_MAN_MAGMA_BAZOOKA;
//			if (type == TYPE_MAGMA_BAZOOKA)
//			{
//				gotoAndStop(FL_MAGMA_BAZOOKA_START);
//				_damageAmt = DamageValue.MEGA_MAN_MAGMA_BAZOOKA;
//			}
//			else
//			{
//				gotoAndStop(FL_MAGMA_BAZOOKA_CHARGE_START);
//				addProperty( new StatusProperty(PR_PASSTHROUGH_DEFEAT) );
//				_damageAmt = DamageValue.MEGA_MAN_MAGMA_BAZOOKA_CHARGE;
//			}
		}
		private function magmaBazookaCharge():void
		{
			setDir();
			magmaBazookaSetDir();
			defyGrav = true;
			SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_MAGMA_BAZOOKA);
			gotoAndStop(FL_MAGMA_BAZOOKA_CHARGE_START);
			addProperty( new StatusProperty(PR_PASSTHROUGH_DEFEAT) );
			_damageAmt = DamageValue.MEGA_MAN_MAGMA_BAZOOKA_CHARGE;
		}
		public static function createWaterShield(megaMan:MegaManBase):void
		{
			var nums:Number = ANGLE_FULL_CIRCLE/WATER_SHIELD_NUM;

//			if (this is Bass && skinNum == Bass.SKIN_SKULL_MAN_NES)
//				nums = ANGLE_FULL_CIRCLE/4;
//			else
//				nums = ANGLE_FULL_CIRCLE/WATER_SHIELD_NUM;

			for (var i:int = 0; i < WATER_SHIELD_NUM; i++)
			{
				var num:Number = nums*i;
				var proj:MegaManProjectile = new MegaManProjectile(megaMan,TYPE_WATER_SHIELD,num);
				Level.levelInstance.addToLevel( proj );
				megaMan.waterShieldDct.addItem( proj );
			}
		}
		private function waterShield():void
		{
			if (waterShieldAngle > 0)
			{
				visible = false;
				stopHit = true;
			}
			destroyOffScreen = false;
			waterShieldDir = megaMan.scaleX;
			if (waterShieldDir < 0)
				waterShieldAngle -= ANGLE_FULL_CIRCLE/2;
			gotoAndStop(FL_WATER_SHIELD);
			x = megaMan.nx + waterShieldRadius*waterShieldDir;
			y = megaMan.hMidY;
			vx = 0;
			vy = 0;
			_damageAmt = DamageValue.MEGA_MAN_WATER_SHIELD;
			stopAnim = true;
			defyGrav = true;
			SND_MNGR.playSound( SoundNames.SFX_MEGA_MAN_WATER_SHIELD );
//			removeAllHitTestableItems();
		}
		public function waterShieldExpandInit():void
		{
			if (!waterShieldExpandPnt)
			{
				destroyOffScreen = true;
				waterShieldExpandPnt = new Point(megaMan.nx,megaMan.hMidY);
				SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_WATER_SHIELD_EXPAND);
			}
		}
		private function magmaBazookaSetDir():void
		{
			var speed:int = MAGMA_BAZOOKA_SPEED;
			vx = speed*megaMan.scaleX;
			if (subType == MB_UP)
				vy = -speed;
			else if (subType == MB_DOWN)
				vy = speed;
			if (vx != 0 && vy != 0)
			{
				vx *= .75;
				vy *= .75;
			}
		}
		private function weakChargeFireShot():void
		{
			stopAnim = false;
			this.gotoAndStop("weakChargeFireStart");
			SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_CHARGE_SHOT);
			_damageAmt = DamageValue.MEGA_MAN_WEAK_CHARGE_FIRE;
			defyGrav = true;
			xSpeed = SPEED;
			setDir();
			mainAnimTmr = ANIM_FAST_TMR;
		}
		private function strongChargeFireShot():void
		{
			stopAnim = false;
			addProperty( new StatusProperty( PR_PASSTHROUGH_DEFEAT) );
			this.gotoAndStop("strongChargeFireStart");
			SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_CHARGE_SHOT);
			_damageAmt = DamageValue.MEGA_MAN_FULL_CHARGE_FIRE;
			mainAnimTmr = ANIM_FAST_TMR;
			defyGrav = true;
			xSpeed = SPEED;
			setDir();
			megaMan.chargeShot = this;
		}
		override protected function setDir():void
		{
			var yOfsOnGround:int = Y_PAD_BOT_ON_GROUND;
			var yOfsOffGround:int = Y_PAD_BOT_OFF_GROUND;
			var skinNum:int = megaMan.skinNum;
			var skinProtoMan:Boolean = MegaManBase.skinProtoMan;

			if (megaMan.repositionBullets())
			{
//				if ( (skinNum > 1 && skinNum < 6) || skinNum == MegaMan.SKIN_BREAK_MAN_NES || skinNum == MegaMan.SKIN_BREAK_MAN_SNES || skinNum == MegaMan.SKIN_BREAK_MAN_GB )
				if ( skinProtoMan || skinNum == MegaMan.SKIN_MEGA_MAN_GB )
				{
					yOfsOnGround = Y_PAD_BOT_ON_GROUND_PROTO;
					yOfsOffGround = Y_PAD_BOT_OFF_GROUND_PROTO;
				}
				else if ( skinNum == MegaMan.SKIN_ROKKO_CHAN )
				{
					yOfsOnGround = Y_PAD_BOT_ON_GROUND_ROKKO;
					yOfsOffGround = Y_PAD_BOT_OFF_GROUND_ROKKO;
				}
			}
			if (megaMan.scaleX > 0)
			{
				vx = xSpeed;
				x = megaMan.nx + X_OFS;
			}
			else
			{
				vx = -xSpeed;
				scaleX = -1;
				x = megaMan.nx - X_OFS;
			}
			if (megaMan.onGround)
				y = megaMan.ny - yOfsOnGround;
			else
				y = megaMan.ny - yOfsOffGround;
			if ( isNaN(xSpeed) )
				vx = 0;
		}
		override public function updateObj():void
		{
			super.updateObj();
			if (type == TYPE_MEGA_BUSTER && x >= 5332 && !stopHit && level.disableScreenScroll)
				attackObjNonPiercing(null);
			if (type == TYPE_SUPER_ARM)
			{
				superArmBrick.x = nx - TILE_SIZE/2;
				superArmBrick.y = ny - TILE_SIZE/2;
			}
			else if (type == TYPE_HARD_KNUCKLE)
			{
				if (currentLabel == FL_HARD_KNUCKLE_START || currentLabel == FL_HARD_KNUCKLE_END )
				{
					vx += HARD_KNUCKLE_AX*scaleX*dt;
					if (megaMan.upBtn)
						vy = -HARD_KNUCKLE_VY;
					else if (megaMan.dwnBtn)
						vy = HARD_KNUCKLE_VY;
					else
						vy = 0;
				}
			}
			else if (type == TYPE_PHARAOH_BALLOON)
			{
				pharaohBalloonUpdPos();
			}
			else if (type == TYPE_WATER_SHIELD)
			{
				var centerX:Number = megaMan.nx;
				var centerY:Number = megaMan.hMidY;
				if (waterShieldExpandPnt)
				{
					centerX = waterShieldExpandPnt.x;
					centerY = waterShieldExpandPnt.y;
					waterShieldRadius += WATER_SHIELD_EXPAND_SPEED;
				}
				nx = centerX + Math.cos(waterShieldAngle) * waterShieldRadius;
				ny = centerY + Math.sin(waterShieldAngle) * waterShieldRadius;
				waterShieldAngle += WATER_SHIELD_ROTATE_SPEED*dt*waterShieldDir;
				if (!visible && ( waterShieldAngle >= ANGLE_FULL_CIRCLE || waterShieldAngle <= -ANGLE_FULL_CIRCLE/2 ) )
				{
					visible = true;
					stopHit = false;
				}
			}
		}
		private function hardKnuckleActivate():void
		{
			gotoAndStop(FL_HARD_KNUCKLE_START);
			stopHit = false;
			megaMan.stopUpdate = false;
		}
		override protected function attackObjNonPiercing(obj:IAttackable):void
		{
			if (type == TYPE_MEGA_BUSTER || type == TYPE_BASS_BUSTER || type == TYPE_METAL_BLADE || type == TYPE_PHARAOH_BALLOON || type == TYPE_PHARAOH_SHOT || type == TYPE_SCREW_CRUSHER)
			{
				vx = -vx;
				vy = -VY_DEFLECT;
				stopHit = true;
				if (type == TYPE_PHARAOH_BALLOON && megaMan.pharaohBalloon == this )
				{
					if (nx < LevObj(obj).nx)
						vx = -SPEED;
					else
						vx = SPEED;
					destroyOffScreen = true;
					megaMan.pharaohBalloon = null;
				}
				else if (vx == 0)
				{
					if (nx < LevObj(obj).nx)
						vx = -SPEED;
					else
						vx = SPEED;
				}
			}
			else if (type == TYPE_FLAME_BLAST && currentLabel == FL_FLAME_BLAST_BULLET)
				vx = -vx;
			else if (type == TYPE_CHARGE_STRONG || type == TYPE_CHARGE_WEAK || type == TYPE_WATER_SHIELD)
				destroy();
			else if (superArmBrick)
				superArmBrick.breakBrick(true);

			// Set SFX
			if ( megaMan.skinNum == MegaMan.SKIN_ICE_MAN_NES && type == TYPE_CHARGE_STRONG )
				SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_ICE_SLASHER_HIT);
			else
				SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_DEFLECT);
		}
		override protected function attackObjPiercing(obj:IAttackable):void
		{
			if (obj is Enemy)
			{
				// Set SFX
				if ( megaMan.skinNum == MegaMan.SKIN_ICE_MAN_NES && type == TYPE_CHARGE_STRONG )
					SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_ICE_SLASHER_HIT);
				else
					SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_HIT_ENEMY);

				if (superArmBrick)
					superArmBrick.breakBrick(true);
			}
		}
	/*	override public function confirmedHit(mc:IAttackable):void
		{

			HIT_OBJS_DCT.addItem(mc);
			if ( !hasProperty(PR_PASSTHROUGH_DEFEAT) )
			{
				if (mc is Enemy && mc.health > 0)
				{
					if (!(mc as Enemy).bulletProof || hasProperty(ItemProperties.ARMOR_PIERCING) )
					{
						SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_HIT_ENEMY);
						blowUp();
					}
					else
					{

						deflect();
					}
				}
				else
					blowUp();
			}
			else
			{
				if (mc is Brick && Brick(mc).item == "coin")
					HIT_OBJS_DCT.addItem(mc);
				if (mc is Enemy && mc.health > 0)
				{
					if (!(mc as Enemy).bulletProof || hasProperty(ItemProperties.ARMOR_PIERCING) )
						SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_HIT_ENEMY);
					else
						SND_MNGR.playSound(SoundNames.SFX_MEGA_MAN_DEFLECT);
					blowUp();
				}
			}
		}*/
		protected function blowUp():void
		{
			if (superArmBrick)
				superArmBrick.breakBrick(true);
			destroy();
		}
		override public function checkFrame():void
		{
			var cf:int = currentFrame;
			if (type == TYPE_MEGA_BUSTER && cf == convFrameToInt(FL_MEGA_BUSTER_END) + 1)
				gotoAndStop(FL_MEGA_BUSTER_START);
			else if (type == TYPE_CHARGE_WEAK && cf == convFrameToInt(FL_WEAK_CHARGE_END) + 1)
				gotoAndStop(FL_WEAK_CHARGE_START);
			else if (type == TYPE_CHARGE_STRONG && cf == convFrameToInt(FL_STRONG_CHARGE_END) + 1)
				gotoAndStop(FL_STRONG_CHARGE_START);
			else if (type == TYPE_METAL_BLADE && cf == convFrameToInt(FL_METAL_BLADE_END) + 1)
				gotoAndStop(FL_METAL_BLADE_START);
			else if (type == TYPE_SCREW_CRUSHER && cf == convFrameToInt(FL_SCREW_CRUSHER_END) + 1)
				gotoAndStop(FL_SCREW_CRUSHER_START);
			else if (type == TYPE_HARD_KNUCKLE)
			{
				if (cf == convFrameToInt(FL_HARD_KNUCKLE_APPEAR_END) + 1)
					hardKnuckleActivate();
				else if (cf == convFrameToInt(FL_HARD_KNUCKLE_END) + 1 )
					gotoAndStop(FL_HARD_KNUCKLE_START);
			}
			else if (type == TYPE_FLAME_BLAST && cf == convFrameToInt(FL_FLAME_BLAST_FLAME_END) + 1)
				destroy();
			else if (type == TYPE_MAGMA_BAZOOKA && cf == convFrameToInt(FL_MAGMA_BAZOOKA_END) + 1)
				gotoAndStop(FL_MAGMA_BAZOOKA_START);
			else if (type == TYPE_MAGMA_BAZOOKA_CHARGE && cf == convFrameToInt(FL_MAGMA_BAZOOKA_CHARGE_END) + 1)
				gotoAndStop(FL_MAGMA_BAZOOKA_CHARGE_START);
			else if (type == TYPE_PHARAOH_BALLOON)
			{
				if (cf == convFrameToInt( FL_PHARAOH_BALLOON_END ) + 1)
				{
					gotoAndStop(FL_PHARAOH_BIG_START);
					_damageAmt = DamageValue.MEGA_MAN_PHARAOH_SHOT_BIG;
					pharaohChargeLevel = PHARAOH_CHARGE_FULL;
				}
				else if (cf == convFrameToInt( FL_PHARAOH_BIG_END ) + 1)
					gotoAndStop(FL_PHARAOH_BIG_START);
				else if (cf == convFrameToInt( FL_PHARAOH_CHARGE_LEVEL_2) + 1)
				{
					_damageAmt = DamageValue.MEGA_MAN_PHARAOH_SHOT_MEDIUM;
					pharaohChargeLevel = PHARAOH_CHARGE_MED;
				}
			}
			else if (type == TYPE_PHARAOH_SHOT && cf == convFrameToInt( FL_PHARAOH_BIG_END) + 1)
				gotoAndStop(FL_PHARAOH_BIG_START);

			/*else if (type == 4 && cf == getLabNum("fireEnd") + 1)
				gotoAndStop("fireStart");
			else if (type == 5 && cf == getLabNum("weakChargeFireEnd") + 1)
				gotoAndStop("weakChargeFireStart");
			else if (type == 6 && cf == getLabNum("strongChargeFireEnd") + 1)
				gotoAndStop("strongChargeFireStart");*/
		}
		override public function hitGround(ground:Ground,side:String):void
		{
			if (type == TYPE_SUPER_ARM)
				blowUp();
			else if (type == TYPE_FLAME_BLAST && ( !(ground is Brick) || Brick(ground).item ) )
				flameBlastExplode(ground,side);
			else if (type == TYPE_BASS_BUSTER && !ground.hitTestTypesDct[HT_BRICK])
				blowUp();
			super.hitGround(ground,side);
		}
		override protected function reattachLsrs():void
		{
			super.reattachLsrs();
			if (pharaohBalloonDelTmr)
				pharaohBalloonDelTmr.addEventListener(TimerEvent.TIMER_COMPLETE,pharaohBallonDelTmrHandler,false,0,true);
		}
		override protected function removeListeners():void
		{
			super.removeListeners();
			if (pharaohBalloonDelTmr)
				pharaohBalloonDelTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,pharaohBallonDelTmrHandler);
			if (type == TYPE_HARD_KNUCKLE)
				EVENT_MNGR.removeEventListener(CustomEvents.LEVEL_SET_INDEXES,levelSetIndexesHandler);
		}
		override public function groundBelow(g:Ground):void
		{

		}
		override public function cleanUp():void
		{
			super.cleanUp();
			if (type == TYPE_CHARGE_STRONG)
				megaMan.chargeShot = null;
			else if (superArmBrick)
				superArmBrick.destroy();
			else if (type == TYPE_WATER_SHIELD)
				megaMan.waterShieldDct.removeItem(this);
			else if (type == TYPE_PHARAOH_BALLOON && megaMan.pharaohBalloon == this)
				megaMan.pharaohBalloon = null;
			else if (type == TYPE_HARD_KNUCKLE && megaMan.stopUpdate)
				megaMan.stopUpdate = false;
		}
	}
}
