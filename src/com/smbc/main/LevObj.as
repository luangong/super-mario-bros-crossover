﻿package com.smbc.main

				if ( isSusceptibleToProperty( stopAllProp ) )
					addStatusEffect( new StatFxStop(this) );
		protected function stopAllEnemiesPropDeactivateHandler(event:Event):void
		{
				var stopAllProp:StatusProperty = player.getProperty(PR_STOP_ALL_ENEMIES_ACTIVE_AGG);
		}
		{
			var trueDct:CustomDictionary = getReasonOvRds(NAME_STOP_ANIM,true);
		}
		{
			var trueDct:CustomDictionary = getReasonOvRds(NAME_STOP_UPDATE,true);
		}
		{
			var trueDct:CustomDictionary = getReasonOvRds(NAME_STOP_TIMERS,true);
		}
		{
			if ( animate(accurateAnimTmr) )
		}
		{
			if (item == HT_BRICK || item == HT_GROUND_NON_BRICK || item == HT_PLATFORM)
		}
		{
			addHitTestableItem(HT_GROUND_NON_BRICK);
		}
		{
			hitTestAgainstGroundDct.clear();
		}
		{
			if (reasonOvRdObj[varName] == undefined)
		}
		{
			if (reasonOvRdObj[varName] == undefined)
		}
		{
			var str:String = " is hitting: ";
		}
		{
			propsDct[prop.type] = prop;
		}
		{
			delete propsDct[type];
		}
		{
			propAggOrderVec.length = 0;
			{
				if (propsDct[ type ])
			}
		}
		{
			return propAggOrderVec;
		}
		{
			return false;
		}
		{
			for each (var statFx:StatusEffect in statusEffectsDct)
		}
		{
			for each (var effect:StatusEffect in statusEffectsDct)
		}*/
//		protected function removeAllProperties():void
//		{
//			propsDct.clear();
		{
			switch(effect)
		}*/