package com.smbc.managers
{
	import com.explodingRabbit.cross.data.ConsoleType;
	import com.explodingRabbit.utils.CustomDictionary;
	import com.explodingRabbit.utils.CustomTimer;
	import com.explodingRabbit.utils.Enum;
	import com.smbc.characters.Bass;
	import com.smbc.characters.Bill;
	import com.smbc.characters.Character;
	import com.smbc.characters.Link;
	import com.smbc.characters.Luigi;
	import com.smbc.characters.Mario;
	import com.smbc.characters.MegaMan;
	import com.smbc.characters.Pit;
	import com.smbc.characters.Ryu;
	import com.smbc.characters.Samus;
	import com.smbc.characters.Simon;
	import com.smbc.characters.Sophia;
	import com.smbc.characters.VicViper;
	import com.smbc.characters.WarriorOfLight;
	import com.smbc.characters.base.MarioBase;
	import com.smbc.data.CampaignModes;
	import com.smbc.data.CharacterInfo;
	import com.smbc.data.Cheats;
	import com.smbc.data.DamageValue;
	import com.smbc.data.Difficulties;
	import com.smbc.data.GameSettings;
	import com.smbc.data.GameStates;
	import com.smbc.data.LevelID;
	import com.smbc.data.MapPack;
	import com.smbc.data.MusicQuality;
	import com.smbc.data.PickupInfo;
	import com.smbc.data.ScoreValue;
	import com.smbc.data.SoundNames;
	import com.smbc.data.Versions;
	import com.smbc.enums.BeatGameStatus;
	import com.smbc.enums.PowerupMode;
	import com.smbc.errors.SingletonError;
	import com.smbc.errors.StringError;
	import com.smbc.events.CustomEvents;
	import com.smbc.graphics.BmdInfo;
	import com.smbc.graphics.BmdSkinCont;
	import com.smbc.graphics.TopScreenText;
	import com.smbc.level.CharacterSelect;
	import com.smbc.level.Level;
	import com.smbc.level.TitleLevel;
	import com.smbc.main.*;
	import com.smbc.messageBoxes.MenuBox;
	import com.smbc.messageBoxes.MenuBoxItems;
	import com.smbc.messageBoxes.MessageBoxMessages;
	import com.smbc.messageBoxes.PlainMessageBox;
	import com.smbc.pickups.FireFlower;
	import com.smbc.pickups.Pickup;
	import com.smbc.sound.GameSecondsLeftIntroOverrideSnd;
	import com.smbc.sound.SoundContainer;

	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;

	public final class StatManager extends MainManager
	{
		private var firstLevel:LevelID;
		public const LAST_WORLD:int = 8;
		private static const LEV_NUM_MIN:int = 1;
		private static const LEV_NUM_MAX:int = 4;
		private static const WORLD_NUM_MIN:int = 1;
		private static const WORLD_NUM_MAX:int = 4;
		private static const NUM_COINS_MIN:int = 0;
		private static const NUM_COINS_MAX:int = 99;
		private static const NUM_LIVES_MIN:int = 1;
		private static const NUM_LIVES_MAX:int = 99;
		private static const P_STATE_MIN:int = 1;
		private static const P_STATE_MAX:int = 3;
		private static const SCORE_MIN:int = 0;
		private static const SCORE_MAX:int = 9999999;
		private static const UNDEFINED_NUM:int = -1;
		public static const NUM_AMMO_PICKUPS_TO_COLLECT:int = 200; // 200
		public static const NUM_CHEEP_CHEEPS_TO_DEFEAT:int = 300; // 300
		public static const NUM_ENEMIES_TO_DEFEAT:int = 1000; // 1000
		public static const NUM_ENEMIES_TO_STOMP:int = 200; // 200
		public static const NUM_BRICKS_TO_BREAK:int = 1000;
		public static const NUM_ARMORED_ENEMIES_TO_DEFEAT:int = 200;
		public static const NUM_HAMMER_BROS_TO_DEFEAT:int = 50; // 50
		private static const STAT_MAX_DEF:int = 999999;
		private static const STAT_MIN_DEF:int = 0;
		public static const MINIMUM_ENABLED_CHARACTER_COUNT:int = 1;

		private var _numCheepCheepsDefeated:int; // name must match in MessageBoxMessages
		private var _numEnemiesDefeated:int; // name must match in MessageBoxMessages
		private var _numHammerBrosDefeated:int; // name must match in MessageBoxMessages
		private var _numEnemiesStomped:int; // name must match in MessageBoxMessages
		private var _numAmmoPickupsCollected:int; // name must match in MessageBoxMessages
		private var _numContinuesUsed:int; // name must match in MessageBoxMessages
		private var _numArmoredEnemiesDefeated:int; // name must match in MessageBoxMessages
		private var _numBricksBroken:int; // name must match in MessageBoxMessages

		public const NUM_LEVS_PER_WORLD:int = 4;
		public static const STAT_MNGR:StatManager = new StatManager();
		private static var instantiated:Boolean;
		private var _numCoins:uint;
		private const NUM_COINS_FOR_NEW_LIFE:uint = 100;
		public const DUNGEON_LEVEL_NUM:int = 4;
		private const DEF_NUM_COINS:int = 0;
		private var _numLives:uint;
		public const NUM_LIVES_GAME_OVER:int = 0; // 0
		private const DEF_NUM_LIVES:int = 3; // 3
		private const DEF_NUM_LIVES_SUPER_EASY:int = 10; // 10
		private const DEF_NUM_LIVES_EASY:int = 5; // 5
		private const DEF_SCORE:int = 0;
		private const PLAYER_DIE_TIME:int = 0; // 0
		public static const DROP_RATE_MOD_VERY_EASY:Number = .15;
		public static const DROP_RATE_MOD_EASY:Number = .075;
		public const SECONDS_LEFT_START_TIME:int = 99; // 99
		private const TIME_MIN:int = 0;
		private var _allowCharacterRevival:Boolean;
		private var _score:int;
		private var _timeLeft:int;
		public var passedHw:Boolean; // set by level in completeLevel();
		private const TIME_LEFT_INT:uint = 397;
		private const EXTRA_TIME_SUPER_EASY:int = 200;
		private const EXTRA_TIME_EASY:int = 100;
		private var tsTxt:TopScreenText;
		private var _plyrStatsArr:Array = []; // [charNum,pState,pExInt]
		private static const PLYR_STATS_IND_CHAR_NUM:int = 0;
		private static const PLYR_STATS_IND_P_STATE:int = 1;
		private static const PLYR_STATS_IND_P_EXIT:int = 2;
		private const MASTER_AVAILABLE_UPGRADES_VEC:Vector.< Vector.<CustomDictionary> > = new Vector.< Vector.<CustomDictionary> >(Character.NUM_CHARACTERS,true);
		private const DEF_AVAILABLE_UPGRADES_VEC:Vector.<CustomDictionary> = new Vector.<CustomDictionary>(Character.NUM_CHARACTERS,true);
		private const DEF_PLYR_STATS_ARR:Array = [0,1,0,false];
		private var DEF_TIER_VEC:Vector.<int> = new Vector.<int>(Character.NUM_CHARACTERS,true);
		private const SUB_WEAPON_VEC:Vector.<String> = new Vector.<String>(Character.NUM_CHARACTERS,true);
		private var DEF_OBTAINED_UPGRADES_VEC:Vector.<CustomDictionary> = new Vector.<CustomDictionary>(Character.NUM_CHARACTERS,true);
		private const availableUpgradesVec:Vector.<CustomDictionary> = new Vector.<CustomDictionary>(Character.NUM_CHARACTERS,true);
		private const obtainedUpgradesVec:Vector.<CustomDictionary> = new Vector.<CustomDictionary>(Character.NUM_CHARACTERS,true);
		public const storedUpgradesVec:Vector.<CustomDictionary> = new Vector.<CustomDictionary>(Character.NUM_CHARACTERS,true);
		public const storedViewedUpgradesVec:Vector.<CustomDictionary> = new Vector.<CustomDictionary>(Character.NUM_CHARACTERS,true);
		private const viewedUpgradesVec:Vector.<CustomDictionary> = new Vector.<CustomDictionary>(Character.NUM_CHARACTERS,true);
		public const storedTierVec:Vector.<int> = new Vector.<int>(Character.NUM_CHARACTERS,true);
		private static const CHAR_SKIN_ORDER_VEC:Vector.< Vector.<int> > = new Vector.< Vector.<int> >(Character.NUM_CHARACTERS,true);
		private const SINGLE_UPGRADES_VEC:Vector.<CustomDictionary> = new Vector.<CustomDictionary>(Character.NUM_CHARACTERS,true);
		private const ICON_ORDER_VEC:Vector.< Vector.<String> > = new Vector.< Vector.<String> >(Character.NUM_CHARACTERS,true);
		private const DEF_AMMO_VEC:Vector.<Array> = new Vector.<Array>(Character.NUM_CHARACTERS,true);
		private const ammoVec:Vector.<Array> = new Vector.<Array>(Character.NUM_CHARACTERS,true);
		private var tierVec:Vector.<int> = new Vector.<int>(Character.NUM_CHARACTERS,true);
		private var _pStateVec:Vector.<int> = new Vector.<int>(Character.NUM_CHARACTERS,true);
		public var skinVec:Vector.<int> = new Vector.<int>(Character.NUM_CHARACTERS,true);
		private var enabledCharactersVec:Vector.<Boolean> = new Vector.<Boolean>(Character.NUM_CHARACTERS, true);
		private var enabledCharacterSkinsVec:Vector.< Vector.<Boolean> > = new Vector.<Vector.<Boolean>>(Character.NUM_CHARACTERS, true);
		private var enabledSkinSetsVec:Vector.<Boolean> = new Vector.<Boolean>(BmdInfo.NUM_SKIN_SETS, true);
		private var DEF_SKIN_VEC:Vector.<int> = new Vector.<int>();
		private var colorVec:Vector.<int> = new Vector.<int>(Character.NUM_CHARACTERS,true);
		private static const DEF_COLOR_VEC:Vector.<int> = new Vector.<int>();
		private static const DEF_P_ST_ARR:Array = [];
		public static const DEF_P_ST_ARR_SURVIVAL:Array = [];
		private var _levStatsVec:Vector.<Array> = new Vector.<Array>();
		private const COIN_PT_VAL:int = ScoreValue.COIN;
		private var _curCharNum:int = GameSettings.DEFAULT_CHARACTER;
		private var _currentLevelID:LevelID;
		private var curWorldNum:int;
		private var curLevNum:int;
		private var _newLev:Boolean = true;
		private var timeScoreConverterTmr:CustomTimer;
		private const TIME_SCORE_CONVERTER_TMR_INT:int = 10;
		public var loadingData:Boolean;
		public static const TIME_PT_VAL:int = ScoreValue.TIME_REMAINING;
		private const IND_SLS_NUM_LIVES:int = 0;
		private const IND_SLS_NUM_COINS:int = 1;
		private const IND_SLS_SCORE:int = 2;
		private const IND_SLS_OBTAINED_UPGRADES_VEC:int = 3;
		private const IND_SLS_AVAILABLE_UPGRADES_VEC:int = 4;
		private const IND_SLS_VIEWED_UPGRADES_VEC:int = 5;
		private const IND_SLS_STORED_UPGRADES_VEC:int = 6;
		private const IND_SLS_STORED_VIEWED_UPGRADES_VEC:int = 7;
		private const IND_SLS_AMMO_VEC:int = 8;
		private const IND_SLS_P_STATE_VEC:int = 9;
		private const SAVE_OFS_LEVEL:int = 327;
		private const SAVE_OFS_STATS:int = 68;
		private const SAVE_OFS_P_STATE:int = 31;
		private const SAVE_OFS_BTNS:int = 77;
		private const SAVE_DATA_STR_DIVIDER:String = ",";
		private var startLevelStats:Array = [];
		private var timeLeftBeatLevel:String;
		private const SAVE_FILE_NAME:String = "smbc_save_data.txt";
		private const SAVE_DATA_PREFIX_STR:String = "<smbc_save_data>";
		private const SAVE_DATA_SUFFIX_STR:String = "</smbc_save_data>";
		private const MAX_LOAD_DATA_STRING_LENGTH:int = 50;
		private var _fileRef:FileReference;
		public var secondsLeft:Boolean;
		public static const SFX_GAME_COIN:String = SoundNames.SFX_GAME_COIN;
		public static const SFX_GAME_NEW_LIFE:String = SoundNames.SFX_GAME_NEW_LIFE;
		public static const SFX_GAME_POINTS:String = SoundNames.SFX_GAME_POINTS;
		private var _showTimeUpScrn:Boolean;
		private var timePassed:Number = 0;
		private var _runTimeLeft:Boolean;
		private var _numSophiaMissiles:int;
		public var sophiaWallGrapple:Boolean;
		public const STAT_NUM_SAMUS_MISSILES:String = "numSamusMissiles";
		public const NUM_SAMUS_MISSILES_MAX:int = 50;
		public const NUM_SAMUS_MISSILES_MIN:int = 0;
		private var _numSamusMissiles:int;
		public const STAT_NUM_SOPHIA_MISSILES:String = "numSophiaMissiles";
		public const NUM_SOPHIA_MISSILES_MAX:int = 20;
		public const NUM_SOPHIA_MISSILES_MIN:int = 0;
//		public var numSophiaHover:int;
//		public const STAT_NUM_SOPHIA_HOVER:String = "numSophiaHover";
//		public const NUM_SOPHIA_HOVER_MAX:int = 8;
//		public const NUM_SOPHIA_HOVER_MIN:int = 0;
		private const CONST_SEP:String = "_";
		private const MAX_STR:String = "_MAX";
		private const MIN_STR:String = "_MIN";
		private static const IND_LOAD_SAVE_ARR_VALUE:int = 0;
		private static const IND_LOAD_SAVE_ARR_NAME:int = 1;
		private static const IND_LOAD_SAVE_ARR_CLASS:int = 2;
		private const LOAD_DATA_REQ_LENGTH:int = 86;
		public var currentWarriorType:String = WarriorOfLight.TYPE_FIGHTER;
		private const beatGameStatusVec:Vector.<BeatGameStatus> = new Vector.<BeatGameStatus>();
		public var pitTransArr:Array;
//		2:36 for 400 on mario
//		that's 156,000 ms
//		156,000 / 400 = 390
		public function StatManager()
		{
			if (instantiated)
				throw new SingletonError();
			instantiated = true;
		}
		override public function initiate():void
		{
			firstLevel = LevelID.Create(GameSettings.FIRST_LEVEL);
			super.initiate();
			setUpDefaultVecs();
			changeDifficulty();
			resetAllStats(true);
			prepareLoadSaveStats();
		}

		private function setUpDefaultVecs():void
		{
			var n:int = CharacterInfo.NUM_CHARACTERS;
			for (var i:int = 0; i < n; i++)
			{
				DEF_SKIN_VEC.push(GameSettings.DEF_CHAR_SKIN_NUM);
				DEF_COLOR_VEC.push(0);
				DEF_P_ST_ARR.push(Character.PS_NORMAL);
				DEF_P_ST_ARR_SURVIVAL.push(Character.PS_FALLEN);
				MASTER_AVAILABLE_UPGRADES_VEC[i] = Character.getAvailableUpgrades(i);
				DEF_AVAILABLE_UPGRADES_VEC[i] = MASTER_AVAILABLE_UPGRADES_VEC[i][0];
				DEF_OBTAINED_UPGRADES_VEC[i] = new CustomDictionary();
				SINGLE_UPGRADES_VEC[i] = Character.getSingleObjVec(i);
				DEF_TIER_VEC[i] = 0;
				ICON_ORDER_VEC[i] = Vector.<String>( CharacterInfo.getCharClassFromNum(i)[Character.ICON_ORDER_ARR_PROP_NAME] );
				SUB_WEAPON_VEC[i] = null;
				DEF_AMMO_VEC[i] = Character.getAmmoVec(i);
				CHAR_SKIN_ORDER_VEC[i] = Character.getSkinOrderVec(i);
				enabledCharactersVec[i] = true;
				enabledCharacterSkinsVec[i] = new Vector.<Boolean>(CHAR_SKIN_ORDER_VEC[i].length, true);
			}
			enableAllSkinsExceptInvisible();

			skinVec = DEF_SKIN_VEC.concat();
			for ( i = 0; i < Enum.GetCount(BeatGameStatus); i++)
				beatGameStatusVec[i] = BeatGameStatus.None;
		}
		public function addCoin():void
		{
			sndMngr.playSound(SFX_GAME_COIN);
			if (gsMngr.gameState == GameStates.CHARACTER_SELECT)
				return;
			_numCoins++;
			if (_numCoins >= NUM_COINS_FOR_NEW_LIFE)
			{
				addLife();
				_numCoins = 0;
			}
			tsTxt.updCoinDispTxt(_numCoins.toString());
			addPoints(COIN_PT_VAL);
		}
		public function resetAllStats(resetLevelToFirstLevel:Boolean = true):void
		{
			if (GameSettings.campaignMode == CampaignModes.SURVIVAL)
				_pStateVec = Vector.<int>(DEF_P_ST_ARR_SURVIVAL).concat();
			else
				_pStateVec = Vector.<int>(DEF_P_ST_ARR).concat();
			var n:int = CharacterInfo.NUM_CHARACTERS;
			for (var i:int = 0; i < n; i++)
			{
				availableUpgradesVec[i] = DEF_AVAILABLE_UPGRADES_VEC[i].clone();
				obtainedUpgradesVec[i] = DEF_OBTAINED_UPGRADES_VEC[i].clone();
				viewedUpgradesVec[i] = new CustomDictionary();
				storedViewedUpgradesVec[i] = null;
				storedUpgradesVec[i] = null;
				storedTierVec[i] = null;
				ammoVec[i] = DEF_AMMO_VEC[i].concat();
				if ( GameSettings.DEBUG_MODE && GameSettings.allUpgrades )
				{
					var allUpgradesDct:CustomDictionary = Character.getAllUpgradesDct(i);
					for each (var upgradeName:String in allUpgradesDct)
					{
						addCharUpgrade(i,upgradeName);
					}
				}
				if (GameSettings.startWithMushroom)
				{
					if (i != Bill.CHAR_NUM)
					{
						addCharUpgrade(i, PickupInfo.MUSHROOM);
						for each ( upgradeName in Character.getMushroomUpgrades(i) )
						{
							addCharUpgrade(i, upgradeName);
						}
					}
				}
			}
			tierVec = DEF_TIER_VEC.concat();
//			skinVec = DEF_SKIN_VEC.concat();  // this was resetting the skins from title screen
			colorVec = DEF_COLOR_VEC.concat();
			resetPlayerStats();
			resetLevelStats();
			_numLives = GameSettings.initialLivesCount.lifeCount;
			_score = DEF_SCORE;
			_numCoins = DEF_NUM_COINS;
			DamageValue.dmgMult = GameSettings.attackStrength.strength;
//			numSamusMissiles = 0;
//			numSophiaMissiles = 0;
			sophiaWallGrapple = false;
			if (resetLevelToFirstLevel)
				_currentLevelID = firstLevel;
			_newLev = true;
			passedHw = false;
		}
		// used for continuing
		public function changeToFirstWorldLevel():void
		{
			_currentLevelID = new LevelID(_currentLevelID.world, 1);
		}
		// called by level.initiateLevel()
		public function startNewLevel():void
		{
			updateVars();
			_showTimeUpScrn = false;
			timePassed = 0;
			startTimeLeft();
			if (level.newLev)
			{
				_timeLeft = level.timeLeftTot;
//				if (!(player is MarioBase) && ( level.id.nameWithoutArea == "8-1" || level.id.nameWithoutArea == "8-3") )
//					_timeLeft += 100;  // this is sloppy. adds more time to two levels for other characters
				if (GameSettings.difficulty == Difficulties.VERY_EASY)
					_timeLeft += EXTRA_TIME_SUPER_EASY;
				else if (GameSettings.difficulty == Difficulties.EASY)
					_timeLeft += EXTRA_TIME_EASY;
				if (GameSettings.DEBUG_MODE && GameSettings.OVERRIDE_TIME_LEFT)
					_timeLeft = GameSettings.OVERRIDE_TIME_LEFT;
				saveStartLevelStats();
				secondsLeft = false;
				if (player is Sophia)
					Sophia(player).setMaxHover();
			}
			else if (secondsLeft)
				eventMngr.secondsLeftStart();
			tsTxt.updTimeDispTxt(_timeLeft.toString());
			tsTxt.updCoinDispTxt(_numCoins.toString());
			tsTxt.updScoreDisp(_score.toString());
		}

		private function saveStartLevelStats():void
		{
			var n:int = CharacterInfo.NUM_CHARACTERS;
			var availableUpgradesVecTmp:Vector.<CustomDictionary> = availableUpgradesVec.concat();
			var obtainedUpgradesVecTmp:Vector.<CustomDictionary> = obtainedUpgradesVec.concat();
			var viewedUpgradesVecTmp:Vector.<CustomDictionary> = viewedUpgradesVec.concat();
			var storedViewedUpgradesVecTmp:Vector.<CustomDictionary> = storedViewedUpgradesVec.concat();
			var storedUpgradesVecTmp:Vector.<CustomDictionary> = storedUpgradesVec.concat();
			var ammoVecTmp:Vector.<Array> = ammoVec.concat();
			for (var i:int = 0; i < n; i++)
			{
				availableUpgradesVecTmp[i] = availableUpgradesVec[i].clone();
				obtainedUpgradesVecTmp[i] = obtainedUpgradesVec[i].clone();
				viewedUpgradesVecTmp[i] = viewedUpgradesVec[i].clone();
				storedViewedUpgradesVecTmp[i] = storedViewedUpgradesVec[i];
				if (storedViewedUpgradesVec[i])
					storedViewedUpgradesVecTmp[i] = storedViewedUpgradesVec[i].clone();
				storedUpgradesVecTmp[i] = storedUpgradesVec[i];
				if (storedUpgradesVec[i])
					storedUpgradesVecTmp[i] = storedUpgradesVec[i].clone();
				ammoVecTmp[i] = ammoVec[i].concat();
			}
			startLevelStats[ IND_SLS_NUM_LIVES ] = _numLives;
			startLevelStats[ IND_SLS_NUM_COINS ] = _numCoins;
			startLevelStats[ IND_SLS_SCORE ] = _score;
			startLevelStats[ IND_SLS_OBTAINED_UPGRADES_VEC ] = obtainedUpgradesVecTmp;
			startLevelStats[ IND_SLS_AVAILABLE_UPGRADES_VEC ] = availableUpgradesVecTmp;
			startLevelStats[ IND_SLS_VIEWED_UPGRADES_VEC ] = viewedUpgradesVecTmp;
			startLevelStats[ IND_SLS_STORED_UPGRADES_VEC ] = storedUpgradesVecTmp;
			startLevelStats[ IND_SLS_STORED_VIEWED_UPGRADES_VEC ] = storedViewedUpgradesVecTmp;
			startLevelStats[ IND_SLS_AMMO_VEC ] = ammoVecTmp;
			startLevelStats[ IND_SLS_P_STATE_VEC ] = _pStateVec.concat();

		}
		public function touchFlag():void
		{
			timeLeftBeatLevel = tsTxt.timeRemaining;
			stopTimeLeft();
		}
		public function convertTimeToScore():void
		{
			if (Cheats.infiniteTime)
			{
				level.raiseFlag();
				return;
			}
			level.pauseMainTmrs();
			sndMngr.playSoundNow(SFX_GAME_POINTS);
			timeScoreConverterTmr = new CustomTimer(TIME_SCORE_CONVERTER_TMR_INT);
			timeScoreConverterTmr.addEventListener(TimerEvent.TIMER,timeScoreConverterTmrLsr,false,0,true);
			timeScoreConverterTmr.start();
		}
		private function timeScoreConverterTmrLsr(e:TimerEvent):void
		{
			if (_timeLeft > 0)
			{
				_timeLeft--;
				addPoints(TIME_PT_VAL);
				tsTxt.updTimeDispTxt(_timeLeft.toString());
			}
			else
			{
				timeScoreConverterTmr.stop();
				timeScoreConverterTmr.removeEventListener(TimerEvent.TIMER,timeScoreConverterTmrLsr);
				timeScoreConverterTmr = null;
				var snd:SoundContainer = sndMngr.findSound(SFX_GAME_POINTS);
				if (snd)
				{
					snd.pauseSound();
					sndMngr.removeSnd(snd);
				}
				level.resumeMainTmrs();
				var lastTimeDigit:String = timeLeftBeatLevel.charAt(timeLeftBeatLevel.length-1);
				if (lastTimeDigit == "1" || lastTimeDigit == "3" || lastTimeDigit == "6")
				{
					level.fireworksRemaining = int(lastTimeDigit);
					level.raiseFlag();
				}
				else
				{
					level.raiseFlag();
					timeLeftBeatLevel = null;
				}
				timeLeftBeatLevel = null;
			}
		}
		public function calcTimeLeft():void
		{
			var dtPassed:Number = level.dt*1000;
			timePassed += dtPassed;
			if (timePassed >= TIME_LEFT_INT)
			{
				timePassed -= TIME_LEFT_INT;
				if (level != null && !level.watchModeOverride)
					timeLeft--;
			}
		}
		public function setTimeLeftVisibility(hide:Boolean):void
		{
			if (tsTxt)
			{
				if (hide)
				{
					tsTxt.hideTime();
					statMngr.secondsLeft = false;
				}
				else
				{
					tsTxt.showTime();
					if (_timeLeft < SECONDS_LEFT_START_TIME)
					{
						_timeLeft = SECONDS_LEFT_START_TIME + 1;
						tsTxt.updTimeDispTxt(_timeLeft.toString());
					}
				}
			}
		}
		public function startNewGameHandler():void
		{
			resetAllStats();
			_allowCharacterRevival = true;
		}
		public function characterSelectStartHandler():void
		{
			_allowCharacterRevival = false;
		}
		public function beatLevelHandler(worldNum:int,levNum:int):void
		{
			if (levNum == LEV_NUM_MAX || (worldNum == LAST_WORLD && levNum == LEV_NUM_MAX - 1))
				_allowCharacterRevival = true;
		}
		public function beatGameHandler():void
		{
			var arr:Array = [];
			setBeatGameStatus(GameSettings.mapPack, GameSettings.mapDifficulty);

			if (_numCheepCheepsDefeated >= NUM_CHEEP_CHEEPS_TO_DEFEAT)
				arr.push(MenuBoxItems.WATER_MODE);
//			if (curCharNum == Sophia.CHAR_NUM)
//				arr.push(MenuBoxItems.INFINITE_HOVER);
			if (GameSettings.mapPack == MapPack.Smb)
				arr.push(MenuBoxItems.ALL_GROUND_IS_BRICKS);
			if (GameSettings.mapPack == MapPack.Special)
				arr.push(MenuBoxItems.ALL_HAMMER_BROS);
			if (allMapPacksBeatOnHard)
				arr.push(MenuBoxItems.LEVEL_SELECT);
			if (_numContinuesUsed == 0)
				arr.push(MenuBoxItems.INFINITE_LIVES);
			if (_numEnemiesStomped >= NUM_ENEMIES_TO_STOMP)
				arr.push(MenuBoxItems.BOUNCY_PITS);
			if (_numEnemiesDefeated >= NUM_ENEMIES_TO_DEFEAT)
				arr.push(MenuBoxItems.INVINCIBLE);
			if (_numAmmoPickupsCollected >= NUM_AMMO_PICKUPS_TO_COLLECT)
				arr.push(MenuBoxItems.INFINITE_AMMO);
			if (_numBricksBroken >= NUM_BRICKS_TO_BREAK)
				arr.push(MenuBoxItems.ALWAYS_BREAK_BRICKS);

			var vec:Vector.<String> = Cheats.unlockCheat(null,arr);
			if (vec.length)
				MessageBoxManager.INSTANCE.addEventListener(CustomEvents.MESSAGE_BOX_SERIES_END,beatGameMsgBoxEndHandler,false,0,true);
			else
				eventMngr.restartGame();
		}

		private function get allMapPacksBeatOnHard():Boolean
		{
			for each(var mapPack:MapPack in Enum.GetConstants(MapPack) )
			{
				if (getBeatGameStatus(mapPack) != BeatGameStatus.Hard)
					return false;
			}
			return true;
		}

		public function continueAfterDyingHandler():void
		{
			numContinuesUsed++;
			resetAllStats(false);
			changeToFirstWorldLevel();
			_allowCharacterRevival = true;
		}
		public function warpPipeHandler():void
		{
			_allowCharacterRevival = true;
		}
		private function beatGameMsgBoxEndHandler(event:Event):void
		{
			MessageBoxManager.INSTANCE.removeEventListener(CustomEvents.MESSAGE_BOX_SERIES_END,beatGameMsgBoxEndHandler);
			eventMngr.restartGame();
		}
		public function stopTimeLeft():void
		{
			_runTimeLeft = false;
		}
		public function startTimeLeft():void
		{
			_runTimeLeft = true;
		}
		public function setRandomCharNum():void
		{
			do
			{
				curCharNum = int(Math.random()*( Character.NUM_CHARACTERS) );
			}
			while ( !StatManager.characterIsEnabled(curCharNum) )
		}
		public function saveAreaStats(oldLevNum:String,oldLevArea:String,newArea:String,oldAreaStatsArr:Array):Array
		{
			var foundOldArea:Boolean;
			var foundNewArea:Boolean;
			var newAreaStatsArr:Array = [];
			if (_levStatsVec.length == 0)
			{
				_levStatsVec.push(oldAreaStatsArr);
				if (oldLevArea == newArea)
				{
					newAreaStatsArr = oldAreaStatsArr;
				}
			}
			else
			{
				for (var i:int = 0; i < _levStatsVec.length; i++)
				{
					var ca:String = _levStatsVec[i][0];
					if (ca == oldLevArea)
					{
						_levStatsVec[i] = oldAreaStatsArr;
						foundOldArea = true;
					}
					if (ca == newArea)
					{
						newAreaStatsArr = _levStatsVec[i];
						foundNewArea = true;
					}
				}
				if (!foundOldArea)
					_levStatsVec.push(oldAreaStatsArr);
				if (!foundNewArea)
					newAreaStatsArr = [];
			}
			return newAreaStatsArr;
		}
		public function prepareLoadSaveStats():Array
		{
			var arr:Array = [
			[ _currentLevelID.world, "curWorldNum"], // worldNum
			[ _currentLevelID.stage, "curLevNum"], // levNum
			[ startLevelStats[IND_SLS_NUM_LIVES], "numLives" ],
//			[ numLives, "numLives" ],
			[ startLevelStats[IND_SLS_NUM_COINS], "numCoins" ],
//			[ _numCoins, "numCoins" ],
			[ startLevelStats[IND_SLS_SCORE], "score" ],
//			[ _score, "score" ],
			[ numEnemiesDefeated, "numEnemiesDefeated" ],
			[ numEnemiesStomped, "numEnemiesStomped" ],
			[ numCheepCheepsDefeated, "numCheepCheepsDefeated" ],
			[ numHammerBrosDefeated, "numHammerBrosDefeated"],
			[ numContinuesUsed, "numContinuesUsed"],
			[ numAmmoPickupsCollected, "numAmmoPickupsCollected" ],
			[ numArmoredEnemiesDefeated, "numArmoredEnemiesDefeated" ],
			[ numBricksBroken, "_numBricksBroken" ],
			[ curCharNum, "curCharNum" ],
//			[ beatGame, "_beatGame" ],
			[ beatGameStatusVec, "beatGameStatusVec", Vector.<Enum> ],
			[ enabledCharactersVec, "enabledCharactersVec", Vector.<Boolean> ],
			[ enabledCharacterSkinsVec, "enabledCharacterSkinsVec", Vector.<Vector.<Boolean>> ],
			[ enabledSkinSetsVec, "enabledSkinSetsVec", Vector.<Boolean> ],
			[ startLevelStats[IND_SLS_OBTAINED_UPGRADES_VEC], "obtainedUpgradesVec", Vector.<CustomDictionary> ],
			[ startLevelStats[IND_SLS_AVAILABLE_UPGRADES_VEC], "availableUpgradesVec", Vector.<CustomDictionary> ],
			[ startLevelStats[IND_SLS_VIEWED_UPGRADES_VEC], "viewedUpgradesVec", Vector.<CustomDictionary> ],
			[ startLevelStats[IND_SLS_STORED_UPGRADES_VEC], "storedUpgradesVec", Vector.<CustomDictionary> ],
			[ startLevelStats[IND_SLS_STORED_VIEWED_UPGRADES_VEC], "storedViewedUpgradesVec", Vector.<CustomDictionary> ],
			[ startLevelStats[IND_SLS_AMMO_VEC], "ammoVec", Vector.<Array> ],
			[ skinVec, "skinVec", Vector.<int> ],
			[ startLevelStats[IND_SLS_P_STATE_VEC], "_pStateVec", Vector.<int> ]
			];
			return arr;
		}
		private function saveStats():Array
		{
			var arr:Array = prepareLoadSaveStats();
			var returnArr:Array = [];
			var n:int = arr.length;
			for (var i:int; i < n; i++)
			{
				var name:String = arr[i][IND_LOAD_SAVE_ARR_NAME];
				var obj:Object = arr[i][IND_LOAD_SAVE_ARR_VALUE];
				if (obj is int || obj is Boolean)
					returnArr.push( int( arr[i][IND_LOAD_SAVE_ARR_VALUE]) );
				else if (obj is Vector.<*> || obj is Vector.<int>)
					returnArr = returnArr.concat( saveVector( Vector.<Object>(obj) ) );
				else
					throw new Error("unknown type");
			}
			return returnArr;
		}
		private function loadStats(data:Array):void
		{
			var refArr:Array = prepareLoadSaveStats();
			var n:int = refArr.length;
			for (var i:int; i < n; i++)
			{
				var arr:Array = refArr[i];
				var name:String = arr[IND_LOAD_SAVE_ARR_NAME];
				var value:int = data[0];
//				var type:Class = arr[IND_LOAD_SAVE_ARR_CLASS];
				if (arr[IND_LOAD_SAVE_ARR_CLASS] == undefined)
					this[name] = data.shift();
				else
					loadVectorNestedStuff(data,arr);
//				else
//					throw new Error("shit");
			}
			_currentLevelID = new LevelID(curWorldNum, curLevNum);
		}
		private function saveVector(vec:Vector.<Object>):Array
		{
			if (!vec)
				return [ UNDEFINED_NUM ];
			else if (!vec.length)
				return [ 0 ];
			var n:int = vec.length;
			var outputArr:Array = [ n ];
			for (var i:int = 0; i < n; i++)
			{
				var obj:Object = vec[i];
				if (obj is Array || obj is Vector.<*>)
					outputArr = outputArr.concat( saveVector( Vector.<Object>(obj) ) );
				else if (obj is CustomDictionary)
					outputArr = outputArr.concat( saveCustomDictionary( obj as CustomDictionary ) );
				else if (obj is int || obj is Boolean)
					outputArr.push( int(obj) );
				else if (obj is Enum)
					outputArr.push( Enum(obj).Index );
				else if (obj == null)
					outputArr.push( UNDEFINED_NUM );
				else
					throw new Error("cannot save this type");
			}
			return outputArr;
		}
		private function loadVectorNestedStuff(data:Array,refArr:Array):void
		{
			var type:Class = refArr[IND_LOAD_SAVE_ARR_CLASS];
			var name:String = refArr[IND_LOAD_SAVE_ARR_NAME];
			var obj:Object = this[name];
			var n:int = data.shift();
//			if (n == UNDEFINED_NUM)
//				this[name] = null;
//			else
//				this[name] = new type();
			if (n == 0)
				return;
			for (var i:int = 0; i < n; i++)
			{
				if (type == Vector.<CustomDictionary>)
					obj[i] = loadSingleCustomDictionary(data);
				else if (type == Vector.<Array>)
					obj[i] = loadSingleArray(data);
				else if (type == Vector.<int>)
					obj[i] = data.shift();
				else if (type == Vector.<Enum>)
					obj[i] = Enum(obj[i]).GetAtIndex( data.shift() );
				else if (type == Vector.<Boolean>)
					obj[i] = Boolean( data.shift() );
				else if (type == Vector.<Vector.<Boolean>>)
					obj[i] = loadVectorBoolean(data);
				else
					throw new Error("unknown type");
			}

//			return outputArr;
		}
		/**
		 *only designed for outputting ints
		 * @param data
		 * @return
		 *
		 */
		private function loadSingleArray(data:Array):Array
		{
			var arr:Array = [];
			var n:int = data.shift();
			if (n == UNDEFINED_NUM)
				return null;
			if (n == 0)
				return arr;
			for (var i:int = 0; i < n; i++)
			{
				arr.push( data.shift() );
			}
			return arr;
		}

		private function loadVectorBoolean(data:Array):Vector.<Boolean>
		{
			var vec:Vector.<Boolean> = new Vector.<Boolean>();
			var n:int = data.shift();
			if (n == UNDEFINED_NUM)
				return null;
			if (n == 0)
				return vec
			for (var i:int = 0; i < n; i++)
			{
				vec.push( Boolean( data.shift() ) );
			}
			return vec;
		}

		private function loadSingleCustomDictionary(data:Array):CustomDictionary
		{
			var dct:CustomDictionary = new CustomDictionary();
			var n:int = data.shift();
			if (n == UNDEFINED_NUM)
				return null;
			if (n == 0)
				return dct;
			for (var i:int = 0; i < n; i++)
			{
				var value:String = PickupInfo.convToString( data.shift() );
				dct.addItem(value);
			}
			return dct;
		}
		private function saveCustomDictionary(dct:CustomDictionary):Array
		{
			if (!dct)
				return [ UNDEFINED_NUM ];
			else if (!dct.length)
				return [ 0 ];
			var outputArr:Array = [ dct.length ];
			for each (var key:Object in dct)
			{
				var value:Object = dct[key];
				if (key != value)
					throw new Error("can only handle matching key/value pairs");
				if ( value is int || value is Boolean )
					outputArr.push(value);
				else if (value is String)
					outputArr.push( PickupInfo.convToInt(value as String) );
				else
					throw new Error("only set up for ints");
			}
			return outputArr;
		}
		public static function characterIsEnabled(charNum:int):Boolean
		{
			return STAT_MNGR.enabledCharactersVec[charNum];
		}

		public static function get enabledCharacterCount():int
		{
			var count:int = 0;
			for each(var bool:Boolean in STAT_MNGR.enabledCharactersVec)
			{
				if (bool)
					count++;
			}
			return count;
		}

		public static function getEnabledCharacterSkinCount(charNum:int):int
		{
			var count:int = 0;
			for each(var bool:Boolean in STAT_MNGR.enabledCharacterSkinsVec[charNum])
			{
				if (bool)
					count++;
			}
			return count;
		}

		public static function get enabledSkinSetCount():int
		{
			var count:int = 0;
			for each(var bool:Boolean in STAT_MNGR.enabledSkinSetsVec)
			{
				if (bool)
					count++;
			}
			return count;
		}

//		public static function set enabledSkinSets(value:Vector.<Boolean>):void
//		{
//			if (value.length != STAT_MNGR.ENABLED_SKIN_SETS.length)
//				return;
//			for (int i = 0; i < value.length; i++)
//				STAT_MNGR.ENABLED_SKIN_SETS[i] = value[i];
//		}

		public static function toggleCharacterIsEnabled(charNum:int):Boolean
		{
			return STAT_MNGR.enabledCharactersVec[charNum] = !STAT_MNGR.enabledCharactersVec[charNum];
		}

		public static function characterSkinIsEnabled(charNum:int, skinNum:int):Boolean
		{
			return STAT_MNGR.enabledCharacterSkinsVec[charNum][skinNum];
		}

		public static function skinSetIsEnabled(skinNum:int):Boolean
		{
			return STAT_MNGR.enabledSkinSetsVec[skinNum];
		}

		public static function toggleSkinSetEnabled(skinNum:int):Boolean
		{
			return STAT_MNGR.enabledSkinSetsVec[skinNum] = !STAT_MNGR.enabledSkinSetsVec[skinNum];
		}

		public static function toggleCharacterSkinEnabled(charNum:int, skinNum:int):Boolean
		{
			return STAT_MNGR.enabledCharacterSkinsVec[charNum][skinNum] = !STAT_MNGR.enabledCharacterSkinsVec[charNum][skinNum];
		}

		public function saveData():void
		{
			var dataArr:Array = [ Versions.toInt(GameSettings.VERSION_NUMBER) ].concat(
				saveStats(),
				btnMngr.keyCodesVec,
				GameSettings.saveData(),
				tutMngr.saveData(),
				Cheats.saveData()
			);
			var saveDataStr:String = SAVE_DATA_PREFIX_STR;
			var n:int = dataArr.length;
			for (var i:int; i < n; i++)
			{
				saveDataStr += dataArr[i].toString();
				saveDataStr += SAVE_DATA_STR_DIVIDER;
			}
			saveDataStr = saveDataStr.substr(0,saveDataStr.length - 1); // takes off last comma
			saveDataStr += SAVE_DATA_SUFFIX_STR;
			_fileRef = new FileReference();
			_fileRef.addEventListener(Event.COMPLETE,fileRefSaveCompleteHandler,false,0,true);
			_fileRef.addEventListener(Event.CANCEL,fileRefCancelHandler,false,0,true);
			_fileRef.save(saveDataStr,SAVE_FILE_NAME);
		}
		private function fileRefLoadCompleteHandler(e:Event):void
		{
			_fileRef.removeEventListener(Event.COMPLETE,fileRefLoadCompleteHandler);
			btnMngr.relBtns();
			var loadedDataStr:String = _fileRef.data.readUTFBytes(_fileRef.data.length);
			_fileRef = null;
			var startInd:int = loadedDataStr.indexOf(SAVE_DATA_PREFIX_STR);
			var endInd:int = loadedDataStr.indexOf(SAVE_DATA_SUFFIX_STR);
			if (startInd == -1 || endInd == -1)
			{
				MenuBox.activeMenu.nextMsgBxToCreate = new PlainMessageBox(MessageBoxMessages.LOAD_GAME_ERROR);
				MessageBoxManager.INSTANCE.writeNextMainMenu(MenuBox.activeMenu.nextMsgBxToCreate);
				MenuBox.activeMenu.cancel();
				return;
			}
			startInd += SAVE_DATA_PREFIX_STR.length;
			loadedDataStr = loadedDataStr.substring(startInd,endInd);
			var loadedDataArr:Array = loadedDataStr.split(SAVE_DATA_STR_DIVIDER);
			var n:int = loadedDataArr.length;
			for (var i:int; i < n; i++)
			{
				loadedDataArr[i] = int(loadedDataArr[i]); // converts everything to ints instead of string
			}
			var versionNum:Number = Versions.toNum(loadedDataArr.shift());
			if (versionNum < GameSettings.VERSION_SAVE_FILE_COMPAT_MIN || n < LOAD_DATA_REQ_LENGTH)
			{
				MenuBox.activeMenu.nextMsgBxToCreate = new PlainMessageBox(MessageBoxMessages.LOAD_GAME_VERSION_ERROR);
				MessageBoxManager.INSTANCE.writeNextMainMenu(MenuBox.activeMenu.nextMsgBxToCreate);
				MenuBox.activeMenu.cancel();
				return;
			}
			loadingData = true;
			resetAllStats();
			loadStats(loadedDataArr);
//			trace("skin num mega: "+skinVec[MegaMan.CHAR_NUM]);
//			n = DEF_P_ST_ARR.length;
//			_pStateVec = Vector.<int>( loadedDataArr.slice(0,n) );
//			loadedDataArr.splice(0,DEF_P_ST_ARR.length);
			n = btnMngr.keyCodesVec.length;
			btnMngr.keyCodesVec = Vector.<int>( loadedDataArr.slice(0,n) );
			btnMngr.writeKeyCodesFromVec();
			loadedDataArr.splice(0,n);
			GameSettings.loadData(loadedDataArr);
//			trace("skin num mega: "+skinVec[MegaMan.CHAR_NUM]);
			tutMngr.loadData(loadedDataArr);
			Cheats.loadData(loadedDataArr);
			if (loadedDataArr.length)
				throw new Error("extra data on load");
			loadedDataArr = null;
			loadingData = false;
			DamageValue.dmgMult = GameSettings.attackStrength.strength;
			eventMngr.loadGame();
		}
		public function loadSaveData():void
		{
			_fileRef = new FileReference();
			var fileFilter:FileFilter = new FileFilter("saveData","*.txt");
			_fileRef.addEventListener(Event.SELECT,fileRefLoadSelect,false,0,true);
			_fileRef.addEventListener(Event.CANCEL,fileRefCancelHandler,false,0,true);
			_fileRef.browse([fileFilter]);
		}
		private function fileRefCancelHandler(event:Event):void
		{
			_fileRef.removeEventListener(Event.CANCEL,fileRefCancelHandler);
			_fileRef = null;
			btnMngr.relBtns();
		}
		private function fileRefSaveCompleteHandler(e:Event):void
		{
			_fileRef.removeEventListener(Event.COMPLETE,fileRefSaveCompleteHandler);
			_fileRef = null;
			btnMngr.relBtns();
		}
		private function fileRefLoadSelect(event:Event):void
		{
			_fileRef.removeEventListener(Event.SELECT,fileRefLoadSelect);
			_fileRef.addEventListener(Event.COMPLETE,fileRefLoadCompleteHandler,false,0,true);
			_fileRef.load();
		}
		public function resetLevelStats():void
		{
			_levStatsVec.length = 0;
			scrnMngr.resetAreaStats();
		}
		public function writePlayerStats(cNum:int,pState:uint,pExInt:int):void
		{
			_plyrStatsArr = [cNum,pState,pExInt];
			_pStateVec[cNum] = pState;
		}
		public function updatePStateVec(charNum:int,pState:int):void
		{
			_pStateVec[charNum] = pState;
		}
		public function getCharPState(charNum:int):int
		{
			return _pStateVec[charNum];
		}
		public function getCurrentBmc(charNum:int = -1):BmdSkinCont
		{
			var gm:GraphicsManager = GraphicsManager.INSTANCE;
			if (charNum < 0)
				charNum = curCharNum;
			var skinNum:int = STAT_MNGR.skinVec[charNum];
			return gm.CLEAN_BMC_VEC_CHARACTER[charNum][skinNum];
		}
		public function getBmc(charNum:int, skinNum:int):BmdSkinCont
		{
			return GraphicsManager.INSTANCE.CLEAN_BMC_VEC_CHARACTER[charNum][skinNum];
		}

		public function getSkinName(fullName:Boolean = false):String
		{
			var arr:Array = getCurrentBmc().namesArr;
			if (arr)
			{
				if (fullName)
					return arr[BmdSkinCont.IND_NAME_ARR_FULL];
				else
					return arr[BmdSkinCont.IND_NAME_ARR_SHORT];
			}
			else
				return null;
		}
		public function setCharSkinNum(charNum:int,skinNum:int):void
		{
			skinVec[charNum] = skinNum;
		}
		public function getCharSkinNum(charNum:int):int
		{
			return skinVec[charNum];
		}

//		public function getRandomCharSkin(charNum:int):int
//		{
//			var skinNumbers:Vector.<int> = Character.getSkinOrderVec(charNum);
//			var index:int = int( Math.random() * skinNumbers.length );
//			return skinNumbers[index];
//		}

		public function getCharSkinOrder(charNum:int):Vector.<int>
		{
			return CHAR_SKIN_ORDER_VEC[charNum];
		}

		public function setCharColorNum(charNum:int,colorNum:int):void
		{
			colorVec[charNum] = colorNum;
		}
		public function getCharColorNum(charNum:int):int
		{
			return colorVec[charNum];
		}
		public function changeStat(statToChange:String,changeAmt:int,updDispFct:Function = null):void
		{
			var capsStr:String = "";
			var n:int = statToChange.length;
			var curStatAmt:int = this[statToChange];
			for (var i:int = 0; i < n; i++)
			{
				var str:String = statToChange.charAt(i);
				if ( !isUpperCase(str) )
					capsStr += str.toUpperCase();
				else
					capsStr += CONST_SEP + str;
			}
			curStatAmt += changeAmt;
			var max:int = this[capsStr + MAX_STR];
			var min:int = this[capsStr + MIN_STR];
			if (curStatAmt > max)
				curStatAmt = max;
			else if (curStatAmt < min)
				curStatAmt = min;
			this[statToChange] = curStatAmt;
			if (updDispFct != null)
				updDispFct(curStatAmt);
		}
		private function isUpperCase(p_char:String):Boolean
		{
			if (p_char.length > 1)
				throw new Error("only works on single character");
			var lowChar:String = p_char.toLowerCase();
			var upChar:String = p_char.toUpperCase();
			switch (p_char) {
				case lowChar:
					return false;
				case upChar:
					return true;
				default:
					return false;
			}
		}
		public function get plyrStatsArr():Array
		{
			return _plyrStatsArr;
		}
		public function resetPlayerStats():void
		{
			_plyrStatsArr = DEF_PLYR_STATS_ARR.concat();
		}
		public function passHalfwayPoint():void
		{
			passedHw = true;
		}
		private function updateVars():void
		{
			level = GlobVars.level;
			player = level.player;
			tsTxt = level.tsTxt;
		}
		public function stopTmrs():void
		{

		}
		public function startTmrs():void
		{

		}
		public function getSubWeapon(charNum:int):String
		{
			var vec:Vector.<String> = SUB_WEAPON_VEC;
			return SUB_WEAPON_VEC[charNum];
		}
		public function setSubWeapon(charNum:int,value:String):void
		{
			SUB_WEAPON_VEC[charNum] = value;
		}
		/**
		 *This is called when an upgrade appears. It prepares the game to figure out the next upgrade
		 * @param charNum
		 * @param upgradeType
		 *
		 */
		public function prepareNextUpgrade(charNum:int,upgradeType:String):void
		{
			var dct:CustomDictionary = getAvailableUpgradesVec(charNum);
			dct.removeItem(upgradeType);
			if (upgradeType != PickupInfo.MUSHROOM && upgradeType != PickupInfo.FIRE_FLOWER)
				viewedUpgradesVec[charNum].addItem(upgradeType);
//			trace("prepare available upgrades: "+dct);
//			trace("prepare viewed upgrades: "+viewedUpgradesVec[charNum]);
			if (dct.length)
				return;
			setTier(charNum, getNextAvailableTier(charNum) );
//			var tierNum:int = getTier(charNum);
//			if ( tierNum < getMaxTierNum(charNum) )
//				tierNum++;
//			else
//				tierNum = getNextAvailableTier(charNum);
//			if (tierNum < 0)
//				throw new Error("no upgrades available");
//			setTier(charNum,tierNum);
		}
		public function charIsFullyUpgraded(charNum:int):Boolean
		{
			if (GameSettings.classicMode)
			{
				var obtainedUpgrades:CustomDictionary = getObtainedUpgradesDct(charNum);
				return obtainedUpgrades[PickupInfo.MUSHROOM] != undefined && obtainedUpgrades[PickupInfo.FIRE_FLOWER] != undefined;
			}
//			if (GameSettings.classicMode)
//
			return getAvailableUpgradesVec(charNum).length == 0;
//			var availableUpgrades:CustomDictionary = getAvailableUpgradesVec(charNum);
//			if ( availableUpgrades.length == 0 )
//				return true;
//			var neverLoseUpgrades:CustomDictionary = Character.getNeverLoseUpgrades(charNum);
//			for each (var upgradeType:String in availableUpgrades)
//			{
//				if ( !upgradeIsSingle(charNum, upgradeType) || neverLoseUpgrades[upgradeType] == undefined )
//					return false;
//			}
//			return true;
		}
		public function addCharUpgrade(charNum:int,upgradeType:String):void
		{
			if (upgradeType == PickupInfo.FIRE_FLOWER && curCharNum != Mario.CHAR_NUM && curCharNum != Luigi.CHAR_NUM && GameSettings.powerupMode != PowerupMode.Classic)
				return;
			obtainedUpgradesVec[charNum].addItem(upgradeType);
			availableUpgradesVec[charNum].removeItem(upgradeType);
			if (player)
			{
				if (upgradeType == PickupInfo.MUSHROOM)
				{
					if (GameSettings.powerupMode == PowerupMode.Classic)
					{
						for each (var str:String in player.classicGetMushroomUpgrades)
							addCharUpgrade(charNum,str);
					}
					else
					{
						for each (str in player.mushroomUpgrades)
							addCharUpgrade(charNum,str);
					}
				}
				else if (GameSettings.powerupMode == PowerupMode.Classic && upgradeType == PickupInfo.FIRE_FLOWER)
				{
					for each (str in player.classicGetFireFlowerUpgrades)
					addCharUpgrade(charNum,str);
				}
				var replacer:String = player.replaceableUpgrades[upgradeType];
				if (replacer && !obtainedUpgradesVec[charNum][replacer])
					availableUpgradesVec[charNum].addItem(replacer);
			}
			removeItemsIfSingle(charNum,upgradeType);
			if (tsTxt)
				tsTxt.updateUpgIcons();
		}
//		checks if item is single and then if has any other items that will be replaced by this item
		public function hasCompetingSingleItem(charNum:int,upg:String):Boolean
		{
//			var singleVec:Vector.<CustomDictionary> = SINGLE_UPGRADES_VEC[charNum];
			var obtainedDct:CustomDictionary = obtainedUpgradesVec[charNum];
			var dct:CustomDictionary = SINGLE_UPGRADES_VEC[charNum];
			if (dct[upg]) // this is a single item
			{
				for each (var str:String in dct)
				{
					if (obtainedDct[str] && str != upg)
						return true;
				}
			}
			return false;
		}

		private function upgradeIsSingle(charNum:int, upgradeType:String):Boolean
		{
			var dct:CustomDictionary = SINGLE_UPGRADES_VEC[charNum];
			return dct[upgradeType] != undefined;
		}

		private function removeItemsIfSingle(charNum:int,upgradeType:String):void
		{
			var obtainedDct:CustomDictionary = obtainedUpgradesVec[charNum];
			var dct:CustomDictionary = SINGLE_UPGRADES_VEC[charNum];
			if (dct[upgradeType])
			{
				for each (var str:String in dct)
				{
					if (obtainedDct[str] && str != upgradeType)
						removeCharUpgrade(charNum,str,true);
				}
			}
		}
		private function maxTierUpgrades(charNum:int):String
		{
			switch(charNum)
			{
				case Bass.CHAR_NUM:
				case MegaMan.CHAR_NUM:
					return PickupInfo.MEGA_MAN_WEAPON_ENERGY_BIG;
				case Link.CHAR_NUM:
				{
					if (Math.random() < .5)
						return PickupInfo.LINK_ARROW_AMMO;
					return PickupInfo.LINK_BOMB_AMMO;
				}
//				case Pit.CHAR_NUM:
//					return PickupInfo.PIT_FEATHER;
				case Samus.CHAR_NUM:
					return PickupInfo.SAMUS_MISSILE_AMMO;
				case Sophia.CHAR_NUM:
				{
					if (Math.random() < .5)
						return PickupInfo.SOPHIA_HOMING_MISSILE_AMMO;
					return PickupInfo.SOPHIA_MISSILE_AMMO;
				}
//				case VicViper.CHAR_NUM:
//					return PickupInfo.VIC_POWER_UP_1;
			}
			return null;
		}
		public function removeAllUpgradesForChar(charNum:int,storeUpgrades:Boolean = false, removeMushroomlessUpgrades:Boolean = false):void
		{
			removeCharUpgrade(charNum,PickupInfo.MUSHROOM); // so mushroom is not stored
			var currentUpgrades:CustomDictionary = obtainedUpgradesVec[charNum].clone();
			var storedUpgradesDct:CustomDictionary = new CustomDictionary();
			var upgradesToKeepDct:CustomDictionary = new CustomDictionary();
			for each (var upg:String in currentUpgrades)
			{
				if (player && player.neverLoseUpgrades[upg] != undefined)
					upgradesToKeepDct.addItem(upg,upg);
				if (player && player.restorableUpgrades[upg] != undefined)
					storedUpgradesDct.addItem(upg,upg);
			}
			if (storeUpgrades && currentUpgrades.length && charNum != Mario.CHAR_NUM && charNum != Luigi.CHAR_NUM)
			{
				storedUpgradesVec[charNum] = storedUpgradesDct;
				storedViewedUpgradesVec[charNum] = viewedUpgradesVec[charNum].clone();
				storedTierVec[charNum] = getTier(charNum);
			}
			else
			{
				storedUpgradesVec[charNum] = null;
				storedTierVec[charNum] = null;
				storedViewedUpgradesVec[charNum] = null;
			}
			for each (var str:String in currentUpgrades)
			{
				removeCharUpgrade(charNum,str);
			}
			setTier(charNum,0);
//			availableUpgradesVec[charNum] = DEF_AVAILABLE_UPGRADES_VEC[charNum].clone();
			var availableUpgradesDct:CustomDictionary = DEF_AVAILABLE_UPGRADES_VEC[charNum].clone();
			if (removeMushroomlessUpgrades)
				obtainedUpgradesVec[charNum] = DEF_OBTAINED_UPGRADES_VEC[charNum].clone();
			else
			{
				obtainedUpgradesVec[charNum] = upgradesToKeepDct;
				for each(upg in upgradesToKeepDct)
					availableUpgradesDct.removeItem(upg);
			}
			availableUpgradesVec[charNum] = availableUpgradesDct;
		}
		public function removeCharUpgrade(charNum:int,upgradeType:String,removeWithoutMushroom:Boolean = false):void
		{
			if ( player && !removeWithoutMushroom && player.neverLoseUpgrades[upgradeType] != undefined )
				return;
			obtainedUpgradesVec[charNum].removeItem(upgradeType);
			if (upgradeType == PickupInfo.MUSHROOM && player && GameSettings.difficulty != Difficulties.VERY_EASY && !GameSettings.classicMode)
			{
				for each (var str:String in player.mushroomUpgrades)
				{
					STAT_MNGR.removeCharUpgrade(charNum,str);
				}
			}
			if (tsTxt)
				tsTxt.updateUpgIcons();
		}
		public function getObtainedUpgradesDct(charNum:int):CustomDictionary
		{
			return obtainedUpgradesVec[charNum];
		}
		public function getRandomUpgrade(charNum:int):String
		{
//			if (storedUpgradesVec[charNum])
//				trace("break");
//			if (GameSettings.hideNewStuff)
//				return PickupInfo.MARIO_FIRE_FLOWER;
			if (player.canGetMushroom)
			{
				if (!player.upgradeIsActive(PickupInfo.MUSHROOM) )
					return PickupInfo.MUSHROOM;
				if ( player is MarioBase || GameSettings.powerupMode == PowerupMode.Classic )
					return PickupInfo.FIRE_FLOWER;
			}
			var dct:CustomDictionary = getAvailableUpgradesVec(charNum);
			var newUpgrade:String;
			if (dct.length)
			{
				newUpgrade = getRandomValueFromDct(dct,viewedUpgradesVec[charNum]);
				if (newUpgrade)
					return newUpgrade;
			}
			var newTier:int = getNextAvailableTier(charNum);
			if (newTier != -1)
			{
				setTier( charNum,newTier );
				if (dct.length)
				{
					newUpgrade = getRandomValueFromDct(dct,viewedUpgradesVec[charNum]);
					if (newUpgrade)
						return newUpgrade;
				}
			}
			else // there are no upgrade sin this tier
				return maxTierUpgrades(charNum);
			throw new Error("no available upgrades in dct");
			return null;
		}
		private function getRandomValueFromDct(dct:CustomDictionary,viewedUpgrades:CustomDictionary):String
		{
			var i:int;
			var arr:Array = [];
			for each (var type:String in dct)
			{
				if (viewedUpgrades[type])
					dct.removeItem(type);
			}
			for each (type in dct)
			{
				arr[i] = type;
				i++;
			}
			if (i > 0)
			{
				i = int(Math.random()*i);
				return arr[i];
			}
			return null;
		}
		public function addStoredUpgrades(charNum:int,upgrades:CustomDictionary,tierNum:int,viewedUpgrades:CustomDictionary):void
		{
			if (!upgrades || player.charNum != charNum)
				return;
//			setTier(charNum,tierNum);
			viewedUpgradesVec[charNum] = viewedUpgrades;
//			trace("fire flower viewed upgrades: "+viewedUpgrades);
			for each (var upgradeType:String in upgrades)
			{
				player.hitPickup( new Pickup(upgradeType),false );
			}
		}
		public function getStoredUpgrades():CustomDictionary
		{
			var dct:CustomDictionary = storedUpgradesVec[curCharNum];
			if (dct)
			{
				dct = dct.clone();
				storedUpgradesVec[curCharNum] = null;
			}
			return dct;
		}
		public function getAvailableUpgradesVec(charNum:int):CustomDictionary
		{
			return availableUpgradesVec[charNum];
		}
		public function getTier(charNum:int):int
		{
			return tierVec[charNum];
		}
		public function getNextAvailableTier(charNum:int):int
		{
			var vec:Vector.<CustomDictionary> = MASTER_AVAILABLE_UPGRADES_VEC[charNum];
			var returnArr:Array = [];
			var obtainedDct:CustomDictionary = obtainedUpgradesVec[charNum];
			var n:int = vec.length;
			var maxTier:int = getMaxTierNum(charNum);
			var tierStart:int = getTier(charNum) + 1;
			if (tierStart > maxTier)
				tierStart = 0;
			var curTier:int = tierStart;
			var dct:CustomDictionary;
			for (curTier; curTier <= maxTier; curTier++)
			{
				dct = vec[curTier];
				for each (var puType:String in dct)
				{
					if ( obtainedDct.containsValue(puType) && player )
						puType = player.replaceableUpgrades[puType];
					if ( puType && !obtainedDct.containsValue(puType) )
						return curTier;
				}
			}
			if (tierStart == 0)
			{
//				trace("no tiers");
				return -1; // all upgrades have been obtained
			}
			// sloppy. copies same code
			curTier = 0;
			for (curTier; curTier <= tierStart; curTier++)
			{
				dct = vec[curTier];
				for each (puType in dct)
				{
					if ( !obtainedDct.containsValue(puType) )
						return curTier;
				}
			}
//			trace("no tiers");
			return -1; // all upgrades have been obtained
		}
		private function getMaxTierNum(charNum:int):int
		{
			return MASTER_AVAILABLE_UPGRADES_VEC[charNum].length - 1;
		}
		private function setTier(charNum:int,newTierNum:int):void
		{
			if (newTierNum == -1)
				return;
			viewedUpgradesVec[charNum] = new CustomDictionary();
			var sourceDct:CustomDictionary = MASTER_AVAILABLE_UPGRADES_VEC[charNum][newTierNum];
			var obtainedDct:CustomDictionary = obtainedUpgradesVec[charNum];
			var dct:CustomDictionary = availableUpgradesVec[charNum];
			for each (var puType:String in sourceDct)
			{
				if ( obtainedDct.containsValue(puType) && player )
					puType = player.replaceableUpgrades[puType];
				if ( puType && !obtainedDct.containsValue(puType) )
					dct.addItem(puType);
			}
			tierVec[charNum] = newTierNum;
			if (player)
			{
				player.curTier = newTierNum;
//				player.availableUpgradesDct = dct;
			}
//			if (!dct.length)
//				throw new Error("cannot set to empty tier");
//			trace("set tier: "+newTierNum+" available upgrades: "+dct);

		}
		public function getAmmoRemaining(charNum:int,ind:int):int
		{
			return ammoVec[charNum][ind];
		}
		public function setAmmoRemaining(charNum:int,ind:int,value:int):void
		{
			ammoVec[charNum][ind] = value;
		}
		public function getIconOrderVec(charNum:int):Vector.<String>
		{
			return ICON_ORDER_VEC[charNum];
		}
		private function setCurrent():void
		{

		}
		public function addPoints(points:uint):void
		{
			if (gsMngr.gameState == GameStates.CHARACTER_SELECT)
				return;
			_score += points;
			if (_score > SCORE_MAX)
				_score = SCORE_MAX;
			tsTxt.updScoreDisp(_score.toString());
		}
		public function addLife():void
		{
			_numLives++;
			if (_numLives > NUM_LIVES_MAX) _numLives = NUM_LIVES_MAX;
			sndMngr.playSound(SFX_GAME_NEW_LIFE);
		}
		public function loseLife():void
		{
			if (Cheats.infiniteLives)
				return;
			_numLives--;
			if (_numLives < NUM_LIVES_GAME_OVER)
				_numLives = NUM_LIVES_GAME_OVER;
		}
		public function checkPStateVecForAllZeroes():Boolean
		{
			var psFall:int = Character.PS_FALLEN;
			for each (var i:int in pStateVec)
			{
				if (i != psFall)
					return false;
			}
			return true;
		}
		public function playerDie():void
		{
			if (GameSettings.campaignMode != CampaignModes.SURVIVAL || Cheats.infiniteLives)
			{
				if (player)
					player.pState = Character.PS_NORMAL;
				_plyrStatsArr[PLYR_STATS_IND_P_STATE] = Character.PS_NORMAL;
				loseLife();
			}
			else // doesn't execute if infinte lives enabled
			{
				var psFall:int = Character.PS_FALLEN;
				_plyrStatsArr[PLYR_STATS_IND_P_STATE] = psFall;
				pStateVec[curCharNum] = psFall;
				if (player)
					player.pState = Character.PS_FALLEN;
			}
		}
		public function set curCharNum(char:int):void
		{
			_curCharNum = char;
			plyrStatsArr[0] = char;
		}

		public function get currentLevelID():LevelID
		{
			return _currentLevelID;
		}

		public function set currentLevelID(value:LevelID):void
		{
			_currentLevelID = value;
		}

		public function get curCharNum():int
		{
			return _curCharNum;
		}
		public function get numLives():int
		{
			return _numLives;
		}
		public function set numLives(value:int):void
		{
			if (value < NUM_LIVES_MIN)
				value = NUM_LIVES_MIN;
			if (value > NUM_LIVES_MAX)
				NUM_LIVES_MAX;
			_numLives = value;
		}
		public function get numCoins():int
		{
			return _numCoins;
		}
		public function set numCoins(value:int):void
		{
			if (value < NUM_COINS_MIN)
				value = NUM_COINS_MIN;
			if (value > NUM_COINS_MAX)
				NUM_COINS_MAX;
			_numCoins = value;
		}
		public function get numCoinsStr():String
		{
			var coinStr:String;
			if (_numCoins < 10) coinStr = "0"+_numCoins.toString();
			else coinStr = _numCoins.toString();
			return coinStr;
		}
		public function get newLev():Boolean
		{
			return _newLev;
		}
		public function set newLev(nl:Boolean):void
		{
			_newLev = nl;
		}
		public function get pStateVec():Vector.<int>
		{
			return _pStateVec;
		}
		public function get score():int
		{
			return _score;
		}
		public function set score(value:int):void
		{
			if (value < SCORE_MIN)
				value = SCORE_MIN;
			else if (value > SCORE_MAX)
				value = SCORE_MAX;
			_score = value;
		}
		public function cleanUp():void
		{

		}
		public function changeDifficulty():void
		{
//			switch(GameSettings.difficulty)
//			{
//				case(Difficulties.VERY_EASY):
//				{
//					DamageValue.dmgMult = DamageValue.DMG_MULT_SUPER_EASY;
//					break;
//				}
//				case(Difficulties.EASY):
//				{
//					DamageValue.dmgMult = DamageValue.DMG_MULT_EASY;
//					break;
//				}
//				case(Difficulties.NORMAL):
//				{
//					DamageValue.dmgMult = DamageValue.DMG_MULT_NORMAL;
//					break;
//				}
//				case(Difficulties.HARD):
//				{
//					DamageValue.dmgMult = DamageValue.DMG_MULT_HARD;
//					break;
//				}
//				case(Difficulties.VERY_HARD):
//				{
//					DamageValue.dmgMult = DamageValue.DMG_MULT_EXTREME;
//					break;
//				}
//			}
		}
		public function convNameToNum(str:String):uint
		{
			return CharacterInfo.convNameToNum(str);
		}
		public function convNumToName(num:int):String
		{
			return CharacterInfo.convNumToName(num);
		}
		public function getRandomCharNum():int
		{
			return int( Math.random() * ( Character.NUM_CHARACTERS ) );
		}
		private function checkDefaultStatMaxMin(value:int):int
		{
			if (value > STAT_MAX_DEF)
				value = STAT_MAX_DEF;
			else if (value < STAT_MIN_DEF)
				value = STAT_MIN_DEF;
			return value;
		}
		public function get fileRef():FileReference
		{
			return _fileRef;
		}
		public function get showTimeUpScrn():Boolean
		{
			return _showTimeUpScrn;
		}
		public function get runTimeLeft():Boolean
		{
			return _runTimeLeft;
		}
		public function get timeLeft():int
		{
			return _timeLeft;
		}
		public function set timeLeft(value:int):void
		{
			_timeLeft = value;
			if (_timeLeft < TIME_MIN)
				_timeLeft = TIME_MIN;
			tsTxt.updTimeDispTxt(_timeLeft.toString());
			if (Cheats.infiniteTime || level is CharacterSelect || level is TitleLevel )
				return;
			if (_timeLeft == SECONDS_LEFT_START_TIME)
				eventMngr.secondsLeftIntro();
			else if (_timeLeft == PLAYER_DIE_TIME)
			{
				_showTimeUpScrn = true;
				player.die();
			}
		}

		public function get numEnemiesDefeated():int
		{
			return _numEnemiesDefeated;
		}

		public function set numEnemiesDefeated(value:int):void
		{
			value = checkDefaultStatMaxMin(value);
			_numEnemiesDefeated = value;
			if (value == NUM_ENEMIES_TO_DEFEAT && beatGame)
				Cheats.unlockCheat(MenuBoxItems.INVINCIBLE);
		}

		public function get numHammerBrosDefeated():int
		{
			return _numHammerBrosDefeated;
		}

		public function set numHammerBrosDefeated(value:int):void
		{
			value = checkDefaultStatMaxMin(value);
			_numHammerBrosDefeated = value;
			if (value == NUM_HAMMER_BROS_TO_DEFEAT)
				Cheats.unlockCheat(MenuBoxItems.EVIL_HAMMER_BROS);
		}

		public function get numEnemiesStomped():int
		{
			return _numEnemiesStomped;
		}

		public function set numEnemiesStomped(value:int):void
		{
			value = checkDefaultStatMaxMin(value);
			_numEnemiesStomped = value;
			if (value == NUM_ENEMIES_TO_STOMP && beatGame)
				Cheats.unlockCheat(MenuBoxItems.BOUNCY_PITS);
		}

		public function get numArmoredEnemiesDefeated():int
		{
			return _numArmoredEnemiesDefeated;
		}

		public function set numArmoredEnemiesDefeated(value:int):void
		{
			value = checkDefaultStatMaxMin(value);
			_numArmoredEnemiesDefeated = value;
			if (value == NUM_ARMORED_ENEMIES_TO_DEFEAT && beatGame)
				Cheats.unlockCheat(MenuBoxItems.ALL_WEAPONS_PIERCE);
		}

		public function get numBricksBroken():int
		{
			return _numBricksBroken;
		}

		public function set numBricksBroken(value:int):void
		{
			value = checkDefaultStatMaxMin(value);
			_numBricksBroken = value;
			if (value == NUM_BRICKS_TO_BREAK && beatGame)
				Cheats.unlockCheat(MenuBoxItems.ALWAYS_BREAK_BRICKS);
		}

		public function get numAmmoPickupsCollected():int
		{
			return _numAmmoPickupsCollected;
		}

		public function set numAmmoPickupsCollected(value:int):void
		{
			value = checkDefaultStatMaxMin(value);
			_numAmmoPickupsCollected = value;
			if (value == NUM_AMMO_PICKUPS_TO_COLLECT && beatGame)
				Cheats.unlockCheat(MenuBoxItems.INFINITE_AMMO);
		}

		public function get beatGame():Boolean
		{
			for each(var mapPack:MapPack in Enum.GetConstants(MapPack) )
			{
				if (getBeatGameStatus(mapPack) != BeatGameStatus.None)
					return true;
			}
			return false;
		}

		public function get numContinuesUsed():int
		{
			return _numContinuesUsed;
		}

		public function set numContinuesUsed(value:int):void
		{
			value = checkDefaultStatMaxMin(value);
			_numContinuesUsed = value;
		}

		public function get numCheepCheepsDefeated():int
		{
			return _numCheepCheepsDefeated;
		}

		public function set numCheepCheepsDefeated(value:int):void
		{
			value = checkDefaultStatMaxMin(value);
			_numCheepCheepsDefeated = value;
			if (value == NUM_CHEEP_CHEEPS_TO_DEFEAT && beatGame)
				Cheats.unlockCheat(MenuBoxItems.WATER_MODE);
		}

		public function get allowCharacterRevival():Boolean
		{
			return _allowCharacterRevival;
		}

		public function get numSophiaMissiles():int
		{
			return _numSophiaMissiles;
		}

		public function set numSophiaMissiles(value:int):void
		{
			if (value < NUM_SOPHIA_MISSILES_MIN)
				value = NUM_SOPHIA_MISSILES_MIN;
			else if (value > NUM_SOPHIA_MISSILES_MAX)
				value = NUM_SOPHIA_MISSILES_MAX;
			_numSophiaMissiles = value;
		}

		public function get numSamusMissiles():int
		{
			return _numSamusMissiles;
		}

		public function set numSamusMissiles(value:int):void
		{
			if (value < NUM_SAMUS_MISSILES_MIN)
				value = NUM_SAMUS_MISSILES_MIN;
			else if (value > NUM_SAMUS_MISSILES_MAX)
				value = NUM_SAMUS_MISSILES_MAX;
			_numSamusMissiles = value;
		}

		private function getBeatGameStatus(mapPack:MapPack):BeatGameStatus
		{
			return beatGameStatusVec[mapPack.Index];
		}

		private function setBeatGameStatus(mapPack:MapPack, mapDifficulty:int):void
		{
			var lastDifficulty:int = BeatGameStatus.GetMapDifficulty( getBeatGameStatus(mapPack) );
			if (mapDifficulty > lastDifficulty)
				beatGameStatusVec[mapPack.Index] = BeatGameStatus.GetStatus(mapDifficulty);
		}

		public function checkCancelSecondsLeft():void
		{
			if (secondsLeft && _timeLeft > SECONDS_LEFT_START_TIME)
			{
				secondsLeft = false;
				sndMngr.changeMusic();
			}
		}

		private static function disableAtariSkins():void
		{
			for (var i:int = 0; i < Character.NUM_CHARACTERS; i++)
				STAT_MNGR.enabledCharacterSkinsVec[i][Character.getAtariSkinNumber(i)] = false;

			STAT_MNGR.enabledCharacterSkinsVec[Bill.CHAR_NUM][Bill.SKIN_LANCE_ATARI] = false; // lance
			STAT_MNGR.enabledSkinSetsVec[BmdInfo.SKIN_NUM_SMB_ATARI] = false;
		}

		private static function disableSharpX1Skins():void
		{
			for (var i:int = 0; i < Character.NUM_CHARACTERS; i++)
				STAT_MNGR.enabledCharacterSkinsVec[i][Character.getSpecialSkinNumber(i)] = false;

			STAT_MNGR.enabledCharacterSkinsVec[Bill.CHAR_NUM][Bill.SKIN_LANCE_X1] = false; // lance
			STAT_MNGR.enabledSkinSetsVec[BmdInfo.SKIN_NUM_SMB_SPECIAL] = false;
		}

		private static function disableInvisibleSkinSet():void
		{
			STAT_MNGR.enabledSkinSetsVec[BmdInfo.SKIN_NUM_INVISIBLE] = false;
		}

		private static function disableAllSkins():void
		{
			for (var i:int = 0; i < STAT_MNGR.enabledCharacterSkinsVec.length; i++)
			{
				var characterSkins:Vector.<Boolean> = STAT_MNGR.enabledCharacterSkinsVec[i];
				for (var j:int = 0; j <  characterSkins.length; j++)
					characterSkins[j] = false;
			}
			for (i = 0; i < BmdInfo.NUM_SKIN_SETS; i++)
				STAT_MNGR.enabledSkinSetsVec[i] = false;
		}

		// begin disable skin shortcuts
		public static function enableAllSkinsExceptInvisible():void
		{
			for (var i:int = 0; i < STAT_MNGR.enabledCharacterSkinsVec.length; i++)
			{
				var characterSkins:Vector.<Boolean> = STAT_MNGR.enabledCharacterSkinsVec[i];
				for (var j:int = 0; j <  characterSkins.length; j++)
					characterSkins[j] = true;
			}
			for (i = 0; i < BmdInfo.NUM_SKIN_SETS; i++)
				STAT_MNGR.enabledSkinSetsVec[i] = true;

			disableInvisibleSkinSet();
		}

		public static function enable8BitSkinsOnly():void
		{
			var bmc:BmdSkinCont = null;

			// character skins
			for (var i:int = 0; i < STAT_MNGR.enabledCharacterSkinsVec.length; i++)
			{
				var characterSkins:Vector.<Boolean> = STAT_MNGR.enabledCharacterSkinsVec[i];
				for (var j:int = 0; j <  characterSkins.length; j++)
				{
					bmc = STAT_MNGR.getBmc(i, j);
					if (bmc.consoleType == ConsoleType.BIT_8 || bmc.consoleType == ConsoleType.GB)
						characterSkins[j] = true;
					else
						characterSkins[j] = false;
				}
			}

			// skin sets
			var bmcs:Vector.<BmdSkinCont> = BmdInfo.getBmcVec();
			for (i = 0; i < BmdInfo.NUM_SKIN_SETS; i++)
			{
				bmc = bmcs[i];
				if (bmc.consoleType == ConsoleType.BIT_8 || bmc.consoleType == ConsoleType.GB)
					STAT_MNGR.enabledSkinSetsVec[i] = true;
				else
					STAT_MNGR.enabledSkinSetsVec[i] = false;
			}

			disableAtariSkins();
			disableSharpX1Skins();
			disableInvisibleSkinSet();
		}

		public static function enable16BitSkinsOnly():void
		{
			var bmc:BmdSkinCont = null;

			// character skins
			for (var i:int = 0; i < STAT_MNGR.enabledCharacterSkinsVec.length; i++)
			{
				var characterSkins:Vector.<Boolean> = STAT_MNGR.enabledCharacterSkinsVec[i];
				for (var j:int = 0; j <  characterSkins.length; j++)
				{
					bmc = STAT_MNGR.getBmc(i, j);
					if (bmc.consoleType == ConsoleType.BIT_16)
						characterSkins[j] = true;
					else
						characterSkins[j] = false;
				}
			}

			// skin sets
			var bmcs:Vector.<BmdSkinCont> = BmdInfo.getBmcVec();
			for (i = 0; i < BmdInfo.NUM_SKIN_SETS; i++)
			{
				bmc = bmcs[i];
				if (bmc.consoleType == ConsoleType.BIT_16)
					STAT_MNGR.enabledSkinSetsVec[i] = true;
				else
					STAT_MNGR.enabledSkinSetsVec[i] = false;
			}

			disableAtariSkins();
			disableInvisibleSkinSet();
		}

		public static function enableGameBoySkinsOnly():void
		{
			var bmc:BmdSkinCont = null;

			// character skins
			for (var i:int = 0; i < STAT_MNGR.enabledCharacterSkinsVec.length; i++)
			{
				var characterSkins:Vector.<Boolean> = STAT_MNGR.enabledCharacterSkinsVec[i];
				for (var j:int = 0; j <  characterSkins.length; j++)
				{
					bmc = STAT_MNGR.getBmc(i, j);
					if (bmc.consoleType == ConsoleType.GB)
						characterSkins[j] = true;
					else
						characterSkins[j] = false;
				}
			}

			// skin sets
			var bmcs:Vector.<BmdSkinCont> = BmdInfo.getBmcVec();
			for (i = 0; i < BmdInfo.NUM_SKIN_SETS; i++)
			{
				bmc = bmcs[i];
				if (bmc.consoleType == ConsoleType.GB)
					STAT_MNGR.enabledSkinSetsVec[i] = true;
				else
					STAT_MNGR.enabledSkinSetsVec[i] = false;
			}
			disableSharpX1Skins();
			disableAtariSkins();
			disableInvisibleSkinSet();
		}

		public static function enableSharpX1SkinsOnly():void
		{
			disableAllSkins();

			for (var i:int = 0; i < Character.NUM_CHARACTERS; i++)
				STAT_MNGR.enabledCharacterSkinsVec[i][Character.getSpecialSkinNumber(i)] = true;

			STAT_MNGR.enabledCharacterSkinsVec[Bill.CHAR_NUM][Bill.SKIN_LANCE_X1] = true; // lance
			STAT_MNGR.enabledSkinSetsVec[BmdInfo.SKIN_NUM_SMB_SPECIAL] = true;
		}

		public static function enableAtariSkinsOnly():void
		{
			disableAllSkins();

			for (var i:int = 0; i < Character.NUM_CHARACTERS; i++)
				STAT_MNGR.enabledCharacterSkinsVec[i][Character.getAtariSkinNumber(i)] = true;

			STAT_MNGR.enabledCharacterSkinsVec[Bill.CHAR_NUM][Bill.SKIN_LANCE_ATARI] = true; // lance
			STAT_MNGR.enabledSkinSetsVec[BmdInfo.SKIN_NUM_SMB_ATARI] = true;
		}

		public static function enableClassicSkinsOnly():void
		{
			disableAllSkins();

			for (var i:int = 0; i < Character.NUM_CHARACTERS; i++)
				STAT_MNGR.enabledCharacterSkinsVec[i][0] = true;

			STAT_MNGR.enabledSkinSetsVec[BmdInfo.SKIN_NUM_SMB_NES] = true;
		}

		public static function enableClassic16BitSkinsOnly():void
		{
			disableAllSkins();

			for (var i:int = 0; i < Character.NUM_CHARACTERS; i++)
				STAT_MNGR.enabledCharacterSkinsVec[i][1] = true;

			STAT_MNGR.enabledSkinSetsVec[BmdInfo.SKIN_NUM_SMB_SNES] = true;
		}
	}
}
