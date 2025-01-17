package com.smbc.ground
{
	import com.explodingRabbit.cross.gameplay.statusEffects.StatusProperty;
	import com.explodingRabbit.display.CustomMovieClip;
	import com.explodingRabbit.utils.CustomDictionary;
	import com.explodingRabbit.utils.CustomTimer;
	import com.smbc.characters.*;
	import com.smbc.characters.base.MegaManBase;
	import com.smbc.data.AnimationTimers;
	import com.smbc.data.Cheats;
	import com.smbc.data.DamageValue;
	import com.smbc.data.EnemyInfo;
	import com.smbc.data.GameStates;
	import com.smbc.data.HealthValue;
	import com.smbc.data.MapInfo;
	import com.smbc.data.RandomDropGenerator;
	import com.smbc.data.ScoreValue;
	import com.smbc.data.SoundNames;
	import com.smbc.events.CustomEvents;
	import com.smbc.interfaces.IAttackable;
	import com.smbc.interfaces.ICustomTimer;
	import com.smbc.level.Level;
	import com.smbc.level.TitleLevel;
	import com.smbc.main.*;
	import com.smbc.managers.EventManager;
	import com.smbc.managers.GraphicsManager;
	import com.smbc.pickups.*;
	import com.smbc.projectiles.*;
	import com.smbc.sound.*;

	import flash.events.Event;
	import flash.events.TimerEvent;

	public class Brick extends Ground implements IAttackable
	{
		private static const EVENT_BOUNCE:Event = new Event(CustomEvents.BRICK_BOUNCE);
		private static const EVENT_BREAK:Event = new Event(CustomEvents.BRICK_BREAK);
		public static const BRICKS_TO_BREAK_DCT:CustomDictionary = new CustomDictionary(true);
		public static const BRICKS_TO_BOUNCE_DCT:CustomDictionary = new CustomDictionary(true);
		private static const BRICKS_DCT:CustomDictionary = new CustomDictionary(true);
		public static var masterBrick:Brick;
		private static const FL_BRICK_END:String = "brickEnd";
		public static const FL_BRICK:String = "brick";
		public static var bounceAndBreakNow:Boolean;
		protected const IT_MULTI_COIN:String = "MultiCoin";
		protected const IT_MULTI_COIN_FINISHED:String = IT_MULTI_COIN + "multiCoinFinished";
		protected const IT_MUSHROOM_RED:String = "Mushroom";
		protected const IT_POISON_MUSHROOM:String = "PoisonMushroom";
		protected const IT_ONE_UP_MUSHROOM:String = "OneUpMushroom";
		protected const IT_STAR:String = "Star";
		public static const IT_SINGLE_COIN:String = "Coin";
		protected const IT_VINE:String = "Vine";
		protected const IT_EXPLODING_RABBIT:String = "ExplodingRabbit";
//		SMB Special Items
		protected const IT_HAMMER:String = "Hammer";
		protected const IT_WING:String = "Wing";
		protected const IT_CLOCK:String = "Clock";
		protected const IT_ATOM:String = "Atom";
		protected const IT_HUDSON_BEE:String = "HudsonBee";


		protected static const FL_HIT_MOVING:String = "hitMoving";
		protected static const FL_HIT_RESTING:String = "hitResting";
		public static const GRAVITY:int = 1000;
		public static const BOUNCE_PWR:int = 150;
		internal var bouncing:Boolean;
		internal var yPos:Number;
		internal var color:String;
		public var item:String;
		internal var invisible:Boolean;
		private var coinBrickTmr:CustomTimer;
		private var coinBrickTmrDur:uint = 6000;
		private var lastHit:Boolean;
		protected const SFX_GAME_BRICK_BREAK:String = SoundNames.SFX_GAME_BRICK_BREAK;
		protected const SFX_GAME_HIT_CEILING:String = SoundNames.SFX_GAME_HIT_CEILING;
		protected const SFX_GAME_ITEM_APPEAR:String = SoundNames.SFX_GAME_ITEM_APPEAR;
		protected const SFX_GAME_VINE:String = SoundNames.SFX_GAME_VINE;
		public const BOUNCE_HIT_DCT:CustomDictionary = new CustomDictionary(true);// contains AnimatedObjects
		private const COIN_BRICK_MAX_COINS:int = 15;
		private var coinBrickCtr:int;
		protected var _health:int = HealthValue.BRICK;
		private const MM_ST_SLIDE:String = MegaManBase.ST_SLIDE;
		public var disableThisRoundOnly:Boolean;
		protected const GS_PLAY:String = GameStates.PLAY;
		private static var animEndFrameNum:int;
		private static const NUM_ANIM_FRAMES:int = 4;
		private static var animStartFrameDelay:int;
		protected var animDelCtr:int;
//		private static const BRICK_MAP_FCT_DCT:CustomDictionary = new CustomDictionary(true);
		private var piecesDamage:Boolean;
		{
			EventManager.EVENT_MNGR.addEventListener(CustomEvents.CHANGE_MAP_SKIN, changeMapSkinHandler, false, 0, true);
		}

		public function Brick(_stopFrame:String = null)
		{
			super(_stopFrame);
			setColor(_stopFrame);
			mainAnimTmr = AnimationTimers.ANIM_SLOWEST_TMR;
			_animated = true;
			var itemName:String = Level.ExtractLevelDataProperty(_stopFrame, Level.PROP_CONTAINED_ITEM, true);
			if (itemName == IT_VINE)
			{
				itemName += Level.PROP_SEP + Level.ExtractLevelDataProperty(_stopFrame, Level.PROP_P_TRANS_DEST, false);
				var numberStr:String = Level.ExtractLevelDataProperty(_stopFrame, Level.PROP_NUMBER, false);
				if (numberStr != null)
					itemName += Level.PROP_SEP + numberStr;
			}
			getPickup( itemName );
			hitTestTypesDct.clear();
			hitTestTypesDct.addItem(HT_BRICK);
			if (itemName == null)
				addProperty( new StatusProperty(StatusProperty.TYPE_SUPER_ARM_GRABBABLE_PAS) );
		}
		public static function initiateLevelHandler():void
		{
			masterBrick = new Brick(FL_BRICK);
			masterBrick.initiate();
		}
		protected static function changeMapSkinHandler(event:Event):void
		{
			var gm:GraphicsManager = GraphicsManager.INSTANCE;
//			var palette:Array = gm.readPalette(gm.drawingBoardMapSkinCont.bmd, GraphicsManager.MAP_INFO_ARR[MapInfo.Brick][GraphicsManager.INFO_ARR_IND_CP]);
			var brick:CustomMovieClip = new CustomMovieClip(null,null,"Brick");
			animStartFrameDelay = gm.getFrameDelay( brick.getPaletteByRow(0) );
			animEndFrameNum = NUM_ANIM_FRAMES + brick.convFrameToInt(FL_BRICK) - 1;
			while ( animEndFrameNum > 0 && brick.frameIsEmpty( animEndFrameNum ) )
			{
				animEndFrameNum--;
			}
			masterBrick.changeMapSkinLocalHandler();
//			for each (var fct:Function in BRICK_MAP_FCT_DCT)
//			{
//				fct();
//			}
		}
		private function changeMapSkinLocalHandler():void
		{
			if (!stopAnim)
				gotoAndStop(FL_BRICK);
		}
		internal function setColor(_stopFrame:String):void
		{

		}
		override public function initiate():void
		{
			super.initiate();
			if (this == masterBrick)
				level.ALWAYS_ANIM_DCT.addItem(this);
			else if (classObj == Brick)
				BRICKS_DCT.addItem(this);
		}
		override public function hitAttack():void
		{
			// not sure if this is used. see hitByAttack()
			if (item)
				bounce();
			else
				breakBrick();
		}
		override internal function standingOnGround(ao:AnimatedObject):void
		{
			BOUNCE_HIT_DCT.addItem(ao);
		}
		public function getPickup(_item:String):void
		{
			item = _item;
			if (_item)
				removeProperty( StatusProperty.TYPE_SUPER_ARM_GRABBABLE_PAS );
		}
		override public function hitProj(proj:Projectile):void
		{
			if (disabled || destroyed || proj.doesntHitBricks || proj.getProperty(PR_PASSTHROUGH_ALWAYS) )
				return;
			if (item != IT_MULTI_COIN || ( item == IT_MULTI_COIN && (!proj.getProperty(PR_PASSTHROUGH_DEFEAT) || (proj.getProperty(PR_PASSTHROUGH_DEFEAT) && !proj.HIT_OBJS_DCT[this]) ) ) )
				level.addToProjHitArr(proj,this);
		}
		override public function confirmedHitProj(proj:Projectile):void
		{
			if (disabled || destroyed || disableThisRoundOnly)
				return;
			if (item)
				bounce();
			else
			{
				takeDamage(proj.damageAmt);
			}
			proj.confirmedHit(this);
		}
		override public function hitCharacter(char:Character,side:String):void
		{
			if (char.dead)
				return;
			if (side == "bottom")
			{
				if (stopHit || char.lastOnGround || char.onGround || char.brickState == Character.BRICK_NONE || char.nonInteractive )
					//|| (player is Samus && player.cState == Samus.ST_BALL) || (player is Ryu && player.cState == Ryu.ST_CLIMB) )
					return;

				//if (player is MegaMan && player.cState == MM_ST_SLIDE)
				//	return;
				yPenAmt = char.hMidX - hMidX;
				if (yPenAmt < 0) yPenAmt = -yPenAmt;
				level.gBounceArr.push(this);
			}
		}
		// called by player when hit attack
		public function hitByAttack(source:LevObj,dmg:int):void
		{
//			if ( source.hasProperty(AttackProperties.NON_BRICK) )
//				return;
			if (!disabled)
			{
				if (item)
					bounce();
				else
					breakBrick();
			}
		}
		public function takeDamage(dmg:int):void
		{
			_health -= int(dmg*DamageValue.dmgMult);
			if (_health <= 0)
				breakBrick();
		}
		public function hitCharacterBounceOrBreak():void
		{
			//if (!item && (((player is Mario || player is MegaMan) && player.pState > 1) || (player is Samus && player.pState != 1 && player.cState != Samus.ST_BALL)))
			if (!item && player.brickState == Character.BRICK_BREAKER)
				breakBrick();
			else
				bounce();
		}
		// called once coordinates are set
		public function flag():void
		{
			yPos = this.y;
		}
		public function breakBrick(piecesDamage:Boolean = false):void
		{
			if (piecesDamage)
				this.piecesDamage = true;
			if (disabled)
				return;
			if (item)
			{
				bounce();
				return;
			}
			if ( !(level is TitleLevel) )
				STAT_MNGR.numBricksBroken++;
			BRICKS_TO_BREAK_DCT.addItem(this);
			destroyed = true;
			if (!bounceAndBreakNow)
				return;
			if (player.canGetAmmoFromBricks)
				RandomDropGenerator.checkDropItem(player.charNameCaps,this);
			hitObjectsAbove();
			var bp1:BrickPiece = new BrickPiece(this,color,"top-left",this.x,this.y,this.piecesDamage);
			var bp2:BrickPiece = new BrickPiece(this,color,"top-right",this.x,this.y,this.piecesDamage);
			var bp3:BrickPiece = new BrickPiece(this,color,"bottom-left",this.x,this.y,this.piecesDamage);
			var bp4:BrickPiece = new BrickPiece(this,color,"bottom-right",this.x,this.y,this.piecesDamage);
			level.addToLevel(bp1);
			level.addToLevel(bp2);
			level.addToLevel(bp3);
			if (!this.piecesDamage)
				level.addToLevelNow(bp4);
			else
				level.addToLevel(bp4);
			BRICKS_TO_BREAK_DCT.removeItem(this);
			dispatchEvent( EVENT_BREAK );
			level.destroy(this);
			if (player is Ryu)
			{
				var ryu:Ryu = player as Ryu;
				if (ryu.cState == Ryu.ST_CLIMB && (ryu.cancelGrappleGroundPos == hRht || ryu.cancelGrappleGroundPos == hLft) )
				{
					if (ryu.hTop <= hBot && ryu.hBot >= hTop)
					{
						ryu.detachFromWall();
						ryu.forceAttachToWall = true;
						level.DESTROY_DCT.removeItem(this);
						cleanUp(); // makes sure it doesn't get checked for collisions again
						level.checkCollisions(player);
					}
				}
			}
			disabled = true;
			SND_MNGR.playSound(SFX_GAME_BRICK_BREAK);
			EVENT_MNGR.addPoints(ScoreValue.BREAK_BRICK);
		}
		public function bounce():void
		{
			if (disabled || destroyed)
				return;
			if (Cheats.alwaysBreakBricks && item == null)
			{
				breakBrick();
				return;
			}
			BRICKS_TO_BOUNCE_DCT.addItem(this);
			_health = 0;
			if (item)
			{
				disableThisRoundOnly = true;
//				trace("marked true");
			}
			if (!bounceAndBreakNow)
				return;
//			disableThisRoundOnly = false;
			if (item)
			{
				startBounce();
				if (item == IT_MULTI_COIN)
				{
					if (player.canGetAmmoFromCoinBlocks)
						RandomDropGenerator.checkDropItem(player.charNameCaps,this);
					addObj();
					coinBrickCtr++;
					if (coinBrickCtr == COIN_BRICK_MAX_COINS)
						lastHit = true;
					if (lastHit)
					{
						disabled = true;
						hitTestTypesDct.clear();
						hitTestTypesDct.addItem(HT_GROUND_NON_BRICK);
						gotoAndStop(FL_HIT_MOVING);
						stopAnim = true;
						item = IT_MULTI_COIN_FINISHED;
						if (coinBrickTmr)
						{
							coinBrickTmr.stop();
							coinBrickTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,coinBrickTmrLsr);
							removeTmr(coinBrickTmr);
							coinBrickTmr = null;
						}
					}
					else if (!coinBrickTmr)
					{
						coinBrickTmr = new CustomTimer(coinBrickTmrDur, 1);
						addTmr(coinBrickTmr);
						coinBrickTmr.addEventListener(TimerEvent.TIMER_COMPLETE,coinBrickTmrLsr);
						coinBrickTmr.start();
					}
				}
				else
				{
					if (item == IT_SINGLE_COIN)
					{
						if (player.canGetAmmoFromCoinBlocks)
							RandomDropGenerator.checkDropItem(player.charNameCaps,this);
						addObj();
					}
					disabled = true;
					hitTestTypesDct.clear();
					hitTestTypesDct.addItem(HT_GROUND_NON_BRICK);
					gotoAndStop(FL_HIT_MOVING);
					stopAnim = true;
				}
			}
			else // if (!item)
				startBounce();
		}
		private function startBounce():void
		{
			hitObjectsAbove();
			this.y = yPos;
			bouncing = true;
			afterGround = true;
			vy = -BOUNCE_PWR;
			_health = 0;
			SND_MNGR.playSound(SFX_GAME_HIT_CEILING);
			dispatchEvent( EVENT_BOUNCE );
			BRICKS_TO_BOUNCE_DCT.removeItem(this);
		}
		private function hitObjectsAbove():void
		{
			for each (var ao:AnimatedObject in BOUNCE_HIT_DCT)
			{
				ao.gBounceHit(this);
				BOUNCE_HIT_DCT.removeItem(ao);
			}
		}
		private function addObj():void
		{
			var ao:AnimatedObject;
			switch (item)
			{

				case IT_MUSHROOM_RED:
				{
					normalItemExitBrickStart( Pickup(ao = Pickup.generateNextUpgrade() ) );
					break;
				}
				case IT_POISON_MUSHROOM:
				{
					normalItemExitBrickStart( Pickup(ao = new Mushroom(Mushroom.ST_POISON) ) );
					break;
				}
				case IT_ONE_UP_MUSHROOM:
					normalItemExitBrickStart( Pickup(ao = new Mushroom(Mushroom.ST_GREEN) ) );
					break;
				case IT_STAR:
					normalItemExitBrickStart( Pickup(ao = new Star() ) );
					break;
				case IT_MULTI_COIN:
					ao = new FlyingCoin();
					FlyingCoin(ao).getFlyingCoinInfo(this);
					EVENT_MNGR.getCoin();
					break;
				case IT_SINGLE_COIN:
					ao = new FlyingCoin();
					FlyingCoin(ao).getFlyingCoinInfo(this);
					EVENT_MNGR.getCoin();
					break;
				case IT_EXPLODING_RABBIT:
					normalItemExitBrickStart( Pickup(ao = new ExplodingRabbitPowerup() ) );
					break;
				// smb special
				case IT_ATOM:
					normalItemExitBrickStart( Pickup(ao = new Atom() ) );
					break;
				case IT_CLOCK:
					normalItemExitBrickStart( Pickup(ao = new Clock() ) );
					break;
				case IT_HAMMER:
					normalItemExitBrickStart( Pickup(ao = new HammerPickup() ) );
					break;
				case IT_HUDSON_BEE:
					normalItemExitBrickStart( Pickup(ao = new HudsonBee() ) );
					break;
				case IT_WING:
					normalItemExitBrickStart( Pickup(ao = new Wing() ) );
					break;
				default:
					if (item.indexOf(IT_VINE) != -1)
					{
						ao = new Vine(item);
						(ao as Vine).exitBrickStart(this);
						SND_MNGR.playSound(SFX_GAME_VINE);
					}
					break;
			}
			if (ao)
			{
				if (ao is FlyingCoin)
					level.addToLevelNow(ao);
				else
					level.addToLevel(ao);
			}
		}

		private function normalItemExitBrickStart(pickup:Pickup):void
		{
			ao = new Mushroom(Mushroom.ST_GREEN);
			pickup.exitBrickStart(this);
			SND_MNGR.playSound(SFX_GAME_ITEM_APPEAR);
		}

		private function coinBrickTmrLsr(e:TimerEvent):void
		{
			lastHit = true;
			if (coinBrickTmr.running) coinBrickTmr.stop();
			coinBrickTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,coinBrickTmrLsr);
			removeTmr(coinBrickTmr);
			coinBrickTmr = null;
		}
		override public function updateGround():void
		{
			super.updateGround();
			if (bouncing)
			{
				this.y += vy*dt
				vy += GRAVITY*dt;
				if (this.y >= yPos)
				{
					this.y = yPos;
					bouncing = false;
					afterGround = false;
					if (player.ATK_DCT[this])
						player.ATK_DCT.removeItem(this);
					if (item && item != IT_MULTI_COIN)
						doneBouncing();
				}
			}
			if (BOUNCE_HIT_DCT.length)
				BOUNCE_HIT_DCT.clear();
		}
		internal function doneBouncing():void
		{
			if (item != IT_SINGLE_COIN && item != IT_MULTI_COIN_FINISHED)
				addObj();
			gotoAndStop(FL_HIT_RESTING);
			stopAnim = true;
			/*if (color == "brown")
				gotoAndStop("brownHit");
			else if (color == "blue")
				gotoAndStop("boxBlue");
			else if (color == "gray")
				gotoAndStop("boxGray");*/
		}
		override protected function removeListeners():void
		{
			super.removeListeners();
			if (coinBrickTmr && coinBrickTmr.hasEventListener(TimerEvent.TIMER_COMPLETE)) coinBrickTmr.removeEventListener(TimerEvent.TIMER_COMPLETE,coinBrickTmrLsr);
		}
		override protected function reattachLsrs():void
		{
			super.reattachLsrs();
			if (coinBrickTmr && !coinBrickTmr.hasEventListener(TimerEvent.TIMER_COMPLETE)) coinBrickTmr.addEventListener(TimerEvent.TIMER_COMPLETE,coinBrickTmrLsr);
		}
		public function get health():int
		{
			return _health;
		}

		public function breakOnNextHit():void
		{
			_health = 1;
		}

		override public function animate(ct:ICustomTimer):Boolean
		{
			if (mainAnimTmr == ct && currentFrameLabel == FL_BRICK && animDelCtr < animStartFrameDelay)
				animDelCtr ++;
			else
			{
				animDelCtr = 0;
				return super.animate(ct);
			}
			return false;
		}
		final protected function $animate(ct:ICustomTimer):Boolean
		{
			return super.animate(ct);
		}
		override public function cleanUp():void
		{
			super.cleanUp();
			if (this == masterBrick)
				level.ALWAYS_ANIM_DCT.removeItem(this);
			else if (classObj == Brick)
				BRICKS_DCT.removeItem(this);
//			if (classObj == Brick)
//				BRICK_MAP_FCT_DCT.removeItem(changeMapSkinHandler);
		}
		override public function disarm():void
		{
			super.disarm();
			if (this != masterBrick && classObj == Brick)
				BRICKS_DCT.removeItem(this);
		}
		override public function rearm():void
		{
			super.rearm();
			if (this == masterBrick)
				level.ALWAYS_ANIM_DCT.addItem(this);
			else if (classObj == Brick)
				BRICKS_DCT.addItem(this);
		}


		override public function checkFrame():void
		{
			if (stopAnim)
				return;
			if (this == masterBrick)
			{
				if (currentFrame == animEndFrameNum + 1)
					gotoAndStop(FL_BRICK);
				for each (var brick:Brick in BRICKS_DCT)
				{
					if (brick.onScreen && !brick.stopAnim)
						brick.gotoAndStop(currentFrame);
				}
			}
		}



	}
}
