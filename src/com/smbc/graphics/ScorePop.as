package com.smbc.graphics
{
	import com.explodingRabbit.display.CustomMovieClip;
	import com.smbc.data.MovieClipInfo;
	import com.smbc.data.ScoreValue;
	import com.smbc.graphics.fontChars.FontCharScore;
	import com.smbc.level.Level;
	import com.smbc.level.LevelForeground;
	import com.smbc.main.AnimatedObject;
	import com.smbc.main.GlobVars;
	import com.smbc.text.TextFieldContainer;

	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	import flashx.textLayout.formats.FormatValue;

	public class ScorePop extends Sprite
	{
		private var tfc:TextFieldContainer;
		private var endY:Number;
		private const RISE_SPEED:int = 125;
		private const RISE_SPEED_SLOW:int = 58;
		private const RISE_DIST:int = 80;
		private const RISE_DIST_SLOW:int = 42;
		private const FONT_SIZE:uint = 16;
		private var levelForeground:LevelForeground;
		private var vy:Number = 0;
		private var level:Level;

		public function ScorePop(points:int,_x:Number,_y:Number,slow:Boolean = false)
		{
			super();
			if (points != ScoreValue.EARN_NEW_LIFE_NUM_VAL)
			{
				tfc = new TextFieldContainer(FontCharScore.FONT_NUM);
				tfc.text = points.toString();
				tfc.x -= tfc.width/2;
				tfc.y -= tfc.height/2;
				addChild(tfc);
			}
			else
			{
				var cmc:CustomMovieClip = new CustomMovieClip( null, null, "OneUp" );
				cmc.x -= cmc.width/2;
				cmc.y -= cmc.height/2;
				addChild(cmc);
			}
			level = Level.levelInstance;
			x = _x + level.x;
			y = _y;
			if (!slow)
			{
				vy = -RISE_SPEED;
				endY = y - RISE_DIST;
			}
			else
			{
				vy = -RISE_SPEED_SLOW;
				endY = y - RISE_DIST_SLOW;
			}
			levelForeground = level.foreground;
			levelForeground.addScorePop(this);
		}
		public function update():void
		{
			y += vy * level.dt;
			if (y < endY)
				destroy();
		}
		public function destroy():void
		{
			levelForeground.removeScorePop(this);
			if (parent)
				parent.removeChild(this);
		}
	}
}
