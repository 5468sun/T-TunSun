package sxf.utils.selector.cropselector
{
	import flash.geom.Rectangle;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.styles.CSSStyleDeclaration;
	
	[Style(name="lineColor",type="uint",format="Color",inherit="yes")]
	[Style(name="lineThickness",type="uint",format="Length",inherit="yes")]
	[Style(name="lineAlpha",type="Number",inherit="yes")]
	[Style(name="backGroundColor",type="uint",format="Color",inherit="yes")]
	[Style(name="backGroundAlpha",type="Number",inherit="yes")]
	[Style(name="lineCapStyle",type="String",inherit="yes",enumeration="none,round,square")]
	[Style(name="lineJoinStyle",type="String",inherit="yes",enumeration="miter,round,bevel")]
	[Style(name="lineMiterLimit",type="Number",inherit="yes")]
	
	public class SolidLine extends UIComponent
	{
		private static var classConstructed:Boolean = classConstruct();
		
		private static const defaultLineColor:uint = 0x000000;
		private static const defaultLineThickness:uint = 1;
		private static const defaultLineAlpha:Number = 1;
		private static const defaultBackGroundColor:uint = 0xffffff;
		private static const defaultBackGroundAlpha:Number = 0.1;
		private static const defaultLineCapStyle:String = "square";
		private static const defaultLineJoinStyle:String = "miter";
		private static const defaultLineMiterLimit:Number = 0;
		
		private var _rectangle:Rectangle;
		private var _lineColor:uint;
		private var _lineThickness:uint;
		private var _lineAlpha:Number;
		private var _backGroundColor:uint;
		private var _backGroundAlpha:Number;
		private var _lineCapStyle:String;
		private var _lineJoinStyle:String;
		private var _lineMiterLimit:Number;
		
		private var _pixelHinting:Boolean = true;
		private var _scaleMode:String = "normal";
		
		public function SolidLine()
		{
			super();
			_rectangle = new Rectangle();
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
		
		public function get lineColor():uint
		{
			return _lineColor;
		}

		public function set lineColor(value:uint):void
		{
			if(value != _lineColor)
			{
				_lineColor = value;
				invalidateDisplayList();
			}
		}

		public function get lineAlpha():Number
		{
			return _lineAlpha;
		}

		public function set lineAlpha(value:Number):void
		{
			if(value != _lineAlpha)
			{
				_lineAlpha = value;
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

		
		
		public function update(rectangle:Rectangle):void
		{
			rectangle = rectangle;
		}
		
		override public function stylesInitialized():void
		{
			if(!lineColor) lineColor = getStyle("lineColor");
			if(!lineThickness) lineThickness = getStyle("lineThickness");
			if(isNaN(lineAlpha)) lineAlpha = getStyle("lineAlpha");
			if(!backGroundColor) backGroundColor = getStyle("backGroundColor");
			if(isNaN(backGroundAlpha)) backGroundAlpha = getStyle("backGroundAlpha");
			if(lineCapStyle == null) lineCapStyle = getStyle("lineCapStyle");
			if(lineJoinStyle == null) lineJoinStyle = getStyle("lineJoinStyle");
			if(isNaN(lineMiterLimit)) lineMiterLimit = getStyle("lineMiterLimit");
		}
		
		override public function styleChanged(styleProp:String):void
		{
			switch(styleProp)
			{
				case "lineColor":
					lineColor = getStyle("lineColor");
					break;
				
				case "lineThickness":
					lineThickness = getStyle("lineThickness");
					break;
				
				case "lineAlpha":
					lineAlpha = getStyle("lineAlpha");
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
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var drawingRect:Rectangle = convertRect(rectangle,lineThickness);;
			
			if(drawingRect && !isNaN(drawingRect.x) && !isNaN(drawingRect.y) && !isNaN(drawingRect.width) && !isNaN(drawingRect.height))
			{
				graphics.clear();
				graphics.moveTo(drawingRect.x,drawingRect.y);
				graphics.beginFill(backGroundColor,backGroundAlpha);
				graphics.lineStyle(lineThickness,lineColor,lineAlpha,_pixelHinting,_scaleMode,lineCapStyle,lineJoinStyle,lineMiterLimit);
				graphics.drawRect(drawingRect.x,drawingRect.y,drawingRect.width,drawingRect.height);
				graphics.endFill();
			}
			else
			{
				graphics.clear();
			}
			
			super.updateDisplayList(unscaledWidth,unscaledHeight);
		}
		
		private function convertRect(orignRect:Rectangle,thickness:Number):Rectangle
		{
			var x:Number;
			var y:Number;
			var w:Number;
			var h:Number;
			
			if(!orignRect || isNaN(orignRect.width) || isNaN(orignRect.height) || isNaN(orignRect.x) || isNaN(orignRect.y))
			{
				return null;
			}
			else if(orignRect.width>=0)
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
			var style:CSSStyleDeclaration = UIComponent(FlexGlobals.topLevelApplication).styleManager.getStyleDeclaration("sxf.utils.selector.cropselector.SolidLine");
			if(!style)
			{
				style = new CSSStyleDeclaration();
				style.factory = function():void
				{
					this.lineColor = defaultLineColor;
					this.lineThickness = defaultLineThickness;
					this.lineAlpha = defaultLineAlpha;
					this.backGroundColor = defaultBackGroundColor;
					this.backGroundAlpha = defaultBackGroundAlpha;
					this.lineCapStyle = defaultLineCapStyle;
					this.lineJoinStyle = defaultLineJoinStyle;
					this.lineMiterLimit = defaultLineMiterLimit;
				}
				UIComponent(FlexGlobals.topLevelApplication).styleManager.setStyleDeclaration("sxf.utils.selector.cropselector.SolidLine",style,true);	
			}
			else
			{
				if(style.getStyle("lineColor") == undefined) style.setStyle("lineColor",defaultLineColor);
				if(style.getStyle("lineThickness") == undefined) style.setStyle("lineThickness",defaultLineThickness);
				if(style.getStyle("lineAlpha") == undefined) style.setStyle("lineAlpha",defaultLineAlpha);
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