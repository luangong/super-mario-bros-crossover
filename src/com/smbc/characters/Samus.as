package com.smbc.characters
{
	import com.explodingRabbit.cross.gameplay.statusEffects.StatFxFlash;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatFxInvulnerable;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatFxStop;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatusProperty;
	import com.explodingRabbit.display.CustomMovieClip;
	import com.explodingRabbit.utils.CustomDictionary;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.data.AnimationTimers;
	import com.smbc.data.CharacterInfo;
	import com.smbc.data.Cheats;
	import com.smbc.data.DamageValue;
	import com.smbc.data.Difficulties;
	import com.smbc.data.GameSettings;
	import com.smbc.data.PaletteTypes;
	import com.smbc.data.PickupInfo;
	import com.smbc.data.RandomDropGenerator;
	import com.smbc.data.SoundNames;
	import com.smbc.displayInterface.SamusMissileCount;
	import com.smbc.enemies.Bowser;
	import com.smbc.enemies.Enemy;
	import com.smbc.enums.SamusWeapon;
	import com.smbc.graphics.BmdSkinCont;
	import com.smbc.graphics.HudAlwaysOnTop;
	import com.smbc.graphics.Palette;
	import com.smbc.graphics.fontChars.FontCharSamus;
	import com.smbc.ground.Ground;
	import com.smbc.ground.Platform;
	import com.smbc.ground.SimpleGround;
	import com.smbc.interfaces.IAttackable;
	import com.smbc.level.CharacterSelect;
	import com.smbc.level.TitleLevel;
	import com.smbc.main.LevObj;
	import com.smbc.managers.TutorialManager;
	import com.smbc.messageBoxes.GridMenuBox;
	import com.smbc.pickups.BowserAxe;
	import com.smbc.pickups.Pickup;
	import com.smbc.pickups.SamusPickup;
	import com.smbc.pickups.Vine;
	import com.smbc.projectiles.*;
	import com.smbc.text.TextFieldContainer;
	import com.smbc.utils.GameLoopTimer;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	import org.osmf.traits.PlayState;

	public class Samus extends Character
	{
		public static const CHAR_NAME:String = CharacterInfo.Samus[ CharacterInfo.IND_CHAR_NAME ];
		public static const CHAR_NAME_CAPS:String = CharacterInfo.Samus[ CharacterInfo.IND_CHAR_NAME_CAPS ];
		public static const CHAR_NAME_TEXT:String = CharacterInfo.Samus[ CharacterInfo.IND_CHAR_NAME_MENUS ];
		public static const CHAR_NUM:int = CharacterInfo.Samus[ CharacterInfo.IND_CHAR_NUM ];
		public static const PAL_ORDER_ARR:Array = [ PaletteTypes.FLASH_POWERING_UP ];
		private static const REPOSITION_BULLETS_DCT:Dictionary = new Dictionary();
		{(function ():void
			{
				var repositionBulletsSkinNums:Array = [ 1, 2, 4, 12 ];
				for each (var num:int in repositionBulletsSkinNums)
				{
					REPOSITION_BULLETS_DCT[num] = num;
				}
			}() );
		}
//		protected static const SAMUS_BOMB:String = PickupInfo.SAMUS_BOMB;
		protected static const SAMUS_HIGH_JUMP:String = PickupInfo.SAMUS_HIGH_JUMP;
		protected static const SAMUS_ICE_BEAM:String = PickupInfo.SAMUS_ICE_BEAM;
		protected static const SAMUS_LONG_BEAM:String = PickupInfo.SAMUS_LONG_BEAM;
		protected static const SAMUS_MISSILE:String = PickupInfo.SAMUS_MISSILE;
		protected static const SAMUS_MISSILE_AMMO:String = PickupInfo.SAMUS_MISSILE_AMMO;
		protected static const SAMUS_MISSILE_CAPACITY:String = PickupInfo.SAMUS_MISSILE_EXPANSION;
		protected static const SAMUS_MORPH_BALL:String = PickupInfo.SAMUS_MORPH_BALL;
		protected static const SAMUS_SCREW_ATTACK:String = PickupInfo.SAMUS_SCREW_ATTACK;
		protected static const SAMUS_WAVE_BEAM:String = PickupInfo.SAMUS_WAVE_BEAM;
		protected static const SAMUS_VARIA_SUIT:String = PickupInfo.SAMUS_VARIA_SUIT;
		public static const OBTAINABLE_UPGRADES_ARR:Array = [
			[ SAMUS_ICE_BEAM, SAMUS_WAVE_BEAM, SAMUS_VARIA_SUIT, SAMUS_SCREW_ATTACK ], // SAMUS_HIGH_JUMP
			[ SAMUS_MISSILE_CAPACITY ]
//			[ SAMUS_MORPH_BALL ],
//			[ SAMUS_MISSILE, SAMUS_BOMB, SAMUS_ICE_BEAM ],
//			[ SAMUS_WAVE_BEAM, SAMUS_VARIA_SUIT  ], // SAMUS_HIGH_JUMP
//			[ SAMUS_SCREW_ATTACK, SAMUS_MISSILE_CAPACITY ]
		];

		override public function get classicGetMushroomUpgrades():Vector.<String>
		{ return Vector.<String>([ SAMUS_LONG_BEAM, SAMUS_MISSILE ]); }

		override public function get classicLoseMushroomUpgrades():Vector.<String>
		{ return Vector.<String>([ SAMUS_LONG_BEAM ]); }

		override public function get classicGetFireFlowerUpgrades():Vector.<String>
		{ return Vector.<String>([ classicWeapon, SAMUS_SCREW_ATTACK, SAMUS_MISSILE_CAPACITY ]); }

		override public function get classicLoseFireFlowerUpgrades():Vector.<String>
		{ return Vector.<String>([ classicWeapon, SAMUS_SCREW_ATTACK ]); }

		private static const CLASSIC_MISSILE_DEFAULT_AMMO:int = 4;

		public static const MUSHROOM_UPGRADES:Array = [ SAMUS_LONG_BEAM ];
		public static const NEVER_LOSE_UPGRADES:Array = [ SAMUS_MISSILE, SAMUS_MORPH_BALL, SAMUS_MISSILE_CAPACITY ];
		public static const RESTORABLE_UPGRADES:Array = [ SAMUS_SCREW_ATTACK, SAMUS_HIGH_JUMP, SAMUS_VARIA_SUIT ];
		public static const START_WITH_UPGRADES:Array = [ SAMUS_MORPH_BALL ];
		public static const SINGLE_UPGRADES_ARR:Array = [ SAMUS_ICE_BEAM, SAMUS_WAVE_BEAM ];
		public static const REPLACEABLE_UPGRADES_ARR:Array = [ [  ] ];
		public static const TITLE_SCREEN_UPGRADES:Array = [ MUSHROOM, SAMUS_LONG_BEAM, SAMUS_MORPH_BALL ];
		public static const ICON_ORDER_ARR:Array = [ SAMUS_MISSILE, SAMUS_MISSILE_CAPACITY, SAMUS_ICE_BEAM, SAMUS_WAVE_BEAM, SAMUS_VARIA_SUIT, SAMUS_HIGH_JUMP, SAMUS_SCREW_ATTACK ]; // samus bomb, SAMUS_MISSILE_CAPACITY
		public static const AMMO_ARR:Array = [ [ SAMUS_MISSILE, 8, 40] ];
		public static const AMMO_DEPLETION_ARR:Array = [ [ SAMUS_MISSILE, 1 ] ];
		public static const AMMO_DCT:CustomDictionary = new CustomDictionary();
		public static const AMMO_DEPLETION_DCT:CustomDictionary = new CustomDictionary();
		private static const DROP_ARR_MISSILES:Array = [ [ 0, SAMUS_MISSILE_AMMO ] ];
		private static const PAL_ROW_POWER_SUIT:int = 1;
		private static const PAL_ROW_POWER_SUIT_MISSILE:int = 2;
		private static const PAL_ROW_VARIA_SUIT:int = 3;
		private static const PAL_ROW_VARIA_SUIT_MISSILE:int = 4;

		private static const SKIN_APPEARANCE_NUM_POWER_SUIT:int = 0;
		private static const SKIN_APPEARANCE_NUM_VARIA_SUIT:int = 1;

		public static const IND_CI_Samus:int = 1;
		public static const IND_CI_SamusPortrait:int = 5;
		public static const IND_CI_SamusVariaSuit:int = 6;
		public static const IND_CI_SamusLongBeam:int = 7;
		public static const IND_CI_SamusIceBeam:int = 8;
		public static const IND_CI_SamusWaveBeam:int = 9;
		public static const IND_CI_SamusMorphBall:int = 10;
		public static const IND_CI_SamusBomb:int = 11;
		public static const IND_CI_SamusMissile:int = 12;
		public static const IND_CI_SamusMissileExpansion:int = 13;
		public static const IND_CI_SamusHighJump:int = 14;
		public static const IND_CI_SamusScrewAttack:int = 15;
		public static const IND_CI_SamusMissileAmmo:int = 16;

		private static const MISSILE_EXPANSION_MAX_AMMO:int = 99;
		private static const FIRE_MISSILE_COST:int = -1;
		public static const MISSILE_PICKUP_VALUE:int = 2;
		private const DIE_TMR_DEL_NORMAL:int = 3000;
		private const DIE_TMR_DEL_PIT:int = 2500;
//		public static const SUFFIX_VEC:Vector.<String> = Vector.<String>(["_1","_2","_2"]);
		public static const WIN_SONG_DUR:int = 4250;
		public static const CHAR_SEL_END_DUR:int = 2000;
		private const REPL_COLOR_1_1:uint = 0xFFE40058; // 1_3
		private const REPL_COLOR_2_1:uint = 0xFFC84C0C; // 2_3
		private const REPL_COLOR_3_1:uint = 0xFFFCC4FC; // 3_3
		private const REPL_COLOR_1_2:uint = 0xFFD82800; // 1_1
		private const REPL_COLOR_2_2:uint = 0xFF009400; // 2_1
		private const REPL_COLOR_3_2:uint = 0xFFFC9838; // 3_1
		private const REPL_COLOR_1_3:uint = REPL_COLOR_1_2; // 1_2
		private const REPL_COLOR_2_3:uint = REPL_COLOR_2_2; // 2_2
		private const REPL_COLOR_3_3:uint = 0xFFFCC4D8; // 3_2
		private const BALL_DISPLACE:int = 10;
		private const BALL_DISPLACE_CROUCH:int = 5;
		private const BOMB_BOOST:uint = 230;
		private const BASE_FL_WALK:String = "walk";
		private const BASE_FL_WALK_SHOOT:String = "shootWalk";
		private const BASE_FL_UP_WALK:String = "upWalk";
		private const BASE_FL_UP_WALK_SHOOT:String = "upWalkShoot";
		private static const FL_MISSILE_AMMO_ICON:String = "missile" + AMMO_ICON_SUFFIX;
		private const FL_BALL_START:String = "ballStart";
		private const FL_BALL_END:String = "ballEnd";
		private const FL_CLIMB_START:String = "climbStart";
		private const FL_CLIMB_END:String = "climbEnd";
		private const FL_CROUCH:String = "crouch";
		private const FL_CROUCH_SHOOT:String = "crouchShoot";
		private const FL_FLIP_START:String = "flipStart";
		private const FL_FLIP_END:String = "flipEnd";
		private const FL_JUMP:String = "jump";
		private const FL_JUMP_SHOOT:String = "jumpShoot";
		private const FL_JUMP_UP:String = "upJump";
		private const FL_JUMP_UP_SHOOT:String = "upJumpShoot";
		private const FL_SLIDE:String = "slide";
		private const FL_STAND:String = "stand";
		private const FL_STAND_FRONT:String = "standFront";
		private const FL_STAND_SHOOT:String = "standShoot";
		private const FL_STAND_UP:String = "upStand";
		private const FL_STAND_UP_SHOOT:String = "upStandShoot";
		private const FL_WALK_SHOOT_START:String = "shootWalk-1";
		private const FL_WALK_SHOOT_END:String = "shootWalk-3";
		private static const FL_WALK_SHOOT_2:String = "shootWalk-2";
		private const FL_WALK_UP_START:String = "upWalk-1";
		private const FL_WALK_UP_END:String = "upWalk-3";
		private const FL_WALK_UP_SHOOT_START:String = "upWalkShoot-1";
		private const FL_WALK_UP_SHOOT_END:String = "upWalkShoot-3";
		private const FL_WALK_START:String = "walk-1";
		private const FL_WALK_END:String = "walk-3";
		public static const ST_BALL:String = "ball";
		private const ST_WALK_UP:String = "walkUp";
		private const SND_MUSIC_WIN:String = SoundNames.MFX_SAMUS_WIN;
		private const SFX_SAMUS_DIE:String = SoundNames.SFX_SAMUS_DIE;
		private const SFX_SAMUS_JUMP:String = SoundNames.SFX_SAMUS_JUMP
		private const SFX_SAMUS_LAND:String = SoundNames.SFX_SAMUS_LAND;
		private const SFX_SAMUS_MORPH_BALL:String = SoundNames.SFX_SAMUS_MORPH_BALL;
		private const SFX_SAMUS_STEP:String = SoundNames.SFX_SAMUS_STEP;
		private static const SN_SCREW_ATTACK:String = SoundNames.SFX_SAMUS_SCREW_ATTACK;
		private static const SN_TAKE_DAMAGE:String = SoundNames.SFX_SAMUS_TAKE_DAMAGE;
		private const STILL_SHOOT_TMR:CustomTimer = new CustomTimer(50,1);
		private const MOVE_SHOOT_TMR:CustomTimer = new CustomTimer(140,1);
		private const STEP_TMR:CustomTimer = new CustomTimer(150,1);
		public const MAX_SHOTS_ON_SCREEN:int = 3;
		private const MAX_BOMBS_ON_SCREEN:int = 3;
		private const CLIMB_ANIM_TMR:CustomTimer = AnimationTimers.ANIM_SLOW_TMR;
		private static const WALK_SPEED:int = 185;
		private const FLIP_HEIGHT_DIST:int = 60;
		private const BALL_CHECK_DIST:int = 60;
		private static const DAMAGE_BOOST_VX:int = WALK_SPEED;
		private static const DAMAGE_BOOST_VY:int = 250;
		public const BULLET_DCT:CustomDictionary = new CustomDictionary();
		public const BOMB_DCT:CustomDictionary = new CustomDictionary();
		private var flipStartPos:Number;
		private var shoot:Boolean;
		private var flip:Boolean;
		public var invertedWaveBeam:Boolean;
		private const BALL_TOP_OFS:int = 30;
		private const BALL_BOT_OFS:int = 10;
		private const FLAG_POLE_OFFSET:int = 0; //15;
		public var muteStepSounds:Boolean;
		public static var classicMode:Boolean;
		private static const JUMP_PWR_NORMAL:int = 500;
		private static const JUMP_PWR_HIGH:int = 580;
//		private static const JUMP_HEIGHT_NORMAL:int = 100;
//		private static const JUMP_HEIGHT_HIGH_JUMP:int = 150;
//		private static const JUMP_SPEED_NORMAL:int = 100;
//		private static const JUMP_SPEED_HIGH_JUMP:int = 100;
		private var standFrame:String = FL_STAND;
		private var damageBoostTmr:GameLoopTimer;
		private static const DAMAGE_BOOST_TMR_DEL:int = 250;
		private static const FLICKER_TMR_DEL:int = 25;
		private var morphBall:Boolean;
		private var missileMode:Boolean;
		private var screwAttack:Boolean;
		private var screwAttackedAlready:Boolean;
		public static const FREEZE_DUR:int = 6000;
		public static const DEFAULT_PROPS_DCT:CustomDictionary = new CustomDictionary();
		private static const SHOT_IMMOBILIZE_DUR:int = 150;
		private static const IND_PALETTE_SCREW_ATTACK:int = 4;
		private var paletteScrewAttack:Palette;
		private var charSelPlatform:Platform;

		public static const SKIN_PREVIEW_SIZE:Point = new Point(30,38);
		public static const SKIN_APPEARANCE_STATE_COUNT:int = 2;
		public static const SKIN_ORDER:Array = [
			SKIN_SAMUS_NES,
			SKIN_SAMUS_SNES,
			SKIN_SAMUS_GB,
			SKIN_SAMUS_X1,
			SKIN_SAMUS_ATARI,
			SKIN_SAMUS_NO_SUIT_NES,
			SKIN_SAMUS_NO_SUIT_SNES,
			SKIN_SAMUS_NO_SUIT_SUPER_METROID,
			SKIN_SAMUS_ZERO_SUIT_NES,
			SKIN_DARK_SAMUS_NES,
			SKIN_DARK_SAMUS_SNES,
			SKIN_DARK_SAMUS_GB,
			SKIN_PIT_NES,
			SKIN_DARK_PIT_NES
		];

		public static const SKIN_SAMUS_NES:int = 0;
		public static const SKIN_SAMUS_SNES:int = 1;
		public static const SKIN_SAMUS_GB:int = 2;
		public static const SKIN_SAMUS_NO_SUIT_NES:int = 3;
		public static const SKIN_DARK_SAMUS_SNES:int = 4;
		public static const SKIN_SAMUS_ZERO_SUIT_NES:int = 5;
		public static const SKIN_PIT_NES:int = 6;
		public static const SKIN_SAMUS_ATARI:int = 7;
		public static const SKIN_SAMUS_X1:int = 8;
		public static const SKIN_SAMUS_NO_SUIT_SUPER_METROID:int = 9;
		public static const SKIN_SAMUS_NO_SUIT_SNES:int = 10;
		public static const SKIN_DARK_PIT_NES:int = 11;
		public static const SKIN_DARK_SAMUS_GB:int = 12;
		public static const SKIN_DARK_SAMUS_NES:int = 13;

		public static const SPECIAL_SKIN_NUMBER:int = SKIN_SAMUS_X1;
		public static const ATARI_SKIN_NUMBER:int = SKIN_SAMUS_ATARI;

		private var _skinShootHeightOffset:int;
		private var skinCanMoveWhileCrouching:Boolean;
		private var skinCanWalkWhileShooting:Boolean;
		private var skinDisableMorphBall:Boolean
		private var skinFootStepsMakeSnd:Boolean
		private var _skinShootSound:String;
		private var skinJumpSound:String;

		private var palRow:int;

		public function Samus()
		{
			charNum = CHAR_NUM;
			recolorsCharSkin = true;
			super();
			if (!DEFAULT_PROPS_DCT.length)
			{
				DEFAULT_PROPS_DCT.addItem( new StatusProperty(PR_FLASH_AGG,0, new StatFxFlash(null,AnimationTimers.DEL_FAST,SHOT_IMMOBILIZE_DUR) ) );
				DEFAULT_PROPS_DCT.addItem( new StatusProperty(PR_STOP_AGG, 0, new StatFxStop(null,SHOT_IMMOBILIZE_DUR) ) );
				DEFAULT_PROPS_DCT.addItem( new StatusProperty(PR_INVULNERABLE_AGG, 0, new StatFxInvulnerable(null,SHOT_IMMOBILIZE_DUR) ) );
				DEFAULT_PROPS_DCT.addItem( new StatusProperty(PR_UNFREEZE_AGG) );
			}
			for each (var prop:StatusProperty in DEFAULT_PROPS_DCT)
			{
				addProperty(prop);
			}
			mainAnimTmr = ANIM_MIN_FAST_TMR;
			_charName = CHAR_NAME;
			_canGetAmmoFromBricks = true;
//			suffixVec = SUFFIX_VEC.concat();
			_charNameCaps = CHAR_NAME_CAPS;
			_charNameTxt = CHAR_NAME_TEXT;
			_sndWinMusic = SND_MUSIC_WIN;
			_dieTmrDel = DIE_TMR_DEL_NORMAL;
			winSongDur = WIN_SONG_DUR;
			_usesHorzObjs = true;
			walkStartLab = FL_WALK_START;
			walkEndLab = FL_WALK_END;
			vineAnimTmr = CLIMB_ANIM_TMR;
			flickerTmrDel = FLICKER_TMR_DEL;
			addProperty( new StatusProperty(PR_PIERCE_AGG,10) );
//			addProperty( new StatusProperty( StatusProperty.TYPE_INSTANT_KILL_AGG ) );
		}

		public function get skinShootHeightOffset():int
		{
			return _skinShootHeightOffset;
		}

		public function get skinShootSound():String
		{
			return _skinShootSound;
		}

		override protected function get currentSkinAppearanceNum():int
		{
			if ( upgradeIsActive(SAMUS_VARIA_SUIT) || (GameSettings.classicMode && upgradeIsActive(FIRE_FLOWER) ) )
				return SKIN_APPEARANCE_NUM_VARIA_SUIT;
			else
				return SKIN_APPEARANCE_NUM_POWER_SUIT;
		}

		private function changeSuitColor(forcePalRow:int = -1):void
		{
			if (upgradeIsActive(SAMUS_VARIA_SUIT) || (GameSettings.classicMode && upgradeIsActive(FIRE_FLOWER) ) )
			{
				if (!missileMode)
					palRow = PAL_ROW_VARIA_SUIT;
				else
					palRow = PAL_ROW_VARIA_SUIT_MISSILE;
			}
			else
			{
				if (!missileMode)
					palRow = PAL_ROW_POWER_SUIT;
				else
					palRow = PAL_ROW_POWER_SUIT_MISSILE;
			}

			if (forcePalRow >= 0)
				palRow = forcePalRow;

//			if (GridMenuBox.instance != null)
//				graphicsMngr.recolorCharacterSheet(charNum,PAL_ROW_POWER_SUIT,[ IND_CI_Samus ]);
//			else
				graphicsMngr.recolorCharacterSheet(charNum,palRow,[ IND_CI_Samus, IND_CI_SamusPortrait ]);
		}


		override protected function prepareDrawCharacter(skinAppearanceState:int = -1):void
		{
			if (skinAppearanceState == SKIN_APPEARANCE_NUM_POWER_SUIT)
				changeSuitColor(PAL_ROW_POWER_SUIT);
			else if (skinAppearanceState == SKIN_APPEARANCE_NUM_VARIA_SUIT)
				changeSuitColor(PAL_ROW_VARIA_SUIT);
			else
				changeSuitColor();
			super.prepareDrawCharacter(skinAppearanceState);
		}


		override public function setStats():void
		{
			inColor1_1 = REPL_COLOR_1_1;
			inColor2_1 = REPL_COLOR_2_1;
			inColor3_1 = REPL_COLOR_3_1;
			inColor1_2 = REPL_COLOR_1_2;
			inColor2_2 = REPL_COLOR_2_2;
			inColor3_2 = REPL_COLOR_3_2;
			inColor1_3 = REPL_COLOR_1_3;
			inColor2_3 = REPL_COLOR_2_3;
			inColor3_3 = REPL_COLOR_3_3;
			gravity = 700;
			if (level.waterLevel)
			{
				defGravity = gravity;
				gravity = 400;
				defGravityWater = gravity;
			}
			defSpringPwr = 300;
			boostSpringPwr = 700;
			vxMax = 150;
			vyMaxPsv = 450;
			fx = .0001;
			fy = .0001;
			numParFrames = 3;
			pState2 = true;
			super.setStats();
			damageAmt = DamageValue.SAMUS_SCREW_ATTACK;
			changeBrickState();
			MOVE_SHOOT_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,moveShootTmrHandler,false,0,true);
			addTmr(MOVE_SHOOT_TMR);
			STILL_SHOOT_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,stillShootTmrHandler,false,0,true);
			addTmr(STILL_SHOOT_TMR);
			STEP_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,stepTmrHandler,false,0,true);
			addTmr(STEP_TMR);
			damageBoostTmr = new GameLoopTimer(DAMAGE_BOOST_TMR_DEL,1);
			damageBoostTmr.addEventListener(TimerEvent.TIMER_COMPLETE,damageBoostTmrHandler,false,0,true);
//			hitPickup(new SamusPickup(PickupInfo.SAMUS_MORPH_BALL) );
//			hitPickup(new SamusPickup(PickupInfo.SAMUS_ICE_BEAM) );
		}
		override protected function startAndDamageFcts(start:Boolean = false):void
		{
			super.startAndDamageFcts(start);
			if (!start)
				changeSuitColor();
			updMissileAmmoMax();
			updDrops();
			updAmmoDisplay();
			setJumpPwr();
		}
		override public function setCurrentBmdSkin(bmc:BmdSkinCont, characterInitiating:Boolean = false):void
		{
			super.setCurrentBmdSkin(bmc);
			skinSettingsRead(this);
			changeSuitColor();
			paletteScrewAttack = paletteSheet.getPaletteFromRow( IND_PALETTE_SCREW_ATTACK, skinNum );
			updAmmoDisplay();
		}
		protected function damageBoostTmrHandler(event:Event):void
		{
			takeDamageEnd();
		}
		override protected function getOnVine(_vine:Vine):void
		{
			if (flip)
				flipEnd();
			super.getOnVine(_vine);
		}
		override public function forceWaterStats():void
		{
			defGravity = gravity;
			gravity = 400;
			defGravityWater = gravity;
			super.forceWaterStats();
		}
		override public function forceNonwaterStats():void
		{
			gravity = 700;
			super.forceNonwaterStats();
		}
		public function repositionWalkingBullets():Boolean
		{
//			if (REPOSITION_BULLETS_DCT[skinNum] != undefined && (currentLabel == FL_WALK_SHOOT_START || currentLabel == FL_WALK_SHOOT_2 || currentLabel == FL_WALK_SHOOT_END ) )
//				return true;
			if (REPOSITION_BULLETS_DCT[skinNum] != undefined && cState == ST_WALK)
				return true;
			return false;
		}
		private function setJumpPwr():void
		{
			if (upgradeIsActive(SAMUS_HIGH_JUMP))
			{
				jumpPwr = JUMP_PWR_HIGH;
//				gravity = 0;
//				jumpPwr = JUMP_HEIGHT_HIGH_JUMP;
//				jumpPwr = JUMP_SPEED_HIGH_JUMP;
			}
			else
			{
				jumpPwr = JUMP_PWR_NORMAL;
//				gravity = 0;
//				jumpPwr = JUMP_HEIGHT_NORMAL;
//				jumpPwr = JUMP_HEIGHT_HIGH_JUMP;
			}
		}
		override protected function movePlayer():void
		{
			if (cState == ST_TAKE_DAMAGE)
				return;
			var dir:int = 0;
			if (rhtBtn && !lftBtn && !wallOnRight)
				dir = 1;
			else if (lftBtn && !rhtBtn && !wallOnLeft)
				dir = -1;
			if (stuckInWall || (onGround && ( !skinCanWalkWhileShooting && upBtn) || (onGround && dwnBtn && cState != ST_BALL && !skinCanMoveWhileCrouching)  ) || (lftBtn && rhtBtn) || (!lftBtn && !rhtBtn) )
				dir = 0;
			if (dir != 0)
			{
				if (cState == ST_VINE)
				{
					if (exitVine)
						getOffVine();
					else
						return;
				}
				vx = WALK_SPEED*dir;
				scaleX = dir;
			}
			else
				vx = 0;

		}
		override protected function landOnGround():void
		{
			if (cState != ST_BALL && cState != ST_FLAG_SLIDE && !onSpring)
				SND_MNGR.playSound(SFX_SAMUS_LAND);
			if (flip)
				flipEnd();
		}

		// Public Methods:
		// JUMP
		override protected function jump():void
		{
			onGround = false;
			vy = -jumpPwr;
			if (cState == ST_STAND)
				setStopFrame(FL_JUMP);
			if (lftBtn || rhtBtn)
			{
				flipStartPos = ny - FLIP_HEIGHT_DIST;
				setPlayFrame(FL_FLIP_START);
			}
			screwAttackedAlready = false;
			setState(ST_JUMP);
			releasedJumpBtn = false;
			frictionY = false;
			jumped = true;
			if (skinJumpSound != null)
				SND_MNGR.playSound(skinJumpSound);
			else
				SND_MNGR.playSound(SFX_SAMUS_JUMP);
		}
		override protected function setAmmo(ammoType:String, value:int):void
		{
			super.setAmmo(ammoType, value);
			if (upgradeIsActive(SAMUS_MISSILE))
				tsTxt.UpdAmmoText( true, getAmmo(ammoType) );
		}

		override public function hitEnemy(enemy:Enemy, side:String):void
		{
			if (!starPwr && screwAttack && !(enemy is Bowser) )
				landAttack(enemy);
			else
				super.hitEnemy(enemy, side);
		}
		override protected function attackObjPiercing(obj:IAttackable):void
		{
			super.attackObjPiercing(obj);
			if (obj is Enemy)
				SND_MNGR.playSound(SoundNames.SFX_SAMUS_HIT_ENEMY);
		}

		override protected function attackObjNonPiercing(obj:IAttackable):void
		{
			super.attackObjNonPiercing(obj);
			if (obj is Enemy)
				SND_MNGR.playSound(SoundNames.SFX_SAMUS_HIT_ENEMY);
		}

		override public function hitPickup(pickup:Pickup,showAnimation:Boolean = true):void
		{
			var hadFireFlower:Boolean = upgradeIsActive(FIRE_FLOWER);
			var hadMissiles:Boolean = upgradeIsActive(SAMUS_MISSILE);
			super.hitPickup(pickup,showAnimation);
			switch(pickup.type)
			{
				case SAMUS_MISSILE:
				{
					updAmmoDisplay();
//					updDrops();
					break;
				}
				case SAMUS_MISSILE_CAPACITY:
				{
					updMissileAmmoMax();
					break;
				}
				case MUSHROOM:
				{
					if (GameSettings.classicMode && !hadMissiles)
						setAmmo(SAMUS_MISSILE, CLASSIC_MISSILE_DEFAULT_AMMO);
					changeSuitColor();
					updDrops();
					updAmmoDisplay();
					break;
				}
				case FIRE_FLOWER:
				{
					if (hadFireFlower)
						increaseAmmoByValue(SAMUS_MISSILE, CLASSIC_MISSILE_DEFAULT_AMMO);
					else
						updMissileAmmoMax();
					changeSuitColor();
					break;
				}
				case SAMUS_VARIA_SUIT:
				{
					changeSuitColor();
					break;
				}
				case SAMUS_MISSILE_AMMO:
				{
					STAT_MNGR.addCharUpgrade(charNum,SAMUS_MISSILE);
					updAmmoDisplay();
					increaseAmmoByValue(SAMUS_MISSILE,MISSILE_PICKUP_VALUE);
					if (showAnimation)
						SND_MNGR.playSound(SoundNames.SFX_SAMUS_GET_MISSILE);
					break;
				}
			}
			if (pickup.mainType == PickupInfo.MAIN_TYPE_UPGRADE)
				setJumpPwr();
			if (!pickup.playsRegularSound && pickup.mainType != PickupInfo.MAIN_TYPE_FAKE && pickup.type != SAMUS_MISSILE_AMMO && showAnimation)
				SND_MNGR.playSound(SoundNames.SFX_SAMUS_GET_ENERGY);
/*			if (pickup is RandomDropGenerator && RandomDropGenerator(pickup).type == RandomDropGenerator.TYPE_SAMUS)
			{
				var tm:TutorialManager = TutorialManager.TUT_MNGR;
				tm.checkTutorial(CHAR_NAME + tm.TYPE_AMMO,true);
				pickup.touchPlayer(this);
			}*/
		}
		override public function revivalBoost():void
		{
			super.revivalBoost();
//			if (upgradeIsActive(SAMUS_MISSILE) )
//			{
				hitPickup( new Pickup(SAMUS_MISSILE_AMMO), false );
				hitPickup( new Pickup(SAMUS_MISSILE_AMMO), false );
//			}
		}
		private function updMissileAmmoMax():void
		{
			if ( upgradeIsActive(SAMUS_MISSILE_CAPACITY) )
				setMaxAmmo(SAMUS_MISSILE,MISSILE_EXPANSION_MAX_AMMO);
		}
		private function updDrops():void
		{
			if (GameSettings.classicMode)
			{
				if ( upgradeIsActive(SAMUS_MISSILE) )
					dropArr = DROP_ARR_MISSILES;
				else
					dropArr = [];
			}
			else
				dropArr = DROP_ARR_MISSILES;
		}
		private function updAmmoDisplay():void
		{
			if ( !upgradeIsActive(SAMUS_MISSILE) )
			{
				tsTxt.UpdAmmoIcon(false);
				tsTxt.UpdAmmoText(false);
			}
			else
			{
				tsTxt.UpdAmmoIcon(true, FL_MISSILE_AMMO_ICON);
				tsTxt.UpdAmmoText( true, getAmmo( SAMUS_MISSILE) );
			}
		}
		// CHECKSTATE
		override protected function checkState():void
		{
			//trace("samus bmdSkinVec: "+BMD_CONT_VEC.length);
			if (cState == ST_VINE)
			{
				mainAnimTmr = vineAnimTmr;
				checkVineBtns();
				checkVinePosition();
				return;
			}
			else if (cState == ST_TAKE_DAMAGE)
				return;
			if (onGround)
			{
				flip = false;
				jumped = false;
				flipStartPos = -1;
				if (cState == ST_BALL)
					mainAnimTmr = ANIM_FAST_TMR;
				else // cState != ball
				{
					mainAnimTmr = ANIM_MIN_FAST_TMR;
					if (vx == 0)
					{
						if (STEP_TMR.running)
							STEP_TMR.stop();
						if (cState != ST_CROUCH)
							setState(ST_STAND);
						if (upBtn)
						{
							if (!shoot)
								setStopFrame(FL_STAND_UP);
							else
								setStopFrame(FL_STAND_UP_SHOOT);
						}
						else
						{
							if (cState == ST_STAND)
							{
								if (!shoot)
									setStopFrame(standFrame);
								else
									setStopFrame(FL_STAND_SHOOT);
							}
							else
							{
								if (!shoot)
									setStopFrame(FL_CROUCH);
								else
									setStopFrame(FL_CROUCH_SHOOT);
							}
						}
					}
					else // moving
					{
						if (!STEP_TMR.running)
							STEP_TMR.start();
						if (upBtn)
						{
							if (cState != ST_WALK && cState != ST_WALK_UP)
							{
								if (!shoot)
									setPlayFrame(FL_WALK_UP_START);
								else
									setPlayFrame(FL_WALK_UP_SHOOT_START);
								setState(ST_WALK_UP);
							}
							else if (cState == ST_WALK_UP) // same as current state
							{
								if (!shoot)
									setPlayFrame(getParFrame(BASE_FL_UP_WALK));
								else
									setPlayFrame(getParFrame(BASE_FL_UP_WALK_SHOOT));
							}
							else if (cState == ST_WALK)
							{
								if (!shoot)
									setPlayFrame(getParFrame(BASE_FL_UP_WALK));
								else
									setPlayFrame(getParFrame(BASE_FL_UP_WALK_SHOOT));
								setState(ST_WALK_UP);
							}
						}
						else // !upBtn
						{
							if (cState != ST_WALK && cState != ST_WALK_UP)
							{
								if (!shoot)
									setPlayFrame(FL_WALK_START);
								else
									setPlayFrame(FL_WALK_SHOOT_START);
								setState(ST_WALK);
							}
							else if (cState == ST_WALK) // same as current state
							{
								if (!shoot)
									setPlayFrame(getParFrame(BASE_FL_WALK));
								else
									setPlayFrame(getParFrame(BASE_FL_WALK_SHOOT));
							}
							else if (cState == ST_WALK_UP)
							{
								if (!shoot)
									setPlayFrame(getParFrame(BASE_FL_WALK));
								else
									setPlayFrame(getParFrame(BASE_FL_WALK_SHOOT));
								setState(ST_WALK);
							}
						}
					}
				}
			}
			else
			{
				if (STEP_TMR.running)
					STEP_TMR.stop();
				mainAnimTmr = ANIM_FAST_TMR;
				if (cState != ST_BALL) // not on ground
				{
					setState(ST_JUMP);
					if (flip && ny > flipStartPos)
						flipEnd();
					if (cState == ST_JUMP)
					{
						if (upBtn)
						{
							flipEnd();
							if (!shoot)
								setStopFrame(FL_JUMP_UP);
							else
								setStopFrame(FL_JUMP_UP_SHOOT);
						}
						else
						{
							if (shoot)
							{
								setStopFrame(FL_JUMP_SHOOT);
								flipEnd();
							}
							else if (!flip && ny < flipStartPos && vy < 0)
								flipStart();
							else if (!flip)
								setStopFrame(FL_JUMP);
						}
					}
				}
				if (frictionY)
				{
					if (vy < 0)
						vy *= Math.pow(fy,dt);
					else
						frictionY = false;
				}
			}
			if (skinCanMoveWhileCrouching && dwnBtn)
			{
				shoot = false;
				setStopFrame(FL_CROUCH);
			}
			if (charSelPlatform)
			{
				setStopFrame(FL_STAND_FRONT);
				y = charSelPlatform.y;
				ny = y;
				defyGrav = true;
				return;
			}
		}
		private function flipStart():void
		{
			if (flip)
				return;
			flip = true;
			setPlayFrame(FL_FLIP_START);
			if ( upgradeIsActive(SAMUS_SCREW_ATTACK) )
			{
				screwAttack = true;
				if ( !screwAttackedAlready )
					SND_MNGR.playSound(SN_SCREW_ATTACK);
				if (!starPwr)
					startReplaceColor();
				screwAttackedAlready = true;
			}
		}
		private function flipEnd():void
		{
			if (!flip)
				return;
			flip = false;
			if (screwAttack)
				endScrewAttack();
		}
		private function exitMorphBall(frameToSet:String,stateToSet:String):void
		{
			var cancelExitMorphBall:Boolean = false;
			for each (var ground:Ground in level.GROUND_STG_DCT)
			{
				if (!ground.onScreen || !ground.visible || level.getDistance(hMidX,hMidY,ground.hMidX,ground.hMidY) > BALL_CHECK_DIST)
					continue;
				if (hTop - BALL_TOP_OFS <= ground.hBot && hBot - BALL_BOT_OFS > ground.hTop && hLft < ground.hRht && hRht > ground.hLft)
				{
					cancelExitMorphBall = true;
					break;
				}
			}
			if (!cancelExitMorphBall)
			{
				setStopFrame(frameToSet);
				setState(stateToSet);
				morphBall = false;
				if (onGround)
				{
					ny -= BALL_DISPLACE;
					y -= BALL_DISPLACE;
					onGround = false;
				}
			}
			changeBrickState();
		}
		// PRESSUPBTN press up once
		override public function pressUpBtn():void
		{
			super.pressUpBtn();
			if (cState == ST_CROUCH)
			{
				setState(ST_STAND);
				checkState();
			}
			else if (cState == ST_BALL)
				exitMorphBall(FL_STAND_UP,ST_STAND);
		}
		// PRESSJMPBTN
		override public function pressJmpBtn():void
		{
			if (cState == ST_VINE)
				return;
			if (cState == ST_BALL)
				exitMorphBall(FL_JUMP,ST_JUMP);
			else if (onGround)
				jump();
			super.pressJmpBtn();
		}
		override public function relJmpBtn():void
		{
			super.relJmpBtn();
			if (!releasedJumpBtn)
			{
				//vyMaxNgv = Math.abs(vy);
				frictionY = true;
				releasedJumpBtn = true;
			}
		}

		private function canExitCrouch():Boolean
		{
			for each (var ground:Ground in level.GROUND_STG_DCT)
			{
				if (!ground.onScreen || !ground.visible || level.getDistance(hMidX,hMidY,ground.hMidX,ground.hMidY) > BALL_CHECK_DIST)
					continue;
				if (hTop - BALL_TOP_OFS <= ground.hBot && hBot - BALL_BOT_OFS > ground.hTop && hLft < ground.hRht && hRht > ground.hLft)
					return false;
			}
			return true;
		}
		override public function relDwnBtn():void
		{
			super.relDwnBtn();
			var cancelExitMorphBall:Boolean;
			if (skinCanMoveWhileCrouching)
			{
				if (onGround)
				{
					if (vx != 0)
					{
						if (!shoot)
							setStopFrame(FL_WALK_START);
						else
							setStopFrame(FL_WALK_SHOOT_START);
						setState(ST_WALK);
					}
					else
					{
						setState(ST_STAND);
						setStopFrame(FL_STAND);
					}
				}
				else
				{
					if (upBtn)
						setStopFrame(FL_JUMP_UP);
					else
						setStopFrame(FL_JUMP);
					setState(ST_JUMP);
				}

			}
		}
		// PRESSATTACKBTN
		override public function pressAtkBtn():void
		{
			if (cState == ST_VINE)
				return;
			super.pressAtkBtn();
			if (skinCanMoveWhileCrouching && currentLabel == FL_CROUCH)
				return;
			if (classicMode && missileMode && upgradeIsActive(SAMUS_MISSILE) && cState != ST_BALL)
			{
				fireMissile();
				return;
			}
			if (cState != ST_BALL)
			{
				if (BULLET_DCT.length < MAX_SHOTS_ON_SCREEN)
				{
					var shot:SamusShot = new SamusShot(this);
					BULLET_DCT.addItem(shot);
					level.addToLevel(shot);
					shoot = true;
					if ((!onGround && upBtn) || (onGround && !lftBtn && !rhtBtn))
					{
						if (STILL_SHOOT_TMR.running)
							STILL_SHOOT_TMR.reset();
						STILL_SHOOT_TMR.start();
					}
					else
					{
						if (MOVE_SHOOT_TMR.running)
							MOVE_SHOOT_TMR.reset();
						MOVE_SHOOT_TMR.start();
					}
					checkState();
				}
			}
			else if (BOMB_DCT.length < MAX_BOMBS_ON_SCREEN ) // cState == ST_BALL
			{
				var bomb:SamusBomb = new SamusBomb(this);
				BOMB_DCT.addItem(bomb);
				level.addToLevel(bomb);
			}
		}
		private function missileModeToggle():void
		{
			missileMode = !missileMode;
			changeSuitColor();
		}

		override public function pressSpcBtn():void
		{
			super.pressSpcBtn();
			if ( upgradeIsActive(SAMUS_MISSILE))
			{
				if (classicMode)
					missileModeToggle();
				else if (cState != ST_BALL && cState != ST_VINE)
					fireMissile();
			}
		}
		override public function pressSelBtn():void
		{
			super.pressSelBtn();
			if (classicMode)
				missileModeToggle();
		}
		private function fireMissile():void
		{
			var infiniteAmmo:Boolean = false;
			if (Cheats.infiniteAmmo || starPwr)
				infiniteAmmo = true;
			if ( (hasEnoughAmmo(SAMUS_MISSILE) ) && BULLET_DCT.length < MAX_SHOTS_ON_SCREEN)
			{
				var shot:SamusShot = new SamusShot(this,SamusShot.SHOT_TYPE_MISSILE);
				BULLET_DCT.addItem(shot);
				level.addToLevel(shot);
				decAmmo(SAMUS_MISSILE);
				shoot = true;
				if ((!onGround && upBtn) || (onGround && !lftBtn && !rhtBtn))
				{
					if (STILL_SHOOT_TMR.running)
						STILL_SHOOT_TMR.reset();
					STILL_SHOOT_TMR.start();
				}
				else
				{
					if (MOVE_SHOOT_TMR.running)
						MOVE_SHOOT_TMR.reset();
					MOVE_SHOOT_TMR.start();
				}
				checkState();
			}
		}
		private function moveShootTmrHandler(e:TimerEvent):void
		{
			MOVE_SHOOT_TMR.reset();
			shoot = false;
		}
		private function stillShootTmrHandler(e:TimerEvent):void
		{
			STILL_SHOOT_TMR.reset();
			shoot = false
		}
		private function stepTmrHandler(e:TimerEvent):void
		{
			STEP_TMR.reset();
			if (!muteStepSounds && skinFootStepsMakeSnd)
				SND_MNGR.playSound(SFX_SAMUS_STEP);
			if (onGround && vx != 0)
				STEP_TMR.start();
		}
		override public function pressDwnBtn():void
		{
			super.pressDwnBtn();
			if (cState == ST_PIPE || cState == ST_VINE)
				return;
			if (!classicMode)
			{
				if (cState == ST_STAND || cState == ST_WALK)
				{
					setState(ST_CROUCH);
					if (!skinCanMoveWhileCrouching)
						vx = 0;
					checkState();
				}
				else if ( upgradeIsActive(SAMUS_MORPH_BALL) && !skinDisableMorphBall && ( cState == ST_CROUCH || (!onGround && cState != ST_BALL) ) )
				{
					setPlayFrame(FL_BALL_START);
					setState(ST_BALL);
					morphBall = true;
					flipEnd();
					lState = ST_STAND;
					if (onGround)
					{
						ny -= BALL_DISPLACE_CROUCH;
						y -= BALL_DISPLACE_CROUCH;
						onGround = false;
					}
					SND_MNGR.playSound(SFX_SAMUS_MORPH_BALL);
				}
			}
			else if ( upgradeIsActive(SAMUS_MORPH_BALL) && cState != ST_BALL && onGround && !skinDisableMorphBall ) // classic mode
			{
				setPlayFrame(FL_BALL_START);
				setState(ST_BALL);
				morphBall = true;
				SND_MNGR.playSound(SFX_SAMUS_MORPH_BALL);
				ny -= BALL_DISPLACE;
				y -= BALL_DISPLACE;
				onGround = false;
			}
			if (cState == ST_BALL)
				changeBrickState();
		}
		override public function hitProj(proj:Projectile):void
		{
			if (level is TitleLevel)
				return;
			if (proj is SamusBomb && !(proj as SamusBomb).hitSamus && vy >= 0)
			{
				if (onGround)
					onGround = false;
				vy = -BOMB_BOOST;
				jumped = true;
				//updateLoc();
				//setHitPoints();
				(proj as SamusBomb).hitSamus = true;
				//level.checkCollisions(this);
			}
			if ( !(proj is FireBar && upgradeIsActive(SAMUS_VARIA_SUIT) ) )
				super.hitProj(proj);
		}
		override public function groundAbove(g:Ground):void
		{
			super.groundAbove(g);
			if (cState == ST_BALL)
				SND_MNGR.removeStoredSound(SND_GAME_HIT_CEILING);
		}

		override protected function bouncePit():void
		{
			if (!(level is CharacterSelect) )
				super.bouncePit();
		}

		override protected function enterPipeHorz():void
		{
			super.enterPipeHorz();
			mainAnimTmr = ANIM_MIN_FAST_TMR;
		}
		override protected function getMushroom():void
		{
			super.getMushroom();
			if (pState == 1)
				swapPsStart(pState,pState + 1);
		}
		override protected function getMushroomEnd():void
		{
			super.getMushroomEnd();
			changeBrickState();
		}
		override protected function takeDamageStart(source:LevObj):void
		{
			super.takeDamageStart(source);
			updDrops();
			updAmmoDisplay();
			takeNoDamage = true;
			disableInput = true;
			nonInteractive = true;
			if (onGround)
				vy = -DAMAGE_BOOST_VY;
			var dir:int = 1;
			if (source.nx > nx)
				dir = -1;
			damageBoostTmr.start();
			vx = DAMAGE_BOOST_VX*dir;
			if (cState != ST_BALL)
				setStopFrame(FL_JUMP);
			if ( !upgradeIsActive(SAMUS_MORPH_BALL) && (morphBall || cState == ST_BALL) )
				exitMorphBall(FL_JUMP,ST_JUMP);
			setState(ST_TAKE_DAMAGE);
			flickerStart();
			BTN_MNGR.relPlyrBtns();
			SND_MNGR.playSound(SN_TAKE_DAMAGE);
		}
		override public function flash(incCtr:Boolean = true):void
		{
			flashCtr++;
			var numColorRows:int;
			var rowOfs:int;
			var ptStar:String = PaletteTypes.FLASH_STAR;
			var ptPoweringUp:String = PaletteTypes.FLASH_POWERING_UP;
			var palette:Palette = palettePowerUp;
			if (starPwr)
				palette = paletteStar;
			else if (screwAttack)
				palette = paletteScrewAttack;
			numColorRows = palette.numRows - 1;
			rowOfs = 1;
			if ( flashCtr > numColorRows - 1 )
				flashCtr = 0;
			setFlashArr(defColors, palette, IND_DEF_COLORS_OUT, rowOfs + flashCtr);
			recolorBmps(flashArr[CustomMovieClip.IND_FLASH_ARR_PAL_IN], flashArr[CustomMovieClip.IND_FLASH_ARR_PAL_OUT], flashArr[CustomMovieClip.IND_FLASH_ARR_IN_COLOR], flashArr[CustomMovieClip.IND_FLASH_ARR_OUT_COLOR]);
		}
		override protected function takeDamageEnd():void
		{
			disableInput = false;
			nonInteractive = false;
			if (morphBall)
				setState(ST_BALL);
			else
				setState(ST_NEUTRAL);
			noDamageTmr.start();
			BTN_MNGR.sendPlayerBtns();
			checkState();
		}
		public static function skinSettingsWrite( shootHeightOffset:int = 0, canMoveWhileCrouching:Boolean = false, canWalkWhileShooting:Boolean = true,
			disableMorphBall:Boolean = false, footStepsMakeSnd:Boolean = true, shootSound:String = null, jumpSound:String = SoundNames.SFX_SAMUS_JUMP):Object
		{
			var obj:Object = new Object();
			obj.shootHeightOffset = shootHeightOffset;
			obj.canMoveWhileCrouching = canMoveWhileCrouching;
			obj.canWalkWhileShooting = canWalkWhileShooting;
			obj.disableMorphBall = disableMorphBall;
			obj.footStepsMakeSnd = footStepsMakeSnd;
			obj.shootSound = shootSound;
			obj.jumpSound = jumpSound;
			return obj;
		}

		private static function skinSettingsRead(samus:Samus):void
		{
			var obj:Object = samus.currentBmdSkin.specialSettings;
			if (obj == null)
			{
				skinSettingsSetDefaults(samus);
				return;
			}
			samus._skinShootHeightOffset = obj.shootHeightOffset;
			samus.skinCanMoveWhileCrouching = obj.canMoveWhileCrouching;
			samus.skinCanWalkWhileShooting = obj.canWalkWhileShooting;
			samus.skinDisableMorphBall = obj.disableMorphBall;
			samus.skinFootStepsMakeSnd = obj.footStepsMakeSnd;
			samus._skinShootSound = obj.shootSound;
			samus.skinJumpSound = obj.jumpSound;
		}

		private static function skinSettingsSetDefaults(samus:Samus):void
		{
			samus._skinShootHeightOffset = 0;
			samus.skinCanMoveWhileCrouching = false;
			samus.skinCanWalkWhileShooting = true;
			samus.skinDisableMorphBall = false;
			samus.skinFootStepsMakeSnd = true;
			samus._skinShootSound = null;
			samus.skinJumpSound = SoundNames.SFX_SAMUS_JUMP;
		}

		override public function getAxe(axe:BowserAxe):void
		{
			if (cState == ST_BALL)
				exitMorphBall(FL_JUMP,ST_JUMP);
			super.getAxe(axe);
		}

		override public function charSelectInitiate():void
		{
			super.charSelectInitiate();
			muteStepSounds = true;
		}

		override public function chooseCharacter():void
		{
			super.chooseCharacter();
			standFrame = FL_STAND_FRONT;
			setStopFrame(FL_STAND_FRONT);
			level.getGroundAt(nx - TILE_SIZE,ny).destroy();
			level.getGroundAt(nx,ny).destroy();
			level.getGroundAt(nx - TILE_SIZE,ny + TILE_SIZE).destroy();
			level.getGroundAt(nx,ny + TILE_SIZE).destroy();

			if (!Cheats.allGroundIsBricks)
			{
				(level.getGroundAt(nx - TILE_SIZE*2, ny) as SimpleGround).gotoAndStop(SimpleGround.BN_NORMAL + SimpleGround.topStr + SimpleGround.rhtStr);
				(level.getGroundAt(nx - TILE_SIZE*2, ny + TILE_SIZE) as SimpleGround).gotoAndStop(SimpleGround.BN_NORMAL + SimpleGround.midStr + SimpleGround.rhtStr);

				(level.getGroundAt(nx + TILE_SIZE, ny) as SimpleGround).gotoAndStop(SimpleGround.BN_NORMAL + SimpleGround.topStr + SimpleGround.lftStr);
				(level.getGroundAt(nx + TILE_SIZE, ny + TILE_SIZE) as SimpleGround).gotoAndStop(SimpleGround.BN_NORMAL + SimpleGround.midStr + SimpleGround.lftStr);
			}

			charSelPlatform = new Platform(null,Platform.PT_CONSTANT_FALL,4);
			charSelPlatform.x = nx;
			charSelPlatform.y = ny;
			defyGrav = true;
			level.addToLevel(charSelPlatform);
		}
		override public function fallenCharSelScrn():void
		{
			super.fallenCharSelScrn();
			cancelCheckState = true;
			setStopFrame(FL_CROUCH);
		}
		override public function initiateDeath(source:LevObj = null):void
		{
			super.initiateDeath(source);
			var dif:int = GameSettings.difficulty;
			if (dif != Difficulties.VERY_EASY && dif != Difficulties.EASY)
				STAT_MNGR.changeStat(STAT_MNGR.STAT_NUM_SAMUS_MISSILES,-STAT_MNGR.NUM_SAMUS_MISSILES_MAX);
		}
		override protected function initiateNormalDeath(source:LevObj = null):void
		{
			super.initiateNormalDeath(source);
			flickerStop();
			stopUpdate = true;
			stopAnim = true;
			stopHit = true;
			visible = false;
//			if (playerGraphic)
//				playerGraphic.visible = false;
			level.addToLevel(new SamusGuts(this,1));
			level.addToLevel(new SamusGuts(this,2));
			level.addToLevel(new SamusGuts(this,3));
			level.addToLevel(new SamusGuts(this,4));
			level.addToLevel(new SamusGuts(this,5));
			level.addToLevel(new SamusGuts(this,6));
			EVENT_MNGR.startDieTmr(DIE_TMR_DEL_NORMAL);
			SND_MNGR.playSound(SFX_SAMUS_DIE);
		}
		override protected function initiatePitDeath():void
		{
			_dieTmrDel = DIE_TMR_DEL_PIT;
			super.initiatePitDeath();
			SND_MNGR.playSound(SFX_SAMUS_DIE);
		}
		override public function slideDownFlagPole():void
		{
			super.slideDownFlagPole();
//			setStopFrame(FL_SLIDE);
			setStopFrame(FL_CLIMB_START);
			nx = level.flagPole.hMidX - FLAG_POLE_OFFSET;
			shoot = false;
			if (screwAttack)
				endScrewAttack();
		}

		private function endScrewAttack():void
		{
			screwAttack = false;
			if (!starPwr)
				endReplaceColor();
		}

		override public function stopFlagPoleSlide():void
		{
			super.stopFlagPoleSlide();
			if (onGround)
			{
				setState(ST_STAND);
				setStopFrame(standFrame);
			}
			else
			{
				setState(ST_JUMP);
				setPlayFrame(FL_FLIP_START);
				flip = true;
				flipStartPos = GLOB_STG_BOT;
				jumped = true;
			}
		}
		override protected function changeBrickState():void
		{
			if (cState == ST_BALL)
				brickState = BRICK_NONE;
			else
				brickState = BRICK_BOUNCER;
		}
		override public function activateWatchModeEnterPipe():void
		{
			super.activateWatchModeEnterPipe();
			muteStepSounds = true;
		}
		override protected function removeListeners():void
		{
			super.removeListeners();
			MOVE_SHOOT_TMR.removeEventListener(TimerEvent.TIMER_COMPLETE,moveShootTmrHandler);
			STILL_SHOOT_TMR.removeEventListener(TimerEvent.TIMER_COMPLETE,stillShootTmrHandler);
			STEP_TMR.removeEventListener(TimerEvent.TIMER_COMPLETE,stepTmrHandler);
			damageBoostTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,damageBoostTmrHandler);

		}
		override protected function reattachLsrs():void
		{
			super.reattachLsrs();
			MOVE_SHOOT_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,moveShootTmrHandler,false,0,true);
			STILL_SHOOT_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,stillShootTmrHandler,false,0,true);
			STEP_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,stepTmrHandler,false,0,true);
			damageBoostTmr.addEventListener(TimerEvent.TIMER_COMPLETE,damageBoostTmrHandler,false,0,true);
		}

		override protected function getAllDroppedUpgrades():void
		{
			hitPickup(new SamusPickup(SAMUS_MISSILE_AMMO), false);
		}

		override public function checkFrame():void
		{
			var cf:int = currentFrame;
			var cl:String = currentLabel;
			if (morphBall && cf == getLabNum(FL_BALL_END) + 1)
				setPlayFrame(FL_BALL_START);
			else if (cState == ST_JUMP && cf == getLabNum(FL_FLIP_END) + 1)
				setPlayFrame(FL_FLIP_START);
			else if ((cState == ST_WALK || cState == ST_PIPE)
				&& (cf == getLabNum(FL_WALK_END) + 1 || cf == getLabNum(FL_WALK_SHOOT_END) + 1))
			{
				if (!shoot)
					setPlayFrame(FL_WALK_START);
				else
					setPlayFrame(FL_WALK_SHOOT_START);
			}
			else if (cState == ST_WALK_UP && (cf == getLabNum(FL_WALK_UP_END) + 1 || cf == getLabNum(FL_WALK_UP_SHOOT_END) + 1))
			{
				if (!shoot)
					setPlayFrame(FL_WALK_UP_START);
				else
					setPlayFrame(FL_WALK_UP_SHOOT_START);
			}
			else if (cState == ST_VINE && cf == getLabNum(FL_CLIMB_END) + 1)
				setPlayFrame(FL_CLIMB_START);
			super.checkFrame();
		}
		override public function cleanUp():void
		{
			super.cleanUp();
			if (dead)
				changeSuitColor();
			tsTxt.UpdAmmoIcon(false);
			tsTxt.UpdAmmoText(false);
		}

		override protected function playDefaultPickupSoundEffect():void
		{
			SND_MNGR.playSound(SoundNames.SFX_SAMUS_GET_ENERGY);
		}

		public function get classicWeapon():String
		{
			switch(GameSettings.samusWeapon)
			{
				case SamusWeapon.IceBeam:
					return SAMUS_ICE_BEAM;
				case SamusWeapon.WaveBeam:
					return SAMUS_WAVE_BEAM;
				default:
					return SAMUS_WAVE_BEAM;
			}
		}
	}
}
