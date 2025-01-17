package com.smbc.projectiles
{
	import com.smbc.characters.Samus;
	import com.smbc.data.AnimationTimers;
	import com.smbc.main.LevObj;

	[Embed(source="../assets/swfs/SmbcGraphics.swf", symbol="SamusGuts")]
	public class SamusGuts extends Projectile
	{
		private const Y_OFFSET_TOP:int = 48;
		private const Y_OFFSET_MID:int = 30;
		private const Y_OFFSET_BOT:int = 12;
		private const X_OFFSET:int = 10;
		private const GRAVITY_TOP:int = 500;
		private const GRAVITY_MID:int = 350;
		private const GRAVITY_BOT:int = 150;
		private const X_SPEED_SAMUS:int = 150;
		private const X_SPEED_ENEMY:int = 300;
		private const Y_SPEED_TOP:int = 200;
		private const Y_SPEED_MID:int = 200;
		private const Y_SPEED_BOT:int = 100;
		private const MAX_X_DIST:int = 100;
		private var endX:int;
		private var typeStr:String;
		private var dir:String;
		private var btwTxt:String = "";
		/*
		1 == top-rht
		2 == mid-rht
		3 == bot-rht
		4 == top-lft
		5 == mid-lft
		6 == bot-lft
		*/
		public function SamusGuts(source:LevObj,typeNum:int)
		{
			super(null,SOURCE_TYPE_NEUTRAL);
			typeStr = typeNum.toString();
			defyGrav = false;
			stopAnim = false;
			mainAnimTmr = AnimationTimers.ANIM_FAST_TMR;
			// set dir
			if (typeNum == 1)
				dir = "top-rht";
			else if (typeNum == 2)
				dir = "mid-rht";
			else if (typeNum == 3)
				dir = "bot-rht";
			else if (typeNum == 4)
				dir = "top-lft";
			else if (typeNum == 5)
				dir = "mid-lft";
			else if (typeNum == 6)
				dir = "bot-lft";
			if ( !(source is Samus) )
				btwTxt = "Enemy";
			gotoAndStop("start"+btwTxt+"_"+typeStr); // set play frame
			// set up stats
			if (dir.indexOf("top") != -1)
			{
				if (source is Samus)
					y = source.ny - Y_OFFSET_TOP;
				else
					y = source.hMidY - 12;
				gravity = GRAVITY_TOP;
				vy = -Y_SPEED_TOP;
			}
			else if (dir.indexOf("mid") != -1)
			{
				if (source is Samus)
					y = source.ny - Y_OFFSET_MID;
				else
					y = source.hMidY + 12;
				gravity = GRAVITY_MID;
				vy = -Y_SPEED_MID;
			}
			else if (dir.indexOf("bot") != -1)
			{
				y = source.ny - Y_OFFSET_BOT;
				gravity = GRAVITY_BOT;
				vy = -Y_SPEED_BOT;
			}
			if (dir.indexOf("rht") != -1)
			{
				x = source.nx + X_OFFSET;
				vx = X_SPEED_SAMUS;
				endX = x + MAX_X_DIST;
			}
			else if (dir.indexOf("lft") != -1)
			{
				x = source.nx - X_OFFSET;
				vx = -X_SPEED_SAMUS;
				endX = x - MAX_X_DIST;
			}
			if ( !(source is Samus) )
				vx *= 2;
		}
		override protected function updateStats():void
		{
			if (dir.indexOf("rht") != -1)
			{
				if (nx > endX) destroy();
			}
			else if (nx < endX) destroy();
			super.updateStats();
		}
		override public function checkFrame():void
		{
			var cf:int = currentFrame;
			if (cf == getLabNum("end"+btwTxt+"_"+typeStr) + 1)
				gotoAndStop("start"+btwTxt+"_"+typeStr);
			super.checkFrame();
		}

	}
}
