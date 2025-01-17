package com.smbc.messageBoxes
{
	import com.smbc.data.Cheats;
	import com.smbc.data.GameSettings;
	import com.smbc.main.GlobVars;
	import com.smbc.managers.TutorialManager;
	import com.smbc.text.TextFieldContainer;

	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public final class PauseMenu extends MenuBox
	{
		public static var lastIndex:int;

		public function PauseMenu(startIndexOverride:int = 0)
		{
			super(loadItems(), startIndexOverride);
			if (GameSettings.invisiblePause)
				visible = false;
		}
		private function loadItems():Array
		{
			var arr:Array = [
				[MenuBoxItems.RESUME_GAME],
//				[MenuBoxItems.LOAD_GAME],
				[MenuBoxItems.LOAD_SAVE_GAME],
				[MenuBoxItems.OPTIONS],
//				[MenuBoxItems.VIEW_WIKI],
//				[MenuBoxItems.SUPER_RETRO_SQUAD],
				[MenuBoxItems.LINKS],
				//[MenuBoxItems.VIEW_STATS],
//				[MenuBoxItems.CHEATS]
			//	[MenuBoxItems.LEVEL_SELECT]) optional
			];
			if ( !Cheats.getLockStatus(MenuBoxItems.LEVEL_SELECT) )
				arr.push([MenuBoxItems.LEVEL_SELECT]);
//			if (GameSettings.DEBUG_MODE)
//				arr.push([MenuBoxItems.NEW_GAME]);
			arr.push([MenuBoxItems.QUIT_GAME]);
			return arr;
		}

		override protected function chooseItem(itemName:String, itemValue:String, itemTfc:TextFieldContainer, gsOvRdNum:int):void
		{
			lastIndex = _cSelNum;
			super.chooseItem(itemName, itemValue, itemTfc, gsOvRdNum);
		}

		override protected function destroy():void
		{
			MSG_BX_MNGR.saveLastMenuPosition();
			super.destroy();
		}
	}
}
