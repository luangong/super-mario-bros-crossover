package com.smbc.graphics
{

	import com.explodingRabbit.display.CustomMovieClip;
	import com.explodingRabbit.utils.CustomDictionary;
	import com.smbc.level.Level;
	import com.smbc.main.GlobVars;
	import com.smbc.managers.GraphicsManager;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.sampler.getLexicalScopes;
	import flash.utils.Timer;

	public class Background extends Sprite
	{
		public static const TYPE_BG:String = "bg";
		public static const TYPE_FG:String = "fg";
		public static var COLOR_BLACK:int = 2;
		public static var COLOR_DARK_BLUE:int = 3;
		public static var COLOR_LIGHT_BLUE:int = 5;
		public static var COLOR_RED:int = 4;
		public static var COLOR_SKY_BLUE:int = 1;
		private static const Y_OFS:int = -14;
		public static const SCROLL_SPEED_STATIONARY:int = 0;
		public static const SCROLL_SPEED_NORMAL:int = 1;
		protected var itemDct:CustomDictionary = new CustomDictionary();
		private var _scrollSpeed:Number;
		private var _repeat:Boolean;
		private var graphicClass:Class;
		private var animTmr:Timer;
		private var animSpeed:int;
		private var animated:Boolean;
		public var masterBmp:Bitmap;
		private var masterBmd:BitmapData;
		private var masterBmdClean:BitmapData;
		public var skinNum:int;
		public var themeNum:int;
		public var setNum:int;
		public var layerNum:int;
		public var type:String;
		public var bgXAtTeleport:Number = 0;
		public var getNewLevelX:Boolean;
		public var levelXAfterTeleport:Number = 0;
		private var shortClassName:String;
		private var xLeftSide:int;
		private var xRightSide:int;

		private var bgWidth:Number;

		public function Background( graphicClass:Class, scrollSpeed:Number = 1, repeat:Boolean = true, animSpeed:int = 0, shortClassName:String = null)
		{
			super();
		 	_scrollSpeed = scrollSpeed;
			_repeat = repeat;
			this.graphicClass = graphicClass;
			this.animSpeed = animSpeed;
			this.shortClassName = shortClassName;
			var obj:DisplayObject = new graphicClass();
			if (obj is Bitmap)
				masterBmp = Bitmap(obj);
			else //if (obj is MovieClip)
			{
				animated = true;
				var mc:CustomMovieClip = new CustomMovieClip(null,null,shortClassName);
				masterBmp = new Bitmap(mc.masterObj.masterBmd);
//				trace("mc.totalframes: "+mc.totalFrames);
				/*var n:int = mc.numChildren;
				for (var i:int = 0; i < n; i++)
				{
					var child:DisplayObject = mc.getChildAt(i);
					if (child is Bitmap)
					{
						masterBmp = Bitmap(child);
						break;
					}
				}*/
			}
			masterBmd = masterBmp.bitmapData;
			masterBmdClean = masterBmd.clone();
			//initiateGraphic();
		}
		public function initiateGraphic():DisplayObject
		{
			var obj:DisplayObject;
			if (!animated)
			{
				obj = new graphicClass();
				obj.scaleX = 2;
				obj.scaleY = 2;
			}
			else
				obj = new CustomMovieClip(null,null,shortClassName);
			obj.y += Y_OFS;
			addChild(obj);
			if (obj is Bitmap)
				Bitmap(obj).bitmapData = masterBmd;
			if (obj is CustomMovieClip)
			{
				var mc:CustomMovieClip = obj as CustomMovieClip;
				mc.stop();
				itemDct.addItem(mc);
				var ni:int = mc.totalFrames;
				var nj:int = mc.numChildren;
				for (var i:int = 0; i < ni; i++)
				{
					mc.gotoAndStop(i + 1);
					for (var j:int; j < nj; j++)
					{
						var child:DisplayObject = mc.getChildAt(j);
						if (child is DisplayObjectContainer)
						{
							var cont:DisplayObjectContainer = child as DisplayObjectContainer;
							if (cont.numChildren)
							{
								var child2:DisplayObject = cont.getChildAt(0);
								if (child2 is Bitmap)
									Bitmap(child2).bitmapData = masterBmd;
							}
						}
					}
				}
			}
			return obj;
		}
		private function animTmrHandler(event:TimerEvent):void
		{
			for each (var mc:CustomMovieClip in itemDct)
			{
				var cf:int = mc.currentFrame;
				if (cf != mc.totalFrames)
					mc.gotoAndStop(cf + 1);
				else
					mc.gotoAndStop(1);
			}
		}
		public function activate():void // called by LevelBackground
		{
			for (var i:int; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				removeChild(child);
				i--;
				itemDct.clear();
			}
			resetOffsets();
			var bmdRect:Rectangle = masterBmdClean.rect;
			masterBmd.fillRect(bmdRect,0);
			masterBmd.copyPixels(masterBmdClean,bmdRect,bmdRect.topLeft);
			initiateGraphic();
			if (_repeat)
			{
				bgWidth = masterBmdClean.width*GraphicsManager.BMD_SCALE;
				var num:Number = Level.levelInstance.mapWidth*_scrollSpeed;
				var totalWidth:Number = bgWidth;
				while (totalWidth < num)
				{
					var nObj:DisplayObject = initiateGraphic();
					nObj.x = totalWidth;
					totalWidth += bgWidth;
				}
				xLeftSide = 0;
				xRightSide = totalWidth;
			}
			if (animSpeed > 0 && !animTmr)
			{
				animTmr = new Timer(animSpeed);
				animTmr.addEventListener(TimerEvent.TIMER,animTmrHandler,false,0,true);
				animTmr.start();
			}
		}

		private function resetOffsets():void
		{
			levelXAfterTeleport = 0;
			bgXAtTeleport = 0;
			getNewLevelX = false;
		}
		public function checkIfNeedsExtension():void
		{
			var globLft:Number = x - Math.abs(xLeftSide);
			var globRht:Number = x + xRightSide;
			var obj:DisplayObject;
			if (globLft > GlobVars.STAGE_LEFT)
			{
				obj = initiateGraphic();
				obj.x = xLeftSide - bgWidth;
				xLeftSide = obj.x;
			}
			else if (globRht < GlobVars.STAGE_WIDTH)
			{
				obj = initiateGraphic();
				obj.x = xRightSide;
				xRightSide += bgWidth;
			}
//			trace("globLft: "+globLft+" globRight: "+globRht+" leftSide: "+xLeftSide+" rightSide: "+xRightSide);
		}
		public function deactivate():void
		{
			if (parent)
				parent.removeChild(this);
			if (itemDct)
				itemDct.clear();
			if (animTmr)
			{
				animTmr.stop();
				animTmr.removeEventListener(TimerEvent.TIMER,animTmrHandler);
				animTmr = null;
			}
			resetOffsets();
		}
		/*public function refresh():void // called while active
		{
			activate();
		}*/
		public function get scrollSpeed():Number
		{
			return _scrollSpeed;
		}

		public function get repeat():Boolean
		{
			return _repeat;
		}

		public function redraw():void
		{
			for each (var cmc:CustomMovieClip in itemDct)
			{
				cmc.masterObj.redraw();
				return;
			}

		}
	}
}
