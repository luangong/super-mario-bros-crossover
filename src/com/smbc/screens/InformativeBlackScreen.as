package com.smbc.screens
{
	import com.explodingRabbit.display.CustomMovieClip;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.SuperMarioBrosCrossover;
	import com.smbc.characters.Bill;
	import com.smbc.characters.Character;
	import com.smbc.characters.Link;
	import com.smbc.characters.Mario;
	import com.smbc.characters.MegaMan;
	import com.smbc.characters.Ryu;
	import com.smbc.characters.Samus;
	import com.smbc.characters.Simon;
	import com.smbc.characters.Sophia;
	import com.smbc.data.CampaignModes;
	import com.smbc.data.GameSettings;
	import com.smbc.data.GameStates;
	import com.smbc.data.MusicSets;
	import com.smbc.data.MusicType;
	import com.smbc.data.SoundNames;
	import com.smbc.errors.SingletonError;
	import com.smbc.graphics.AllCharactersCmc;
	import com.smbc.graphics.Background;
	import com.smbc.graphics.MushroomSelector;
	import com.smbc.graphics.TopScreenText;
	import com.smbc.graphics.fontChars.FontCharHud;
	import com.smbc.graphics.fontChars.FontCharMenu;
	import com.smbc.interfaces.IKeyPressable;
	import com.smbc.level.Level;
	import com.smbc.level.LevelData;
	import com.smbc.main.GlobVars;
	import com.smbc.main.GlobalFunctions;
	import com.smbc.managers.ButtonManager;
	import com.smbc.managers.EventManager;
	import com.smbc.managers.GameStateManager;
	import com.smbc.managers.GraphicsManager;
	import com.smbc.managers.ScreenManager;
	import com.smbc.managers.SoundManager;
	import com.smbc.managers.StatManager;
	import com.smbc.managers.TextManager;
	import com.smbc.messageBoxes.CampaignModeMenu;
	import com.smbc.messageBoxes.MessageBox;
	import com.smbc.messageBoxes.MessageBoxSounds;
	import com.smbc.sound.MusicEffect;
	import com.smbc.sound.MusicInfo;
	import com.smbc.text.TextFieldContainer;

	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;

	[Embed(source="../assets/swfs/SmbcGraphics.swf", symbol="InformativeBlackScreen")]
	public class InformativeBlackScreen extends Sprite implements IKeyPressable
	{
		public static const SCREEN_TYPE_GAME_OVER:String = "gameOver";
		public static const SCREEN_TYPE_PRE_LEVEL:String = "preLevel";
		public static const SCREEN_TYPE_TIME_UP:String = "timeUp";
		private const DUR_TMR_DUR_DEFAULT_GAME_OVER:int = 3000;
		private const DUR_TMR_PRE_LEVEL_DEFAULT:int = 2500;// real time is 2500, just changed for faster loading
		private const DUR_TMR_DUR_TIME_UP:int = 2500;
		private const END_DUR_PRELEVEL_BILL:int = 2200;
		private const END_DUR_PRELEVEL_LINK:int = 1800;
		private const END_DUR_PRELEVEL_MARIO:int = 2000;
		private const END_DUR_PRELEVEL_MEGA_MAN:int = 2000;
		private const END_DUR_PRELEVEL_RYU:int = 1500;
		private const END_DUR_PRELEVEL_SAMUS:int = 2000;
		private const END_DUR_PRELEVEL_SIMON:int = 2000;
		private const END_DUR_PRELEVEL_SOPHIA:int = 2500;
		private static const PRELEVEL_DEFAULT_ALL_CHARS:int = 2000;
		private const END_DUR_GAME_OVER_BILL:int = 6000;
		private const END_DUR_GAME_OVER_LINK:int = DUR_TMR_DUR_DEFAULT_GAME_OVER;
		private const END_DUR_GAME_OVER_MARIO:int = 4500;
		private const END_DUR_GAME_OVER_MEGA_MAN:int = DUR_TMR_DUR_DEFAULT_GAME_OVER;
		private const END_DUR_GAME_OVER_RYU:int = 4000;
		private const END_DUR_GAME_OVER_SAMUS:int = DUR_TMR_DUR_DEFAULT_GAME_OVER;
		private const END_DUR_GAME_OVER_SIMON:int = 4000;
		private static const END_DUR_GAME_OVER_SOPHIA:int = 4500;
		public static var instance:InformativeBlackScreen;
		private var durTmr:CustomTimer;
		private var _screenType:String;
		private const GAME:SuperMarioBrosCrossover = SuperMarioBrosCrossover.game;
		private const GS_MNGR:GameStateManager = GameStateManager.GS_MNGR;
		private const SCRN_MNGR:ScreenManager = ScreenManager.SCRN_MNGR;
		private const STAT_MNGR:StatManager = StatManager.STAT_MNGR;
		private const EVENT_MNGR:EventManager = EventManager.EVENT_MNGR;
		private const GS_CONTINUE_SELECT:String = GameStates.CONTINUE_SELECT;
		private const SND_MNGR:SoundManager = SoundManager.SND_MNGR;
		private const SELECTOR_BOTTOM_MARGIN:int = 6;
		private const SELECTOR_X_POS:int = 196;
		private var selectingYes:Boolean;
		// begin stage vars
		public var tsTxtStg:TopScreenText;
		// GAME_OVER
		public var continueTxtStg:TextField;
		public var gameOverTxtStg:TextField;
		public var noTxtStg:TextField;
		private var selector:MushroomSelector;
		public var yesTxtStg:TextField;
		// PRE_LEVEL
		public var livesDispTxtStg:TextField;
		public var worldDispTxtStg:TextField;
		public var timesSymbolStg:Sprite;
		// TIME_UP
		public var timeUpTxtStg:TextField;
		// end stage vars
		private var continueTfc:TextFieldContainer;
		private var gameOverTfc:TextFieldContainer;
		private var noTfc:TextFieldContainer;
		private var yesTfc:TextFieldContainer;
		private var livesDispTfc:TextFieldContainer;
		private var timeUpTfc:TextFieldContainer;
		private var worldDispTfc:TextFieldContainer;
		private var timesTfc:TextFieldContainer;
		private static const TIMES_TFC_PNT:Point = new Point(242,224);
		private static const LIVES_TFC_PNT:Point = new Point(269,225);
		private const COLOR_PINK:uint = GlobVars.COLOR_PINK;
		private const COLOR_WHITE:uint = GlobVars.COLOR_WHITE;
		private var txtMngr:TextManager = TextManager.INSTANCE;

		public function InformativeBlackScreen(_screenTypeTmp:String)
		{
			super();
			if (instance != null)
				throw new SingletonError();
			instance = this;
			_screenType = _screenTypeTmp;
			if (tsTxtStg && contains(tsTxtStg) )
				removeChild(tsTxtStg);
//			tsTxtStg = TopScreenText.instance;
//			tsTxtStg.hideTime();
			if (_screenType == SCREEN_TYPE_GAME_OVER)
			{
				clearPreLevelElements();
				clearTimeUpElements();
				continueTfc = new TextFieldContainer(FontCharMenu.FONT_NUM,FontCharMenu.TYPE_CREDITS);
				txtMngr.replaceStageTextField(continueTxtStg,continueTfc,this);
				continueTxtStg = null;
				gameOverTfc = new TextFieldContainer(FontCharHud.FONT_NUM);
				txtMngr.replaceStageTextField(gameOverTxtStg,gameOverTfc,this);
				gameOverTxtStg = null;
				noTfc = new TextFieldContainer(FontCharMenu.FONT_NUM);
				txtMngr.replaceStageTextField(noTxtStg,noTfc,this);
				noTxtStg = null;
				yesTfc = new TextFieldContainer(FontCharMenu.FONT_NUM);
				txtMngr.replaceStageTextField(yesTxtStg,yesTfc,this);
				yesTxtStg = null;
			}
			else if (_screenType == SCREEN_TYPE_PRE_LEVEL)
			{
				clearGameOverElements();
				clearTimeUpElements();
				livesDispTfc = new TextFieldContainer(FontCharHud.FONT_NUM);
				txtMngr.replaceStageTextField(livesDispTxtStg,livesDispTfc,this);
				livesDispTxtStg = null;
				worldDispTfc = new TextFieldContainer(FontCharHud.FONT_NUM);
				txtMngr.replaceStageTextField(worldDispTxtStg,worldDispTfc,this);
				worldDispTxtStg = null;

			}
			else if (_screenType == SCREEN_TYPE_TIME_UP)
			{
				clearGameOverElements();
				clearPreLevelElements();
				timeUpTfc = new TextFieldContainer(FontCharHud.FONT_NUM);
				txtMngr.replaceStageTextField(timeUpTxtStg,timeUpTfc,this);
				timeUpTxtStg = null;
			}
			addChild(TopScreenText.instance);
			TopScreenText.instance.initiateBlackScreen();
		}
		public function initiate():void
		{
			GS_MNGR.lockGameState = false;
			if (GS_MNGR.gameState != GameStates.BLACK_SCREEN)
				GS_MNGR.gameState = GameStates.BLACK_SCREEN;
			GAME.addChild(this);
			if (_screenType == SCREEN_TYPE_GAME_OVER)
			{
				removeChild(continueTfc);
				removeChild(yesTfc);
				removeChild(noTfc);
				if ( selector && contains(selector) )
					removeChild(selector);
				var durTmrDurGameOver:int = DUR_TMR_DUR_DEFAULT_GAME_OVER;
				//SND_MNGR.playSoundNow(SoundNames.MFX_GAME_GAME_OVER);
				SND_MNGR.changeMusic( MusicType.GAME_OVER );
				switch( SND_MNGR.getMusicCharName() )
				{
					case Bill.CHAR_NAME_CAPS:
					{
						durTmrDurGameOver = END_DUR_GAME_OVER_BILL;
						break;
					}
					case Link.CHAR_NAME_CAPS:
					{
						durTmrDurGameOver = END_DUR_GAME_OVER_LINK;
						break;
					}
					case Mario.CHAR_NAME_CAPS:
					{
						durTmrDurGameOver = END_DUR_GAME_OVER_MARIO;
						break;
					}
					case MegaMan.CHAR_NAME_CAPS:
					{
						durTmrDurGameOver = END_DUR_GAME_OVER_MEGA_MAN;
						break;
					}
					case Ryu.CHAR_NAME_CAPS:
					{
						durTmrDurGameOver = END_DUR_GAME_OVER_RYU;
						break;
					}
					case Samus.CHAR_NAME_CAPS:
					{
						durTmrDurGameOver = END_DUR_GAME_OVER_SAMUS;
						break;
					}
					case Simon.CHAR_NAME_CAPS:
					{
						durTmrDurGameOver = END_DUR_GAME_OVER_SIMON;
						break;
					}
					case Sophia.CHAR_NAME_CAPS:
					{
						durTmrDurGameOver = END_DUR_GAME_OVER_SOPHIA;
						break;
					}
				}
				durTmr = new CustomTimer(durTmrDurGameOver,1);
				durTmr.addEventListener(TimerEvent.TIMER_COMPLETE,durTmrLsr,false,0,true);
				durTmr.start();
			}
			else if (_screenType == SCREEN_TYPE_PRE_LEVEL)
			{
//				if (GameSettings.campaignMode == CampaignModes.SINGLE_CHARACTER_RANDOM)
//				{
//					STAT_MNGR.setRandomCharNum();
//				}
				var cNum:int = STAT_MNGR.curCharNum;
				var cName:String = STAT_MNGR.convNumToName(cNum);
				var endDur:int = PRELEVEL_DEFAULT_ALL_CHARS;
				TopScreenText.instance.updNameDispTxt();
				/*if (cName == Bill.CHAR_NAME)
				{
					endDur = END_DUR_PRELEVEL_BILL;
					SND_MNGR.musicPlayer.fadeOut(.1,END_DUR_PRELEVEL_BILL - 200);
				}
				else if (cName == Link.CHAR_NAME)
					endDur = END_DUR_PRELEVEL_LINK;
				else if (cName == Mario.CHAR_NAME)
				{
					endDur = END_DUR_PRELEVEL_MARIO;
					SND_MNGR.musicPlayer.fadeOut(.05);
				}
				else if (cName == MegaMan.CHAR_NAME)
					endDur = END_DUR_PRELEVEL_MEGA_MAN;
				else if (cName == Ryu.CHAR_NAME)
					endDur = END_DUR_PRELEVEL_RYU;
				else if (cName == Samus.CHAR_NAME)
				{
					endDur = END_DUR_PRELEVEL_SAMUS;
					SND_MNGR.musicPlayer.fadeOut(.035,END_DUR_PRELEVEL_SAMUS - 1000);
				}
				else if (cName == Simon.CHAR_NAME)
					endDur = END_DUR_PRELEVEL_SIMON;
				else if (cName == Sophia.CHAR_NAME)
				{
					endDur = END_DUR_PRELEVEL_SOPHIA;
					var ms:int = GameSettings.musicSet;
					var ld:LevelData = LevelData.instance;
					var parser:LevelDataParser = LevelDataParser.instance;
					var levStr:String = STAT_MNGR.curFullLevStr;
					var lm:int = parser.getSpecificLevelMusic( int(levStr.charAt(0)),int(levStr.charAt(2)),levStr.charAt(3));
					var bgc:int = parser.getBackground();
//					if ( !(lm == MusicType.OVER_WORLD && bgc == Background.COLOR_SKY_BLUE && (ms == MusicSets.SOPHIA || ms == MusicSets.CHARACTER) ) )
//						SND_MNGR.musicPlayer.fadeOut(.018);
				}*/
				if (GameSettings.campaignMode == CampaignModes.SINGLE_CHARACTER)
					endDur = DUR_TMR_PRE_LEVEL_DEFAULT;
				else
					SND_MNGR.curMusicPlayer.fadeOut(endDur - 500,500);
				timesTfc = new TextFieldContainer(FontCharHud.FONT_NUM);
				timesTfc.text = "*";
				addChild(timesTfc);
				timesTfc.x = TIMES_TFC_PNT.x;
				timesTfc.y = TIMES_TFC_PNT.y;
				livesDispTfc.x = LIVES_TFC_PNT.x;
				livesDispTfc.y = LIVES_TFC_PNT.y;
//				trace("======livestfc.x: "+livesDispTfc.x+" y: "+livesDispTfc.y);
				if (GameSettings.DEBUG_MODE && GameSettings.noLoading)
					endDur = 1;
				durTmr = new CustomTimer(endDur,1);
				durTmr.addEventListener(TimerEvent.TIMER_COMPLETE,durTmrLsr,false,0,true);
				durTmr.start();
//				var mcChar:CustomMovieClip = new CustomMovieClip(null,null,"Mario");
				var skinPreviews:Vector.<CustomMovieClip> = Character.getSkinPreviews(STAT_MNGR.curCharNum);

				var mcChar:CustomMovieClip = skinPreviews[STAT_MNGR.getCharSkinNum(STAT_MNGR.curCharNum)];
//				mcChar.gotoAndStop("jump");
				mcChar.gotoAndStop(STAT_MNGR.curCharNum + 1);
//				trace("mcChar.width: "+mcChar.width+" mcChar.height: "+mcChar.height);
				var bounds:Rectangle = MessageBox.getVisibleBounds(mcChar);
//				mcChar.x = 206 + mcChar.width/2;
//				mcChar.y = 234 + mcChar.height - bounds.height/2;
//				var previewSize:Point = Character.getSkinPreviewSize(STAT_MNGR.curCharNum);
				mcChar.x = 206 - mcChar.width/2;
				mcChar.y = 232 - mcChar.height + bounds.height/2;

//				trace("bounds: "+bounds.width+"x"+bounds.height+" normal: "+mcChar.width +"x"+mcChar.height);

				addChild(mcChar);
				worldDispTfc.text = "WORLD "+STAT_MNGR.currentLevelID.nameWithoutAreaDisplay;
				var numLives:int = STAT_MNGR.numLives;
				if (GameSettings.campaignMode == CampaignModes.SURVIVAL)
					numLives = 1;
				var livesStr:String;
				if (numLives < 10)
					livesStr = " "+numLives.toString();
				else
					livesStr = numLives.toString();
				livesDispTfc.text = livesStr;
				EVENT_MNGR.preLevelStart();
			}
			else if (_screenType == SCREEN_TYPE_TIME_UP)
			{
				durTmr = new CustomTimer(DUR_TMR_DUR_TIME_UP,1);
				durTmr.addEventListener(TimerEvent.TIMER_COMPLETE,durTmrLsr,false,0,true);
				durTmr.start();
			}
		}
		private function durTmrLsr(e:TimerEvent):void
		{
			durTmr.stop();
			durTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,durTmrLsr);
			durTmr = null;
			if (_screenType == SCREEN_TYPE_GAME_OVER)
			{
				removeChild(gameOverTfc);
				gameOverTfc = null;
				addChild(continueTfc);
				addChild(yesTfc);
				addChild(noTfc);
				selector = new MushroomSelector();
				addChild(selector);
				selector.y = yesTfc.y + SELECTOR_BOTTOM_MARGIN;
				selector.x = SELECTOR_X_POS;
				yesTfc.changeType(FontCharMenu.TYPE_SELECTED);
				noTfc.changeType(FontCharMenu.TYPE_NORMAL);
				selectingYes = true;
				GS_MNGR.gameState = GS_CONTINUE_SELECT;
			}
			else if (_screenType == SCREEN_TYPE_PRE_LEVEL)
			{
				cleanUp();
				trace("prelevel finished");
				SCRN_MNGR.preLevelScreenFinished();
			}
			else if (_screenType == SCREEN_TYPE_TIME_UP)
			{
				cleanUp();
				SCRN_MNGR.timeUpScreenFinished();
			}
		}
		private function clearGameOverElements():void
		{
			removeChild(continueTxtStg);
			continueTxtStg = null;
			removeChild(gameOverTxtStg);
			gameOverTxtStg = null;
			removeChild(yesTxtStg);
			yesTxtStg = null;
			removeChild(noTxtStg);
			noTxtStg = null;
			if (selector)
				removeChild(selector);
			selector = null;
		}
		private function clearPreLevelElements():void
		{
			removeChild(livesDispTxtStg);
			livesDispTxtStg = null;
			removeChild(timesSymbolStg);
			timesSymbolStg = null;
			removeChild(worldDispTxtStg);
			worldDispTxtStg = null;
		}
		private function clearTimeUpElements():void
		{
			removeChild(timeUpTxtStg);
			timeUpTxtStg = null;
		}
		private function setNewSelection():void
		{
			if (selectingYes)
			{
				selector.y = noTfc.y + SELECTOR_BOTTOM_MARGIN;
				noTfc.changeType(FontCharMenu.TYPE_SELECTED);
				yesTfc.changeType(FontCharMenu.TYPE_NORMAL);
				selectingYes = false;
			}
			else
			{
				selector.y = yesTfc.y + SELECTOR_BOTTOM_MARGIN;
				yesTfc.changeType(FontCharMenu.TYPE_SELECTED);
				noTfc.changeType(FontCharMenu.TYPE_NORMAL);
				selectingYes = true;
			}
			SND_MNGR.playSoundNow(MessageBoxSounds.SN_CHANGE_SELECTION);

		}
		private function makeSelection():void
		{
			GS_MNGR.lockGameState = false;
			GS_MNGR.gameState = GameStates.LOADING;
			cleanUp();
			if (selectingYes)
			{
				EVENT_MNGR.continueAfterDying();
				SND_MNGR.playSoundNow(MessageBoxSounds.SN_START_NEW_GAME);
			}
			else
			{
				EVENT_MNGR.restartGame();
				SND_MNGR.playSoundNow(MessageBoxSounds.SN_CANCEL_ITEM);
			}
		}
		public function pressUpBtn():void
		{
			if (GS_MNGR.gameState == GS_CONTINUE_SELECT)
				setNewSelection();
		}
		public function pressDwnBtn():void
		{
			if (GS_MNGR.gameState == GS_CONTINUE_SELECT)
				setNewSelection();
		}
		public function pressLftBtn():void
		{

		}
		public function pressRhtBtn():void
		{

		}
		public function pressJmpBtn():void
		{
			if (GS_MNGR.gameState == GS_CONTINUE_SELECT)
				makeSelection();
		}
		public function pressAtkBtn():void
		{

		}
		public function pressSpcBtn():void
		{

		}
		public function pressPseBtn():void
		{
			if (GS_MNGR.gameState == GS_CONTINUE_SELECT)
				makeSelection();
		}
		public function cleanUp():void
		{
			if (durTmr && durTmr.hasEventListener(TimerEvent.TIMER_COMPLETE))
				durTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,durTmrLsr);
			if (parent == GAME)
				GAME.removeChild(this);
			instance = null;
		}
		public function get screenType():String
		{
			return _screenType;
		}

	}
}
