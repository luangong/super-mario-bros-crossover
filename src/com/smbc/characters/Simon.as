﻿package com.smbc.characters
	
		{
			if ( upgradeIsActive( SIMON_WHIP_LEVEL_3 ) )
		}
		{
			if ( upgradeIsActive(SIMON_AXE) )
		}
		{
			super.setCurrentBmdSkin(bmc);
		}
		{
				gotoAndStop(fLab);
		}
		{
			EVENT_MNGR.dispatchEvent( new Event(CustomEvents.STOP_ALL_ENEMIES_PROP_DEACTIVATE) );
		}
		{
				gotoAndStop(currentFrame + 1);
		}
		{
			super.attackObjPiercing(obj);
		}
		{
		}
		override protected function takeDamageEnd():void
		{
			BTN_MNGR.sendPlayerBtns();
		{
			super.landOnGround();
		}
		{
		}
		{
			super.chooseCharacter();
			level.addToLevel(brick2);
		}
		override public function hitPickup(pickup:Pickup,showAnimation:Boolean = true):void
		{
    			super.hitPickup(pickup,showAnimation);
		}
		private function canThrow(weaponToThrow:String = null):String
		{
		}
		
		{
			super.setAmmo(ammoType, value);
		}
		{
			super.removeListeners();
		}
		{
			super.cleanUp();
			tsTxt.UpdAmmoText(false);
		}
		{
			return [ dct[FL_ATTACK_START], dct[FL_ATTACK_2], dct[FL_ATTACK_END], dct[FL_CROUCH_ATTACK_START], dct[FL_CROUCH_ATTACK_2], dct[FL_CROUCH_ATTACK_END] ];
		}
		{
			return _classicMode;
		}
		{
			_classicMode = value;
		}