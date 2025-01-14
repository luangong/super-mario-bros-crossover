package com.smbc.managers
{
	import __AS3__.vec.Vector;

	import com.explodingRabbit.utils.Base64;
	import com.gme.GameMusicEmu;
	import com.smbc.characters.Character;
	import com.smbc.characters.Sophia;
	import com.smbc.data.Cheats;
	import com.smbc.data.GameSettings;
	import com.smbc.data.GameStates;
	import com.smbc.data.PickupInfo;
	import com.smbc.errors.SingletonError;
	import com.smbc.interfaces.IMessageBoxSelectable;
	import com.smbc.level.CharacterSelect;
	import com.smbc.level.TitleLevel;
	import com.smbc.main.*;
	import com.smbc.messageBoxes.CharacterSelectBox;
	import com.smbc.messageBoxes.MenuBox;
	import com.smbc.messageBoxes.MessageBox;
	import com.smbc.messageBoxes.MessageBoxMessages;
	import com.smbc.messageBoxes.MessageBoxSounds;
	import com.smbc.messageBoxes.MessageBoxTitleContainer;
	import com.smbc.messageBoxes.PlainMessageBox;
	import com.smbc.messageBoxes.StatsMessageBox;
	import com.smbc.pickups.FireFlower;
	import com.smbc.pickups.Pickup;
	import com.smbc.screens.InformativeBlackScreen;
	import com.smbc.sound.MusicInfo;
	import com.smbc.utils.CharacterSequencer;

	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;

	import nl.stroep.utils.ImageSaver;

	public final class ButtonManager extends MainManager
	{
		public static const BTN_MNGR:ButtonManager = new ButtonManager();
		private static var instantiated:Boolean;
		private const STAGE:Stage = GlobVars.STAGE;
		private var lftBtn:Boolean;
		private var rhtBtn:Boolean;
		private var upBtn:Boolean;
		private var dwnBtn:Boolean;
		private var jmpBtn:Boolean;
		private var atkBtn:Boolean;
		private var spcBtn:Boolean;
		private var selBtn:Boolean;
		private var pseBtn:Boolean;
		private var _lftBtnKeyCode:int = Keyboard.LEFT;
		private var _rhtBtnKeyCode:int = Keyboard.RIGHT;
		private var _upBtnKeyCode:int = Keyboard.UP;
		private var _dwnBtnKeyCode:int = Keyboard.DOWN;
		private var _jmpBtnKeyCode:int = Keyboard.Z; // Z
		private var _atkBtnKeyCode:int = Keyboard.X; // X
		private var _spcBtnKeyCode:int = Keyboard.C;
		private var _pseBtnKeyCode:int = Keyboard.ENTER;
		private var _selBtnKeyCode:int = Keyboard.A;
		private var _lftBtnKeyCodeTemp:int = -1;
		private var _rhtBtnKeyCodeTemp:int = -1;
		private var _upBtnKeyCodeTemp:int = -1;
		private var _dwnBtnKeyCodeTemp:int = -1;
		private var _jmpBtnKeyCodeTemp:int = -1;
		private var _atkBtnKeyCodeTemp:int = -1;
		private var _spcBtnKeyCodeTemp:int = -1;
		private var _pseBtnKeyCodeTemp:int = -1;
		private var _selBtnKeyCodeTemp:int = -1;
		private const UP_ARROW_KEY_CODE:int = Keyboard.UP;
		private const DOWN_ARROW_KEY_CODE:int = Keyboard.DOWN;
		private const LEFT_ARROW_KEY_CODE:int = Keyboard.LEFT;
		private const RIGHT_ARROW_KEY_CODE:int = Keyboard.RIGHT;
		private const ENTER_KEY_CODE:int = Keyboard.ENTER;
		private const ESCAPE_KEY_CODE:int = Keyboard.ESCAPE;
		private const ADD_UPGRADE_KEY_CODE:int = 80; // "p"
		private const CHANGE_CHARACTER_BTN_KEY_CODE:int = 81; // "q"
		private const CHANGE_CHAR_SKIN_KEY_CODE:int = 221; // "]"
		private const CHANGE_MAP_SKIN_KEY_CODE:int = 220; // "\"
		private const CHANGE_INTERFACE_SKIN_KEY_CODE:int = 219; // "["
		private const CHANGE_MUSIC_TYPE_KEY_CODE:int = 192; // "`" (tilda)
		private const SWAP_FLASH_PALETTE:int = 186; // ";"
		private const CHANGE_GB_PALETTE_KEY_CODE:int = 222; // "'"
		private const TAKE_NO_DAMAGE_BTN_KEY_CODE:int = 73; // "i"
		private const MAX_AMMO_KEY:int = Keyboard.SLASH; // /
		private const REMOVE_MISSILE_BTN_KEY_CODE:int = 188; // ","
		private const TOGGLE_FULL_SCREEN_KEY_CODE:int = Keyboard.F; // "f"
		private const NEXT_FRAME:int = 187; // "="
		private const PAUSE_GAME_LOOP:int = 189; // "-"
		private const TOGGLE_SCREEN_SCROLL_BTN_KEY_CODE:int = 57; // "9"
		private const SPC_PORT_1_INC:int = 49; // "1"
		private const SPC_PORT_2_INC:int = 50; // "2"
		private const SPC_PORT_3_INC:int = 51; // "3"
		private const SPC_PORT_4_INC:int = 52; // "4"
		private const SPC_RESET_PORTS:int = 48; // "0"
		private static const RECORD_KEY:int = Keyboard.SPACE;
		private static const EXPORT_RECORDING_KEY:int = Keyboard.BACKSPACE; // backspace
		public var keyCodesVec:Vector.<int> = new Vector.<int>(9,true);
		private var cs:CharacterSelect;
		private var tl:TitleLevel;
		public var activeMsgBx:MessageBox;
		public var menuBx:MenuBox;
		public var setButtons:Boolean;
		private const GS_CHAR_SEL:String = GameStates.CHARACTER_SELECT;
		private const GS_PAUSE:String = GameStates.PAUSE;
		private const GS_PLAY:String = GameStates.PLAY;
		private const GS_MENU:String = GameStates.MENU;
		private const GS_CONTINUE_SELECT:String = GameStates.CONTINUE_SELECT;
		private const DEBUG_MODE:Boolean = GameSettings.DEBUG_MODE;
		private var recordSeq:CharacterSequencer;

		public function ButtonManager()
		{
			if (instantiated)
				throw new SingletonError();
			instantiated = true;
		}
		override public function initiate():void
		{
			super.initiate();
			updateKeyCodesVec();
			if (STAGE.hasEventListener(KeyboardEvent.KEY_DOWN))
				throw new Error("stage already has keyDownLsr");
			if (STAGE.hasEventListener(KeyboardEvent.KEY_UP))
				throw new Error("stage already has keyUpLsr");
			STAGE.addEventListener(KeyboardEvent.KEY_DOWN, keyDownLsr);
			STAGE.addEventListener(KeyboardEvent.KEY_UP, keyUpLsr);
		}
		private function keyDownLsr(e:KeyboardEvent):void
		{
//			trace("keyDown: "+e.keyCode);
			var gs:String = gsMngr.gameState;
			var sendToMsgBx:Boolean = false;
			if (level is CharacterSelect && !activeMsgBx)
				activeMsgBx = CharacterSelectBox.instance;
			if (activeMsgBx && activeMsgBx.interactive)
			{
				sendToMsgBx = true;
				if (setButtons)
				{
					setButtonKeyCode(e.keyCode);
					return;
				}
				else if (activeMsgBx is PlainMessageBox
				&& !(activeMsgBx is IMessageBoxSelectable)
				&& !(activeMsgBx is MessageBoxTitleContainer)
				&& !(activeMsgBx is StatsMessageBox)
				)
				{
					activeMsgBx.pressJmpBtn();
					return;
				}
			}
			else if (tl)
				tl.pressJmpBtn();
			switch (e.keyCode)
			{
				case _lftBtnKeyCode:
				{
					if (lftBtn)
						break;
					else if (tl)
						tl.pressLftBtn();
					else if (gs == GS_PLAY && !player.disableInput)
						player.storeButton( player.pressLftBtn, "pressLftBtn" );
					if (sendToMsgBx)
						activeMsgBx.pressLftBtn();
					else if (gs == GS_CHAR_SEL)
						cs.pressLftBtn();
					lftBtn = true;
					break;
				}
				case _rhtBtnKeyCode:
				{
					if (rhtBtn)
						break;
					else if (tl)
						tl.pressRhtBtn();
					else if (gs == GS_PLAY && !player.disableInput)
						player.storeButton( player.pressRhtBtn, "pressRhtBtn" );
					if (sendToMsgBx)
						activeMsgBx.pressRhtBtn();
					else if (gs == GS_CHAR_SEL)
						cs.pressRhtBtn();
					rhtBtn = true;
					break;
				}
				case _upBtnKeyCode:
				{
					if (upBtn)
						break;
					else if (tl)
						tl.pressUpBtn();
					else if (gs == GS_PLAY && !player.disableInput)
						player.storeButton( player.pressUpBtn, "pressUpBtn" );
					if (sendToMsgBx)
						activeMsgBx.pressUpBtn();
					else if (gs == GS_CHAR_SEL)
						cs.pressUpBtn();
					else if (gs == GS_CONTINUE_SELECT)
						InformativeBlackScreen.instance.pressUpBtn();
					upBtn = true;
					break;
				}
				case _dwnBtnKeyCode:
				{
					if (dwnBtn)
						break;
					else if (tl)
						tl.pressDwnBtn();
					else if (gs == GS_PLAY && !player.disableInput)
						player.storeButton( player.pressDwnBtn, "pressDwnBtn" );
					if (sendToMsgBx)
						activeMsgBx.pressDwnBtn();
					else if (gs == GS_CHAR_SEL)
						cs.pressDwnBtn();
					else if (gs == GS_CONTINUE_SELECT)
						InformativeBlackScreen.instance.pressDwnBtn();
					dwnBtn = true;
					break;
				}
				case _jmpBtnKeyCode:
				{
					if (jmpBtn)
						break;
					else if (tl)
						tl.pressJmpBtn();
					else if (gs == GS_PLAY && !player.disableInput)
						player.storeButton( player.pressJmpBtn, "pressJmpBtn" );
					if (sendToMsgBx)
						activeMsgBx.pressJmpBtn();
					else if (gs == GS_CHAR_SEL)
						cs.pressJmpBtn();
					else if (gs == GS_CONTINUE_SELECT)
						InformativeBlackScreen.instance.pressJmpBtn();
					jmpBtn = true;
					break;
				}
				case _atkBtnKeyCode:
				{
					if (atkBtn)
						break;
					else if (tl)
						tl.pressAtkBtn();
					else if (gs == GS_PLAY && !player.disableInput)
						player.storeButton( player.pressAtkBtn, "pressAtkBtn" );
					if (sendToMsgBx)
						activeMsgBx.pressAtkBtn();
					else if (gs == GS_CHAR_SEL)
						cs.pressAtkBtn();
					atkBtn = true;
					break;
				}
				case _spcBtnKeyCode:
				{
					if (spcBtn)
						break;
					else if (tl)
						tl.pressSpcBtn();
					else if (gs == GS_PLAY && !player.disableInput)
						player.storeButton( player.pressSpcBtn, "pressSpcBtn" );
					if (sendToMsgBx)
						activeMsgBx.pressSpcBtn();
					spcBtn = true;
//					SoundManager.SND_MNGR.playByteArraySound(sndMngr.soundBuffer);
					break;
				}
				case _selBtnKeyCode:
				{
					if (selBtn)
						break;
//					else if (tl)
//						tl.pressSpcBtn();
					else if (gs == GS_PLAY && !player.disableInput)
						player.storeButton( player.pressSelBtn, "pressSelBtn" );
					if (sendToMsgBx)
						activeMsgBx.pressSpcBtn();
					selBtn = true;
//					SoundManager.SND_MNGR.playByteArraySound(sndMngr.soundBuffer);
//					sndMngr.cacheByteArray(sndMngr.soundBuffer);
					break;
				}
				case _pseBtnKeyCode:
				{
					if (pseBtn)
						break;
					else if (tl)
						tl.pressPseBtn();
					else if (scrnMngr.creditsAreRolling)
						scrnMngr.fastForwardCredits();
					else if (gs == GS_PLAY)
						eventMngr.pauseGame();
					if (sendToMsgBx)
						activeMsgBx.pressPseBtn();
					else if (gs == GS_CHAR_SEL)
						cs.pressPseBtn();
					else if (gs == GS_CONTINUE_SELECT)
						InformativeBlackScreen.instance.pressPseBtn();
					pseBtn = true;
					if (DEBUG_MODE && GameSettings.recordCharSeq)
					{
						if (gs == GS_PAUSE && !recordSeq)
						{
							recordSeq = new CharacterSequencer();
							recordSeq.recordStart(player);
						}
						else if (gs == GS_PLAY && recordSeq)
						{
							recordSeq.recordEnd();
							recordSeq = null;
						}
					}
					break;
				}
				case UP_ARROW_KEY_CODE:
				{
					if (upBtn)
						return;
					if (sendToMsgBx)
						activeMsgBx.pressUpBtn();
					else if (gs == GS_CONTINUE_SELECT)
						InformativeBlackScreen.instance.pressUpBtn();
					break;
				}
				case DOWN_ARROW_KEY_CODE:
				{
					if (dwnBtn)
						return;
					if (sendToMsgBx)
						activeMsgBx.pressDwnBtn();
					else if (gs == GS_CONTINUE_SELECT)
						InformativeBlackScreen.instance.pressDwnBtn();
					break;
				}
				case LEFT_ARROW_KEY_CODE:
				{
					if (lftBtn)
						return;
					if (sendToMsgBx)
						activeMsgBx.pressLftBtn();
					break;
				}
				case RIGHT_ARROW_KEY_CODE:
				{
					if (rhtBtn)
						return;
					if (sendToMsgBx)
						activeMsgBx.pressRhtBtn();
					break;
				}
				case ENTER_KEY_CODE:
				{
					if (jmpBtn)
						return;
					if (sendToMsgBx)
						activeMsgBx.pressJmpBtn();
					else if (gs == GS_CONTINUE_SELECT)
						InformativeBlackScreen.instance.pressJmpBtn();
					break;
				}
				/*case ESCAPE_KEY_CODE:
				{
					if (pseBtn)
						return;
					if (gs == GS_PLAY)
						eventMngr.pauseGame();
					else if (sendToMsgBx)
						activeMsgBx.pressPseBtn();
					break;
				}*/
			} // end nondebug mode keys
			if (!DEBUG_MODE)
				return;
			switch(e.keyCode)
			{
				case ADD_UPGRADE_KEY_CODE: // debug... changes player.pState
				{
					if (!DEBUG_MODE)
						break;
					if (gs == GS_PLAY && !player.disableInput)
					{
						Character.hitRandomUpgrade(statMngr.curCharNum, false);
					}
					break;
				}
				case CHANGE_CHARACTER_BTN_KEY_CODE: // debug... changes character
				{
					if (!DEBUG_MODE)
						break;
					if (gs == GS_PLAY && !player.disableInput)
						player.changeChar();
					break;
				}
				case CHANGE_CHAR_SKIN_KEY_CODE: // debug... changes current character skin
				{
					if (!DEBUG_MODE)
						break;
					if (gs == GS_PLAY && !player.disableInput)
						GraphicsManager.INSTANCE.changeCharacterSkin(player);
					break;
				}
				case CHANGE_MAP_SKIN_KEY_CODE: // debug... changes map skin
				{
					if (!DEBUG_MODE)
						break;
					if (gs == GS_PLAY)
						GameSettings.changeMapSkin(-1,false);
					break;
				}
				case TOGGLE_FULL_SCREEN_KEY_CODE: // debug... toggles full screen
				{
					if (!DEBUG_MODE)
						break;
					scrnMngr.enterFullScreen();
					break;
				}
				case TAKE_NO_DAMAGE_BTN_KEY_CODE:
				{
					var bool:Boolean = !Cheats.invincible;
					Cheats.invincible = bool;
					if (level && level.player)
					{
						if (bool)
							level.player.forceTakeNoDamage();
						else
							level.player.forceTakeDamage();
					}
					break;
				}
				case CHANGE_INTERFACE_SKIN_KEY_CODE: // debug... changes interface skin
				{
					if (!DEBUG_MODE)
						break;
					if (gs == GS_PLAY)
						GameSettings.changeInterfaceSkin(GameSettings.INCREASE_SETTING_NUM);
					break;
				}
				case SWAP_FLASH_PALETTE: // debug... changes current character color
				{
					if (!DEBUG_MODE)
						break;
					if (gs == GS_PLAY)
						player.flashPaletteSwap();
					break;
				}
				case CHANGE_GB_PALETTE_KEY_CODE: // debug... changes gameboy palette
				{
					if (!DEBUG_MODE)
						break;
					if (gs == GS_PLAY)
						GameSettings.changeMapPalette(GameSettings.INCREASE_SETTING_NUM);
					break;
				}
				case CHANGE_MUSIC_TYPE_KEY_CODE: // debug... changes music type
				{
					if (!DEBUG_MODE)
						break;
					if (gs == GS_PLAY && !player.disableInput)
					{
						if (!GameSettings.muteMusic)
							GameSettings.changeMusicType(GameSettings.INCREASE_SETTING_NUM);
						else
						{
							GameSettings.changeMuteMusic();
							sndMngr.changeMusic();
						}
					}
					break;
				}
				case PAUSE_GAME_LOOP: // debug... pauses the game loop
				{
					if (!DEBUG_MODE)
						break;
					if (gs == GS_PLAY)
						level.manualGameLoop = !level.manualGameLoop;
					break;
				}
				case NEXT_FRAME: // debug... advances game loop to next frame
				{
					if (!DEBUG_MODE)
						break;
					if (gs == GS_PLAY)
						level.manualGameLoopNextFrame = true;
					break;
				}
				case TOGGLE_SCREEN_SCROLL_BTN_KEY_CODE: // debug
				{
					if (!DEBUG_MODE)
						break;
					if (gs == GS_PLAY)
						level.toggleScreenScroll();
					break;
				}
				case MAX_AMMO_KEY: // debug
				{
					if (!DEBUG_MODE)
						break;
					if (GameSettings.classicMode)
						GameSettings.NextClassicWeapons();
					if (player)
						player.setAllAmmoToMax();
					break;
				}
					/*case REMOVE_MISSILE_BTN_KEY_CODE: // debug
				{
					if (!DEBUG_MODE)
						break;
					if (gs == GS_PLAY && player is Sophia)
						statMngr.changeStat(statMngr.STAT_NUM_SOPHIA_MISSILES,-1,Sophia(player).MISSILE_COUNT.updateDisplay);
					break;
				}*/
				case RECORD_KEY: // debug
				{
					if (!DEBUG_MODE)
						break;
					var imgSvr:ImageSaver = ImageSaver.INSTANCE;
					if (imgSvr.recording)
						imgSvr.stopRecording();
					else
						imgSvr.startRecording();
					break;
				}
				case EXPORT_RECORDING_KEY: // debug
				{
					if (!DEBUG_MODE)
						break;
//					ImageSaver.INSTANCE.save( game, "game.png",0,0, new Rectangle(0,0,512,480) );
					if (jmpBtn)
						ImageSaver.INSTANCE.clearStoredImages();
					else
						ImageSaver.INSTANCE.saveAll();
					break;
				}
				case SPC_PORT_1_INC:
				{
					if (!DEBUG_MODE)
						break;
					if (gs == GS_PLAY && !player.disableInput)
					{
						sndMngr.musicPlayerMain.port1++;
						sndMngr.musicPlayerMain.setSpcPorts();
						sndMngr.changeMusic();
					}
					break;
				}
				case SPC_PORT_2_INC:
				{
					if (!DEBUG_MODE)
						break;
					if (gs == GS_PLAY && !player.disableInput)
					{
						sndMngr.musicPlayerMain.port2++;
						sndMngr.musicPlayerMain.setSpcPorts();
						sndMngr.changeMusic();
					}
					break;
				}
				case SPC_PORT_3_INC:
				{
					if (!DEBUG_MODE)
						break;
					if (gs == GS_PLAY && !player.disableInput)
					{
						sndMngr.musicPlayerMain.port3++;
						sndMngr.musicPlayerMain.setSpcPorts();
						sndMngr.changeMusic();
					}
					break;
				}
				case SPC_PORT_4_INC:
				{
					if (!DEBUG_MODE)
						break;
					if (gs == GS_PLAY && !player.disableInput)
					{
						sndMngr.musicPlayerMain.port4++;
						sndMngr.musicPlayerMain.setSpcPorts();
						sndMngr.changeMusic();
					}
					break;
				}
				case SPC_RESET_PORTS:
				{
					if (!DEBUG_MODE)
						break;
					if (gs == GS_PLAY && !player.disableInput)
					{
						var mp:GameMusicEmu = sndMngr.musicPlayerMain;
						mp.port1 = -1;
						mp.port2 = -1;
						mp.port3 = -1;
						mp.port4 = -1;
						mp.setSpcPorts();
						sndMngr.changeMusic();
					}
					break;
				}
				default:
				{
					break;
				}
			}
		}
		private function keyUpLsr(e:KeyboardEvent):void
		{
			//trace("keyUp: "+e.keyCode);
			var gs:String = gsMngr.gameState;
			switch (e.keyCode)
			{
				case _lftBtnKeyCode:
				{
					if (!lftBtn)
						break;
					if (!tl && gs == GS_PLAY && !player.disableInput)
						player.storeButton( player.relLftBtn, "relLftBtn" );
					lftBtn = false;
					break;
				}
				case _rhtBtnKeyCode:
				{
					if (!rhtBtn)
						break;
					if (!tl && gs == GS_PLAY && !player.disableInput)
						player.storeButton( player.relRhtBtn, "relRhtBtn" );
					rhtBtn = false;
					break;
				}
				case _upBtnKeyCode:
				{
					if (!upBtn)
						break;
					if (!tl && gs == GS_PLAY && !player.disableInput)
						player.storeButton( player.relUpBtn, "relUpBtn" );
					upBtn = false;
					break;
				}
				case _dwnBtnKeyCode:
				{
					if (!dwnBtn)
						break;
					if (!tl && gs == GS_PLAY && !player.disableInput)
						player.storeButton( player.relDwnBtn, "relDwnBtn" );
					dwnBtn = false;
					break;
				}
				case _jmpBtnKeyCode:
				{
					if (!jmpBtn)
						break;
					if (!tl && gs == GS_PLAY && !player.disableInput)
						player.storeButton( player.relJmpBtn, "relJmpBtn" );
					jmpBtn = false;
					break;
				}
				case _atkBtnKeyCode:
				{
					if (!atkBtn)
						break;
					if (!tl && gs == GS_PLAY && !player.disableInput)
						player.storeButton( player.relAtkBtn, "relAtkBtn" );
					atkBtn = false;
					break;
				}
				case _spcBtnKeyCode:
				{
					if (!tl && gs == GS_PLAY && !player.disableInput)
						player.storeButton( player.relSpcBtn, "relSpcBtn" );
					spcBtn = false;
					break;
				}
				case _selBtnKeyCode:
				{
					if (!tl && gs == GS_PLAY && !player.disableInput)
						player.storeButton( player.relSelBtn, "relSelBtn" );
					selBtn = false;
					break;
				}
				case _pseBtnKeyCode:
				{
					if (!pseBtn)
						break;
					pseBtn = false;
					break;
				}
				default:
				{
					break;
				}
			}
		}
		private function updateKeyCodesVec():void
		{
			keyCodesVec[0] = _lftBtnKeyCode;
			keyCodesVec[1] = _rhtBtnKeyCode;
			keyCodesVec[2] = _upBtnKeyCode;
			keyCodesVec[3] = _dwnBtnKeyCode;
			keyCodesVec[4] = _jmpBtnKeyCode;
			keyCodesVec[5] = _atkBtnKeyCode;
			keyCodesVec[6] = _spcBtnKeyCode;
			keyCodesVec[7] = _pseBtnKeyCode;
			keyCodesVec[8] = _selBtnKeyCode;
		}
		public function writeKeyCodesFromVec():void
		{
			_lftBtnKeyCode = keyCodesVec[0];
			_rhtBtnKeyCode = keyCodesVec[1];
			_upBtnKeyCode = keyCodesVec[2];
			_dwnBtnKeyCode = keyCodesVec[3];
			_jmpBtnKeyCode = keyCodesVec[4];
			_atkBtnKeyCode = keyCodesVec[5];
			_spcBtnKeyCode = keyCodesVec[6];
			_pseBtnKeyCode = keyCodesVec[7];
			_selBtnKeyCode = keyCodesVec[8];
			relBtns();
		}
		public function updateVars():void
		{
			level = GlobVars.level;
			player = level.player;
		}
		public function characterSelectStartHandler():void
		{
			cs = CharacterSelect.instance;
		}
		public function titleLevelInitiateHandler():void
		{
			tl = TitleLevel.instance;
		}
		public function titleLevelDestroyHandler():void
		{
			tl = null;
		}
		public function relBtns():void
		{
			// should only be called when changing buttons
			upBtn = false;
			dwnBtn = false;
			lftBtn = false;
			rhtBtn = false;
			atkBtn = false;
			jmpBtn = false;
			spcBtn = false;
			pseBtn = false;
		}
		private function setButtonKeyCode(newKeyCode:uint):void
		{
			switch((activeMsgBx as PlainMessageBox).msgStr)
			{
				case MessageBoxMessages.SET_BUTTONS_LFT:
				{
					if (checkNewKeyCode(newKeyCode))
					{
						_lftBtnKeyCodeTemp = newKeyCode;
						sndMngr.playSoundNow(MessageBoxSounds.SN_SB_LEFT);
					}
					else
						recallButtonMessageBox();
					break;
				}
				case MessageBoxMessages.SET_BUTTONS_RHT:
				{
					if (checkNewKeyCode(newKeyCode))
					{
						_rhtBtnKeyCodeTemp = newKeyCode;
						sndMngr.playSoundNow(MessageBoxSounds.SN_SB_RIGHT);
					}
					else
						recallButtonMessageBox();
					break;
				}
				case MessageBoxMessages.SET_BUTTONS_UP:
				{
					if (checkNewKeyCode(newKeyCode))
					{
						_upBtnKeyCodeTemp = newKeyCode;
						sndMngr.playSoundNow(MessageBoxSounds.SN_SB_UP);
					}
					else
						recallButtonMessageBox();
					break;
				}
				case MessageBoxMessages.SET_BUTTONS_DWN:
				{
					if (checkNewKeyCode(newKeyCode))
					{
						_dwnBtnKeyCodeTemp = newKeyCode;
						sndMngr.playSoundNow(MessageBoxSounds.SN_SB_DOWN);
					}
					else
						recallButtonMessageBox();
					break;
				}
				case MessageBoxMessages.SET_BUTTONS_JMP:
				{
					if (checkNewKeyCode(newKeyCode))
					{
						_jmpBtnKeyCodeTemp = newKeyCode;
						sndMngr.playSoundNow(MessageBoxSounds.SN_SB_JUMP);
					}
					else
						recallButtonMessageBox();
					break;
				}
				case MessageBoxMessages.SET_BUTTONS_ATK:
				{
					if (checkNewKeyCode(newKeyCode))
					{
						_atkBtnKeyCodeTemp = newKeyCode;
						sndMngr.playSoundNow(MessageBoxSounds.SN_SB_ATTACK);
					}
					else
						recallButtonMessageBox();
					break;
				}
				case MessageBoxMessages.SET_BUTTONS_SPC:
				{
					if (checkNewKeyCode(newKeyCode))
					{
						_spcBtnKeyCodeTemp = newKeyCode;
						sndMngr.playSoundNow(MessageBoxSounds.SN_SB_SPECIAL);
					}
					else
						recallButtonMessageBox();
					break;
				}
				case MessageBoxMessages.SET_BUTTONS_PSE:
				{
					if (checkNewKeyCode(newKeyCode))
					{
						_pseBtnKeyCodeTemp = newKeyCode;
						sndMngr.playSoundNow(MessageBoxSounds.SN_SB_PAUSE);
					}
					else
						recallButtonMessageBox();
					break;
				}
				case MessageBoxMessages.SET_BUTTONS_SEL:
				{
					if (checkNewKeyCode(newKeyCode))
					{
						_selBtnKeyCodeTemp = newKeyCode;
						sndMngr.playSoundNow(MessageBoxSounds.SN_SB_PAUSE);
						setButtons = false;
					}
					else
						recallButtonMessageBox();
					break;
				}
			}
			activeMsgBx.cancel();
		}
		private function recallButtonMessageBox():void
		{
			var nMsg:MessageBox = activeMsgBx.nextMsgBxToCreate;
			activeMsgBx.nextMsgBxToCreate = new PlainMessageBox(MessageBoxMessages.SET_BUTTONS_ERROR);
			activeMsgBx.nextMsgBxToCreate.nextMsgBxToCreate = new PlainMessageBox((activeMsgBx as PlainMessageBox).msgStr);
			activeMsgBx.nextMsgBxToCreate.nextMsgBxToCreate.nextMsgBxToCreate = nMsg;
			sndMngr.playSoundNow(MessageBoxSounds.SN_CANCEL_ITEM);
		}
		public function writeNewButtons():void
		{
			_lftBtnKeyCode = _lftBtnKeyCodeTemp;
			_rhtBtnKeyCode = _rhtBtnKeyCodeTemp;
			_upBtnKeyCode = _upBtnKeyCodeTemp;
			_dwnBtnKeyCode = _dwnBtnKeyCodeTemp;
			_jmpBtnKeyCode = _jmpBtnKeyCodeTemp;
			_atkBtnKeyCode = _atkBtnKeyCodeTemp;
			_spcBtnKeyCode = _spcBtnKeyCodeTemp;
			_pseBtnKeyCode = _pseBtnKeyCodeTemp;
			_selBtnKeyCode = _selBtnKeyCodeTemp;
			updateKeyCodesVec();
			msgBxMngr.setBtnsDct = null;
			discardTempButtons();
		}
		public function discardTempButtons():void
		{
			_lftBtnKeyCodeTemp = -1;
			_rhtBtnKeyCodeTemp = -1;
			_upBtnKeyCodeTemp = -1;
			_dwnBtnKeyCodeTemp = -1;
			_jmpBtnKeyCodeTemp = -1;
			_atkBtnKeyCodeTemp = -1;
			_spcBtnKeyCodeTemp = -1;
			_pseBtnKeyCodeTemp = -1;
			_selBtnKeyCodeTemp = -1;
			msgBxMngr.setBtnsDct = null;
		}
		private function checkNewKeyCode(newKeyCode:uint):Boolean
		{
			switch(newKeyCode)
			{
				case _lftBtnKeyCodeTemp:
					return false;
				case _rhtBtnKeyCodeTemp:
					return false;
				case _upBtnKeyCodeTemp:
					return false;
				case _dwnBtnKeyCodeTemp:
					return false;
				case _jmpBtnKeyCodeTemp:
					return false;
				case _atkBtnKeyCodeTemp:
					return false;
				case _spcBtnKeyCodeTemp:
					return false;
				case _pseBtnKeyCodeTemp:
					return false;
				case _selBtnKeyCodeTemp:
					return false;
				default:
					return true;
			}
		}
		public function relPlyrBtns():void
		{
			if (player.upBtn)
				player.relUpBtn();
			if (player.dwnBtn)
				player.relDwnBtn();
			if (player.rhtBtn)
				player.relRhtBtn();
			if (player.lftBtn)
				player.relLftBtn();
			if (player.atkBtn)
				player.relAtkBtn();
			if (player.jmpBtn)
				player.relJmpBtn();
			if (player.spcBtn)
				player.relSpcBtn();
			//player.relPseBtn();
		}
		public function sendPlayerBtns():void // only sends during GS_PLAY
		{
			if (gsMngr.gameState != GS_PLAY)
				return;
			player.upBtn = upBtn;
			player.dwnBtn = dwnBtn;
			player.rhtBtn = rhtBtn;
			player.lftBtn = lftBtn;
			player.spcBtn = spcBtn;
			player.jmpBtn = jmpBtn;
			player.atkBtn = atkBtn;
			if (player is Sophia)
			{
				if (upBtn)
					player.pressUpBtn();
				if (lftBtn)
					player.pressLftBtn();
				if (rhtBtn)
					player.pressRhtBtn();
				if (dwnBtn)
					player.pressDwnBtn();
			}
		}
		/* public function sendPlayerUnpauseBtns():void
		{
			if (player.pUpBtn && !upBtn)

			player.upBtn = upBtn;
			player.dwnBtn = dwnBtn;
			player.rhtBtn = rhtBtn;
			player.lftBtn = lftBtn;
			player.spcBtn = spcBtn;
			player.jmpBtn = jmpBtn;
			player.atkBtn = atkBtn;
		} */
		public function cleanUp():void
		{
			removeLsrs();
		}
		private function removeLsrs():void
		{
			if (STAGE.hasEventListener(KeyboardEvent.KEY_DOWN)) STAGE.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownLsr);
			if (STAGE.hasEventListener(KeyboardEvent.KEY_UP)) STAGE.removeEventListener(KeyboardEvent.KEY_UP, keyUpLsr);
		}
		public function get lftBtnKeyCode():uint
		{
			return _lftBtnKeyCode;
		}
		public function get rhtBtnKeyCode():uint
		{
			return _rhtBtnKeyCode;
		}
		public function get upBtnKeyCode():uint
		{
			return _upBtnKeyCode;
		}
		public function get dwnBtnKeyCode():uint
		{
			return _dwnBtnKeyCode;
		}
		public function get jmpBtnKeyCode():uint
		{
			return _jmpBtnKeyCode;
		}
		public function get atkBtnKeyCode():uint
		{
			return _atkBtnKeyCode;
		}
		public function get spcBtnKeyCode():uint
		{
			return _spcBtnKeyCode;
		}
		public function get pseBtnKeyCode():uint
		{
			return _pseBtnKeyCode;
		}
		public function get selBtnKeyCode():uint
		{
			return _selBtnKeyCode;
		}
		public function get lftBtnKeyCodeTemp():int
		{
			return _lftBtnKeyCodeTemp;
		}
		public function get rhtBtnKeyCodeTemp():int
		{
			return _rhtBtnKeyCodeTemp;
		}
		public function get upBtnKeyCodeTemp():int
		{
			return _upBtnKeyCodeTemp;
		}
		public function get dwnBtnKeyCodeTemp():int
		{
			return _dwnBtnKeyCodeTemp;
		}
		public function get jmpBtnKeyCodeTemp():int
		{
			return _jmpBtnKeyCodeTemp;
		}
		public function get atkBtnKeyCodeTemp():int
		{
			return _atkBtnKeyCodeTemp;
		}
		public function get spcBtnKeyCodeTemp():int
		{
			return _spcBtnKeyCodeTemp;
		}
		public function get pseBtnKeyCodeTemp():int
		{
			return _pseBtnKeyCodeTemp;
		}
		public function get selBtnKeyCodeTemp():int
		{
			return _selBtnKeyCodeTemp;
		}

	}
}
