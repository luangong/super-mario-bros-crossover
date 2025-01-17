package com.smbc.characters
{

	import com.explodingRabbit.cross.gameplay.statusEffects.StatFxFlash;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatFxStop;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatusProperty;
	import com.explodingRabbit.utils.CustomDictionary;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.data.AnimationTimers;
	import com.smbc.data.CharacterInfo;
	import com.smbc.data.Cheats;
	import com.smbc.data.DamageValue;
	import com.smbc.data.GameSettings;
	import com.smbc.data.MovieClipInfo;
	import com.smbc.data.MusicType;
	import com.smbc.data.PaletteTypes;
	import com.smbc.data.PickupInfo;
	import com.smbc.data.SoundNames;
	import com.smbc.enemies.Enemy;
	import com.smbc.enums.RyuSimonThrowType;
	import com.smbc.enums.SimonSpecialWeapon;
	import com.smbc.events.CustomEvents;
	import com.smbc.graphics.BmdSkinCont;
	import com.smbc.graphics.HudAlwaysOnTop;
	import com.smbc.graphics.SimonSimpleGraphics;
	import com.smbc.graphics.SimonWhip;
	import com.smbc.graphics.TopScreenText;
	import com.smbc.graphics.fontChars.FontCharSimon;
	import com.smbc.ground.Brick;
	import com.smbc.ground.Ground;
	import com.smbc.ground.SpringGreen;
	import com.smbc.ground.SpringRed;
	import com.smbc.interfaces.IAttackable;
	import com.smbc.level.LevelForeground;
	import com.smbc.level.TitleLevel;
	import com.smbc.main.LevObj;
	import com.smbc.managers.GameStateManager;
	import com.smbc.pickups.Pickup;
	import com.smbc.pickups.SimonPickup;
	import com.smbc.pickups.Vine;
	import com.smbc.projectiles.*;
	import com.smbc.sound.MusicInfo;
	import com.smbc.text.TextFieldContainer;
	import com.smbc.utils.CharacterSequencer;
	import com.smbc.utils.GameLoopTimer;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class Simon extends Character
	{
		public static const CHAR_NAME:String = CharacterInfo.Simon[ CharacterInfo.IND_CHAR_NAME ];
		public static const CHAR_NAME_CAPS:String = CharacterInfo.Simon[ CharacterInfo.IND_CHAR_NAME_CAPS ];
		public static const CHAR_NAME_TEXT:String = CharacterInfo.Simon[ CharacterInfo.IND_CHAR_NAME_MENUS ];
		public static const CHAR_NUM:int = CharacterInfo.Simon[ CharacterInfo.IND_CHAR_NUM ];
		public static const PAL_ORDER_ARR:Array = [ PaletteTypes.FLASH_POWERING_UP, PaletteTypes.FLASH_STAR ];
		public static const SIMON_AXE:String = PickupInfo.SIMON_AXE;
		public static const SIMON_STOP_WATCH:String = PickupInfo.SIMON_STOP_WATCH;
		public static const SIMON_CROSS:String = PickupInfo.SIMON_CROSS;
		public static const SIMON_DOUBLE:String = PickupInfo.SIMON_DOUBLE;
		public static const SIMON_DAGGER:String = PickupInfo.SIMON_DAGGER;
		public static const SIMON_HOLY_WATER:String = PickupInfo.SIMON_HOLY_WATER;
		public static const SIMON_TRIPLE:String = PickupInfo.SIMON_TRIPLE;
		public static const SIMON_WHIP_LEVEL_2:String = PickupInfo.SIMON_WHIP_LEVEL_2;
		public static const SIMON_WHIP_LEVEL_3:String = PickupInfo.SIMON_WHIP_LEVEL_3;
		public static const SIMON_HEART_BIG:String = PickupInfo.SIMON_HEART_BIG;
		public static const SIMON_HEART_SMALL:String = PickupInfo.SIMON_HEART_SMALL;
		public static const OBTAINABLE_UPGRADES_ARR:Array = [
			[ SIMON_WHIP_LEVEL_3 ],
			[ SIMON_DAGGER, SIMON_HOLY_WATER, SIMON_STOP_WATCH, SIMON_CROSS, SIMON_AXE, SIMON_DOUBLE]
		];
//			[ SIMON_WHIP_LEVEL_3 ],
//			[ SIMON_DAGGER, SIMON_HOLY_WATER, SIMON_STOP_WATCH ],
//			[ SIMON_DOUBLE, SIMON_CROSS, SIMON_AXE ],
//			[ SIMON_TRIPLE ]

		override public function get classicGetMushroomUpgrades():Vector.<String>
		{ return Vector.<String>([ SIMON_WHIP_LEVEL_2, SIMON_DOUBLE ]); }

		override public function get classicGetFireFlowerUpgrades():Vector.<String>
		{ return Vector.<String>([ SIMON_WHIP_LEVEL_3, SIMON_TRIPLE ]); }

		public static const MUSHROOM_UPGRADES:Array = [ SIMON_WHIP_LEVEL_2 ];
		public static const RESTORABLE_UPGRADES:Array = [ ];
		public static const NEVER_LOSE_UPGRADES:Array = [ SIMON_DAGGER, SIMON_HOLY_WATER, SIMON_STOP_WATCH, SIMON_CROSS, SIMON_AXE, SIMON_DOUBLE, SIMON_TRIPLE ];
		public static const START_WITH_UPGRADES:Array = [ SIMON_DAGGER ];
		public static const SINGLE_UPGRADES_ARR:Array = [ SIMON_DAGGER, SIMON_HOLY_WATER, SIMON_STOP_WATCH, SIMON_CROSS, SIMON_AXE ];
		public static const REPLACEABLE_UPGRADES_ARR:Array = [ [ SIMON_DOUBLE, SIMON_TRIPLE ] ];
//			[ SIMON_DOUBLE, SIMON_TRIPLE ], [ SIMON_DAGGER, SIMON_DOUBLE ], [ SIMON_HOLY_WATER, SIMON_DOUBLE ],
//			[ SIMON_CROSS, SIMON_DOUBLE ], [ SIMON_AXE, SIMON_DOUBLE ] ];
		public static const TITLE_SCREEN_UPGRADES:Array = [ MUSHROOM, SIMON_WHIP_LEVEL_2, SIMON_AXE, SIMON_DOUBLE, SIMON_TRIPLE ];
		public static const ICON_ORDER_ARR:Array = [ SIMON_WHIP_LEVEL_3, SIMON_DOUBLE, SIMON_TRIPLE, SIMON_DAGGER, SIMON_HOLY_WATER, SIMON_STOP_WATCH, SIMON_CROSS, SIMON_AXE ];
		private static const AMMO_TYPE_HEARTS:String = "hearts";
		private static const CLASSIC_DEFAULT_AMMO:int = 10;
		public static const AMMO_ARR:Array = [ [ AMMO_TYPE_HEARTS, 15, 99 ] ];
		public static const AMMO_DEPLETION_ARR:Array = [ [ SIMON_DAGGER, 1 ], [ SIMON_HOLY_WATER, 1 ], [ SIMON_STOP_WATCH, 5 ], [ SIMON_CROSS, 2], [SIMON_AXE, 1 ] ];
		public static const DROP_ARR:Array = [ [ 0, SIMON_HEART_SMALL ], [ .8, SIMON_HEART_BIG ] ];
		public static const AMMO_DCT:CustomDictionary = new CustomDictionary();
		public static const AMMO_DEPLETION_DCT:CustomDictionary = new CustomDictionary();
		public static const WIN_SONG_DUR:int = 4080;
		public static const CHAR_SEL_END_DUR:int = 2000;
		public static const SUFFIX_VEC:Vector.<String> = Vector.<String>(["","",""]);
		public static const IND_CI_Simon:int = 1;
		public static const IND_CI_SimonWhipMid:int = 5;
		public static const IND_CI_SimonWhip:int = 6;
		private static const IND_SKIN_SETTINGS_ARR_WHIP_HANG:int = 0;
		private static const IND_SKIN_SETTINGS_ARR_WHIP_HANG_CROUCH:int = 1;
		private static const IND_SKIN_SETTINGS_ARR_WHIP_WAVE:int = 2;
		private static const IND_SKIN_SETTINGS_ARR_WHIP_WAVE_CROUCH:int = 3;
		private static const IND_SKIN_SETTINGS_ARR_WHIP_STRAIGHT:int = 4;
		private static const IND_SKIN_SETTINGS_ARR_WHIP_STRAIGHT_CROUCH:int = 5;
		public static var characterSkinsVec:Vector.<BmdSkinCont>;
		private static const DEF_WHIP_POS_DCT:CustomDictionary = new CustomDictionary();
		private static const DV_SIMON_FLAME_WHIP:int = DamageValue.SIMON_FLAME_WHIP;
		private static const DV_SIMON_MORNING_STAR:int = DamageValue.SIMON_MORNING_STAR;
		private static const DV_SIMON_SHORT_WHIP:int = DamageValue.SIMON_SHORT_WHIP;
		public static const JUMP_TYPE_EASY:String = "easy";
		public static const JUMP_TYPE_HARD:String = "hard";
		public static const JUMP_TYPE_CLASSIC:String = "classic";
		private static const DIE_TMR_DEL_NORMAL:int = 1700;
		private static const DIE_TMR_DEL_NORMAL_MAX:int = 6000;
		private static const DIE_TMR_DEL_PIT:int = 2500;
		private static const REPL_COLOR_1_1:uint = 2; // peach
		private static const REPL_COLOR_2_1:uint = 0xFF522100; // dark brown
		private static const REPL_COLOR_3_1:uint = 0xFFE79C21; // yellow
		private static const REPL_COLOR_1_2:uint = REPL_COLOR_1_1;
		private static const REPL_COLOR_2_2:uint = 0xFF881400;
		private static const REPL_COLOR_3_2:uint = 0xFFFF9229;
		private static const REPL_COLOR_1_3:uint = REPL_COLOR_1_1;
		private static const REPL_COLOR_2_3:uint = 0xFF000000;
		private static const REPL_COLOR_3_3:uint = 0xFFDE3B3C;
		private static const FLASH_COLOR_1_1:uint = 0xFFFFE7E7; // light pink
		private static const FLASH_COLOR_2_1:uint = 0xFFB70000; // dark red
		private static const FLASH_COLOR_3_1:uint = 0xFFF0F000; // yellow
		private static const FLASH_COLOR_1_2:uint = 0xFFFFFFFF; // white
		private static const FLASH_COLOR_2_2:uint = 0xFF005D02; // dark green
		private static const FLASH_COLOR_3_2:uint = 0XFF00CCFF; // bright cyan
		private static const FLASH_COLOR_1_3:uint = 0xFFCDC3FF; // light purple
		private static const FLASH_COLOR_2_3:uint = 0xFF004557; // dark cyan
		private static const FLASH_COLOR_3_3:uint = 0xFFCB3DFF; // bright purple
		private static const SECONDS_LEFT_SND:String = SoundNames.BGM_SIMON_SECONDS_LEFT;
		private static const SN_GET_HEART:String = SoundNames.SFX_SIMON_GET_HEART;
		private static const SN_GET_WEAPON:String = SoundNames.SFX_SIMON_GET_WEAPON;
		private static const SND_MUSIC_WIN:String = SoundNames.MFX_SIMON_WIN;
		private static const FL_AMMO_ICON:String = "heartsAmmo";
		private static const FL_ATTACK_START:String = "attackStart";
		private static const FL_ATTACK_2:String = "attack-2";
		private static const FL_ATTACK_END:String = "attackEnd";
		private static const FL_CLIMB_START:String = "climbStart";
		private static const FL_CLIMB_END:String = "climbEnd";
		private static const FL_CROUCH:String = "crouch";
		private static const FL_CROUCH_ATTACK_START:String = "crouchAttackStart";
		private static const FL_CROUCH_ATTACK_2:String = "crouchAttack-2";
		private static const FL_CROUCH_ATTACK_END:String = "crouchAttackEnd";
		private static const FL_CROUCH_THROW_START:String = "crouchThrowStart";
		private static const FL_CROUCH_THROW_2:String = "crouchThrow-2";
		public static const FL_CROUCH_THROW_END:String = "crouchThrowEnd";
		private static const FL_TAKE_DAMAGE:String = "takeDamage";
		private static const FL_DIE_START:String = "dieStart";
		private static const FL_DIE_END:String = "dieEnd";
		private static const FL_THROW_START:String = "throwStart";
		private static const FL_THROW_2:String = "throw-2";
		public static const FL_THROW_END:String = "throwEnd";
		private static const FL_JUMP:String = "jump";
		private static const FL_JUMP_FALL:String = "fall";
		private static const FL_SLIDE:String = "slide";
		private static const FL_STAND:String = "stand";
		private static const FL_WALK_START:String = "walkStart";
		private static const FL_WALK_END:String = "walkEnd";
		public static const FL_WHIP_HANG:String = "hang";
		public static const FL_WHIP_WAVE:String = "wave";
		public static const FL_WHIP_STRAIGHT:String = "straight";
		private static const WHIP_REMAIN_ARR:Array = [
			FL_ATTACK_START, FL_ATTACK_2, FL_ATTACK_END, FL_CROUCH_ATTACK_START,
			FL_CROUCH_ATTACK_2, FL_CROUCH_ATTACK_END
		];
		private static const THROW_ARR:Array = [
			FL_THROW_START, FL_THROW_2, FL_THROW_END, FL_CROUCH_THROW_START,
			FL_CROUCH_THROW_2, FL_CROUCH_THROW_END
		];
		private const CHOOSE_CHAR_SEQ:Array = [
			[ 1, pressAtkBtn ], [ 500, pressDwnBtn ], [ 100, pressAtkBtn ], [ 500, relDwnBtn ],
			[ 100, pressRhtBtn ], [ 500, relRhtBtn ]
		];
		private static const MFX_SIMON_DIE:String = SoundNames.MFX_SIMON_DIE;
//		private static const SFX_SIMON_FLAME_WHIP:String = SoundNames.SFX_SIMON_FLAME_WHIP;
		private static const SFX_SIMON_HIT:String = SoundNames.SFX_SIMON_TAKE_DAMAGE;
		private static const SFX_SIMON_HIT_ENEMY_NORMAL:String = SoundNames.SFX_SIMON_HIT_ENEMY;
		private static const SFX_SIMON_HIT_ENEMY_C2:String = SoundNames.SFX_SIMON_HIT_ENEMY_C2;
		private static const SFX_SIMON_WHIP:String = SoundNames.SFX_SIMON_WHIP;
		private static const WALK_SPEED:int = 150;
		private static const IND_HIT_BOX_VEC_LEATHER_WHIP:int = 0;
		private static const IND_HIT_BOX_VEC_CHAIN_WHIP:int = 1;
		private static const IND_HIT_BOX_VEC_FLAME_WHIP:int = 2;
		private static const IND_HIT_BOX_VEC_STAND:int = 0;
		private static const IND_HIT_BOX_VEC_CROUCH:int = 1;
		private static const HIT_BOX_VEC:Vector.<Array> = Vector.<Array>([
			[ new Rectangle(15,-48,57,14), new Rectangle(15,-30,57,14) ], // leather whip
			[ new Rectangle(15,-48,57,14), new Rectangle(15,-30,57,14) ], // chain whip
			[ new Rectangle(15,-48,87,14), new Rectangle(15,-30,87,14) ] // flame whip
		]);
		private var canDoubleJump:Boolean;
		private static const DAMAGE_BOOST_VY:int = 300;
		private static const DAMAGE_BOOST_GRAVITY:int = 300;
		private static const NUM_KNEEL_FRAMES:int = 3;
		private var frameCtr:int;
		private static const FLAG_POLE_OFFSET:int = 0; //20;
		private static const SMALL_HEART_VALUE:int = 1;
		private static const BIG_HEART_VALUE:int = 5;
		private var attackedInAir:Boolean;
		private var justCrouched:Boolean;
		private const MAIN_ANIM_TMR:CustomTimer = AnimationTimers.ANIM_VERY_SLOW_TMR;
		//private const VINE_ANIM_TMR:CustomTimer = AnimationTimers.ANIM_SLOW_TMR;
		private const HIT_DIST_OVER_OFFSET:int = 30;
		private const NSF_STR_DIE:String = MusicInfo.CHAR_STR_SIMON + MusicInfo.TYPE_DIE;
		private static var _classicMode:Boolean;
		private var whip:SimonWhip;
		public var whipLevel:int;
		private var whipDmg:int;
		private var attackAnimTmr:GameLoopTimer = new GameLoopTimer(115);
		private static var skinSettingsNestedArr:Array = [];
		private var curSubWeapon:String;
		private static const ATTACK_STATE_FRAME_DCT:CustomDictionary = new CustomDictionary();
		public static const STOP_WATCH_DURATION:int = 3000;
		private var stopWatchTmr:GameLoopTimer = new GameLoopTimer(STOP_WATCH_DURATION,1);
		public static const DEFAULT_PROPS_DCT:CustomDictionary = new CustomDictionary();
		public static const STOP_WATCH_STRENGTH:int = 7;
		public static const HIT_DEL:int = 400;
		public var launchedFromGreenSpring:Boolean;

		public static const SKIN_PREVIEW_SIZE:Point = new Point(23,34);
		public static const SKIN_ORDER:Array = [
			SKIN_SIMON_NES,
			SKIN_SIMON_SNES,
			SKIN_SIMON_CV4_SNES,
			SKIN_SIMON_CV2_NES,
			SKIN_SIMON_X1,
			SKIN_SIMON_ATARI,
			SKIN_TREVOR_NES,
			SKIN_TREVOR_SNES,
			SKIN_TREVOR_GB,
			SKIN_TREVOR_FAKE_NES,
			SKIN_TREVOR_FAKE_SNES,
			SKIN_RICHTER_NES,
			SKIN_RICHTER_SNES,
			SKIN_CHRISTOPHER,
			SKIN_SOLEIYU,
			SKIN_SONIA,
			SKIN_WHIP_SKELETON,
			SKIN_ALEX_NES,
			SKIN_KUNIO_SNES
		];

		public static const SKIN_SIMON_NES:int = 0;
		public static const SKIN_SIMON_SNES:int = 1;
		public static const SKIN_CHRISTOPHER:int = 2;
		public static const SKIN_TREVOR_NES:int = 3;
		public static const SKIN_TREVOR_SNES:int = 4;
		public static const SKIN_TREVOR_GB:int = 5;
		public static const SKIN_SIMON_CV2_NES:int = 6;
		public static const SKIN_SIMON_CV4_SNES:int = 7;
		public static const SKIN_WHIP_SKELETON:int = 8;
		public static const SKIN_SIMON_ATARI:int = 9;
		public static const SKIN_SIMON_X1:int = 10;
		public static const SKIN_RICHTER_NES:int = 11;
		public static const SKIN_ALEX_NES:int = 12;
		public static const SKIN_TREVOR_FAKE_NES:int = 13;
		public static const SKIN_TREVOR_FAKE_SNES:int = 14;
		public static const SKIN_RICHTER_SNES:int = 15;
		public static const SKIN_SONIA:int = 16;
		public static const SKIN_KUNIO_SNES:int = 17;
		public static const SKIN_SOLEIYU:int = 18;

		public static const SPECIAL_SKIN_NUMBER:int = SKIN_SIMON_X1;
		public static const ATARI_SKIN_NUMBER:int = SKIN_SIMON_ATARI;
		private var lastThrowType:RyuSimonThrowType = RyuSimonThrowType.Default;

		private static const FLASHING_PROP:StatusProperty = new StatusProperty(PR_FLASH_AGG, 0, new StatFxFlash(null,AnimationTimers.DEL_FAST,HIT_DEL));

		public function Simon()
		{
			super();
			poorBowserFighter = true;
			if (!DEFAULT_PROPS_DCT.length)
			{
				DEFAULT_PROPS_DCT.addItem( new StatusProperty(PR_STOP_AGG, 0, new StatFxStop(null,HIT_DEL) ) );
			}
			for each (var prop:StatusProperty in DEFAULT_PROPS_DCT)
			{
				addProperty(prop);
			}
			charNum = CHAR_NUM;
			_canGetAmmoFromCoinBlocks = true;
			_canGetAmmoFromBricks = true;
			mainAnimTmr = MAIN_ANIM_TMR;
			suffixVec = SUFFIX_VEC.concat();
			_charName = CHAR_NAME;
			_charNameCaps = CHAR_NAME_CAPS;
			_charNameTxt = CHAR_NAME_TEXT;
			_dieTmrDel = DIE_TMR_DEL_NORMAL;
			_secondsLeftSnd = SECONDS_LEFT_SND;
			_sndWinMusic = SND_MUSIC_WIN;
			winSongDur = WIN_SONG_DUR;
			_usesHorzObjs = true;
			_secondsLeftSndIsBgm = true;
			walkStartLab = FL_WALK_START;
			walkEndLab = FL_WALK_END;
			var arr:Array = WHIP_REMAIN_ARR.concat(THROW_ARR);
			for each (var fLab:String in arr)
			{
				ATTACK_STATE_FRAME_DCT.addItem(fLab);
			}
		}
		override protected function setObjsToRemoveFromFrames():void
		{
			super.setObjsToRemoveFromFrames();
			removeObjsFromFrames(whip,WHIP_REMAIN_ARR,true);
		}
		override protected function mcReplacePrep(thisMc:MovieClip):void
		{
			for (var i:int = 0; i < thisMc.numChildren; i++)
			{
				var dObj:DisplayObject = thisMc.getChildAt(i);
				if (dObj is MovieClip)
				{
					var mc:MovieClip = dObj as MovieClip;
					var whipMc:MovieClip = new MovieClipInfo.SimonWhipMc();
					if (mc.totalFrames == whipMc.totalFrames)
					{
						whip = new SimonWhip( this, whipMc );
						mcReplaceArr = [ mc, whip ];
					}
				}
			}
		}
		protected function setWhipLevel():void
		{
			if ( upgradeIsActive( SIMON_WHIP_LEVEL_3 ) )
			{
				whipLevel = 3;
				whipDmg = DamageValue.SIMON_FLAME_WHIP;
			}
			else if ( upgradeIsActive( SIMON_WHIP_LEVEL_2) )
			{
				whipLevel = 2;
				whipDmg = DamageValue.SIMON_MORNING_STAR;
			}
			else
			{
				whipLevel = 1;
				whipDmg = DamageValue.SIMON_SHORT_WHIP;
			}
		}
		private function setCurSubWeapon():void
		{
			if ( upgradeIsActive(SIMON_AXE) )
				curSubWeapon = SIMON_AXE;
			else if ( upgradeIsActive(SIMON_CROSS) )
				curSubWeapon = SIMON_CROSS;
			else if ( upgradeIsActive(SIMON_DAGGER) )
				curSubWeapon = SIMON_DAGGER;
			else if ( upgradeIsActive(SIMON_HOLY_WATER) )
				curSubWeapon = SIMON_HOLY_WATER;
			else if ( upgradeIsActive(SIMON_STOP_WATCH) )
				curSubWeapon = SIMON_STOP_WATCH;
			else
				curSubWeapon = null;
		}
		override public function setCurrentBmdSkin(bmc:BmdSkinCont, characterInitiating:Boolean = false):void
		{
			super.setCurrentBmdSkin(bmc);
			if (!DEF_WHIP_POS_DCT.length)
				setUpDefWhipPosArr();
			var dct:Dictionary = skinSettingsNestedArr[skinNum];
			var cf:int = currentFrame;
			for each (var fLab:String in WHIP_REMAIN_ARR)
			{
				setChildPoperty(whip,"x",DEF_WHIP_POS_DCT[fLab].x + dct[fLab].x,fLab);
				setChildPoperty(whip,"y",DEF_WHIP_POS_DCT[fLab].y + dct[fLab].y,fLab);
			}
			gotoAndStop(cf);

//			castlevania 2 flashing
			if (skinNum == SKIN_SIMON_CV2_NES)
			{
				addProperty(FLASHING_PROP);
				DEFAULT_PROPS_DCT.addItem(FLASHING_PROP);
			}
			else
			{
				removeProperty(PR_FLASH_AGG);
				DEFAULT_PROPS_DCT.removeItem(FLASHING_PROP);
			}

		}

		private function setUpDefWhipPosArr():void
		{
			var cf:int = currentFrame;
			for each (var fLab:String in WHIP_REMAIN_ARR)
			{
				var arr:Array = [];
				gotoAndStop(fLab);
				DEF_WHIP_POS_DCT.addItem(fLab, new Point(whip.x,whip.y) );
			}
			gotoAndStop(cf);
		}

	// SETSTATS sets statistics and initializes character
		override public function setStats():void
		{
			jumpPwr = 565;
			gravity = 1500;
			if (level.waterLevel)
			{
				defGravity = gravity;
				gravity = 750;
				defGravityWater = gravity;
			}
			defSpringPwr = 500;
			boostSpringPwr = 1000;
			xSpeed = WALK_SPEED;
			numParFrames = 0;
			pState2 = true;
			vxMax = WALK_SPEED;
			vxMaxDef = vxMax;
			vyMaxPsv = 2000;
			super.setStats();
			tsTxt.UpdAmmoIcon(true, FL_AMMO_ICON);
			setAmmo(AMMO_TYPE_HEARTS,getAmmo(AMMO_TYPE_HEARTS) );
			attackAnimTmr.addEventListener(TimerEvent.TIMER,attackAnimTmrHandler,false,0,true);
			addTmr( stopWatchTmr );
			stopWatchTmr.addEventListener(TimerEvent.TIMER_COMPLETE,stopWatchTmrHandler,false,0,true);
		}

		protected function stopWatchTmrHandler(event:Event):void
		{
			EVENT_MNGR.dispatchEvent( new Event(CustomEvents.STOP_ALL_ENEMIES_PROP_DEACTIVATE) );
			stopWatchTmr.stop();
			removeProperty(PR_STOP_ALL_ENEMIES_ACTIVE_AGG);
		}
		override protected function startAndDamageFcts(start:Boolean = false):void
		{
			super.startAndDamageFcts(start);
			if (GameSettings.classicMode && start && !upgradeIsActive(classicStartWeapon) && !(level is TitleLevel) )
				STAT_MNGR.addCharUpgrade(charNum, classicStartWeapon);
			setWhipLevel();
			setCurSubWeapon();
		}

		private function getClassicWeapon(weapon:SimonSpecialWeapon):String
		{
			switch(weapon)
			{
				case SimonSpecialWeapon.Axe:
					return SIMON_AXE
				case SimonSpecialWeapon.Cross:
					return SIMON_CROSS;
				case SimonSpecialWeapon.Dagger:
					return SIMON_DAGGER
				case SimonSpecialWeapon.HolyWater:
					return SIMON_HOLY_WATER;
				case SimonSpecialWeapon.Stopwatch:
					return SIMON_STOP_WATCH;
				default:
					return SIMON_AXE;
			}
		}

		private function get classicStartWeapon():String
		{
			return getClassicWeapon(GameSettings.simonStartWeapon);
		}

		private function get classicExtraWeapon():String
		{
			return getClassicWeapon(GameSettings.simonExtraWeapon);
		}

		protected function attackAnimTmrHandler(event:Event):void
		{
			var found:Boolean;
			for each (var fLab:String in ATTACK_STATE_FRAME_DCT)
			{
				if (currentFrameLabel == fLab)
				{
					found = true;
					break;
				}
			}
			if (!found)
				finishAttack();
			else
			{
				gotoAndStop(currentFrame + 1);
				checkFrame();
			}
		}
		override public function forceWaterStats():void
		{
			defGravity = gravity;
			gravity = 750;
			defGravityWater = gravity;
			super.forceWaterStats();
		}
		override public function forceNonwaterStats():void
		{
			gravity = 1500;
			super.forceNonwaterStats();
		}
		override protected function movePlayer():void
		{
			if (cState == ST_TAKE_DAMAGE)
				return;
			if (onGround || (!classicMode) )
			{
				if ( (cState == ST_ATTACK && onGround) || cState == ST_CROUCH)
				{
					vx = 0;
					return;
				}
				if (rhtBtn && !lftBtn && !wallOnRight)
				{
					if (justCrouched)
					{
						justCrouched = false;
						return;
					}
					if (stuckInWall)
						return;
					if (cState == ST_VINE)
					{
						if (exitVine)
							getOffVine();
						else
							return;
					}
					vx = xSpeed;
					if (onGround)
						this.scaleX = 1;
				}
				else if (lftBtn && !rhtBtn && !wallOnLeft)
				{
					if (justCrouched)
					{
						justCrouched = false;
						return;
					}
					if (stuckInWall)
						return;
					if (cState == ST_VINE)
					{
						if (exitVine)
							getOffVine();
						else
							return;
					}
					vx = -xSpeed;
					if (onGround)
						this.scaleX = -1;
				}
				else if (lftBtn && rhtBtn && cState != ST_DIE)
					vx = 0;
				else if (!lftBtn && !rhtBtn && cState != ST_DIE)
					vx = 0;
				if (onGround && vx == 0)
				{
					if (lftBtn && wallOnLeft)
						scaleX = -1;
					else if (rhtBtn && wallOnRight)
						scaleX = 1;
				}
			}
			else
			{
				if (cState == ST_VINE)
				{
					if (rhtBtn && !lftBtn)
					{
						if (exitVine)
							getOffVine();
						else
							return;
						vx = xSpeed;
						this.scaleX = 1;
					}
					else if (lftBtn && !rhtBtn)
					{
						if (exitVine)
							getOffVine();
						else
							return;
						vx = -xSpeed;
						this.scaleX = -1;
					}
				}
				if ( classicMode || cState == ST_DIE)
				{
					if (lastVX != 0 && !wallOnLeft && !wallOnRight)
					{
						vx = lastVX;
						lastVX = 0;
					}
				}
				//if (!jumped) vx = 0;
			}
		}
		// Public Methods:
		// CHECKSTATE
		override protected function checkState():void
		{
			if (cState == ST_VINE)
			{
				checkVineBtns();
				checkVinePosition();
				return;
			}
			else if (cState == ST_TAKE_DAMAGE)
				return;
			if (onGround)
			{
				lastVX = 0;
				jumped = false;
				attackedInAir = false;
				canDoubleJump = true;
				if (cState != ST_ATTACK && cState != ST_DIE)
				{
					if (dwnBtn)
					{
						setState(ST_CROUCH);
						setStopFrame(FL_CROUCH);
						justCrouched = true;
					}
					else if (vx == 0)
					{
						setState(ST_STAND);
						setStopFrame(FL_STAND );
					}
					else
					{
						setState(ST_WALK);
						if (lState != ST_WALK) setPlayFrame(FL_WALK_START);
					}
				}
				else if (cState == ST_DIE && currentLabel == convLab(FL_TAKE_DAMAGE))
				{
					lockFrame = false;
					setStopFrame(FL_DIE_START);
					lockFrame = true;
					vx = 0;
				}
			}
			else if (cState != ST_ATTACK)
			{
				if (classicMode && !jumped)
					vx = 0;
				setState(ST_JUMP);
				if (attackedInAir)
					setStopFrame(FL_JUMP_FALL );
				else if (vy < 0)
					setStopFrame(FL_JUMP);
				else
					setStopFrame(FL_JUMP_FALL );
				if (lastOnSpring && !onSpring)
				{
					if (rhtBtn && !lftBtn)
					{
						vx = xSpeed;
						scaleX = 1;
						if (lastVX < 0) lastVX = 0;
					}
					else if (lftBtn && !rhtBtn)
					{
						vx = -xSpeed;
						scaleX = -1;
						if (lastVX > 0) lastVX = 0;
					}
					canDoubleJump = true;
				}
				if (onSpring) // turns player while on spring
				{
					if (rhtBtn) scaleX = 1;
					else if (lftBtn) scaleX = -1;
				}
			}
			if (currentFrame == getLabNum(FL_ATTACK_END) || currentFrame == getLabNum(FL_CROUCH_ATTACK_END))
			{
					checkAtkRect = true;
					var crouchNum:int = IND_HIT_BOX_VEC_STAND;
					if (currentLabel.indexOf("crouch") != -1)
						crouchNum = IND_HIT_BOX_VEC_CROUCH;
					var rect:Rectangle = HIT_BOX_VEC[whipLevel-1][crouchNum];
					ahRect.x = rect.x;
					ahRect.y = rect.y;
					ahRect.width = rect.width;
					ahRect.height = rect.height;
					if (pState != PS_NORMAL)
						hitDistOver = rect.width*2;
					else
						hitDistOver = 0;
			}
			else
			{
				checkAtkRect = false;
				hitDistOver = 0;
			}
		}
		override protected function attackObjPiercing(obj:IAttackable):void
		{
			if ( upgradeIsActive(SIMON_WHIP_LEVEL_3) )
				damageAmt = DV_SIMON_FLAME_WHIP;
			else if ( upgradeIsActive(SIMON_WHIP_LEVEL_2) )
				damageAmt = DV_SIMON_MORNING_STAR;
			else
				damageAmt = DV_SIMON_SHORT_WHIP;
			super.attackObjPiercing(obj);
			if (obj is Enemy)
			{
				level.addToLevel( new SimonSimpleGraphics(obj as LevObj,SimonSimpleGraphics.TYPE_WHIP_SPARK,this) );
				if (skinNum == SKIN_SIMON_CV2_NES)
				{
					if (obj.health <= 0)
						SND_MNGR.playSound(SoundNames.SFX_SIMON_KILL_ENEMY_C2);
					else
						SND_MNGR.playSound(SFX_SIMON_HIT_ENEMY_C2);
				}
				else
					SND_MNGR.playSound(SFX_SIMON_HIT_ENEMY_NORMAL);
			}
		}

//		override protected function attackObjNonPiercing(obj:IAttackable):void
//		{
//			super.attackObjNonPiercing(obj);
//			if (obj is Enemy)
//				SND_MNGR.playSound(SoundNames.SFX_SIMON_HIT_ENEMY_ARMOR);
//		}

		// PRESSJUMPBTN
		override public function pressJmpBtn():void
		{
			if (cState == ST_VINE)
				return;
			if (!onSpring)
			{
				if (onGround)
				{
					onGround = false;
					attackedInAir = false;
					vy = -jumpPwr;
					setStopFrame(FL_CROUCH);
					setState(ST_JUMP);
					canDoubleJump = true;
					jumped = true;
					attackAnimTmr.stop();
					if (rhtBtn && !lftBtn)
					{
						vx = xSpeed;
						scaleX = 1;
					}
					else if (lftBtn && !rhtBtn)
					{
						vx = -xSpeed;
						scaleX = -1;
					}
				}
				else if (canDoubleJump)
				{
					attackAnimTmr.stop();
					attackedInAir = false;
					jumped = true;
					vy = -jumpPwr;
					setStopFrame(FL_CROUCH);
					setState(ST_JUMP);
					canDoubleJump = false;
					if (classicMode)
					{
						if (!rhtBtn && !lftBtn)
						{
							vx = 0;
							lastVX = 0;
						}
						else if (rhtBtn && !lftBtn)
						{
							vx = xSpeed;
							scaleX = 1;
							if (lastVX < 0) lastVX = 0;
						}
						else if (lftBtn && !rhtBtn)
						{
							vx = -xSpeed;
							scaleX = -1;
							if (lastVX > 0) lastVX = 0;
						}
					}
					else
					{
						if (rhtBtn && !lftBtn)
							scaleX = 1;
						else if (lftBtn && !rhtBtn)
							scaleX = -1;
					}
				}
			}
			super.pressJmpBtn();
		}
		// PRESSATTACKBTN
		override public function pressAtkBtn():void
		{
			if (upBtn && GameSettings.classicSpecialInput)
			{
				pressedSpecialButton();
				return;
			}
			if (cState == ST_VINE)
				return;
			super.pressAtkBtn();
			if (cState != ST_ATTACK)
			{
				if (dwnBtn && onGround)
					setStopFrame(FL_CROUCH_ATTACK_START);
				else
					setStopFrame(FL_ATTACK_START);
				attackAnimTmr.start();
				whip.setStopFrame(FL_WHIP_HANG);
				setState(ST_ATTACK);
				if (skinNum == SKIN_SIMON_CV2_NES && upgradeIsActive(SIMON_WHIP_LEVEL_3))
					SND_MNGR.playSound(SoundNames.SFX_SIMON_FLAME_WHIP);
				else
					SND_MNGR.playSound(SFX_SIMON_WHIP);
				if (!onGround)
					attackedInAir = true;
			}
		}
		override protected function bounce(enemy:Enemy):void
		{
			super.bounce(enemy);
			canDoubleJump = true;
		}
		// PRESSSPECIALBUTTON
		override public function pressSpcBtn():void
		{
			super.pressSpcBtn();
			pressedSpecialButton();
		}

		private function pressedSpecialButton():void
		{
			if (cState == ST_VINE)
				return;

			if (cState != ST_ATTACK )
			{
				if (curSubWeapon == SIMON_STOP_WATCH)
					useStopWatchIfPossible();
				else if ( canThrow() )
					startThrow(RyuSimonThrowType.Default);
			}
		}

		override public function pressSelBtn():void
		{
			super.pressSelBtn();
			if (cState == ST_VINE || cState == ST_ATTACK || !upgradeIsActive(FIRE_FLOWER) )
				return;

			if (classicExtraWeapon == SIMON_STOP_WATCH)
				useStopWatchIfPossible();
			else if ( canThrow(classicExtraWeapon) )
				startThrow(RyuSimonThrowType.Extra);
		}

		override protected function getDefaultAmmo(ammoType:String):int
		{
			if (GameSettings.classicMode)
				return CLASSIC_DEFAULT_AMMO;
			else
				return super.getDefaultAmmo(ammoType);
		}

		private function startThrow(throwType:RyuSimonThrowType):void
		{
			lastThrowType = throwType;
			if (onGround && dwnBtn)
				setStopFrame(FL_CROUCH_THROW_START);
			else
				setStopFrame(FL_THROW_START);
			attackAnimTmr.start();
			setState(ST_ATTACK);
		}

		private function useStopWatchIfPossible():void
		{
			if ( !getProperty(PR_STOP_ALL_ENEMIES_ACTIVE_AGG) && hasEnoughAmmo( AMMO_TYPE_HEARTS, SIMON_STOP_WATCH ) )
			{
				SND_MNGR.playSound( SoundNames.SFX_SIMON_STOP_WATCH );
				decAmmo(AMMO_TYPE_HEARTS,SIMON_STOP_WATCH);
				addProperty( new StatusProperty(PR_STOP_ALL_ENEMIES_ACTIVE_AGG,STOP_WATCH_STRENGTH) );
				stopWatchTmr.start();
				EVENT_MNGR.dispatchEvent( new Event(CustomEvents.STOP_ALL_ENEMIES_PROP_ACTIVATE) );
			}
		}

		override public function groundAbove(g:Ground):void
		{
			hitCeiling = true;
			if (cState != ST_ATTACK)
			{
				setStopFrame(FL_JUMP_FALL);
				setHitPoints();
			}
			ny = g.hBot + hHeight;
			if (jumped)
				vy = CIELING_DISPLACE;
			setHitPoints();
			SND_MNGR.playSound(SND_GAME_HIT_CEILING);
		}

		override protected function takeDamageStart(source:LevObj):void
		{
			super.takeDamageStart(source);
			setWhipLevel();
			setCurSubWeapon();
			takeNoDamage = true;
			disableInput = true;
			nonInteractive = true;
			damageBoost(source);
			setState(ST_TAKE_DAMAGE);
			BTN_MNGR.relPlyrBtns();
		}
		override protected function takeDamageEnd():void
		{
			disableInput = false;
			nonInteractive = false;
			setState(ST_STAND);
			setStopFrame(FL_STAND);
			alpha = TD_ALPHA;
			noDamageTmr.start();
			BTN_MNGR.sendPlayerBtns();
		}

		override protected function landOnGround():void
		{
			super.landOnGround();
			launchedFromGreenSpring = false;
			if (cState == ST_TAKE_DAMAGE)
				takeDamageEnd();
		}
		override protected function initiateNormalDeath(source:LevObj = null):void
		{
			super.initiateNormalDeath(source);
			damageBoost(source);
			lockFrame = true;
			checkFrameDuringStopAnim = true;
			EVENT_MNGR.startDieTmr(DIE_TMR_DEL_NORMAL_MAX);
		}
		private function damageBoost(source:LevObj = null):void
		{
			var dir:int = 1;
			if (source)
			{
				if (source.nx > nx)
					dir = -1;
			}
			else
			{
				if (scaleX > 0)
					dir = -1;
			}
			vy = -DAMAGE_BOOST_VY;
			vx = dir*xSpeed;
			scaleX = -dir;
			onGround = false;
			if (cState == ST_ATTACK)
				finishAttack();
			setStopFrame(FL_TAKE_DAMAGE);
			jumped = true;
			SND_MNGR.playSound(SFX_SIMON_HIT);
		}
		override public function revivalBoost():void
		{
			super.revivalBoost();
			hitPickup( new Pickup(SIMON_HEART_BIG), false );
			hitPickup( new Pickup(SIMON_HEART_BIG), false );
		}
		override protected function initiatePitDeath():void
		{
			_dieTmrDel = DIE_TMR_DEL_PIT;
			super.initiatePitDeath();
			SND_MNGR.changeMusic(MusicType.DIE);
		}

		override protected function bouncePit():void
		{
			if (cState == ST_TAKE_DAMAGE)
				takeDamageEnd();
			return super.bouncePit();
		}
		override public function slideDownFlagPole():void
		{
			super.slideDownFlagPole();
			nx = level.flagPole.hMidX - FLAG_POLE_OFFSET;
//			setStopFrame(FL_SLIDE);
			setStopFrame(FL_CLIMB_START);
			attackAnimTmr.stop();
		}
		override public function stopFlagPoleSlide():void
		{
			super.stopFlagPoleSlide();
			//nx = level.flagPole.hMidX + FLAG_POLE_OFFSET;
		}
		private function finishAttack():void
		{
			if (ATK_DCT.length != 0)
				ATK_DCT.clear();
			attackAnimTmr.stop();
			setState(ST_NEUTRAL);
		}
		override public function firstCollisionCheck():void
		{
			if (!onGround)
				canDoubleJump = false;
		}

		override public function chooseCharacter():void
		{
			super.chooseCharacter();
			vx = 0;
			var brick1:Brick = new Brick(Brick.FL_BRICK);
			var brick2:Brick = new Brick(Brick.FL_BRICK);
			var brickXPos:int = level.getNearestGrid(nx + TILE_SIZE*2,-1);
			brick1.x = brickXPos;
			brick2.x = brickXPos;
			brick1.breakOnNextHit();
			brick2.breakOnNextHit();
			brick1.y = ny - TILE_SIZE*2;
			brick2.y = ny - TILE_SIZE;
			level.addToLevel(brick1);
			level.addToLevel(brick2);
			var porkChop:SimonPickup = new SimonPickup(PickupInfo.SIMON_PORK_CHOP);
			porkChop.x = brick1.x + TILE_SIZE/2;
			porkChop.y = player.ny;
			porkChop.behindGround = true;
			level.addToLevel(porkChop);
			var sequencer:CharacterSequencer = new CharacterSequencer();
			sequencer.startNewSequence(CHOOSE_CHAR_SEQ);
		}
		override public function fallenCharSelScrn():void
		{
			super.fallenCharSelScrn();
			cancelCheckState = true;
			setStopFrame(FL_DIE_END);
		}

		override public function hitPickup(pickup:Pickup,showAnimation:Boolean = true):void
		{
			var hadFireFlower:Boolean = upgradeIsActive(FIRE_FLOWER);
    			super.hitPickup(pickup,showAnimation);
			setCurSubWeapon();
			var puType:String = pickup.type;
			switch(puType)
			{
				case MUSHROOM:
				{
					setWhipLevel();
					break;
				}
				case FIRE_FLOWER:
				{
					setWhipLevel();
					if (hadFireFlower)
						increaseAmmoByValue(AMMO_TYPE_HEARTS, CLASSIC_DEFAULT_AMMO/2);
					break;
				}
				case SIMON_WHIP_LEVEL_3:
				{
					if (showAnimation)
					{
						getMushroom();
						SND_MNGR.playSound(SoundNames.SFX_SIMON_GET_WEAPON);
					}
					setWhipLevel();
					break;
				}
				case SIMON_HEART_BIG:
				{
					increaseAmmoByValue(AMMO_TYPE_HEARTS,BIG_HEART_VALUE);
					break;
				}
				case SIMON_HEART_SMALL:
				{
					increaseAmmoByValue(AMMO_TYPE_HEARTS,SMALL_HEART_VALUE);
					break;
				}
			}
			if (!pickup.playsRegularSound && pickup.mainType != PickupInfo.MAIN_TYPE_FAKE && showAnimation)
			{
				if (puType == SIMON_HEART_BIG || puType == SIMON_HEART_SMALL)
					SND_MNGR.playSound(SN_GET_HEART);
				else
					SND_MNGR.playSound(SN_GET_WEAPON);
			}
		}

		override protected function getOnVine(_vine:Vine):void
		{
			if (cState == ST_TAKE_DAMAGE)
				takeDamageEnd();
			super.getOnVine(_vine);
		}
		private function canThrow(weaponToThrow:String = null):String
		{
			if (weaponToThrow == null)
				weaponToThrow = curSubWeapon;
			if (!weaponToThrow || !hasEnoughAmmo(AMMO_TYPE_HEARTS, weaponToThrow) )
				return null;
			var numProjAllowed:int = 1;
			if ( upgradeIsActive(SIMON_TRIPLE) )
				numProjAllowed = 3;
			else if ( upgradeIsActive(SIMON_DOUBLE) )
				numProjAllowed = 2;
			if (level.PLAYER_PROJ_DCT.length >= numProjAllowed)
				return null;

			return getProjectileTypeFromPickupType(weaponToThrow);
		}

		private function getPickupTypeFromProjectileType(projectileType:String):String
		{
			switch(projectileType)
			{
				case SimonProjectile.TYPE_AXE:
					return SIMON_AXE;
				case SimonProjectile.TYPE_CROSS:
					return SIMON_CROSS;
				case SimonProjectile.TYPE_DAGGER:
					return SIMON_DAGGER;
				case SimonProjectile.TYPE_HOLY_WATER:
					return SIMON_HOLY_WATER;
				default:
					return null;
			}
		}

		private function getProjectileTypeFromPickupType(pickupType:String):String
		{
			switch(pickupType)
			{
				case SIMON_AXE:
					return SimonProjectile.TYPE_AXE;
				case SIMON_CROSS:
					return SimonProjectile.TYPE_CROSS;
				case SIMON_DAGGER:
					return SimonProjectile.TYPE_DAGGER;
				case SIMON_HOLY_WATER:
					return SimonProjectile.TYPE_HOLY_WATER;
				default:
					return null;
			}
		}

		override protected function setAmmo(ammoType:String, value:int):void
		{
			super.setAmmo(ammoType, value);
			tsTxt.UpdAmmoText(true, getAmmo(ammoType) );
		}


		override public function checkFrame():void
		{
			var cl:String = currentLabel;
			var cf:int = currentFrame;
			if ((cState == ST_WALK || cState == ST_PIPE) && cf == getLabNum(FL_WALK_END) + 1)
				setPlayFrame(FL_WALK_START);
			else if (cState == ST_ATTACK)
			{
				if (cl == convLab(FL_ATTACK_2) || cl == convLab(FL_CROUCH_ATTACK_2) )
					whip.setStopFrame(FL_WHIP_WAVE);
				else if (cl == convLab(FL_ATTACK_END) || cl == convLab(FL_CROUCH_ATTACK_END) )
					whip.setStopFrame(FL_WHIP_STRAIGHT);
				if (cl == convLab(FL_THROW_END) || cl == convLab(FL_CROUCH_THROW_END))
				{
					var weaponTypeToThrow:String;
					if (GameSettings.classicMode && lastThrowType == RyuSimonThrowType.Extra)
						weaponTypeToThrow = canThrow(classicExtraWeapon);
					else
						weaponTypeToThrow = canThrow();

					if (weaponTypeToThrow)
					{
						decAmmo(AMMO_TYPE_HEARTS, getPickupTypeFromProjectileType(weaponTypeToThrow) );
						level.addToLevel( new SimonProjectile(this,weaponTypeToThrow) );
					}
				}
				if (cf == getLabNum(FL_ATTACK_END) + 1 || cf == getLabNum(FL_THROW_END) + 1)
				{
					if (onGround)
					{
						setState(ST_STAND);
						setStopFrame(FL_STAND);
						finishAttack();
					}
					else
					{
						setState(ST_JUMP);
						finishAttack();
						setStopFrame(FL_STAND);
					}
				}
				else if (cf == getLabNum(FL_CROUCH_ATTACK_END) + 1 || cf == getLabNum(FL_CROUCH_THROW_END) + 1)
				{
					setState(ST_CROUCH);
					setStopFrame(FL_CROUCH);
					finishAttack();
				}
			}
			else if (cState == ST_VINE)
			{
				if (cf == getLabNum(FL_CLIMB_END) + 1)
					setPlayFrame(FL_CLIMB_START);
			}
			else if (cState == ST_DIE)
			{
				if (cl == convLab(FL_DIE_START))
				{
					if (frameCtr == 0)
					{
						SND_MNGR.changeMusic( MusicType.DIE );
					}
					frameCtr++;
					if (frameCtr > NUM_KNEEL_FRAMES)
					{
						lockFrame = false;
						setStopFrame(FL_DIE_END);
						lockFrame = true;
						EVENT_MNGR.startDieTmr(DIE_TMR_DEL_NORMAL);
					}
				}
			}
			super.checkFrame();
		}

		override protected function removeListeners():void
		{
			super.removeListeners();
			attackAnimTmr.removeEventListener(TimerEvent.TIMER,attackAnimTmrHandler);
			stopWatchTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,stopWatchTmrHandler);
		}

		override public function cleanUp():void
		{
			super.cleanUp();
			tsTxt.UpdAmmoIcon(false);
			tsTxt.UpdAmmoText(false);
		}

		override protected function playDefaultPickupSoundEffect():void
		{
			SND_MNGR.playSound(SoundNames.SFX_SIMON_GET_WEAPON);
		}

		override protected function addAllPowerups():void
		{
			for (var i:int = 0; i < 16; i++)
			{
				hitRandomUpgrade(charNum,false);
			}
		}

		override public function springLaunch(spring:SpringRed):void
		{
			super.springLaunch(spring);
			if (spring is SpringGreen)
				launchedFromGreenSpring = true;
			if (cState == ST_TAKE_DAMAGE)
				takeDamageEnd();
		}

		public static function skinSettings(whipHangOfsX:int,whipHangOfsY:int,whipWaveOfsX:int,whipWaveOfsY:int,whipStraightOfsX:int,whipStraightOfsY:int,whipHangCrouchOfsX:int,whipHangCrouchOfsY:int,whipWaveCrouchOfsX:int,whipWaveCrouchOfsY:int,whipStraightCrouchOfsX:int,whipStraightCrouchOfsY:int):Array
		{
			var dct:Dictionary = new Dictionary();
			dct[FL_ATTACK_START] = new Point(whipHangOfsX,whipHangOfsY);
			dct[FL_CROUCH_ATTACK_START] = new Point(whipHangCrouchOfsX,whipHangCrouchOfsY);
			dct[FL_ATTACK_2] = new Point(whipWaveOfsX,whipWaveOfsY);
			dct[FL_CROUCH_ATTACK_2] = new Point(whipWaveCrouchOfsX,whipWaveCrouchOfsY);
			dct[FL_ATTACK_END] = new Point(whipStraightOfsX,whipStraightOfsY);
			dct[FL_CROUCH_ATTACK_END] = new Point(whipStraightCrouchOfsX,whipStraightCrouchOfsY);
			skinSettingsNestedArr.push(dct);
			return [ dct[FL_ATTACK_START], dct[FL_ATTACK_2], dct[FL_ATTACK_END], dct[FL_CROUCH_ATTACK_START], dct[FL_CROUCH_ATTACK_2], dct[FL_CROUCH_ATTACK_END] ];
		}

		public static function get classicMode():Boolean
		{
			if (player && player is Simon && Simon(player).launchedFromGreenSpring && GameStateManager.GS_MNGR.gameState == GS_PLAY)
				return false;
			return _classicMode;
		}

		public static function set classicMode(value:Boolean):void
		{
			_classicMode = value;
		}

	}
}
