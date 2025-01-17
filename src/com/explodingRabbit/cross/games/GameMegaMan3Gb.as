package com.explodingRabbit.cross.games
{

	import com.explodingRabbit.cross.data.Consoles;
	import com.explodingRabbit.cross.sound.Song;
	import com.smbc.data.Themes;
	import com.smbc.errors.SingletonError;
	import com.smbc.graphics.ThemeGroup;

	import flash.utils.Dictionary;

	public class GameMegaMan3Gb extends Game
	{
		private static var instance:Game;

		public function GameMegaMan3Gb(gameNum:int, skinSetNum:int = -1)
		{
			super("Mega Man III (Game Boy)", "Capcom", Consoles.gameBoy, gameNum, null, skinSetNum);
			if (instance)
				throw new SingletonError();
			instance = this;
		}

		[Embed(source="../../../../../assets/audio/seq/gbs/MegaMan3.gbs", mimeType="application/octet-stream")]
		public const Gbs:Class;
		private const VOLUME:int = 50;

		public const SngStageSelect:Song = addSong( Gbs, 1, null, VOLUME );
		public const SngStageStart:Song = addSong( Gbs, 2, null, VOLUME );
		public const SngShadowMan:Song = addSong( Gbs, 3, null, VOLUME );
		public const SngBossBattle1:Song = addSong( Gbs, 4, null, VOLUME );
		public const SngGeminiMan:Song = addSong( Gbs, 5, null, VOLUME );
		public const SngSnakeMan:Song = addSong( Gbs, 6, null, VOLUME );
		public const SngSparkMan:Song = addSong( Gbs, 7, null, VOLUME );
		public const SngJusticeMarch:Song = addSong( Gbs, 8, null, VOLUME );
		public const SngGameOver:Song = addSong( Gbs, 9, null, VOLUME );
		public const SngBossBatle2:Song = addSong( Gbs, 10, null, VOLUME );
		public const SngVictory:Song = addSong( Gbs, 11, null, VOLUME );
		public const SngMegaManTheme:Song = addSong( Gbs, 12, null, VOLUME );
		public const SngDustMan:Song = addSong( Gbs, 13, null, VOLUME );
		public const SngDiveMan:Song = addSong( Gbs, 14, null, VOLUME );
		public const SngSkullMan:Song = addSong( Gbs, 15, null, VOLUME );
		public const SngDrillMan:Song = addSong( Gbs, 16, null, VOLUME );
		public const SngEnterWilyBase:Song = addSong( Gbs, 17, null, VOLUME );
		public const SngFinalVictory:Song = addSong( Gbs, 18, null, VOLUME );
		public const SngWilyEntrance:Song = addSong( Gbs, 19, null, VOLUME );
		public const SngWilyMarineBase:Song = addSong( Gbs, 20, null, VOLUME );
		public const SngHunterPunk:Song = addSong( Gbs, 21, null, VOLUME );
		public const SngGotWeapon:Song = addSong( Gbs, 22, null, VOLUME );
		public const SngTitle:Song = addSong( Gbs, 23, null, VOLUME );
		public const SngPassword:Song = addSong( Gbs, 24, null, VOLUME );
		public const SngDie:Song = addSong( Gbs, 41, null, VOLUME );


		override protected function createPlayList():void
		{
			addOverridableMusicTypes(LT_NORMAL);

			addToTypePlayList(LT_CASTLE, SngWilyEntrance);
			addToTypePlayList(LT_CHEEP_CHEEP, SngDrillMan);
			addToTypePlayList(LT_COIN_HEAVEN, SngWilyMarineBase);
			addToTypePlayList(LT_INTRO, SngPassword);
			addToTypePlayList(LT_NORMAL, SngSparkMan);
			addToTypePlayList(LT_PIPE_BONUS, SngGotWeapon);
			addToTypePlayList(LT_PLATFORM, SngSnakeMan);
			addToTypePlayList(LT_UNDER_GROUND, SngGeminiMan);
			addToTypePlayList(LT_WATER, SngDiveMan);
			addToTypePlayList(MT_DARK_EPIC, SngSkullMan);

			addToTypePlayList(BOSS, SngBossBattle1);
			addToTypePlayList(CHAR_SEL, SngStageSelect);
			addToTypePlayList(CHOOSE_CHARACTER, SngStageStart);
			addToTypePlayList(CREDITS, SngJusticeMarch);
			addToTypePlayList(DIE, SngDie);
			addToTypePlayList(FINAL_BOSS, SngBossBatle2);
			addToTypePlayList(GAME_OVER, SngGameOver);
			addToTypePlayList(HURRY, SngSnakeMan);
			addToTypePlayList(STAR, null);
			addToTypePlayList(TITLE_SCREEN, SngTitle);
			addToTypePlayList(WIN, SngVictory);
			addToTypePlayList(WIN_CASTLE, SngFinalVictory);

		}
	}
}
