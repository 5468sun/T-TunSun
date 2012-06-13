package sxf.comps.antlineselector{
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import spark.primitives.Rect;
	
	public class AntLineRectSelector extends UIComponent{
		
		private var _rect:Rectangle;
		private var rectChange:Boolean;
		
		private var defaultRestrainRect:Rectangle;
		private var customRestrainRect:Rectangle;
		private var _useCustomRestrainRect:Boolean;

		private var restrainRectChange:Boolean;
		
		private var _bgWidth:Number;

		private var _bgHeight:Number;

		
		private var bgWidthChange:Boolean;
		private var bgHeightChange:Boolean;

		private var _keepRatio:Boolean;
		private var _ratio:Number;// abs(x/y)
		
		private var antLineRectBox:AntLineBox;
		
		private var _initPoint:Point;
		private var _endPoint:Point;
		
		//private var initPointChange:Boolean;
		//private var endPointChange:Boolean;
		

		
		private var mouseHeldDown:Boolean;

		//private var perWidth:Number;
		//private var perHeight:Number;
		
		public function AntLineRectSelector(){
			
			super();
			
			_rect = new Rectangle(0,0,0,0);
			_keepRatio = false;
			_ratio = 1;
			mouseHeldDown = false;
			rectChange = false;
			useCustomRestrainRect = false;
			restrainRectChange = false;
			bgWidthChange = false;
			bgHeightChange = false;

			addEventListener(FlexEvent.INITIALIZE,onInitialize);
			addEventListener(Event.RESIZE,onResize);
			//addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
			//addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
			addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			
			
			//addEventListener(MouseEvent.MOUSE_MOVE,onMouseShowMousePosition);
			//addEventListener(MouseEvent.MOUSE_OUT,onMouseShowMousePositionEnd);
		}
		
		/**
		 * 获取限制选区 
		 * @return 
		 * 
		 */		
		public function get restrainRect():Rectangle{
			
			if(useCustomRestrainRect && customRestrainRect){
			
				return customRestrainRect;
			
			}else{
			
				return defaultRestrainRect;
			
			}

		}
		/**
		 * 设置限制选区 
		 * @param value
		 * 
		 */		
		public function set restrainRect(value:Rectangle):void{
			
			if(useCustomRestrainRect){
				
				customRestrainRect = value;
				
			}else{
				
				defaultRestrainRect = value;
				
			}
		}
		
		/**
		 * 设置是否使用自定义限制区域
		 * @return 
		 * 
		 */		
		public function get useCustomRestrainRect():Boolean{
			
			return _useCustomRestrainRect;
		}
		/**
		 * 获取是否使用自定义限制区域
		 * @param value
		 * 
		 */		
		public function set useCustomRestrainRect(value:Boolean):void{
			
			_useCustomRestrainRect = value;
		}
		
		
		
		/**
		 * 获取矩形选区
		 * @return 
		 * 
		 */
		public function get rect():Rectangle{
			
			return _rect;
		}
		
		/**
		 * 设置矩形选区
		 * @param value
		 * 
		 */		
		public function set rect(value:Rectangle):void{
			
			if(!value.equals(_rect)){
			
				_rect = value;
				rectChange = true;
				
				invalidateDisplayList();
			
			}
			
		}
		
		/**
		 * 设置初始点
		 * @return 
		 * 
		 */		
		private function get initPoint():Point{
			
			return _initPoint;
		}
		/**
		 * 获取初始点
		 * @param value
		 * 
		 */		
		private function set initPoint(value:Point):void{
			
			_initPoint = value;

		}
		
		
		/**
		 * 设置结束点
		 * @return 
		 * 
		 */		
		private function get endPoint():Point{
			
			return _endPoint;
		}
		/**
		 * 获取结束点
		 * @param value
		 * 
		 */		
		private function set endPoint(value:Point):void{
			
			_endPoint = value;

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
			
			_ratio = value;
			
		}
		
		/**
		 * 
		 * 获取、设置 是否比例
		 * 
		 * **/
		
		public function get keepRatio():Boolean{
			
			return _keepRatio;
			
		}
		
		public function set keepRatio(value:Boolean):void{
			
			_keepRatio = value;
			
		}
		
		private function get bgWidth():Number{
			
			return _bgWidth;
		}
		
		private function set bgWidth(value:Number):void{
			
			if(value != _bgWidth){
				
				_bgWidth = value;
				bgWidthChange = true;
				invalidateDisplayList();
			
			}
			
		}
		
		private function get bgHeight():Number{
			
			return _bgHeight;
		}
		
		private function set bgHeight(value:Number):void{
			
			if(value != _bgHeight){
				
				_bgHeight = value;
				bgHeightChange = true;
				invalidateDisplayList();
				
			}

		}

		////////////////////////
		// overrided functions
		/////////////////////////
		override protected function createChildren():void{
			
			super.createChildren();
			
			if(antLineRectBox == null){
				
				antLineRectBox = new AntLineBox();
				addChild(antLineRectBox);
				
			}
		
		}
		
		override protected function commitProperties():void{
		
			super.commitProperties();
		
		}
		
		override protected function measure():void{
		
			super.measure();
			
			measuredWidth = 100;
			measuredHeight = 100;
			measuredMinWidth = 100;
			measuredMinHeight = 100;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{

			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			if(bgWidthChange){
			
				drawBg(bgWidth,bgHeight);
				bgWidthChange = false;
				
			}
			
			if(bgHeightChange){
			
				drawBg(bgWidth,bgHeight);
				bgHeightChange = false;
				
			}
			
			if(rectChange){
			
				antLineRectBox.drawRect(rect);
				rectChange = false;
				
			}

		}
		
		//////////////////////
		// util functions
		///////////////////////
		
		private function drawBg(w:Number,h:Number):void{
			
			this.graphics.clear();
			this.graphics.beginFill(0xffff00,0.5);
			this.graphics.drawRect(0,0,w,h);
			this.graphics.endFill();
			
		}
		
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
			
			
			if((refPoint.x>initPoint.x && refPoint.y>initPoint.y) || (refPoint.x<initPoint.x && refPoint.y<initPoint.y)){
				
				a = 1/ratio;
				c = -1/a;
				
			}else{
				
				a = -1/ratio;
				c = -1/a;
				
			}
			
			b = initPoint.y - a*initPoint.x;
			d = refPoint.y - c*refPoint.x;
			
			if(keepRatio){
				
				//模式1：
				crossPoint = new Point((d-b)/(a-c),(a*(d-b)/(a-c))+b);
				
				
				
				
				/*模式2：
				
				if(Math.abs((refPoint.x - initPoint.x)/(refPoint.y - initPoint.y))>ratio){
				
				crossPoint = new Point(Math.round((refPoint.y-b)/a),refPoint.y);
				
				}else{
				
				crossPoint = new Point(refPoint.x,Math.round(a*refPoint.x+b));
				
				}
				
				模式2*/
				
				
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
		
		/////////////////////////
		// handler functions
		////////////////////////
		
		private function onInitialize(e:FlexEvent):void{
			
			bgWidth = this.width;
			bgHeight = this.height;
			defaultRestrainRect = new Rectangle(0,0,this.width,this.height);
			
			
			
		}
		
		private function onResize(e:Event):void{
			
			bgWidth = this.width;
			bgHeight = this.height;
			defaultRestrainRect = new Rectangle(0,0,this.width,this.height);
			
		}
		
		/*private function onMouseOver(e:MouseEvent):void{
		
			addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		
		}
		
		private function onMouseOut(e:MouseEvent):void{
		
			removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		
		}*/
		
		private function onMouseMove(e:MouseEvent):void{
			
			if(!mouseHeldDown){
				
				sendLocatePoint();
				
			}
			
		}
		
		private function onMouseDown(e:MouseEvent):void{

			dragBegin();
		
		}
		
		
		
		private function onEnterFrame(e:Event):void{
			
			if(mouseHeldDown){
				
				dragproccess();
				
			}
			
		}
		
		
		
		private function onMouseUp(e:MouseEvent):void{
			
			if(mouseHeldDown){
				
				dragFinish();
				
			}
			
		}
		
		private function onStageMouseUp(e:MouseEvent):void{
			
			if(mouseHeldDown){
				
				dragFinish();
				
			}
			
		}
		
		/*private function onMouseShowMousePosition(e:MouseEvent):void{
			
			trace(e.localX +"|"+ e.localY);
			var initPoint:Point = new Point(e.localX,e.localY);
			dispatchEvent(new AntLineRectSelectorEvent(AntLineRectSelectorEvent.INIT,false,false,initPoint));
			
		}
		private function onMouseShowMousePositionEnd(e:MouseEvent):void{
			
			dispatchEvent(new AntLineRectSelectorEvent(AntLineRectSelectorEvent.INIT_END,false,false));
			
		}*/
		
		
		/////////////////////////
		// handler util functions
		//////////////////////////
		
		private function sendLocatePoint():void{
			
			var locatePoint:Point = new Point(mouseX,mouseY);
			trace(locatePoint);
			dispatchEvent(new AntLineRectSelectorEvent(AntLineRectSelectorEvent.LOCATING,false,false,locatePoint));
			
		}
		

		private function dragBegin():void{
			
			mouseHeldDown = true;
			initPoint = restrainInitPoint(new Point(mouseX,mouseY),restrainRect);
			
			var mousePoint:Point = new Point(this.mouseX,this.mouseY);
			endPoint = getRestrainCrossPoint(mousePoint,restrainRect);
			rect = calcRectFromPoints(initPoint,endPoint);
			trace("rectangle" + rect);
			dispatchEvent(new AntLineRectSelectorEvent(AntLineRectSelectorEvent.BEGIN,false,false,null,initPoint,endPoint,rect));
			
			
			addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			
			
			addEventListener(Event.ENTER_FRAME,onEnterFrame);
			removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			
		}
		
		private function dragproccess():void{
			
			var mousePoint:Point = new Point(this.mouseX,this.mouseY);
			endPoint = getRestrainCrossPoint(mousePoint,restrainRect);
			rect = calcRectFromPoints(initPoint,endPoint);
			trace("rectangle2" + rect);
			dispatchEvent(new AntLineRectSelectorEvent(AntLineRectSelectorEvent.PROCCESS,false,false,null,initPoint,endPoint,rect));
			
		}
		
		private function dragFinish():void{
			
			mouseHeldDown = false;
			var mousePoint:Point = new Point(this.mouseX,this.mouseY);
			endPoint = getRestrainCrossPoint(mousePoint,restrainRect);
			rect = calcRectFromPoints(initPoint,endPoint);
			trace("rectangle3" + rect);
			if(endPoint.equals(initPoint)){
				
				dispatchEvent(new AntLineRectSelectorEvent(AntLineRectSelectorEvent.CANCEL,false,false,null,initPoint,endPoint,rect));
				
			}else{
				
				dispatchEvent(new AntLineRectSelectorEvent(AntLineRectSelectorEvent.FINISH,false,false,null,initPoint,endPoint,rect));
				
			}
			
			
			removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			
		}
	}
}