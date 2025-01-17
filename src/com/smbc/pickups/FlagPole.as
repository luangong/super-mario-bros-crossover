package com.smbc.pickups
{

	import com.customClasses.*;
	import com.smbc.characters.*;
	import com.smbc.data.GameStates;
	import com.smbc.data.PickupInfo;
	import com.smbc.data.ScoreValue;
	import com.smbc.graphics.*;
	import com.smbc.graphics.fontChars.FontCharScore;
	import com.smbc.ground.*;
	import com.smbc.level.TitleLevel;
	import com.smbc.main.GlobVars;
	import com.smbc.main.LevObj;
	import com.smbc.managers.EventManager;
	import com.smbc.text.TextFieldContainer;

	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class FlagPole extends Pickup
	{
		private const SCORE_LEVEL_1_HEIGHT_PERC:Number = .1;
		private const SCORE_LEVEL_2_HEIGHT_PERC:Number = .2;
		private const SCORE_LEVEL_3_HEIGHT_PERC:Number = .4;
		private const SCORE_LEVEL_4_HEIGHT_PERC:Number = .65;
		private const SCORE_LEVEL_5_HEIGHT_PERC:Number = .9;
		private var scoreLev1Y:Number;
		private var scoreLev2Y:Number;
		private var scoreLev3Y:Number;
		private var scoreLev4Y:Number;
		private var scoreLev5Y:Number;
		protected var xLoc:Number;
		protected var flag:Scenery;
		private var _activated:Boolean;
		private var flagStopLoc:Number;
		public const FLAG_DROP_SPEED:Number = 220;
		private var scoreTxtCont:LevObj
		private var yTop:Number;
		private var yMid:Number;
		private var yBot:Number;
		private const SCORE_TXT_FONT_SIZE:int = 16;
		public function FlagPole(_xLoc:Number):void
		{
			super(PickupInfo.FLAG_POLE);
			xLoc = _xLoc + TILE_SIZE*.5;
			defyGrav = true;
			stopAnim = true;
			hitDistOver = GLOB_STG_BOT/2;
		}
		override public function initiate():void
		{
			super.initiate();
//			hRect.width = 12;
//			hRect.x = -hRect.width/2;
//			setChildPoperty(hRect,"height",TILE_SIZE*9.3);
//			hRect.height = TILE_SIZE*9.3;
//			setChildPoperty(hRect,"y", -hRect.height);
//			hRect.y = -hRect.height;
			nx = xLoc;
			ny = GLOB_STG_BOT - TILE_SIZE*3;
			setHitPoints();
			flagStopLoc = hBot - TILE_SIZE*1.25;
		}
		public function rcvFlag(_flag:Scenery):void
		{
			flag = _flag;
			flag.x = nx - TILE_SIZE;
			flag.y = ny - height + TILE_SIZE/2;

		}
		override protected function updateStats():void
		{
			super.updateStats();
			if (_activated)
			{
				if (flag.y < flagStopLoc)
				{
					flag.y += FLAG_DROP_SPEED*dt;
					var flagY:Number = flag.y;
					if (flagY < yMid)
						scoreTxtCont.y = yMid + (yMid - flagY);
					else if (flagY > yMid)
						scoreTxtCont.y = yMid - (flagY - yMid);
					else if (flagY == yMid)
						scoreTxtCont.y = yMid;
				}
				if (flag.y >= flagStopLoc)
				{
					flag.y = flagStopLoc;
					scoreTxtCont.y = yTop;
					_activated = false;
					player.stopFlagPoleSlide();
				}
			}
		}
		public function checkPlayerLoc():void
		{
//			if (player.hBot < hTop )
//			{
//				if (player.hRht >= nx)
//				{
//					player.nx = nx - player.hWidth*.5;
//					player.vx = 0;
//				}
//			}
//			else if (GS_MNGR.gameState == GS_PLAY && player.hRht >= hLft)
//				EventManager.EVENT_MNGR.touchedFlagPole();
		}
		// called by player
		override public function touchPlayer(char:Character):void
		{
			if (stopHit)
				return;
			stopHit = true;
			_activated = true;
			yTop = flag.y;
			yBot = flagStopLoc;
			yMid = (yBot + yTop)*.5;
			scoreLev1Y = hBot - hHeight*SCORE_LEVEL_1_HEIGHT_PERC;
			scoreLev2Y = hBot - hHeight*SCORE_LEVEL_2_HEIGHT_PERC;
			scoreLev3Y = hBot - hHeight*SCORE_LEVEL_3_HEIGHT_PERC;
			scoreLev4Y = hBot - hHeight*SCORE_LEVEL_4_HEIGHT_PERC;
			scoreLev5Y = hBot - hHeight*SCORE_LEVEL_5_HEIGHT_PERC;
			var pointAmt:int;
			if (player.hMidY <= scoreLev5Y)
				pointAmt = ScoreValue.FLAG_POLE_HEIGHT_5;
			else if (player.hMidY <= scoreLev4Y)
				pointAmt = ScoreValue.FLAG_POLE_HEIGHT_4;
			else if (player.hMidY <= scoreLev3Y)
				pointAmt = ScoreValue.FLAG_POLE_HEIGHT_3;
			else if (player.hMidY <= scoreLev2Y)
				pointAmt = ScoreValue.FLAG_POLE_HEIGHT_2;
			else
				pointAmt = ScoreValue.FLAG_POLE_HEIGHT_1;
			EVENT_MNGR.addPoints(pointAmt);
			var format:TextFormat = new TextFormat();
			format.font = GlobVars.SCORE_FNT.fontName;
			format.size = SCORE_TXT_FONT_SIZE;
			format.color = 0xFFFFFF;
			var scoreTfc:TextFieldContainer = new TextFieldContainer(FontCharScore.FONT_NUM);
			scoreTfc.text = pointAmt.toString();
			scoreTxtCont = new LevObj();
			scoreTxtCont.addChild(scoreTfc);
			scoreTxtCont.x = hRht;
			scoreTxtCont.y = yBot;
			level.addToLevel(scoreTxtCont);
//			if (level is TitleLevel)
				EventManager.EVENT_MNGR.touchedFlagPole();
		}
		public function set activated(val:Boolean):void
		{
			_activated = val;
		}
		override public function hitCharacter(char:Character,side:String):void
		{

		}

		public function get activated():Boolean
		{
			return _activated;
		}

	}
}
