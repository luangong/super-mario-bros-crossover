package com.customClasses
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	public class MCScrollBar extends MovieClip
	{
		private var _content			:MovieClip 			= new MovieClip;
		private var _contMask			:MovieClip		 	= new MovieClip;
		private var _dragger			:MovieClip 			= new MovieClip;
		private var _scrollbar			:MovieClip 			= new MovieClip;
		private var scrollPercent		:Number				= new Number(0);

		private var _speed				:uint;
		private var _padding			:uint;

		public function MCScrollBar(content:MovieClip, contMask:MovieClip, dragger:MovieClip, scrollbar:MovieClip, speed:uint = 1, padding:uint = 0):void
		{
			_content 			= content;
			_contMask			= contMask;
			_dragger 			= dragger;
			_scrollbar 			= scrollbar;
			_padding			= padding;
			_speed				= speed;
			_content.mask 		= _contMask;
			_content.y 			= _contMask.y;
			_dragger.y 			= _scrollbar.y;

			_dragger.buttonMode = true;

			/* Events					_____________________________________________*/

			_dragger.addEventListener(MouseEvent.MOUSE_DOWN, moveDrag);
			_dragger.parent.stage.addEventListener(MouseEvent.MOUSE_UP, releaseDrag);
			_scrollbar.addEventListener(MouseEvent.CLICK, moveDragPercent);
			_dragger.parent.stage.addEventListener(MouseEvent.MOUSE_WHEEL, moveContentWheel);

			/* if need use Scrollbar	_____________________________________________*/

			verifyHeight();
		}

		/*
		When the mouse_down into the dragger clip function
		Execute function to drag scroll slider
		*/

		private function moveDrag(m:MouseEvent):void
		{
			var newRect:Rectangle = new Rectangle(_scrollbar.x,_scrollbar.y,0,_scrollbar.height - _dragger.height);
			_dragger.startDrag(false,newRect);

			/* Moving the content together when move the dragger */
			_dragger.addEventListener(MouseEvent.MOUSE_MOVE, function()
			{
				_dragger.stage.addEventListener(Event.ENTER_FRAME, moveContent);
			});
		}

		/*
		Execute release Drag to stop all enter frame function
		and stop the content scroll
		*/

		private function releaseDrag(m:MouseEvent):void
		{
			_dragger.stopDrag();
			_dragger.stage.removeEventListener(Event.ENTER_FRAME, moveContent);
			moveContent(null);
		}

		/*
		CLICK IN THE SCROLL AND GOTO
		When click on the scroll will
		jump to position with out slide
		the dragger movieclip
		*/

		private function moveDragPercent(m:MouseEvent):void
		{
			_dragger.y = mouseY;
			_dragger.stage.addEventListener(Event.ENTER_FRAME, moveContent);
		}

		/*
		Execute this function using EnterFrame when moveDrag is working
		*/

		private function moveContent(e:Event):void
		{
			/* Verify if dragger is inside the background */

			if ( _dragger.y > ( (_scrollbar.y + _scrollbar.height) - _dragger.height )) _dragger.y = (_scrollbar.y + _scrollbar.height) - _dragger.height;
			if ( _dragger.y < _scrollbar.y ) _dragger.y = _scrollbar.y;

			/* Scroll Move */

			scrollPercent = ( 100 / ( _scrollbar.height - _dragger.height ) ) * ( _dragger.y - _scrollbar.y );

			var acty:Number = Number(_content.y);
			var endy:Number = Number(_contMask.y + ( ( _contMask.height - _content.height - _padding ) / 100 ) * scrollPercent);

			_content.y += (endy - acty) / _speed;

			verifyHeight();
		}

		/*
		Using Mouse Wheel
		*/

		private function moveContentWheel(m:MouseEvent):void
		{
			if ( mouseX > _contMask.x && mouseX < _contMask.x + _contMask.width && mouseY > _contMask.y && mouseY < _contMask.y + _contMask.height )
			{
				_dragger.y -= ( m.delta * 5 );
				moveContent(null);
			}
		}

		/*
		Verify if need or not the content
		If content is smaller than mask
		will not show the scrollbase
		*/

		public function verifyHeight():void
		{
			if ( _contMask.height > _content.height )
			{
				_dragger.visible = false;
				_scrollbar.visible = false;
			}
			else
			{
				_dragger.visible = true;
				_scrollbar.visible = true;

				/* Change the dragger size */

				_dragger.height = ((_contMask.height / _content.height) * _scrollbar.height);
			}
		}

	}
}
