package com.smbc.managers
{
	import com.explodingRabbit.utils.CustomDictionary;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.data.CampaignModes;
	import com.smbc.data.GameSettings;
	import com.smbc.data.GameStates;
	import com.smbc.data.LevelID;
	import com.smbc.data.OnlineData;
	import com.smbc.data.SoundNames;
	import com.smbc.errors.SingletonError;
	import com.smbc.interfaces.IManager;
	import com.smbc.level.FakeLevel;
	import com.smbc.level.TitleLevel;
	import com.smbc.messageBoxes.MenuBox;
	import com.smbc.messageBoxes.NotConnectedMessageBox;
	import com.smbc.messageBoxes.PauseMenu;
	import com.smbc.sound.BackgroundMusic;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public final class EventManager extends MainManager
	{
		public static const EVENT_MNGR:EventManager = new EventManager();
		private const MNGR_DCT:CustomDictionary = MainManager.MNGR_DCT;
		private static var instantiated:Boolean;
		private var dieTmr:CustomTimer;
		private var gsMsg:String;
		private const SFX_GAME_FLAG_POLE:String = SoundNames.SFX_GAME_FLAG_POLE;
		private var levelTransferDelTmr:Timer;
		private var levelToLoadArr:Array;

		public function EventManager()
		{
			if (instantiated)
				throw new SingletonError();
			instantiated = true;
		}
		public function getLevelVars():void
		{
			for each (var mngr:IManager in MNGR_DCT)
			{
				mngr.updateLevelRefs();
			}
		}
		public function characterSelectStart():void // called by CharacterSelectScreen after initiated
		{
			sndMngr.removeAllSounds();
			if (GameSettings.tutorials)
				tutMngr.characterSelect();
			statMngr.characterSelectStartHandler();
			btnMngr.characterSelectStartHandler();
		}
		public function selectedCharacter(curCharNum:int):void
		{
			statMngr.curCharNum = curCharNum;
			scrnMngr.selectedCharacterHandler();
		}
		public function titleLevelInitiate():void
		{
			btnMngr.titleLevelInitiateHandler();
		}
		public function titleLevelDestroy():void
		{
			btnMngr.titleLevelDestroyHandler();
		}
		public function preLevelStart():void
		{
			//sndMngr.removeBgm();
		}
		public function playerDie():void
		{
			statMngr.stopTimeLeft();
			if (gsMngr.lockGameState)
				gsMngr.lockGameState = false;
			gsMngr.gameState = "watch";
			gsMngr.lockGameState = true;
			sndMngr.removeAllSounds();
		}
		// must be called by player after he dies
		public function startDieTmr(dieTmrDur:int):void
		{
			if (dieTmr)
			{
				dieTmr.stop();
				dieTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,dieDurTmrLsr);
				dieTmr = null;
			}
			dieTmr = new CustomTimer(dieTmrDur,1);
			dieTmr.addEventListener(TimerEvent.TIMER_COMPLETE,dieDurTmrLsr,false,0,true);
			dieTmr.start();
			statMngr.stopTimeLeft();
		}
		private function dieDurTmrLsr(e:TimerEvent):void
		{
			dieTmr.stop();
			dieTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,dieDurTmrLsr);
			dieTmr = null;
			statMngr.playerDie();
			if (statMngr.showTimeUpScrn)
				scrnMngr.showTimeUpScreen();
			else
				checkGameOver();
		}
		public function checkGameOver():void
		{
			var cm:int = GameSettings.campaignMode;
			var ts:int = CampaignModes.SURVIVAL;
			if ( (cm != ts && statMngr.numLives > statMngr.NUM_LIVES_GAME_OVER)
				|| (cm == ts && !statMngr.checkPStateVecForAllZeroes() ) )
				level.reloadLevel();
			else
				gameOver();
		}
		public function gameOver():void
		{
			scrnMngr.gameOver();
		}
		public function continueAfterDying():void
		{
			statMngr.continueAfterDyingHandler();
			var id:LevelID = statMngr.currentLevelID;
			game.addChild( new FakeLevel() );
			scrnMngr.createLevel(id);
		}
		public function startNewGame():void
		{
			TitleLevel.allowRestart = false;
			tutMngr.startNewGameHandler();
			statMngr.startNewGameHandler();
			scrnMngr.startNewGameHandler();
		}
		// called by level after it is destroyed
		public function destroyLevel():void
		{
			for each (var mngr:IManager in MNGR_DCT)
			{
				mngr.clearLevelRefs();
			}
		}
		// called by player after entering pipe, climing vine, or falling into vine pit
		public function levelTransfer(newArea:String,_pExInt:int,delayTransferDur:int = 0):void
		{
			trace("newArea: "+newArea);
			if (delayTransferDur)
			{
				levelToLoadArr = [newArea,_pExInt];
				levelTransferDelTmr = new CustomTimer(delayTransferDur,1);
				levelTransferDelTmr.addEventListener(TimerEvent.TIMER_COMPLETE,levelTransferDelTmrHandler,false,0,true);
				levelTransferDelTmr.start();
				return;
			}
			if (newArea.length == 1)
				level.areaToLoadArr = [newArea,_pExInt];
			else
			{
				statMngr.passedHw = false;
				statMngr.warpPipeHandler();
				level.levelIDToLoad = LevelID.Create(newArea);
			}
		}
		private function levelTransferDelTmrHandler(event:TimerEvent):void
		{
			if (levelTransferDelTmr)
			{
				levelTransferDelTmr.stop();
				levelTransferDelTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,levelTransferDelTmrHandler);
				levelTransferDelTmr = null;
			}
			if (levelToLoadArr == null)
				return;
			levelTransfer(levelToLoadArr[0],levelToLoadArr[1]);
			levelToLoadArr = null;
		}
		// called by btnMngr when pause button is pressed while gamestate == "play"
		public function pauseGame():void
		{
			level.pauseGame();
			msgBxMngr.resetLastMenuPosition();
			var pMenu:PauseMenu = new PauseMenu();
			pMenu.initiate();
			sndMngr.pauseGame();
		}
		public function beatGame():void // called by screen manager when credits end
		{
			statMngr.beatGameHandler();
			//restartGame();
		}
		public function beatLevel(worldNum:int,levNum:int):void // called by level
		{
			//trace("beat level: "+worldNum+"-"+levNum);
			statMngr.beatLevelHandler(worldNum,levNum);
		}
		// called by MenuBox when it disappears
		public function unpauseGame():void
		{
			level.resumeGame();
			sndMngr.resumeGame();
		}
		// called by StatManager
		public function secondsLeftIntro():void
		{
			sndMngr.changeMusic(SoundNames.BGM_GAME_SECONDS_LEFT_INTRO);
			statMngr.secondsLeft = true;
		}
		// called by GameSecondsLeftIntroSnd
		public function secondsLeftStart():void
		{
			/*if (sndMngr.TURN_OFF_SOUND)
				return;*/
			/*sndMngr.removeBgm();
			if (player.starPwrBgmShouldBePlaying)
				sndMngr.starPwrStart();
			else
			{
				sndMngr.changeMusic(player.);
			}*/
			/*else
			{
				sndMngr.playSound(player.secondsLeftSnd);
				if (player.starPwrBgmShouldBePlaying)
					sndMngr.starPwrStart();
				else
				{
					sndMngr.changeBGM();
					sndMngr.bgm.playAtLoopNum();
				}
			}
			trace("starPwrBgm: "+player.starPwrBgmShouldBePlaying);*/
		}
		// called by ScrnMngr after credits are finished
		public function loadGame():void
		{
			var mb:MenuBox = MenuBox.activeMenu;
			if (mb)
			{
				mb.nextMsgBxToCreate = null;
				mb.cancel();
			}
			TitleLevel.allowRestart = false;
			if (level)
				level.destroyLevel();
			sndMngr.removeAllSounds();
			game.addChild( new FakeLevel() );
			statMngr.newLev = true;
			statMngr.passedHw = false;
			scrnMngr.createLevel(statMngr.currentLevelID);
		}
		public function restartGame():void
		{
			if (level)
				level.destroyLevel();
			sndMngr.removeAllSounds();
			statMngr.resetAllStats();
			statMngr.numContinuesUsed = 0;
			scrnMngr.restartGame();
		}
		// called by player
		public function enterLevelExit():void
		{
			if (level.flagPole != null) // not a castle level
				statMngr.convertTimeToScore();
		}
		// called by player and brick
		public function getCoin():void
		{
			statMngr.addCoin();
		}
		public function addPoints(points:uint):void
		{
			statMngr.addPoints(points);
		}
		// called by level.flagPole
		public function touchedFlagPole():void
		{
			gsMngr.lockGameState = false;
			gsMngr.gameState = GameStates.WATCH;
			gsMngr.lockGameState = true;
			level.destroyAllEnemiesAndProjectilesOnScreen();
			level.startBackupTouchLevelExitTmr();
			level.flagPole.touchPlayer(player);
			player.slideDownFlagPole();
			if ( !(level is TitleLevel) )
				sndMngr.removeAllSounds();
			sndMngr.playSound(SFX_GAME_FLAG_POLE);
			statMngr.touchFlag();
		}
		public function getAxe():void// called by player.getAxe();
		{
			level.startBackupTouchLevelExitTmr();
		}
		public function cleanUp():void
		{
			if (dieTmr && dieTmr.hasEventListener(TimerEvent.TIMER_COMPLETE))
				dieTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,dieDurTmrLsr);
		}
	}
}
