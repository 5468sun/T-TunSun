package sxf.utils.selector.lineselector
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	import sxf.utils.selector.lineselector.AntLine;
	import sxf.utils.selector.lineselector.LineSelectorEvent;
	
	[SkinState("normal")]
	[SkinState("selecting")]
	[SkinState("selected")]
	
	[Style(name="restrainRect",type="Rectangle",inherit="yes")]
	[Style(name="ratio",type="Number",inherit="yes")]
	
	public class LineSelector extends SkinnableComponent
	{
		private static var classConstructed:Boolean = classConstruct();
		private static const defaultRestrainRect:Rectangle = null;
		private static const defaultRatio:Number = 0;
		private static const mode1:String = "mode1";
		private static const mode2:String = "mode2";
		
		/*private var _rectX:Number;
		private var _rectY:Number;
		private var _rectW:Number;
		private var _rectH:Number;*/
		private var _selectRect:Rectangle;
		private var _restrainRect:Rectangle;
		
		private var _ratio:Number; // abs(x/y)
		private var _mode:String = mode1;
	
		private var _mouseHeldDown:Boolean = false;
		
		private var _initPoint:Point;
		private var _endPoint:Point;
		
		[SkinPart(required="true")]
		public var antLine:AntLine;
		
		public function LineSelector()
		{
			super();
			_selectRect = new Rectangle();
			addEventListener(FlexEvent.CREATION_COMPLETE,onCreateComplete);
			addEventListener(Event.RESIZE,onResize);
			addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			
		}
		

		/*private function get rectX():Number
		{
			return _rectX;
		}

		private function set rectX(value:Number):void
		{
			if(value != _rectX)
			{
				_rectX = value;
				invalidateDisplayList();
			}
			
		}

		private function get rectY():Number
		{
			return _rectY;
		}

		private function set rectY(value:Number):void
		{
			if(value != _rectY)
			{
				_rectY = value;
				invalidateDisplayList();
			}
			
		}

		private function get rectW():Number
		{
			return _rectW;
		}

		private function set rectW(value:Number):void
		{
			if(value != _rectW)
			{
				_rectW = value;
				invalidateDisplayList();
			}
		}

		private function get rectH():Number
		{
			return _rectH;
		}

		private function set rectH(value:Number):void
		{
			if(value != _rectH)
			{
				_rectH = value;
				invalidateDisplayList();
			}
		}
*/
		public function get selectRect():Rectangle
		{
			return _selectRect;
		}
		
		public function set selectRect(value:Rectangle):void
		{
			if(!value.equals(_selectRect))
			_selectRect = value;
			invalidateDisplayList();
		}
		
		public function get restrainRect():Rectangle
		{
			return _restrainRect;
		}

		public function set restrainRect(value:Rectangle):void
		{
			if(value != _restrainRect)
			{
				_restrainRect = value;
			}
			
		}
		
		/**
		 * 
		 * 获取、设置比例
		 * 
		 * **/
		
		public function get ratio():Number{
			
			return _ratio;
			
		}
		
		public function set ratio(value:Number):void{
			
			if(value != _ratio)
			{
				_ratio = value;
			}
		}
		
		public function get mode():String{
			
			return _mode;
		}
		
		public function set mode(value:String):void{
			
			if(value != _mode)
			{
				_mode = value;
			}
		}
	
		/*override protected function createChildren():void
		{}
		
		override protected function commitProperties():void
		{}
		
		override protected function measure():void
		{}*/
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			antLine.rectangle = selectRect;
		}
		
		override protected function getCurrentSkinState():String
		{
			var skinState:String;

			if(_mouseHeldDown)
			{
				skinState = "selecting";
			}
			else if(!_mouseHeldDown && (selectRect.width && selectRect.height))
			{
				skinState = "selected";
			}
			else
			{
				skinState = "normal";
			}
			return skinState;
		}
		
		override public function styleChanged(styleProp:String):void
		{
			switch(styleProp)
			{
				case "restrainRect":
					this.restrainRect = getStyle("restrainRect");
					break;
				
				case "ratio":
					this.ratio = getStyle("ratio");
					break;
				
				default:
					break;
			}
		}

		private function onCreateComplete(e:FlexEvent):void
		{
			if(getStyle("restrainRect") == undefined)
			{
				restrainRect = new Rectangle(0,0,this.width,this.height);
			}
			else
			{
				restrainRect = getStyle("restrainRect");
			}
			
		}
		
		private function onResize(e:Event):void
		{
			if(getStyle("restrainRect") == undefined)
			{
				restrainRect = new Rectangle(0,0,this.width,this.height);
			}
			else
			{
				restrainRect = getStyle("restrainRect");
			}
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			_mouseHeldDown = true;
			invalidateSkinState();
			
			_initPoint = restrainInitPoint(new Point(e.localX,e.localY),restrainRect);
			dispatchEvent(new LineSelectorEvent(LineSelectorEvent.BEGIN,false,false,_initPoint));
			
			addEventListener(MouseEvent.MOUSE_MOVE,onMouseDownMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		private function onMouseDownMove(e:MouseEvent):void
		{
			addEventListener(Event.ENTER_FRAME,onEnterFrame);
		}
		
		private function onEnterFrame(e:Event):void{
			
			var mousePoint:Point = new Point(this.mouseX,this.mouseY);
			_endPoint = getRestrainCrossPoint(mousePoint,restrainRect);
			var rect:Rectangle = calcRectFromPoints(_initPoint,_endPoint);
			selectRect = rect;
			dispatchEvent(new LineSelectorEvent(LineSelectorEvent.PROCCESS,false,false,_initPoint,_endPoint,rect));
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			if(_mouseHeldDown)
			{
				_mouseHeldDown = false;
				invalidateSkinState();
				
				var mousePoint:Point = new Point(this.mouseX,this.mouseY);
				_endPoint = getRestrainCrossPoint(mousePoint,restrainRect);
				
				if(_initPoint != _endPoint)
				{
					var rect:Rectangle = calcRectFromPoints(_initPoint,_endPoint);
					selectRect = rect;
					dispatchEvent(new LineSelectorEvent(LineSelectorEvent.FINISH,false,false,_initPoint,_endPoint,rect));
				}
				else
				{
					dispatchEvent(new LineSelectorEvent(LineSelectorEvent.CANCEL,false,false));
					
				}
				
				removeEventListener(Event.ENTER_FRAME,onEnterFrame);
				removeEventListener(MouseEvent.MOUSE_MOVE,onMouseDownMove);
				stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);

			}
		}
		
		private function onStageMouseUp(e:MouseEvent):void
		{
			onMouseUp(e);
		}
		/*private function onMouseMove(e:MouseEvent):void
		{
			var initPoint:Point = new Point(e.localX,e.localY);
			dispatchEvent(new LineSelectorEvent(LineSelectorEvent.INIT,false,false,initPoint));
		}
		
		private function onMouseOut(e:MouseEvent):void{
			
			dispatchEvent(new LineSelectorEvent(LineSelectorEvent.INIT_END,false,false));
			
		}*/
		
		//helper function 
		
		private function getRestrainCrossPoint(refPoint:Point,restrainRect:Rectangle):Point{
			
			var crossPoint:Point;
			var restrainCrossPoint:Point;
			var restrainRect:Rectangle;
			var rawRulePoints:Array;
			var rulePoints:Array;
			
			
			//y=ax+b and y=cx+d
			var a:Number;//斜率
			var b:Number;
			var c:Number;//斜率
			var d:Number;
			
			
			if((refPoint.x>_initPoint.x && refPoint.y>_initPoint.y) || (refPoint.x<_initPoint.x && refPoint.y<_initPoint.y)){
				
				a = 1/ratio;
				c = -1/a;
				
			}else{
				
				a = -1/ratio;
				c = -1/a;
				
			}
			
			b = _initPoint.y - a*_initPoint.x;
			d = refPoint.y - c*refPoint.x;
			
			if(ratio){
				
				if(mode == mode1)
				{
					//模式1：
					crossPoint = new Point((d-b)/(a-c),(a*(d-b)/(a-c))+b);
				}
				else if(mode == mode2)
				{
					//模式2：
					
					if(Math.abs((refPoint.x - _initPoint.x)/(refPoint.y - _initPoint.y))>ratio){
					
					crossPoint = new Point(Math.round((refPoint.y-b)/a),refPoint.y);
					
					}else{
					
					crossPoint = new Point(refPoint.x,Math.round(a*refPoint.x+b));
					
					}
				}

				rawRulePoints = [];
				rawRulePoints.push(new Point((restrainRect.y-b)/a,restrainRect.y));
				rawRulePoints.push(new Point((restrainRect.y+restrainRect.height-b)/a,restrainRect.y+restrainRect.height));
				rawRulePoints.push(new Point(restrainRect.x,a*restrainRect.x+b));
				rawRulePoints.push(new Point(restrainRect.x+restrainRect.width,a*(restrainRect.x+restrainRect.width)+b));
				
				rulePoints = filterRulePoint(rawRulePoints,restrainRect);

			}else{
				
				crossPoint = refPoint;
				
				rawRulePoints = [];
				rawRulePoints.push(new Point(restrainRect.x,restrainRect.y));
				rawRulePoints.push(new Point(restrainRect.x+restrainRect.width,restrainRect.y+restrainRect.height));
				
				rulePoints = filterRulePoint(rawRulePoints,restrainRect);
				
			}
			
			restrainRect = restrainRect;
			
			
			
			
			restrainCrossPoint = restrainPoint(crossPoint,rulePoints);
			
			return restrainCrossPoint;
			
			
		}
		
		
		/**
		 * 
		 * 过滤掉没有意义的限制参照点
		 * 
		 * **/
		
		private function filterRulePoint(rawRulePoints:Array,restrainRect:Rectangle):Array{
			
			var rulePoints:Array = [];
			
			for(var i:int=0; i<rawRulePoints.length; i++){
				
				var point:Point = rawRulePoints[i];
				
				if (point.x>=restrainRect.x && point.x<=restrainRect.x+restrainRect.width && point.y>=restrainRect.y && point.y<=restrainRect.y + restrainRect.height){
					
					rulePoints.push(point);
					
				}			
				
			}
			return rulePoints;
			
		}
		
		/**
		 * 
		 * 限制point对象的范围
		 * 
		 * **/
		private function restrainPoint(targetPoint:Point,rulePoints:Array):Point{
			
			var restrainedPoint:Point;
			
			var minx:Number = Math.round(Math.min(rulePoints[0].x,rulePoints[1].x));
			var maxx:Number = Math.round(Math.max(rulePoints[0].x,rulePoints[1].x));
			var miny:Number = Math.round(Math.min(rulePoints[0].y,rulePoints[1].y));
			var maxy:Number = Math.round(Math.max(rulePoints[0].y,rulePoints[1].y));
			
			var x:Number;
			var y:Number;
			
			if(targetPoint.x<minx){
				
				x = minx;
				
			}else if(targetPoint.x>maxx){
				
				x = maxx;
				
			}else{
				
				x = Math.round(targetPoint.x);
			}
			
			if(targetPoint.y<miny){
				
				y = miny;
				
			}else if(targetPoint.y>maxy){
				
				y = maxy;
				
			}else{
				
				y = Math.round(targetPoint.y);
			}
			
			restrainedPoint = new Point(x,y);
			
			return restrainedPoint;
			
		}
		
		
		private function restrainInitPoint(initPoint:Point,restrainRect:Rectangle):Point{
			
			var newPoint:Point;
			var x:Number;
			var y:Number;
			
			if(initPoint.x<restrainRect.x){
				
				x = restrainRect.x;
				
			}else if(initPoint.x>restrainRect.x+restrainRect.width){
				
				x = restrainRect.x+restrainRect.width;
				
			}else{
				
				x = initPoint.x;
				
			}
			
			if(initPoint.y<restrainRect.y){
				
				y = restrainRect.y;
				
			}else if(initPoint.y>restrainRect.y+restrainRect.height){
				
				y = restrainRect.y+restrainRect.height;
				
			}else{
				
				y = initPoint.y;
				
			}
			
			newPoint = new Point(x,y);
			return newPoint;
		}
		
		/**
		 * 
		 * 根据两个点构造Rectangle对象
		 * 
		 * **/
		private function calcRectFromPoints(initPoint:Point,endPoint:Point):Rectangle{
			
			var rectangle:Rectangle;
			var x:Number;
			var y:Number;
			var w:Number;
			var h:Number;
			
			x = Math.min(initPoint.x,endPoint.x);
			y = Math.min(initPoint.y,endPoint.y);
			w = Math.abs(endPoint.x - initPoint.x);
			h = Math.abs(endPoint.y - initPoint.y);
			
			
			rectangle =  new Rectangle(x,y,w,h);
			return rectangle;
			
		}
		
		private static function classConstruct():Boolean
		{
			var globalApp:UIComponent = FlexGlobals.topLevelApplication as UIComponent;
			var style:CSSStyleDeclaration = globalApp.styleManager.getStyleDeclaration("sxf.utils.selector.lineselector.LineSelector");
			
			if(!style)
			{
				style = new CSSStyleDeclaration();
				style.defaultFactory = function():void
				{
					this.restrainRect = defaultRestrainRect;
					this.ratio = defaultRatio;
				}
				globalApp.styleManager.setStyleDeclaration("sxf.utils.selector.lineselector.LineSelector",style,true);
			}
			else
			{
				if(style.getStyle("restrainRect") == undefined) style.setStyle("restrainRect",defaultRestrainRect);
				if(style.getStyle("ratio") == undefined) style.setStyle("ratio",defaultRatio);
			}
			return true;
		}
	}
}