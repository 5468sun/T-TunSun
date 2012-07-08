////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2011-2012 5468sun
//  All Rights Reserved.
//
////////////////////////////////////////////////////////////////////////////////

package sxf.utils.selector.lineselector
{
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	
	[Style(name="oddGap",type="uint",format="Length",inherit="yes")]
	[Style(name="evenGap",type="uint",format="Length",inherit="yes")]
	[Style(name="oddColor",type="uint",format="Color",inherit="yes")]
	[Style(name="evenColor",type="uint",format="Color",inherit="yes")]
	
	[Style(name="lineThickness",type="uint",format="Length",inherit="yes")]
	[Style(name="lineAlphaOdd",type="Number",inherit="yes")]
	[Style(name="lineAlphaEven",type="Number",inherit="yes")]
	[Style(name="backGroundColor",type="uint",format="Color",inherit="yes")]
	[Style(name="backGroundAlpha",type="Number",inherit="yes")]
	[Style(name="lineCapStyle",type="String",inherit="yes",enumeration="none,round,square")]
	[Style(name="lineJoinStyle",type="String",inherit="yes",enumeration="miter,round,bevel")]
	[Style(name="lineMiterLimit",type="Number",inherit="yes")]
	
	public class AntLine extends UIComponent{
		
		private static var classConstructed:Boolean = classConstruct();
		
		/**
		 * 
		 * @param defaultOddGap 蚂蚁线段1的长度，整数
		 * @param defaultEvenGap 蚂蚁线段2的长度，整数
		 * @param defaultOddColor 蚂蚁线段1的颜色，整数
		 * @param defaultEvenColor 蚂蚁线段2的颜色，整数
		 * @param defaultThickness 蚂蚁线的粗细，整数
		 * 
		 * **/
		private static const defaultOddGap:uint = 4;
		private static const defaultEvenGap:uint = 4;
		private static const defaultOddColor:uint = 0x000000;
		private static const defaultEvenColor:uint = 0xffffff;
		
		private static const defaultLineColor:uint = 0x000000;
		private static const defaultLineThickness:uint = 1;
		private static const defaultLineAlphaOdd:Number = 1;
		private static const defaultLineAlphaEven:Number = 0;
		private static const defaultBackGroundColor:uint = 0xffffff;
		private static const defaultBackGroundAlpha:Number = 0;
		private static const defaultLineCapStyle:String = "square";
		private static const defaultLineJoinStyle:String = "miter";
		private static const defaultLineMiterLimit:Number = 0;
		
		private static const odd:String = "colorGapFlagOdd";
		private static const even:String = "colorGapFlagEven";
		
		private var _rectangle:Rectangle;
		private var _oddGap:uint;
		private var _evenGap:uint;
		private var _oddColor:uint;
		private var _evenColor:uint;
		
		private var _lineThickness:uint;
		private var _lineAlphaOdd:Number;
		private var _lineAlphaEven:Number;
		private var _backGroundColor:uint;
		private var _backGroundAlpha:Number;
		private var _lineCapStyle:String;
		private var _lineJoinStyle:String;
		private var _lineMiterLimit:Number;
		
		private var _pixelHinting:Boolean = true;
		private var _scaleMode:String = "normal";
		
		private var _timer:Timer;
		private var _interval:Number = 100;
		
		/**
		 * Constructor.
		 * **/
		public function AntLine()
		{
			super();
			_rectangle = new Rectangle();
			_timer = new Timer(_interval);
			_timer.addEventListener(TimerEvent.TIMER,timerHandler);
		}

		public function get rectangle():Rectangle
		{
			return _rectangle;
		}

		public function set rectangle(value:Rectangle):void
		{
			if(!value.equals(_rectangle))
			{
				_rectangle = value;
				invalidateDisplayList();
			}
		}

		public function get oddGap():uint
		{
			return _oddGap;
		}
		
		public function set oddGap(value:uint):void
		{
			if(value != _oddGap)
			{
				_oddGap = value;
				invalidateDisplayList();
			}
		}
		
		public function get evenGap():uint
		{
			return _evenGap;
		}
		
		public function set evenGap(value:uint):void
		{
			if(value != _evenGap)
			{
				_evenGap = value;
				invalidateDisplayList();
			}
		}
		
		public function get oddColor():uint
		{
			return _oddColor;
		}
		
		public function set oddColor(value:uint):void
		{
			if(value != _oddColor)
			{
				_oddColor = value;
				invalidateDisplayList();
			}
		}

		public function get evenColor():uint
		{
			return _evenColor;
		}
		
		public function set evenColor(value:uint):void
		{
			if(value != _evenColor)
			{
				_evenColor = value;
				invalidateDisplayList();
			}
		}
		
		public function get lineThickness():Number
		{
			return _lineThickness;
		}
		
		public function set lineThickness(value:Number):void
		{
			if(value != _lineThickness)
			{
				_lineThickness = value;
				invalidateDisplayList();
			}
		}

		public function get lineAlphaOdd():Number
		{
			return _lineAlphaOdd;
		}
		
		public function set lineAlphaOdd(value:Number):void
		{
			if(value != _lineAlphaOdd)
			{
				_lineAlphaOdd = value;
				invalidateDisplayList();
			}
		}
		
		public function get lineAlphaEven():Number
		{
			return _lineAlphaEven;
		}
		
		public function set lineAlphaEven(value:Number):void
		{
			if(value != _lineAlphaEven)
			{
				_lineAlphaEven = value;
				invalidateDisplayList();
			}
		}
		
		public function get backGroundColor():uint
		{
			return _backGroundColor;
		}
		
		public function set backGroundColor(value:uint):void
		{
			if(value != _backGroundColor)
			{
				_backGroundColor = value;
				invalidateDisplayList();
			}
		}

		public function get backGroundAlpha():Number
		{
			return _backGroundAlpha;
		}
		
		public function set backGroundAlpha(value:Number):void
		{
			if(value != _backGroundAlpha)
			{
				_backGroundAlpha = value;
				invalidateDisplayList();
			}
		}

		public function get lineCapStyle():String
		{
			return _lineCapStyle;
		}
		
		public function set lineCapStyle(value:String):void
		{
			if(value != _lineCapStyle)
			{
				_lineCapStyle = value;
				invalidateDisplayList();
			}
		}
		
		public function get lineJoinStyle():String
		{
			return _lineJoinStyle;
		}
		
		public function set lineJoinStyle(value:String):void
		{
			if(value != _lineJoinStyle)
			{
				_lineJoinStyle = value;
				invalidateDisplayList();
			}
		}
		
		public function get lineMiterLimit():Number
		{
			return _lineMiterLimit;
		}
		
		public function set lineMiterLimit(value:Number):void
		{
			if(value != _lineMiterLimit)
			{
				_lineMiterLimit = value;
				invalidateDisplayList();
			}
		}
		
		
		
		
		override public function stylesInitialized():void
		{
			if(!oddGap) oddGap = getStyle("oddGap");
			if(!evenGap) evenGap = getStyle("evenGap");
			if(!oddColor) oddColor = getStyle("oddColor");
			if(!evenColor) evenColor = getStyle("evenColor");
			
			if(!lineThickness) lineThickness = getStyle("lineThickness");
			if(isNaN(lineAlphaOdd)) lineAlphaOdd = getStyle("lineAlphaOdd");
			if(isNaN(lineAlphaEven)) lineAlphaEven = getStyle("lineAlphaEven");
			if(!backGroundColor) backGroundColor = getStyle("backGroundColor");
			if(isNaN(backGroundAlpha)) backGroundAlpha = getStyle("backGroundAlpha");
			if(lineCapStyle == null) lineCapStyle = getStyle("lineCapStyle");
			if(lineJoinStyle == null) lineJoinStyle = getStyle("lineJoinStyle");
			if(isNaN(lineMiterLimit)) lineMiterLimit = getStyle("lineMiterLimit");
		}
		
		override public function styleChanged(styleProp:String):void
		{
			switch (styleProp)
			{
				case "oddGap":
					oddGap = getStyle("oddGap");
					break;
				
				case "evenGap":
					evenGap = getStyle("evenGap");
					break;
				
				case "oddColor":
					oddColor = getStyle("oddColor");
					break;
				
				case "evenColor":
					evenColor = getStyle("evenColor");
					break;
				
				case "lineThickness":
					lineThickness = getStyle("lineThickness");
					break;
				
				case "lineAlphaOdd":
					lineAlphaOdd = getStyle("lineAlphaOdd");
					break;
				
				case "lineAlphaEven":
					lineAlphaEven = getStyle("lineAlphaEven");
					break;
				
				case "backGroundColor":
					backGroundColor = getStyle("backGroundColor");
					break;
				
				case "backGroundAlpha":
					backGroundAlpha = getStyle("backGroundAlpha");
					break;
				
				case "lineCapStyle":
					lineCapStyle = getStyle("lineCapStyle");
					break;
				
				case "lineJoinStyle":
					lineJoinStyle = getStyle("lineJoinStyle");
					break;
				case "lineMiterLimit":
					lineMiterLimit = getStyle("lineMiterLimit");
					break;
				
				default:
					break;
			}
			
			super.styleChanged(styleProp);
			
		}
		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if(rectangle && rectangle.x && rectangle.x && rectangle.width && rectangle.height)
			{
				_timer.start();
			}
			else
			{
				_timer.stop();
				graphics.clear();
			}
			
			super.updateDisplayList(unscaledWidth,unscaledHeight);
		}
		
	
			
		private function draw(flag:String,offset:Number):void
		{
			var drawingRect:Rectangle = convertRect(rectangle,lineThickness);
			
			graphics.clear();
			drawTR(drawingRect,flag,offset);
			drawLB(drawingRect,flag,offset);
		}
		
		private function drawTR(rect:Rectangle,flag:String,offset:Number):void
		{
			var offset:Number = offset;
			var flag:String = flag;
			var lineLen:int = 0;
			var absWidth:Number = Math.abs(rect.width);
			var absHeight:Number = Math.abs(rect.height);
			var lineColor:uint = (flag==odd)?oddColor:evenColor;
			var gap:uint = (flag==odd)?oddGap:evenGap;
			var lineAlpha:Number = (flag==odd)?lineAlphaOdd:lineAlphaEven;
			
			graphics.moveTo(rect.x,rect.y);
			graphics.lineStyle(lineThickness,lineColor,lineAlpha,_pixelHinting,_scaleMode,lineCapStyle,lineJoinStyle,lineMiterLimit);
			graphics.lineTo(rect.x+(rect.width>0?offset:-offset),rect.y);
			
			lineLen += offset;
			flag = (flag==odd)?even:odd;

			while(lineLen<=absWidth+absHeight)
			{
				lineColor = (flag==odd)?oddColor:evenColor;
				gap = (flag==odd)?oddGap:evenGap;
				lineAlpha = (flag==odd)?lineAlphaOdd:lineAlphaEven;
				
				graphics.lineStyle(lineThickness,lineColor,lineAlpha,_pixelHinting,_scaleMode,lineCapStyle,lineJoinStyle,lineMiterLimit);
				var targetLineLen:Number;
				if(lineLen<absWidth && lineLen+gap<=absWidth){
					
					targetLineLen = rect.width>0?(lineLen+gap):-(lineLen+gap);
					
					graphics.lineTo(rect.x+targetLineLen,rect.y);
					
				}
				
				else if(lineLen<absWidth && lineLen+gap>absWidth){

					targetLineLen = rect.height>0?(lineLen+gap-absWidth):-(lineLen+gap-absWidth);
					
					graphics.lineTo(rect.x+rect.width,rect.y);
					graphics.lineTo(rect.x+rect.width,rect.y+targetLineLen);
					
				}
				else if(lineLen>=absWidth && lineLen+gap<=(absWidth+absHeight)){
					
					targetLineLen = rect.height>0?(lineLen+gap-absWidth):-(lineLen+gap-absWidth);
					
					graphics.lineTo(rect.x+rect.width,rect.y+targetLineLen);
					
					
				}
				else if(lineLen>=absWidth && lineLen+gap>(absWidth+absHeight)){
					
					graphics.lineTo(rect.x+rect.width,rect.y+rect.height);
					
				}
				
				lineLen += gap;
				flag = (flag==odd)?even:odd;
				
			}
		}
		private function drawLB(rect:Rectangle,flag:String,offset:Number):void
		{
			var offset:Number = offset;
			var flag:String = flag;		
			var lineLen:int = 0;
			var absWidth:Number = Math.abs(rect.width);
			var absHeight:Number = Math.abs(rect.height);
			var lineColor:uint = (flag==odd)?oddColor:evenColor;
			var gap:uint = (flag==odd)?oddGap:evenGap;
			var lineAlpha:Number = (flag==odd)?lineAlphaOdd:lineAlphaEven;
			
			graphics.moveTo(rect.x,rect.y);
			graphics.lineStyle(lineThickness,lineColor,lineAlpha,_pixelHinting,_scaleMode,lineCapStyle,lineJoinStyle,lineMiterLimit);
			graphics.lineTo(rect.x,rect.y+(rect.height>0?offset:-offset));
			
			lineLen += offset;
			flag = (flag==odd)?even:odd;
			
			while(lineLen<=(absWidth+absHeight))
			{
				lineColor = (flag==odd)?oddColor:evenColor;
				gap = (flag==odd)?oddGap:evenGap;
				lineAlpha = (flag==odd)?lineAlphaOdd:lineAlphaEven;
				
				graphics.lineStyle(lineThickness,lineColor,lineAlpha,_pixelHinting,_scaleMode,lineCapStyle,lineJoinStyle,lineMiterLimit);
				
				var targetLineLen:Number;
				
				if(lineLen<absHeight && lineLen+gap<=absHeight){
					
					targetLineLen = rect.height>0?(lineLen+gap):-(lineLen+gap);
					graphics.lineTo(rect.x,rect.y+targetLineLen);
					
				}
				else if(lineLen<absHeight && lineLen+gap>absHeight){
					
					targetLineLen = rect.width>0?(lineLen+gap-absHeight):-(lineLen+gap-absHeight);
					
					graphics.lineTo(rect.x,rect.y+rect.height);
					
					graphics.lineTo(rect.x+targetLineLen,rect.y+rect.height);
					
					
				}
				else if(lineLen>=absHeight && lineLen+gap<=(absWidth+absHeight)){
					
					targetLineLen = rect.width>0?(lineLen+gap-absHeight):-(lineLen+gap-absHeight);
					graphics.lineTo(rect.x+targetLineLen,rect.y+rect.height);

				}
				else if(lineLen>=absHeight && lineLen+gap>(absWidth+absHeight)){
					
					graphics.lineTo(rect.x+rect.width,rect.y+rect.height);
					
				}
				
				lineLen += gap;
				flag = (flag==odd)?even:odd;
				
			}
		}
		
		
		private function timerHandler(e:TimerEvent):void{
			var offset:Number;
			var flag:String;
			var timerCount:Number = Timer(e.target).currentCount;
			var count:Number = timerCount%(oddGap + evenGap);
			
			if(count == 0) count = oddGap + evenGap;
			
			if(count>0 && count<=oddGap)
			{
				offset = count;
				flag = odd;
			}
			else if(count>oddGap && count<=(oddGap+evenGap))
			{
				offset = count - oddGap;
				flag = even;
			}
			draw(flag,offset);
		}
		
		private function convertRect(orignRect:Rectangle,thickness:Number):Rectangle
		{
			var x:Number;
			var y:Number;
			var w:Number;
			var h:Number;
			if(orignRect.width>=0)
			{
				x = orignRect.x - Math.ceil(thickness/2);
				w = orignRect.width + thickness;
			}
			else if(orignRect.width<0)
			{
				x = orignRect.x + Math.floor(thickness/2);
				w = orignRect.width - thickness;
			}
			
			if(orignRect.height>=0)
			{
				y = orignRect.y - Math.ceil(thickness/2);
				h = orignRect.height + thickness;
			}
			else if(orignRect.height<0)
			{
				y = orignRect.y + Math.floor(thickness/2);
				h = orignRect.height - thickness;
			}
			
			return new Rectangle(x,y,w,h);
		}
		
		private static function classConstruct():Boolean
		{
			var style:CSSStyleDeclaration = FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("sxf.utils.selector.lineselector.AntLine");
			
			if(!style)
			{
				style = new CSSStyleDeclaration();
				style.defaultFactory = function():void
				{
					this.oddGap = defaultOddGap;
					this.evenGap = defaultEvenGap;
					this.oddColor = defaultOddColor;
					this.evenColor = defaultEvenColor;
					
					this.lineThickness = defaultLineThickness;
					this.lineAlphaOdd = defaultLineAlphaOdd;
					this.lineAlphaEven = defaultLineAlphaEven;
					this.backGroundColor = defaultBackGroundColor;
					this.backGroundAlpha = defaultBackGroundAlpha;
					this.lineCapStyle = defaultLineCapStyle;
					this.lineJoinStyle = defaultLineJoinStyle;
					this.lineMiterLimit = defaultLineMiterLimit;
				}
				FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("sxf.utils.selector.lineselector.AntLine",style,true);		
			}
			else
			{
				if(style.getStyle("oddGap") == undefined) style.setStyle("oddGap",defaultOddGap);
				if(style.getStyle("evenGap") == undefined) style.setStyle("evenGap",defaultEvenGap);
				if(style.getStyle("oddColor") == undefined) style.setStyle("oddColor",defaultOddColor);
				if(style.getStyle("evenColor") == undefined) style.setStyle("evenColor",defaultEvenColor);
				
				if(style.getStyle("lineThickness") == undefined) style.setStyle("lineThickness",defaultLineThickness);
				if(style.getStyle("lineAlphaOdd") == undefined) style.setStyle("lineAlphaOdd",defaultLineAlphaOdd);
				if(style.getStyle("lineAlphaEven") == undefined) style.setStyle("lineAlphaEven",defaultLineAlphaEven);
				if(style.getStyle("backGroundColor") == undefined) style.setStyle("backGroundColor",defaultBackGroundColor);
				if(style.getStyle("backGroundAlpha") == undefined) style.setStyle("backGroundAlpha",defaultBackGroundAlpha);
				if(style.getStyle("lineCapStyle") == undefined) style.setStyle("lineCapStyle",defaultLineCapStyle);
				if(style.getStyle("lineJoinStyle") == undefined) style.setStyle("lineJoinStyle",defaultLineJoinStyle);
				if(style.getStyle("lineMiterLimit") == undefined) style.setStyle("lineMiterLimit",defaultLineMiterLimit);
			}
			return true;
		}
		
	}
}