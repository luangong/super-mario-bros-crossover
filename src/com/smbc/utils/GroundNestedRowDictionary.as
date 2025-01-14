package com.smbc.utils
{
	import com.explodingRabbit.utils.CustomDictionary;
	import com.smbc.ground.Ground;
	import com.smbc.ground.Platform;
	import com.smbc.main.GlobVars;

	import flash.utils.Dictionary;

	public final dynamic class GroundNestedRowDictionary extends CustomDictionary
	{
		// this has one dictionary for each row
		public const ROW_DCTS:CustomDictionary = new CustomDictionary();
		public const OFF_GRID_KEY:String = "offGridKey";
//		public static const NON_GRID_ITEM_KEY:String = "nonGridItem";

		public function GroundNestedRowDictionary(weakKeys:Boolean=false)
		{
			super(weakKeys);
		}
		public function prepLevDcts(numRowsLev:int,tileSize:int):void
		{
			var ts:int = tileSize;
			var numRows:int = numRowsLev - 1; // skips top row because there is never any ground on it
			var curPos:int = ts;
			var i:int = 0;
			for (i = 0; i < numRows; i++)
			{
				ROW_DCTS.addItem(curPos,new Dictionary(true));
				curPos += ts;
			}
			ROW_DCTS[OFF_GRID_KEY] = new Dictionary(true);
//			ROW_DCTS[NON_GRID_ITEM_KEY] = new Dictionary(true);
		}
		override public function addItem(key:Object,value:Object = null):void
		{
			if (!this[key])
			{
				_length++;
				this[key] = key;
				if (key is Ground)
				{
					var ground:Ground = key as Ground;
					var dct:Dictionary;
					var keyNum:Number = ground.y;
					if (!ground.offGrid)
						dct = ROW_DCTS[keyNum];
					else
						dct = ROW_DCTS[OFF_GRID_KEY];
					if (dct)
					{
						ground.rowKey = keyNum;
						dct[key] = key;
					}
					//else
						//trace(Ground(key).name+" could not be added");
					/*else
					{
						dct = ROW_DCTS[NON_GRID_ITEM_KEY];
						if (dct)
							dct[key] = key;
					}*/
					//	trace("add: "+key+" dct[key]: "+dct[key]+" key.name: "+Ground(key).name);
				}
			}
		}
		override public function removeItem(key:Object):void
		{
			if (this[key])
			{
				delete this[key];
				_length--;
				if (key is Ground)
				{
					var dct:Dictionary;
					var ground:Ground = key as Ground;
					if (!ground.offGrid)
						dct = ROW_DCTS[ground.rowKey];
					else
						dct = ROW_DCTS[OFF_GRID_KEY];
					if (dct && dct[key])
					{
						ground.rowKey
						delete dct[key];
					}
					//else
					//	trace(Ground(key).name+" could not be removed");
					/*{
						dct = ROW_DCTS[NON_GRID_ITEM_KEY];
						if (dct && dct[key])
							delete dct[key];
					}*/
					//trace("remove: "+key+" dct[key]: "+dct[key]+" key.name: "+Ground(key).name);
				}
			}
		}
	}
}
