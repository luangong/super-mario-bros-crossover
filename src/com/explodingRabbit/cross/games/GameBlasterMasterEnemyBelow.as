package com.explodingRabbit.cross.games
{

	import com.explodingRabbit.cross.data.Consoles;
	import com.explodingRabbit.cross.sound.Song;
	import com.smbc.data.Themes;
	import com.smbc.errors.SingletonError;
	import com.smbc.graphics.ThemeGroup;

	import flash.utils.Dictionary;

	public class GameBlasterMasterEnemyBelow extends Game
	{
		private static var instance:Game;

		public function GameBlasterMasterEnemyBelow(gameNum:int, skinSetNum:int = -1)
		{
			super("Blaster Master: Enemy Below", "Sunsoft", Consoles.gameBoy, gameNum, "BM: Enemy Below", skinSetNum);
			if (instance)
				throw new SingletonError();
			instance = this;
		}

		[Embed(source="../../../../../assets/audio/seq/gbs/BlasterMasterEnemyBelow.gbs", mimeType="application/octet-stream")]
		private const Gbs:Class;
		private const VOLUME:int = 60;

		private const TG_OVERWORLD:ThemeGroup = addThemeGroup( 1, 1 );

		public const SngArea1Overworld:Song = addSong( Gbs, 1, null, VOLUME );
		public const SngArea2UnderGround:Song = addSong( Gbs, 2, null, VOLUME );
		public const SngArea3Robots:Song = addSong( Gbs, 3, null, VOLUME );
		public const SngArea4Frog:Song = addSong( Gbs, 4, null, VOLUME );
		public const SngArea5Water:Song = addSong( Gbs, 5, null, VOLUME );
		public const SngArea6:Song = addSong( Gbs, 6, null, VOLUME );
		public const SngArea7:Song = addSong( Gbs, 7, null, VOLUME );
		public const SngArea8Final:Song = addSong( Gbs, 8, null, VOLUME );
		public const SngBossEasy:Song = addSong( Gbs, 9, null, VOLUME );
		public const SngBossHard:Song = addSong( Gbs, 10, null, VOLUME );
		public const SngIntro:Song = addSong( Gbs, 11, null, VOLUME );
		public const SngEnding:Song = addSong( Gbs, 12, null, VOLUME );
		public const SngVictory:Song = addSong( Gbs, 13, null, VOLUME );
		public const SngGameOver:Song = addSong( Gbs, 14, null, VOLUME );

		override protected function setUpLevelThemes():void
		{

		}
		override protected function createPlayList():void
		{
			addOverridableMusicTypes(LT_NORMAL);

			addToTypePlayList(LT_CASTLE, SngArea4Frog);
			addToTypePlayList(LT_CHEEP_CHEEP, SngArea3Robots);
			addToTypePlayList(LT_COIN_HEAVEN, SngArea5Water);
			addToTypePlayList(LT_INTRO, SngArea8Final);
			addToTypePlayList(LT_NORMAL, SngArea1Overworld);
			addToTypePlayList(LT_PIPE_BONUS, SngArea2UnderGround);
			addToTypePlayList(LT_PLATFORM, SngArea3Robots);
			addToTypePlayList(LT_UNDER_GROUND, SngArea2UnderGround);
			addToTypePlayList(LT_WATER, SngArea5Water);
			addToTypePlayList(MT_DARK_EPIC, SngArea6);


			addToTypePlayList(BOSS, SngBossEasy);
			addToTypePlayList(CHAR_SEL, SngIntro);
			addToTypePlayList(CHOOSE_CHARACTER, SngArea1Overworld);
			addToTypePlayList(CREDITS, SngEnding);
			addToTypePlayList(DIE, null);
			addToTypePlayList(FINAL_BOSS, SngBossHard);
			addToTypePlayList(GAME_OVER, SngGameOver);
			addToTypePlayList(HURRY, SngArea7);
			addToTypePlayList(STAR, SngBossHard);
			addToTypePlayList(TITLE_SCREEN, SngIntro);
			addToTypePlayList(WIN, SngVictory);
			addToTypePlayList(WIN_CASTLE, SngEnding);

		}
	}
}
