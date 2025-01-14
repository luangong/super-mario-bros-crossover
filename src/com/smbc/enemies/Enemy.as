package com.smbc.enemies
{
	import com.explodingRabbit.cross.gameplay.statusEffects.StatFxFlash;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatFxFreeze;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatFxInvulnerable;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatFxKnockBack;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatFxStop;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatusEffect;
	import com.explodingRabbit.cross.gameplay.statusEffects.StatusProperty;
	import com.explodingRabbit.display.CustomMovieClip;
	import com.explodingRabbit.utils.CustomDictionary;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.characters.*;
	import com.smbc.characters.base.MegaManBase;
	import com.smbc.data.AnimationTimers;
	import com.smbc.data.Cheats;
	import com.smbc.data.DamageValue;
	import com.smbc.data.Difficulties;
	import com.smbc.data.EnemyInfo;
	import com.smbc.data.GameSettings;
	import com.smbc.data.RandomDropGenerator;
	import com.smbc.data.ScoreValue;
	import com.smbc.data.SoundNames;
	import com.smbc.enums.EnemySpeed;
	import com.smbc.graphics.BillSimpleGraphics;
	import com.smbc.graphics.LinkSword;
	import com.smbc.graphics.MegaManSimpleGraphics;
	import com.smbc.graphics.Palette;
	import com.smbc.graphics.PaletteSheet;
	import com.smbc.graphics.RyuSimpleGraphics;
	import com.smbc.graphics.SamusSimpleGraphics;
	import com.smbc.graphics.SimonSimpleGraphics;
	import com.smbc.graphics.SophiaExplosion;
	import com.smbc.graphics.StarBurst;
	import com.smbc.graphics.BmdInfo;
	import com.smbc.ground.*;
	import com.smbc.interfaces.IAttackable;
	import com.smbc.interfaces.ICustomTimer;
	import com.smbc.level.TitleLevel;
	import com.smbc.main.AnimatedObject;
	import com.smbc.main.LevObj;
	import com.smbc.managers.GraphicsManager;
	import com.smbc.managers.StatManager;
	import com.smbc.projectiles.*;
	import com.smbc.sound.*;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;

	public class Enemy extends AnimatedObject implements IAttackable
	{
		// when shot by megaMan, everything changes to white/yellow except black lines
		public static const ENEMY_WALK_SPEED_NORMAL:int = 65;
		public static const ENEMY_WALK_SPEED_FAST:int = 90;
		private static var GM:GraphicsManager;
		private static const ENEMY_NUM_PROPERY_NAME:String = "ENEMY_NUM";
		protected static const FL_COLOR_PALETTE:String = "colorPalette";
		public static const NUM_FLASH_COLORS:int = 3; // original is 0, so there are three other colors
		protected var defaultWalkSpeed:int = ENEMY_WALK_SPEED_NORMAL;
		private const MAX_COLOR_VALUE:int = 255;
		private const MIN_COLOR_VALUE:Number = .0000001;
		protected const SV_STOMP_SEQ_MAX:int = ScoreValue.STOMP_SEQ_MAX;
		protected const SV_DOUBLE_STOMP:int = ScoreValue.DOUBLE_STOMP;
		private const F_CR_1_RED_R:Number = 255 / MAX_COLOR_VALUE;
		private const F_CR_1_RED_G:Number = 150 / MAX_COLOR_VALUE;
		private const F_CR_1_RED_B:Number = 0;
		private const F_CR_1_GREEN_R:Number = 255 / MAX_COLOR_VALUE;
		private const F_CR_1_GREEN_G:Number = 254 / MAX_COLOR_VALUE;
		private const F_CR_1_GREEN_B:Number = 161 / MAX_COLOR_VALUE;
		private const F_CR_1_BLUE_R:Number = 183 / MAX_COLOR_VALUE;
		private const F_CR_1_BLUE_G:Number = 0;
		private const F_CR_1_BLUE_B:Number = 0;
		private const F_CR_2_RED_R:Number = 255 / MAX_COLOR_VALUE;
		private const F_CR_2_RED_G:Number = 0;
		private const F_CR_2_RED_B:Number = 0;
		private const F_CR_2_GREEN_R:Number = 255 / MAX_COLOR_VALUE;
		private const F_CR_2_GREEN_G:Number = 255 / MAX_COLOR_VALUE;
		private const F_CR_2_GREEN_B:Number = 255 / MAX_COLOR_VALUE;
		private const F_CR_2_BLUE_R:Number = 0;
		private const F_CR_2_BLUE_G:Number = 134 / MAX_COLOR_VALUE;
		private const F_CR_2_BLUE_B:Number = 3 / MAX_COLOR_VALUE;
		private const F_CR_3_RED_R:Number = 0;
		private const F_CR_3_RED_G:Number = 116 / MAX_COLOR_VALUE;
		private const F_CR_3_RED_B:Number = 197 / MAX_COLOR_VALUE;
		private const F_CR_3_GREEN_R:Number = 180 / MAX_COLOR_VALUE;
		private const F_CR_3_GREEN_G:Number = 197 / MAX_COLOR_VALUE;
		private const F_CR_3_GREEN_B:Number = 255 / MAX_COLOR_VALUE;
		private const F_CR_3_BLUE_R:Number = 0;
		private const F_CR_3_BLUE_G:Number = 0;
		private const F_CR_3_BLUE_B:Number = 0;
		public const MIN_HIT_DELAY_TMR:CustomTimer = new CustomTimer(250,1);
		private static const MIN_HIT_DELAY_TMR_DUR_LINK:int = 350;
		private static const MIN_HIT_DELAY_TMR_DUR_RYU:int = 250;
		public static const SEP_STR:String = "_";
		public static const FLASH_STR:String = "flash";
		internal var numColors:uint;
		internal var colorNum:uint;
		public var xSpeedStuck:Number;
		protected var touchedWall:Boolean;
		private var cielingDisplace:Number = 100;
		internal var falling:Boolean;
		internal var enemyGravDef:int = 1300;
		internal var enemyVYMaxPsvDef:int = 800;
		public var stunned:Boolean;
		protected var frozen:Boolean;
		public var BOOM_STUN_TMR:CustomTimer = new CustomTimer(3000,1);
		public var stompable:Boolean;
		protected var stompKills:Boolean = true;
		protected var forceDefaultDeath:Boolean;
		protected var dropsItems:Boolean = true;
		protected var SFX_GAME_KICK_SHELL:String = SoundNames.SFX_GAME_KICK_SHELL;
		protected var SFX_GAME_STOMP:String = SoundNames.SFX_GAME_STOMP;
		protected var scoreStomp:int = 100;
		protected var scoreAttack:int = 200;
		public var scoreStar:int = 200;
		protected var scoreBelow:int = 100;
		public static const SP_Y_OFFSET:uint = 50;
		private const DIE_BOOST_X:int = 100;
		private const DIE_BOOST_Y:int = 200;
		private const ANIM_TMR_FOR_FLASHING:CustomTimer = AnimationTimers.ANIM_FAST_TMR;
		protected var _health:int;
		protected const ATK_STUN_TMR_DUR:int = 400;
		protected const ATK_STUN_TMR:CustomTimer = new CustomTimer(ATK_STUN_TMR_DUR,1);
		protected var changeColorNum:int = 1;
		protected var resetColorNextCycle:Boolean;
		protected var _currentlyChangingColor:Boolean;
		protected const ANIM_FAST_TMR:CustomTimer = AnimationTimers.ANIM_FAST_TMR;
		protected var oRdFrameLabel:String;
		protected var oRdCurrentFrame:int;
		protected var stunStopAnimStr:String;
		private const TRUE_STR:String = "true";
		private var flashWhiteTmr:CustomTimer;
		private const FLASH_WHITE_TMR_DUR:int = 40;
		protected var lhTopSaved:Number;
		protected var lhBotSaved:Number;
		protected var lhLftSaved:Number;
		protected var lhRhtSaved:Number;
		protected var lhMidXSaved:Number;
		protected var lhMidYSaved:Number;
		protected var lhWidthSaved:Number;
		protected var lhHeightSaved:Number;
		public var enemyNum:int;
		private var fakeGround:SimpleGround;
		private static const RYU_CLIMB_STATE:String = Ryu.ST_CLIMB;

		public function Enemy()
		{
			super();
			if (!GM)
				GM = GraphicsManager.INSTANCE;
			enemyNum = classObj[ENEMY_NUM_PROPERY_NAME];
			overwriteInitialStats();
			dosBot = true;
			if (STAT_MNGR.curCharNum == Link.CHAR_NUM)
				MIN_HIT_DELAY_TMR.delay = MIN_HIT_DELAY_TMR_DUR_LINK;
			else if (STAT_MNGR.curCharNum == Ryu.CHAR_NUM)
				MIN_HIT_DELAY_TMR.delay = MIN_HIT_DELAY_TMR_DUR_RYU;
			MIN_HIT_DELAY_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,minHitDelayTmrHandler,false,0,true);
			addTmr(MIN_HIT_DELAY_TMR);
			ACTIVE_ANIM_TMRS_DCT.addItem(ANIM_TMR_FOR_FLASHING);
			hitTestTypesDct.addItem(HT_ENEMY);
			addHitTestableItem(HT_CHARACTER);
			addHitTestableItem(HT_ENEMY);
			addHitTestableItem(HT_PROJECTILE_CHARACTER);
			addHitTestableItem(HT_BRICK);
			addHitTestableItem(HT_GROUND_NON_BRICK);
			addHitTestableItem(HT_PLATFORM);
			addProperty( new StatusProperty(PR_DAMAGES_PLAYER_AGG) );
			addProperty( new StatusProperty(PR_FREEZE_PAS) );
			addProperty( new StatusProperty(PR_STOP_PAS) );
		}

		override public function initiate():void
		{
			super.initiate();
			updDirection();
		}


		protected function overwriteInitialStats():void
		{
			if (GameSettings.enemySpeed == EnemySpeed.Fast)
				defaultWalkSpeed = ENEMY_WALK_SPEED_FAST;
		}

		override protected function addedToStageHandler(e:Event):void
		{
			if (player.dead && !level.player.fellInPit)
				return;
			else
				super.addedToStageHandler(e);
		}
		override protected function updateStats():void
		{
			super.updateStats();
			if (cState != ST_DIE)
			{
				checkState();
				moveEnemy();
			}
			if (resetColorNextCycle)
			{
				resetColor();
				resetColorNextCycle = false;
			}
			touchedWall = false;
			stuckInEnemy = false;
		}
		public function stomp():void
		{
			if ( !(level is TitleLevel) && (!stompable || !player.canStomp || player.nonInteractive || cState == ST_DIE) )
				return;
			if ( !(level is TitleLevel) )
				STAT_MNGR.numEnemiesStomped++;
			resetColor();
			SND_MNGR.playSound(SFX_GAME_STOMP);
			_currentlyChangingColor = false;
			level.removeColorObject(this);
			stunned = false;
			var doubleStomp:Boolean = false;
			if ( player.stompedEnemyThisCycle && ( this is Goomba || this is Beetle) )
				doubleStomp = true;
			if (!(this is BulletBill))
				player.stompEnemy();
			var stompSeqAmt:int = -1;
			var numPoints:int = 0;
			switch (player.numContStomps)
			{
				case 0:
				{
					stompSeqAmt = -1;
					break;
				}
				case 1:
				{
					stompSeqAmt = ScoreValue.STOMP_SEQ_1;
					break;
				}
				case 2:
				{
					stompSeqAmt = ScoreValue.STOMP_SEQ_2;
					break;
				}
				case 3:
				{
					stompSeqAmt = ScoreValue.STOMP_SEQ_3;
					break;
				}
				case 4:
				{
					stompSeqAmt = ScoreValue.STOMP_SEQ_4;
					break;
				}
				case 5:
				{
					stompSeqAmt = ScoreValue.STOMP_SEQ_5;
					break;
				}
				case 6:
				{
					stompSeqAmt = ScoreValue.STOMP_SEQ_6;
					break;
				}
				case 7:
				{
					stompSeqAmt = ScoreValue.STOMP_SEQ_7;
					break;
				}
				case 8:
				{
					stompSeqAmt = ScoreValue.STOMP_SEQ_8;
					break;
				}
				case 9:
				{
					stompSeqAmt = ScoreValue.STOMP_SEQ_9;
					break;
				}
				case 10:
				{
					stompSeqAmt = ScoreValue.STOMP_SEQ_10;
					break;
				}
				default:
				{
					stompSeqAmt = SV_STOMP_SEQ_MAX;
					break;
				}
			}
			if (stompSeqAmt > scoreStomp || stompSeqAmt == SV_STOMP_SEQ_MAX)
				numPoints = stompSeqAmt;
			else
				numPoints = scoreStomp;
			if (doubleStomp && SV_DOUBLE_STOMP > numPoints && numPoints != SV_STOMP_SEQ_MAX)
				numPoints = SV_DOUBLE_STOMP;
			level.scorePop(numPoints,nx,hTop-SP_Y_OFFSET);
			// stomp enemy
		}

		override public function gotoAndStop(frame:Object, scene:String=null):void
		{
			if (flashWhiteTmr)
				resetColor();
			super.gotoAndStop(frame, scene);
			if (flashWhiteTmr)
				flashWhiteChangeColor();
		}
		// DIE
		public function die(dmgSrc:LevObj = null):void
		{
			if (cState == ST_DIE)
				return;
			if (getProperty(PR_PIERCE_PAS) != null)
				STAT_MNGR.numArmoredEnemiesDefeated++;
			removeAllProperties();
			removeAllStatusEffects();
			removeAllHitTestableItems();
			if (level != TitleLevel.instance)
				STAT_MNGR.numEnemiesDefeated++;
			level.removeColorObject(this);
			if (dropsItems)
			{
				RandomDropGenerator.checkDropItem(player.charNameCaps,this);
			}
			if (!forceDefaultDeath)
			{
				if (dmgSrc is SophiaBullet)
					level.addToLevel(new SophiaExplosion(this));
				else if (dmgSrc is MegaManProjectile || dmgSrc is MegaManBase || dmgSrc is BrickPiece)
					level.addToLevel( new MegaManSimpleGraphics( this, MegaManSimpleGraphics.TYPE_ENEMY_EXPLOSION ) );
				else if (dmgSrc is Link || dmgSrc is LinkProjectile)
					level.addToLevel( new LinkSimpleGraphics( this, LinkSimpleGraphics.TYPE_ENEMY_EXPLOSION ) );
				else if (dmgSrc is Simon || dmgSrc is SimonProjectile)
					level.addToLevel( new SimonSimpleGraphics( this, SimonSimpleGraphics.TYPE_DESTROY_FLAME ) );
				else if (dmgSrc is SamusShot || dmgSrc is SamusBomb || dmgSrc is Samus)
					level.addToLevel( new SamusSimpleGraphics( this, SamusSimpleGraphics.TYPE_ENEMY_EXPLOSION, dmgSrc ) );
				else if (dmgSrc is BillBullet)
					level.addToLevel( new BillSimpleGraphics( this, BillSimpleGraphics.TYPE_ENEMY_EXPLOSION ) );
				else if (dmgSrc is Ryu || dmgSrc is RyuProjectile)
				{
					level.addToLevel( new RyuSimpleGraphics( this, RyuSimpleGraphics.TYPE_ENEMY_EXPLOSION ) );
					destroy();
					return;
				}
				else if (dmgSrc is MarioFireBall)
					level.addToLevel( new StarBurst(this, StarBurst.TYPE_FIREBALL, dmgSrc) );
				if (destroyed)
					return;
			}
			_currentlyChangingColor = false;
			changeColorThisCycle = false;
			SND_MNGR.playSound(SFX_GAME_KICK_SHELL);
			stopUpdate = false;
			stopHit = true;
			stopAnim = true;
			defyGrav = false;
			if (!resetColorNextCycle)
				resetColor();
			if (BOOM_STUN_TMR.running)
				BOOM_STUN_TMR.stop();
			if (ATK_STUN_TMR.running)
				ATK_STUN_TMR.stop();
			ACTIVE_ANIM_TMRS_DCT.clear();
			mainAnimTmr = null;
			stunned = false;
			lockState = false;
			setState(ST_DIE);
			lockState = true;
			if (level.waterLevel)
				vx = 0;
			else
			{
				if (player.nx > nx)
					vx = -DIE_BOOST_X;
				else
					vx = DIE_BOOST_X;
			}
			scaleY = -1;
			vy = -DIE_BOOST_Y;
			ny -= height;
			y = ny;
			setHitPoints();
			onGround = false;
			destroyOffScreen = true;
			stopTimers();
		}
		// MOVEENEMY
		internal function moveEnemy():void
		{
			// move enemy
		}
		// CHECKSTATE
		override protected function checkState():void
		{
			/*if (!stuckInEnemy)
			{
				if (vx > 0) vx = xSpeed;
				else if (vx < 0) vx = -xSpeed;
			}*/
			if (!(this is Bowser) && !(this is HammerBro))
			{
				if (vx > 0)
					scaleX = 1;
				else if (vx < 0)
					scaleX = -1;
			}
			// check state
		}
		override public function groundAbove(g:Ground):void {
			hitCeiling = true;
			ny = g.hBot + hHeight;
			if (!onGround)
			{
				vy = 0;
				//ny += 5;
			}
			super.groundAbove(g);
		}
		override public function groundOnSide(g:Ground,side:String):void
		{
			if (side == "left")
			{
				if (vx < 0 && !touchedWall)
					vx = -vx;
				nx = g.hRht + hWidth/2;
				wallOnLeft = true;
			}
			else if (side == "right")
			{
				if (vx > 0 && !touchedWall)
					vx = -vx;
				wallOnRight = true;
				nx = g.hLft - hWidth/2;
			}
			updDirection();
			touchedWall = true;
			super.groundOnSide(g,side);
		}
		// CONVLAB
		public function convLab(_fLab:String):String
		{
			return _fLab;
			/*var str:String;
			if (numColors <= 1 || !numColors)
				return _fLab;
			else
			{
				str = "_" + colorNum.toString();
				return _fLab.concat(str);
			}*/
		}
		// GETLABNUM
		override public function getLabNum(_fLab:String):uint
		{
			return super.getLabNum(convLab(_fLab));
		}
		// SETSTOPFRAME
		internal function setStopFrame(_stopFrame:String):void
		{
			if (currentFrameLabel != convLab(_stopFrame)) gotoAndStop(convLab(_stopFrame));
			stopAnim = true;
		}
		// SETPLAYFRAME
		internal function setPlayFrame(_stopFrame:String):void
		{
			if (currentFrameLabel != convLab(_stopFrame))
				gotoAndStop(convLab(_stopFrame));
			stopAnim = false;
		}
		protected function moveToFrame(_frame:String):void
		{
			gotoAndStop( convLab(_frame) );
		}

		protected function saveLastHitPoints():void
		{
			lhTopSaved = lhTop;
			lhBotSaved = lhBot;
			lhLftSaved = lhLft;
			lhRhtSaved = lhRht;
			lhMidXSaved = lhMidX;
			lhMidYSaved = lhMidY;
			lhWidthSaved = lhWidth;
			lhHeightSaved = lhHeight;
		}
		protected function restoreLastHitPoints():void
		{
			lhTop = lhTopSaved;
			lhBot = lhBotSaved;
			lhLft = lhLftSaved;
			lhRht = lhRhtSaved;
			lhMidX = lhMidXSaved;
			lhMidY = lhMidYSaved;
			lhWidth = lhWidthSaved;
			lhHeight = lhHeightSaved;
		}
		// SHIFTHIT
		override public function shiftHit(mc:LevObj,side:String,pen:Number):void
		{
			if ( getStatusEffect(STATFX_FREEZE) || getStatusEffect(STATFX_STOP) )
				return;
			if (side == "left")
				nx += pen/2 + .2;
			else if (side == "right")
				nx -= pen/2 - .2;
			if (mc is Enemy)
				hitEnemy(mc as Enemy,side);
			else if (mc is Ground)
				groundOnSide(mc as Ground,side);
		}
		override public function hit(mc:LevObj,hType:String):void
		{
			if (mc is Ground && !Ground(mc).visible)
				return;
			else
				super.hit(mc,hType);
		}
		override public function hitEnemy(enemy:Enemy,hType:String):void
		{
			if (cState == ST_DIE || enemy.cState == ST_DIE)
				return;
			if (hType == "left" && vx < 0 && !stuckInEnemy)
				vx = -vx;
			else if (hType == "right" && vx > 0 && !stuckInEnemy)
				vx = -vx;
			updDirection();
//			var statFxKnockBack:StatFxKnockBack = getStatusEffect(STATFX_KNOCK_BACK) as StatFxKnockBack;
//			if (statFxKnockBack)
//				statFxKnockBack.hitEnemy(enemy,hType);
		}
		protected function updDirection():void
		{
			if (vx > 0)
				scaleX = 1;
			else if (vx < 0)
				scaleX = -1;
		}
		override public function hitProj(proj:Projectile):void
		{
			if (cState == ST_DIE || proj.HIT_OBJS_DCT[this] || proj.getProperty(PR_PASSTHROUGH_ALWAYS) )
				return;
			level.addToProjHitArr(proj,this);
		}
		override public function confirmedHitProj(proj:Projectile):void
		{
			if (cState == ST_DIE)
				return;
			var damaged:Boolean;
			var healthStart:int = _health;
			if ( checkAttackProps(proj) )
			{
				takeDamage(proj.damageAmt,proj);
				if (proj.damageAmt > 0)
					damaged = true;
			}
//			applyNewStatusEffects();
			proj.confirmedHit(this,damaged);
		}
		protected function takeDamage(dmg:int,dmgSrc:LevObj = null):void
		{
			_health -= int(dmg*DamageValue.dmgMult);
			if (_health <= 0)
			{
				level.scorePop(scoreAttack,nx,hTop-SP_Y_OFFSET);
				die(dmgSrc);
			}
		}
		override public function gBounceHit(g:Ground):void
		{
			level.scorePop(scoreBelow,nx,hTop-SP_Y_OFFSET);
			level.addToLevel( new StarBurst(this,StarBurst.TYPE_BELOW) );
			die();
		}
		public function hitByAttack(source:LevObj,dmg:int):void
		{
			if (cState == ST_DIE)
				return;
			if ( checkAttackProps(source) )
				takeDamage(dmg,source);
//			applyNewStatusEffects();
		}
		private function checkAttackProps(attacker:LevObj):Boolean
		{
			if ( getStatusEffect(STATFX_INVULNERABLE) )
				return false;
			var atkrFreezeProp:StatusProperty = attacker.getProperty(PR_FREEZE_AGG);
			if ( getStatusEffect(STATFX_FREEZE) )
			{
				if ( attacker.getProperty(PR_UNFREEZE_AGG) )
					removeStatusEffect(STATFX_FREEZE);
			}
			else if ( atkrFreezeProp && isSusceptibleToProperty( atkrFreezeProp ) )
			{
				addStatusEffect( atkrFreezeProp.getStatusEffectFromValue(this,attacker) );
				return false;
			}
			var attackerPropVec:Vector.<StatusProperty> = attacker.getPropOrderVec();
			var n:int = attackerPropVec.length;
			for (var i:int = 0; i < n; i++)
			{
				var prop:StatusProperty = attackerPropVec[i];
				if ( isSusceptibleToProperty( prop ) )
				{
					var statFx:StatusEffect = prop.getStatusEffectFromValue(this,attacker);
					if (statFx)
						addStatusEffect( statFx );
				}
				else if (prop.type == PR_PIERCE_AGG && !Cheats.allWeaponsPierce) // if not pierced, don't add other effects
					return false;
			}
			return true;
		/*	var prop:StatusProperty = attacker.getProperty(PR_STOP_AGG);
			if ( isSusceptibleToProperty( prop ) )
				addStatusEffect( prop.getStatusEffectFromValue(this) );
			prop = attacker.getProperty(PR_FLASH_AGG);
			if ( isSusceptibleToProperty( prop ) )
				addStatusEffect( prop.getStatusEffectFromValue(this) );
			return true;*/
			/*var shouldBeDamaged:Boolean = true;
			var atkrGetProp:Function = attacker.getProperty;
			if ( atkrGetProp(StatusProperty.STUN) && ( getProperty(PR_STOP_PAS) || atkrGetProp(PR_STUN_ALWAYS) ) )
				stun();
			if (atkrGetProp(StatusProperty.FREEZE) && getProperty(PR_FREEZE_PAS) )
			{
				if ( !freezeCheck() )
					return false;
			}
			if (pierced)
			{
				var prop:StatusProperty = attacker.getProperty(PR_STOP_AGG);
				if ( isSusceptibleToProperty( prop )
					addStatusEffect( prop.getStatusEffectFromValue(this) );
				if ( atkrGetProp(StatusProperty.STALL) && ( getProperty(PR_STALLABLE) || atkrGetProp(PR_STALL_ALWAYS) ) )
				{
					stall(false);
				}
				else if ( atkrHasProp(StatusProperty.FLASH) )
					nonStunFlash();
				if ( atkrHasProp(StatusProperty.FLASH_WHITE) )
					flashWhiteStart();
			}
			else
				shouldBeDamaged = false;
			return shouldBeDamaged;*/
		}
		protected function flashWhiteStart():void
		{
			/*var matrix:Array = new Array();
			matrix = matrix.concat([0, 0, 0, 0, 255]); // red
			matrix = matrix.concat([0, 0, 0, 0, 255]); // green
			matrix = matrix.concat([0, 0, 0, 0, 180]); // blue
			matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
			this.filters = [new ColorMatrixFilter(matrix)];*/
			if (flashWhiteTmr)
				removeFlashWhiteTmr();
			flashWhiteTmr = new CustomTimer(FLASH_WHITE_TMR_DUR,1);
			flashWhiteTmr.addEventListener(TimerEvent.TIMER_COMPLETE,flashWhiteTmrHandler,false,0,true);
			addTmr(flashWhiteTmr);
			flashWhiteTmr.start();
			flashWhiteChangeColor();
		}
		private function flashWhiteChangeColor():void
		{
			visible = false;
			/*var palArr:Array = GM.readPalette(GM.drawingBoardEnemySkinCont.bmd,GraphicsManager.ENEMY_INFO_ARR[enemyNum][GraphicsManager.INFO_ARR_IND_CP]);
			if (!level)
				return;
			var inRow:int = level.theme + 1;
			var outRow:int = 0;
			var n:int = ( palArr[inRow] as Array ).length;
			var outArr:Array = palArr[outRow] as Array;
			var pnt:Point = MegaManBase.ENEMY_CHANGE_COLOR_PNT;
			var playerBmd:BitmapData = GM.masterCharSkinVec[STAT_MNGR.curCharNum].bmd;
			var outColor:uint = playerBmd.getPixel32(pnt.x,pnt.y);
			for (var j:int = 1; j < n; j++)
			{
				outArr[j] = outColor;
			}
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				if (child is Bitmap)
				{
					var bmp:Bitmap = getChildAt(i) as Bitmap;
					var bmd:BitmapData = bmp.bitmapData.clone();
					bmp.bitmapData = bmd;
					GM.recolorSingleBitmap(bmd,palArr, inRow, outRow);
				}
			}*/
		}
		private function flashWhiteTmrHandler(event:TimerEvent):void
		{
			removeFlashWhiteTmr();
			resetColor();
		}
		private function removeFlashWhiteTmr():void
		{
			if (!flashWhiteTmr)
				return;
			flashWhiteTmr.stop();
			flashWhiteTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,flashWhiteTmrHandler);
			removeTmr(flashWhiteTmr);
			flashWhiteTmr = null;
		}
		public function changeColor():void
		{
			setUpCommonPalettes();
			flash();
			/*changeColorNum++;
			if (changeColorNum > NUM_FLASH_COLORS)
				changeColorNum = 0;
//			var paletteSheet:PaletteSheet = BmdInfo.getMainPaletteSheet( GameSettings.getEnemySkinLimited() );
//			var palette:Palette = paletteSheet.getPaletteFromRow( EnemyInfo[shortClassName], 0, PaletteSheet.THEME_TYPE_ENEMY );
			var palette:Palette = getPaletteByRow(0);
			resetColor(true);
			if (changeColorNum == 0)
				return;
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				if (child is Bitmap)
				{
					var bmp:Bitmap = getChildAt(i) as Bitmap;
					var bmd:BitmapData = bmp.bitmapData.clone();
					bmp.bitmapData = bmd;
					GM.recolorSingleBitmap(bmd,palette,palette,0,changeColorNum);
				}
			}*/
		}
		override public function animate(ct:ICustomTimer):Boolean
		{

			var bool:Boolean = super.animate(ct);
			if (_currentlyChangingColor && ct == ANIM_TMR_FOR_FLASHING)
				changeColorThisCycle = true;
			return bool;
		}
		private function minHitDelayTmrHandler(event:TimerEvent):void // for Ryu's passthrough projectile
		{
			MIN_HIT_DELAY_TMR.reset();
		}
		override public function resetColor(useCleanBmd:Boolean = false):void
		{
			visible = true;
			relinkBmdToMasterSingleFrame();
			var matrix:Array = new Array();
			matrix = matrix.concat([1, 0, 0, 0, 0]); // red
			matrix = matrix.concat([0, 1, 0, 0, 0]); // green
			matrix = matrix.concat([0, 0, 1, 0, 0]); // blue
			matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha

			var cmFilter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			//var cmFilter2 = new ColorMatrixFilter(matrix2);
			//var filter = new Array();
			//filter.splice(0,1,cmFilter);
			this.filters = [cmFilter];
		}
		/*override public function checkStgPos():void
		{

			super.checkStgPos();
		}*/
		override public function hitCharacter(char:Character,side:String):void
		{
			if (char.starPwr)
			{
				level.scorePop(scoreStar,nx,hTop-SP_Y_OFFSET);
				level.addToLevel( new StarBurst( this, StarBurst.TYPE_STAR ) );
				die();
			}
			else if (side == "top" && !player.nonInteractive)
				stomp();
		}

		override public function cleanUp():void
		{
			super.cleanUp();
			if (fakeGround)
				fakeGround.destroy();
		}

		override protected function removeListeners():void
		{
			super.removeListeners();
			if (flashWhiteTmr)
				flashWhiteTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,flashWhiteTmrHandler);
			MIN_HIT_DELAY_TMR.removeEventListener(TimerEvent.TIMER_COMPLETE,minHitDelayTmrHandler);
		}
		override protected function reattachLsrs():void
		{
			super.reattachLsrs();
			if (flashWhiteTmr)
				flashWhiteTmr.addEventListener(TimerEvent.TIMER_COMPLETE,flashWhiteTmrHandler,false,0,true);
			MIN_HIT_DELAY_TMR.addEventListener(TimerEvent.TIMER_COMPLETE,minHitDelayTmrHandler,false,0,true);
		}
		public function get currentlyChangingColor():Boolean
		{
			return _currentlyChangingColor;
		}
		public function get health():int
		{
			return _health;
		}

	}
}
