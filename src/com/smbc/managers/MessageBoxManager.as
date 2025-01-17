package com.smbc.managers
{
	import __AS3__.vec.Vector;

	import com.smbc.data.Cheats;
	import com.smbc.data.GameStates;
	import com.smbc.errors.SingletonError;
	import com.smbc.events.CustomEvents;
	import com.smbc.interfaces.IInitiater;
	import com.smbc.level.CharacterSelect;
	import com.smbc.level.Level;
	import com.smbc.main.GlobVars;
	import com.smbc.messageBoxes.CharacterSelectBox;
	import com.smbc.messageBoxes.MenuBox;
	import com.smbc.messageBoxes.MessageBox;
	import com.smbc.messageBoxes.MessageBoxMessages;
	import com.smbc.messageBoxes.PauseMenu;
	import com.smbc.messageBoxes.PlainMessageBox;
	import com.smbc.messageBoxes.StartMenu;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	public final class MessageBoxManager extends MainManager implements IInitiater
	{
		public static const INSTANCE:MessageBoxManager = new MessageBoxManager();
		private static var instantiated:Boolean;
		private const DEF_POS_PNT:Point = new Point(GlobVars.STAGE_WIDTH/2,GlobVars.STAGE_HEIGHT/2);
		private var msgBx:PlainMessageBox;
		private var msgsToShowVec:Vector.<String>;
		private var oldPlayerStopAnim:Boolean;
		public var mainMenu:MenuBox;
		private const TUT_MNGR:TutorialManager = TutorialManager.TUT_MNGR;
		public var setBtnsDct:Dictionary;
		private var _lastMenuPosition:int;
		private var freezeGame:Boolean;
		private var playCheatSfx:Boolean;

		public function MessageBoxManager()
		{
			if (instantiated)
			{
				throw new SingletonError();
				return;
			}
			instantiated = true;
		}
		public function updateVars():void
		{
			level = Level.levelInstance;
			player = level.player;
		}
		public function createPlainMessageBox(msg:String):void
		{
			//if (pos == null)
			//	pos = DEF_POS_PNT;
		}
		public function tutorialStart(msgVec:Vector.<String>,freezeGame:Boolean = true):void
		{
			if (Level.levelInstance is CharacterSelect)
				freezeGame = false;
			this.freezeGame = freezeGame;
//			if (msgVec.length > 1)
//			{
				if (!msgsToShowVec)
				{
					msgsToShowVec = new Vector.<String>();
					msgsToShowVec = msgsToShowVec.concat(msgVec.concat());
					createTutorialMessagebox(msgsToShowVec[0]);
				}
				else
				{
					msgsToShowVec = msgsToShowVec.concat(msgVec.concat());
				}
//			}
//			else
//			{
//				if (msgsToShowVec)
//					msgsToShowVec = msgsToShowVec.concat(msgVec.concat());
//				createTutorialMessagebox(msgVec[0]);
//			}
		}
		public function createMessageBoxSeries(msgVec:Vector.<String>,freezeGame:Boolean,playCheatSfx:Boolean = false):void
		{
			this.playCheatSfx = playCheatSfx;
			tutorialStart(msgVec,freezeGame);
		}
		private function createTutorialMessagebox(msgStr:String):void
		{
			msgBx = new PlainMessageBox(msgStr);
			msgBx.tutorial = true;
			var currentBox:MessageBox = MessageBox.activeInstance;
			if (currentBox is PlainMessageBox && (currentBox as PlainMessageBox).msgStr == msgStr)
				return;
			if (playCheatSfx && msgStr.indexOf(MessageBoxMessages.UNLOCKED_CHEAT_PRETEXT) != -1)
				sndMngr.playSoundNow(Cheats.SN_ACTIVATE_CHEAT);
			if (currentBox && currentBox != CharacterSelectBox.instance)
				currentBox.nextMsgBxToCreate = msgBx;
			else
				msgBx.initiate();
			if (level && freezeGame)
			{
				level.freezeGame();
				oldPlayerStopAnim = player.stopAnim;
				player.stopAnim = true;
			}
		}
		// called by messageBox.destroy();
		public function tutorialEnd():void
		{
			if (msgsToShowVec)
			{
				msgsToShowVec.shift();
				if (msgsToShowVec.length > 0)
				{
					createTutorialMessagebox(msgsToShowVec[0]);
					return;
				}
				else
					msgsToShowVec = null;
			}
			playCheatSfx = false;
			msgBx = null;
			btnMngr.activeMsgBx = null;
			if (level && freezeGame )
			{
				level.unfreezeGame();
				player.stopAnim = oldPlayerStopAnim;
				oldPlayerStopAnim = false;
			}
			dispatchEvent(new Event(CustomEvents.MESSAGE_BOX_SERIES_END));
		}
		public function writeNextMainMenu(mb:MessageBox, rememberPosition:Boolean = true):void
		{
			var index:int = 0;
			if (gsMngr.gameState == GameStates.PAUSE)
			{
				if (rememberPosition)
					index = PauseMenu.lastIndex;
				mb.nextMsgBxToCreate = new PauseMenu(index);
			}
			else
			{
				if (rememberPosition)
					index = StartMenu.lastIndex;
				mb.nextMsgBxToCreate = new StartMenu(index);
			}
		}
		public function resetLastMenuPosition():void
		{
			_lastMenuPosition = 0;
		}
		public function saveLastMenuPosition():void // must be called while MenuBox.activeMenu has not been reset
		{
			if (MenuBox.activeMenu != null)
			_lastMenuPosition = MenuBox.activeMenu.cSelNum;
		}
		public function removeAllMessageBoxes():void
		{
			var n:int = GlobVars.STAGE.numChildren;
			for (var i:int = 0; i < n; i++)
			{
				var mc:DisplayObject = GlobVars.STAGE.getChildAt(i);
				if (mc is MessageBox)
				{
					with (mc as MessageBox)
					{
						nextMsgBxToCreate = null;
						nextMsgBxToFocus = null;
						cancel();
					}
				}
			}
		}
		public function get lastMenuPosition():int
		{
			return _lastMenuPosition;
		}
	}
}
