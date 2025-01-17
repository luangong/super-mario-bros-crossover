package com.smbc.messageBoxes
{
	import com.explodingRabbit.utils.KeyCodeToString;
	import com.smbc.graphics.fontChars.FontChar;
	import com.smbc.graphics.fontChars.FontCharMenu;
	import com.smbc.main.GlobVars;
	import com.smbc.managers.SoundManager;
	import com.smbc.managers.TutorialManager;
	import com.smbc.text.TextFieldContainer;

	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class PlainMessageBox extends MessageBox
	{
		protected var _msgStr:String;
		protected const PLAIN_MSG_MAX_WIDTH:int = 460;
		protected const MSG_TXT:TextFieldContainer = new TextFieldContainer(FontCharMenu.TYPE_NORMAL);
		private static const DEFAULT_ALIGN:String = TextFormatAlign.LEFT;
		public var tutorial:Boolean;
		protected var oRdMaxWidth:int;
		protected var align:String;
		private var boxWidth:Number;
		private var boxHeight:Number;

		public function PlainMessageBox(messageTemp:String,boxWidth:Number = NaN,boxHeight:Number = NaN,yPos:Number = NaN,align:String = null)
		{
			_msgStr = messageTemp;
			if (align)
				this.align = align;
			else
				align = DEFAULT_ALIGN;
			this.boxWidth = boxWidth;
			this.boxHeight = boxHeight;
			super(boxWidth,boxHeight);
			if (!(isNaN(yPos)))
				endYPos = yPos;
		}
		override protected function setUpText():void
		{
			//if (tutorial)
			replaceButtonStrings();
			/*var txtForm:TextFormat = GlobVars.TF_MAIN;
			txtForm.leading = TXT_LEADING;
			txtForm.align = align;
			with (MSG_TXT)
			{
				defaultTextFormat = txtForm;
				selectable = false;
				embedFonts = true;
				multiline = true;
				autoSize = TextFieldAutoSize.LEFT;
				if (isNaN(boxWidth))
					width = endBoxWidth - CONTAINER_PADDING*2;
				else
					width = boxWidth;
				//height = endBoxHeight - CONTAINER_PADDING*2;
				wordWrap = true;
				text = _msgStr;
				filters = [GlobVars.TXT_DROP_SHADOW];
			}*/
			MSG_TXT.multiline = true;
			if (isNaN(boxWidth))
				MSG_TXT.textBlockWidth = endBoxWidth - CONTAINER_PADDING*2;
			else
				MSG_TXT.textBlockWidth = boxWidth;
			MSG_TXT.text = _msgStr;
			TXT_CONT.addChild(MSG_TXT);
//			if (!isNaN(boxHeight))
//				TXT_CONT.height = boxHeight;
			TXT_CONT.x = CONTAINER_PADDING;
			TXT_CONT.y = CONTAINER_PADDING;
		}
		override protected function reachedMaxSize():void
		{
			super.reachedMaxSize();
			if (tutorial && cancelTmr && cancelTmr.running)
				_interactive = false;
		}
		private function replaceButtonStrings():void
		{
			checkString(TutorialManager.LFT_BTN_STR,BTN_MNGR.lftBtnKeyCode);
			checkString(TutorialManager.RHT_BTN_STR,BTN_MNGR.rhtBtnKeyCode);
			checkString(TutorialManager.UP_BTN_STR,BTN_MNGR.upBtnKeyCode);
			checkString(TutorialManager.DWN_BTN_STR,BTN_MNGR.dwnBtnKeyCode);
			checkString(TutorialManager.JMP_BTN_STR,BTN_MNGR.jmpBtnKeyCode);
			checkString(TutorialManager.ATK_BTN_STR,BTN_MNGR.atkBtnKeyCode);
			checkString(TutorialManager.SPC_BTN_STR,BTN_MNGR.spcBtnKeyCode);
			checkString(TutorialManager.PSE_BTN_STR,BTN_MNGR.pseBtnKeyCode);
			checkString(TutorialManager.SEL_BTN_STR,BTN_MNGR.selBtnKeyCode);

			function checkString(str:String,keyCode:int):void
			{
				while (_msgStr.indexOf(str) != -1)
				{
					_msgStr = _msgStr.replace(str,KeyCodeToString.convertKeyCode(keyCode));
				}
			}

		}
		override public function pressJmpBtn():void
		{
			cancel();
		}
		override public function pressAtkBtn():void
		{
			cancel();
		}
		override public function pressSpcBtn():void
		{
			cancel();
		}
		override public function pressPseBtn():void
		{
			cancel();
		}
		override protected function destroy():void
		{
			super.destroy();
			if (tutorial)
				MSG_BX_MNGR.tutorialEnd();
		}
		public function get msgStr():String
		{
			return _msgStr;
		}
	}
}
