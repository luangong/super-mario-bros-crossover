package com.smbc.messageBoxes
{
	import __AS3__.vec.Vector;

	import com.explodingRabbit.utils.CustomDictionary;
	import com.smbc.characters.Samus;
	import com.smbc.characters.Simon;
	import com.smbc.data.CampaignModes;
	import com.smbc.data.Cheats;
	import com.smbc.data.GameSettings;
	import com.smbc.data.GameStates;
	import com.smbc.data.OnlineData;
	import com.smbc.data.SoundNames;
	import com.smbc.errors.SingletonError;
	import com.smbc.graphics.MushroomSelector;
	import com.smbc.graphics.fontChars.FontCharMenu;
	import com.smbc.interfaces.IMessageBoxSelectable;
	import com.smbc.level.Level;
	import com.smbc.main.GlobVars;
	import com.smbc.managers.GameStateManager;
	import com.smbc.managers.MainManager;
	import com.smbc.managers.ScreenManager;
	import com.smbc.managers.SoundManager;
	import com.smbc.managers.StatManager;
	import com.smbc.managers.TutorialManager;
	import com.smbc.sound.GameSecondsLeftIntroOverrideSnd;
	import com.smbc.sound.SoundLevels;
	import com.smbc.text.TextFieldContainer;

	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;

	public class MenuBox extends MessageBox implements IMessageBoxSelectable
	{
		public static var activeMenu:MenuBox;
		// [ item str, item value, textfield];
		protected const IND_ARR_VEC_NAME:int = 0;
		protected const IND_ARR_VEC_VALUE:int = 1;
		protected const IND_ARR_VEC_TEXT_FIELD:int = 2; // also used for name text string override
		protected const ARR_VEC:Vector.<Array> = new Vector.<Array>();
		public static const MAX_HEIGHT:int = 300; // 500
		//protected const ITEM_VEC:Vector.<TextField> = new Vector.<TextField>();
		protected const ITEM_TXT_TOP_PADDING:int = 30;
		protected const SPACE_BTWN_ITEMS:int = 34;
		public static const LEFT_MARGIN:int = 20;
		protected static var numItemsThatFitOnScreen:int = 9;
		public static const SELECTOR_LEFT_MARGIN:int = 8; // 8
		private static const SELECTOR_X_OFS_CENTER_TEXT:int = -40;
		public static const SELECTOR_BOTTOM_MARGIN:int = 8; // 16
		protected const VALUE_SEP:String = MenuBoxItems.VALUE_SEP;
		protected const ON_STR:String = MenuBoxItems.ON;
		protected const OFF_STR:String = MenuBoxItems.OFF;
		protected const EMPTY_STR:String = "";
		protected const SPACE_STR:String = " ";
		protected const SELECTOR:MushroomSelector = new MushroomSelector();
		protected var selectorStartIndex:int;
		protected var _cSelNum:int;
		protected var C_SEL_NUM_MIN:int = 0;
		protected var cSelNumMax:int;
		protected var numItems:int;
		private var txtContStartY:Number;
		private var resumeGame:Boolean;
		protected const COLOR_WHITE:uint = GlobVars.COLOR_WHITE;
		protected const COLOR_PINK:uint = GlobVars.COLOR_PINK;
		protected const COLOR_GRAY:uint = 0xFFAAAAAA;
		protected const STAT_MNGR:StatManager = StatManager.STAT_MNGR;
		protected const TUT_MNGR:TutorialManager = TutorialManager.TUT_MNGR;
		protected const SND_MNGR:SoundManager = SoundManager.SND_MNGR;
		protected var madeFirstSelection:Boolean;
		protected const SN_CHOOSE_ITEM:String = MessageBoxSounds.SN_CHOOSE_ITEM;
		protected const SN_CANCEL_ITEM:String = MessageBoxSounds.SN_CANCEL_ITEM;
		private var preTxtStr:String; // text displays before menu box items
		private var level:Level = Level.levelInstance;
		private var dscTxt:TextFieldContainer;
		private var centerChoices:Boolean;
//		protected var leftRightItems:CustomDictionary;

		public function MenuBox(arr:Array,selectorStartIndex:int = 0,txtContStartY:Number = NaN,centerChoices:Boolean = false,preTxtStr:String = null)
		{
			this.selectorStartIndex = selectorStartIndex;
			if ( !isNaN(txtContStartY) )
				this.txtContStartY = txtContStartY;
			// arr = [ name, value (optional), text string override (optional)];
			var n:int = arr.length;
			for (var i:int; i < n; i++)
			{
				ARR_VEC[i] = arr[i];
			}
			ARR_VEC.fixed = true;
			//strVec = strVecTemp.concat();
			this.preTxtStr = preTxtStr;
			this.centerChoices = centerChoices;
			super();
			maxHeight = MAX_HEIGHT;
		}
		override public function initiate():void
		{
//			if (activeMenu != null)
//				throw new SingletonError();
			activeMenu = this;
			super.initiate();
			setNewSelection(_cSelNum);
			madeFirstSelection = true;
			MSG_BX_MNGR.mainMenu = this;
		}
		private function setUpPreTxt():void
		{
			var txtForm:TextFormat = GlobVars.TF_MAIN;
			txtForm.leading = TXT_LEADING;
			dscTxt = new TextFieldContainer(FontCharMenu.FONT_NUM);
			with (dscTxt)
			{
//				defaultTextFormat = txtForm;
				selectable = false;
//				embedFonts = true;
				multiline = true;
//				autoSize = TextFieldAutoSize.LEFT;
//				width = endBoxWidth - CONTAINER_PADDING*2;
				//height = endBoxHeight - MSG_TXT_Y_OFFSET*2;
//				wordWrap = true;
				text = preTxtStr;
//				filters = [GlobVars.TXT_DROP_SHADOW];
			}
			TXT_CONT.addChild(dscTxt);
			//TXT_CONT.x = TXT_X_OFFSET;
			//TXT_CONT.y = TXT_Y_OFFSET;
		}
		override protected function setUpText():void
		{
			if (preTxtStr)
				setUpPreTxt();
			var n:int = ARR_VEC.length;
			var txtForm:TextFormat = GlobVars.TF_MAIN;
			var changeToGray:Boolean = false;
			var grayStr1:String = MenuBoxItems.NEW_GAME;
			var grayStr2:String = MenuBoxItems.LOAD_GAME;
			for (var i:int = 0; i < n; i++)
			{
				var arr:Array = ARR_VEC[i];
				var txtStr:String = arr[IND_ARR_VEC_NAME];
				var val:String = arr[IND_ARR_VEC_VALUE];
				var oRdTxtStr:String = arr[IND_ARR_VEC_TEXT_FIELD];
				if (oRdTxtStr != null)
					txtStr = oRdTxtStr;
				if (oRdTxtStr == null && val != null)
				{
					if (val === GlobVars.TRUE_STR)
						txtStr += VALUE_SEP + ON_STR;
					else if (val === GlobVars.FALSE_STR)
						txtStr += VALUE_SEP + OFF_STR;
					else
						txtStr += VALUE_SEP + val;
				}
				var tfc:TextFieldContainer = new TextFieldContainer(FontCharMenu.FONT_NUM);
				tfc.text = txtStr;
				tfc.y = SPACE_BTWN_ITEMS*i;
				if (dscTxt)
					tfc.y += dscTxt.height + ITEM_TXT_TOP_PADDING;
				if (centerChoices)
					tfc.x = TXT_CONT.width*.3;
				else
					tfc.x = LEFT_MARGIN;
				if ( ( changeToGray && (txtStr == grayStr1 || txtStr == grayStr2 ) ) || txtStr == MenuBoxItems.HIDDEN_CHEAT )
					tfc.changeType(FontCharMenu.TYPE_DISABLED);
				TXT_CONT.addChild(tfc);
//				trace("txt_cont: "+TXT_CONT.width);
				arr[IND_ARR_VEC_TEXT_FIELD] = tfc;
			}
			numItems = ARR_VEC.length;
			cSelNumMax = numItems - 1;
			TXT_CONT.x = CONTAINER_PADDING;
			TXT_CONT.y = CONTAINER_PADDING;
			setUpSelector();
//			if (!centerChoices)
//				TXT_CONT.x += LEFT_MARGIN;
		}
		protected function setUpSelector():void
		{
			SELECTOR.x = SELECTOR_LEFT_MARGIN;
			TXT_CONT.addChild(SELECTOR);
			_cSelNum = selectorStartIndex;
			if (!isNaN(txtContStartY))
				TXT_CONT.y = txtContStartY;
		}
		protected function getTfc(index:int):TextFieldContainer
		{
			return ARR_VEC[index][IND_ARR_VEC_TEXT_FIELD] as TextFieldContainer;
		}

		protected function setNewSelection(nSelNum:int):void
		{
			var arr:Array = ARR_VEC[_cSelNum];
			var lTxt:TextFieldContainer = arr[IND_ARR_VEC_TEXT_FIELD] as TextFieldContainer;
			if (lTxt.text == MenuBoxItems.HIDDEN_CHEAT)
				lTxt.changeType(FontCharMenu.TYPE_DISABLED);
			else
				lTxt.changeType(FontCharMenu.TYPE_NORMAL);
			_cSelNum = nSelNum;
			arr = ARR_VEC[_cSelNum];
			var cTxt:TextFieldContainer = arr[IND_ARR_VEC_TEXT_FIELD] as TextFieldContainer;
//			trace("cTxt: "+cTxt.text);
			SELECTOR.y = cTxt.y + SELECTOR_BOTTOM_MARGIN;
			if (centerChoices)
				SELECTOR.x = cTxt.x - 14;
//			trace("selector.x: "+SELECTOR.x+" selector.y: "+SELECTOR.y);
			cTxt.changeType(FontCharMenu.TYPE_SELECTED);
			if (madeFirstSelection)
				SND_MNGR.playSoundNow(MessageBoxSounds.SN_CHANGE_SELECTION);
			else if (!isNaN(txtContStartY))
				TXT_CONT.y = txtContStartY;
			var globY:Number = SELECTOR.localToGlobal(GlobVars.ZERO_PT).y;
			var yOffset:Number = 0;
			if (dscTxt)
				yOffset = dscTxt.height + ITEM_TXT_TOP_PADDING;
			if (contentMaskRect && globY > y + contentMaskRect.height + 10)
			{
				if (_cSelNum == numItems - 1)
					TXT_CONT.y =  -(numItems - numItemsThatFitOnScreen)*SPACE_BTWN_ITEMS + txtContDefY;
				else
					TXT_CONT.y -= SPACE_BTWN_ITEMS;
			}
			else if (globY < y)
			{
				if (_cSelNum == 0) // first item
					TXT_CONT.y = txtContDefY;
				else
					TXT_CONT.y += SPACE_BTWN_ITEMS;
			}

		}
	/*	protected function addOnOffOption(itemStr:String,value:Boolean,reverse:Boolean=false):Array
		{
			if (!reverse)
			{
				if (value)
					STR_VEC.push(itemStr + SPACE_ON);
				else
					STR_VEC.push(itemStr + SPACE_OFF);
			}
			else
			{
				if (value)
					STR_VEC.push(itemStr + SPACE_OFF);
				else
					STR_VEC.push(itemStr + SPACE_ON);
			}
		}*/
		protected function chooseItem(itemName:String, itemValue:String, itemTfc:TextFieldContainer, gsOvRdNum:int):void
		{
			if ( checkChoseLockedCheat(itemName,itemTfc.text) )
				return;
			var strVec:Vector.<String>;
			switch(itemName)
			{
				case (MenuBoxItems.QUICK_PLAY):
				{
					if (GameSettings.tutorials)
						GameSettings.changeTutorials(0);
					GameSettings.changeCampaignMode(CampaignModes.ALL_CHARACTERS);
					cancel();
					EVENT_MNGR.startNewGame();
					break;
				}
				case (MenuBoxItems.GAME_PAD_INFO) :
				{
					strVec = new Vector.<String>();
					strVec.push(MenuBoxItems.CANCEL);
					strVec.push(MenuBoxItems.OKAY);
					nextMsgBxToCreate = new PlainMessageMenuBox(MessageBoxMessages.GAME_PAD_INFO_MSG_1,strVec);
					MSG_BX_MNGR.writeNextMainMenu(nextMsgBxToCreate);
					cancel();
					SND_MNGR.playSoundNow(SN_CHOOSE_ITEM);
					break;
				}
				case (MenuBoxItems.LOAD_GAME) :
				{
					if (OnlineData.newVersionAvailable && !GameSettings.showedNewVersionAvailableMessage && !OnlineData.onOfficialWebsite)
					{
						GameSettings.showedNewVersionAvailableMessage = true;
						nextMsgBxToCreate = new PlainMessageMenuBox(MessageBoxMessages.NEW_VERSION_AVAILABLE, Vector.<String>([ MenuBoxItems.NO, MenuBoxItems.YES ]), 1);
						cancel();
					}
					else if (STAT_MNGR.fileRef == null)
						STAT_MNGR.loadSaveData();
					SND_MNGR.playSoundNow(SN_CHOOSE_ITEM);
					break;
				}
				case (MenuBoxItems.NEW_GAME) :
				{
					//nextMsgBxToCreate = new DifficultyMenu();
					if (OnlineData.newVersionAvailable && !GameSettings.showedNewVersionAvailableMessage)
					{
						GameSettings.showedNewVersionAvailableMessage = true;
						nextMsgBxToCreate = new PlainMessageMenuBox(MessageBoxMessages.NEW_VERSION_AVAILABLE, Vector.<String>([ MenuBoxItems.NO, MenuBoxItems.YES ]), 1);
						nextMsgBxToCreate.nextMsgBxToCreate = new NewGameOptionsMenu();
					}
					else
						nextMsgBxToCreate = new NewGameOptionsMenu();
//					GameSettings.resetDifficultySettings();
					cancel();
					SND_MNGR.playSoundNow(MessageBoxSounds.SN_START_NEW_GAME);
					break;
				}
				case (MenuBoxItems.RESUME_GAME) :
				{
					pressPseBtn();
					break;
				}
				case (MenuBoxItems.LOAD_SAVE_GAME) :
				{
					nextMsgBxToCreate = new PlainMessageMenuBox(MessageBoxMessages.LOAD_SAVE_MSG, Vector.<String>([ MenuBoxItems.LOAD, MenuBoxItems.SAVE ]));
					MSG_BX_MNGR.writeNextMainMenu(nextMsgBxToCreate);
					cancel();
					SND_MNGR.playSoundNow(SN_CHOOSE_ITEM);
					break;
				}
				case (MenuBoxItems.QUIT_GAME) :
				{
					strVec = new Vector.<String>();
					strVec.push(MenuBoxItems.CANCEL);
					strVec.push(MenuBoxItems.OKAY);
					nextMsgBxToCreate = new PlainMessageMenuBox(MessageBoxMessages.QUIT_GAME_CONFIRM,strVec);
					MSG_BX_MNGR.writeNextMainMenu(nextMsgBxToCreate);
					cancel();
					SND_MNGR.playSoundNow(SN_CHOOSE_ITEM);
					break;
				}
				case (MenuBoxItems.PLAY_NEW_VERSION) :
				{
					strVec = new Vector.<String>();
					strVec.push(MenuBoxItems.CANCEL);
					strVec.push(MenuBoxItems.OKAY);
					nextMsgBxToCreate = new PlainMessageMenuBox(MessageBoxMessages.VISIT_WEBSITE_MSG_1,strVec);
					MSG_BX_MNGR.writeNextMainMenu(nextMsgBxToCreate);
					cancel();
					SND_MNGR.playSoundNow(SN_CHOOSE_ITEM);
					break;
				}
				case (MenuBoxItems.VIEW_WIKI) :
				{
					strVec = new Vector.<String>();
					strVec.push(MenuBoxItems.CANCEL);
					strVec.push(MenuBoxItems.OKAY);
					nextMsgBxToCreate = new PlainMessageMenuBox(MessageBoxMessages.VIEW_WIKI_MSG,strVec);
					MSG_BX_MNGR.writeNextMainMenu(nextMsgBxToCreate);
					cancel();
					SND_MNGR.playSoundNow(SN_CHOOSE_ITEM);
					break;
				}
				case (MenuBoxItems.SUPER_RETRO_SQUAD) :
				{
					strVec = new Vector.<String>();
					strVec.push(MenuBoxItems.CANCEL);
					strVec.push(MenuBoxItems.OKAY);
					nextMsgBxToCreate = new PlainMessageMenuBox(MessageBoxMessages.SUPER_RETRO_SQUAD_MSG,strVec);
					MSG_BX_MNGR.writeNextMainMenu(nextMsgBxToCreate);
					cancel();
					SND_MNGR.playSoundNow(SN_CHOOSE_ITEM);
					break;
				}
				case (MenuBoxItems.LINKS):
				{
					nextMsgBxToCreate = new LinksMenu();
					MSG_BX_MNGR.writeNextMainMenu(nextMsgBxToCreate);
					cancel();
					SND_MNGR.playSoundNow(SN_CHOOSE_ITEM);
					break;
				}
				case (MenuBoxItems.OPTIONS):
				{
					nextMsgBxToCreate = new OptionsMenu();
					MSG_BX_MNGR.writeNextMainMenu(nextMsgBxToCreate);
					cancel();
					SND_MNGR.playSoundNow(SN_CHOOSE_ITEM);
					break;
				}
				case MenuBoxItems.VIEW_STATS:
				{
					nextMsgBxToCreate = new StatsMessageBox();
					MSG_BX_MNGR.writeNextMainMenu(nextMsgBxToCreate);
					cancel();
					SND_MNGR.playSoundNow(SN_CHOOSE_ITEM);
					break;
				}
				case (MenuBoxItems.CHEATS):
				{
					nextMsgBxToCreate = new CheatMenu();
					MSG_BX_MNGR.writeNextMainMenu(nextMsgBxToCreate);
					cancel();
					SND_MNGR.playSoundNow(SN_CHOOSE_ITEM);
					break;
				}
				case MenuBoxItems.LEVEL_SELECT:
				{
					nextMsgBxToCreate = new LevelSelectMenu();
					MSG_BX_MNGR.writeNextMainMenu(nextMsgBxToCreate);
					cancel();
					SND_MNGR.playSoundNow(SN_CHOOSE_ITEM);
					break;
				}
			}
		}
		private function checkChoseLockedCheat(cheatName:String,tfStr:String):Boolean
		{
			if (tfStr != MenuBoxItems.HIDDEN_CHEAT)
				return false;
			return false;
		}
		override public function pressUpBtn():void
		{
			var num:int = _cSelNum;
			num--;
			if (num < C_SEL_NUM_MIN)
				num = cSelNumMax;
			setNewSelection(num);
		}
		override public function pressDwnBtn():void
		{
			var num:int = _cSelNum;
			num++;
			if (num > cSelNumMax)
				num = C_SEL_NUM_MIN;
			setNewSelection(num);
		}
		override public function pressJmpBtn():void
		{
			var name:String = ARR_VEC[_cSelNum][IND_ARR_VEC_NAME];
			var value:String = ARR_VEC[_cSelNum][IND_ARR_VEC_VALUE];
			var tfc:TextFieldContainer = ARR_VEC[_cSelNum][IND_ARR_VEC_TEXT_FIELD] as TextFieldContainer;
			chooseItem(name, value, tfc, GameSettings.INCREASE_SETTING_NUM);
		}
		override public function pressLftBtn():void
		{
			var name:String = ARR_VEC[_cSelNum][IND_ARR_VEC_NAME];
			var value:String = ARR_VEC[_cSelNum][IND_ARR_VEC_VALUE];
			var tfc:TextFieldContainer = ARR_VEC[_cSelNum][IND_ARR_VEC_TEXT_FIELD] as TextFieldContainer;
			if (value && tfc && tfc.text != MenuBoxItems.HIDDEN_CHEAT)
				chooseItem(name, value, tfc, GameSettings.DECREASE_SETTING_NUM);
		}
		override public function pressRhtBtn():void
		{
			var name:String = ARR_VEC[_cSelNum][IND_ARR_VEC_NAME];
			var value:String = ARR_VEC[_cSelNum][IND_ARR_VEC_VALUE];
			var tfc:TextFieldContainer = ARR_VEC[_cSelNum][IND_ARR_VEC_TEXT_FIELD] as TextFieldContainer;
			if (value && tfc && tfc.text != MenuBoxItems.HIDDEN_CHEAT)
				pressJmpBtn();
		}
		override public function pressPseBtn():void
		{
			if (GameStateManager.GS_MNGR.gameState == GameStates.PAUSE)
			{
				resumeGame = true;
				nextMsgBxToCreate = null;
				cancel();
			}
		}
		override protected function reachedMaxSize():void
		{
			super.reachedMaxSize();
			_interactive = true;
		}
		public function changeTextToWhite():void
		{
			for (var i:int = 0; i < numItems; i++)
			{
				var tf:TextField = ARR_VEC[i][IND_ARR_VEC_TEXT_FIELD] as TextField;
				if (tf.text == MenuBoxItems.LOAD_GAME || tf.text == MenuBoxItems.NEW_GAME)
					tf.textColor = COLOR_WHITE;
			}
			tf = ARR_VEC[_cSelNum][IND_ARR_VEC_TEXT_FIELD] as TextField;
			if (tf.text == MenuBoxItems.LOAD_GAME || tf.text == MenuBoxItems.NEW_GAME)
				tf.textColor = COLOR_PINK;
		}
		override protected function destroy():void
		{
			activeMenu = null;
			super.destroy();
			SELECTOR.cleanUp();
			MSG_BX_MNGR.mainMenu = null;
			if (resumeGame)
				EVENT_MNGR.unpauseGame();
		}
		public function get cSelNum():int
		{
			return _cSelNum;
		}

	}
}
