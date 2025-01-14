package com.smbc
{
	import com.explodingRabbit.cross.games.Games;
	import com.explodingRabbit.utils.CustomDictionary;
	import com.smbc.data.CharacterInfo;
	import com.smbc.data.Cheats;
	import com.smbc.data.GameSettings;
	import com.smbc.data.GameSettingsValues;
	import com.smbc.data.OnlineData;
	import com.smbc.data.PickupInfo;
	import com.smbc.data.ScreenSize;
	import com.smbc.data.SoundNames;
	import com.smbc.errors.SingletonError;
	import com.smbc.graphics.MasterObjects;
	import com.smbc.level.FakeLevel;
	import com.smbc.main.GlobVars;
	import com.smbc.managers.ButtonManager;
	import com.smbc.managers.EventManager;
	import com.smbc.managers.GameStateManager;
	import com.smbc.managers.GraphicsManager;
	import com.smbc.managers.MainManager;
	import com.smbc.managers.MessageBoxManager;
	import com.smbc.managers.ScreenManager;
	import com.smbc.managers.SoundManager;
	import com.smbc.managers.StatManager;
	import com.smbc.managers.TextManager;
	import com.smbc.managers.TutorialManager;
	import com.smbc.messageBoxes.MenuBox;
	import com.smbc.pickups.LinkPickup;
	import com.smbc.sound.RepeatingSilenceOverrideSnd;
	import com.smbc.sound.SoundLevels;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.describeType;

	import nl.stroep.utils.ImageSaver;

	[SWF(width=512,height=480,backgroundColor="#000000")]
	public class SuperMarioBrosCrossover extends Sprite
	{
		public static var game:SuperMarioBrosCrossover;
		public var testBmp:Bitmap = new Bitmap();
		public const MASK_SPRITE:Sprite = new Sprite();

		private var onlineDataLoaded:Boolean;
		private var addedToStage:Boolean;

		public function SuperMarioBrosCrossover()
		{
			if (game != null)
				throw new SingletonError();
			game = this;
			addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler,false,0,true);
		}

		private function addedToStageHandler(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			OnlineData.instance.addEventListener(Event.COMPLETE, onlineDataCompleteHandler, false, 0, true);
			OnlineData.initiate();
//			addedToStage = true;
//			trace("addedToStageHandler");
//			if (onlineDataLoaded)
//				initiateGame();
		}

		protected function onlineDataCompleteHandler(event:Event):void
		{
			OnlineData.instance.removeEventListener(Event.COMPLETE, onlineDataCompleteHandler);
			initiateGame();
//			trace("onlineDataCompleteHandler");
//			onlineDataLoaded = true;
//			if (addedToStage)
		}


		private function initiateGame():void
		{
			// set up stage
			if (OnlineData.loaded)
				trace("currentVersion: "+OnlineData.currentVersion);
			else
				trace("not loaded");
			//var gStage:Stage = GlobVars.STAGE;
			stage.quality = StageQuality.LOW;
			stage.scaleMode = StageScaleMode.NO_SCALE;
//			stage.color = 0x000000;
			MASK_SPRITE.graphics.beginFill(0xFF0000);
			MASK_SPRITE.graphics.drawRect(0,0,ScreenSize.SCREEN_WIDTH,ScreenSize.SCREEN_HEIGHT);
			MASK_SPRITE.graphics.endFill();
			this.mask = MASK_SPRITE;
			// set up managers
			if (!GameSettings.DEBUG_MODE)
				GameSettings.setDefaults();
			var gsMngr:GameStateManager = GameStateManager.GS_MNGR;
			var btnMngr:ButtonManager = ButtonManager.BTN_MNGR;
			var statMngr:StatManager = StatManager.STAT_MNGR;
			var scrnMngr:ScreenManager = ScreenManager.SCRN_MNGR;
			var sndMngr:SoundManager = SoundManager.SND_MNGR;
			var eventMngr:EventManager = EventManager.EVENT_MNGR;
			var txtMngr:TextManager = TextManager.INSTANCE;
			var msgBxMngr:MessageBoxManager = MessageBoxManager.INSTANCE;
			var tutMngr:TutorialManager = TutorialManager.TUT_MNGR;
			var grMngr:GraphicsManager = GraphicsManager.INSTANCE;
			var mngrDct:CustomDictionary = MainManager.MNGR_DCT;
			btnMngr.initiate();
			mngrDct.addItem(btnMngr);
			gsMngr.initiate();
			mngrDct.addItem(gsMngr);
			statMngr.initiate();
			mngrDct.addItem(statMngr);
			sndMngr.initiate();
			mngrDct.addItem(sndMngr);
			eventMngr.initiate();
			mngrDct.addItem(eventMngr);
			txtMngr.initiate();
			mngrDct.addItem(txtMngr);
			tutMngr.initiate();
			mngrDct.addItem(tutMngr);
			msgBxMngr.initiate();
			mngrDct.addItem(msgBxMngr);
			grMngr.initiate();
			mngrDct.addItem(grMngr);
			mngrDct.addItem(scrnMngr);
			GameSettings.managersReady();
			ImageSaver.INSTANCE = new ImageSaver( "http://localhost:8888/save-my-image.php", this );
			if (GameSettings.callJavaScript)
				ExternalInterface.addCallback("fromJava", sndMngr.fromJava);

			MasterObjects.initiate();  // sets up master objects
			// check debug mode
			Games.initiateGames();
			Cheats.setUpCheats();
			if (GameSettings.DEBUG_MODE)
				GameSettings.activateDebugMode();
			GameSettingsValues.initiate();
			var repeatingSnd:RepeatingSilenceOverrideSnd = new RepeatingSilenceOverrideSnd();
			PickupInfo.initiate();
			scrnMngr.initiate(); // this starts everything (I think)
		}

		override public function addChild(child:DisplayObject):DisplayObject
		{
			super.addChild(child);
			if (contains(GraphicsManager.gameBoyFilterSprite))
				setChildIndex(GraphicsManager.gameBoyFilterSprite,numChildren - 1);
			return child;
		}
		private function shit():Boolean
		{
//			return true;
			//*
			var url:String = stage.loaderInfo.url;
			if (GameSettings.callJavaScript && url.indexOf("file://") != -1 )
				GameSettings.callJavaScript = false;
			var testDct:Dictionary = new Dictionary();
			testDct["file://"] = "file://";
//			testDct["http://localhost/"] = "http://localhost/";
			testDct["http://localhost:8888/"] = "http://localhost:8888/";
			testDct["http://127.0.0.1:8888/"] = "http://127.0.0.1:8888/";

			//testDct["http://supermariobroscrossover.com/"] = "http://supermariobroscrossover.com/";
			if (!GameSettings.DEBUG_MODE)
			{
				testDct["http://www.explodingrabbit.com/"] = "http://www.explodingrabbit.com/";
				testDct["http://explodingrabbit.com/"] = "http://www.explodingrabbit.com/";
			}
			for each (var str:String in testDct)
			{
				if ( str == url.substr(0,str.length) )
					return true;
			}
			return false;//*/
			//return true;
		}

		/*override public function addChild(child:DisplayObject):DisplayObject
		{
			super.addChild(child);
			var arr:Array = [];
			for (var i:int = 0; i < numChildren; i++)
			{
				arr.push(getChildAt(i));
			}
			trace("arr: "+arr);
			return child;
		}

		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			super.addChildAt(child, index);
			var arr:Array = [];
			for (var i:int = 0; i < numChildren; i++)
			{
				arr.push(getChildAt(i));
			}
			trace("arr: "+arr);
			return child;
		}

		override public function removeChild(child:DisplayObject):DisplayObject
		{
			super.removeChild(child);
			var arr:Array = [];
			for (var i:int = 0; i < numChildren; i++)
			{
				arr.push(getChildAt(i));
			}
			trace("arr: "+arr);
			return child;
		}

		override public function removeChildAt(index:int):DisplayObject
		{
			var child:DisplayObject = getChildAt(index);
			super.removeChildAt(index);

			trace("arr: "+arr);
			return child;
		}*/
		public function getChildrenArr():Array
		{
			var arr:Array = [];
			for (var i:int = 0; i < numChildren; i++)
			{
				arr.push(getChildAt(i));
			}
			return arr;
		}


	}
}
