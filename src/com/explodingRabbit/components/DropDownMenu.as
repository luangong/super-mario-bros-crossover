package com.explodingRabbit.components
{
	import com.caurina.transitions.*;

	import flash.display.MovieClip;
	import flash.events.*;

   public class DropDownMenu extends MovieClip
   {
	   private var _names:Array;
	   private var boxesVec:Vector.<LinkBox>;
	   private var _defaultValue:String;
	   private var defaultLinkBox:LinkBox;
	   private var _value:String;
	   private var _index:int;

      public function DropDownMenu(names:Array, title:String)
      {
        _names = names;
		_defaultValue = title;
		initMenu();
      }

	  private function initMenu():void
	  {
		  defaultLinkBox = new LinkBox(_defaultValue,0);
		  boxesVec = new Vector.<LinkBox>();
		  boxesVec.push(defaultLinkBox);
		  for(var i:int=0; i <_names.length; i++)
		  {
			  var linkBox:LinkBox = new LinkBox(_names[i],i+1);
			  addChild(linkBox);
			  boxesVec.push(linkBox);
			  linkBox.alpha=0;
			  linkBox.addEventListener(MouseEvent.CLICK, getLink);
		  }
		  addChild(defaultLinkBox);
		  defaultLinkBox.addEventListener(MouseEvent.CLICK, showMenu);
	  }

	  private function showMenu(e:Event):void
	  {
		  for(var i:int = 0;i<this.numChildren;i++)
		  {
			  var tempChild:* = this.getChildAt(i);
			  var startY:int = tempChild.height;
			  if(tempChild != e.currentTarget)
			  {
				 Tweener.addTween(tempChild, {y:(startY+(tempChild.height)*i), alpha:1, time:.5, transition:"easeOutCubic"});
			  }
		  }
		  this.addEventListener(MouseEvent.ROLL_OUT, hideMenu);
	  }
	  public function setIndex(num:int):void
	  {
		  _index = num;
		  _value = boxesVec[_index + 1].title;
		  defaultLinkBox.textField.text = _value;
		  defaultLinkBox.centerText();
		  dispatchEvent( new Event(Event.CHANGE) );
	  }

	  public function setIndexFromName(name:String):void
	  {
		  var ind:int = getIndexFromName(name);
		  setIndex(ind);
	  }

	  private function hideMenu(e:Event):void
	  {
		  for(var i:int = 0;i<this.numChildren;i++)
		  {
			 var tempChild:* = this.getChildAt(i);
			  if(tempChild.y !=0)
			  {
			  	Tweener.addTween(tempChild, {y:0, time:.5, alpha:0, transition:"easeOutCubic"});
			  }
		  }
	  }
	  private function getLink(e:Event):void
	  {
		  var linkBox:LinkBox = e.currentTarget as LinkBox;
		  _value = linkBox.title;
		  _index = linkBox.index;
		  defaultLinkBox.textField.text = _value;
		  defaultLinkBox.centerText();
		  dispatchEvent( new Event(Event.CHANGE) );
	  }

	  public function getIndexFromName(name:String):int
	  {
		  var n:int = _names.length;
		  for (var i:int = 0; i < n; i++)
		  {
			  if ( _names[i] == name)
				  return i;
		  }
		  return -1;
	  }

	  public function get names():Array
	  {
		  return _names;
	  }
	   public function get value():String
	   {
		   return _value;
	   }

	   public function get defaultValue():String
	   {
		   return _defaultValue;
	   }

	   public function get index():int
	   {
		   return _index;
	   }


   }
}
