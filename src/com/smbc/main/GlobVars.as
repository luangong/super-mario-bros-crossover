package com.smbc.main
{

	import com.customClasses.MCAnimator;
	import com.customClasses.TDCalculator;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.SuperMarioBrosCrossover;
	import com.smbc.data.AnimationTimers;
	import com.smbc.data.ScreenSize;
	import com.smbc.level.Level;
	import com.smbc.text.fonts.FontMain000;
	import com.smbc.text.fonts.ScoreFont;

	import flash.display.Stage;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextFormat;

	public class GlobVars
	{
		/* public function GlobVars():void
		{
			// does nothing
		} */
		public static const STAGE:Stage = SuperMarioBrosCrossover.game.stage;
		public static const MAIN_FNT:FontMain000 = new FontMain000();
		public static const TF_MAIN:TextFormat = new TextFormat(MAIN_FNT.fontName,16,0xFFFFFF);
		public static const TXT_DROP_SHADOW:DropShadowFilter = new DropShadowFilter(2,45,0,1,0,0,200);
		public static const SCORE_FNT:ScoreFont = new ScoreFont();
		public static const STAGE_LEFT:int = 0;
		public static const STAGE_TOP:int = 0;
		public static const STAGE_WIDTH:int = ScreenSize.SCREEN_WIDTH;
		public static const STAGE_HEIGHT:int = ScreenSize.SCREEN_HEIGHT;
		public static const TILE_SIZE:int = 32;
		public static const SCALE:Number = 2;
		public static const ANIMATOR:MCAnimator = new MCAnimator();
		public static const ANIM_TMR_FOR_FLASING_ITEMS:CustomTimer = AnimationTimers.ANIM_SLOWEST_TMR;
		public static var level:Level;
		public static const TD_CALC:TDCalculator = new TDCalculator();
		public static const COLOR_WHITE:uint = 0xFFFFFFFF;
		public static const COLOR_PINK:uint = 0xFFFFCEC7;
		public static const ZERO_PT:Point = new Point();
		public static const TRUE_STR:String = "true";
		public static const FALSE_STR:String = "false";

	}
}
