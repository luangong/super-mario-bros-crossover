 package com.smbc.level
{

	import com.customClasses.MCAnimator;
	import com.customClasses.TDCalculator;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatusProperty;
	import com.explodingRabbit.display.CustomMovieClip;
	import com.explodingRabbit.utils.CustomDictionary;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.SuperMarioBrosCrossover;
	import com.smbc.characters.*;
	import com.smbc.data.AnimationTimers;
	import com.smbc.data.CampaignModes;
	import com.smbc.data.CharacterInfo;
	import com.smbc.data.Cheats;
	import com.smbc.data.Difficulties;
	import com.smbc.data.FireworkLocations;
	import com.smbc.data.GameSettings;
	import com.smbc.data.GameStates;
	import com.smbc.data.HitTester;
	import com.smbc.data.LevelDataTranscoder;
	import com.smbc.data.LevelID;
	import com.smbc.data.LevelTypes;
	import com.smbc.data.MapDifficulty;
	import com.smbc.data.MusicType;
	import com.smbc.data.ScoreValue;
	import com.smbc.data.ScreenSize;
	import com.smbc.data.Themes;
	import com.smbc.enemies.*;
	import com.smbc.enums.GoombaReplacementType;
	import com.smbc.enums.PiranhaSpawnType;
	import com.smbc.errors.StringError;
	import com.smbc.events.CustomEvents;
	import com.smbc.graphics.*;
	import com.smbc.ground.*;
	import com.smbc.interfaces.IAnimated;
	import com.smbc.interfaces.ICustomTimer;
	import com.smbc.main.AnimatedObject;
	import com.smbc.main.GlobVars;
	import com.smbc.main.LevObj;
	import com.smbc.main.SimpleAnimatedObject;
	import com.smbc.managers.ButtonManager;
	import com.smbc.managers.EventManager;
	import com.smbc.managers.GameStateManager;
	import com.smbc.managers.GraphicsManager;
	import com.smbc.managers.MessageBoxManager;
	import com.smbc.managers.ScreenManager;
	import com.smbc.managers.SoundManager;
	import com.smbc.managers.StatManager;
	import com.smbc.managers.TutorialManager;
	import com.smbc.messageBoxes.MenuBoxItems;
	import com.smbc.pickups.*;
	import com.smbc.projectiles.*;
	import com.smbc.sound.RepeatingSilenceOverrideSnd;
	import com.smbc.utils.AnimatedObjectSortableDictionary;
	import com.smbc.utils.GameLoopTimer;
	import com.smbc.utils.GroundNestedColumnDictionary;
	import com.smbc.utils.GroundNestedRowDictionary;
	import com.smbc.utils.GroundSortableDictionary;
	import com.smbc.utils.SceneryNestedColumnDictionary;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display3D.IndexBuffer3D;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.sampler.Sample;
	import flash.sampler.clearSamples;
	import flash.sampler.getSamples;
	import flash.sampler.startSampling;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	import flashx.textLayout.formats.BackgroundColor;
	import flashx.textLayout.formats.Float;

	import nl.stroep.utils.ImageSaver;

	public class Level extends Sprite
	{
		public static var levelInstance:Level;
		public static const LOOP_TMR_INT:Number = 1000/60;
		private static const GAME_LOOP_END_EVENT:Event = new Event(CustomEvents.GAME_LOOP_END);
		protected static const AP_PASSTHROUGH_ALWAYS:String = StatusProperty.TYPE_PASS_THROUGH_ALWAYS_AGG;
		protected static const AP_PASSTHROUGH_DEFEAT:String = StatusProperty.TYPE_PASS_THROUGH_DEFEAT_AGG;
		internal var onGround:Boolean;
		public var bgmType:int;
		public var player:Character;
		public static const GLOB_STG_TOP:int = 0;
		public static const GLOB_STG_BOT:int = ScreenSize.SCREEN_HEIGHT;
		public static const GLOB_STG_RHT:int = ScreenSize.SCREEN_WIDTH;
		public static const GLOB_STG_LFT:int = 0;
		public const TOP_LFT_PT:Point = new Point(GLOB_STG_LFT,GLOB_STG_TOP);
		public const BOTTOM_RHT_PT:Point = new Point(GLOB_STG_RHT,GLOB_STG_BOT);
		public const SCREEN_WIDTH:int = GLOB_STG_RHT;
		public const SCROLL_SPEED_BEAT_DUNGEON:int = 150;
		public const SCROLL_SPEED_MARIO_FLAG_POLE_FIX:int = 50;
		protected var screenScrollsLeft:Boolean = !Cheats.classicScreenScroll;
		public var forceScreenScrollLeft:Boolean;
		public const ZERO_PT:Point = new Point();
		public const ANIMATOR:MCAnimator = GlobVars.ANIMATOR;
		public const TILE_SIZE:int = GlobVars.TILE_SIZE;
		public const HALF_TILE_SIZE:int = TILE_SIZE/2;
		private const STAGE:Stage = GlobVars.STAGE;
		public static const PROP_SEP:String = "&&";
		private const BLANK_TILE:String = "0";
		public static const PROP_EQUALS:String = "=";
		public static const PROP_OBJECT_SEP:String = "()"; // used to separate to objects on one tile
		public static const PROP_CHAR_HORZ:String = "charHorz";
		public static const VISIBILITY_HIDE:String = "Hide";
		public static const VISIBILITY_SHOW:String = "Show";

		public static const PROP_CHAR_VERT:String = "charVert";
		public static const PROP_BAD_SWIMMER:String = "BadSwimmer";
		public static const PROP_WIDE_CHARACTER:String = "WideCharacter";
		public static const PROP_CONTAINED_ITEM:String = "ContainedItem";
		public static const PROP_INVISIBLE:String = "Invisible";
		public static const PROP_POOR_BOWSER_FIGHTER:String = "poorBowserFighter";
		public static const PROP_HIDE_ON_DIFFICULTIES:String = "HideOnDifficulties";
		public static const PROP_P_TRANS_DEST:String = "pTransDest";
		public const PROP_SHIFT_RIGHT:String = "shiftRight";
		public const PROP_SHIFT_UP:String = "shiftUp";
		public static const PROP_TYPE:String = "type"; // for platforms
		public static const PROP_WIDTH:String = "width"; // for platforms
		public static const PROP_NUMBER:String = "number"; // for pipe transporters
		public static const PROP_BOWSER_TYPE:String = "BowserType"; // for pipe transporters
		private static const HIDE_ON_DIFFICULTY_EASY:String = "easy";
		private static const HIDE_ON_DIFFICULTY_NORMAL:String = "normal";
		private static const HIDE_ON_DIFFICULTY_HARD:String = "hard";
		protected const GS_PLAY:String = GameStates.PLAY;
		private const GS_WATCH:String = GameStates.WATCH;
		public var locStgTop:Number = GLOB_STG_TOP;
		public var locStgRht:Number = GLOB_STG_RHT;
		public var locStgLft:Number = GLOB_STG_LFT;
		public var locStgBot:Number = GLOB_STG_BOT;
		private var lftTilePos:int;
		private var rhtTilePos:int;
		public var GAME:SuperMarioBrosCrossover = SuperMarioBrosCrossover.game;
		public const LOOP_TMR:CustomTimer = new CustomTimer(1000/60);
		public const ANIM_TMR_FLASHING_ITEM:CustomTimer = GlobVars.ANIM_TMR_FOR_FLASING_ITEMS;
		public const ANIM_SUPER_SLOWEST_TMR:CustomTimer = AnimationTimers.ANIM_SUPER_SLOWEST_TMR;
		public const ANIM_VERY_SLOW_TMR:CustomTimer = AnimationTimers.ANIM_VERY_SLOW_TMR;
		public const ANIM_SLOW_TMR:CustomTimer = AnimationTimers.ANIM_SLOW_TMR;
		public const ANIM_MODERATE_TMR:CustomTimer = AnimationTimers.ANIM_MODERATE_TMR;
		public const ANIM_MIN_FAST_TMR:CustomTimer = AnimationTimers.ANIM_MIN_FAST_TMR;
		public const ANIM_FAST_TMR:CustomTimer = AnimationTimers.ANIM_FAST_TMR;
		private const ACTIVE_ANIM_TMRS_DCT:CustomDictionary = new CustomDictionary();
		public const ALL_ANIM_TMRS_DCT:CustomDictionary = new CustomDictionary();
		private const CHANGE_COLOR_OBJS_DCT:CustomDictionary = new CustomDictionary(true);
		public const RECOLOR_OBJS_DCT:CustomDictionary = new CustomDictionary(true);
		private var fastAnim:Boolean;
		private var mainAnim:Boolean;
		private const SCROLL_EDGE_DIST:Number = GLOB_STG_RHT/2;
		private const DEFAULT_LEFT_SCROLL_POS:Number = SCROLL_EDGE_DIST;
		private const DEFAULT_RIGHT_SCROLL_POS:Number = GLOB_STG_RHT - SCROLL_EDGE_DIST;
		private const DEFAULT_RIGHT_SCROLL_POS_NO_LEFT_SCROLL:Number = 240; //210;
		private var rightScrollPos:Number;
		private var leftScrollPos:Number;
		public var rightScrollPosOvRd:Number;
		public var leftScrollPosOvRd:Number;
		private const SCREEN_MAX_LEFT_SCROLL:int = 0;
		public var manualGameLoop:Boolean;
		public var manualGameLoopNextFrame:Boolean;
		private var screenMaxRightScroll:Number;
		private const SCREEN_UNWALKABLE_BUFFER:int = 6; // determines how much of an invisible wall there is on edges of screen
		public var offScreenScrollShift:Number = SCROLL_EDGE_DIST*.5;
		public var keepPlayerOnRight:Boolean;
		public var playerUncentered:Boolean;
		private const PLAYER_ON_RIGHT_EDGE_BUFFER:int = 6;
		private var tileRightEdge:Number;
		private var tileLeftEdge:Number;
		private var totalTileWidth:Number;
		private var levMap:Array = [];
		private var levPickups:Array = [];
		public const PROJ_DCT:CustomDictionary = new CustomDictionary(true);
		public const PLAYER_PROJ_DCT:CustomDictionary = new CustomDictionary(true);
		public var gHitArr:Array = [];
		public var gBounceArr:Array = [];
		public const ALWAYS_ANIM_DCT:CustomDictionary = new CustomDictionary(true);
		public var bbVec:Vector.<BowserBridge>;
		public const SCENERY_DCT:SceneryNestedColumnDictionary = new SceneryNestedColumnDictionary();
		private var testPlayer:DisplayObject;
		public var background:LevelBackground;
		public var foreground:LevelForeground;
		private const TD_CALC:TDCalculator = GlobVars.TD_CALC;
		public var dt:Number = .03;
		protected var levData:LevelData;
		private var playerX:Number;
		private var playerY:Number;
		private const ADD_DCT:CustomDictionary = new CustomDictionary();
		public const DESTROY_DCT:CustomDictionary = new CustomDictionary();
		private var ht:HitTester;
		public var numHorzTiles:int;
		public var numVertTiles:int;
		public var mapWidth:int;
		private var ldt:Number;
		private var offsetDT:Boolean;
		private var gArrLength:int;
		private var numLevChildren:int;
		private const DT_MAX:Number = .045; // DT_MAX is set separately on other elements like MessageBox... make them the same later
		private var soundPlayArr:Array;
		public var projHitArr:Array;
		private var addedPiranha:Boolean;
		public var bfbX:Number;
		public var bowser:Bowser;
		public var bowserAxe:BowserAxe;
		public var bbChain:Scenery;
		public var fcStartX:Number;
//		public var fcEndX:Number;
//		public var fcStartX_2:Number;
//		public var fcEndX_2:Number;
		public var bulBillGraySpawnZoneStart:Number;
		public var bulBillGraySpawnZoneEnd:Number;
		public var bulBillBlackSpawnZoneStart:Number;
		public var bulBillBlackSpawnZoneEnd:Number;
		public var lakSpawnZoneStart:Number;
//		public var lakSpawnZoneEnd:Number;
		public const ENEMY_SPAWNER_DCT:CustomDictionary = new CustomDictionary();
		public var waterLevel:Boolean;
		private var _initialWaterLevel:Boolean;
		public var pitVacVec:Vector.<PitVacuum>;
		public var pullyCornerVec:Vector.<Scenery>;
		public var pullyPlatVec:Vector.<Platform>;
		public var platVec:Vector.<Platform>;
		public var teleDataVec:Vector.<Array>;
		public var teleVec:Vector.<Teleporter>;
		public var checkPtClonesVec:Vector.<Teleporter>;
		public var disableScreenScroll:Boolean;
		private const TMR_DCT:CustomDictionary = new CustomDictionary(true);
		private const P_TMR_DCT:CustomDictionary = new CustomDictionary(true);
		private var vecsVec:Vector.<Vector>;
		public var pTransVec:Vector.<PipeTransporter>;
		private var _id:LevelID;
		private var _levNum:int; // number after dash
		private var _worldNum:int; // first number
		private var _areaStr:String; // letter
		private var _plyrStatsArr:Array;
		private var areaStatsArr:Array;
		private var disarm:Boolean;
		private var _flagPole:FlagPole;
		private var flag:Scenery;
		protected var _beatLevel:Boolean;
		public var watchModeOverride:Boolean;
		protected const STAT_MNGR:StatManager = StatManager.STAT_MNGR;
		protected const BTN_MNGR:ButtonManager = ButtonManager.BTN_MNGR;
		private const SV_EARN_NEW_LIFE_NUM_VAL:int = ScoreValue.EARN_NEW_LIFE_NUM_VAL;
		public var areaToLoadArr:Array;
		public var levelIDToLoad:LevelID;
		public var tsTxt:TopScreenText;
		public var resetStats:Boolean;
		private var _hwArea:String;
		private var _timeLeftTot:uint;
		private var _newLev:Boolean;
		public var scorePopVec:CustomDictionary = new CustomDictionary(true);
		private const MOVE_PTS_TMR_INT:Number = LOOP_TMR.delay;
		private var _moveDuringFreezeTmr:CustomTimer;
		private const EVENT_MNGR:EventManager = EventManager.EVENT_MNGR;
		public const GROUND_DCT:GroundNestedColumnDictionary = new GroundNestedColumnDictionary();
		//public const GROUND_DCT:CustomDictionary = new CustomDictionary();
		//public const GROUND_DCT:GroundSortableDictionary = new GroundSortableDictionary();
		public const AO_DCT:CustomDictionary = new CustomDictionary();
		public const ANIM_DCT:CustomDictionary = new CustomDictionary(true);
		public const UPDATE_DCT:CustomDictionary = new CustomDictionary(true);
		public const AO_STG_DCT:AnimatedObjectSortableDictionary = new AnimatedObjectSortableDictionary();
		public const GROUND_STG_DCT:GroundNestedRowDictionary = new GroundNestedRowDictionary();
		public const LEV_OBJ_FINAL_CHECK:CustomDictionary = new CustomDictionary(true);
		//public const GROUND_STG_DCT:GroundSortableDictionary = new GroundSortableDictionary();
		//public const GROUND_STG_DCT:CustomDictionary = new CustomDictionary();
		public var sortedGroundVec:Vector.<Ground> = new Vector.<Ground>();
		private var sortedGroundVecLen:int;
		// for STAGE layer order
		private const AO_ORDER_STG_DCT:CustomDictionary = new CustomDictionary(true);
		private const GROUND_ORDER_STG_DCT:CustomDictionary = new CustomDictionary(true);
		private const PLAT_STG_DCT:CustomDictionary = new CustomDictionary(true);
		public const SCENERY_STG_DCT:CustomDictionary = new CustomDictionary(true);
		private const AO_BOTTOM_STG_DCT:CustomDictionary = new CustomDictionary(true);
		private var BEHIND_GROUND_STG_DCT:CustomDictionary = new CustomDictionary(true);
		private var COIN_STG_DCT:CustomDictionary = new CustomDictionary(true);
		private var AFTER_GROUND_STG_DCT:CustomDictionary = new CustomDictionary(true);
		private var TOP_STG_DCT:CustomDictionary = new CustomDictionary(true);
		public var lgpx:Number;
		private var cgpx:Number;
		private var pExInt:int;
		private const SCRN_MNGR:ScreenManager = ScreenManager.SCRN_MNGR;
		private const GS_MNGR:GameStateManager = GameStateManager.GS_MNGR;
		private const SND_NAME_PREFIX:String = "Snd";
		protected const SND_MNGR:SoundManager = SoundManager.SND_MNGR;
		private var winEndTmr:CustomTimer;
		private var winEndTmrMusic:CustomTimer;
		private const WIN_END_TMR_NORMAL_DUR:int = 2000;
		private const WIN_END_TMR_FIREWORKS_DUR:int = 1000;
		private const WIN_END_TMR_DUNGEON_DUR:int = 3500;
		public var watchModeOverrideVine:Boolean;
		public var playerGraphic:Bitmap;
		private var castleFlag:CastleFlag;
		private var castleFlagEndPosition:int;
		private var fireworkPivotY:int;
		private const TUT_MNGR:TutorialManager = TutorialManager.TUT_MNGR;
		private var raiseCastleFlag:Boolean;
		private const RAISE_CASTLE_FLAG_INT:int = 90;
		private const WIN_MUSIC_TAIL:int = 1000;
		public var fireworksRemaining:int;
		private var fwPosArr:Array;
		private const DEFAULT_MAX_HIT_TEST_DISTANCE:int = HitTester.MAX_DIST_DEF;
		private const BOWSER_AXE_SCREEN_SCROLL_OFFSET:int = 8;
		private var hwPnt:Point;
		private const HW_ENEMY_REMOVAL_DIST:Number = TILE_SIZE*6;
		public var previouslyVisitedArea:Boolean;
		private const AREA_STATS_ARR_IND_AREA_STR:int = 0;
		private const AREA_STATS_ARR_IND_AO_DCT:int = 1;
		private const AREA_STATS_ARR_IND_GROUND_DCT:int = 2;
		private const AREA_STATS_ARR_IND_SCENERY_DCT:int = 3;
		private const AREA_STATS_ARR_IND_HW_PNT:int = 4;
		private const AREA_STATS_ARR_IND_ENEMY_SPAWNER_DCT:int = 5;
		private static const AREA_STATS_ARR_IND_BOWSER_FIREBALL_X:int = 6;
		private const ENTER_FRAME_EVENT:String = Event.ENTER_FRAME;
		private var maxDist:Number = DEFAULT_MAX_HIT_TEST_DISTANCE;
		private var aoVecHt:Vector.<AnimatedObject>;
		private var aoVecHtLen:int;
		private var winEndTmrComplete:Boolean;
		private const PO_PLAYER:String = Projectile.SOURCE_TYPE_PLAYER;
		private const PO_ENEMY:String = Projectile.SOURCE_TYPE_ENEMY;
		private var groundRowDcts:CustomDictionary;
		private var groundRowDctsLen:int;
		private var groundColDcts:CustomDictionary;
		private var sceneryColDcts:CustomDictionary;
		private const SCENERY_DCT_NON_GRID_ITEM_KEY:String = SceneryNestedColumnDictionary.NON_GRID_ITEM_KEY;
		private var sceneryVec:Vector.< Vector.<Scenery> > = new Vector.< Vector.<Scenery> >();
		public var bgColor:int;
		private const LD_TC:LevelDataTranscoder = new LevelDataTranscoder();
		public var checkAllObjectsOnScreen:Boolean;
		public var forceShiftScreenToFollowPlayer:Boolean;
		public const GAME_LOOP_TMRS_DCT:CustomDictionary = new CustomDictionary(false);
		private static const BACKUP_TOUCH_LEVEL_EXIT_TMR_DEL:int = 6000;
		private var backupTouchLevelExitTmr:Timer;
		private var editor:LevelEditor;
		private var _autoScroll:Boolean;
		public static const SCROLL_SPEED_AUTO:int = 100;
		public var charDct:CustomDictionary;
		private static const SOUNDS_TO_PLAY_DCT:CustomDictionary = SoundManager.SND_MNGR.SOUNDS_TO_PLAY_DCT;
		private var _type:String;
		private var captureFrame:Boolean;
		private var barrelSpawner:BarrelSpawner;


		public function Level(levelID:LevelID, _levData:LevelData, _areaStatsArr:Array, __newLev:Boolean)
		{
			if (levelInstance)
				throw new Error("there can only be one level at a time.");
			GlobVars.level = this;
			levelInstance = this;
			_plyrStatsArr = STAT_MNGR.plyrStatsArr.concat();
			areaStatsArr = _areaStatsArr;
			ht = new HitTester();
			_id = levelID;
			if (levelID.fullName == CharacterSelect.FULL_LEVEL_STR && !(this is FakeLevel) && !(this is CharacterSelect) )
			{
				levelID = LevelID.Create(GameSettings.FIRST_LEVEL);
				STAT_MNGR.currentLevelID = _id;
			}
			this._newLev = __newLev;
			levData = _levData;
			_worldNum = _id.world;
			_levNum = _id.stage;
			_areaStr = _id.area;
//			if ( funTime() )
				this.addEventListener(Event.ADDED_TO_STAGE, addedListener);
		}

		public function get autoScroll():Boolean
		{
			return _autoScroll;
		}

		private function addedListener(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, addedListener);
			GAME = parent as SuperMarioBrosCrossover;
			STAGE.addEventListener(Event.RENDER, renderLsr); // for animation
			setUpAnimTmrs();
			if (levData.id == null || levData.id.fullName != _id.fullName)
				levData.getCurrentLevel(_id);
			getLevelDataInfo();
//			if (GameSettings.campaignMode == CampaignModes.LEVEL_EDITOR)
//			{
//				editor = LevelEditor.INSTANCE;
//				LevelEditor.INSTANCE.enterLevelEditorMode();
//			}
			STAT_MNGR.pitTransArr = null;
			if (areaStatsArr.length)
				rebuildLevel();
			else
			{
				createCharacter();
				buildLevel();
			}
		}
		private function createCharacter():void
		{
			if (_plyrStatsArr.length)
			{
				var charClass:Class = CharacterInfo.getCharClassFromNum(STAT_MNGR.curCharNum);
				player = new charClass();
				player.pState = STAT_MNGR.pStateVec[player.charNum];
				pExInt = _plyrStatsArr[2];
				_plyrStatsArr = null;
				EVENT_MNGR.getLevelVars();
			}
			else
			{
				player = new Mario();
				EVENT_MNGR.getLevelVars();
			}
		}
			protected function getLevelDataInfo():void
			{
				//var parser:LevelDataParser = LevelDataParser.instance;
				//parser.loadLevel(_worldNum,_levNum,_areaStr);
				levMap = levData.getMap();
				levPickups = levData.getPickups();
				_hwArea = levData.hwArea;
				_timeLeftTot = levData.gettimeLeftTot();
//				bgColor = int( LevelDataTranscoder.BACKGROUND_OBJ[ levData.getBGVec() ] );
				_type = levData.getType();
//				trace("fullLevStr: "+fullLevStr);
				background = new LevelBackground(this);
				foreground = new LevelForeground(this);
//				background.setBackgrounds();
//				foreground.setBackgrounds();
				bgmType = levData.getMusic();
				waterLevel = Cheats.waterMode;
				if (_type == LevelTypes.WATER)
				{
					waterLevel = true;
					_initialWaterLevel = true;
				}
				numHorzTiles = levMap[0].length;
				numVertTiles = levMap.length;
				mapWidth = numHorzTiles*TILE_SIZE;
				GROUND_STG_DCT.prepLevDcts(numVertTiles,TILE_SIZE);
				GROUND_DCT.prepLevDcts(numHorzTiles,TILE_SIZE);
				SCENERY_DCT.prepLevDcts(numHorzTiles,TILE_SIZE);
				groundRowDcts = GROUND_STG_DCT.ROW_DCTS;
				groundRowDctsLen = numVertTiles - 1; // top row is not counted
				groundColDcts = GROUND_DCT.COL_DCTS;
				sceneryColDcts = SCENERY_DCT.COL_DCTS;
			}
		//*
		public function clickLsr(e:MouseEvent):void
		{
			if (GS_MNGR.gameState == "play")
			{
				var point:Point = getCurrentGrid(mouseX,mouseY);
				var ground:Ground = getGroundAt(point.x,point.y);
				if (ground && ground is Brick)
					Brick(ground).breakBrick();
				else
					if (player)
					{
						player.vx = 0;
						player.vy = 0;
						player.nx = mouseX;
						player.ny = mouseY;
						player.changeChar(player.charNum);
//						trace("mouse x: "+mouseX+" y: "+mouseY);
					}
			}
		}
		//*/
		private function setUpAnimTmrs():void
		{
			ANIM_TMR_FLASHING_ITEM.addEventListener(TimerEvent.TIMER,animTmrFlashingItemHandler,false,0,true);
			ALL_ANIM_TMRS_DCT.addItem(ANIM_TMR_FLASHING_ITEM);
			ANIM_SUPER_SLOWEST_TMR.addEventListener(TimerEvent.TIMER,animSuperSlowestTmrHandler,false,0,true);
			ALL_ANIM_TMRS_DCT.addItem(ANIM_SUPER_SLOWEST_TMR);
			ANIM_VERY_SLOW_TMR.addEventListener(TimerEvent.TIMER, animVerySlowTmrHandler,false,0,true);
			ALL_ANIM_TMRS_DCT.addItem(ANIM_VERY_SLOW_TMR);
			ANIM_SLOW_TMR.addEventListener(TimerEvent.TIMER, animSlowTmrHandler,false,0,true);
			ALL_ANIM_TMRS_DCT.addItem(ANIM_SLOW_TMR);
			ANIM_MODERATE_TMR.addEventListener(TimerEvent.TIMER, animModerateTmrHandler,false,0,true);
			ALL_ANIM_TMRS_DCT.addItem(ANIM_MODERATE_TMR);
			ANIM_MIN_FAST_TMR.addEventListener(TimerEvent.TIMER, animMinFastTmrHandler,false,0,true);
			ALL_ANIM_TMRS_DCT.addItem(ANIM_MIN_FAST_TMR);
			ANIM_FAST_TMR.addEventListener(TimerEvent.TIMER, animFastTmrHandler,false,0,true);
			ALL_ANIM_TMRS_DCT.addItem(ANIM_FAST_TMR);
		}
		// called if area was previously visited
		private function rebuildLevel():void
		{
//			trace("rebuild level");
			var i:int;
			var char:Character;
			previouslyVisitedArea = true;
			createCharacter();
			AO_DCT.addItem(player);
			var levelExit:LevelExit;
			var aoDct:CustomDictionary = areaStatsArr[AREA_STATS_ARR_IND_AO_DCT];
			for each (var ao:AnimatedObject in aoDct)
			{
				AO_DCT.addItem(ao);
				ao.rearm();
				if (ao is PipeTransporter && (ao as PipeTransporter).ptType == "globalEnd")
				{
					if (pTransVec) pTransVec.push(ao);
					else
					{
						pTransVec = new Vector.<PipeTransporter>;
						pTransVec.push(ao);
					}
				}
				else if (ao is FlagPole)
					_flagPole = ao as FlagPole;
				else if (ao is LevelExit)
					levelExit = ao as LevelExit; // this is just to set up the flag later
			}
			var gDct:CustomDictionary = areaStatsArr[AREA_STATS_ARR_IND_GROUND_DCT];
			for each (var g:Ground in gDct)
			{
				GROUND_DCT.addItem(g);
				g.rearm();
				if (g is Platform)
				{
					if (platVec)
						platVec.push(g);
					else
					{
						platVec = new Vector.<Platform>();
						platVec.push(g);
					}
					if (Platform(g).platType == Platform.PT_PULLY)
					{
						if (pullyPlatVec)
							pullyPlatVec.push(g);
						else
						{
							pullyPlatVec = new Vector.<Platform>();
							pullyPlatVec.push(g);
						}
					}
				}
			}
			var sDct:CustomDictionary = areaStatsArr[AREA_STATS_ARR_IND_SCENERY_DCT]
			for each (var s:Scenery in sDct)
			{
				SCENERY_DCT.addItem(s);
				s.level = this;
				if (s.mainAnimTmr)
					s.setUpAnimation();
				addChild(s);
				var lab:String = s.currentLabel;
				if (lab != null)
				{
					if (lab.indexOf("flag") != -1 && lab.indexOf("Pole") == -1)
					{
						flag = s;
						if (levelExit != null)
						{
							castleFlag = new CastleFlag();
							castleFlag.x = levelExit.x - TILE_SIZE*1.5;
							castleFlag.y = GLOB_STG_BOT - TILE_SIZE*7;
							castleFlagEndPosition = castleFlag.y - TILE_SIZE*.85;
							fireworkPivotY = castleFlag.y - TILE_SIZE;
						}
					}
					else if (lab.indexOf("bridgeChain") != -1)
						bbChain = s;
				}
			}
			hwPnt = areaStatsArr[AREA_STATS_ARR_IND_HW_PNT];
			bfbX = areaStatsArr[AREA_STATS_ARR_IND_BOWSER_FIREBALL_X];
			var esDct:CustomDictionary = areaStatsArr[AREA_STATS_ARR_IND_ENEMY_SPAWNER_DCT];
			for each (var es:EnemySpawner in esDct)
			{
				es.rearm();
				ENEMY_SPAWNER_DCT.addItem(es);
			}
			areaStatsArr = null;
			GS_MNGR.gameState = "cleanUp";
			//var ldtPickup:Object = LevelDataTranscoder.PICKUP_SHORT_TO_LONG;
			for (i = 0; i < numVertTiles; i++)
			{
				for (var j:int = 0; j < numHorzTiles; j++)
				{
					//var mt:String = levMap[i][j] as String;
					var pt:String = levMap[i][j] as String;
					var currentY:int = i*TILE_SIZE;
					var currentX:int = j*TILE_SIZE;
					var pShiftRight:Boolean = false;
					//var mShiftRight:Boolean = false;
					var pBase:String;
					var pProps:String;
					var pPropSepInd:int = pt.indexOf(PROP_SEP);
					/*if (pPropSepInd == -1)
						pt = ldtPickup[pt];
					else
					{
						pBase = pt.substring(0,pPropSepInd);
						pProps = pt.substr(pPropSepInd);
						pt = ldtPickup[pBase];
						pt += pProps;
					}*/

					// check pickup shift right
					if (pt.indexOf("&&shiftRight") != -1)
						pShiftRight = true;
					// playerSTART
					if (pt.indexOf("playerStart") != -1)
					{
						player.x = currentX + TILE_SIZE*.5;
						player.y = currentY + TILE_SIZE;
						if (pShiftRight)
							player.x += TILE_SIZE*.5;
						player.initiate(); // it's important that player gets initiated after everything else gets rearmed
					}
					// VINE
					else if (pt.indexOf("pitTransferStart") != -1)
					{
						var transDest:String;
						var sInd:int = pt.indexOf("&&pTransDest=")+13;
						var eInd:int = pt.indexOf("&&",sInd);
						if (eInd == -1)
							eInd = pt.length;
						transDest = pt.substring(sInd,eInd);
						player.getPitTransfer(transDest);
					}
				}
			}
			initiateLevel();
		}

		public static function ExtractLevelDataProperty(text:String, property:String, returnValueOnly:Boolean = false):String
		{
			var startIndex:int = text.indexOf(property);
			if (startIndex == -1)
				return null;
			if (returnValueOnly)
			{
				startIndex = text.indexOf(PROP_EQUALS,startIndex) + 1;
				if (startIndex == 0)
					throw new Error("Value does not exist");
			}
			var endIndex:int = text.indexOf(PROP_SEP,startIndex);
			if (endIndex == -1)
				endIndex = int.MAX_VALUE;
			return text.substring(startIndex,endIndex);
		}

		public static function RemoveProperties(text:String):String
		{
			var endIndex:int = text.indexOf(PROP_SEP);
			if (endIndex == -1)
				return text;
			else
				return text.substring(0, endIndex);
		}

		private function getPropertyVisibility(itemText:String, property:String, showValue:Boolean):Boolean
		{
			if (ExtractLevelDataProperty(itemText, property, true) == VISIBILITY_HIDE && showValue)
				return false;
			else if (ExtractLevelDataProperty(itemText, property, true) == VISIBILITY_SHOW && !showValue)
				return false;
			else
				return true;
		}

		private function determineHelperVisibility(itemText:String, usesHorzObjects:Boolean, usesVerticalObjects:Boolean):Boolean
		{
			if (ExtractLevelDataProperty(itemText, PROP_CHAR_HORZ, true) == VISIBILITY_HIDE && usesHorzObjects)
				return false;
			if (ExtractLevelDataProperty(itemText, PROP_CHAR_VERT, true) == VISIBILITY_HIDE && usesVerticalObjects)
				return false;

			var showHorz:Boolean = ExtractLevelDataProperty(itemText, PROP_CHAR_HORZ, true) == VISIBILITY_SHOW;
			var showVert:Boolean = ExtractLevelDataProperty(itemText, PROP_CHAR_VERT, true) == VISIBILITY_SHOW;

			if (showHorz && showVert)
				return usesHorzObjects || usesVerticalObjects;
			else if (showVert)
				return usesVerticalObjects;
			else if (showHorz)
				return usesHorzObjects;
			else
				return true;
		}

		public function buildLevel():void
		{
			var dif:int = GameSettings.difficulty;
			var difExtreme:int = Difficulties.VERY_HARD;
			var difHard:int = Difficulties.HARD;
			var ldtMap:Object = LevelDataTranscoder.MAP_SHORT_TO_LONG;
			var ldtPickup:Object = LevelDataTranscoder.PICKUP_SHORT_TO_LONG;
			var allHammerBrosCheat:Boolean = Cheats.allHammerBros;
			var piranhaSpawnType:PiranhaSpawnType = GameSettings.piranhaSpawnType;
			var goombaReplacementType:GoombaReplacementType = GameSettings.goombaReplacementType;
			if (this == TitleLevel.instance)
			{
				piranhaSpawnType = PiranhaSpawnType.SomePipes;
				goombaReplacementType = GoombaReplacementType.Goomba;
			}
			for (var i:int = 0; i < numVertTiles; i++)
			{
				for (var j:int = 0; j < numHorzTiles; j++)
				{
					var fullItemText:String = levMap[i][j] as String;
					var itemTexts:Array = fullItemText.split(PROP_OBJECT_SEP);
					var currentY:int = i*TILE_SIZE;
					var currentX:int = j*TILE_SIZE;
					var forceRedPiranha:Boolean = false;
					var forceGreenPiranha:Boolean = false;

					for each( var itemText:String in itemTexts)
					{
						var mapBase:String;
						var mapProps:String;
						var pBase:String;
						var pProps:String;
						//var mt:String = "0";// = levPickups[i][j] as String;
						var objectToSpawn:DisplayObject;
						var pBoxable:Boolean = false;
						var pBoxed:Boolean = false;
						var pBoxItem:String = null;
						var shiftRight:Boolean = false;
						var shiftUp:Boolean = false;
						var mPropSepInd:int = itemText.indexOf(PROP_SEP);
						var tile:GridTile = null;
	//					if (editor)
	//						tile = editor.getTileAt(currentX,currentY);

						/*if (mPropSepInd == -1)
							mt = ldtMap[mt];
						else
						{
							mapBase = mt.substring(0,mPropSepInd);
							mapProps = mt.substr(mPropSepInd);
							mt = ldtMap[mapBase];
							mt += mapProps;
						}
						if (pPropSepInd == -1)
							pt = ldtPickup[pt];
						else
						{
							pBase = pt.substring(0,pPropSepInd);
							pProps = pt.substr(pPropSepInd);
							pt = ldtPickup[pBase];
							pt += pProps;
						}*/
						var mapDifficulty:int = GameSettings.mapDifficulty;
						if (this is TitleLevel)
							mapDifficulty = MapDifficulty.NORMAL;
						var difficultiesToHideOn:String = ExtractLevelDataProperty(itemText, PROP_HIDE_ON_DIFFICULTIES, true);
						if (itemText == BLANK_TILE)
						{
							// PITVACUUM
							if (_initialWaterLevel && currentY == GLOB_STG_BOT - TILE_SIZE && itemText == BLANK_TILE)
							{
								objectToSpawn = new PitVacuum();
								if (pitVacVec) pitVacVec.push(objectToSpawn);
								else
								{
									pitVacVec = new Vector.<PitVacuum>();
									pitVacVec.push(objectToSpawn);

								}
								AO_DCT.addItem(objectToSpawn);
							}
							else
								continue;
						}
						else if (
							!determineHelperVisibility(itemText, player.usesHorzObjs, player.usesVertObjs) ||
							!getPropertyVisibility(itemText, PROP_BAD_SWIMMER, !player.isGoodSwimmer) ||
							!getPropertyVisibility(itemText, PROP_WIDE_CHARACTER, player.isWideCharacter) ||
							(!player.poorBowserFighter && itemText.indexOf(PROP_POOR_BOWSER_FIGHTER) != -1) ||
							(mapDifficulty == MapDifficulty.EASY && difficultiesToHideOn != null && difficultiesToHideOn.indexOf(HIDE_ON_DIFFICULTY_EASY) != -1) ||
							(mapDifficulty == MapDifficulty.NORMAL && difficultiesToHideOn != null && difficultiesToHideOn.indexOf(HIDE_ON_DIFFICULTY_NORMAL) != -1) ||
							(mapDifficulty == MapDifficulty.HARD && difficultiesToHideOn != null && difficultiesToHideOn.indexOf(HIDE_ON_DIFFICULTY_HARD) != -1)
						)
							continue;
						// check pickup shift right
						if (itemText.indexOf(PROP_SHIFT_RIGHT) != -1)
							shiftRight = true;
						if (itemText.indexOf(PROP_SHIFT_UP) != -1)
							shiftUp = true;
						// check if pObj can be inside Brick
	//					if (mt.indexOf("coin") != -1)
	//					{
	//						pBoxItem = "coin";
	//						pBoxable = true;
	//					}
	//					else if (mt.indexOf("mushroom") != -1)
	//					{
	//						pBoxItem = mt;
	//						pBoxable = true;
	//					}
	//					else if (mt.indexOf("star") != -1)
	//					{
	//						pBoxItem = mt;
	//						pBoxable = true;
	//					}
	//					else if (mt.indexOf("vineTransferStart") != -1)
	//					{
	//						pBoxItem = mt;
	//						pBoxable = true;
	//					}
						// check map first
						// GROUND
						if (itemText.indexOf("ground") != -1 || itemText.indexOf("block") != -1 || itemText.indexOf("cloudFace") != -1 || itemText.indexOf("platform") != -1 || itemText.indexOf("box") != -1)
						{
							if (itemText.indexOf("BillBlaster") == -1) // if it doesn't say Canon
							{
								if (itemText.indexOf("UnbreakableBrick") == -1)
								{
									if (!Cheats.allGroundIsBricks || itemText.indexOf("Pipe") != -1 || (flag != null && currentX >= flag.x) || (bowserAxe != null && currentX >= bowserAxe.x - TILE_SIZE) )
										objectToSpawn = new SimpleGround(itemText);
									else
									{
//										trace("currentX: "+currentX+" flagX: "+flag.x);
										objectToSpawn = new Brick( getSpawnedBrickItem(currentX, currentY) );
									}
									if (piranhaSpawnType == PiranhaSpawnType.AllPipes || piranhaSpawnType == PiranhaSpawnType.GreenAllPipes || piranhaSpawnType == PiranhaSpawnType.RedAllPipes)
									{
										if ( itemText.indexOf("PipeTopLeft") != -1 )
											addPiranhaAtLocationIfNotThere(currentX + TILE_SIZE, currentY, false);
										else if ( itemText.indexOf("PipeBottomLeft") != -1 )
											addPiranhaAtLocationIfNotThere(currentX + TILE_SIZE, currentY + TILE_SIZE, true);
									}

								}
								else
									objectToSpawn = new Brick(itemText);
							}
							else
							{
								if (itemText.indexOf("Top") != -1)
									objectToSpawn = new Canon();
								else
									objectToSpawn = new SimpleGround(itemText);
							}
						}
						// PIPE
						else if (itemText.indexOf("pipe") != -1 && itemText.indexOf("ground") == -1 && itemText.indexOf("Transporter") == -1)
						{
							objectToSpawn = new Pipe(itemText);
						}
						// BRICK
						else if (itemText.indexOf("brick") != -1)
						{
							objectToSpawn = new Brick(itemText);
//							Brick(objectToSpawn).getPickup(pBoxItem);
//							if (pBoxable)
//							{
//
//								pBoxed = true;
//								objectToSpawn = null;
//								itemText = "";
//							}
						}
						// ITEM BLOCK
						else if (itemText.indexOf("itemBlock") != -1)
						{
							objectToSpawn = new ItemBlock(itemText);
//							ItemBlock(objectToSpawn).getPickup(pBoxItem);
//							if (pBoxable)
//							{
//
//								pBoxed = true;
//								objectToSpawn = null;
//							}
						}
						// BRIDGE
						else if (itemText.indexOf("bowserBridge") != -1)
						{
							objectToSpawn = new BowserBridge(itemText);
						}
						// SPRING
						else if (itemText.indexOf("spring") != -1)
						{
							if (itemText.indexOf("Red") != -1)
								objectToSpawn = new SpringRed();
							else if (itemText.indexOf("Green") != -1)
								objectToSpawn = new SpringGreen();
						}
						// check pickups
						// ENEMY
						else if (itemText.indexOf("enemy") != -1)
						{
							if (allHammerBrosCheat && itemText.indexOf("Bowser") == -1)
								objectToSpawn = new HammerBro(itemText);
							else
							{
								if (itemText.indexOf("Goomba") != -1)
								{
									switch(goombaReplacementType)
									{
										case GoombaReplacementType.Goomba:
										{
											objectToSpawn = new Goomba(itemText);
											break;
										}
										case GoombaReplacementType.BuzzyBeetle:
										{
											objectToSpawn = new Beetle(itemText);
											break;
										}
										case GoombaReplacementType.Spiney:
										{
											objectToSpawn = new Spiney();
											break;
										}
										case GoombaReplacementType.SpikeTop:
										{
											objectToSpawn = new SpikeTop(itemText);
											break;
										}
									}
								}
								else if (itemText.indexOf("Koopa") != -1)
								{
									if (itemText.indexOf("Red") == -1)
										objectToSpawn = new KoopaGreen(itemText);
									else
										objectToSpawn = new KoopaRed(itemText);
								}
								else if (itemText.indexOf("Piranha") != -1)
								{
									var upsideDownPiranha:Boolean = false;
									if (itemText.indexOf(PiranhaGreen.UPSIDE_DOWN_STR) != -1)
										upsideDownPiranha = true;
									// make sure piranha is not already there
									if ( (!upsideDownPiranha && piranhaExistsAtLocation(currentX + TILE_SIZE, currentY, false) ) || (upsideDownPiranha && piranhaExistsAtLocation(currentX + TILE_SIZE, currentY + TILE_SIZE, true) ) )
										{}
									else
									{
										if (forcePiranhaType() == PiranhaGreen.RED || (forcePiranhaType() == null && itemText.indexOf(PiranhaGreen.RED) != -1) )
											objectToSpawn = new PiranhaRed(itemText);
										else
											objectToSpawn = new PiranhaGreen(itemText);
									}
								}
								else if (itemText.indexOf("Beetle") != -1)
									objectToSpawn = new Beetle(itemText);
								else if (itemText.indexOf("Cheep") != -1)
								{
									if (Math.random() > .5)
										objectToSpawn = new CheepFast("enemyCheepRed");
									else
										objectToSpawn = new CheepSlow("enemyCheepGreen");
								}
								else if (itemText.indexOf("Blooper") != -1)
									objectToSpawn = new Bloopa();
								else if (itemText.indexOf("HamBro") != -1)
									objectToSpawn = new HammerBro(itemText);
								else if (itemText.indexOf("Bowser") != -1)
								{
									if (itemText.indexOf("Fake") != -1)
										objectToSpawn = new BowserFake(itemText);
									else
										objectToSpawn = new Bowser(itemText);
								}
								else if (itemText.indexOf("SpikeTop") != -1)
									objectToSpawn = new SpikeTop(itemText);
								else if (itemText.indexOf("Spiney") != -1)
									objectToSpawn = new Spiney();
								// smb special
								else if (itemText.indexOf("Barrel") != -1)
									objectToSpawn = new Barrel(itemText);
								else if (itemText.indexOf("Crab") != -1)
									objectToSpawn = new Crab(itemText);
								else if (itemText.indexOf("FireEnemy") != -1)
									objectToSpawn = new FireEnemy(itemText);
								else if (itemText.indexOf("Fly") != -1)
									objectToSpawn = new Fly(itemText);
								else if (itemText.indexOf("Icicle") != -1)
									objectToSpawn = new Icicle(itemText);
							}
						}
						// TELEPORTER
						else if (itemText.indexOf("teleporter") != -1)
						{
							var teleNum:int = int(itemText.charAt(itemText.indexOf("&&number=") + 9));
							var teleType:String;
							var teleX:Number = currentX + TILE_SIZE*.5;
							var teleY:Number = currentY + TILE_SIZE;
							if (itemText.indexOf("Start") != -1)
							{
								if (itemText.indexOf("One") != -1)
									teleType = "startOne";
								else
									teleType = "start";
							}
							else if (itemText.indexOf("CheckPoint") != -1)
								teleType = "checkPoint";
							else if (itemText.indexOf("End") != -1)
								teleType = "end";
							if (teleDataVec)
								teleDataVec.push([teleType,teleNum,teleX,teleY]);
							else
							{
								teleDataVec = new Vector.<Array>();
								teleDataVec.push([teleType,teleNum,teleX,teleY]);
							}
						}
						// VINE
						else if (itemText.indexOf("vineStart") != -1)
								objectToSpawn = new Vine(itemText);
						else if (itemText.indexOf("pitTransfer") != -1)
						{
							if (itemText.indexOf("Start") != -1)
							{
								var transDest:String;
								var sInd:int = itemText.indexOf("&&pTransDest=")+13;
								var eInd:int = itemText.indexOf("&&",sInd);
								if (eInd == -1)
									eInd = itemText.length;
								transDest = itemText.substring(sInd,eInd);
								player.getPitTransfer(transDest);
							}
							else
								objectToSpawn = new PipeTransporter(itemText);
						}
						// LEVEL_EXIT
						else if (itemText.indexOf("levelExit") != -1)
						{
							objectToSpawn = new LevelExit();
							// set up castle flag
							if (flag != null || _flagPole != null)
							{
								castleFlag = new CastleFlag();
								castleFlag.x = currentX - TILE_SIZE;
								castleFlag.y = currentY - TILE_SIZE*4;
								castleFlagEndPosition = currentY - TILE_SIZE*4.85; //was *4.8, changed for accuracy
								fireworkPivotY = currentY - TILE_SIZE*5;
							}
						}
						// PIPE_TRANSPORTER
						else if (itemText.indexOf("pipeTransporter") != -1)
						{
							objectToSpawn = new PipeTransporter(itemText);
							if (itemText.indexOf("GlobalVertEnd") != -1)
							{
								if (pTransVec)
									pTransVec.push(objectToSpawn);
								else
								{
									pTransVec = new Vector.<PipeTransporter>;
									pTransVec.push(objectToSpawn);
								}
							}
						}

						else if (itemText.indexOf("gameStateWatch") != -1)
						{
							watchModeOverride = true;
						}
						// halfwayPoint
						else if (itemText.indexOf("halfwayPoint") != -1)
						{
							if (shiftRight)
								hwPnt = new Point(currentX + TILE_SIZE/2,currentY + TILE_SIZE);
							else
								hwPnt = new Point(currentX,currentY + TILE_SIZE);
						}
						// COIN
						else if (itemText.indexOf("coin") != -1 && !pBoxed) // changed to else
						{
							objectToSpawn = new Coin(itemText);
						}
						// PLATFORM
						else if (itemText.indexOf("movingPlatform") != -1)
						{
							objectToSpawn = new Platform(itemText);
							GROUND_DCT.addItem(objectToSpawn);
							if (itemText.indexOf(Platform.PT_PULLY) != -1)
							{
								Platform(objectToSpawn).pullyCornerX = currentX;
								if (pullyPlatVec)
									pullyPlatVec.push(objectToSpawn);
								else
								{
									pullyPlatVec = new Vector.<Platform>();
									pullyPlatVec.push(objectToSpawn);
								}
							}
						}
						// FIREBAR
						else if (itemText.indexOf("fireBar") != -1)
						{
							objectToSpawn = new FireBar(itemText);
						}
						// BULLET_BILL
						else if (itemText.indexOf("bulletBill") != -1)
						{

							if (itemText.indexOf("Start") != -1)
								bulBillBlackSpawnZoneStart = currentX;
							else if (itemText.indexOf("End") != -1)
								bulBillBlackSpawnZoneEnd = currentX;
						}
						// BULLET_BILL_END
//						else if (itemText.indexOf("spawnBulletBillGrayEnd") != -1)
//						{
//							fcEndX = currentX;
//						}
						// FLYINGCHEEPSTART
						else if (itemText.indexOf("flyingCheepStart") != -1)
						{
//							if ( isNaN(fcStartX) )
								fcStartX = currentX;
//							else
//								fcStartX_2 = currentX;
						}
						// FLYINGCHEEPEND
						else if (itemText.indexOf("flyingCheepEnd") != -1)
						{
							if ( !isNaN(fcStartX) )
							{
								ENEMY_SPAWNER_DCT.addItem(new FlyingCheepSpawner(fcStartX, currentX) );
								fcStartX = NaN;
							}
						}
						// LAKITU_START
						else if (itemText.indexOf("lakituStart") != -1)
						{
							lakSpawnZoneStart = currentX;
						}
						// LAKITU_END
						else if (itemText.indexOf("lakituEnd") != -1)
						{
							if (!isNaN(lakSpawnZoneStart) )
							{
								ENEMY_SPAWNER_DCT.addItem( new LakituSpawner(lakSpawnZoneStart, currentX, itemText.indexOf("Middle") != -1) );
								lakSpawnZoneStart = NaN;
							}
						}
						else if (itemText.indexOf("barrelSpawner") != -1)
						{
							barrelSpawner = new BarrelSpawner( new Point(currentX,currentY) );
						}
						// BOWSERFIREBALLSTART
						else if (itemText.indexOf("bowserFireBallStart") != -1)
						{
							bfbX = currentX;
						}
						// BOWSERAXE
						else if (itemText.indexOf("bowserAxe") != -1)
						{
							objectToSpawn = new BowserAxe();
							bowserAxe = BowserAxe(objectToSpawn);
						}
						// LAVAFIREBALL
						else if (itemText.indexOf("podoboo") != -1)
						{
							objectToSpawn = new LavaFireBall();
						}
						// playerSTART
						else if (itemText.indexOf("playerStart") != -1)
						{
							objectToSpawn = player;
						}
							// SCENERY
						else if (itemText != BLANK_TILE)
						{
							objectToSpawn = new Scenery(itemText);
							if (itemText == "bridgeChain")
								bbChain = Scenery(objectToSpawn);
							else if (itemText.indexOf("pullyCorner") != -1)
							{
								if (pullyCornerVec) pullyCornerVec.push(objectToSpawn);
								else
								{
									pullyCornerVec = new Vector.<Scenery>();
									pullyCornerVec.push(objectToSpawn);
								}
							}
							else if (itemText.indexOf("flag") != -1)
							{
								if (itemText.indexOf("Pole") != -1)
								{
									if (!_flagPole)
									{
										_flagPole = new FlagPole(currentX);
										addToLevelNow(_flagPole);
									}
								}
								else
									flag = objectToSpawn as Scenery;
							}

						}
 						while (objectToSpawn)
						{
							objectToSpawn.x = currentX;
							objectToSpawn.y = currentY;
							if (objectToSpawn is Platform) // doing this first becuase is ground shouldn't be called
							{
								objectToSpawn.x = currentX + TILE_SIZE/2;
								if (platVec)
									platVec.push(objectToSpawn);
								else
								{
									platVec = new Vector.<Platform>;
									platVec.push(objectToSpawn);
								}
							}
							else if (objectToSpawn is Ground)
							{
								GROUND_DCT.addItem(objectToSpawn);
								if (objectToSpawn is Brick)
									Brick(objectToSpawn).flag();
								else if (objectToSpawn is BowserBridge)
								{
									if (!bbVec)
										bbVec = new Vector.<BowserBridge>();
									bbVec.push(objectToSpawn);
								}
								else if (objectToSpawn is SpringRed)
								{
									var dg:DummyGround = new DummyGround();
									dg.x = currentX;
									dg.y = currentY - TILE_SIZE;
									GROUND_DCT.addItem(dg);
									dg.initiate();
								}
							}
							else if (objectToSpawn is Scenery)
							{
								if (objectToSpawn == flag)
									objectToSpawn.y -= TILE_SIZE*2;
								SCENERY_DCT.addItem(objectToSpawn);
								if (shiftRight && itemText.indexOf("sceneryTxt") != -1)
									objectToSpawn.y -= TILE_SIZE/2;
								AddSceneryToVec(objectToSpawn as Scenery);
							}
							else if (objectToSpawn is Projectile)
								objectToSpawn.y -= TILE_SIZE*.5;

							if (objectToSpawn is AnimatedObject)
							{
								objectToSpawn.x = currentX + TILE_SIZE/2;
								objectToSpawn.y = currentY + TILE_SIZE;
								AO_DCT.addItem(objectToSpawn);
							}
							if (shiftRight)
								objectToSpawn.x += TILE_SIZE*.5;
							if (shiftUp)
								objectToSpawn.y -= TILE_SIZE*.5;
							if (objectToSpawn is LevObj)
								LevObj(objectToSpawn).initiate();
							if (tile)
								tile.addItem(objectToSpawn);
							if ( _initialWaterLevel && currentY == Scenery.WAVE_Y_POS && !(objectToSpawn is Scenery) ) // what is this?
							{
								objectToSpawn = null;
								objectToSpawn = new Scenery(Scenery.WAVE_BASE_STR);
							}
							else
								objectToSpawn = null;
						}
					}
				}
			}
			initiateLevel();
		}

		private function getSpawnedBrickItem(xPosition:Number, yPosition:Number):String
		{
			var topRightGround:Ground = getGroundAt(xPosition + TILE_SIZE, yPosition - TILE_SIZE);
			if (topRightGround != null && topRightGround.currentLabel == SimpleGround.PIPE_SIDE_BOTTOM)
				return "whatever" + PROP_CONTAINED_ITEM + PROP_EQUALS + Brick.IT_SINGLE_COIN;
			else
				return "whatever";
		}

		private function forcePiranhaType():String
		{
			var piranhaSpawnType:PiranhaSpawnType = GameSettings.piranhaSpawnType;
			if (piranhaSpawnType == PiranhaSpawnType.GreenSomePipes || piranhaSpawnType == PiranhaSpawnType.GreenAllPipes)
				return PiranhaGreen.GREEN;
			else if (piranhaSpawnType == PiranhaSpawnType.RedSomePipes || piranhaSpawnType == PiranhaSpawnType.RedAllPipes)
				return PiranhaGreen.RED;
			return null;
		}

		private function piranhaExistsAtLocation(xPos:Number, yPos:Number, upsideDown:Boolean):Boolean
		{
			for each(var ao:AnimatedObject in AO_DCT)
			{
				if (ao is PiranhaGreen)
				{
					var existingPiranha:PiranhaGreen = ao as PiranhaGreen;
					if (existingPiranha.originalX == xPos && existingPiranha.originalY == yPos && existingPiranha.upsideDown == upsideDown)
						return true;
				}
			}
			return false;
		}
		private function addPiranhaAtLocationIfNotThere(xPos:Number, yPos:Number, upsideDown:Boolean):void
		{
			if ( piranhaExistsAtLocation(xPos, yPos, upsideDown) )
				return;
			var piranha:PiranhaGreen;
			var frameLabel:String = "";
			if (upsideDown)
				frameLabel = PiranhaGreen.UPSIDE_DOWN_STR;
			if (forcePiranhaType() == PiranhaGreen.RED)
				piranha = new PiranhaRed(frameLabel);
			else
				piranha = new PiranhaGreen(frameLabel);
			piranha.x = xPos;
			piranha.y = yPos;
			AO_DCT.addItem(piranha);
			piranha.initiate();
		}

		private function AddSceneryToVec(scenery:Scenery):void
		{
			var length:int = sceneryVec.length;
			var currentSceneryVec:Vector.<Scenery>;
			if (length == 0 || ( currentSceneryVec = sceneryVec[length - 1] ) == null || currentSceneryVec[0].x != scenery.x || currentSceneryVec[0].y != scenery.y)
				sceneryVec.push( new <Scenery>[scenery] );
			else
				currentSceneryVec.push(scenery);
		}
		// INITIATE level
		 public function initiateLevel():void
		{
//			sets up top screen display text]
			//applyColorFilter();
//			scrollRect = new Rectangle(0,0,GLOB_STG_RHT,GLOB_STG_BOT);
			if (bowser && bowser.onScreen)
				bowser.onScreen = false;
			if (!previouslyVisitedArea)
			{
				for each (var ground:Ground in GROUND_DCT)
				{
					if (ground is SimpleGround)
						SimpleGround(ground).checkNearbyGround();
				}
			}
			tsTxt = TopScreenText.instance;
			tsTxt.initiateLevelHandler();
			background.initiateLevelHandler();
			foreground.initiateLevelHandler();
//			foreground = new LevelForeground(this);
			//background.BG_VEC[0].addChild(tsTxt);
			STAT_MNGR.startNewLevel();
			Brick.initiateLevelHandler();
			ItemBlock.initiateLevelHandler();
			Coin.initiateLevelHandler();
			GraphicsManager.INSTANCE.initiateLevelHandler();
			replaceScenery();
			if (_initialWaterLevel)
				player.enterWater();
			STAGE.addEventListener(ENTER_FRAME_EVENT,enterFrameHandler,false,0,true);
			_moveDuringFreezeTmr = new CustomTimer(MOVE_PTS_TMR_INT);
			_moveDuringFreezeTmr.addEventListener(TimerEvent.TIMER,moveDuringFreezeTmrHandeler,false,0,true);
			if (pullyCornerVec && pullyPlatVec)
			{
				var i:int;
				var pullyPlatVecLen:int = pullyPlatVec.length;
				var pully:Platform;
				for (i = 0; i < pullyPlatVecLen; i++)
				{
					pully = pullyPlatVec[i];
					pully.getPartnerStep1();
				}
				for (i = 0; i < pullyPlatVecLen; i++)
				{
					pully = pullyPlatVec[i];
					pully.getPartnerStep2();
				}
				pullyCornerVec = null;
			}
			if (bowserAxe)
				bowserAxe.setUpBridge();
			if (flag && _flagPole)
				_flagPole.rcvFlag(flag);
			if (pitVacVec) setUpPitVacs();
//			if (!isNaN(fcStartX) && !isNaN(fcEndX) )
//				ENEMY_SPAWNER_DCT.addItem(new FlyingCheepSpawner(fcStartX,fcEndX) );
//			if (!isNaN(fcStartX_2) && !isNaN(fcEndX_2) )
//				ENEMY_SPAWNER_DCT.addItem(new FlyingCheepSpawner(fcStartX_2,fcEndX_2) );
//			if (!isNaN(lakSpawnZoneStart) && !isNaN(lakSpawnZoneEnd) )
//				ENEMY_SPAWNER_DCT.addItem(new LakituSpawner(lakSpawnZoneStart,lakSpawnZoneEnd));
//			if (!isNaN(bulBillGraySpawnZoneStart) && !isNaN(bulBillGraySpawnZoneEnd) )
//				ENEMY_SPAWNER_DCT.addItem(new BulletBillSpawner(bulBillGraySpawnZoneStart,bulBillGraySpawnZoneEnd,BulletBill.COLOR_GRAY) );
			if (!isNaN(bulBillBlackSpawnZoneStart) && !isNaN(bulBillBlackSpawnZoneEnd) )
				ENEMY_SPAWNER_DCT.addItem(new BulletBillSpawner(bulBillBlackSpawnZoneStart,bulBillBlackSpawnZoneEnd,BulletBill.COLOR_BLACK) );
			if (teleDataVec)
				setUpTeleporters();
			if (pExInt && pTransVec)
				changePlayerLoc();
			else if (hwPnt && shouldStartAtCheckPoint )
				startAtHalfwayPoint();
			setUpTiles();
			scrollScreen();
			checkCollisions(player);
			player.firstCollisionCheck();
//			sets up timers
			for each (var ct:CustomTimer in ALL_ANIM_TMRS_DCT)
			{
				ct.start();
			}
			for each (var animObj:AnimatedObject in AO_DCT) // makes sure objects nx and ny values are okay
			{
				animObj.drawObj();
			}
			//*
			if (GameSettings.DEBUG_MODE && !(this is TitleLevel) )
				addEventListener(MouseEvent.CLICK, clickLsr);
			//*/
			SND_MNGR.startLevel();
			RepeatingSilenceOverrideSnd.instance.playSound();
			LOOP_TMR.addEventListener(TimerEvent.TIMER, gameLoop);
			LOOP_TMR.start();
			GS_MNGR.lockGameState = false;
			if (!watchModeOverride && !watchModeOverrideVine && player.cState != Character.ST_PIPE)
			{
				GS_MNGR.gameState = GS_PLAY;
				BTN_MNGR.sendPlayerBtns();
				if (GameSettings.tutorials)
					TUT_MNGR.startLevel(player);
			}
			else if (watchModeOverride)
			{
				GS_MNGR.gameState = GS_WATCH;
				player.activateWatchModeEnterPipe();
				tsTxt.hideTime();
			}
			else if (watchModeOverrideVine)
			{
				GS_MNGR.gameState = GS_WATCH;
				BTN_MNGR.relPlyrBtns();
				player.upBtn = true;
				player.visible = false;
				if (player.vineToClimb)
					player.climbVineStarter(player.vineToClimb);
				tsTxt.hideTime();
			}
		}

		private function get shouldStartAtCheckPoint():Boolean
		{
			if ( STAT_MNGR.passedHw && (!levData.lockedCheckpoint || Cheats.extraCheckpoints || GameSettings.mapDifficulty == MapDifficulty.HARD || GameSettings.mapDifficulty == MapDifficulty.EASY) )
				return true;
			else
				return false;
		}

		private function replaceScenery():void
		{
			var platformStem:String = "standardPlatformStem";
			var railing:String = "railing";
//			var groundRail:String = "groundRail";
//			var railingDayMisspell:String = "raililngDay";
			var rail:String = "rail";
			const sLft:String = "Lft";
			const sMid:String = "Mid";
			const sRht:String = "Rht";
			const sTop:String = "Top";
			const sSin:String = "Sin";

			var bush:String = "bushGreen";
			var bushLeft:String = "bushGreenLeft";
			var bushMid:String = "bushGreenMid";
			var bushRight:String = "bushGreenRight";
			var bushSmall:String = "bushGreenSmall";

			var n:int = sceneryVec.length;
			for (var i:int; i < n; i++)
			{
				var objects:Vector.<Scenery> = null;
				var objects2:Vector.<Scenery> = null;
				var objects3:Vector.<Scenery> = null;
				if (i != 0)
					objects = sceneryVec[i - 1];
				objects2 = sceneryVec[i];
				if (i < n - 1)
					objects3 = sceneryVec[i+1];
//				if (i == 0) // first time only, otherwise first one isn't checked properly
//				{
//					objects3 = objects2;
//					objects2 = objects;
//					objects = null;
//				}
				if (objects2 == null || DESTROY_DCT[objects2])
					continue;
				autoDetectScenery(objects, objects2, objects3, railing, railing + sLft, railing + sMid, railing + sRht, null);
//				autoDetectScenery(objects, objects2, objects3, groundRail, groundRail + sLft, groundRail + sMid, groundRail + sRht, groundRail + sSin);
				autoDetectScenery(objects, objects2, objects3, bush, bushLeft, bushMid, bushRight, bushSmall);

//				if (objects2 != null)
//				{
					var scenery:Scenery = objects2[0];
					if (scenery != null && getGroundAt(scenery.x, scenery.y - TILE_SIZE) != null)
						autoDetectScenery(objects, objects2, objects3, platformStem, platformStem + sLft + sTop, platformStem + sMid + sTop, platformStem + sRht + sTop, platformStem + sSin + sTop);
					else
						autoDetectScenery(objects, objects2, objects3, platformStem, platformStem + sLft, platformStem + sMid, platformStem + sRht, platformStem + sSin);
//				}
			}
			destroyObj();
			for each (scenery in SCENERY_DCT)
			{
				scenery.cloneFromMaster([scenery.stopFrame]);
			}
			sceneryVec = null;
			resizeScenery();
		}

		private function autoDetectScenery(leftObjects:Vector.<Scenery>, middleObjects:Vector.<Scenery>, rightObjects:Vector.<Scenery>, labelToCheck:String, leftLabel:String, middleLabel:String, rightLabel:String, singleLabel:String):void
		{
			for each( var scenery:Scenery in middleObjects)
			{
//				if (labelToCheck == "railing")
//					trace("railing x: "+scenery.x+" y: "+scenery.y);
				if (scenery == null || scenery.stopFrame != labelToCheck || DESTROY_DCT[scenery])
					continue;
				if ( anyHasString(leftObjects, labelToCheck, scenery.x - TILE_SIZE) ) // on left
				{
					if ( anyHasString(rightObjects, labelToCheck, scenery.x + TILE_SIZE) ) // also on right
						scenery.gotoAndStop(middleLabel);
					else
						scenery.gotoAndStop(rightLabel);
				}
				else if ( anyHasString(rightObjects, labelToCheck, scenery.x + TILE_SIZE) ) // on right only
					scenery.gotoAndStop(leftLabel);
				else // no bush on left or right
					scenery.gotoAndStop(singleLabel);

			}
		}

		private function anyHasString(vec:Vector.<Scenery>, stopFrame:String, requiredX:Number):Boolean
		{
			if (vec == null || vec.length == 0)
				return false;
			for each( var scenery:Scenery in vec)
			{
				if (scenery != null && scenery.stopFrame.indexOf(stopFrame) != -1 && scenery.x == requiredX && DESTROY_DCT[scenery] == undefined)
					return true;
			}
			return false;
		}

		public function resizeScenery():void
		{
			var tempDct:Dictionary = new Dictionary(true);
			Scenery.mapSkin = GameSettings.getMapSkinLimited();
			for each (var s:Scenery in SCENERY_DCT)
			{
				if (s.updateOnSkinChange())
					tempDct[s] = s;
			}
//			resets grid position column
			for each (s in tempDct)
			{
				SCENERY_DCT.removeItem(s);
				SCENERY_DCT.addItem(s);
			}
		}
		private function changePlayerLoc():void
		{
			var pTransVecLen:int = pTransVec.length;
			for (var i:int = 0; i < pTransVecLen; i++)
			{
				var pt:PipeTransporter = pTransVec[i];
				if (pt.pipeInt == pExInt)
				{
					if (pExInt > 0)
						player.exitPipeVert(pt);
					else
					{
						player.x = pt.x;
						player.y = pt.y;
						player.nx = player.x;
						player.ny = player.y;
						player.setHitPoints()
					}
					if (autoScroll)
					{
						autoScrollStop();
						scrollScreen();
						autoScrollStart();
					}
					else
						scrollScreen();
					break;
				}
			}
			pTransVec = null;
			pExInt = 0;
			destroyNearbyEnemies(true);
		}
		private function applyColorFilter():void
		{
			var matrix:Array = [];
			matrix = matrix.concat([.33, .33, .33, 0, 0]); // red
			matrix = matrix.concat([.33, .33, .33, 0, 0]); // green
			matrix = matrix.concat([.33, .33, .33, 0, 0]); // blue
			matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
			var cmFilter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			//var cmFilter2 = new ColorMatrixFilter(matrix2);
			//var filter = new Array();
			//filter.splice(0,1,cmFilter);
			this.filters = [cmFilter];
		}
		private function calcLocStgPos():void
		{
			var locTopLeftPt:Point = globalToLocal(TOP_LFT_PT);
			var locBottomRightPt:Point = globalToLocal(BOTTOM_RHT_PT);
			locStgTop = locTopLeftPt.y;
			locStgLft = locTopLeftPt.x;
			locStgBot = locBottomRightPt.y;
			locStgRht = locBottomRightPt.x;
			lftTilePos = getNearestGrid(locStgLft,-1);
		}
		public function getNearestGrid(locToTest:Number,gridSide:int = 0):int
		{
			/* gridSide
			-1 = returns smaller grid
			0 = returns nearest grid
			1 = returns bigger grid
			*/
			if (locToTest % TILE_SIZE == 0) // checks if number is already on grid
				return locToTest;
			var num:int;
			var dec:Number = locToTest / TILE_SIZE;
			var smallNum:int = Math.floor(dec) * TILE_SIZE;
			var bigNum:int = smallNum + TILE_SIZE;
			if (gridSide == 1)
				return bigNum;
			else if (gridSide == -1)
				return smallNum;
			var bigNumDif:Number = bigNum - locToTest;
			var smallNumDif:Number = locToTest - smallNum;
			if (bigNumDif < 0)
				bigNumDif = -bigNumDif;
			if (smallNumDif < 0)
				smallNumDif = -smallNumDif;
			if (bigNumDif > smallNumDif)
				return smallNum;
			else
				return bigNum;
		}
		public function getCurrentGrid(_x:Number,_y:Number):Point
		{
			return new Point( getNearestGrid(_x,-1), getNearestGrid(_y,-1) );
		}
		private function startAtHalfwayPoint():void
		{
			player.x = hwPnt.x;
			player.nx = player.x;
			player.y = hwPnt.y;
			player.ny = player.y;
			player.setHitPoints();
			player.setLastHitPointsToCurrent();
			scrollScreen();
			destroyNearbyEnemies();
			destroyObj();
			STAT_MNGR.passedHw = true;
		}
		private function destroyNearbyEnemies(leavePiranhas:Boolean = false):void
		{
			for each (var ao:AnimatedObject in AO_DCT)
			{
				if ( !(ao is Enemy) || (ao is PiranhaGreen && leavePiranhas) )
					continue;
				var num:Number = ao.x - player.x;
				if (num < 0)
					num = -num;
				if (num < HW_ENEMY_REMOVAL_DIST)
					destroy(ao);
			}
			destroyObj();
		}
		private function setUpTiles():void
		{
			numLevChildren = numChildren;
			var n:int = numChildren;
			for (var i:int = 0;i < n;i++)
			{
				removeChildAt(0);
				//i--;
			}
			addChild(player);
			updLevTiles(true);
		}
		private function setUpPitVacs():void
		{
			var npv:PitVacuum;
			var cpv:PitVacuum;
			var pitStartInd:int = 0;
			var pitMidInd:Number;
			var pitEndInd:int;
			var pitLength:int;
			var cInd:int;
			var i:int = 0;
			var wholeNumber:Boolean;
			pitVacVec.forEach(function calcPitVacType(pv:PitVacuum,ind:int,vec:Vector.<PitVacuum>):void
			{
				if (ind != vec.length - 1) npv = vec[ind+1];
				else npv = null;
				if ((npv && pv.x - npv.x < -32) || !npv)
				{
					pitEndInd = ind;
					pitLength = pitEndInd - pitStartInd;
					pitMidInd = (pitStartInd + pitEndInd)/2;
					for (i = 0; i < pitLength+1; i++)
					{
						cInd = pitStartInd + i;
						cpv = vec[cInd];
						if (cInd < pitMidInd) cpv.setVacDir("down-right");
						else if (cInd == pitMidInd) cpv.setVacDir("down");
						else if (cInd > pitMidInd) cpv.setVacDir("down-left");
					}
					pitStartInd = ind+1;
				}
			});
		}
		private function setUpTeleporters():void
		{
			var i:int;
			var ctArr:Array;
			var ctType:String;
			var ctNum:int;
			var ctx:Number;
			var cty:Number;
			var ntArr:Array;
			var ntType:String;
			var ntNum:int;
			var ntx:Number;
			var nty:Number;
			var teleStartInd:int;
			var teleMidInd:Number;
			var teleEndInd:int;
			var teleLength:int;
			var teleHeight:Number;
			var teleX:Number;
			var teleY:Number;
			var cInd:int;
			var teleDataVecLen:int = teleDataVec.length;
			var teleporter:Teleporter;
			teleDataVec = teleDataVec.sort(sortTeleporters);
			for (i; i < teleDataVecLen; i++)
			{
				ctArr = teleDataVec[i];
				ctType = ctArr[0];
				ctNum = ctArr[1];
				ctx = ctArr[2];
				cty = ctArr[3];
				if (i != teleDataVecLen - 1)
				{
					ntArr = teleDataVec[i+1];
					ntType = ntArr[0];
					ntNum = ntArr[1];
					ntx = ntArr[2];
					nty = ntArr[3];
				}
				else
				{
					ntArr = null;
					ntType = null;
					ntNum = NaN;
					ntx = 0;
					nty = 0;
				}
				if (ctType == "checkPoint" || ctType == "start" || ctType == "startOne")
				{
					if ((ntArr && (ctType != ntType) || (ctNum != ntNum) || (ctx != ntx)) || !ntArr)
					{
						teleEndInd = i;
						teleLength = teleEndInd - teleStartInd;
						teleHeight = (cty + TILE_SIZE) - teleDataVec[teleStartInd][3];
						teleX = teleDataVec[teleStartInd][2];
						teleY = teleDataVec[teleEndInd][3];
						teleporter = new Teleporter(ctType,ctNum,teleX,teleY,teleHeight);
						teleStartInd = i+1;
					}
				}
				else if (ctType == "end")
				{
					teleporter = new Teleporter(ctType,ctNum,ctx,cty,TILE_SIZE);
					teleStartInd = i+1;
				}
			}
			if (teleVec) teleVec.forEach(function tpSetUp(tp:Teleporter,ind:int,vec:Vector.<Teleporter>):void
			{
				tp.getRelationships();
			});
			function sortTeleporters(a1:Array,a2:Array):int
			{
				var phase1:int = sortStrings(a1[0],a2[0]);
				if (phase1 != 0)
					return phase1;
				var phase2:int = sortStrings(a1[1],a2[1]);
				if (phase2 != 0)
					return phase2;
				var phase3:int = sortNums(a1[2],a2[2]);
				if (phase3 != 0)
					return phase3;
				var phase4:int = sortStrings(a1[3],a2[3]);
				return phase4;
			}
		}
		// GAMELOOP
		protected function gameLoop(evt:TimerEvent):void
		{
			ldt = dt;
			dt = TD_CALC.getTD(); // get time difference since last update
			if (manualGameLoop && !manualGameLoopNextFrame)
				return;
			if (offsetDT)
			{
				dt = ldt;
				offsetDT = false;
			}
			if (dt > DT_MAX)
				dt = DT_MAX;
			var locTopLeftPt:Point = globalToLocal(TOP_LFT_PT);
			var locBottomRightPt:Point = globalToLocal(BOTTOM_RHT_PT);
			locStgTop = locTopLeftPt.y;
			locStgLft = locTopLeftPt.x;
			locStgBot = locBottomRightPt.y;
			locStgRht = locBottomRightPt.x;
			STAGE.focus = null;
			for each (var glTmr:GameLoopTimer in GAME_LOOP_TMRS_DCT)
			{
				if (glTmr.running)
					glTmr.update();
			}
			if (STAT_MNGR.runTimeLeft)
				STAT_MNGR.calcTimeLeft();
			if (platVec)
				platVec.forEach(function updPlats(elem:Platform,ind:int,vec:Vector.<Platform>):void
			{
				if (elem.onScreen || elem.updateOffScreen)
					elem.updateGround();
			});
			// fix gameState look up to improve speed
			for each (var ao:AnimatedObject in AO_STG_DCT)
			{
				if (GS_MNGR.gameState == "cleanUp")
					break;
				if ( !ao.stopUpdate && (ao.onScreen || ao.updateOffScreen) )
					ao.updateObj();
				else
					ao.updateStatusEffects();
				ao.hitDct.clear();
			}
			if (GS_MNGR.gameState == "cleanUp")
				return;
			for each (var levObj:LevObj in UPDATE_DCT)
			{
				levObj.updateObj();
				levObj.hitDct.clear();
			}
			if (ENEMY_SPAWNER_DCT.length)
			{
				for each (var es:EnemySpawner in ENEMY_SPAWNER_DCT)
				{
					if (es.active)
						es.updateSpawner();
				}
			}
			for each (var g:Ground in GROUND_STG_DCT)
			{
				if (g is Brick || g is SpringRed)
					g.updateGround();
				g.hitDct.clear();
			}
			//if (player is Sophia)
			//	trace("lhRht: "+player.lhRht+" hRht: "+player.hRht+" lhLft: "+player.lhLft+" hLft: "+player.hLft);
			checkCollisions(); // projectiles get checked against ground when they're created
			if (player.canCrossSmallGaps && !player.onGround && player.lastOnGround)
				checkCrossSmallGap(player);
			if (!player.onGround && player.vy != 0 && ( (player.wallOnRight && player.rhtBtn && !player.lftBtn) || (player.wallOnLeft && player.lftBtn && !player.rhtBtn) ) )
				checkForceIntoSmallGap(player);
			if (_flagPole && (_flagPole.onScreen || _flagPole.updateOffScreen) )
				_flagPole.checkPlayerLoc();
			if (!STAT_MNGR.passedHw && hwPnt && player.nx >= hwPnt.x && !levelIDToLoad && !player.dead)
				STAT_MNGR.passHalfwayPoint();
			if (pullyPlatVec) pullyPlatVec.forEach(function updPully(elem:Platform,ind:int,vec:Vector.<Platform>):void
			{
				if (elem.onScreen || elem.updateOffScreen)
					elem.updatePully()
			});
			for each (ao in AO_STG_DCT)
			{
				ao.drawObj();
			}
			scrollScreen();
			if (ADD_DCT.length)
				addObj();
			var brick:Brick;
			Brick.bounceAndBreakNow = true;
			// check if bricks need to be bounced
			var bricksToBounceDct:CustomDictionary = Brick.BRICKS_TO_BOUNCE_DCT;
			if (bricksToBounceDct.length)
			{
				for each (brick in bricksToBounceDct)
				{
					brick.bounce();
					brick.disableThisRoundOnly = false;
				}
			}
			// check if bricks need to be broken
			var bricksToBreakDct:CustomDictionary = Brick.BRICKS_TO_BREAK_DCT;
			if (bricksToBreakDct.length)
			{
				for each (brick in bricksToBreakDct)
				{
					brick.breakBrick();
				}
			}
			Brick.bounceAndBreakNow = false;
			if (DESTROY_DCT.length)
				destroyObj();
			updLevTiles(checkAllObjectsOnScreen);
			if (foreground.SCORE_POP_DCT.length)
				foreground.updateScorePops();
			if (bfbX && bowser && !bowser.onScreen)
			{
				if (player.nx >= bfbX)
				{
					if (!bowser.FB_TMR.running && bowser.FB_DCT.length < Bowser.MAX_FIREBALLS_ON_SCREEN)
						bowser.startFbTmr();
				}
			}
			if (SND_MNGR.readyToPlay)
				SND_MNGR.playStoredSounds(SOUNDS_TO_PLAY_DCT);
			if (raiseCastleFlag)
			{
				if (castleFlag.y > castleFlagEndPosition)
					castleFlag.y -= RAISE_CASTLE_FLAG_INT*dt;
				else
				{
					castleFlag.y = castleFlagEndPosition;
					raiseCastleFlag = false;
				}
			}
			if (_beatLevel)
				completeLevel();
			else if (areaToLoadArr)
				loadArea(areaToLoadArr[0],areaToLoadArr[1]);
			else if (levelIDToLoad)
				loadNewLevel(levelIDToLoad);

			STAGE.invalidate();
			manualGameLoopNextFrame = false;
			dispatchEvent(GAME_LOOP_END_EVENT);
		}
		// CHECKCOLLISIONS
		// this is also called by projectiles as soon as they're created
		public function checkCollisions(singleObject:AnimatedObject = null):void
		{
			//var gColArr:Array = new Array();
			var penAmt:Number;
			var n:int;
			var ao:AnimatedObject;
			aoVecHt = AO_STG_DCT.AO_VEC;
			aoVecHtLen = aoVecHt.length; // if something gets removed from the stage, this value will change
			/*sortedGroundVec = null;
			sortedGroundVec = new Vector.<Ground>();
			var numRows:int = groundRowDcts.length;
			sortedGroundVecLen = sortedGroundVec.length;*/
			/*for (i = 0; i < sortedGroundVecLen; i++)
			{
				var grnd:Ground = sortedGroundVec[i];
				trace(grnd.x.toString() + "," + grnd.y.toString());
			}
			trace("finish sort");*/
			if (singleObject)
			{
				ao = singleObject;
				singleObject.hitDct.clear();
				//aoVecHtLen = 1;
				if ( (singleObject.onScreen || singleObject.updateOffScreen) && !singleObject.stopHit)
				{
					if (singleObject.hitDistOver)
						maxDist = singleObject.hitDistOver;
					aoHT(ao,0);
					groundHT(ao);
				}
				return;
			}
			ao = player;
			(ao as Character).curHitDct.clear();
			if (!player.stopHit)
			{
				if (player.hitDistOver)
					maxDist = player.hitDistOver;
				groundHT(ao);
				if ( !(this is CharacterSelect) )
				{
					if (player.hLft <= SCREEN_MAX_LEFT_SCROLL + SCREEN_UNWALKABLE_BUFFER)
					{
						player.groundOnSide(null,"left");
						player.nx = player.hWidth*.5 + SCREEN_MAX_LEFT_SCROLL + SCREEN_UNWALKABLE_BUFFER;
						player.setHitPoints();
					}
					else if (player.hLft <= locStgLft + SCREEN_UNWALKABLE_BUFFER)
					{
						player.groundOnSide(null,"left");
						player.nx = player.hWidth*.5 + locStgLft + SCREEN_UNWALKABLE_BUFFER;
						player.setHitPoints();
					}
					else if (player.hRht >= (screenMaxRightScroll + SCREEN_WIDTH) - SCREEN_UNWALKABLE_BUFFER)
					{
						player.groundOnSide(null,"right");
						player.nx = (screenMaxRightScroll + SCREEN_WIDTH) - (player.hWidth*.5 + SCREEN_UNWALKABLE_BUFFER);
						player.setHitPoints();
					}
				}
			}
			for (var i:int = 0; i < aoVecHtLen; i++)
			{
				ao = aoVecHt[i];
				//if ( (!ao.onScreen && !ao.updateOffScreen) || ao.stopHit)
				if (ao.stopHit)
					continue;
				maxDist = DEFAULT_MAX_HIT_TEST_DISTANCE;
				aoHT(ao,i);
				if (ao != player)
					groundHT(ao);
			}
			if (gBounceArr.length)
			{
				if (gBounceArr.length == 1)
				{
					gBounceArr[0].hitCharacterBounceOrBreak();
					gBounceArr.pop();
				}
				else if (gBounceArr.length > 1 && !player.canHitMultipleBricks)
				{
					gBounceArr.sortOn("yPenAmt",Array.NUMERIC);
					gBounceArr[0].hitCharacterBounceOrBreak();
					gBounceArr = [];
				}
				else if (player.canHitMultipleBricks)
				{
					n = gBounceArr.length;
					for (i = 0; i < n; i++)
					{
						Brick(gBounceArr[i]).hitCharacterBounceOrBreak();
					}
					gBounceArr = [];
				}
			}
		}
		private function aoHT(ao:AnimatedObject,i:int):void
		{
			var j:int = i+1;
			outer: for (j; j < aoVecHtLen; j++)
			{
				var ao2:AnimatedObject = aoVecHt[j];
				//if ( (!ao2.onScreen && !ao2.updateOffScreen) || ao2.stopHit || ao.stopHit)
				if (ao2.stopHit || ao.stopHit || !(i < aoVecHtLen - 1) )
					continue;
				if (ao.hitDistOver || ao2.hitDistOver)
					checkMaxDistOver(ao,ao2);
				if (getDistance(ao.hMidX,ao.hMidY,ao2.hMidX,ao2.hMidY) > maxDist)
					continue;
				/*if ( (ao2 is Enemy && ao.testEnemy && !(ao is Enemy && !ao2.testEnemy) ) || (ao2 is Character && ao.testChar) || (ao2 is Pickup && ao.testPickup) || (ao2 is Projectile && ao.testProj) )
				{
					if (ao2 is Projectile)
					{
						if (ao is Character && ( (ao2 is SamusBomb && SamusBomb(ao2).checkAtkRect) || (ao2 is LinkBoomerang && LinkBoomerang(ao2).followPlayer) || (ao2 is RyuProjectile && RyuProjectile(ao2).destroyHitChar) ))
							ao.testCharProj = true; // tests only for character projectile during this time

						if ((Projectile(ao2).projOrigin == PO_PLAYER && ao.testCharProj) || (Projectile(ao2).projOrigin == PO_ENEMY && ao.testEnemyProj))
						{
							if ((!(ao2 is SamusBomb) || (ao2 is SamusBomb && SamusBomb(ao2).checkAtkRect)) && i < aoVecHtLen - 1)
								ht.hTest(ao,ao2);
						}
					}
					else if (i < aoVecHtLen - 1)
						ht.hTest(ao,ao2);
				}*/
				/*if (ao is MegaManBullet || ao2 is MegaManBullet)
				{
					trace("ao: "+ao+" ao2: "+ao2);
					return;
				}*/
				var aoTypes:CustomDictionary = ao.hitTestTypesDct;
				var ao2Types:CustomDictionary = ao2.hitTestTypesDct;
				var aoTa:CustomDictionary = ao.hitTestAgainstNonGroundDct;
				var ao2Ta:CustomDictionary = ao2.hitTestAgainstNonGroundDct;
				for each (var aoType:String in aoTypes)
				{
					for each (var ao2Type:String in ao2Types)
					{
						if ( aoTa[ao2Type] && ao2Ta[aoType] )
						{
							ht.hTest(ao,ao2);
							continue outer;
						}
					}
				}
			}
		}

		private function checkMaxDistOver(mc1:LevObj,mc2:LevObj):void
		{
			var mc1Dist:int;
			var mc2Dist:int;
			if (mc1.hitDistOver)
			{
				mc1Dist = mc1.hitDistOver;
				if (mc2.hitDistOver)
				{
					mc2Dist = mc2.hitDistOver;
					if (mc1Dist > mc2Dist)
						maxDist = mc1Dist;
					else
						maxDist = mc2Dist;
				}
				else
					maxDist = mc1Dist;
			}
			else if (mc2.hitDistOver)
			{
				mc2Dist = mc2.hitDistOver;
				if (mc1.hitDistOver)
				{
					mc1Dist = mc1.hitDistOver;
					if (mc2Dist > mc1Dist)
						maxDist = mc2Dist;
					else
						maxDist = mc1Dist;
				}
				else
					maxDist = mc2Dist;
			}
		}
		private function sortStrings(s1:String,s2:String):int
		{
			if (s1 < s2) return -1;
			else if (s1 > s2) return 1;
			else return 0;
		}
		private function sortNums(n1:Number,n2:Number):int
		{
			if (n1 < n2)
				return -1;
			else if (n1 > n2)
				return 1;
			else
				return 0;
		}
		// sorts ground by y and then x
		private function sortGround(g1:Ground,g2:Ground):int
		{
			var n1:int = g1.y;
			var n2:int = g2.y;
			if (n1 < n2)
				return -1;
			else if (n1 > n2)
				return 1;
			else
				return 0;
		}
		private function checkForceIntoSmallGap(char:Character):void
		{
			var dyMax:int = TILE_SIZE*.75; // maximum difference between char.ny and char.ly
			var dy:Number = char.ny - char.ly;
			var anySizeGap:Boolean;
			if (dy < 0)
				dy = -dy;
			if (dy > dyMax)
				return;
			var dirX:int = -1;
			var dirY:int = -1;
			if (char.rhtBtn && !char.lftBtn)
				dirX = 1;
			if (char.vy > 0)
				dirY = 1;
			//if (dirY < 0)
			//	return; // just for now
			var xOfs:int;
			var yOfs:int;
			if (dirX < 0)
				xOfs = -TILE_SIZE;
			if (dirY < 0)
				yOfs = -char.hHeight;
			var point:Point = getCurrentGrid(char.nx + xOfs + char.hWidth*.5*dirX,char.ny + yOfs);
			//trace("point.x: "+point.x+" point.y: "+point.y);
			var ground:Ground = getGroundAt(point.x,point.y);
			//trace("dirX: "+dirX+" dirY: "+dirY+" ground: "+ground);
			if (!ground) // there should be ground here because char needs to have just missed it
				return;
			point = getCurrentGrid(point.x,char.ly + yOfs);
			if (getGroundAt(point.x,point.y)) // there should not be ground at last position
				return;
			if (char.hWidth >= TILE_SIZE) // will not test for certain size gaps
				anySizeGap = true;
			else
			{
				var gapSize:int = TILE_SIZE;
				if (char.hHeight > TILE_SIZE)
					gapSize *= 2;
				if (!getGroundAt(ground.x,ground.y - (gapSize + TILE_SIZE)*dirY) ) // checks to make sure it's a gap by seeing if there is ground above or below
					return;
				if (gapSize == TILE_SIZE*2 && getGroundAt(ground.x,ground.y - gapSize*dirY) ) // makes sure gap is two spaces big
					return;
			}
			if (char.vy > 0)
				char.groundBelow(ground);
			else
			{
				char.groundAbove(ground);
				ground.hit(char,HitTester.SIDE_BOTTOM);
			}
			char.nx += 1*dirX;
			char.setHitPoints();
		}
		private function checkCrossSmallGap(char:Character):void
		{
			var curCol:int = getNearestGrid(player.nx,-1);
			var lftColNum:int = curCol - TILE_SIZE;
			var rhtColNum:int = curCol + TILE_SIZE;
			if (lftColNum <= 0)
				return;
			if (rhtColNum >= mapWidth)
				return;
			var groundOnLeft:Boolean = false;
			var groundOnRight:Boolean = false;
			var lftColDct:Dictionary = groundColDcts[lftColNum];
			var rhtColDct:Dictionary = groundColDcts[rhtColNum];
			var g:Ground;
			var groundToStandOn:Ground;
			var cy:Number = player.y;
			for each (g in lftColDct)
			{
				if (g.y == cy && !(g is Platform) )
				{
					groundOnLeft = true;
					break;
				}
			}
			if (!groundOnLeft)
				return;
			for each (g in rhtColDct)
			{
				if (g.y == cy && !(g is Platform) )
				{
					groundToStandOn = g;
					groundOnRight = true;
					break;
				}
			}
			if (!groundOnRight)
				return;
			else
			{
				player.groundBelow(groundToStandOn); // uses ground to the right of player
				player.setHitPoints();
			}
		}
		public function addToProjHitArr(proj:Projectile,mc:LevObj):void
		{
			if ( !proj.getProperty(AP_PASSTHROUGH_DEFEAT) && !proj.getProperty(AP_PASSTHROUGH_ALWAYS) )
			{
				if (mc is Brick)
				{	if (!projHitArr)
						projHitArr = [[Brick(mc),proj]];
					else
						projHitArr.push([Brick(mc),proj]);
				}
				else if (mc is Enemy)
				{
					if (!projHitArr)
						projHitArr = [[Enemy(mc),proj]];
					else
						projHitArr.push([Enemy(mc),proj]);
				}
			}
			else if (mc is Brick)
				Brick(mc).confirmedHitProj(proj);
			else if (mc is Enemy)
				Enemy(mc).confirmedHitProj(proj);
		}
		private function animTmrFlashingItemHandler(event:TimerEvent):void
		{
			ACTIVE_ANIM_TMRS_DCT.addItem(ANIM_TMR_FLASHING_ITEM);
			STAGE.invalidate();
		}
		private function animSuperSlowestTmrHandler(e:TimerEvent):void
		{
			ACTIVE_ANIM_TMRS_DCT.addItem(ANIM_SUPER_SLOWEST_TMR);
			STAGE.invalidate();
		}
		private function animVerySlowTmrHandler(e:TimerEvent):void
		{
			ACTIVE_ANIM_TMRS_DCT.addItem(ANIM_VERY_SLOW_TMR);
			STAGE.invalidate();
		}
		private function animSlowTmrHandler(e:TimerEvent):void
		{
			ACTIVE_ANIM_TMRS_DCT.addItem(ANIM_SLOW_TMR);
			STAGE.invalidate();
		}
		private function animModerateTmrHandler(e:TimerEvent):void
		{
			ACTIVE_ANIM_TMRS_DCT.addItem(ANIM_MODERATE_TMR);
			STAGE.invalidate();
		}
		private function animMinFastTmrHandler(e:TimerEvent):void
		{
			ACTIVE_ANIM_TMRS_DCT.addItem(ANIM_MIN_FAST_TMR);
			STAGE.invalidate();
		}
		private function animFastTmrHandler(e:TimerEvent):void
		{
			ACTIVE_ANIM_TMRS_DCT.addItem(ANIM_FAST_TMR);
			STAGE.invalidate();
		}
		private function enterFrameHandler(event:Event):void
		{
			if (CHANGE_COLOR_OBJS_DCT.length)
			{
				if (GS_MNGR.gameState == GS_PLAY || GS_MNGR.gameState == GS_WATCH)
				{
					for each (var en:Enemy in CHANGE_COLOR_OBJS_DCT)
					{
						en.resetColor();
						en.changeColorThisCycle = false;
					}
				}
			}
		}
		public function captureFrameOnRender():void
		{
			stage.invalidate();
			captureFrame = true;
		}
		// RENDERLISTENER
		private function renderLsr(e:Event):void
		{
			if (manualGameLoop && !manualGameLoopNextFrame)
				return;
			var i:int;
			var n:int;
			var ao:CustomMovieClip;
			var ct:CustomTimer;
			for each (ao in AO_STG_DCT)
			{
				if (ao is Coin || ao is BowserAxe) // this is really stupid and costly
					continue;
				if (GS_MNGR.gameState != "freeze")
				{
					for each (ct in ao.ACTIVE_ANIM_TMRS_DCT)
					{
						if (ACTIVE_ANIM_TMRS_DCT[ct])
						{
							ao.animate(ct);
							if (ct == ao.mainAnimTmr && (!ao.stopAnim || (ao.stopAnim && ao.checkFrameDuringStopAnim) ) )
								ao.checkFrame();
						}
					}
				}
				else if (ao == player || ao is FireBar)
				{
					for each (ct in ao.ACTIVE_ANIM_TMRS_DCT)
					{
						if (ACTIVE_ANIM_TMRS_DCT[ct])
						{
							ao.animate(ct);
							if (ct == ao.mainAnimTmr && (!ao.stopAnim || (ao.stopAnim && ao.checkFrameDuringStopAnim) ) )
								ao.checkFrame();
						}
					}
				}
			}
			for each (var animItem:CustomMovieClip in ANIM_DCT)
			{
				if (GS_MNGR.gameState != "freeze")
				{
					for each (ct in animItem.ACTIVE_ANIM_TMRS_DCT)
					{
						if (ACTIVE_ANIM_TMRS_DCT[ct])
						{
							animItem.animate(ct);
							if (ct == animItem.mainAnimTmr && (!animItem.stopAnim || (animItem.stopAnim && animItem.checkFrameDuringStopAnim) ) )
								animItem.checkFrame();
						}
					}
				}
				else if (ao == player || ao is FireBar)
				{
					for each (ct in ao.ACTIVE_ANIM_TMRS_DCT)
					{
						if (ACTIVE_ANIM_TMRS_DCT[ct])
						{
							ao.animate(ct);
							if (ct == ao.mainAnimTmr && (!ao.stopAnim || (ao.stopAnim && ao.checkFrameDuringStopAnim) ) )
								ao.checkFrame();
						}
					}
				}
			}
			for each (var levObj:CustomMovieClip in ALWAYS_ANIM_DCT)
			{
				//if (!levObj.animated || ( !(levObj is ItemBlock) && (!levObj.onScreen && !levObj.updateOffScreen) ) )
				//	continue;
				for each (ct in levObj.ACTIVE_ANIM_TMRS_DCT)
				{
					if (ACTIVE_ANIM_TMRS_DCT[ct])
					{
						levObj.animate(ct);
						if (ct == levObj.mainAnimTmr)
							levObj.checkFrame();
					}
				}
			}
			for each (var enemy:Enemy in CHANGE_COLOR_OBJS_DCT)
			{
				if (enemy.changeColorThisCycle)
					enemy.changeColor();
			}
			for each (var something:LevObj in RECOLOR_OBJS_DCT)
			{
				something.initiateRecolor();
				RECOLOR_OBJS_DCT.removeItem(something);
			}
			if (ACTIVE_ANIM_TMRS_DCT[TopScreenText.COIN_ANIM_TMR])
				tsTxt.animateCoin();
//			if (player.replaceColor && !(player is Sophia))
//				player.updClone();
			ACTIVE_ANIM_TMRS_DCT.clear();
			for each (var lObj:LevObj in LEV_OBJ_FINAL_CHECK)
			{
				lObj.finalCheck();
			}
			if (manualGameLoop)
				manualGameLoopNextFrame = false;
			if (captureFrame)
			{
				ImageSaver.INSTANCE.store(GAME);
				captureFrame = false;
			}
			//pauseGame();
		/*	GAME.gameBm.scaleX = 1;
			GAME.gameBm.visible = false;
			GAME.gameBmd.draw(GAME);
			GAME.gameBm.scaleX = 1.25;
			GAME.gameBm.visible = true;
			GAME.setChildIndex(GAME.gameBm,GAME.numChildren-1);*/
		}
		// ADDTOlevel add an object to the level
		public function addToLevel(mc:DisplayObject):void
		{
			ADD_DCT.addItem(mc);
		}
		// ADDTOlevel add an object to the level
		public function addToLevelNow(mc:DisplayObject):void
		{
			addToLevel(mc);
			addObj();
		}
		private function updLevTiles(checkAllTiles:Boolean = false):void
		{
			if (!checkAllTiles)
				checkStgPositionLocal();
			else
				checkStgPositionAll();
			sortStgObjIntoDcts();
			setIndexOfStgObjs();
			checkAllObjectsOnScreen = false;
			//sortedGroundVec = GROUND_STG_DCT.GROUND_VEC.sort(sortGround);
			/*var n:int = sortedGroundVec.length;
			for (var i:int = 0; i < n; i++)
			{
				var grnd:Ground = sortedGroundVec[i];
				trace(grnd.x.toString() + "," + grnd.y.toString());
			}
			trace("finish sort");*/


			//trace("aoStg: "+numAos+" aoDct: "+AO_STG_DCT.length+" gStg: "+numGround+" gDct: "+GROUND_STG_DCT.length+" sStg: "+numScenery+" sDct: "+SCENERY_STG_DCT.length);
			// the order that things appear in the game

		}
		private function checkStgPositionLocal():void
		{
			var ao:AnimatedObject;
			var g:Ground;
			var s:Scenery;
			var dct:Dictionary;
			var sceneryDct:CustomDictionary;
			var tileDif:Number = locStgLft - lftTilePos;
			if (tileDif > TILE_SIZE)
				lftTilePos += TILE_SIZE;
			else if (tileDif <= 0)
				lftTilePos -= TILE_SIZE;
			if (lftTilePos < 0)
				lftTilePos = 0;
			rhtTilePos = lftTilePos + SCREEN_WIDTH;
			var groundLftCol:int = lftTilePos - TILE_SIZE*2;
			var groundRhtCol:int = rhtTilePos + TILE_SIZE*2;
			var sceneryLftCol:int = lftTilePos;
			var sceneryRhtCol:int = rhtTilePos;
			var sceneryRhtColMore:int = sceneryRhtCol + TILE_SIZE;
			for each (ao in AO_DCT)
			{
				ao.checkStgPos();
			}
			for each (g in GROUND_STG_DCT)
			{
				g.checkStgPos();
			}
			if (groundLftCol >= 0)
			{
				dct = groundColDcts[groundLftCol];
				for each (g in dct)
				{
					g.checkStgPos();
				}
			}
			if (groundRhtCol < mapWidth)
			{
				dct = groundColDcts[groundRhtCol];
				for each (g in dct)
				{
					g.checkStgPos();
				}
			}
			if (platVec)
			{
				dct = groundColDcts[GROUND_DCT.PLATFORM_KEY];
				for each (g in dct)
				{
					g.checkStgPos();
				}
			}
			for each (s in SCENERY_STG_DCT)
			{
				s.checkStgPos();
			}
			if (sceneryLftCol >= 0)
			{
				dct = sceneryColDcts[sceneryLftCol];
				for each (sceneryDct in dct)
				{
					for each (s in sceneryDct)
					{
						s.checkStgPos();
					}
				}
			}
			if (sceneryRhtCol < mapWidth)
			{
				dct = sceneryColDcts[sceneryRhtCol];
				for each (sceneryDct in dct)
				{
					for each (s in sceneryDct)
					{
						s.checkStgPos();
					}
				}
				dct = sceneryColDcts[sceneryRhtColMore];
				for each (sceneryDct in dct)
				{
					for each (s in sceneryDct)
					{
						s.checkStgPos();
					}
				}
			}
			dct = sceneryColDcts[SCENERY_DCT_NON_GRID_ITEM_KEY];
			for each (s in dct)
			{
				s.checkStgPos();
			}
		}
		private function checkStgPositionAll():void
		{
			calcLocStgPos();
			for each (var ao:AnimatedObject in AO_DCT)
			{
				ao.checkStgPos();
			}
			for each (var g:Ground in GROUND_DCT)
			{
				g.checkStgPos();
			}
			for each (var s:Scenery in SCENERY_DCT)
			{
				s.checkStgPos();
			}
		}
		private function sortStgObjIntoDcts():void
		{
			for each (var sao:CustomMovieClip in ANIM_DCT)
			{
				if (sao is SimpleAnimatedObject && sao.parent == this)
					AO_ORDER_STG_DCT.addItem(sao);
			}
			for each (var ao:AnimatedObject in AO_STG_DCT)
			{
				/*if (ao.parent != this)
				{
				AO_STG_DCT.removeItem(ao);
				continue;
				}*/
				if (ao.behindGround)
				{
					if (ao is Coin)
						COIN_STG_DCT.addItem(ao);
					else
						BEHIND_GROUND_STG_DCT.addItem(ao);
				}
				else if (ao.afterGround)
					AFTER_GROUND_STG_DCT.addItem(ao);
				else if (ao.bottomAo)
					AO_BOTTOM_STG_DCT.addItem(ao);
				else
					AO_ORDER_STG_DCT.addItem(ao);
			}
			for each (var g:Ground in GROUND_STG_DCT)
			{
				/*if (g.parent != this)
				{
				GROUND_STG_DCT.removeItem(g);
				continue;
				}*/
				if (!(g is Platform))
				{
					if (g.afterGround)
						AFTER_GROUND_STG_DCT.addItem(g);
					else
						GROUND_ORDER_STG_DCT.addItem(g);
				}
				else
					PLAT_STG_DCT.addItem(g);
			}
		}
		protected function setIndexOfStgObjs():void
		{
			var insertInd:int = 0;
			var dispObj:DisplayObject;
			var backSceneryDct:CustomDictionary = new CustomDictionary(true);
			var normalSceneryDct:CustomDictionary = new CustomDictionary(true);
			var frontSceneryDct:CustomDictionary = new CustomDictionary(true);
			for each (var scenery:Scenery in SCENERY_STG_DCT)
			{
				if (scenery.inFrontOfEverything)
					TOP_STG_DCT.addItem(scenery);
				else if (scenery.topLayer)
					frontSceneryDct.addItem(scenery);
				else if (scenery.bottomLayer)
					backSceneryDct.addItem(scenery);
				else
					normalSceneryDct.addItem(scenery);
			}
			for each (dispObj in backSceneryDct)
			{
				setIndex(dispObj);
			}
			for each (dispObj in normalSceneryDct)
			{
				setIndex(dispObj);
			}
			if (flag && this.contains(flag))
				this.setChildIndex(flag,insertInd);
			for each (dispObj in frontSceneryDct)
			{
				setIndex(dispObj);
			}
			for each (dispObj in COIN_STG_DCT)
			{
				setIndex(dispObj);
				COIN_STG_DCT.removeItem(dispObj);
			}
			for each (dispObj in BEHIND_GROUND_STG_DCT)
			{
				setIndex(dispObj);
				BEHIND_GROUND_STG_DCT.removeItem(dispObj);
			}
			for each (dispObj in GROUND_ORDER_STG_DCT)
			{
				setIndex(dispObj);
				GROUND_ORDER_STG_DCT.removeItem(dispObj);
			}
			for each (dispObj in AFTER_GROUND_STG_DCT)
			{
				setIndex(dispObj);
				AFTER_GROUND_STG_DCT.removeItem(dispObj);
			}
			for each (dispObj in PLAT_STG_DCT)
			{
				setIndex(dispObj);
				PLAT_STG_DCT.removeItem(dispObj);
			}
			if ( !contains(tsTxt) )
				addChild(tsTxt);
			setIndex(tsTxt);
			for each (dispObj in AO_BOTTOM_STG_DCT)
			{
				setIndex(dispObj);
				AO_BOTTOM_STG_DCT.removeItem(dispObj);
			}
			for each (dispObj in AO_ORDER_STG_DCT)
			{
				setIndex(dispObj); // this one is causing problems sometimes
				AO_ORDER_STG_DCT.removeItem(dispObj);
			}
			if (playerGraphic && this.contains(playerGraphic))
				setChildIndex(playerGraphic,numChildren-1);
			for each (dispObj in TOP_STG_DCT)
			{
				setChildIndex(dispObj,numChildren-1);
				TOP_STG_DCT.removeItem(dispObj);
			}
			EVENT_MNGR.dispatchEvent( new Event( CustomEvents.LEVEL_SET_INDEXES ) );
			function setIndex(_dispObj:DisplayObject):void
			{
				setChildIndex(_dispObj,insertInd);
				insertInd++;
			}
		}
		public function toggleScreenScroll():void
		{
			if (disableScreenScroll)
				disableScreenScroll = false;
			else
				disableScreenScroll = true;
		}

		public function autoScrollStart():void
		{
			_autoScroll = true;
		}

		public function autoScrollStop(disableScreenScroll:Boolean = false):void
		{
			this.disableScreenScroll = disableScreenScroll;
			_autoScroll = false;
		}
		//scrolls the screen with the player
		public function scrollScreen():void
		{
			if (disableScreenScroll)
				return;
//			x = -scrollRect.x;
			// cgpx == "currentGlobalPlayerX";
			var globalBowserPos:Number;
			var moved:Boolean;
			var lastX:Number = x;
			if (forceShiftScreenToFollowPlayer)
			{
				if (screenScrollsLeft)
					forceShiftScreenToFollowPlayer = false;
				else
					screenScrollsLeft = true;
			}
			lgpx = cgpx;
			cgpx = player.localToGlobal(ZERO_PT).x;
			if ( !isNaN(player.screenScrollPosOffset) )
				cgpx += player.screenScrollPosOffset;
			if (player.hTop > GLOB_STG_BOT && player.dead)
				return;
			if (!keepPlayerOnRight)
			{
				if (!bowser || (bowser && !bowser.onScreen) )
				{
					if (!playerUncentered)
					{
						if ( isNaN(rightScrollPosOvRd) )
							rightScrollPos = DEFAULT_RIGHT_SCROLL_POS;
						else
							rightScrollPos = rightScrollPosOvRd;
						if ( isNaN(leftScrollPosOvRd) )
							leftScrollPos = DEFAULT_LEFT_SCROLL_POS;
						else
							leftScrollPos = leftScrollPosOvRd;
					}
					else
					{
						if (cgpx < DEFAULT_LEFT_SCROLL_POS)
							leftScrollPos += SCROLL_SPEED_BEAT_DUNGEON*dt;
						else
						{
							leftScrollPos = DEFAULT_LEFT_SCROLL_POS;
							rightScrollPos = DEFAULT_RIGHT_SCROLL_POS;
							playerUncentered = false;
						}
					}
				}
				else if (bowser.onScreen && GS_MNGR.gameState == GS_PLAY)
				{
					var curMusicType:String = SND_MNGR.curMusicType;
					if (curMusicType != MusicType.BOSS && curMusicType != MusicType.FINAL_BOSS)
					{
						if (worldNum == 8 || worldNum == 13)
							SND_MNGR.changeMusic( MusicType.FINAL_BOSS );
						else
							SND_MNGR.changeMusic( MusicType.BOSS );
					}
					if (screenScrollsLeft)
					{
						rightScrollPos = SCREEN_WIDTH - BOWSER_AXE_SCREEN_SCROLL_OFFSET;
						leftScrollPos = SCREEN_WIDTH*.1;
						if (cgpx > leftScrollPos)
						{
							this.x -= SCROLL_SPEED_BEAT_DUNGEON*dt;
							//background.moveBg(SCROLL_SPEED_BEAT_DUNGEON*dt);
							moved = true;
							if (Math.abs(x) > screenMaxRightScroll)
							{
								x = -screenMaxRightScroll;
								//background.moveBg(screenMaxRightScroll,0,true);
								moveAmt = 0;
							}
							cgpx = player.localToGlobal(ZERO_PT).x;
						}
						playerUncentered = true;
					}
					//else // if (cgpx <= leftScrollPos)
					//{

					//}
				}
			}
			else // if (keepPlayerOnRight)
			{
				if (player.touchedExit && player.vx == 0)
				{
					rightScrollPos -= SCROLL_SPEED_BEAT_DUNGEON*dt;
					leftScrollPos = DEFAULT_LEFT_SCROLL_POS;
					if (rightScrollPos < leftScrollPos)
					{
						rightScrollPos = DEFAULT_RIGHT_SCROLL_POS;
						keepPlayerOnRight = false;
						SCRN_MNGR.displayThankYouText();
						LOOP_TMR.stop();
					}
				}
				else
				{
					rightScrollPos = GLOB_STG_RHT - player.hWidth/2 - BOWSER_AXE_SCREEN_SCROLL_OFFSET;
					leftScrollPos = DEFAULT_LEFT_SCROLL_POS;
				}
			}
			if (!screenScrollsLeft && !forceScreenScrollLeft)
				rightScrollPos = DEFAULT_RIGHT_SCROLL_POS_NO_LEFT_SCROLL;
			if (!bowserAxe)
				screenMaxRightScroll = mapWidth - SCREEN_WIDTH;
			else
				screenMaxRightScroll = bowserAxe.x + bowserAxe.width/2 + BOWSER_AXE_SCREEN_SCROLL_OFFSET - SCREEN_WIDTH;
			var moveAmt:Number;
			if (cgpx > rightScrollPos)
			{
				moveAmt = cgpx-rightScrollPos
				this.x -= moveAmt;
				//background.moveBg(moveAmt);
				moved = true;
			}
			else if (cgpx < leftScrollPos && (screenScrollsLeft || forceScreenScrollLeft ) )
			{
				moveAmt = cgpx-leftScrollPos;
				this.x -= moveAmt;
				//background.moveBg(moveAmt);
				moved = true;
			}
			if (autoScroll)
			{
				x = lastX;
				var num:Number = SCROLL_SPEED_AUTO*dt;
				x -= num;
				x = Math.floor(x);
				player.x += num;
				player.x = Math.ceil(player.x);
				moved = true;
//				x = 0;
//				var numBefore:Number = num;
//				var playerX:Number = player.x;
//				num = correctFloatingPointError(num,3);
//				var pnt:Point = localToGlobal( new Point(player.x,player.y) );
//				var rectan:Rectangle = new Rectangle(scrollRect.x + num,0,GLOB_STG_RHT,GLOB_STG_BOT);
//				scrollRect = rectan;
//				var stgLftDif:Number = player.x - locStgLft;

//				var numStr:String = num.toPrecision(2);
//				num = Number(numStr);
//				trace("numStr: "+numStr+" numBefore: "+numBefore+" numAfter: "+num);
//				calcLocStgPos();
//				player.x = locStgLft + stgLftDif;
//				player.x.to
//				var newStgLftDif:Number = player.x - locStgLft;
//				trace("stgLftDif: "+stgLftDif+" newStgLftDif: "+newStgLftDif+" player.x: "+player.x);
//				num = 1.2;
//				x = (x*100) - (num*100);
//				x /= 100;
//				var lastPlayX:Number = player.x;
//				player.x = globalToLocal(pnt).x;
//				player.x += num;
//				player.x = (player.x*100) + (num*100);
//				player.x /= 100;
//				trace("player.x: "+player.x+" lastPlayX: "+lastPlayX+" dif: "+(player.x - lastPlayX) );
//				x = correctFloatingPointError(x,1);
//				player.x = correctFloatingPointError(player.x,1);
//				trace("num: "+num+" x: "+x+" player.x: "+player.x +" dif: "+(x - player.x) );
			}
			if (moved)
			{
//				if (x > lastX)
//					x = Math.floor(x);
//				else if (x < lastX)
//					x = Math.ceil(x);
				if (x < -screenMaxRightScroll)
				{
					x = -screenMaxRightScroll;
					//background.moveBg(screenMaxRightScroll,0,true);
					moveAmt = 0;
					if (autoScroll)
						autoScrollStop(true);
				}
				else if (this.x > 0)
				{
					this.x = 0;
					//background.moveBg(0,0,true);
					moveAmt = 0;
				}
				//if (moveAmt != 0)
				//	moveScorePops();
			}
			if (forceShiftScreenToFollowPlayer)
			{
				forceShiftScreenToFollowPlayer = false;
				screenScrollsLeft = false;
				scrollScreen();
			}
			/*if (!disableScreenScroll && x < -5088)
			{
				x = -5088;
				toggleScreenScroll();
			}*/
			background.scroll();
			foreground.scroll();
			tsTxt.scroll();
			/*function moveScorePops():void
			{
				var spLen:int = scorePopVec.length;
				if (spLen) for (var i:int = 0; i < spLen; i++)
				{
					var sp:ScorePop = scorePopVec[i];
					sp.x += moveAmt;
					sp.nx = sp.x;
				}
			}*/
//			trace("scrollRect.x: "+scrollRect.x+" x: "+x);
//			scrollRect = new Rectangle(-x,0,GLOB_STG_RHT,GLOB_STG_BOT);
//			x = 0;
		}
		protected function getPreciseCoordinates(num:Number):Number
		{
			var str:String = num.toString();
			var ind:int = str.indexOf(".");
			if (ind < 0)
				return num;
			str = str.substr();
			if (str.length <= 3)
				return num;
			return correctFloatingPointError(num);
		}
		protected function correctFloatingPointError(number:Number, precision:int = 5):Number
		{
			//default returns (10000 * number) / 10000
			//should correct very small floating point errors
			var correction:Number = Math.pow(10, precision);
			return Math.round(correction * number) / correction;
		}
		public function forceScreenScrollLeftFunction():void
		{
			forceScreenScrollLeft = true;
			rightScrollPos = DEFAULT_RIGHT_SCROLL_POS;
		}
		public function changeScreenScrollsLeftSetting():void
		{
			screenScrollsLeft = !Cheats.classicScreenScroll;
			if (screenScrollsLeft)
				rightScrollPos = DEFAULT_RIGHT_SCROLL_POS;
			else
				rightScrollPos = DEFAULT_RIGHT_SCROLL_POS_NO_LEFT_SCROLL;
			checkAllObjectsOnScreen = true;
		}
		// CHANGECHAR
		public function changeChar(char:Class):void
		{
			var playerNX:Number = player.nx;
			var playerNY:Number = player.ny;
			var playerVX:Number = player.vx;
			var playerVY:Number = player.vy;
			var playerScaleX:Number = player.scaleX;
			var playerP:int = player.pState;
			var playerUpBtn:Boolean = player.upBtn;
			var playerDownBtn:Boolean = player.dwnBtn;
			var playerLeftBtn:Boolean = player.lftBtn;
			var playerRightBtn:Boolean = player.rhtBtn;
			var playerLastOnGround:Boolean = player.lastOnGround;
			var playerOnGround:Boolean = player.onGround;
			player.cleanUp();
			AO_DCT.removeItem(player);
			if (player.parent)
				player.parent.removeChild(player);
			player = null;
			player = new char();
//			if (player.pState != 1)
//				player.resetColor();
			var i:int;
			AO_DCT.addItem(player);
			LevObj.updPlayerRef(player);
			STAT_MNGR.curCharNum = player.charNum;
//			trace("charNum: "+player.charNum);
			player.x = playerNX;
			player.y = playerNY;
//			if (GS_MNGR.gameState == GS_PLAY && !(this is CharacterSelect) )
//				player.pState = playerP;
//			else
//				player.pState = STAT_MNGR.pStateVec[player.charNum];
			player.initiate();
			player.vx = playerVX;
			player.vy = playerVY;
			player.scaleX = playerScaleX;
			player.upBtn = playerUpBtn;
			player.dwnBtn = playerDownBtn;
			player.lftBtn = playerLeftBtn;
			player.rhtBtn = playerRightBtn;
			if (player is Sophia)
			{
				var sophia:Sophia = player as Sophia;
				if (playerRightBtn)
					sophia.pressRhtBtn();
			}
			player.onGround = playerOnGround;
			player.lastOnGround = playerLastOnGround;
//			player.setCurrentBmdSkin(STAT_MNGR.getCurrentBmc());
//			if (!char.recolorsCharSkin)
//				GraphicsManager.INSTANCE.prepareRecolor(player.currentBmdSkin);
			addChild(player);
			EVENT_MNGR.getLevelVars();
			if (GS_MNGR.gameState == GS_PLAY)
				SND_MNGR.changeMusic();
			tsTxt.updNameDispTxt();
			tsTxt.updateUpgIcons();
			if (GS_MNGR.gameState == GS_PLAY)
				BTN_MNGR.sendPlayerBtns();
			player.changedToThisChar();
		}
		public function destroy(mc:DisplayObject):void
		{
			if (mc is LevObj)
			{
				LevObj(mc).destroyed = true;
				mc.visible = false;
			}
			DESTROY_DCT.addItem(mc);
		}
		// ADDOBJ
		public function addObj():void
		{
			for each (var mc:DisplayObject in ADD_DCT)
			{
				if (mc is AnimatedObject)
				{
					if (mc is Projectile)
					{
						if ( (mc as Projectile).sourceType == Projectile.SOURCE_TYPE_PLAYER)
							PLAYER_PROJ_DCT.addItem(mc);
						else
							PROJ_DCT.addItem(mc);
					}
					else if (mc is Teleporter)
					{
						if (teleVec)
							teleVec.push(mc);
						else
						{
							teleVec = new Vector.<Teleporter>;
							teleVec.push(mc);
						}
					}
					AO_DCT.addItem(mc);
				}
				else if (mc is SimpleAnimatedObject)
				{
					var sao:SimpleAnimatedObject = mc as SimpleAnimatedObject;
					if (!sao.stopAnim)
						ANIM_DCT.addItem(sao);
					if (!sao.stopUpdate)
						UPDATE_DCT.addItem(sao);
				}
				else if (mc is Scenery)
					SCENERY_DCT.addItem(mc);
				else if (mc is Ground)
				{
					GROUND_DCT.addItem(mc);
					if (mc is BowserBridge)
					{
						if (!bbVec)
							bbVec = new Vector.<BowserBridge>();
						bbVec.push(mc);
					}
					else if (mc is SpringRed)
					{
						var dg:DummyGround = new DummyGround();
						dg.x = mc.x;
						dg.y = mc.y - TILE_SIZE;
						GROUND_DCT.addItem(dg);
						dg.initiate();
					}
					else if (mc is Brick)
						Brick(mc).flag();
					else if (mc is Platform)
					{
						if (platVec)
							platVec.push(mc);
						else
						{
							platVec = new Vector.<Platform>;
							platVec.push(mc);
						}
					}
				}

				if (mc is LevObj)
					LevObj(mc).initiate();
				ADD_DCT.removeItem(mc);
			}
		}
		private function destroyObj():void
		{
			for each (var mc:DisplayObject in DESTROY_DCT)
			{
				if (mc.parent == this)
					removeChild(mc);
				if (mc is Scenery)
					Scenery(mc).cleanUp();
				if (mc is LevObj)
					LevObj(mc).cleanUp();
				DESTROY_DCT.removeItem(mc);
				mc = null;
			}
		}
		public function killAllEnemiesOnScreen():void
		{
			for each (var ao:AnimatedObject in AO_STG_DCT)
			{
				if (ao is Enemy)
				{
					var enemy:Enemy = ao as Enemy;
					if (enemy.cState == LevObj.ST_DIE)
						continue;
					scorePop(enemy.scoreStar,enemy.nx,enemy.hTop - Enemy.SP_Y_OFFSET);
					enemy.die();
				}
			}
		}
		public function destroyAllEnemiesAndProjectilesOnScreen():void
		{
			for each (var ao:AnimatedObject in AO_STG_DCT)
			{
				if ( (ao is Enemy || ao is Projectile) )
					destroy(ao);
			}
			// destroys enemies at proper time during game loop
		}
		public function forceWaterLevel():void
		{
			waterLevel = true;
			if (player)
				player.forceWaterStats();
		}
		public function forceNonwaterLevel():void
		{
			if (Cheats.waterMode)
				return;
			waterLevel = false;
			if (player)
				player.forceNonwaterStats();
		}
		public function addColorObject(ao:AnimatedObject):void
		{
			CHANGE_COLOR_OBJS_DCT.addItem(ao);
			if ( !STAGE.hasEventListener(ENTER_FRAME_EVENT) )
			STAGE.addEventListener(ENTER_FRAME_EVENT,enterFrameHandler);
		}
		public function removeColorObject(ao:AnimatedObject):void
		{
			CHANGE_COLOR_OBJS_DCT.removeItem(ao);
			if (CHANGE_COLOR_OBJS_DCT.length == 0)
				STAGE.removeEventListener(ENTER_FRAME_EVENT,enterFrameHandler);
		}
		public function pauseGame():void
		{
			LOOP_TMR.stop();
			pauseAnimationTimers();
			GS_MNGR.gameState = GameStates.PAUSE;
			player.setPauseBtns();
			pauseTimers();
			/*var o:* = getSamples();
			for each (var s:Sample in o)
			{
				trace(s.time,s.stack);
			}
			clearSamples();*/
		}
		public function resumeGame():void
		{
			LOOP_TMR.start();
			resumeAnimationTimers();
			GS_MNGR.gameState = GS_PLAY;
			offsetDT = true;
			unpauseTimers();
			BTN_MNGR.sendPlayerBtns();
			player.relPauseBtns();
			//startSampling();
		}
		public function freezeGame(pauseLoopingSounds:Boolean = false):void
		{
			GS_MNGR.gameState = "freeze";
			LOOP_TMR.stop();
			player.setPauseBtns();
			pauseTimers();
			if (pauseLoopingSounds)
				SND_MNGR.pauseLoopingsSfx();
			_moveDuringFreezeTmr.start(); // for score pops
		}
		public function unfreezeGame():void
		{
			GS_MNGR.lockGameState = false;
			GS_MNGR.gameState = GameStates.PLAY;
			LOOP_TMR.start();
			SND_MNGR.resumeLoopingSfx();
			BTN_MNGR.sendPlayerBtns();
			player.relPauseBtns();
			offsetDT = true;
			unpauseTimers();
			_moveDuringFreezeTmr.reset(); // for score pops
		}
		public function freezeGameDeath(source:LevObj = null):void
		{
			BTN_MNGR.relPlyrBtns();
			pauseTimers();
			for each (var ao:AnimatedObject in AO_STG_DCT)
			{
				if (ao != player && ao is Enemy)
				{
					ao.stopAnim = true;
					ao.stopHit = true;
					ao.stopUpdate = true;
				}
			}
			if (platVec)
			{
				var n:int = platVec.length;
				for (var i:int = 0; i < n; i++)
				{
					var plat:Platform = platVec[i];
					plat.stopAnim = true;
					plat.stopHit = true;
					plat.stopUpdate = true;
				}
			}
			player.initiateDeath(source);
		}
		public function freezePlayer():void
		{
			GS_MNGR.gameState = "freezePlayer";
			player.stopAnim = true;
			player.stopHit = true;
			player.stopUpdate = true;
		}
		public function unfreezePlayer():void
		{
			GS_MNGR.lockGameState = false;
			GS_MNGR.gameState = GameStates.PLAY;
			player.stopAnim = false;
			player.stopHit = false;
			player.stopUpdate = false;
		}
		private function moveDuringFreezeTmrHandeler(e:TimerEvent):void
		{
			dt = TD_CALC.getTD()
			if (foreground.SCORE_POP_DCT.length)
				foreground.updateScorePops();
			/*var spLen:int = scorePopVec.length;
			if (spLen) for (var i:int = 0; i < spLen; i++)
			{
				var sp:ScorePop = scorePopVec[i];
				sp.updateObj();
				sp.drawObj();
			}*/
		}
		public function get moveDuringFreezeTmr():CustomTimer
		{
			return _moveDuringFreezeTmr;
		}
		public function getLevel():Level
		{
			return this;
		}
		private function pauseTimers():void
		{
			for each (var t:ICustomTimer in TMR_DCT)
			{
				if (t.running)
				{
					t.pause();
					P_TMR_DCT.addItem(t);
				}
			}
		}

		private function unpauseTimers():void
		{
			for each (var t:ICustomTimer in P_TMR_DCT)
			{
				t.resume();
				P_TMR_DCT.removeItem(t);
			}
		}
		public function addTmr(t:ICustomTimer):void
		{
			TMR_DCT.addItem(t);
		}
		public function removeTmr(t:ICustomTimer):void
		{
			if (t.running)
				t.stop();
			TMR_DCT.removeItem(t);
			P_TMR_DCT.removeItem(t);

		}
		/*public function addVec(v:Vector.<*>):void
		{
			if (vecsVec)
			{
				if (vecsVec.indexOf(v) != -1) vecsVec.push(v);
			}
			else
			{
				vecsVec = new Vector.<Vector>;
				vecsVec.push(v);
			}
		}*/
		public function getDistance(x1:Number,y1:Number,x2:Number,y2:Number):Number
		{
			var dx:Number = x1 - x2;
			var dy:Number = y1 - y2;
			return Math.sqrt(dx * dx + dy * dy);
		}
		// loads an area in the current level
		public function loadArea(newArea:String,_pExInt:int):void
		{
			//trace("newArea: "+newArea+" pExInt: "+_pExInt);
			if (newArea == "0")
				newArea = _areaStr;
			// removes player and destroyable objects
			AO_DCT.removeItem(player);
			destroy(player);
			for each (var ao:AnimatedObject in AO_DCT)
			{
				if (ao.destroyOffScreen
				|| (ao is Projectile && !(ao is FireBar || ao is LavaFireBall) )
				|| ao.dosTop || ao.dosLft ||ao.dosRht
				|| ao is Lakitu
				|| (ao is CheepFast && CheepFast(ao).flying) )
					destroy(ao);
			}
			if (ENEMY_SPAWNER_DCT.length)
			{
				for each (var es:EnemySpawner in ENEMY_SPAWNER_DCT)
				{
					es.disarm();
				}
			}
			destroyObj();
			areaStatsArr = [_areaStr,AO_DCT,GROUND_DCT,SCENERY_DCT,hwPnt,ENEMY_SPAWNER_DCT, bfbX];
			disarm = true;
			STAT_MNGR.writePlayerStats(player.charNum,player.pState,_pExInt);
			destroyLevel();
//			var levSubLevStr:String = _fullLevStr.substr(0,3);
			//trace("about to load level levSubLevStr: "+levSubLevStr);
			SCRN_MNGR.loadNewArea(_id.nameWithoutArea,_areaStr,newArea,areaStatsArr);
		}
		public function getGroundAt(_x:Number,_y:Number):Ground
		{
			return GROUND_DCT.getGroundAt(_x,_y);
		}

		public function getSceneryAt(_x:Number,_y:Number):CustomDictionary
		{
			return SCENERY_DCT.getSceneryAt(_x,_y);
		}

		private function loadNewLevel(levelID:LevelID):void
		{
//			try
//			{
//				if (newLevel.length < 3)
//					throw new StringError("invalid new level length");
//			}
//			catch(e:StringError)
//			{
//				return;
//			}
			destroyLevel();
			STAT_MNGR.writePlayerStats(player.charNum,player.pState,0);
			SCRN_MNGR.loadNewLevel(levelID);
		}
		public function reloadLevel():void
		{
			var lev:String = _worldNum+"-"+_levNum;
			var firstArea:LevelID = LevelID.Create(_id.nameWithoutArea);
			if (shouldStartAtCheckPoint)
				levelIDToLoad = LevelID.Create(_id.nameWithoutArea + _hwArea);
			else
			{
				if (levData.getType(firstArea) == LevelTypes.INTRO)
					levelIDToLoad = LevelID.Create(_id.nameWithoutArea + "b");
				else
					levelIDToLoad = firstArea;
			}
			if (!LOOP_TMR.running)
				loadNewLevel(levelIDToLoad);
		}
		public function set beatLevel(val:Boolean):void
		{
			_beatLevel = val;
		}
//		public function get fullLevStr():String
//		{
//			return _fullLevStr;
//		}

		public function resetTeleporters():void
		{
			for each (var teleporter:Teleporter in teleVec)
				teleporter.resetCheckPoints();
		}
		protected function completeLevel():void
		{
			if ( Cheats.getLockStatus(MenuBoxItems.INFINITE_TIME) )
			{
				Cheats.unlockCheat(MenuBoxItems.INFINITE_TIME);
				if (GameSettings.cheatNotify)
				{
					MessageBoxManager.INSTANCE.addEventListener(CustomEvents.MESSAGE_BOX_SERIES_END,messageBoxSeriesEndHandler,false,0,true);
					return;
				}
			}
			if ( Cheats.getLockStatus(MenuBoxItems.EXTRA_CHECKPOINTS) && _levNum == 4 )
			{
				Cheats.unlockCheat(MenuBoxItems.EXTRA_CHECKPOINTS);
				if (GameSettings.cheatNotify)
				{
					MessageBoxManager.INSTANCE.addEventListener(CustomEvents.MESSAGE_BOX_SERIES_END,messageBoxSeriesEndHandler,false,0,true);
					return;
				}
			}
			var newSubLevNum:int = _levNum + 1;
			var newLevNum:int;
			if (newSubLevNum <= 4)
				newLevNum = _worldNum;
			else
			{
				newLevNum = _worldNum + 1;
				newSubLevNum = 1;
			}
//			var newLevStr:String = String(newLevNum+"-"+newSubLevNum);
//			if (newLevStr == CharacterSelect.FULL_LEVEL_STR)
//				newLevStr = GameSettings.FIRST_LEVEL;
			STAT_MNGR.passedHw = false;
			EVENT_MNGR.beatLevel(_worldNum,_levNum);
			loadNewLevel( new LevelID(newLevNum, newSubLevNum) );
		}
		private function messageBoxSeriesEndHandler(event:Event):void
		{
			MessageBoxManager.INSTANCE.removeEventListener(CustomEvents.MESSAGE_BOX_SERIES_END,messageBoxSeriesEndHandler);
			completeLevel();
		}
		public function launchNextFirework():void
		{
			if (fwPosArr.length)
			{
				var xPos:int;
				var yPos:int;
				xPos = fwPosArr[0][0] + castleFlag.x;
				yPos = fwPosArr[0][1] + fireworkPivotY;
				if (levNum == 3)
					xPos += TILE_SIZE;
				fwPosArr.shift();
				addToLevel(new Firework(xPos,yPos));
			}
			else
			{
				winEndTmr = new CustomTimer(WIN_END_TMR_FIREWORKS_DUR,1);
				winEndTmr.addEventListener(TimerEvent.TIMER_COMPLETE,winEndTmrLsr,false,0,true);
				winEndTmr.start();
			}
		}

		private function get bigCastleIsOnScreen():Boolean
		{
			for each (var scenery:Scenery in SCENERY_STG_DCT)
			{
				if (scenery.currentLabel == Scenery.FL_CASTLE_BIG)
					return true;
			}
			return false;
		}

		public function raiseFlag():void
		{
			if (castleFlag != null && !bigCastleIsOnScreen)
			{
				addChildAt(castleFlag,1);
				raiseCastleFlag = true;
			}
			if (fireworksRemaining)
			{
				if (fireworksRemaining == 6)
					fwPosArr = FireworkLocations.FW_6_ARR.concat();
				else if (fireworksRemaining == 3)
					fwPosArr = FireworkLocations.FW_3_ARR.concat();
				else if (fireworksRemaining == 1)
					fwPosArr = FireworkLocations.FW_1_ARR.concat();
				launchNextFirework();
			}
			else
			{
				winEndTmr = new CustomTimer(WIN_END_TMR_NORMAL_DUR,1);
				winEndTmr.addEventListener(TimerEvent.TIMER_COMPLETE,winEndTmrLsr,false,0,true);
				winEndTmr.start();
			}
		}
		private function funTime():Boolean
		{
//			return true;
			//*
			var url:String = STAGE.loaderInfo.url;
			var testDct:Dictionary = new Dictionary();
			testDct["file://"] = "file://";
			//testDct["http://localhost/"] = "http://localhost/";
			testDct["http://localhost:8888/"] = "http://localhost:8888/";
			//testDct["http://supermariobroscrossover.com/"] = "http://supermariobroscrossover.com/";
			testDct["http://www.explodingrabbit.com/"] = "http://www.explodingrabbit.com/";
			testDct["http://127.0.0.1:8888/"] = "http://127.0.0.1:8888/";
			for each (var str:String in testDct)
			{
				if ( str == url.substr(0,str.length) )
					return true;
			}
			return false;
			//*/
			//return true;
		}
		public function startDungeonEndTmr():void
		{
			winEndTmr = new CustomTimer(WIN_END_TMR_DUNGEON_DUR,1);
			winEndTmr.addEventListener(TimerEvent.TIMER_COMPLETE,winEndTmrLsr,false,0,true);
			winEndTmr.start();
		}
		// called when music starts playing
		public function startBackupTouchLevelExitTmr():void
		{
			backupTouchLevelExitTmr = new Timer(BACKUP_TOUCH_LEVEL_EXIT_TMR_DEL,1);
			backupTouchLevelExitTmr.addEventListener(TimerEvent.TIMER_COMPLETE,backupTouchLevelExitTmrHandler,false,0,true);
			backupTouchLevelExitTmr.start();
		}
		private function backupTouchLevelExitTmrHandler(event:TimerEvent):void
		{
			if (player)
				player.touchLevelExit();
			backupTouchLevelExitTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,backupTouchLevelExitTmrHandler);
			backupTouchLevelExitTmr = null;
		}
		public function startWinEndTmrMusic(winSongDur:int):void
		{
			winEndTmrMusic = new CustomTimer(winSongDur + WIN_MUSIC_TAIL,1);
			winEndTmrMusic.addEventListener(TimerEvent.TIMER_COMPLETE,winEndTmrMusicHandler,false,0,true);
			winEndTmrMusic.start();
		}
		private function winEndTmrMusicHandler(e:TimerEvent):void
		{
			winEndTmrMusic.stop();
			winEndTmrMusic.removeEventListener(TimerEvent.TIMER_COMPLETE,winEndTmrMusicHandler);
			winEndTmrMusic = null;
			if (!winEndTmrComplete)
				return;
			_beatLevel = true;
			if (!LOOP_TMR.running)
				completeLevel();
		}
		private function winEndTmrLsr(e:TimerEvent):void
		{
			winEndTmr.stop();
			winEndTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,winEndTmrLsr);
			winEndTmr = null;
			winEndTmrComplete = true;
			if (winEndTmrMusic != null)
				return;
			_beatLevel = true;
			if (!LOOP_TMR.running)
				completeLevel();
		}
		private function pauseAnimationTimers():void
		{
			for each (var ct:CustomTimer in ALL_ANIM_TMRS_DCT)
			{
				ct.pause();
			}
		}
		private function resumeAnimationTimers():void
		{
			for each (var ct:CustomTimer in ALL_ANIM_TMRS_DCT)
			{
				ct.resume();
			}
		}
		public function destroyLevel():void
		{
			var i:int;
			//GS_MNGR.gameState = GameStates.CLEAN_UP;
			if (disarm) // disarms AnimatedObjects and Ground
			{
				for each (var ao:AnimatedObject in AO_DCT)
				{
					ao.disarm();
				}
				for each (var g:Ground in GROUND_DCT)
				{
					g.disarm();
				}
			}
			else
			{
				for each (ao in AO_DCT)
				{
					destroy(ao);
				}
				for each (g in GROUND_DCT)
				{
					destroy(g);
				}
				for each (var s:Scenery in SCENERY_DCT)
				{
					destroy(s);
				}
			}
			Brick.masterBrick.destroy();
			ItemBlock.masterItemBlock.destroy();
			// destroy timers
			LOOP_TMR.stop();
			for each (var ct:CustomTimer in ALL_ANIM_TMRS_DCT)
			{
				ct.stop();
			}
			for each (var glt:GameLoopTimer in GAME_LOOP_TMRS_DCT)
			{
				glt.stop();
				glt.destroy();
			}
			LOOP_TMR.removeEventListener(TimerEvent.TIMER, gameLoop);
			ANIM_TMR_FLASHING_ITEM.removeEventListener(TimerEvent.TIMER,animTmrFlashingItemHandler);
			ANIM_SUPER_SLOWEST_TMR.removeEventListener(TimerEvent.TIMER,animSuperSlowestTmrHandler);
			ANIM_VERY_SLOW_TMR.removeEventListener(TimerEvent.TIMER, animVerySlowTmrHandler);
			ANIM_SLOW_TMR.removeEventListener(TimerEvent.TIMER, animSlowTmrHandler);
			ANIM_MODERATE_TMR.removeEventListener(TimerEvent.TIMER, animModerateTmrHandler);
			ANIM_MIN_FAST_TMR.removeEventListener(TimerEvent.TIMER, animMinFastTmrHandler);
			ANIM_FAST_TMR.removeEventListener(TimerEvent.TIMER, animFastTmrHandler);
			if (_moveDuringFreezeTmr)
			{
				_moveDuringFreezeTmr.stop();
				_moveDuringFreezeTmr.removeEventListener(TimerEvent.TIMER,moveDuringFreezeTmrHandeler);
				_moveDuringFreezeTmr = null;
			}
			if (backupTouchLevelExitTmr)
				backupTouchLevelExitTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,backupTouchLevelExitTmrHandler);
			// remove event listeners
			STAGE.removeEventListener(Event.RENDER, renderLsr); // for animation
			STAGE.removeEventListener(ENTER_FRAME_EVENT,enterFrameHandler);
			if (STAGE.hasEventListener(MouseEvent.CLICK) )
				removeEventListener(MouseEvent.CLICK,clickLsr);
			destroyObj();
			background.destroy();
			foreground.destroy();
			levelInstance = null;
			GlobVars.level = null;
			tsTxt.level = null;
			if (GAME.contains(this))
				GAME.removeChild(this);
			removeAllSounds();
			EVENT_MNGR.destroyLevel();
		}
		protected function removeAllSounds():void
		{
			SND_MNGR.removeAllSounds();
		}
		public function pauseMainTmrs():void
		{
			LOOP_TMR.stop();
			ANIM_SLOW_TMR.stop();
		}
		public function resumeMainTmrs():void
		{
			LOOP_TMR.start();
			ANIM_SLOW_TMR.start();
		}
		public function scorePop(points:uint,_x:Number,_y:Number,addToScore:Boolean = true,slow:Boolean = false):void
		{
			var sp:ScorePop = new ScorePop(points,_x,_y,slow);
			addToLevel(sp);
			if (addToScore)
			{
				if (points != SV_EARN_NEW_LIFE_NUM_VAL)
					EVENT_MNGR.addPoints(points);
				else
					STAT_MNGR.addLife();
			}
		}
		public function get hwArea():String
		{
			return _hwArea;
		}
		public function get timeLeftTot():uint
		{
			return _timeLeftTot;
		}
		public function get newLev():Boolean
		{
			return _newLev;
		}
		public function get flagPole():FlagPole
		{
			return _flagPole;
		}
		public function get worldNum():int
		{
			return _worldNum;
		}
		public function get levNum():int
		{
			return _levNum;
		}
		public function get areaStr():String
		{
			return _areaStr;
		}
		public function get initialWaterLevel():Boolean
		{
			return _initialWaterLevel;
		}

		public function get type():String
		{
			return _type;
		}

		public function get id():LevelID
		{
			return _id;
		}

		private function groundHT(ao:AnimatedObject):void
		{
			//var gVec:Vector.<Ground> = GROUND_DCT.GROUND_VEC;
			//sortedGroundVec
			var j:int;
			var curRowPos:int = TILE_SIZE;
			var g:Ground;
			var dct:Dictionary = groundRowDcts[GROUND_STG_DCT.OFF_GRID_KEY];
			var aoTypes:CustomDictionary = ao.hitTestTypesDct;
			var aoTa:CustomDictionary = ao.hitTestAgainstGroundDct;
			var match:Boolean = false;
			var aoType:String;
			var gType:String;
			var gTypes:CustomDictionary
			var gTa:CustomDictionary
			// the ground test info is copied twice just to avoid calling a function twice
			for each (g in dct)
			{
				if (g.stopHit || ao.stopHit)
					continue;
				gTypes = g.hitTestTypesDct;
				gTa = g.hitTestAgainstNonGroundDct;
				match = false;
				loopToBreak: for each (aoType in aoTypes)
				{
					for each (gType in gTypes)
					{
						if ( aoTa[gType] && gTa[aoType] )
						{
							match = true;
							break loopToBreak;
						}
					}
				}
				if (!match)
					continue;
				if (g.hitDistOver)
					checkMaxDistOver(ao,g);
				if (getDistance(ao.hMidX,ao.hMidY,g.hMidX,g.hMidY) > maxDist)
					continue;
				ht.hTest(ao,g);
			}

			for (var i:int; i < groundRowDctsLen; i++)
			{
				dct = groundRowDcts[curRowPos];
				// begin copied code
				for each (g in dct)
				{
					if (g.stopHit || ao.stopHit)
						continue;
					gTypes = g.hitTestTypesDct;
					gTa = g.hitTestAgainstNonGroundDct;
					match = false;
					newLoopToBreak: for each (aoType in aoTypes)
					{
						for each (gType in gTypes)
						{
							if ( aoTa[gType] && gTa[aoType] )
							{
								match = true;
								break newLoopToBreak;
							}
						}
					}
					if (!match)
						continue;
					if (g.hitDistOver)
						checkMaxDistOver(ao,g);
					if (getDistance(ao.hMidX,ao.hMidY,g.hMidX,g.hMidY) > maxDist)
						continue;
					ht.hTest(ao,g);
				}
				curRowPos += TILE_SIZE;
			}
			if (projHitArr)
			{
				var n:int = projHitArr.length;
				for (i = 0; i < n; i++)
				{
					if (!projHitArr) // no idea why I need this
						continue;
					var hitObj:LevObj = LevObj(projHitArr[i][0]);
					var proj:Projectile = Projectile(projHitArr[i][1]);
					if (!proj.destroyed && !proj.stopHit && !hitObj.destroyed && !hitObj.stopHit
						&& (!(hitObj is Ground) || !Ground(hitObj).disabled) )
						hitObj.confirmedHitProj(proj);
				}
				projHitArr = null;
			}
			if (gHitArr.length > 0) for (j = 0; j < gHitArr.length; j++)
			{
				ht.hTest(ao,gHitArr[j]);
				gHitArr.shift();
				j--;
			}
		}

	}
}
