package com.smbc.messageBoxes
{
	import com.explodingRabbit.utils.KeyCodeToString;
	import com.smbc.data.CampaignModes;
	import com.smbc.data.GameSettings;
	import com.smbc.data.OnlineData;
	import com.smbc.events.CustomEvents;
	import com.smbc.graphics.MushroomSelector;
	import com.smbc.graphics.fontChars.FontCharMenu;
	import com.smbc.interfaces.IMessageBoxSelectable;
	import com.smbc.main.GlobVars;
	import com.smbc.managers.ScreenManager;
	import com.smbc.managers.SoundManager;
	import com.smbc.managers.StatManager;
	import com.smbc.text.TextFieldContainer;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class PlainMessageMenuBox extends PlainMessageBox implements IMessageBoxSelectable
	{
		public static const SET_BUTTONS_START_NAME:String = "setButtonsStart";
		public static const SET_BUTTONS_END_NAME:String = "setButtonsEnd";
		private var strVec:Vector.<String> = new Vector.<String>();
		private const ITEM_VEC:Vector.<TextFieldContainer> = new Vector.<TextFieldContainer>();
		protected const SPACE_BTWN_ITEMS:int = 12;
		protected const LEFT_MARGIN:int = 15;
		protected const ITEM_TXT_TOP_PADDING:int = 30;
		protected const SELECTOR_LEFT_MARGIN:int = MenuBox.SELECTOR_LEFT_MARGIN;
		protected const SELECTOR_BOTTOM_MARGIN:int = MenuBox.SELECTOR_BOTTOM_MARGIN;
		protected const SELECTOR_RIGHT_PADDING:int = 10;
		protected const SELECTOR:Sprite = new MushroomSelector();
		protected const GAMEPAD_INFO_URL:String = "http://www.explodingrabbit.com/games/super-mario-bros-crossover/how-to-play-with-a-gamepad";
		protected const VISIT_WEBSITE_URL:String = "http://www.explodingrabbit.com";
		protected const VIEW_WIKI:String = "http://www.explodingrabbit.com/wiki/Super_Mario_Bros._Crossover";
		protected const SUPER_RETRO_SQUAD_URL:String = "http://www.explodingrabbit.com/games/super-retro-squad";
		public static const BLANK_PAGE:String = "_blank";
		protected const SN_CHANGE_SELECTION:String = MessageBoxSounds.SN_CHANGE_SELECTION;
		protected var cSelNum:int;
		protected var C_SEL_NUM_MIN:int = 0;
		protected var cSelNumMax:int;
		protected var itemVecLen:int;
		private const COLOR_WHITE:uint = 0xFFFFFFFF;
		private const COLOR_PINK:uint = 0xFFFFCEC7;
		private const SND_MNGR:SoundManager = SoundManager.SND_MNGR;
		private var madeFirstSelection:Boolean;

		public function PlainMessageMenuBox(msg:String,strVec:Vector.<String>,initialSelection:int = 0)
		{
			this.strVec = strVec.concat();
			super(msg);
			cSelNum = initialSelection;
		}
		override public function initiate():void
		{
			super.initiate();
			setUpSelector();
		}
		override protected function setUpText():void
		{
			if (mbName == SET_BUTTONS_START_NAME)
				replaceButtonStrings(false);
			else if (mbName == SET_BUTTONS_END_NAME)
				replaceButtonStrings(true);
			super.setUpText();
			var n:int = strVec.length;
			var txtForm:TextFormat = GlobVars.TF_MAIN;
			for (var i:int = 0; i < n; i++)
			{
				var txtStr:String = strVec[i];
				var txtFld:TextFieldContainer = new TextFieldContainer(FontCharMenu.FONT_NUM);
				with (txtFld)
				{
					defaultTextFormat = txtForm;
					selectable = false;
					embedFonts = true;
					multiline = false;
					autoSize = TextFieldAutoSize.LEFT;
					wordWrap = false;
					text = txtStr;
//					filters = [GlobVars.TXT_DROP_SHADOW];
					// didn't feel like figuring out formula... hard-coded for only two items
					if (i == 0)
						x = MSG_TXT.width*.25 - width/2;
					else if (i == 1)
						x = MSG_TXT.width*.75 - width/2;
					y = MSG_TXT.y + MSG_TXT.height + ITEM_TXT_TOP_PADDING;
				}
				TXT_CONT.addChild(txtFld);
				ITEM_VEC.push(txtFld);
			}
			strVec = null;
			ITEM_VEC.fixed = true;
			itemVecLen = ITEM_VEC.length;
			cSelNumMax = itemVecLen - 1;

			//TXT_CONT.x += LEFT_MARGIN;
		}
		protected function setUpSelector():void
		{
			SELECTOR.y = ITEM_VEC[0].y + SELECTOR_BOTTOM_MARGIN;
			TXT_CONT.addChild(SELECTOR);
			setNewSelection(cSelNum);
			madeFirstSelection = true;
		}
		protected function setNewSelection(nSelNum:int):void
		{
			var lTxt:TextFieldContainer = ITEM_VEC[cSelNum];
			lTxt.changeType(FontCharMenu.TYPE_NORMAL);
			cSelNum = nSelNum;
			var cTxt:TextFieldContainer = ITEM_VEC[cSelNum];
			SELECTOR.x = cTxt.x - SELECTOR_RIGHT_PADDING;
			cTxt.changeType(FontCharMenu.TYPE_SELECTED);
			if (madeFirstSelection)
				SND_MNGR.playSoundNow(SN_CHANGE_SELECTION);
		}
		protected function chooseItem(cItem:String):void
		{
			var yes:Boolean = false;
			var forceYesSound:Boolean = false;
			var statManager:StatManager = StatManager.STAT_MNGR;
			if (cItem == MenuBoxItems.OKAY || cItem == MenuBoxItems.YES || cItem == MenuBoxItems.SAVE)
				yes = true;
			switch (_msgStr)
			{
				case MessageBoxMessages.GAME_PAD_INFO_MSG_1:
				{
					if (yes)
						navigateToURL(new URLRequest(GAMEPAD_INFO_URL),BLANK_PAGE);
					break;
				}
				case MessageBoxMessages.VISIT_WEBSITE_MSG_1:
				{
					if (yes)
						navigateToURL(new URLRequest(VISIT_WEBSITE_URL),BLANK_PAGE);
					break;
				}
				case MessageBoxMessages.VIEW_WIKI_MSG:
				{
					if (yes)
						navigateToURL(new URLRequest(VIEW_WIKI),BLANK_PAGE);
					break;
				}
				case MessageBoxMessages.NEW_VERSION_AVAILABLE:
				{
					if (yes)
					{
						navigateToURL(new URLRequest(OnlineData.gameUrl),BLANK_PAGE);
						nextMsgBxToCreate = null;
					}
					else if (nextMsgBxToCreate == null && statManager.fileRef == null) // load
						statManager.loadSaveData();
					break;
				}
//				case MessageBoxMessages.SUPER_RETRO_SQUAD_MSG:
//				{
//					if (yes)
//						navigateToURL(new URLRequest(SUPER_RETRO_SQUAD_URL),BLANK_PAGE);
//					break;
//				}
				case MessageBoxMessages.FULL_SCREEN_ONLY_AVAILABLE_ON_DEVELOPER_WEBSITE:
				{
					if (yes)
						navigateToURL(new URLRequest(OnlineData.gameUrl),BLANK_PAGE);
					break;
				}
				case MessageBoxMessages.CANCEL_REVIVE:
				{
					if (yes)
						CharacterSelectBox.instance.confirmCancelRevive();
					break;
				}
				case MessageBoxMessages.LOAD_SAVE_MSG:
				{
					if (yes)
					{
						if (statManager.fileRef == null)
							statManager.saveData();
					}
					else if (statManager.fileRef == null)
						statManager.loadSaveData();
					forceYesSound = true;
					break;
				}
				case MessageBoxMessages.QUIT_GAME_CONFIRM:
				{
					if (yes)
					{
						EVENT_MNGR.restartGame();
						nextMsgBxToCreate = null;
					}
					else
						MSG_BX_MNGR.writeNextMainMenu(this);
					break;
				}
				case MessageBoxMessages.TUTORIALS_ARE_ON: // this calls return instead of break
				{
					if (!yes)
					{
						GameSettings.changeTutorials(0);
						forceYesSound = true;
					}
					cancel();
					//SND_MNGR.playSoundNow(MessageBoxSounds.SN_CHOOSE_ITEM);
					dispatchEvent( new Event( CustomEvents.MSG_BX_CHOOSE_ITEM + cItem) );
					if (GameSettings.campaignMode != CampaignModes.SINGLE_CHARACTER_RANDOM)
						ScreenManager.SCRN_MNGR.forceShowCharacterSelectScreen = true;
					EVENT_MNGR.startNewGame();
					return;
				}
				default:
				{
					if (mbName == SET_BUTTONS_START_NAME)
					{
						if (yes)
						{
							nextMsgBxToCreate = MSG_BX_MNGR.setBtnsDct[MessageBoxMessages.SET_BUTTONS_LFT];
							BTN_MNGR.setButtons = true;
						}
					}
					else if (mbName == SET_BUTTONS_END_NAME)
					{
						nextMsgBxToCreate = new OptionsMenu();
						if (yes)
							BTN_MNGR.writeNewButtons();
						else
							BTN_MNGR.discardTempButtons();
					}
				}
			}
			if (yes || forceYesSound)
			{
				SND_MNGR.playSoundNow(MessageBoxSounds.SN_CHOOSE_ITEM);
			}
			else
				SND_MNGR.playSoundNow(MessageBoxSounds.SN_CANCEL_ITEM);
			dispatchEvent( new Event( CustomEvents.MSG_BX_CHOOSE_ITEM + cItem) );
			cancel(); // always executes
		}
		private function replaceButtonStrings(useTempValues:Boolean):void
		{
			if (useTempValues)
			{
				_msgStr = _msgStr.replace(MessageBoxMessages.SET_BUTTONS_LFT_REPLACE_STR,KeyCodeToString.convertKeyCode(BTN_MNGR.lftBtnKeyCodeTemp));
				_msgStr = _msgStr.replace(MessageBoxMessages.SET_BUTTONS_RHT_REPLACE_STR,KeyCodeToString.convertKeyCode(BTN_MNGR.rhtBtnKeyCodeTemp));
				_msgStr = _msgStr.replace(MessageBoxMessages.SET_BUTTONS_UP_REPLACE_STR,KeyCodeToString.convertKeyCode(BTN_MNGR.upBtnKeyCodeTemp));
				_msgStr = _msgStr.replace(MessageBoxMessages.SET_BUTTONS_DWN_REPLACE_STR,KeyCodeToString.convertKeyCode(BTN_MNGR.dwnBtnKeyCodeTemp));
				_msgStr = _msgStr.replace(MessageBoxMessages.SET_BUTTONS_JMP_REPLACE_STR,KeyCodeToString.convertKeyCode(BTN_MNGR.jmpBtnKeyCodeTemp));
				_msgStr = _msgStr.replace(MessageBoxMessages.SET_BUTTONS_ATK_REPLACE_STR,KeyCodeToString.convertKeyCode(BTN_MNGR.atkBtnKeyCodeTemp));
				_msgStr = _msgStr.replace(MessageBoxMessages.SET_BUTTONS_SPC_REPLACE_STR,KeyCodeToString.convertKeyCode(BTN_MNGR.spcBtnKeyCodeTemp));
				_msgStr = _msgStr.replace(MessageBoxMessages.SET_BUTTONS_PSE_REPLACE_STR,KeyCodeToString.convertKeyCode(BTN_MNGR.pseBtnKeyCodeTemp));
				_msgStr = _msgStr.replace(MessageBoxMessages.SET_BUTTONS_SEL_REPLACE_STR,KeyCodeToString.convertKeyCode(BTN_MNGR.selBtnKeyCodeTemp));
			}
			else
			{
				_msgStr = _msgStr.replace(MessageBoxMessages.SET_BUTTONS_LFT_REPLACE_STR,KeyCodeToString.convertKeyCode(BTN_MNGR.lftBtnKeyCode));
				_msgStr = _msgStr.replace(MessageBoxMessages.SET_BUTTONS_RHT_REPLACE_STR,KeyCodeToString.convertKeyCode(BTN_MNGR.rhtBtnKeyCode));
				_msgStr = _msgStr.replace(MessageBoxMessages.SET_BUTTONS_UP_REPLACE_STR,KeyCodeToString.convertKeyCode(BTN_MNGR.upBtnKeyCode));
				_msgStr = _msgStr.replace(MessageBoxMessages.SET_BUTTONS_DWN_REPLACE_STR,KeyCodeToString.convertKeyCode(BTN_MNGR.dwnBtnKeyCode));
				_msgStr = _msgStr.replace(MessageBoxMessages.SET_BUTTONS_JMP_REPLACE_STR,KeyCodeToString.convertKeyCode(BTN_MNGR.jmpBtnKeyCode));
				_msgStr = _msgStr.replace(MessageBoxMessages.SET_BUTTONS_ATK_REPLACE_STR,KeyCodeToString.convertKeyCode(BTN_MNGR.atkBtnKeyCode));
				_msgStr = _msgStr.replace(MessageBoxMessages.SET_BUTTONS_SPC_REPLACE_STR,KeyCodeToString.convertKeyCode(BTN_MNGR.spcBtnKeyCode));
				_msgStr = _msgStr.replace(MessageBoxMessages.SET_BUTTONS_PSE_REPLACE_STR,KeyCodeToString.convertKeyCode(BTN_MNGR.pseBtnKeyCode));
				_msgStr = _msgStr.replace(MessageBoxMessages.SET_BUTTONS_SEL_REPLACE_STR,KeyCodeToString.convertKeyCode(BTN_MNGR.selBtnKeyCode));
			}
		}
		override public function pressLftBtn():void
		{
			if (cSelNum == 0)
				setNewSelection(1);
			else if (cSelNum == 1)
				setNewSelection(0);
		}
		override public function pressRhtBtn():void
		{
			if (cSelNum == 0)
				setNewSelection(1);
			else if (cSelNum == 1)
				setNewSelection(0);
		}
		override public function pressJmpBtn():void
		{
			var txtStr:String = ITEM_VEC[cSelNum].text;
			chooseItem(txtStr);
		}
		override public function pressAtkBtn():void
		{
			if (nextMsgBxToCreate)
			{
				cancel();
				SND_MNGR.playSoundNow(MessageBoxSounds.SN_CANCEL_ITEM);
			}
		}
		override public function pressPseBtn():void
		{

		}
		override public function pressSpcBtn():void
		{

		}
	}
}
