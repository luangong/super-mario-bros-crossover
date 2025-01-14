package com.smbc.level
{
	import com.smbc.data.BackgroundNames;
	import com.smbc.data.GameSettings;
	import com.smbc.data.LevelDataTranscoder;
	import com.smbc.data.LevelID;
	import com.smbc.data.LevelTypes;
	import com.smbc.data.MapPack;
	import com.smbc.data.MusicType;
	import com.smbc.data.Themes;
	import com.smbc.errors.SingletonError;
	import com.smbc.graphics.Background;
	import com.smbc.graphics.BackgroundInfo;
	import com.smbc.managers.GraphicsManager;
	import com.smbc.managers.StatManager;

	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class LevelData {

		[Embed(source="../assets/documents/levelDataSmb.xml",mimeType="application/octet-stream")]
		private static const SmbXmlData:Class;
		private static const SmbXml:XML = XML(new SmbXmlData);

		[Embed(source="../assets/documents/levelDataSpecial.xml",mimeType="application/octet-stream")]
		private static const SpecialXmlData:Class;
		private static const SpecialXml:XML = XML(new SpecialXmlData);

		[Embed(source="../assets/documents/levelDataLostLevels.xml",mimeType="application/octet-stream")]
		private static const LostLevelsXmlData:Class;
		private static const LostLevelsXml:XML = XML(new LostLevelsXmlData);

		private static const DEF_WATER_BG:String = BackgroundNames.WATER_SKY+BackgroundNames.CORAL_AND_ROCKS+BackgroundNames.WATER_DISTORTION+BackgroundNames.WATER_HAZE;
		private static const IND_DEF_SKIN_VEC_MUSIC:int = 0;
		private static const IND_DEF_SKIN_VEC_BACKGROUND:int = 1;
		private static const IND_DEF_SKIN_VEC_FOREGROUND:int = 2;
		private var xml:XML;
		private var levelObject:Level;
		private var _id:LevelID;
		private var map:Array;
		private var pickups:Array;
		public var bgStrVec:Vector.<String>;
		public var fgStrVec:Vector.<String>;
		private var music:int;
//		private var area:String;
		private var _type:String;
//		private var worldLevNum:String;
		private var theme:int;
		private var _hwArea:String;
		private var _lockedCheckpoint:Boolean;
		private var _timeLeftTot:uint;
		private var mainArea:String;
		private var mapPack:MapPack;
		private var _worldCount:int;

		/* xml header
		<LEVEL ID="2-3" TIME="300" HW_AREA="a">
		<AREA ID="a" SKIN="outside" BACKGROUND="blueSky,clouds,bigHills" (MUSIC="overWorld" SWIM="true" LEVEL_INTRO="true")>
		*/

		// Public Properties:

		// Private Properties:
		// Initialization:
		public function LevelData(mapPack:MapPack)
		{
			this.mapPack = mapPack;
			xml = getXml(mapPack);

			// get world count, assumes worlds are consecutive numbers starting from 1
			for each (var level:XML in xml.*)
			{
				var worldNumber:int = LevelID.getWorldNumber(level.@ID);
				if (_worldCount < worldNumber)
					_worldCount = worldNumber;
			}
			if (mapPack == MapPack.Smb)
				_worldCount = 8;
//			trace("mapPack: "+mapPack.NiceName+" world count: "+_worldCount);
		}

		private function getXml(mapPack:MapPack):XML
		{
			switch(mapPack)
			{
				case MapPack.Smb:
					return SmbXml;
				case MapPack.Special:
					return SpecialXml;
				case MapPack.LostLevels:
					return LostLevelsXml;
				default:
					return null;
			}
		}

		public function getCurrentLevel(levelID:LevelID):void
		{
			this._id = levelID;
			trace("current level: "+id.fullName);
			var mapStr:String;
			var lpickupevPickupStr:String;
//			worldLevNum = fullLevStr.substring(0,3);
//			if (fullLevStr.length > 3)
//				area = fullLevStr.charAt(3);
//			else
//				area = "a";
//			trace("worldLevNum: "+worldLevNum);
			var ldt:LevelDataTranscoder;
			outerLoop: for each (var level:XML in xml.*)
			{
				if (level.@ID == id.nameWithoutArea)
				{
					for each (var areaXml:XML in level.*)
					if (areaXml.@ID == id.area)
					{
						{
							_hwArea = level.@HW_AREA;
							_lockedCheckpoint = stringToBool(level.@LOCKED_CP);
							mainArea = level.@MAIN_AREA;
							_timeLeftTot = int(level.@TIME);
							mapStr = areaXml.MAP;
							lpickupevPickupStr = areaXml.PICKUPS;
//							theme = LevelDataTranscoder.SKIN_LEVEL_TYPES_OBJ[areaXml.@SKIN];
//							var bgStr:String = areaXml.@BACKGROUND;
//							if (bgStr == "")
//								bgStr = DEF_SKIN_VEC[theme][IND_DEF_SKIN_VEC_BACKGROUND];
//							bgStrVec = Vector.<String>( bgStr.split(",") );
//							var fgStr:String = areaXml.@FOREGROUND;
//							if (fgStr == "")
//								fgStr = DEF_SKIN_VEC[theme][IND_DEF_SKIN_VEC_FOREGROUND];
//							fgStrVec = Vector.<String>( fgStr.split(",") );
							_type = areaXml.@TYPE;
							var musicStr:String = areaXml.@MUSIC;
							if (musicStr == "night")
								musicStr = "overworld";
							music = LevelDataTranscoder.MUSIC_OBJ[ musicStr ];
							break outerLoop;
						}
					}
				}
			}
			var tempMapArr:Array = new Array();
			var tempPickupArr:Array = new Array();
			tempMapArr = mapStr.split("],");
			tempPickupArr = lpickupevPickupStr.split("],");
			map = new Array();
			//pickups = new Array();
			for (var i:uint = 0; i < tempMapArr.length; i++)
			{
				map[i] = (tempMapArr[i].split(","));
			//	pickups[i] = (tempPickupArr[i].split(","));
			}
		}

		private function stringToBool(value:String):Boolean
		{
			return value == "True";
		}

		public function getSpecificLevelMusic(levelID:LevelID):int
		{
			return getMusic(levelID);
		}

		// Public Methods:
		public function get hwArea():String
		{
			return _hwArea;
		}

		public function get lockedCheckpoint():Boolean
		{
			return _lockedCheckpoint;
		}

		public function gettimeLeftTot(levelID:LevelID = null):uint
		{
			checkGetCurrentLevel(levelID);
			return _timeLeftTot;
		}
		public function getMap():Array
		{
			return map;
		}
		public function getPickups():Array
		{
			return pickups;
		}

		public function getMusic(levelID:LevelID = null):int
		{
			checkGetCurrentLevel(levelID);
			return music;
		}

		public function getBGVec(levelID:LevelID = null):Vector.<Background>
		{
			checkGetCurrentLevel(levelID);
			var bgVec:Vector.<Background> = new Vector.<Background>();
			var n:int = bgStrVec.length;
			for (var j:int; j < n; j++)
			{
				var bg:Background = BackgroundInfo.OBJ[ GraphicsManager.INSTANCE.cMapNum + BackgroundInfo.SEP+ bgStrVec[j] ];
				if (bg)
					bgVec[j] = bg;
			}
			return bgVec;
		}
		public function getFGVec(levelID:LevelID = null):Vector.<Background>
		{
			checkGetCurrentLevel(levelID);
			var fgVec:Vector.<Background> = new Vector.<Background>();
			var n:int = fgStrVec.length;
			for (var j:int; j < n; j++)
			{
				var fg:Background = BackgroundInfo.OBJ[ GraphicsManager.INSTANCE.cMapNum.toString() + BackgroundInfo.SEP+ fgStrVec[j] ];
				if (fg)
					fgVec[j] = fg;
			}
			return fgVec;
		}
		public function getWorldLevNum():String
		{
			return id.nameWithoutArea;
		}
		public function getArea():String
		{
			return id.area;
		}
		public function getTheme(levelID:LevelID = null):int
		{
			checkGetCurrentLevel(levelID);
			return theme;
		}
		public function getMainArea(levelID:LevelID = null):String
		{
			checkGetCurrentLevel(levelID);
			return mainArea;
		}
		private function checkGetCurrentLevel(levelID:LevelID):void
		{
			if (levelID != null && this.id != null && this.id.fullName != levelID.fullName)
				getCurrentLevel(levelID);
		}

		public function getType(levelID:LevelID = null):String
		{
			checkGetCurrentLevel(levelID);
			return _type;
		}

		public function get worldCount():int
		{
			return _worldCount;
		}

		public function get id():LevelID
		{
			return _id;
		}

		public function get type():String
		{
			return _type;
		}


		// Protected Methods:
	}

}
