package com.smbc.characters
{
	import avmplus.getQualifiedClassName;

	import com.explodingRabbit.cross.gameplay.statusEffects.StatusProperty;
	import com.explodingRabbit.cross.games.Game;
	import com.explodingRabbit.cross.games.Games;
	import com.explodingRabbit.display.CustomMovieClip;
	import com.explodingRabbit.utils.CustomDictionary;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.SuperMarioBrosCrossover;
	import com.smbc.characters.VicViper;
	import com.smbc.characters.base.MarioBase;
	import com.smbc.characters.base.MegaManBase;
	import com.smbc.data.*;
	import com.smbc.enemies.*;
	import com.smbc.enums.ClassicDamageResponse;
	import com.smbc.enums.DamageResponse;
	import com.smbc.enums.PowerupMode;
	import com.smbc.events.CustomEvents;
	import com.smbc.graphics.AllCharactersCmc;
	import com.smbc.graphics.BillLegs;
	import com.smbc.graphics.BillTorso;
	import com.smbc.graphics.BmdInfo;
	import com.smbc.graphics.BmdSkinCont;
	import com.smbc.graphics.MegaManHead;
	import com.smbc.graphics.Palette;
	import com.smbc.graphics.PaletteSheet;
	import com.smbc.graphics.SubMc;
	import com.smbc.graphics.TopScreenText;
	import com.smbc.ground.*;
	import com.smbc.interfaces.IAttackable;
	import com.smbc.interfaces.ICustomTimer;
	import com.smbc.interfaces.IKeyPressable;
	import com.smbc.interfaces.IKeyReleasable;
	import com.smbc.level.CharacterSelect;
	import com.smbc.level.FakeLevel;
	import com.smbc.level.Level;
	import com.smbc.level.LevelGraphicLayerContainer;
	import com.smbc.level.TitleLevel;
	import com.smbc.main.*;
	import com.smbc.managers.ButtonManager;
	import com.smbc.managers.GraphicsManager;
	import com.smbc.managers.SoundManager;
	import com.smbc.managers.StatManager;
	import com.smbc.managers.TutorialManager;
	import com.smbc.messageBoxes.CharacterSelectBox;
	import com.smbc.messageBoxes.MessageBox;
	import com.smbc.pickups.*;
	import com.smbc.projectiles.*;
	import com.smbc.sound.*;
	import com.smbc.utils.CharacterSequencer;
	import com.smbc.utils.GameLoopTimer;

	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;

	import nl.stroep.utils.ImageSaver;


	public class Character extends AnimatedObject implements IKeyPressable, IKeyReleasable
	{
		public static const NUM_CHARACTERS:int = CharacterInfo.NUM_CHARACTERS;
		public static const CHAR_NUM_MAX:int = NUM_CHARACTERS - 1;
		public static const CHAR_NUM_MIN:int = 0;
		public static const IND_CI_NAME:String = "IND_CI_";
		public static const PS_SEP_STR:String = "_";
		public static const PS_FALLEN:int = 0;
		public static const PS_NORMAL:int = 1;
		public static const PS_MUSHROOM:int = 2;
		public static const PS_FIRE_FLOWER:int = 3;
		public static const NUM_P_STATES:int = 3;
		private static const IND_PALETTE_MAIN:int = 1;
		private static const IND_PALETTE_POWER_UP:int = 2;
		private static const IND_PALETTE_STAR:int = 3;
		protected static const HRECT_PADDING_Y:int = 6;
		protected static const HRECT_PADDING_X:int = 4;
		protected static const VINE_CLIMB_SPEED:int = 130;
		public static const ST_ATTACK:String = "attack";
		public static const ST_CROUCH:String = "crouch";
		public static var BRICK_BREAKER:int = 1;
		public static var BRICK_BOUNCER:int = 0;
		public static var BRICK_NONE:int = -1;
		protected static const IND_AMMO_ARR_IND:int = 0;
		protected static const IND_AMMO_ARR_DEFAULT:int = 1;
		protected static const IND_AMMO_ARR_MAX:int = 2;
		protected static const IND_AMMO_DEPL_ARR_TYPE:int = 0;
		protected static const IND_AMMO_DEPL_ARR_COST:int = 1;
		protected static const MUSHROOM:String = PickupInfo.MUSHROOM;
		protected static const FIRE_FLOWER:String = PickupInfo.FIRE_FLOWER;
		protected static const CHAR_NUM_PROPERTY_NAME:String = "CHAR_NUM";
		protected static const CHAR_NAME_PROPERTY_NAME:String = "CHAR_NAME";
		protected static const CHAR_NAME_CAPS_PROPERTY_NAME:String = "CHAR_NAME_CAPS";
		protected static const CHAR_NAME_TEXT_PROPERTY_NAME:String = "CHAR_NAME_TEXT";
		protected static const OBTAINABLE_UPGRADES_ARR_PROPERTY_NAME:String = "OBTAINABLE_UPGRADES_ARR";
		protected static const AMMO_ARR_PROP_NAME:String = "AMMO_ARR";
		protected static const AMMO_DCT_PROP_NAME:String = "AMMO_DCT";
		protected static const AMMO_DEPLETION_ARR_PROP_NAME:String = "AMMO_DEPLETION_ARR";
		protected static const AMMO_DEPLETION_DCT_PROP_NAME:String = "AMMO_DEPLETION_DCT";
		protected static const WIN_SONG_DUR_PROPERTY_NAME:String = "WIN_SONG_DUR";
		protected static const SUFFIX_VEC_PROPERTY_NAME:String = "SUFFIX_VEC";
		protected static const PAL_ORDER_ARR_PROPERTY_NAME:String = "PAL_ORDER_ARR";
		protected static const MUSHROOM_UPGRADES_PROP_NAME:String = "MUSHROOM_UPGRADES";
		protected static const START_WITH_UPGRADES_PROP_NAME:String = "START_WITH_UPGRADES";
		protected static const NEVER_LOSE_UPGRADES_PROP_NAME:String = "NEVER_LOSE_UPGRADES";
		protected static const RESTORABLE_UPGRADES_PROP_NAME:String = "RESTORABLE_UPGRADES";
		protected static const REPLACEABLE_UPGRADES_ARR_PROP_NAME:String = "REPLACEABLE_UPGRADES_ARR";
		protected static const SINGLE_UPGRADES_ARR_PROP_NAME:String = "SINGLE_UPGRADES_ARR";
		private static const SKIN_ORDER_ARR_PROP_NAME:String = "SKIN_ORDER";
		public static const ICON_ORDER_ARR_PROP_NAME:String = "ICON_ORDER_ARR";
		public static const DROP_ARR_PROP_NAME:String = "DROP_ARR";
		protected static const SKIN_PREVIEW_FRAMES_PROP_NAME:String = "SKIN_PREVIEW_FRAMES";
		protected static const SKIN_PREVIEW_SIZE_PROP_NAME:String = "SKIN_PREVIEW_SIZE";
		protected static const SKIN_APPEARANCE_STATE_COUNT_PROP_NAME:String = "SKIN_APPEARANCE_STATE_COUNT";
		protected static const SPECIAL_SKIN_NUMBER_PROP_NAME:String = "SPECIAL_SKIN_NUMBER";
		protected static const ATARI_SKIN_NUMBER_PROP_NAME:String = "ATARI_SKIN_NUMBER";


		protected static const skinPreviews:Vector.<Vector.<Vector.<CustomMovieClip>>> = new Vector.<Vector.<Vector.<CustomMovieClip>>>(NUM_CHARACTERS,true);

		protected static const GET_SKIN_PREVIEWS_FUNCTION_NAME:String = "getSkinPreviews";
		public var mushroomUpgrades:CustomDictionary = new CustomDictionary();
		public var startWithUpgrades:CustomDictionary = new CustomDictionary();
		public var neverLoseUpgrades:CustomDictionary = new CustomDictionary();
		public var replaceableUpgrades:CustomDictionary = new CustomDictionary();
		public var restorableUpgrades:CustomDictionary = new CustomDictionary();
//		public var availableUpgradesDct:CustomDictionary;
//		public var obtainedUpgradesDct:CustomDictionary;
		public var curTier:int; // current level of upgrades
		public const curHitDct:CustomDictionary = new CustomDictionary(true);

		// begin local vars
		private const P_UP_SCORE_VAL:int = ScoreValue.POWER_UP;
		protected const ENTER_PIPE_VX_MAX:int = 90;
		protected const DEF_PS:int = 1;
		protected const PIPE_LEV_TRANS_DELAY:int = 500;
		protected const PIT_LEV_TRANS_DELAY:int = 500;
		protected const TD_ALPHA:Number = .65;
		protected var graphicsMngr:GraphicsManager;
		private const STORED_BUTTONS_VEC:Vector.<Array> = new Vector.<Array>();
		protected var _stompedEnemyThisCycle:Boolean;
		protected var _numContStomps:int;
		protected var _charNameCaps:String;
		protected var _numColors:int = 4;
		protected var palettePowerUp:Palette;
		protected var paletteStar:Palette;
		protected var paletteMain:Palette;
		public var lftBtn:Boolean;
		public var rhtBtn:Boolean;
		public var upBtn:Boolean;
		public var dwnBtn:Boolean;
		public var atkBtn:Boolean;
		public var jmpBtn:Boolean;
		public var spcBtn:Boolean;
		public var selBtn:Boolean;
		public var jumped:Boolean;
		public var releasedJumpBtn:Boolean;
		private var disableJump:Boolean;
		public var maxJumpHeight:Boolean;
		private var wallRight:Boolean;
		private var wallLeft:Boolean;
		public var swapZone:Boolean;
		public var disableInput:Boolean; // cannot accept button presses
		public var nonInteractive:Boolean; // disables interaction with everything
		protected const CIELING_DISPLACE:int = 100;
		protected var bouncePwr:int = 300;
		protected var bounced:Boolean;
		protected var vineAnimTmr:CustomTimer = AnimationTimers.ANIM_SLOW_TMR;
		private var initialJumpPower:Number;
		private var maxRunSpeed:Number = 350;
		public var pState:uint;
		public var pState2:Boolean;
//		protected var pStateRecolor:Boolean;
		protected var numParFrames:uint;
		public var charNum:int;
		public var frictionY:Boolean = true;
		protected var lastVX:Number = 0;
		// pause keys
		public var pUpBtn:Boolean;
		public var pDwnBtn:Boolean;
		public var pLftBtn:Boolean;
		public var pRhtBtn:Boolean;
		public var pAtkBtn:Boolean;
		public var pJmpBtn:Boolean;
		public var pSpcBtn:Boolean;
		// end pause keys
		public var starPwr:Boolean;
		public var starPwrTmr1:CustomTimer; // starts flashing slow
		private var starPwrTmr2:CustomTimer; // music ends
		protected var starPwrTmr3:CustomTimer; // star power ends
		protected var poweringUp:Boolean;
		public var skinNum:int;
		public const STAR_PWR_TMR_1_DUR:int = 9500;
		private const STAR_PWR_TMR_2_DUR:int = 1200;
		private const STAR_PWR_TMR_3_DUR:int = 1300;
		protected const STAR_PWR_FLASH_ANIM_TMR:CustomTimer = AnimationTimers.ANIM_FAST_TMR;
		private const STAR_PWR_SLOW_FLASH_ANIM_TMR:CustomTimer = AnimationTimers.ANIM_SLOW_TMR;
		private static const FREEZE_GAME_TMR_DEL:uint = 1000;
		protected var freezeGameTmr:CustomTimer;
		protected var noDamageTmr:CustomTimer;
		protected var noDamageTmrDur:uint = 1250;
		private var colorNum:uint = 1;
		public var takeNoDamage:Boolean = Cheats.invincible;
		protected var hitFrameLabel:String;
		protected var hitStopAnim:Boolean;
		protected var hitState:String;
		protected var damageInfoArr:Array = [];
		private static const IND_DAMAGE_INFO_ARR_LABEL:int = 0;
		private static const IND_DAMAGE_INFO_ARR_STOP_ANIM:int = 1;
		private static const IND_DAMAGE_INFO_ARR_STATE:int = 2;
		public var bRect:Rectangle;
		public var dead:Boolean;
		public var springBoost:Boolean;
		public var defSpringPwr:int = 500;
		public var boostSpringPwr:int = 1000;
		public var underWater:Boolean;
		protected var defGravity:Number;
		protected var defGravityWater:Number;
		protected var vyMaxPsvWater:Number = 250;
		private var vxMaxGroundWater:Number = 90;
		public var pulledDown:Boolean;
		public var pulledRight:Boolean;
		public var pulledLeft:Boolean;
		private var bubbleTmr:CustomTimer;
		private var bubbleTmrDurMin:int = 500;
		private var bubbleTmrDurMax:int = 1500;
		protected var onPipeVert:Boolean;
		protected var pipe:PipeTransporter;
		protected var vine:Vine;
		protected var onPipeHorz:Boolean;
		public var falseDestroy:Boolean;
		protected var vertPipeSpeed:int = 50;
		protected var horzPipeSpeed:int = 50;
		protected var startPipeLoc:Number;
		protected var pType:String;
		private var flagDelayTmr:CustomTimer;
		protected var flickerTmr:GameLoopTimer;
		private var FLAG_DELAY_TMR_DUR:int = 300;
		private var musicDelTmr:CustomTimer;
		private var MUSIC_DEL_TMR_DUR:int = 250;
		protected const BTN_MNGR:ButtonManager = ButtonManager.BTN_MNGR;
		private var pitTransArr:Array;
		protected var _charName:String;
		protected var _charNameTxt:String;
		protected var _dieTmrDel:int = 3000;
		private const DIE_TMR_DEL_PIT_DEFAULT:int = 2500;
		protected var lockFrame:Boolean;
		protected var _fellInPit:Boolean;
		protected var VINE_WATCH_Y:int;
		protected var exitVine:Boolean;
		public var vineToClimb:Vine;
		protected var _boundsRect:Rectangle;
		protected var inColor1:uint;
		protected var inColor2:uint;
		protected var inColor3:uint;
		protected var inColor1_1:uint;
		protected var inColor2_1:uint;
		protected var inColor3_1:uint;
		protected var inColor1_2:uint;
		protected var inColor2_2:uint;
		protected var inColor3_2:uint;
		protected var inColor1_3:uint;
		protected var inColor2_3:uint;
		protected var inColor3_3:uint;
		protected var outColor1:uint;
		protected var outColor2:uint;
		protected var outColor3:uint;
		protected var _replaceColor:Boolean;
		protected var offsetMx:Matrix;
		protected const SFX_GAME_PIPE:String = SoundNames.SFX_GAME_PIPE;
		protected const SFX_GAME_POWER_UP:String = SoundNames.SFX_GAME_POWER_UP;
		protected const SND_GAME_HIT_CEILING:String = SoundNames.SFX_GAME_HIT_CEILING;
		private const SND_NAME_SUFFIX:String = SoundManager.SND_NAME_SUFFIX;
		private const MUSIC_EFFECT_TYPE_WIN:String = SoundNames.MUSIC_EFFECT_TYPE_WIN;
		protected const STAR_COLOR_1_1:uint = 0xFF00A800;
		protected const STAR_COLOR_2_1:uint = 0xFFFC9838;
		protected const STAR_COLOR_3_1:uint = 0xFFFFFFFF;
		protected const STAR_COLOR_1_2:uint = 0xFFD82800;
		protected const STAR_COLOR_2_2:uint = STAR_COLOR_2_1;
		protected const STAR_COLOR_3_2:uint = STAR_COLOR_3_1;
		protected const STAR_COLOR_1_3:uint = 0xFF000000;
		protected const STAR_COLOR_2_3:uint = 0xFFC84C0C;
		protected const STAR_COLOR_3_3:uint = 0xFFFCBCB0;
		protected var outColor1_1:uint = STAR_COLOR_1_1;
		protected var outColor2_1:uint = STAR_COLOR_2_1;
		protected var outColor3_1:uint = STAR_COLOR_3_1;
		protected var outColor1_2:uint = STAR_COLOR_1_2;
		protected var outColor2_2:uint = STAR_COLOR_2_2;
		protected var outColor3_2:uint = STAR_COLOR_3_2;
		protected var outColor1_3:uint = STAR_COLOR_1_3;
		protected var outColor2_3:uint = STAR_COLOR_2_3;
		protected var outColor3_3:uint = STAR_COLOR_3_3;
		protected var suffixVec:Vector.<String> = Vector.<String>(["","",""]);
		protected const SWAP_PS_VEC:Vector.<int> = new Vector.<int>();
		public static const ST_FLAG_SLIDE:String = "flagSlide";
		protected const ST_DIE:String = "die";
		protected const ST_JUMP:String = "jump";
		protected const ST_NEUTRAL:String = "neutral";
		protected const ST_GET_MUSHROOM:String = "getMushroom";
		public static const ST_PIPE:String = "pipe";
		protected static const ST_GET_UPGRADE:String = "getUpgrade";
		public const ST_STAND:String = "stand";
		protected const ST_TAKE_DAMAGE:String = "takeDamage";
		protected const ST_VINE:String = "vine";
		protected const ST_WALK:String = "walk";
		protected const ANIM_VERY_SLOW_TMR:CustomTimer = AnimationTimers.ANIM_VERY_SLOW_TMR;
		protected const ANIM_SLOW_TMR:CustomTimer = AnimationTimers.ANIM_SLOW_TMR;
		protected const ANIM_MODERATE_TMR:CustomTimer = AnimationTimers.ANIM_MODERATE_TMR;
		protected const ANIM_MIN_FAST_TMR:CustomTimer = AnimationTimers.ANIM_MIN_FAST_TMR;
		protected const ANIM_FAST_TMR:CustomTimer = AnimationTimers.ANIM_FAST_TMR;
		protected const NUM_STAR_COLORS:int = 3;
		private const STUCK_IN_WALL_SHIFT:int = 3;
		private var storedPState:int;
		public const ATK_DCT:CustomDictionary = new CustomDictionary(true);
		protected var walkStartLab:String;
		protected var walkEndLab:String;
		public var touchedExit:Boolean;
		public var cloudPlatform:Boolean;
		protected const FALL_BTWN_TMR:CustomTimer = new CustomTimer(50,1);
		protected var _fallBtwn:Boolean;
		protected var _secondsLeftSnd:String;
		protected var _sndWinMusic:String;
		protected var _secondsLeftSndIsBgm:Boolean;
		protected var _usesHorzObjs:Boolean;
		protected var _usesVertObjs:Boolean;
		protected var winSongDur:int;
		protected var swapAnimTmr:CustomTimer = AnimationTimers.ANIM_SLOW_TMR;
		protected var flashAnimTmr:CustomTimer = AnimationTimers.ANIM_FAST_TMR;
		private var _starPwrBgmShouldBePlaying:Boolean;
		protected var nPState:int;
		protected var neverTakeDamage:Boolean = Cheats.invincible;
		protected var _canStomp:Boolean = false;
		protected var canStompUnderWater:Boolean = true;
		public var canCrossSmallGaps:Boolean;
		public var disableStuckInWallShift:Boolean;
		public var screenScrollPosOffset:Number;
		public var putSubMcsOnTop:Boolean;
		public var brickState:int = BRICK_BOUNCER;
		public var canHitMultipleBricks:Boolean = false;
		private static const AXE_FALL_TMR_DEL:int = 300;
		private var axeFallTmr:GameLoopTimer;
		private var bowserAxeRect:Rectangle;
		public var subMcDct:CustomDictionary;
		public var masterBmdSkin:BmdSkinCont;
		protected var flickerTmrDel:int = 80;
		protected var showBmps:Boolean = true;
		protected var hidesBmps:Boolean = false;
		protected var cancelCheckState:Boolean;
		public var currentBmdSkin:BmdSkinCont;
//		private var palLenArr:Array;
		protected var firstPStateCall:Boolean = true;
		protected var initiated:Boolean;
		public var recordSeq:CharacterSequencer;
		private var _canGetMushroom:Boolean;
		protected const C_HIT_DCT:CustomDictionary = new CustomDictionary(true);
		protected const L_HIT_DCT:CustomDictionary = new CustomDictionary(true);
		protected var damageAmt:int;
		private var ammoDct:CustomDictionary;
		protected var paletteSheet:PaletteSheet;
		protected static const AMMO_ICON_SUFFIX:String = "Ammo";
		protected static var tsTxt:TopScreenText;
		protected var drawFrameLabel:String = "stand";
		public var wingTimer:CustomTimer;
		private static const WING_TIMER_DURATION:int = 10000;
		protected var hammerWeapon:HammerWeapon;
		protected var _canGetAmmoFromCoinBlocks:Boolean;
		protected var _canGetAmmoFromBricks:Boolean;
		protected var _isWideCharacter:Boolean;
		protected var _isGoodSwimmer:Boolean;

		/** When you get a mushroom, also get these upgrades. */
		public function get classicGetMushroomUpgrades():Vector.<String> { return new Vector.<String>(); }
		/** When you lose a mushroom, also lose these upgrades. */
		public function get classicLoseMushroomUpgrades():Vector.<String> { return classicGetMushroomUpgrades; }

		/** When you get a fire flower, also get these upgrades. */
		public function get classicGetFireFlowerUpgrades():Vector.<String> { return new Vector.<String>(); }
		/** When you lose a fire flower, also lose these upgrades. */
		public function get classicLoseFireFlowerUpgrades():Vector.<String> { return classicGetFireFlowerUpgrades; }
//		public function get classicNeverLoseUpgrades():Vector.<String> { return new Vector.<String>(); }

		/**
		 * Holds percentages of item drops.
		 */
		public var dropRate:Number = .25;
		public var dropArr:Array;
		public var recolorsCharSkin:Boolean;
		protected var walksSlowUnderWater:Boolean = false;
		public var poorBowserFighter:Boolean = false;
		private static const skinAppearanceNumbers:Vector.<int> = new Vector.<int>(NUM_CHARACTERS,true);

//		allows a character to enter a pipe without being on the ground
		protected var canEnterPipesUngrounded:Boolean;

//		protected var recoloredCharSheet:Boolean;

		public function Character()
		{
			super();
			LevObj.player = this;
			if (!tsTxt)
				tsTxt = TopScreenText.instance;
			graphicsMngr = GraphicsManager.INSTANCE;
			_charName = classObj[CHAR_NAME_PROPERTY_NAME];
			_charNameTxt = classObj[CHAR_NAME_TEXT_PROPERTY_NAME];
			_charNameCaps = classObj[CHAR_NAME_CAPS_PROPERTY_NAME];
			winSongDur = classObj[WIN_SONG_DUR_PROPERTY_NAME];
			mushroomUpgrades.fromArray( classObj[MUSHROOM_UPGRADES_PROP_NAME] );
			neverLoseUpgrades.fromArray( classObj[NEVER_LOSE_UPGRADES_PROP_NAME] );
			addStartWithUpgrades(classObj[START_WITH_UPGRADES_PROP_NAME]);
			restorableUpgrades.fromArray( classObj[RESTORABLE_UPGRADES_PROP_NAME] );
			var replUpgArr:Array = classObj[REPLACEABLE_UPGRADES_ARR_PROP_NAME];
			for each (var arr:Array in replUpgArr)
			{
				if (arr.length)
					replaceableUpgrades.addItem(arr[0],arr[1]);
			}
			dropArr = classObj[DROP_ARR_PROP_NAME];
			if (!dropArr)
				dropArr = [];
			var staticAmmoDct:CustomDictionary = classObj[AMMO_DCT_PROP_NAME];
			ammoDct = new CustomDictionary(); // makes a clone so that I can modify max values
			for (var key:Object in staticAmmoDct)
			{
				arr = staticAmmoDct[key];
				ammoDct.addItem( key, arr.concat() );
			}
			canGetMushroom = true;
//			obtainedUpgradesDct = STAT_MNGR.getObtainedUpgradesDct(charNum);
			paletteSheet = BmdInfo.getCharPaletteSheet(charNum);
			var suffixVecTmp:Vector.<String> = classObj[SUFFIX_VEC_PROPERTY_NAME];
			if (suffixVecTmp)
				suffixVec = suffixVecTmp.concat();
//			setCurrentBmdSkin(STAT_MNGR.getCurrentBmc(charNum));
			setCurrentBmdSkin(STAT_MNGR.getCurrentBmc(charNum),true);
			ACTIVE_ANIM_TMRS_DCT.addItem(swapAnimTmr);
			ACTIVE_ANIM_TMRS_DCT.addItem(flashAnimTmr);
			VINE_WATCH_Y = GLOB_STG_TOP + TILE_SIZE*2;
//			setUpFlashPaletteOrder();
			pState = 1;
			curTier = STAT_MNGR.getTier(charNum);
			setUpHitTesting();
			addProperty( new StatusProperty(StatusProperty.TYPE_PIERCE_AGG) );
		}

		private function addStartWithUpgrades(arr:Array):void
		{
			for ( var i:int = 0; i < arr.length; i++)
			{
				var upg:String = arr[i];
				startWithUpgrades.addItem(upg,upg);
				if ( !STAT_MNGR.hasCompetingSingleItem(charNum,upg) )
					STAT_MNGR.addCharUpgrade(charNum,upg);
			}
		}

		public static function getNeverLoseUpgrades(charNum:int):CustomDictionary
		{
			var classObject:Object = CharacterInfo.getCharClassFromNum(charNum) as Object;
			var dct:CustomDictionary = new CustomDictionary();
			dct.fromArray(classObject[NEVER_LOSE_UPGRADES_PROP_NAME]);
			return dct;
		}

		protected function setUpHitTesting():void
		{
			hitTestTypesDct.addItem(HitTestTypes.CHARACTER);
			addHitTestableItem(HT_PICKUP);
			addHitTestableItem(HT_ENEMY);
			addHitTestableItem(HT_PROJECTILE_ENEMY);
			addHitTestableItem(HT_GROUND_NON_BRICK);
			addHitTestableItem(HT_BRICK);
			addHitTestableItem(HT_PLATFORM);
		}
		protected function startAndDamageFcts(start:Boolean = false):void
		{

		}

		/*override public function setUpFlashPaletteOrder(palOrderArrOvRd:Array = null):void
		{
			super.setUpFlashPaletteOrder( (classObj[PAL_ORDER_ARR_PROPERTY_NAME] as Array).concat() );
			for each (var subMc:SubMc in subMcDct)
			{
				if (subMc.palOrderArr)
					subMc.setUpFlashPaletteOrder();
			}
		}*/

		private static function getSkinAppearanceNumber(charNum:int):int
		{
			return skinAppearanceNumbers[charNum];
		}

		private static function setSkinAppearanceNumber(charNum:int, value:int):void
		{
			skinAppearanceNumbers[charNum] = value;
		}

		public static function getSkinPreviews(charNum:int):Vector.<CustomMovieClip>
		{
			var classObject:Object = CharacterInfo.getCharClassFromNum(charNum) as Object;
			var skinAppearanceNum:int = 0;
			if (Level.levelInstance && Level.levelInstance.player)
				skinAppearanceNum = Level.levelInstance.player.currentSkinAppearanceNum;
			else
				skinAppearanceNum = getSkinAppearanceNumber(charNum);
//			trace("getting appearance num: "+skinAppearanceNum);
			return skinPreviews[charNum][skinAppearanceNum];
		}

		public static function getSkinPreviewSize(charNum:int):Point
		{
			var classObject:Object = CharacterInfo.getCharClassFromNum(charNum) as Object;
			var size:Point = (classObject[SKIN_PREVIEW_SIZE_PROP_NAME] as Point).clone();
			size.x *= GlobVars.SCALE;
			size.y *= GlobVars.SCALE;
			return size;
		}

		protected function saveSkinPreviews():Boolean // returns true if successfully saved
		{
			var skinPreviewsTemp:Vector.<Vector.<Vector.<CustomMovieClip>>> = skinPreviews;
			if (skinPreviews[0] == null)
				setUpSkinPreviews();
			else if (skinPreviews[charNum][0][0] != null) // previews have already been saved
				return false;
			gotoAndStop(drawFrameLabel);
			var skinOrder:Vector.<int> = getSkinOrderVec(charNum);
			var skinAppearanceStateCount:int = 1;
			if (classObj[SKIN_APPEARANCE_STATE_COUNT_PROP_NAME] != undefined)
				skinAppearanceStateCount = classObj[SKIN_APPEARANCE_STATE_COUNT_PROP_NAME] as int;
			var startSkinNumber:int = skinNum;
//			for each( var skinNum:int in skinOrder)
			for (var i:int = 0; i < skinOrder.length; i++)
			{
				var skinNum:int = skinOrder[i];
				for (var skinAppearanceState:int = 0; skinAppearanceState < skinAppearanceStateCount; skinAppearanceState++)
				{
					graphicsMngr.changeCharacterSkin(this, skinNum);
					prepareDrawCharacter(skinAppearanceState);
					var size:Point = getSkinPreviewSize(charNum);
	//				gotoAndStop(drawFrameLabel);
					var bmdNormal:BitmapData = ImageSaver.INSTANCE.getBitmapData(this, 0);
					var colorRect:Rectangle = bmdNormal.getColorBoundsRect(0xFFFFFFFF,0,false);
					colorRect.x -= (size.x - colorRect.width)/GlobVars.SCALE;
					colorRect.y -= (size.y - colorRect.height);
					colorRect.width = size.x;
					colorRect.height = size.y;
					var bmdTrimmed:BitmapData = new BitmapData(colorRect.width, colorRect.height, true, 0);
					bmdTrimmed.copyPixels(bmdNormal,colorRect, GlobVars.ZERO_PT);
					var customMovieClip:CustomMovieClip = new CustomMovieClip();
					customMovieClip.setNumFrames(1);
					customMovieClip.addChildToSingleFrame(new Bitmap(bmdTrimmed),1);
					skinPreviews[charNum][skinAppearanceState][skinNum] = customMovieClip;
					customMovieClip.gotoAndStop(1);
				}
			}
			graphicsMngr.changeCharacterSkin(this, startSkinNumber);
			prepareDrawCharacter();
			return true;
		}

		private static function setUpSkinPreviews():void
		{
			for (var i:int = 0; i < skinPreviews.length; i++)
			{
				var skinAppearanceStateCount:int = 1;
				var classObject:Object = CharacterInfo.getCharClassFromNum(i) as Object;
				if (classObject[SKIN_APPEARANCE_STATE_COUNT_PROP_NAME] != undefined)
					skinAppearanceStateCount = classObject[SKIN_APPEARANCE_STATE_COUNT_PROP_NAME] as int;

				skinPreviews[i] = new Vector.<Vector.<CustomMovieClip>>(skinAppearanceStateCount, true);
				for (var j:int = 0; j < skinAppearanceStateCount; j++)
				{
					skinPreviews[i][j] = new Vector.<CustomMovieClip>( getSkinOrderVec(i).length, true);
				}
//				for (var j:int = 0; j < skinPreviews[i].length; j++)
//					skinPreviews[i][j] = new Vector.<CustomMovieClip>(1, false);
			}
		}

		public static function getAtariSkinNumber(charNum:int):int
		{
			var classObject:Object = CharacterInfo.getCharClassFromNum(charNum) as Object;
			return classObject[ATARI_SKIN_NUMBER_PROP_NAME];
		}

		public static function getSpecialSkinNumber(charNum:int):int
		{
			var classObject:Object = CharacterInfo.getCharClassFromNum(charNum) as Object;
			return classObject[SPECIAL_SKIN_NUMBER_PROP_NAME];
		}

		public function upgradeIsActive(type:String):Boolean
		{
//			if (startWithUpgrades[type] != undefined)
//				return true;
			var obtainedUpgradesDct:CustomDictionary = STAT_MNGR.getObtainedUpgradesDct(charNum);
			if ( (!obtainedUpgradesDct[MUSHROOM] && canGetMushroom) && neverLoseUpgrades[type] == undefined && GameSettings.damageResponse != DamageResponse.KeepUpgrades)
				return false;
			return Boolean( obtainedUpgradesDct[type] );
		}

		override protected function firstCall():void
		{
			charNum = classObj[CHAR_NUM_PROPERTY_NAME];
			masterBmdSkin = new BmdSkinCont( BmdInfo.MASTER_CHAR_BMP_VEC[charNum], 0, GraphicsManager.TYPE_CHARACTER, this );
		}
		public function get numColors():int
		{
			return _numColors;
		}
		public function addSubMc(subMc:SubMc):void
		{
			if (!subMcDct)
				subMcDct = new CustomDictionary(true);
			subMcDct.addItem(subMc);
		}
		override public function initiate():void
		{
			initiated = true;
			super.initiate();
			level.LEV_OBJ_FINAL_CHECK.addItem(this);
			//if (vineToClimb)
			//	climbVineStarter(vineToClimb);
			_boundsRect = getBounds(this);
			for each (var ct:CustomTimer in level.ALL_ANIM_TMRS_DCT)
			{
				ACTIVE_ANIM_TMRS_DCT.addItem(ct);
			}
			if (level.levNum == STAT_MNGR.DUNGEON_LEVEL_NUM)
				_sndWinMusic = SoundNames.MFX_MARIO_WIN_CASTLE;
			lastOnGround = true;
			onGround = false;
			if (Cheats.invincible)
				forceTakeNoDamage();
			if (subMcDct)
			{
				for each (var subMc:SubMc in subMcDct)
				{
					subMc.initiate();
				}
			}
			if (level is FakeLevel)
				saveSkinPreviews();
		}
		public static function getMushroomUpgrades(charNum:int):CustomDictionary
		{
			var classObject:Object = CharacterInfo.getCharClassFromNum(charNum) as Object;
			var dct:CustomDictionary = new CustomDictionary();
			dct.fromArray(classObject[MUSHROOM_UPGRADES_PROP_NAME]);
			return dct;
		}

		override protected function prepareSkins():void
		{
			super.prepareSkins();
			/*for each (var bmc:BmdSkinCont in BMD_CONT_VEC)
			{
				bmc.bmp.bitmapData = BMD_CONT_VEC[0].bmd;
			}*/
			/*for each (var subMc:SubMc in subMcDct)
			{
				for each (var bmc:BmdSkinCont in subMc.BMD_CONT_VEC)
				{
					bmc.bmp.bitmapData = BMD_CONT_VEC[0].bmd;
				}
			}*/
		}
		override public function resetColor(useCleanBmd:Boolean = false):void
		{
			if (useCleanBmd)
				redraw(currentFrame,getCleanMasterBmdSkinForReading().bmd);
			else
				redraw(currentFrame);
		}
		override public function setStats():void
		{
			//_replaceColor = true;
			onScreen = true;
			onGround = true;
			if (pState < PS_NORMAL)
				pState = PS_NORMAL;
			pState--;
			manualChangePwrState();
			setStopFrame("stand");
			cState = "stand";
			super.setStats();
			freezeGameTmr = new CustomTimer(FREEZE_GAME_TMR_DEL,1);
			freezeGameTmr.addEventListener(TimerEvent.TIMER_COMPLETE,freezeGameTmrHandler);
			noDamageTmr = new CustomTimer(noDamageTmrDur,1);
			noDamageTmr.addEventListener(TimerEvent.TIMER_COMPLETE,noDamageTmrLsr);
			addTmr(noDamageTmr);
			FALL_BTWN_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,fallBtwnTmrHandler,false,0,true);
			addTmr(FALL_BTWN_TMR);
			startAndDamageFcts(true);
		}
		override public function animate(ct:ICustomTimer):Boolean
		{
			var animated:Boolean;
			if (!stopAnim)
			{
				if (mainAnimTmr == ct)
				{
					if (!noAnimThisCycle && !lockFrame)
					{
						ANIMATOR.animate(this);
						animated = true;
					}
					else
						noAnimThisCycle = false;
				}
			}
			if (ct == swapAnimTmr && SWAP_PS_VEC.length)
				swapPs();
			if (ct == flashAnimTmr && _replaceColor)
				flash();
			return animated;
		}

		// called by hit tester when player attacks something
		// this is the only function called
		public function landAttack(obj:IAttackable):void
		{
			if ( !hitIsAllowed(obj) )
				return;
			if ( !obj.isSusceptibleToProperty( getProperty(PR_PIERCE_AGG) ) && !Cheats.allWeaponsPierce)
				attackObjNonPiercing(obj);
			else
				attackObjPiercing(obj);
		}

		override protected function hitIsAllowed(mc:IAttackable):Boolean
		{
			if (L_HIT_DCT[mc])
			{
				C_HIT_DCT.addItem(mc);
				return false;
			}
			C_HIT_DCT.addItem(mc);
			return true;
		}

		override protected function attackObjPiercing(obj:IAttackable):void
		{
			super.attackObjPiercing(obj);
			obj.hitByAttack(this,damageAmt);
		}


		public function firstCollisionCheck():void
		{
			// for Simon to cancel his double jump if he's in the air
		}
		public function setLastHitPointsToCurrent():void
		{
			lhTop = hTop;
			lhBot = hBot;
			lhLft = hLft;
			lhRht = hRht;
			lhMidX = hMidX;
			lhMidY = hMidY;
			lhWidth = hWidth;
			lhHeight = hHeight;
		}
		protected function swapPsStart(p1:int,p2:int):void
		{
			if (SWAP_PS_VEC.length)
				SWAP_PS_VEC.length = 0;
			SWAP_PS_VEC.push(p1);
			SWAP_PS_VEC.push(p2);
			storedPState = pState;
		}
		protected function swapPsEnd():void
		{
			SWAP_PS_VEC.length = 0;
			if (storedPState)
			{
				pState = storedPState;
				storedPState = 0;
			}
		}
		protected function swapPs():void
		{
			if (!SWAP_PS_VEC.length)
				return;
			var ps1:int = SWAP_PS_VEC[0];
			var ps2:int = SWAP_PS_VEC[1];
			if (pState == ps1)
				pState = ps2;
			else if (pState == ps2)
				pState = ps1;
			var cl:String = currentLabel;
			//var stopFrame:String = cl.substr(0,cl.length-1)+pState.toString();
			var stopFrame:String = cl.substr(0,cl.length-2);
			setStopFrame(stopFrame);
		}
		public function flashPaletteSwap():void
		{
			if (!replaceColor)
			{
				startReplaceColor();
				poweringUp = true;
			}
			else if (!starPwr)
			{
				flashAnimTmr = STAR_PWR_FLASH_ANIM_TMR;
				poweringUp = false;
				starPwr = true;
			}
			else
			{
				starPwr = false;
				poweringUp = false;
				endReplaceColor();
			}
		}
		protected function setPStateColors():void
		{

		}
		/*public function updClone():void
		{
			var cf:int = 0;
			if (contains(playerGraphic))
				removeChild(playerGraphic);
			playerGraphic.bitmapData.dispose();
			playerGraphic.bitmapData = null;
			if (bmd2)
				bmd2.dispose();
			var changeSx:Boolean;
			if (scaleX < 1)
			{
				scaleX = -scaleX;
				changeSx = true;
			}
			visible = true;
			_boundsRect = getBounds(level);
			var locBoundRect:Rectangle = getBounds(this);
			var zeroRect:Rectangle = new Rectangle(0,0,locBoundRect.width,locBoundRect.height);
			offsetMx = this.transform.matrix;
			offsetMx.tx = this.x - _boundsRect.x;
			offsetMx.ty = this.y - _boundsRect.y;
			bmd2 = new BitmapData(locBoundRect.width,locBoundRect.height,true,0);
			bmd2.draw(this,offsetMx);
			if (!useOriginalColors)
			{
				if (outColor1 != 0)
					bmd2.threshold(bmd2,zeroRect,ZERO_PT,"==",inColor1,outColor1);
				if (outColor2 != 0)
					bmd2.threshold(bmd2,zeroRect,ZERO_PT,"==",inColor2,outColor2);
				if (outColor3 != 0)
				bmd2.threshold(bmd2,zeroRect,ZERO_PT,"==",inColor3,outColor3);
			}
			playerGraphic.bitmapData = bmd2;
			playerGraphic.x = _boundsRect.left;
			playerGraphic.y = _boundsRect.top;
			//addChild(bm);
			//if (shape)
			//	shape.visible = false;
			if (changeSx)
			{
				scaleX = -scaleX;
				//bm.scaleX = -1;
				//bm.x += boundsRect.width/2;
			}
		//	else
		//		bm.scaleX = 1;
			if (!level.contains(playerGraphic))
				level.addChild(playerGraphic);
			playerGraphic.transform.matrix = transform.matrix;
			playerGraphic.y -= offsetMx.ty;
			if (scaleX > 0)
				playerGraphic.x -= offsetMx.tx;
			else
				playerGraphic.x += offsetMx.tx;
			visible = false;
			playerGraphic.alpha = alpha;
		}		*/
		override protected function updateStats():void
		{
			super.updateStats();
			if (STORED_BUTTONS_VEC.length)
				activateStoredButtons();
			if (cState == ST_PIPE)
			{
				if (pType == "enterVert")
				{
					ny += vertPipeSpeed*dt;
					if (hTop - HRECT_PADDING_Y > startPipeLoc)
					{
						EVENT_MNGR.levelTransfer(pipe.globDest,pipe.globPipeExInt,PIPE_LEV_TRANS_DELAY);
						stopUpdate = true;
						visible = false;
					}
					vx = 0;
					vy = 0;
					return;
				}
				else if (pType == "enterHorz")
				{
					nx += horzPipeSpeed*dt;
					if (hLft - HRECT_PADDING_X > startPipeLoc)
					{
						EVENT_MNGR.levelTransfer(pipe.globDest,pipe.globPipeExInt,PIPE_LEV_TRANS_DELAY);
						stopUpdate = true;
						visible = false;
					}
					vx = 0;
					vy = 0;
					return;
				}
				else if (pType == "exitVert")
				{
					ny -= vertPipeSpeed*dt;
					vx = 0;
					vy = 0;
					if (hBot <= startPipeLoc)
					{
						completePipeExit();
					}
					return;
				}
			}
			else if (cState == ST_FLAG_SLIDE)
			{
				if (onGround && !(this is Link) && !(this is MegaMan) )
					stopAnim = true;
				return;
			}
			checkPlatform();
			if (C_HIT_DCT.length || L_HIT_DCT.length)
			{
				L_HIT_DCT.clear();
				for (var key:Object in C_HIT_DCT)
				{
					L_HIT_DCT.addItem(key,C_HIT_DCT[key]);
				}
				C_HIT_DCT.clear();
			}
			if (!cancelCheckState)
				checkState();
			checkBtns();
			if (!stuckInWall || disableStuckInWallShift)
				movePlayer();
			else if (!(this is Ryu) || (this is Ryu && cState != Ryu.ST_CLIMB && !(this as Ryu).CANCEL_GRAPPLE_TMR.running ) )
			{
				vx = 0;
				vy = 0;
				if (scaleX >= 0)
					nx -= STUCK_IN_WALL_SHIFT;
				else
					nx += STUCK_IN_WALL_SHIFT;
			}
			if (!onSpring)
				springBoost = false;
			if (level.waterLevel && cState != ST_DIE)
			{
				if (!bubbleTmr)
				{
					bubbleTmr = new CustomTimer(bubbleTmrDurMin,1);
					bubbleTmr.addEventListener(TimerEvent.TIMER_COMPLETE,bubbleTmrLsr);
					addTmr(bubbleTmr);
					bubbleTmr.start();
				}
				if (hTop <= GLOB_STG_TOP + TILE_SIZE*2)
				{
					if (underWater)
						exitWater();
				}
				else if (!underWater)
					enterWater();
				if (!underWater)
					gravity = defGravity;
				else
				{
					gravity = defGravityWater;
					if (!pulledDown && vy > vyMaxPsvWater)
						vy = vyMaxPsvWater;
					if (onGround && walksSlowUnderWater )
					{
						if (vx > vxMaxGroundWater)
							vx = vxMaxGroundWater;
						else if (vx < -vxMaxGroundWater)
							vx = -vxMaxGroundWater;
					}
				}
				if (underWater)
					_canStomp = false;
				pulledDown = false;
				pulledLeft = false;
				pulledRight = false;
			}
			onPipeVert = false;
			onPipeHorz = false;
			cloudPlatform = false;
			_stompedEnemyThisCycle = false;
			if (pipe && cState != "pipe")
				pipe = null;
			lastCharacterCheck();
		}
		override public function gotoAndStop(frame:Object, scene:String=null):void
		{
			if (hidesBmps)
				applyBmpVisibility(true,true);
			if (_replaceColor)
			{
				resetColor();
				super.gotoAndStop(frame,scene);
				if (flashArr)
					recolorBmps(flashArr[IND_FLASH_ARR_PAL_IN], flashArr[IND_FLASH_ARR_PAL_OUT], flashArr[IND_FLASH_ARR_IN_COLOR], flashArr[IND_FLASH_ARR_OUT_COLOR]);
			}
			else
				super.gotoAndStop(frame,scene);
			if (hidesBmps)
				applyBmpVisibility();
		}
		protected function applyBmpVisibility(value:Boolean=false,override:Boolean=false):void
		{
			if (!override)
				value = showBmps;
			for each (var bmp:Bitmap in currentBmpDct)
			{
				bmp.visible = value;
			}
		}
		private function bubbleTmrLsr(e:TimerEvent):void
		{
			if (!level.waterLevel)
			{
				bubbleTmr.reset();
				bubbleTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,bubbleTmrLsr);
				removeTmr(bubbleTmr);
				bubbleTmr = null;
				return;
			}
			if (wingTimer != null)
				return;
			var bubble:Bubble = new Bubble();
			level.addToLevel(bubble);
			bubbleTmr.reset();
			bubbleTmr.delay = Math.random()*(bubbleTmrDurMax - bubbleTmrDurMin) + bubbleTmrDurMin;
			bubbleTmr.start();
		}
		override public function setHitPoints():void
		{
			super.setHitPoints();
//			_boundsRect = hRect.getBounds(level);
		}
		protected function checkPlatform():void
		{
			if (onPlatform)
			{
				if (!isNaN(nyPlatform))
				{
					ny = nyPlatform;
					nyPlatform = NaN;
				}
				else if (!isNaN(dxPlatform) && !cloudPlatform)
				{
					nx += dxPlatform;
					dxPlatform = NaN;
				}
			}
		}
		public function activateWatchModeEnterPipe():void
		{
			BTN_MNGR.relPlyrBtns();
			pressRhtBtn();
			vxMax = ENTER_PIPE_VX_MAX;
		}
		protected function lastCharacterCheck():void
		{
			// for link and whoever else needs it
		}
		protected function movePlayer():void
		{
			if (rhtBtn && !lftBtn && !wallOnRight)
			{
				if (cState == "vine")
				{
					if (exitVine)
						getOffVine();
					else
						return;
				}
				vx += ax*dt;
				this.scaleX = 1;
			}
			if (lftBtn && !rhtBtn && !wallOnLeft)
			{
				if (cState == "vine")
				{
					if (exitVine)
						getOffVine();
					else
						return;
				}
				vx -= ax*dt;
				this.scaleX = -1;
			}
			if (lftBtn && rhtBtn)
			{
				vx *= Math.pow(fx,dt);
			}
			if (!lftBtn && !rhtBtn && onGround)
			{
				vx *= Math.pow(fx,dt);
			}

			/*if (attackBtn)
			{
				if (vx > maxRunSpeed) {vx = maxRunSpeed;}
				if (vx < -maxRunSpeed) {vx = -maxRunSpeed;}
			}*/

		}
		override protected function checkState():void
		{
			if (onGround && vx == 0)
			{
				setState("stand");
				if (lState != "stand")
					setStopFrame("stand");
			}
			else if (onGround && vx != 0)
			{
				setState("walk");
				if (lState != "walk")
					setPlayFrame("walkStart");
			}
		}
		protected function jump():void
		{

			onGround = false;
			vy = -jumpPwr;
			setState("jump");
			setStopFrame("jump");
		}
		protected function enterPipeVert():void
		{
			setState("pipe");
			pType = "enterVert";
			lockState = true;
			stopHit = true;
			defyGrav = true;
			behindGround = true;
			setStopFrame("stand");
			vx = 0;
			vy = 0;
			startPipeLoc = ny;
			ny += vertPipeSpeed*dt;
			GS_MNGR.gameState = "watch";
			SND_MNGR.playSound(SFX_GAME_PIPE);
			if (_replaceColor)
				endReplaceColor();
			BTN_MNGR.relPlyrBtns();
			STAT_MNGR.stopTimeLeft();
		}
		public function exitPipeVert(pt:PipeTransporter):void
		{
			pipe = pt;
			onScreen = true;
			setState(ST_PIPE);
			lockState = true;
			pType = "exitVert";
			stopHit = true;
			defyGrav = true;
			behindGround = true;
			onGround = false;
			setStopFrame("stand");
			vx = 0;
			vy = 0;
			startPipeLoc = pt.y - pt.height;
			x = pt.x;
			y = startPipeLoc + height;
			nx = x;
			ny = y;
			setHitPoints();
			GS_MNGR.lockGameState = false;
			GS_MNGR.gameState = GS_WATCH;
			GS_MNGR.lockGameState = true;
			SND_MNGR.playSound(SFX_GAME_PIPE);
			STAT_MNGR.stopTimeLeft();
		}
		protected function enterPipeHorz():void
		{
			if (cState != ST_WALK)
				setPlayFrame(walkStartLab);
			setState("pipe");
			pType = "enterHorz";
			lockState = true;
			stopHit = true;
			defyGrav = true;
			behindGround = true;
			vx = 0;
			vy = 0;
			startPipeLoc = hRht;
			nx += horzPipeSpeed*dt;
			GS_MNGR.gameState = "watch";
			SND_MNGR.playSound(SFX_GAME_PIPE);
			if (_replaceColor)
				endReplaceColor();
			BTN_MNGR.relPlyrBtns();
			STAT_MNGR.stopTimeLeft();
		}
		protected function completePipeExit():void
		{
			lockState = false;
			setState("stand");
			pType = null;
			onPipeVert = false;
			pipe = null;
			stopHit = false;
			defyGrav = false;
			behindGround = false;
			ny = startPipeLoc;
			onGround = true;
			GS_MNGR.lockGameState = false;
			GS_MNGR.gameState = GS_PLAY;
			BTN_MNGR.relPlyrBtns();
			BTN_MNGR.sendPlayerBtns();
			STAT_MNGR.startTimeLeft();
		}
		override public function drawObj():void
		{
			super.drawObj();
			if (!onScreen)
				onScreen = true;
		}
		// excutes once when attack button is pressed
		public function pressAtkBtn():void
		{
			atkBtn = true;
		}
		public function pressJmpBtn():void
		{
			if (onSpring)
				springBoost = true;
			jmpBtn = true;
		}
		public function pressSpcBtn():void
		{
			spcBtn = true;
		}
		public function pressSelBtn():void
		{
			selBtn = true;
		}
		public function pressUpBtn():void
		{
			upBtn = true;
		}
		public function pressDwnBtn():void
		{
			dwnBtn = true;
			if (onGround && onPipeVert)
				enterPipeVert();
		}
		public function pressLftBtn():void
		{
			lftBtn = true;
		}
		public function pressRhtBtn():void
		{
			rhtBtn = true;
		}
		public function pressPseBtn():void
		{

		}
		protected function activateStoredButtons():void
		{
			var n:int = STORED_BUTTONS_VEC.length;
			for (var i:int; i < n; i++)
			{
				var fun:Function = STORED_BUTTONS_VEC[0][0]; // always gets first element
				if (recordSeq)
					recordSeq.addEvent(STORED_BUTTONS_VEC[0][1]);
				fun();
				STORED_BUTTONS_VEC.shift();
			}
		}
		public function storeButton(buttonFct:Function, fctName:String):void
		{
			STORED_BUTTONS_VEC.push([buttonFct,fctName]);
		}
		protected function checkBtns():void
		{
			if (onPipeVert && dwnBtn && (onGround || canEnterPipesUngrounded) )
				enterPipeVert();
			else if (onPipeHorz && rhtBtn && (onGround || canEnterPipesUngrounded) )
				enterPipeHorz();
		}
		public function relUpBtn():void
		{
			upBtn = false;
		}
		public function relDwnBtn():void
		{
			dwnBtn = false;
		}
		public function relLftBtn():void
		{
			lftBtn = false;
			if (cState == ST_VINE)
				exitVine = true;
		}
		public function relRhtBtn():void
		{
			rhtBtn = false;
			if (cState == ST_VINE)
				exitVine = true;
		}
		// RELJUMPBTN
		public function relJmpBtn():void
		{
			jmpBtn = false;
		}
		// RELATTACKBTN
		public function relAtkBtn():void
		{
			atkBtn = false;
		}
		// RELSPECIALBTN
		public function relSpcBtn():void
		{
			spcBtn = false;
		}
		public function relSelBtn():void
		{
			selBtn = false;
		}
		public function relPseBtn():void
		{

		}
		// CHECKFRAME
		override public function checkFrame():void
		{
			//if (starPwr || cState == "takeDamage" || cState == "poweringUp") changeColor();
			//if (takeNoDamage) this.alpha = .5;
		}
		public function forceWaterStats():void
		{
			enterWater();
		}
		public function forceNonwaterStats():void
		{
			exitWater();
		}
		// CONVLAB
		public function convLab(_fLab:String):String
		{
			var num:int = pState - 1;
			if (num < 0)
				num = 0;
			return _fLab + suffixVec[num];
		}
		/*private function jump() {
			var smoothFall:Number = 6;
			var holdJump:Number = -15;
			initialJumpPower = -375;
			if (upBtn && onGround && !disableJump)
			{
				onGround = false;
				releasedUp = false;
				vy = 0;
				vy += initialJumpPower;
				jumped = true;

			}
			if (!onGround) {
				disableJump = true;
			}
			if (!upBtn && jumped) {
				releasedUp = true;
				jumped = false;
			}
			//in the air after releasing jump button
			/*if (releasedUp) {
				if (holdJump < -10) {
					smoothFall = holdJump + 5;
				}
				if (holdJump < -11) {
					smoothFall = holdJump + 3;
				} else if (holdJump < -12) {
					smoothFall = holdJump + 1;
				} else if (holdJump < -13) {
					smoothFall = holdJump;
				}
				vy += smoothFall;
			}
			//holding the jump button
			if (upBtn && !releasedUp && jumped) {
				//holdJump += -.2;
				//vy += holdJump;
			}
			if (onGround && !upBtn) {
				disableJump = false;
			}
		}*/

		protected function setStopFrame(_stopFrame:String):void
		{
			if (!lockFrame && currentFrameLabel != convLab(_stopFrame))
				gotoAndStop(convLab(_stopFrame));
			stopAnim = true;
		}
		protected function setPlayFrame(_stopFrame:String):void
		{
			if (!lockFrame && currentFrameLabel != convLab(_stopFrame))
				gotoAndStop(convLab(_stopFrame));
			stopAnim = false;
		}
		// GETPARFRAME
		protected function getParFrame(_parSeq:String):String
		{
			var cl:String = currentLabel;
			var num:uint = uint(cl.charAt(cl.indexOf("-")+1));
			if (num > numParFrames)
				num -= numParFrames;
			_parSeq += "-" + num.toString();
			return _parSeq;
		}
		override public function getLabNum(_fLab:String):uint
		{
			return super.getLabNum(convLab(_fLab));
		}
		protected function landOnGround():void
		{
			bounced = false;
		}
		override public function groundBelow(g:Ground):void
		{
			_fallBtwn = false;
			if (!lastOnGround && !onGround && !(g is SpringRed) && cState != ST_FLAG_SLIDE && cState != ST_VINE)
				landOnGround();
			super.groundBelow(g);
			if (!(g is SpringRed))
				_numContStomps = 0;
		}
		// simon overrides this function and does not call super
		override public function groundAbove(g:Ground):void
		{
			if (stuckInWall || lastStuckInWall || (!g.visible && brickState == BRICK_NONE) )
				return;
			_fallBtwn = false;
			hitCeiling = true;
			SND_MNGR.playSound(SND_GAME_HIT_CEILING);
			ny = g.hBot + hHeight;
			if (jumped)
			{
				vy = CIELING_DISPLACE;
				//ny += 5;
			}
			super.groundAbove(g);
		}
		override public function groundOnSide(g:Ground,side:String):void
		{
			if (stuckInWall || lastStuckInWall)
				return;
			_fallBtwn = false;
			if (side == "left")
			{
				if (vx < 0)
				{
					if (!onGround)
						lastVX = vx;
					vx = 0;
				}
				if (g)
					nx = g.hRht + hWidth/2;
				wallOnLeft = true;
			}
			else if (side == "right")
			{
				if (vx > 0)
				{
					if (!onGround)
						lastVX = vx;
					vx = 0;
				}
				wallOnRight = true;
				if (g)
					nx = g.hLft - hWidth/2;
			}
			super.groundOnSide(g,side);
		}
		override public function hitEnemy(enemy:Enemy,side:String):void
		{
			if (GS_MNGR.gameState != GS_PLAY || enemy.cState == ST_DIE)
				return;
			if (starPwr || (enemy is KoopaGreen && (KoopaGreen(enemy).cState == "shell" || KoopaGreen(enemy).NO_HIT_SHELL_TMR.running)))
			{
				// do nothing
			}
			else if (side == "bottom" && enemy.stompable && canStomp && !nonInteractive)
				bounce(enemy);
			else if (!takeNoDamage)
				takeDamage(enemy);
		}
		public function stompEnemy():void
		{
			_numContStomps++;
			_stompedEnemyThisCycle = true;
		}
		override public function hitPickup(pickup:Pickup,showAnimation:Boolean = true):void
		{
			if (dead)
				return;
			if ( !(level is CharacterSelect) )
				TutorialManager.TUT_MNGR.checkTutorial(pickup.type,true);
			if (poweringUp)
				getMushroomEnd();
			var hasFireFlower:Boolean = upgradeIsActive(FIRE_FLOWER);
			pickup.touchPlayer(this);
			if (PickupInfo.AMMO_DCT[pickup.type])
				STAT_MNGR.numAmmoPickupsCollected++;
			if (pickup.mainType == PickupInfo.MAIN_TYPE_UPGRADE)
			{
				if (canGetMushroom && !STAT_MNGR.getObtainedUpgradesDct(charNum)[MUSHROOM])
				{
					pickup.type = MUSHROOM;
					pickup.playsRegularSound = true;
				}
				else if (GameSettings.classicMode && pickup.type == MUSHROOM && upgradeIsActive(MUSHROOM) )
				{
					pickup.type = FIRE_FLOWER;
					pickup.playsRegularSound = true;
				}
				STAT_MNGR.addCharUpgrade(charNum,pickup.type);
			}
			switch(pickup.type)
			{
				case PickupInfo.MUSHROOM:
				{
					level.scorePop(P_UP_SCORE_VAL,pickup.nx,pickup.ny-pickup.height);
					if ( !(this is MarioBase) && GameSettings.powerupMode != PowerupMode.Classic)
					{
						if (pickup is Mushroom)
							(pickup as Mushroom).transferStoredUpgrades();
						else // acting as Mushroom
							fakeMushroomUpgrades();
					}
					getMushroom();
					if (showAnimation)
						SND_MNGR.playSound(SFX_GAME_POWER_UP);
					break;
				}
				case PickupInfo.EXPLODING_RABBIT:
				{
					level.scorePop(P_UP_SCORE_VAL,pickup.nx,pickup.ny-pickup.height);
					fullyPowerup();
					SND_MNGR.playSound(SFX_GAME_POWER_UP);
					break;
				}
				case PickupInfo.MARIO_FIRE_FLOWER:
				{
					level.scorePop(P_UP_SCORE_VAL,pickup.nx,pickup.ny-pickup.height);
					if (showAnimation)
						SND_MNGR.playSound(SFX_GAME_POWER_UP);
					if ( !(this is MarioBase) && !hasFireFlower )
						getMushroom();
					break;
				}
				case PickupInfo.GREEN_MUSHROOM:
				{
					level.scorePop(ScoreValue.EARN_NEW_LIFE_NUM_VAL,pickup.nx,pickup.ny-pickup.height);
					break;
				}
				case PickupInfo.POISON_MUSHOOM:
				{
					if (!starPwr)
						takeDamage(pickup);
					break;
				}
				case PickupInfo.STAR:
				{
					level.scorePop(P_UP_SCORE_VAL,pickup.nx,pickup.ny-pickup.height);
					activateStarPwr();
					SND_MNGR.playSound(SFX_GAME_POWER_UP);
					var tm:TutorialManager = TutorialManager.TUT_MNGR;
					tm.checkTutorial(tm.TYPE_STAR,true);
					break;
				}
				case PickupInfo.COIN:
				{
					EVENT_MNGR.getCoin();
					break;
				}
				case PickupInfo.HUDSON_BEE:
				{
					level.scorePop(HudsonBee.SCORE_VALUE,pickup.nx,pickup.ny-pickup.height);
//					playDefaultPickupSoundEffect();
					SND_MNGR.playSound(SFX_GAME_POWER_UP);
					break;
				}
				case PickupInfo.ATOM:
				{
					level.scorePop(Atom.SCORE_VALUE,pickup.nx,pickup.ny-pickup.height);
					level.killAllEnemiesOnScreen();
//					playDefaultPickupSoundEffect();
					if (GameSettings.mapSkin != BmdInfo.SKIN_NUM_CASTLEVANIA)
						SND_MNGR.playSound(SFX_GAME_POWER_UP);
					else
						SND_MNGR.playSound(SoundNames.SFX_SIMON_ROSARY);
					break;
				}
				case PickupInfo.HAMMER:
				{
					if (hammerWeapon)
						hammerWeapon.destroy();
					hammerWeapon = new HammerWeapon(this);
					level.scorePop(HammerPickup.SCORE_VALUE,pickup.nx,pickup.ny-pickup.height);
					level.addToLevel(hammerWeapon);
//					playDefaultPickupSoundEffect();
					SND_MNGR.playSound(SFX_GAME_POWER_UP);
					break;
				}
				case PickupInfo.CLOCK:
				{
					level.scorePop(Clock.SCORE_VALUE,pickup.nx,pickup.ny-pickup.height);
//					playDefaultPickupSoundEffect();
					SND_MNGR.playSound(SFX_GAME_POWER_UP);
					STAT_MNGR.timeLeft += Clock.TIME_TO_ADD;
					if (STAT_MNGR.secondsLeft)
						STAT_MNGR.checkCancelSecondsLeft();

					break;
				}
				case PickupInfo.WING:
				{
//					playDefaultPickupSoundEffect();
					SND_MNGR.playSound(SFX_GAME_POWER_UP);
					level.scorePop(Wing.SCORE_VALUE,pickup.nx,pickup.ny-pickup.height);
					level.forceWaterLevel();
					if (wingTimer != null)
						destroyWingTimer();
					wingTimer = new CustomTimer(WING_TIMER_DURATION, 1);
					addTmr(wingTimer);
					wingTimer.addEventListener(TimerEvent.TIMER_COMPLETE, wingTimerHandler, false, 0, true);
					wingTimer.start();
					break;
				}
				case PickupInfo.VINE:
				{
					if (cState != "vine" && ny <= (pickup as Vine).yStart)
						getOnVine(pickup as Vine);
					break;
				}
				case PickupInfo.LEVEL_EXIT:
				{
					touchLevelExit();
					break;
				}
				case PickupInfo.PIPE_TRANSPORTER:
				{
					var pt:PipeTransporter = pickup as PipeTransporter;
					if (pt.ptType == "global")
					{
						if (pt.axis == "horizontal" && onGround)
							setOnPipeHorz(pt);
						else if (pt.axis == "vertical")
						{
							if (hMidX >= hLft && hMidX <= hRht)
								setOnPipeVert(pt);
						}
					}
					break;
				}
				default:
				{

				}
			}
		}

		private function fakeMushroomUpgrades():void
		{
			var curCharNum:int = STAT_MNGR.curCharNum;
			var tierOnDamage:int = STAT_MNGR.storedTierVec[curCharNum];
			STAT_MNGR.storedTierVec[curCharNum] = null;
			var storedUpgrades:CustomDictionary = STAT_MNGR.getStoredUpgrades();
			var viewedUpgrades:CustomDictionary;
			if (storedUpgrades)
			{
				viewedUpgrades = STAT_MNGR.storedViewedUpgradesVec[curCharNum].clone();
				STAT_MNGR.storedViewedUpgradesVec[curCharNum] = null;
				STAT_MNGR.addStoredUpgrades(curCharNum, storedUpgrades, tierOnDamage, viewedUpgrades);
			}
		}

		protected function fullyPowerup():void
		{
			if (GameSettings.classicMode)
			{
				if ( !upgradeIsActive(MUSHROOM) )
					hitRandomUpgrade(charNum,false);
				if ( !upgradeIsActive(FIRE_FLOWER) )
					hitRandomUpgrade(charNum, false);
				setAllAmmoToMax();
			}
			else
			{
				addAllPowerups();
				getAllDroppedUpgrades();
				setAllAmmoToMax();
			}
		}

		protected function addAllPowerups():void
		{
			while ( !STAT_MNGR.charIsFullyUpgraded(charNum) )
			{
				hitRandomUpgrade(charNum,false);
			}
		}

		protected function playDefaultPickupSoundEffect():void
		{
			// for override
		}
		protected function wingTimerHandler(event:TimerEvent):void
		{
			if (!level.initialWaterLevel && !Cheats.waterMode)
				level.forceNonwaterLevel();
			destroyWingTimer();
		}

		private function destroyWingTimer():void
		{
			removeTmr(wingTimer);
			wingTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, wingTimerHandler);
			wingTimer = null;
		}
		public function revivalBoost():void
		{

		}
		public function touchLevelExit():void
		{
			if (touchedExit || GS_MNGR.gameState == GS_PLAY)
				return;
			touchedExit = true;
			EVENT_MNGR.enterLevelExit();
			if (level.flagPole != null) // this is not a castle level
			{
				visible = false;
				stopHit = true;
				stopAnim = true;
				stopUpdate = true;
				BTN_MNGR.relPlyrBtns();
				vx = 0;
				vy = 0;
			}
			else
				BTN_MNGR.relPlyrBtns();
			if (this is Samus)
				Samus(this).muteStepSounds = true; // sorry I made it sloppy
		}
		private function setOnPipeVert(_pipe:PipeTransporter):void
		{
			pipe = _pipe;
			onPipeVert = true;
		}
		private function setOnPipeHorz(_pipe:PipeTransporter):void
		{
			pipe = _pipe;
			onPipeHorz = true;
		}
		protected function getOffVine():void
		{
			if (lftBtn)
				nx = vine.hLft - hWidth*.5;
			else if (rhtBtn)
				nx = vine.hRht + hWidth*.5;
			setState("neutral");
			defyGrav = false;
			vine = null;
			if (GS_MNGR.gameState == "watch")
			{
				nx += 5;
				x = nx;
			}
		}
		protected function getOnVine(_vine:Vine):void
		{
			setState("vine");
			vine = _vine;
			nx = vine.hMidX;
			if (hTop <= vine.hTop)
				ny = vine.hTop + hHeight;
			vx = 0;
			vy = 0;
			defyGrav = true;
			setStopFrame("climbStart");
			exitVine = false;
		}
		// this is called by Vine.
		public function climbVineStarter(_vine:Vine):void
		{
			ny = GLOB_STG_BOT + height;
			BTN_MNGR.relPlyrBtns();
			getOnVine(_vine);
			this.x = nx;
			visible = true;
			this.y = ny;
			setHitPoints();
			upBtn = true;
		}
		protected function checkVinePosition():void
		{
			if (hTop < VINE_WATCH_Y && GS_MNGR.gameState == GS_PLAY)
			{
				GS_MNGR.gameState = GS_WATCH;
				BTN_MNGR.relPlyrBtns();
				upBtn = true;
			}
			else if (GS_MNGR.gameState == GS_PLAY && hBot >= GLOB_STG_BOT - TILE_SIZE*2)
			{
				ny = GLOB_STG_BOT - TILE_SIZE*2;
				if (vy > 0)
					vy = 0;
			}
			else if (hBot < GLOB_STG_TOP)
			{
				var vd:String = vine.vineDest;
				if (vd.length) EVENT_MNGR.levelTransfer(vd,vine.vineExInt);
			}
			else if (hTop <= vine.hTop)
			{
				if (hTop > GLOB_STG_TOP)
				{
					ny = vine.hTop + hHeight;
					if (vy < 0)
						vy = 0;
				}
				if (GS_MNGR.gameState == GS_WATCH && hTop > VINE_WATCH_Y)
				{
					upBtn = false;
					rhtBtn = true;
					exitVine = true;
					getOffVine();
					upBtn = true;
					rhtBtn = false;
					BTN_MNGR.relPlyrBtns();
					GS_MNGR.gameState = GS_PLAY;
					BTN_MNGR.sendPlayerBtns();
					level.tsTxt.showTime();
				}
			}
		}
		protected function checkVineBtns():void
		{
			if (upBtn)
			{
				vy = -VINE_CLIMB_SPEED;
				stopAnim = false;
			}
			else if (dwnBtn)
			{
				vy = VINE_CLIMB_SPEED;
				stopAnim = false;
			}
			else
			{
				vy = 0;
				stopAnim = true;
			}
		}
		protected function getAmmo(ammoType:String):int
		{
			return STAT_MNGR.getAmmoRemaining(charNum,ammoDct[ammoType][IND_AMMO_ARR_IND]);
		}
		protected function setAmmo(ammoType:String,value:int):void
		{
			if ( Cheats.infiniteAmmo || starPwr)
			{
				var curAmmo:int = getAmmo(ammoType);
				if (value < curAmmo )
					value = curAmmo;
			}
			var arr:Array = ammoDct[ammoType];
			var max:int = getMaxAmmo(ammoType);
			if (value > max)
				value = max;
			else if ( value < 0)
				value = 0;
			STAT_MNGR.setAmmoRemaining(charNum,arr[IND_AMMO_ARR_IND],value);
		}
		protected function getMaxAmmo(ammoType:String):int
		{
			return ammoDct[ammoType][IND_AMMO_ARR_MAX];
		}
		protected function getDefaultAmmo(ammoType:String):int
		{
			return ammoDct[ammoType][IND_AMMO_ARR_DEFAULT];
		}
		protected function setMaxAmmo(ammoType:String,value:int):void
		{
			ammoDct[ammoType][IND_AMMO_ARR_MAX] = value;
		}
		protected function increaseAmmoByValue(ammoType:String,value:int):void
		{
			setAmmo( ammoType, getAmmo(ammoType) + value );
		}
		protected function decreaseAmmoByValue(ammoType:String,value:int):void
		{
			setAmmo( ammoType, getAmmo(ammoType) - value );
		}
		protected function hasEnoughAmmo(ammoType:String,ammoDeplType:String = null,cost:int = -1):Boolean
		{
			if (Cheats.infiniteAmmo || level is TitleLevel || starPwr)
				return true;
			if (!ammoDeplType)
				ammoDeplType = ammoType;
			if (cost == -1)
				cost = getAmmoCost(ammoDeplType);
			 return getAmmo(ammoType) - cost >= 0;
		}
		protected function decAmmo(ammoType:String,ammoDeplType:String = null):void
		{
			if (!ammoDeplType)
				ammoDeplType = ammoType;
			decreaseAmmoByValue( ammoType, getAmmoCost(ammoDeplType) );
		}
		protected function getAmmoCost(ammoDeplType:String):int
		{
			var ammoDeplDct:CustomDictionary = classObj[AMMO_DEPLETION_DCT_PROP_NAME];
			return ammoDeplDct[ammoDeplType][IND_AMMO_DEPL_ARR_COST];
		}
		protected function getAmmoTypeWithLeastAmmo():String
		{
			var lowestNum:int = int.MAX_VALUE;
			var lowestType:String;
			for (var ammoType:String in ammoDct)
			{
				var num:int = getAmmo(ammoType);
				if (upgradeIsActive(ammoType) && num < lowestNum)
				{
					lowestNum = num;
					lowestType = ammoType;
				}
			}
			return lowestType;
		}
		public function setAllAmmoToMax():void
		{
			for (var ammoType:String in ammoDct)
			{
				setAmmo( ammoType, getMaxAmmo(ammoType) );
			}
		}

		public function setAllAmmoToDefault():void
		{
			for (var ammoType:String in ammoDct)
				setAmmo( ammoType, getDefaultAmmo(ammoType) );
		}
		// POWERUP
		protected function getMushroom():void
		{
//			if (pState == 3)
//				return;
			if (GS_MNGR.gameState == GameStates.CHARACTER_SELECT)
				return;
			var cl:String = currentLabel;
			setDamageInfoArr();
			setState(ST_GET_MUSHROOM);
			poweringUp = true;
			lockState = true;
			lockFrame = true;
			startReplaceColor();
			stopAnim = true;
			freezeGame();
		}
		// MegaMan overrides this function and does not call super
		protected function getMushroomEnd():void
		{
			swapPsEnd();
			if (!starPwr)
				endReplaceColor();
			poweringUp = false;
			var pStateNum:int = pState + 1;
			if (pStateNum > 3)
				pStateNum = 3;
			setPowerState(pStateNum);
//			if (!pStateRecolor)
//				setStopFrame(hitFrameLabel);
			lockState = false;
			lockFrame = false;
			getDataFromDamageInfoArr();
		}

		protected function beforeLoseSomeUpgradesCalled():void
		{

		}

		private function get shouldDieInstantly():Boolean
		{
			if (GameSettings.damageResponse == DamageResponse.InstantDeath && GameSettings.powerupMode == PowerupMode.Modern)
				return true;
			else if (GameSettings.classicDamageResponse == ClassicDamageResponse.InstantDeath && GameSettings.classicMode)
				return true;
			else
				return false;
		}

		protected function takeDamage(source:LevObj):void
		{
			if (takeNoDamage || level is TitleLevel)
				return;
			var dif:int = GameSettings.difficulty;
			if ( !canGetMushroom || !upgradeIsActive(MUSHROOM) || shouldDieInstantly )
			{
				die(source);
				return;
			}
			else
			{
				if (GameSettings.classicMode)
				{
					var upgradeType:String = null;
					var hadFireFlower:Boolean = upgradeIsActive(FIRE_FLOWER);
					// remove fire flower upgrades
					if (hadFireFlower)
					{
						STAT_MNGR.removeCharUpgrade(charNum, FIRE_FLOWER, true);
						for each( upgradeType in classicLoseFireFlowerUpgrades)
							STAT_MNGR.removeCharUpgrade(charNum, upgradeType, true);
					}

					// remove mushroom upgrades
					if (GameSettings.classicDamageResponse == ClassicDamageResponse.LoseEverything || !hadFireFlower)
					{
						STAT_MNGR.removeCharUpgrade(charNum, MUSHROOM, true);
						for each( upgradeType in classicLoseMushroomUpgrades)
							STAT_MNGR.removeCharUpgrade(charNum, upgradeType, true);
					}
				}
				else
				{
					STAT_MNGR.removeCharUpgrade(charNum,MUSHROOM);
					if (GameSettings.damageResponse != DamageResponse.KeepUpgrades)
					{
						if (GameSettings.damageResponse == DamageResponse.LoseSomeUpgrades)
						{
							beforeLoseSomeUpgradesCalled();
							STAT_MNGR.removeAllUpgradesForChar(charNum,true);
						}
						else if (GameSettings.damageResponse == DamageResponse.LoseAllUpgrades)
						{
							STAT_MNGR.removeAllUpgradesForChar(charNum, false, true);
							addStartWithUpgrades(classObj[START_WITH_UPGRADES_PROP_NAME]);
						}
					}
					else if (this is MarioBase)
						STAT_MNGR.removeCharUpgrade(charNum,PickupInfo.FIRE_FLOWER);
				}
				TopScreenText.instance.updateUpgIcons();
				takeDamageStart(source);
			}
			/*if (dif == Difficulties.SUPER_EASY || dif == Difficulties.EASY)
			{
				nPState = pState - 1;
				takeDamageStart(pState,nPState,source);
			}
			else
			{
				nPState = DEF_PS;
				takeDamageStart(pState,nPState,source);
			}*/
		}
		protected function takeDamageStart(source:LevObj):void
		{
			startAndDamageFcts();
		}
		protected function takeDamageEnd():void
		{
			dispatchEvent( new Event(CustomEvents.CHARACTER_TAKE_DAMAGE_END) );
			takeNoDamage = true;
			if (SWAP_PS_VEC.length)
				swapPsEnd();
			setPowerState(nPState);
//			if (!pStateRecolor)
//				setStopFrame(hitFrameLabel);
			lockState = false;
			lockFrame = false;
//			if (!starPwr)
//				endReplaceColor();
			getDataFromDamageInfoArr();
			alpha = TD_ALPHA;
			noDamageTmr.start();
		}
		protected function flickerTmrHandler(event:Event):void
		{
			visible = !visible;
		}
		protected function flickerStart():void
		{
			if (!flickerTmr)
			{
				flickerTmr = new GameLoopTimer(flickerTmrDel);
				flickerTmr.addEventListener(TimerEvent.TIMER,flickerTmrHandler,false,0,true);
			}
			flickerTmr.start();
			visible = true;
		}
		protected function flickerStop():void
		{
			if (flickerTmr)
				flickerTmr.stop();
			visible = true;
		}
		protected function setDamageInfoArr(fLab:Boolean = true, stpAnim:Boolean = true, state:Boolean = true):void
		{
			if (fLab)
				damageInfoArr[IND_DAMAGE_INFO_ARR_LABEL] = removeSuffix(currentLabel);
			if (stpAnim)
				damageInfoArr[IND_DAMAGE_INFO_ARR_STOP_ANIM] = stopAnim;
			if (state)
				damageInfoArr[IND_DAMAGE_INFO_ARR_STATE] = cState;
		}
		protected function getDataFromDamageInfoArr(fLab:Boolean = true, stpAnim:Boolean = true, state:Boolean = true):void
		{
			if (fLab)
				setStopFrame(damageInfoArr[IND_DAMAGE_INFO_ARR_LABEL]);
			if (stpAnim)
				stopAnim = damageInfoArr[IND_DAMAGE_INFO_ARR_STOP_ANIM];
			if (state)
				setState(damageInfoArr[IND_DAMAGE_INFO_ARR_STATE]);
		}
		public static function getAvailableUpgrades(cNum:int):Vector.<CustomDictionary>
		{
			var classObj:Class = CharacterInfo.getCharClassFromNum(cNum);
			var readArr:Array = classObj[OBTAINABLE_UPGRADES_ARR_PROPERTY_NAME];
			var n:int = readArr.length;
			var returnVec:Vector.<CustomDictionary> = new Vector.<CustomDictionary>();
			for (var i:int = 0; i < n; i++)
			{
				var dct:CustomDictionary = new CustomDictionary();
				returnVec[i] = dct;
				var itemReadArr:Array = readArr[i];
				var n2:int = itemReadArr.length;
				for (var j:int = 0; j < n2; j++)
				{
					dct.addItem(itemReadArr[j]);
				}
			}
			return returnVec;
		}
		public static function getSingleObjVec(cNum:int):CustomDictionary
		{
//			this is nested inside a Vector for no reason
			var classObj:Class = CharacterInfo.getCharClassFromNum(cNum);
			var readArr:Array = classObj[SINGLE_UPGRADES_ARR_PROP_NAME];
			var n:int = readArr.length;
//			var returnVec:Vector.<CustomDictionary> = new Vector.<CustomDictionary>();
			var dct:CustomDictionary = new CustomDictionary();
			for (var i:int = 0; i < n; i++)
			{
				dct.addItem( readArr[i] );
//				returnVec[i] = dct;
//				var itemReadArr:Array = readArr[i];
//				var n2:int = itemReadArr.length;
//				for (var j:int = 0; j < n2; j++)
//				{
//					dct.addItem(itemReadArr[j]);
//				}
			}
			return dct;
		}
		public static function getAllUpgradesDct(cNum:int):CustomDictionary
		{
			var classObj:Class = CharacterInfo.getCharClassFromNum(cNum);
			var readArr:Array = classObj[OBTAINABLE_UPGRADES_ARR_PROPERTY_NAME];
			var mushroomArr:Array = classObj[MUSHROOM_UPGRADES_PROP_NAME];
			var n:int = readArr.length;
			var returnVec:Vector.<CustomDictionary> = new Vector.<CustomDictionary>();
			var dct:CustomDictionary = new CustomDictionary();
			for (var i:int = 0; i < n; i++)
			{
				returnVec[i] = dct;
				var itemReadArr:Array = readArr[i];
				var n2:int = itemReadArr.length;
				for (var j:int = 0; j < n2; j++)
				{
					dct.addItem(itemReadArr[j]);
				}
				for each (var str:String in mushroomArr)
				{
					dct.addItem(str);
				}
			}
			return dct;
		}
		public static function getSkinOrderVec(cNum:int):Vector.<int>
		{
			var classObj:Class = CharacterInfo.getCharClassFromNum(cNum) as Class;
			var arr:Array = classObj[SKIN_ORDER_ARR_PROP_NAME];
			return Vector.<int>( arr );
		}
		public static function getAmmoVec(cNum:int):Array
		{
			var classObj:Class = CharacterInfo.getCharClassFromNum(cNum) as Class;
			var readArr:Array = classObj[AMMO_ARR_PROP_NAME];
			var returnVec:Array = [];
			if (!readArr)
				return returnVec;
			var dctToWrite:CustomDictionary = new CustomDictionary();
			var n:int = readArr.length;
			for (var i:int = 0; i < n; i++)
			{
				var arr:Array = readArr[i];
				var itemName:String = arr[IND_AMMO_ARR_IND];
				arr[IND_AMMO_ARR_IND] = i;
				dctToWrite.addItem(itemName,arr);
				returnVec[i] = arr[IND_AMMO_ARR_DEFAULT];
			}
			var targetDct:CustomDictionary = classObj[AMMO_DCT_PROP_NAME];
			dctToWrite.clone(targetDct);
			setUpAmmoDepletionDct(cNum);
			return returnVec;
		}

		private static function setUpAmmoDepletionDct(cNum:int):void
		{
			var classObj:Class = CharacterInfo.getCharClassFromNum(cNum) as Class;
			var readArr:Array = classObj[AMMO_DEPLETION_ARR_PROP_NAME];
			var dct:CustomDictionary = classObj[AMMO_DEPLETION_DCT_PROP_NAME];
			var n:int = readArr.length;
			for (var i:int = 0; i < n; i++)
			{
				var arr:Array = readArr[i];
				var type:String = arr[IND_AMMO_DEPL_ARR_TYPE];
				dct.addItem( type, arr );
			}
		}
		protected function freezeGame():void
		{
			freezeGameTmr.start();
			level.freezeGame();
		}
		private function removeSuffix(str:String):String
		{
			var ind:int = str.indexOf("_");
			if (ind != -1)
				str = str.substr(0,ind);
			return str;
		}
		protected function freezeGameTmrHandler(e:TimerEvent):void
		{
			freezeGameTmr.reset();
			if (!MessageBox.activeInstance || level is TitleLevel)
				level.unfreezeGame();
			if (cState == ST_TAKE_DAMAGE)
				takeDamageEnd();
			else if (cState == ST_GET_MUSHROOM)
				getMushroomEnd();
			else if (cState == ST_GET_UPGRADE)
				getUpgradeEnd();
		}

		protected function getUpgradeStart(upgrade:Pickup):void
		{

		}
		protected function getUpgradeEnd():void
		{

		}
		protected function hitAnimation():void
		{
			var cl:String = currentLabel;
//			hitFrameLabel = cl.substring(0,cl.length-2);
//			hitStopAnim = stopAnim;
			if (this is MegaMan || this is Simon)
				setStopFrame("takeDamage");
			else
				stopAnim = true;
			lockFrame = true;
		}
		public function initiateDeath(source:LevObj = null):void
		{
			dead = true;
			setState("die");
			lockState = true;
			vx = 0;
			vy = 0;
			if (_fellInPit)
				initiatePitDeath();
			else
				initiateNormalDeath(source);
		}
		protected function initiatePitDeath():void
		{
			EVENT_MNGR.startDieTmr(_dieTmrDel);
			_fellInPit = true;
		}
		protected function initiateNormalDeath(source:LevObj = null):void
		{

		}
		protected function startReplaceColor():void
		{
			_replaceColor = true;
		}
		protected function endReplaceColor():void
		{
			visible = true;
			_replaceColor = false;
			flashArr = null;
			resetColor();
		}
		protected function noDamageTmrLsr(e:TimerEvent):void
		{
			noDamageTmr.reset();
			if (!neverTakeDamage)
			{
				takeNoDamage = false;
				alpha = 1;
			}
			if (flickerTmr && flickerTmr.running)
				flickerStop();
		}
		// DIE
		public function die(source:LevObj = null):void
		{
			if (GS_MNGR.gameState != GS_PLAY || level is TitleLevel)
				return;
			if (!dead)
			{
				if (hammerWeapon != null)
					hammerWeapon.destroy();
				if (_fellInPit)
				{
					if (Cheats.bouncyPits)
					{
						//ny = GLOB_STG_TOP;
						ny = GLOB_STG_BOT + hHeight;
						vy = -1000;

						y = ny;
						setHitPoints();
						_fellInPit = false;
						return;
					}
					stopAnim = true;
					stopUpdate = true;
					stopHit = true;
					visible = false;
				}
				//if (GameSettings.campaignMode == CampaignModes.TEAM_SURVIVAL && !Cheats.infiniteLives)
				//	pState = PS_FALLEN;
				//else
				pState = PS_NORMAL;
				EVENT_MNGR.playerDie();
				if (!fellInPit)
					level.freezeGameDeath(source);
				else
					initiateDeath();
			}
			removeAllHitTestableItems();
			addHitTestableItem(HT_BRICK);
			addHitTestableItem(HT_GROUND_NON_BRICK);
			addHitTestableItem(HT_PLATFORM);
		}
		public function teleport(offset:Number):void
		{
			var blah:Number = nx;
			nx += offset;
			setHitPoints();
			level.checkAllObjectsOnScreen = true;
			level.forceShiftScreenToFollowPlayer = true;
			level.background.setOffset();
			level.foreground.setOffset();
		}
		protected function activateStarPwr():void
		{
			if (starPwr)
			{
				starPwrTmr1.reset();
				starPwrTmr1.removeEventListener(TimerEvent.TIMER_COMPLETE,starPwrTmr1Handler);
				starPwrTmr1 = null;
			}
			starPwrTmr1 = new CustomTimer(STAR_PWR_TMR_1_DUR,1);
			addTmr(starPwrTmr1);
			starPwrTmr1.addEventListener(TimerEvent.TIMER_COMPLETE,starPwrTmr1Handler,false,0,true);
			starPwrTmr1.start();
			starPwr = true;
			TopScreenText.instance.updateUpgIcons();
			flashAnimTmr = STAR_PWR_FLASH_ANIM_TMR;
			startReplaceColor();
			_starPwrBgmShouldBePlaying = true;
			SND_MNGR.starPwrStart();
		}
		protected function starPwrTmr1Handler(e:TimerEvent):void
		{
			if (starPwrTmr1)
			{
				starPwrTmr1.stop();
				starPwrTmr1.removeEventListener(TimerEvent.TIMER_COMPLETE,starPwrTmr1Handler);
				starPwrTmr1 = null;
			}
			starPwrTmr2 = new CustomTimer(STAR_PWR_TMR_2_DUR,1);
			addTmr(starPwrTmr2);
			starPwrTmr2.addEventListener(TimerEvent.TIMER_COMPLETE,starPwrTmr2Handler,false,0,true);
			starPwrTmr2.start();
			flashAnimTmr = STAR_PWR_SLOW_FLASH_ANIM_TMR;

		}
		protected function starPwrTmr2Handler(e:TimerEvent):void
		{
			if (starPwrTmr2)
			{
				starPwrTmr2.stop();
				starPwrTmr2.removeEventListener(TimerEvent.TIMER_COMPLETE,starPwrTmr2Handler);
				starPwrTmr2 = null;
			}
			starPwrTmr3 = new CustomTimer(STAR_PWR_TMR_3_DUR,1);
			addTmr(starPwrTmr3);
			starPwrTmr3.addEventListener(TimerEvent.TIMER_COMPLETE,starPwrTmr3Handler,false,0,true);
			starPwrTmr3.start();
			_starPwrBgmShouldBePlaying = false;
			SND_MNGR.starPwrEnd();
		}
		protected function starPwrTmr3Handler(e:TimerEvent):void
		{
			if (starPwrTmr3)
			{
				starPwrTmr3.stop();
				starPwrTmr3.removeEventListener(TimerEvent.TIMER_COMPLETE,starPwrTmr3Handler);
				starPwrTmr3 = null;
			}
			starPwr = false;
			endReplaceColor();
			flashAnimTmr = STAR_PWR_FLASH_ANIM_TMR;
			visible = true;
			resetColor();
			TopScreenText.instance.updateUpgIcons();
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
			numColorRows = palette.numRows - 1;
			rowOfs = 1;
			if ( flashCtr > numColorRows - 1 )
				flashCtr = 0;
			setFlashArr(defColors, palette, IND_DEF_COLORS_OUT, rowOfs + flashCtr);
			recolorBmps(flashArr[CustomMovieClip.IND_FLASH_ARR_PAL_IN], flashArr[CustomMovieClip.IND_FLASH_ARR_PAL_OUT], flashArr[CustomMovieClip.IND_FLASH_ARR_IN_COLOR], flashArr[CustomMovieClip.IND_FLASH_ARR_OUT_COLOR]);
		}

		// called when character changes skin
		public function setCurrentBmdSkin(bmc:BmdSkinCont, characterInitiating:Boolean = false):void
		{
			currentBmdSkin = bmc;
			skinNum = STAT_MNGR.getCharSkinNum(charNum);
			palettePowerUp = paletteSheet.getPaletteFromRow( IND_PALETTE_POWER_UP, skinNum );
			paletteStar = paletteSheet.getPaletteFromRow( IND_PALETTE_STAR, skinNum );
			paletteMain = paletteSheet.getPaletteFromRow( IND_PALETTE_MAIN, skinNum );
			defColors = paletteMain.extractRowsAsPalette(0,1);
//			bmdMaster = bmc.bmd;
			gotoAndStop(currentFrame);
			for each (var subMc:SubMc in subMcDct)
			{
				subMc.gotoAndStop(subMc.currentFrame);
				subMc.setUpCommonPalettes();
			}
			if (initiated)
				setPowerState(pState);
			TopScreenText.instance.refreshAmmoIcon();
//			setUpFlashPaletteOrder();
		}
		protected function changeColor():void
		{
			var numMatrices:int = 6;
			var matrix:Array = new Array();
			if (colorNum > numMatrices)
				colorNum = 1;
			switch (colorNum)
			{
				case 1:
					matrix = matrix.concat([0, 1, 0, 0, 0]); // red
					matrix = matrix.concat([0, 0, 1, 0, 0]); // green
					matrix = matrix.concat([1, 0, 0, 0, 0]); // blue
					matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
					break;
				case 2:
					matrix = matrix.concat([0, 0, 1, 0, 0]); // red
					matrix = matrix.concat([1, 0, 0, 0, 0]); // green
					matrix = matrix.concat([0, 1, 0, 0, 0]); // blue
					matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
					break;
				case 3:
					matrix = matrix.concat([0, 1, 3, 0, 0]); // red
					matrix = matrix.concat([0, 0, 0, 0, 0]); // green
					matrix = matrix.concat([0, 0, 1, 0, 0]); // blue
					matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
					break;
				case 4:
					matrix = matrix.concat([0, 0, 1, 0, 0]); // red
					matrix = matrix.concat([0, 2, 1, 0, 0]); // green
					matrix = matrix.concat([1, 0, 1, 0, 0]); // blue
					matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
					break;
				case 5:
					matrix = matrix.concat([0, .5, 1, 0, 0]); // red
					matrix = matrix.concat([0, 0, 1, 0, -100]); // green
					matrix = matrix.concat([1, .5, .5, 0, 0]); // blue
					matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
					break;
				case 6:
					matrix = matrix.concat([5, 0, 0, 0, 0]); // red
					matrix = matrix.concat([0, 0, 1, 0, 0]); // green
					matrix = matrix.concat([0, 0, 0, 0, 0]); // blue
					matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
					break;

			}
			var cmFilter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			//var cmFilter2 = new ColorMatrixFilter(matrix2);
			//var filter = new Array();
			//filter.splice(0,1,cmFilter);
			this.filters = [cmFilter];
			colorNum++;
		}
		override public function finalCheck():void
		{
			var n:int = numChildren;
			for (var i:int; i < n; i++)
			{
				var mc:DisplayObject = getChildAt(i);
				if (mc is Shape)
				{
					mc.visible = false;
				}
			}
			if (this is Bill)
			{
				var torso:BillTorso = Bill(this).torso;
				n = torso.numChildren;
				for (i=0; i < n; i++)
				{
					mc = torso.getChildAt(i);
					if (mc is Shape)
					{
						mc.visible = false;
					}
				}
				var legs:BillLegs = Bill(this).legs;
				n = legs.numChildren;
				for (i=0; i < n; i++)
				{
					mc = legs.getChildAt(i);
					if (mc is Shape)
					{
						mc.visible = false;
					}
				}
			}
			if (this is MegaMan)
			{
				var mmHead:MegaManHead = MegaMan(this).head;
				n = mmHead.numChildren;
				for (i=0; i < n; i++)
				{
					mc = mmHead.getChildAt(i);
					if (mc is Shape)
					{
						mc.visible = false;
					}
				}
			}
			if (hammerWeapon != null)
			{
				hammerWeapon.update();
			}
		}
		override public function hitProj(proj:Projectile):void
		{
			if (proj.sourceType == Projectile.SOURCE_TYPE_ENEMY)
			{
				if (!starPwr && !takeNoDamage)
					takeDamage(proj);
			}
		}
		override public function hit(mc:LevObj,hType:String):void
		{
			super.hit(mc,hType);
			curHitDct.addItem(mc);
		}
		protected function bounce(enemy:Enemy):void
		{
			vy = -bouncePwr;
			if (enemy && ny > enemy.hTop)
				ny = enemy.hTop;
			setHitPoints();
			jumped = true;
			bounced = true;
		}
		public function setPowerState(value:int):void
		{
			var tsTxt:TopScreenText = TopScreenText.instance;
			if (tsTxt)
				tsTxt.updateUpgIcons();
			changeBrickState();
			pState = 1;
//			var gm:GraphicsManager = GraphicsManager.INSTANCE;
//			gm.prepareRecolor(gm.masterCharSkinVec[charNum]);
			firstPStateCall = false;
		}
		public function manualChangePwrState():void
		{
			setDamageInfoArr();
			var num:int = pState + 1;
			if (num > 3)
				num = 1;
			setPowerState(num);
			getDataFromDamageInfoArr();
		}
		private function desaturate():void
		{
			var matrix:Array = new Array();

			matrix = matrix.concat([.75, .25, .25, 0, -10]); // red
			matrix = matrix.concat([.25, .75, .25, 0, -10]); // green
			matrix = matrix.concat([.25, .25, .75, 0, -10]); // blue
			matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha

			var cmFilter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			this.filters = [cmFilter];
		}
		public function setPauseBtns():void
		{
			// reset pBtns
			pUpBtn = false;
			pDwnBtn = false;
			pLftBtn = false;
			pRhtBtn = false;
			pAtkBtn = false;
			pJmpBtn = false;
			pSpcBtn = false;
			// set pBtns
			if (upBtn)
				pUpBtn = true;
			if (dwnBtn)
				pDwnBtn = true;
			if (lftBtn)
				pLftBtn = true;
			if (rhtBtn)
				pRhtBtn = true;
			if (atkBtn)
				pAtkBtn = true;
			if (jmpBtn)
				pJmpBtn = true;
			if (spcBtn)
				pSpcBtn = true;
		}
		public function relPauseBtns():void
		{
			if (pUpBtn && !upBtn)
			{
				upBtn = true;
				relUpBtn();
			}
			if (pDwnBtn && !dwnBtn)
			{
				dwnBtn = true;
				relDwnBtn();
			}
			if (pLftBtn && !lftBtn)
			{
				lftBtn = true;
				relLftBtn();
			}
			if (pRhtBtn && !rhtBtn)
			{
				rhtBtn = true;
				relRhtBtn();
			}
			if (pAtkBtn && !atkBtn)
			{
				atkBtn = true;
				relAtkBtn();
			}
			if (pJmpBtn && !jmpBtn)
			{
				jmpBtn = true;
				relJmpBtn();
			}
			if (pSpcBtn && !spcBtn)
			{
				spcBtn = true;
				relSpcBtn();
			}
		}
		protected function setAllButtonsFalse():void
		{
			upBtn = false;
			dwnBtn = false;
			lftBtn = false;
			rhtBtn = false;
			spcBtn = false;
			atkBtn = false;
			jmpBtn = false;
		}
		public function forceTakeNoDamage():void
		{
			takeNoDamage = true;
			neverTakeDamage = true;
			if (GameSettings.DEBUG_MODE)
				alpha = 1;
			else
				alpha = .75;
		}
		public function enterWater():void
		{
			underWater = true;
		}
		protected function exitWater():void
		{
			underWater = false;
		}
		public function forceTakeDamage():void
		{
			neverTakeDamage = false;
			takeNoDamage = false;
			alpha = 1;
		}
		protected function getAllDroppedUpgrades():void // gives character all upgrades that are dropped by enemies (should be overrided)
		{

		}

		public function changeChar(num:int = -1):void
		{
			var newCharNum:int = charNum;
			if (num == -1)
				newCharNum++;
			else
				newCharNum = num;
			if (newCharNum > CHAR_NUM_MAX || newCharNum < 0)
				newCharNum = 0;
			var charClass:Class = CharacterInfo.getCharClassFromNum(newCharNum);
			level.changeChar(charClass);
//			charNum = newCharNum;
			setPowerState(pState);
		}
		public function changedToThisChar():void
		{
//			var charBmd:BmdSkinCont = graphicsMngr.masterCharSkinVec[STAT_MNGR.curCharNum];
//			if ( graphicsMngr.shouldBeRecoloredToGb(charBmd) )
//				graphicsMngr.recolorGbSkin(charBmd);
		}
		public function slideDownFlagPole():void
		{
			BTN_MNGR.relPlyrBtns();
			stopTimers();
			if (starPwr)
				starPwrTmr3Handler(new TimerEvent(TimerEvent.TIMER_COMPLETE));
			scaleX = 1;
			vx = 0;
			vy = level.flagPole.FLAG_DROP_SPEED;
			nx = level.flagPole.hLft;
			setState(ST_FLAG_SLIDE);
			lockState = true;
			defyGrav = true;
		}
		public function stopFlagPoleSlide():void
		{
			lockState = false;
			setState("neutral");
			flagDelayTmr = new CustomTimer(FLAG_DELAY_TMR_DUR,1);
			addTmr(flagDelayTmr);
			flagDelayTmr.addEventListener(TimerEvent.TIMER_COMPLETE,flagDelayTmrLsr,false,0,true);
			flagDelayTmr.start();
			vy = 0;
			if (!(this is MarioBase))
				defyGrav = false;
		}
		protected function flagDelayTmrLsr(e:TimerEvent):void
		{
			if (flagDelayTmr)
			{
				flagDelayTmr.stop();
				flagDelayTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,flagDelayTmrLsr);
				removeTmr(flagDelayTmr);
				flagDelayTmr = null;
			}
			if (!onGround)
				setState("jump");
			defyGrav = false;
			pressRhtBtn();
			rhtBtn = true;
			musicDelTmr = new CustomTimer(MUSIC_DEL_TMR_DUR,1);
			level.addTmr(musicDelTmr);
			musicDelTmr.addEventListener(TimerEvent.TIMER_COMPLETE,musicDelTmrLsr,false,0,true);
			musicDelTmr.start();
			if (level is TitleLevel)
				level.beatLevel = true;
		}
		private function musicDelTmrLsr(e:TimerEvent):void
		{
			musicDelTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,musicDelTmrLsr);
			SND_MNGR.changeMusic( MusicType.WIN );
			/*var cn:String = charName;
			var nameStr:String = cn.charAt(0).toUpperCase() + cn.substring(1,cn.length);
			SND_MNGR.playSound(nameStr + MUSIC_EFFECT_TYPE_WIN + SND_NAME_SUFFIX);*/
			level.startWinEndTmrMusic(winSongDur);
		}
		public function getAxe(axe:BowserAxe):void // it's called after the game freezes if bowser exists
		{
			EVENT_MNGR.getAxe();
			GS_MNGR.gameState = GS_WATCH;
			GS_MNGR.lockGameState = true;
			BTN_MNGR.relPlyrBtns();
			vx = vxMax;
			pressRhtBtn();
			stopUpdate = false;
			STAT_MNGR.stopTimeLeft();
			SND_MNGR.removeAllSounds();
			SND_MNGR.changeMusic( MusicType.WIN_CASTLE );
			//SND_MNGR.playSound(_sndWinMusic);
			level.forceScreenScrollLeftFunction();
			bowserAxeRect = axe.hRect.rect;
			axeFallTmr = new GameLoopTimer(AXE_FALL_TMR_DEL,1);
			addTmr(axeFallTmr);
			axeFallTmr.addEventListener(TimerEvent.TIMER_COMPLETE,axeFallTmrHandler,false,0,true);
			axeFallTmr.start();
		}
		private function axeFallTmrHandler(event:TimerEvent):void
		{
			removeTmr(axeFallTmr);
			axeFallTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,axeFallTmrHandler);
			axeFallTmr = null;
			if (hRht < bowserAxeRect.left)
			{
				nx = bowserAxeRect.right;
				ny = bowserAxeRect.bottom;
				x = nx;
				y = ny;
			}
		}
		override public function gravityPull():void
		{
			if (lastOnGround && !onGround && !jumped)
			{
				FALL_BTWN_TMR.reset();
				FALL_BTWN_TMR.start();
				_fallBtwn = true;
			}
			super.gravityPull();
		}
		public function charSelectInitiate():void // called right when character changes
		{
			BTN_MNGR.relPlyrBtns();
			if (CharacterSelectBox.instance.mode == CharacterSelectBox.MODE_CHARACTER_SELECT)
				pressRhtBtn();
			x = CharacterSelect.PLAYER_X_POS;
			y = GLOB_STG_BOT - TILE_SIZE*2;
			ny = y;
			vy = 0;
		}
		public function chooseCharacter():void
		{
			nx = CharacterSelect.PLAYER_X_POS;
		}
		public function fallenCharSelScrn():void
		{

		}
		protected function originalGravityPull():void
		{
			super.gravityPull();
		}
		private function fallBtwnTmrHandler(event:TimerEvent):void
		{
			FALL_BTWN_TMR.reset();
			_fallBtwn = false;
		}
		public function swapChar():void
		{
			// for changing character without losing variable
		}
		protected function bouncePit():void
		{
			ny = GLOB_STG_BOT;
			y = ny;
			setHitPoints();
			vy = -boostSpringPwr;
			releasedJumpBtn = true;
			frictionY = false;
			jumped = true;
		}
		public static function hitRandomUpgrade(charNum:int,showAnimation:Boolean = true):void
		{
			var pickupType:String = StatManager.STAT_MNGR.getRandomUpgrade(charNum);
			var pickup:Pickup;
			if (pickupType == PickupInfo.MUSHROOM)
				pickup = new Mushroom(Mushroom.ST_RED);
			else if (pickupType == PickupInfo.FIRE_FLOWER)
				pickup = new FireFlower();
			else
				pickup = new Pickup(pickupType);

			player.hitPickup( pickup, showAnimation );
		}
		protected function checkBouncePit():Boolean
		{
			return hBot > GLOB_STG_BOT;
		}
		override public function checkStgPos():void
		{
			if (vine)
				return;
			pitTransArr = STAT_MNGR.pitTransArr;
			if ( (Cheats.bouncyPits || level is TitleLevel) && !dead && checkBouncePit() && pitTransArr == null && !pipe )
			{
				bouncePit();
				return;
			}
			var levX:Number = level.x;
			if (levX < 0)
				levX = -levX;
			if (nx > levX - TILE_SIZE*3
			&& nx < levX + GLOB_STG_RHT + TILE_SIZE*2
			&& scaleY > 0 && ny - height > locStgBot
			&& scaleY < 0 && ny > locStgBot)
			{
				if (parent != level)
					level.addChild(this);
			}
			if ( (!(this is Sophia) && ny - height >= GLOB_STG_BOT) || (this is Sophia && hTop >= GLOB_STG_BOT) )
			{
				if (!pitTransArr && cState != "vine")
				{
					if (!_fellInPit && dead)
					{
						initiatePitDeath();
						return;
					}
					_fellInPit = true;
					die();
				}
				else if (pitTransArr && !_fellInPit)
				{
					if (dead)
						initiatePitDeath();
					else
					{
						EVENT_MNGR.levelTransfer(pitTransArr[0],pitTransArr[1],PIT_LEV_TRANS_DELAY);
						stopUpdate = true;
						_fellInPit = true;
					}
				}
			}
			//else if (parent == level) level.removeChild(this);
		}
		/**
		 * Checks if a direction is the only direction being pressed. Can also check if no directions are pressed.
		 *
		 * @param dirFun The directional button press function to check. Example: pressUpBtn.
		 * @return Returns true if there are no other directional buttons being pressed
		 *
		 */
		protected function isOnlyDirPressed(dirFun:Function):Boolean
		{
			if (dirFun == pressUpBtn && upBtn && !dwnBtn && !lftBtn && !rhtBtn)
				return true;
			else if (dirFun == pressRhtBtn && rhtBtn && !lftBtn && !dwnBtn && !upBtn)
				return true;
			else if (dirFun == pressDwnBtn && dwnBtn && !lftBtn && !rhtBtn && !upBtn)
				return true;
			else if (dirFun == pressLftBtn && lftBtn && !rhtBtn && !dwnBtn && !upBtn)
				return true;
			else if (dirFun == null && !upBtn && !rhtBtn && !dwnBtn && !lftBtn)
				return true;
			return false;
		}
		/**
		 * Checks if opposite direction is pressed
		 * @param dirFun
		 * @return True if opposite direction is being pressed.
		 *
		 */
		protected function oppDirIsPressed(dirFun:Function):Boolean
		{
			if (dirFun == pressUpBtn)
			{
				if (dwnBtn)
					return true;
				return false;
			}
			if (dirFun == pressDwnBtn)
			{
				if (upBtn)
					return true;
				return false;
			}
			if (dirFun == pressRhtBtn)
			{
				if (lftBtn)
					return true;
				return false;
			}
			if (dirFun == pressLftBtn)
			{
				if (rhtBtn)
					return true;
				return false;
			}
			return false;
		}
		public function springLaunch(spring:SpringRed):void
		{

		}

		protected function changeBrickState():void
		{
			// some might use this
		}
		public function getPitTransfer(globDest:String):void
		{
			pitTransArr = [globDest,-1];
			STAT_MNGR.pitTransArr = pitTransArr;
		}
		override public function destroy():void
		{
			if (!falseDestroy)
				super.destroy();
		}
		public function get DEATH_TMR_DEL():int
		{
			return _dieTmrDel;
		}
		protected function prepareDrawCharacter(skinAppearanceState:int = -1):void
		{
			if (drawFrameLabel != null)
				gotoAndStop(drawFrameLabel);
			if (replaceColor || level is FakeLevel)
				endReplaceColor();
		}

		protected function get currentSkinAppearanceNum():int
		{
			return 0;
		}

//		private function drawCharacter():void
//		{
//			prepareDrawCharacter();
//			AllCharactersCmc.getInstance().drawCharacter(this);
//		}

		override public function cleanUp():void
		{
			if (dead)
			{
				setAllAmmoToDefault();
				STAT_MNGR.removeAllUpgradesForChar(charNum, false, true);
				if (GameSettings.startWithMushroom && canGetMushroom)
					STAT_MNGR.addCharUpgrade(charNum, MUSHROOM);
			}
			setSkinAppearanceNumber(charNum, currentSkinAppearanceNum);
//			if ( !(level is CharacterSelect) || !CharacterSelectBox.instance)
//				drawCharacter();
			super.cleanUp();
			if (freezeGameTmr) // not incluced in tmrVec
			{
				freezeGameTmr.stop();
				freezeGameTmr = null;
			}
			for each (var subMc:SubMc in subMcDct)
			{
				subMc.cleanUp();
			}
			pitTransArr = null;
			if (level && level.charDct)
				level.charDct.removeItem(this);
		}
		public static function getGamesFromSkin(charNum:int):Vector.<Game>
		{
			var bmc:BmdSkinCont = StatManager.STAT_MNGR.getCurrentBmc(charNum);
			return bmc.games;
		}
		override protected function removeListeners():void
		{
			super.removeListeners();
			if (bubbleTmr && bubbleTmr.hasEventListener(TimerEvent.TIMER_COMPLETE))
				bubbleTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,bubbleTmrLsr);
			if (freezeGameTmr && freezeGameTmr.hasEventListener(TimerEvent.TIMER_COMPLETE))
				freezeGameTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,freezeGameTmrHandler);
			if (noDamageTmr && noDamageTmr.hasEventListener(TimerEvent.TIMER_COMPLETE))
				noDamageTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,noDamageTmrLsr);
			if (starPwrTmr1 && starPwrTmr1.hasEventListener(TimerEvent.TIMER_COMPLETE))
				starPwrTmr1.removeEventListener(TimerEvent.TIMER_COMPLETE,starPwrTmr1Handler);
			if (starPwrTmr2 && starPwrTmr2.hasEventListener(TimerEvent.TIMER_COMPLETE))
				starPwrTmr2.removeEventListener(TimerEvent.TIMER_COMPLETE,starPwrTmr2Handler);
			if (starPwrTmr3 && starPwrTmr3.hasEventListener(TimerEvent.TIMER_COMPLETE))
				starPwrTmr3.removeEventListener(TimerEvent.TIMER_COMPLETE,starPwrTmr3Handler);
			if (flagDelayTmr && flagDelayTmr.hasEventListener(TimerEvent.TIMER_COMPLETE))
				flagDelayTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,flagDelayTmrLsr);
			if (musicDelTmr && musicDelTmr.hasEventListener(TimerEvent.TIMER_COMPLETE))
				musicDelTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,musicDelTmrLsr);
			if (flickerTmr)
				flickerTmr.removeEventListener(TimerEvent.TIMER,flickerTmrHandler);
			if (wingTimer != null)
				wingTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, wingTimerHandler);
			FALL_BTWN_TMR.removeEventListener(TimerEvent.TIMER_COMPLETE,fallBtwnTmrHandler);
		}
		override protected function reattachLsrs():void
		{
			super.reattachLsrs();
			if (bubbleTmr && !bubbleTmr.hasEventListener(TimerEvent.TIMER_COMPLETE))
				bubbleTmr.addEventListener(TimerEvent.TIMER_COMPLETE,bubbleTmrLsr);
			if (freezeGameTmr && !freezeGameTmr.hasEventListener(TimerEvent.TIMER_COMPLETE))
				freezeGameTmr.addEventListener(TimerEvent.TIMER_COMPLETE,freezeGameTmrHandler);
			if (noDamageTmr && !noDamageTmr.hasEventListener(TimerEvent.TIMER_COMPLETE))
				noDamageTmr.addEventListener(TimerEvent.TIMER_COMPLETE,noDamageTmrLsr);
			if (starPwrTmr1 && !starPwrTmr1.hasEventListener(TimerEvent.TIMER_COMPLETE))
				starPwrTmr1.addEventListener(TimerEvent.TIMER_COMPLETE,starPwrTmr1Handler);
			if (starPwrTmr2 && !starPwrTmr2.hasEventListener(TimerEvent.TIMER_COMPLETE))
				starPwrTmr2.addEventListener(TimerEvent.TIMER_COMPLETE,starPwrTmr2Handler);
			if (starPwrTmr3 && !starPwrTmr3.hasEventListener(TimerEvent.TIMER_COMPLETE))
				starPwrTmr3.addEventListener(TimerEvent.TIMER_COMPLETE,starPwrTmr3Handler);
			if (flagDelayTmr && !flagDelayTmr.hasEventListener(TimerEvent.TIMER_COMPLETE))
				flagDelayTmr.addEventListener(TimerEvent.TIMER_COMPLETE,flagDelayTmrLsr);
			if (flickerTmr)
				flickerTmr.addEventListener(TimerEvent.TIMER,flickerTmrHandler,false,0,true);
			FALL_BTWN_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,fallBtwnTmrHandler,false,0,true);
		}
		public function get usesHorzObjs():Boolean
		{
			return _usesHorzObjs;
		}
		public function get usesVertObjs():Boolean
		{
			return _usesVertObjs;
		}
		public function get charName():String
		{
			return _charName;
		}
		public function get charNameTxt():String
		{
			return _charNameTxt;
		}
		public function get fallBtwn():Boolean
		{
			return _fallBtwn;
		}
		public function get fellInPit():Boolean
		{
			return _fellInPit;
		}
		public function get numContStomps():int
		{
			return _numContStomps;
		}
		public function get replaceColor():Boolean
		{
			return _replaceColor;
		}
		public function get secondsLeftSnd():String
		{
			return _secondsLeftSnd;
		}
		public function get secondsLeftSndIsBgm():Boolean
		{
			return _secondsLeftSndIsBgm;
		}
		public function get starPwrBgmShouldBePlaying():Boolean
		{
			return _starPwrBgmShouldBePlaying;
		}
		public function get stompedEnemyThisCycle():Boolean
		{
			return _stompedEnemyThisCycle;
		}
		public function get boundsRect():Rectangle
		{
			return _boundsRect;
		}
		public function get charNameCaps():String
		{
			return _charNameCaps;
		}
		public function getFlashArr():Array
		{
			return flashArr;
		}

		public function get canStomp():Boolean
		{
			if (level == TitleLevel.instance)
				return true;
			if (underWater && !canStompUnderWater)
				return false;
			if (Cheats.everyoneCanStomp)
				return true;
			return _canStomp;
		}

		public function get canGetAmmoFromCoinBlocks():Boolean
		{
			return _canGetAmmoFromCoinBlocks;
		}

		public function get canGetAmmoFromBricks():Boolean
		{
			return _canGetAmmoFromBricks;
		}

		public function get isGoodSwimmer():Boolean
		{
			return _isGoodSwimmer;
		}

		public function get isWideCharacter():Boolean
		{
			return _isWideCharacter;
		}

		public function get canGetMushroom():Boolean
		{
			return _canGetMushroom || GameSettings.powerupMode == PowerupMode.Classic;
		}

		public function set canGetMushroom(value:Boolean):void
		{
			_canGetMushroom = value;
		}


	}
}
