package sxf.comps.cropselector
{
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.graphics.SolidColor;
	
	import spark.components.RichEditableText;
	import spark.primitives.Rect;
	
	import sxf.comps.cropselector.CropSelectorEvent;
	
	public class CropSelector extends UIComponent
	{
		private var _rect:Rectangle;
		private var rectChange:Boolean;
		
		private var defaultRestrainRect:Rectangle;
		private var customRestrainRect:Rectangle;
		private var _useCustomRestrainRect:Boolean;
		
		private var handles:Array;
		private var rectPoints:Array;
		
		private var handleWidth:Number = 7;
		private var handleHeight:Number = 7;
		private var handleBgColor:Number = 0xffffff;
		private var handleNum:Number = 8;
		
		private var borderThickness:Number = 1;
		private var borderWidth:Number = borderThickness/2;
		private var borderColor:Number = 0x03f731;
		
		private var scaleMode:String = LineScaleMode.NORMAL;//LineScaleMode.NORMAL、LineScaleMode.NONE、LineScaleMode.VERTICAL
		private var caps:String = CapsStyle.SQUARE;//CapsStyle.NONE、CapsStyle.ROUND、CapsStyle.SQUARE
		private var joints:String = JointStyle.MITER;//JointStyle.BEVEL、JointStyle.MITER 、JointStyle.ROUND
		
		private var rectBox:Sprite;
		private var rectBoxBgColor:Number = 0xffffff;

		
		private var maskColor:Number = 0x000000;//mask bg color
		private var maskOpacity:Number = 0.7;//mask bg opacity
		private var maskColor2:Number = 0xffffff;//rect bg color
		private var maskOpacity2:Number = 0;//rect bg opacity
		
		private var activeHandleIndex:Number;
		
		private var resizingRect:Boolean;
		private var movingRect:Boolean;
		private var drawingRect:Boolean;

		

		
		private var handleLocalOffsetX:Number;//小方块上的鼠标触点到方块中心的水平偏移量
		private var handleLocalOffsetY:Number;//小方块上的鼠标触点到方块中心的垂直偏移量
		
		private var resizeInitPoint:Point;
		private var resizeEndPoint:Point;
		
		private var dragInitPoint:Point;
		
		private var drawInitPoint:Point;
		private var drawEndPoint:Point;
		
		private var _keepRatio:Boolean;
		private var _ratio:Number; // abs(x/y)
		
		private var _bgWidth:Number;
		private var _bgHeight:Number;
		private var bgWidthChange:Boolean;
		private var bgHeightChange:Boolean;
		private var mouseHeldDown:Boolean;

		
		/**
		 * 
		 * 构造函数
		 * 
		 * @param initRect 初始截取范围，如未指定，则使用默认的Rectangle(100,100,100,100)。 Rectangle
		 * @param restrainRect 控制可截取范围，如未指定，则可截取范围为Rectangle(0,0,this.width,this.height),既是本控件的范围。 Rectangle
		 * 
		 * **/
		public function CropSelector(){
			
			super();
			
			_rect = new Rectangle(0,0,0,0);
			rectChange = false;
			_useCustomRestrainRect = false;
			resizingRect = false;
			movingRect = false;
			drawingRect = false;
			_keepRatio = false;
			_ratio = 1;
			bgWidthChange = false;
			bgHeightChange = false;
			mouseHeldDown = false;


			addEventListener(FlexEvent.INITIALIZE,onInitialize);
			addEventListener(Event.RESIZE,onResize);
			
			addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP,onMouseUp);

		}
		
		public function get rect():Rectangle{
		
			return this._rect;
		
		}
		
		public function set rect(value:Rectangle):void{
		
			if(!value.equals(_rect)){
			
				this._rect = value;
				rectChange = true;
				invalidateDisplayList();
			
			}
			
		
		}
		
		/**
		 * 
		 * 获取选取限制对象
		 * 
		 * **/
		public function get restrainRect():Rectangle{
			
			if(useCustomRestrainRect){
				trace("customRestrainRect" + customRestrainRect);
				return customRestrainRect;
				
			}else{
				trace("defaultRestrainRect" + defaultRestrainRect);
				return defaultRestrainRect;
				
			}
			
		}
		
		/**
		 * 
		 * 设置选取限制对象
		 * 
		 * **/
		
		public function set restrainRect(rct:Rectangle):void{
			
			if(useCustomRestrainRect){
				
				customRestrainRect = rct;
				
			}else{

				defaultRestrainRect = rct;
				
			}
			
		}
		
		public function get useCustomRestrainRect():Boolean{
			
			return _useCustomRestrainRect;
			
		}
		
		public function set useCustomRestrainRect(value:Boolean):void{
			
			_useCustomRestrainRect = value;
			
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
		
		
		public function get bgWidth():Number{
			
			return _bgWidth;
		}
		
		public function set bgWidth(value:Number):void{
			
			if(value != _bgWidth){
			
				_bgWidth = value;
				bgWidthChange = true;
				invalidateDisplayList();
			
			}
			
		}

		
		public function get bgHeight():Number{
			
			return _bgHeight;
		}
		
		public function set bgHeight(value:Number):void{
			
			if(value != _bgHeight){
				
				_bgHeight = value;
				bgHeightChange = true;
				invalidateDisplayList();
				
			}
			
		}
		/**
		 * 
		 * 更新Cropper
		 * 
		 * **/
		
		public function updateCropper(rectangle:Rectangle):void{
		
			this.rect = rectangle;

			
		}
		
		
		public function moveBy(offsetX:Number,offsetY:Number):void{
		
			var x:Number = rect.x + offsetX;
			var y:Number = rect.y + offsetY;
			var w:Number = rect.width;
			var h:Number = rect.height;
			
			var newRect:Rectangle = new Rectangle(x,y,w,h);
			updateCropper(newRect);
		
		}
		

		
		public function zoomBy(scalevalue:Number):void{
		
			var x:Number = rect.x;
			var y:Number = rect.y;
			
			var w:Number = Math.round(rect.width * scalevalue);
			var h:Number = Math.round(rect.height * scalevalue);
			
			var newRect:Rectangle = new Rectangle(x,y,w,h);
			
			updateCropper(newRect);
		
		}
		
		/**
		 * 
		 * 设置宽高
		 * 
		 * **/
		
		public function setSize(width:Number,height:Number):void{
			
			/* 模式1，顶点为最后操作的把手
			rectPoints = calcRectPoints();
			var tempEndPoint:Point;
			if(activeHandleIndex == -1){activeHandleIndex = 7}
			
			switch (activeHandleIndex){
			
			case 0:
			
			resizeInitPoint = rectPoints[7];
			tempEndPoint = rectPoints[0];
			break;
			
			case 7:
			
			resizeInitPoint = rectPoints[0];
			tempEndPoint = rectPoints[7];
			break;
			
			case 2:
			
			resizeInitPoint = rectPoints[5];
			tempEndPoint = rectPoints[2];
			break;
			
			case 5:
			
			resizeInitPoint = rectPoints[2];
			tempEndPoint = rectPoints[5];
			break;
			
			case 1:
			
			resizeInitPoint = rectPoints[6];
			tempEndPoint = rectPoints[1];
			break;
			
			case 3:
			
			resizeInitPoint = rectPoints[4];
			tempEndPoint = rectPoints[3];
			break;
			
			case 4:
			
			resizeInitPoint = rectPoints[3];
			tempEndPoint = rectPoints[4];
			break;
			
			case 6:
			
			resizeInitPoint = rectPoints[1];
			tempEndPoint = rectPoints[6];
			break;
			
			}
			
			var initX:Number;
			var initY:Number;
			var endX:Number;
			var endY:Number;
			var newX:Number;
			var newY:Number;
			
			initX = resizeInitPoint.x;
			initY = resizeInitPoint.y;
			
			endX = tempEndPoint.x;
			endY = tempEndPoint.y;
			
			
			if(endX>initX){
			
			newX = initX + width;
			
			}else{
			
			newX = initX - width;
			
			}
			
			if(endY>initY){
			
			newY = initY + height;
			
			}else{
			
			newY = initY - height;
			
			}
			
			var crossPoint:Point = new Point(newX,newY);
			trace("resizeInitPoint"+resizeInitPoint);
			trace("tempEndPoint"+tempEndPoint);
			trace("crossPoint"+crossPoint);
			this.resizeEndPoint = getRestrainEndPoint(crossPoint,this.restrainRect);
			
			trace("resizeEndPoint"+resizeEndPoint);
			var newRect:Rectangle = calcRectFromPoints(this.resizeInitPoint,this.resizeEndPoint);
			
			trace(newRect);
			updateCropper(newRect);
			
			*/
			
			//* 模式2,顶点为左上角
			rectPoints = calcRectPoints();
			
			var tempEndPoint:Point;
			
			resizeInitPoint = rectPoints[0];
			tempEndPoint = rectPoints[7];
			

			var initX:Number;
			var initY:Number;
			var endX:Number;
			var endY:Number;
			var newX:Number;
			var newY:Number;
			
			initX = resizeInitPoint.x;
			initY = resizeInitPoint.y;
			
			endX = tempEndPoint.x;
			endY = tempEndPoint.y;
			
			
			if(endX>initX){
			
			newX = initX + width;
			
			}else{
			
			newX = initX - width;
			
			}
			
			if(endY>initY){
			
			newY = initY + height;
			
			}else{
			
			newY = initY - height;
			
			}
			
			var crossPoint:Point = new Point(newX,newY);

			this.resizeEndPoint = getRestrainEndPoint(crossPoint,this.restrainRect);

			var newRect:Rectangle = calcRectFromPoints(this.resizeInitPoint,this.resizeEndPoint);

			updateCropper(newRect);
			
			//*/
			
		}
		
		//////////////////////////
		// override functions
		/////////////////////////
		override protected function createChildren():void{
		
			super.createChildren();
			createView();
			
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
				
				updateView();
				rectChange = false;
				
			}
		
		}
		
		
		/**
		 * 
		 * 创建选取方框
		 * 
		 * **/
		private function createRectBox():void{
			
			rectBox = new Sprite();
			addChild(rectBox);

		}
		
		/**
		 * 
		 * 调整选取框的大小和位置
		 * 
		 * **/
		private function updateRectBox():void{
			
			drawBorderAndBg(rectBox,rect,borderThickness,borderColor,rectBoxBgColor,1,true,scaleMode,caps,joints);
			
		}
		
		/**
		 * 
		 * 创建8个调整按钮,初始化按钮位置
		 * 
		 * **/
		private function createHandles():void{
			
			handles = new Array();
			
			var handleRect:Rectangle = new Rectangle(0,0,handleWidth,handleHeight);
			
			for(var i:int = 0; i<handleNum; i++){
				
				var handle:Sprite = new Sprite();
				drawBorderAndBg(handle,handleRect,borderThickness,borderColor,handleBgColor,1,true,scaleMode,caps,joints);
				handles.push(handle);
				addChild(handle);
				
			}

		}
		
		
		
		/**
		 * 
		 * 调整8个按钮的位置
		 * 
		 * **/
		private function updateHandles():void{

			var handlePoints:Array = calHandlePoints();
			
			for(var i:int = 0; i<handles.length; i++){
				
				var point:Point = handlePoints[i] as Point;
				var handle:Sprite = handles[i] as Sprite;
				
				handle.x = Math.round(point.x - handle.width/2);
				handle.y = Math.round(point.y - handle.height/2);
				
			}
			
		}
		
		
		
		/**
		 * 
		 * 根据传入的Rectangle对象计算8个控制点的坐标位置。
		 * **/
		private function calHandlePoints():Array{
			
			var borderThicknessw:Number = rect.width<0?-borderThickness:borderThickness;
			var borderThicknessh:Number = rect.height<0?-borderThickness:borderThickness;
			var x:Number = this.rect.x - borderThicknessw;
			var y:Number = this.rect.y - borderThicknessh;
			var w:Number = this.rect.width + borderThicknessw;
			var h:Number = this.rect.height + borderThicknessh;
			
			var borderedRect:Rectangle = new Rectangle(x,y,w,h);
	
			return calcPoints(borderedRect);
			
		}
		
		private function calcRectPoints():Array{
			
			return calcPoints(this.rect);
		
		}
		
		/**
		 * 
		 * 计算8个端点
		 * 
		 * **/
		
		private function calcPoints(rect:Rectangle):Array{
			
			var rectPoints:Array = new Array();
			
			rectPoints.push(new Point(rect.x,rect.y));
			rectPoints.push(new Point(Math.round(rect.x+rect.width/2),rect.y));
			rectPoints.push(new Point(rect.x+rect.width,rect.y));
			
			rectPoints.push(new Point(rect.x,rect.y+Math.round(rect.height/2)));
			rectPoints.push(new Point(rect.x+rect.width,rect.y+Math.round(rect.height/2)));
			
			rectPoints.push(new Point(rect.x,rect.y+rect.height));
			rectPoints.push(new Point(rect.x+Math.round(rect.width/2),rect.y+rect.height));
			rectPoints.push(new Point(rect.x+rect.width,rect.y+rect.height));
			
			return rectPoints;
			
		}
		/**
		 * 
		 * 更新遮罩
		 * 
		 * **/
		private function updateMask():void{

			var x:Number = (rect.width<0)?(rect.x + rect.width):rect.x;
			var y:Number = (rect.height<0)?(rect.y + rect.height):rect.y;
			var w:Number = Math.abs(rect.width);
			var h:Number = Math.abs(rect.height);
			graphics.clear();
			graphics.beginFill(maskColor,maskOpacity);
			graphics.drawRect(0,0,x,y);
			graphics.drawRect(x,0,w,y);
			graphics.drawRect(x+w,0,this.width-(x+w),y);
			
			graphics.drawRect(0,y,x,h);
			graphics.drawRect(x+w,y,this.width-(x+w),h);
			
			graphics.drawRect(0,y+h,x,this.height-(y+h));
			graphics.drawRect(x,y+h,w,this.height-(y+h));
			graphics.drawRect(x+w,y+h,this.width-(x+w),this.height-(y+h));
			
			graphics.beginFill(maskColor2,maskOpacity2);
			graphics.drawRect(x,y,w,h);
			
			graphics.endFill();
			
		}
		
		/**
		 * 画透明背景，用以响应鼠标事件
		 * @param w
		 * @param h
		 * 
		 */		
		private function drawBg(w:Number,h:Number):void{
			
			this.graphics.clear();
			this.graphics.beginFill(0x000000,0.1);
			this.graphics.drawRect(0,0,w,h);
			this.graphics.endFill();
			
		}
		
		/**
		 * 
		 * 根据rectangle对象为Sprite画背景和边框
		 * 
		 * **/
		
		private function drawBorderAndBg(target:Sprite,rect:Rectangle,borderThickness:Number,borderColor:int,bgColor:int,alpha:Number=1.0, pixelHinting:Boolean=false, scaleMode:String="normal", caps:String=null, joints:String=null):void{
			//宽高为正数和负数的算法不一样
			var borderThicknessw:Number = rect.width<0?-borderThickness:borderThickness;
			var borderThicknessh:Number = rect.height<0?-borderThickness:borderThickness;
			target.graphics.clear();
			target.graphics.moveTo(0,0);
			target.graphics.beginFill(bgColor,0);
			target.graphics.lineStyle(borderThickness,borderColor,1,pixelHinting,scaleMode,caps,joints);
			target.graphics.drawRect(borderThicknessw/2,borderThicknessh/2,rect.width+borderThicknessw,rect.height+borderThicknessh);
			target.graphics.endFill();
			target.x = rect.x - borderThicknessw;
			target.y = rect.y - borderThicknessh;
		}
		
		/**
		 * 
		 * 创建视图
		 * 
		 * **/
		private function createView():void{
			
			createRectBox();
			createHandles();
			hideView();
			
		}
		
		/**
		 * 
		 * 更新视图
		 * 
		 * **/
		private function updateView():void{


			updateRectBox();
			updateHandles();
			//updateMask();
			
		}
		
		private function hideView():void{
		
			rectBox.visible = false;
			for each (var handle:Sprite in handles){
			
				handle.visible = false;
			
			}
		
		}
		
		private function showView():void{
		
			rectBox.visible = true;
			for each (var handle:Sprite in handles){
				
				handle.visible = true;
				
			}
		
		}
		
		/**
		 * 
		 * 更新选取区域数据
		 * 
		 * **/
		
		
		private function calcDrawRect():Rectangle{
		
			var newRect:Rectangle;
			var mousePoint:Point = new Point(this.mouseX,this.mouseY);
trace(restrainRect);
			this.drawEndPoint = getRestrainEndPoint(mousePoint,restrainRect);
			
			newRect = calcRectFromPoints(this.drawInitPoint,this.drawEndPoint);
			
			return newRect;
		
		}
		
		private function calcResizeRect():Rectangle{
		
			var newRect:Rectangle;
			var mousePoint:Point = new Point(this.mouseX + this.handleLocalOffsetX,this.mouseY + this.handleLocalOffsetY);
			
			this.resizeEndPoint = getRestrainEndPoint(mousePoint,this.restrainRect);
			
			newRect = calcRectFromPoints(this.resizeInitPoint,this.resizeEndPoint);
			
			return newRect;
		
		}
		
		private function calcMoveRect():Rectangle{
		
			var newRect:Rectangle;
			var offx:Number;
			var offy:Number;
			var offsetx:Number;
			var offsety:Number;
			
			var gInitPoint:Point = rectBox.localToGlobal(dragInitPoint);
			var lInitPont:Point = this.globalToLocal(gInitPoint);
			
			offx = this.mouseX - Math.round(lInitPont.x);
			offy = this.mouseY - Math.round(lInitPont.y);
			
			var moveBackx1:Number = dragInitPoint.x<0?((rectBox.width + dragInitPoint.x) - borderThickness):(dragInitPoint.x - borderThickness);
			var moveBackx2:Number = dragInitPoint.x<0?(-dragInitPoint.x - borderThickness):((rectBox.width - dragInitPoint.x) - borderThickness);
			
			if(offx<(restrainRect.x - lInitPont.x + moveBackx1)){
				
				offsetx = (restrainRect.x - lInitPont.x + moveBackx1);
				
			}else if(offx > (restrainRect.x + restrainRect.width - lInitPont.x - moveBackx2)){
				
				offsetx = (restrainRect.x + restrainRect.width - lInitPont.x - moveBackx2);
				
			}else{
				
				offsetx = offx;
				
			}
			
			var moveBacky1:Number = dragInitPoint.y<0?((rectBox.height + dragInitPoint.y) - borderThickness):(dragInitPoint.y - borderThickness);
			var moveBacky2:Number = dragInitPoint.y<0?(-dragInitPoint.y - borderThickness):((rectBox.height - dragInitPoint.y) - borderThickness);
			
			if(offy<(restrainRect.y - lInitPont.y + moveBacky1)){
				
				offsety = (restrainRect.y - lInitPont.y + moveBacky1);
				
			}else if(offy > (restrainRect.y + restrainRect.height - lInitPont.y - moveBacky2)){
				
				offsety = (restrainRect.y + restrainRect.height - lInitPont.y - moveBacky2);
				
			}else{
				
				offsety = offy;
				
			}
			
			
			newRect = new Rectangle((rect.x+offsetx),(rect.y+offsety),rect.width,rect.height);
			
			return newRect;
		
		}

		
		///////////////////////////////////
		//
		//  util functions
		// 
		/////////////////////////////////////
			
		
		
		
		
		
		/**
		 * 
		 * 重新计算限制框 在拖动上下左右把手时用到
		 * 
		 * **/
		
		private function recalcRestrainRect(restrainRect:Rectangle,initPoint:Point,direction:String="vertical"):Rectangle{
			
			var newRestrainRect:Rectangle;
			var vertical:Boolean = (direction == "vertical");
			
			var on:Number = vertical?restrainRect.x:restrainRect.y;
			var pn:Number = vertical?initPoint.x:initPoint.y;
			var rn:Number = vertical?restrainRect.width:restrainRect.height;
			var absn:Number;
			
			if((pn - on)/(on + rn - pn)<1){
				
				absn = Math.abs(pn - on);
				
			}else if((pn - on)/(on + rn - pn)>=1){
				
				absn = Math.abs(on + rn - pn);
				
			}

			newRestrainRect = vertical?new Rectangle(pn-absn,restrainRect.y,absn*2,restrainRect.height):new Rectangle(restrainRect.x,pn-absn,restrainRect.width,absn*2);

			return newRestrainRect;
			
		}

		
		
		/**
		 * 
		 * 获取过参照点并与斜线垂直的交点，返回受限制的交点
		 * 
		 * **/
		private function getRestrainEndPoint(refPoint:Point,restrainRect:Rectangle):Point{
			
			var initPoint:Point;
			var crossPoint:Point;
			var restrainedEndPoint:Point;
			var restrainRect:Rectangle;
			var rawRulePoints:Array;
			var rulePoints:Array;
			
			
			//y=ax+b and y=cx+d
			var a:Number;//斜率
			var b:Number;
			var c:Number;//斜率
			var d:Number;
			
			if(drawingRect){
				
				initPoint = drawInitPoint;
			
			}else if(resizingRect){
			
				initPoint = resizeInitPoint;
			
			}
			
			switch (activeHandleIndex){
				
				case 0:
				case 7:	
				case 2:
				case 5:
					
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
						restrainRect = restrainRect;
						
						
						
						///*模式2：
						
						/*if(Math.abs((refPoint.x - initPoint.x)/(refPoint.y - initPoint.y))>ratio){
						
						crossPoint = new Point(Math.round((refPoint.y-b)/a),refPoint.y);
						
						}else{
						
						crossPoint = new Point(refPoint.x,Math.round(a*refPoint.x+b));
						
						}*/
						
						//模式2*/
						
						
					}else{
						
						crossPoint = refPoint;
						restrainRect = restrainRect;
						
						
					}
					
					break;
				
				case 1:
				case 6:	
					
					a = 2/ratio;
					b = initPoint.y - a*initPoint.x;
					rectPoints = calcRectPoints();
					crossPoint = new Point(rectPoints[1].x,refPoint.y);
					restrainRect = recalcRestrainRect(restrainRect,initPoint,"vertical");
					break;
				
				case 3:
				case 4:	
					
					a = 1/(ratio*2);
					b = initPoint.y - a*initPoint.x;
					rectPoints = calcRectPoints();
					crossPoint = new Point(refPoint.x,rectPoints[3].y);
					restrainRect = recalcRestrainRect(restrainRect,initPoint,"horizontal");
					
					break;
				
				case -1:
					
					crossPoint = refPoint;
					restrainRect = restrainRect;
					break;
				
			}
			

			if(keepRatio){
				
				rawRulePoints = [];
				rawRulePoints.push(new Point((restrainRect.y-b)/a,restrainRect.y));
				rawRulePoints.push(new Point((restrainRect.y+restrainRect.height-b)/a,restrainRect.y+restrainRect.height));
				rawRulePoints.push(new Point(restrainRect.x,a*restrainRect.x+b));
				rawRulePoints.push(new Point(restrainRect.x+restrainRect.width,a*(restrainRect.x+restrainRect.width)+b));

				rulePoints = filterRulePoint(rawRulePoints,restrainRect);
			
			}else{
			
				rawRulePoints = [];
				rawRulePoints.push(new Point(restrainRect.x,restrainRect.y));
				rawRulePoints.push(new Point(restrainRect.x+restrainRect.width,restrainRect.y+restrainRect.height));
				
				rulePoints = filterRulePoint(rawRulePoints,restrainRect);
			
			}


			restrainedEndPoint = restrainCrossPoint(crossPoint,rulePoints);

			return restrainedEndPoint;
			
			
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
		 * 修正交点
		 * 
		 * **/
		private function restrainCrossPoint(targetPoint:Point,rulePoints:Array):Point{

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
		
		/**
		 * 修正初始点 
		 * @param initPoint
		 * @param restrainRect
		 * @return 
		 * 
		 */		
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
			
			

			switch(activeHandleIndex){
			
				case -1:
				case 0:
				case 7:	
				case 2:
				case 5:
					
					x = Math.min(initPoint.x,endPoint.x);
					y = Math.min(initPoint.y,endPoint.y);
					w = Math.abs(endPoint.x - initPoint.x);
					h = Math.abs(endPoint.y - initPoint.y);
					break;
				
				case 1:
				case 6:
					
					h = Math.abs(endPoint.y - initPoint.y);
					y = Math.min(initPoint.y,endPoint.y);
					
					if(keepRatio){
						
						w = Math.abs(Math.round(h*ratio));
						x = initPoint.x - Math.round(w/2);
					
					}else{
					
						w = rect.width;
						x = rect.x;
					
					}
					break;
				
				case 3:
				case 4:
					w = Math.abs(endPoint.x - initPoint.x);
					x = Math.min(initPoint.x,endPoint.x);
					
					if(keepRatio){
						
						h = Math.abs(Math.round(w/ratio));
						y = initPoint.y - Math.round(h/2);
						
					}else{
						
						h = rect.height;
						y = rect.y;
						
					}
					break;
			
			}

			
			rectangle =  new Rectangle(x,y,w,h);
			return rectangle;
			
		}
		/////////////////////////////
		//
		//   handlers
		//
		///////////////////////////////
		
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
		
		private function onMouseMove(e:MouseEvent):void{
		
			if(!mouseHeldDown){
				
				sendLocatePoint();
				
			}	
		
		}
		
		private function onMouseDown(e:MouseEvent):void{

			mouseHeldDown = true;
			
			var handle:Sprite = e.target as Sprite;
			var index:int = handles.indexOf(handle);
			
			if(index == -1 && handle != rectBox){
				
				drawingRect = true;
				activeHandleIndex = 7;
				drawInitPoint = restrainInitPoint(new Point(mouseX,mouseY),restrainRect);
				
				showView();
				trace("CropSelectorEvent.DRAW_BEGIN");
				dispatchEvent(new CropSelectorEvent(CropSelectorEvent.DRAW_BEGIN,false,false,null,drawInitPoint));
				
				
			}else if(index!=-1){

				resizingRect = true;
				activeHandleIndex = index;
				handleLocalOffsetX = Math.abs(Sprite(e.target).width/2) - e.localX;
				handleLocalOffsetY = Math.abs(Sprite(e.target).height/2) - e.localY;
				
				rectPoints = calcRectPoints();
				
				switch (activeHandleIndex){
					
					case 0:
						
						resizeInitPoint = rectPoints[7];
						break;
					
					case 7:
						
						resizeInitPoint = rectPoints[0];
						break;
					
					case 2:
						
						resizeInitPoint = rectPoints[5];
						break;
					
					case 5:
						
						resizeInitPoint = rectPoints[2];
						break;
					
					case 1:
						
						resizeInitPoint = rectPoints[6];
						break;
					
					case 3:
						
						resizeInitPoint = rectPoints[4];
						break;
					
					case 4:
						
						resizeInitPoint = rectPoints[3];
						break;
					
					
					
					case 6:
						
						resizeInitPoint = rectPoints[1];
						break;
				}
				
			}else if(handle == rectBox){

				movingRect = true;
				dragInitPoint = new Point(e.localX,e.localY);
				
			}
			
			addEventListener(Event.ENTER_FRAME,onEnterFrame);
			addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			
		}
		
		
		
		private function onEnterFrame(e:Event):void{
		
			var newRect:Rectangle;

			if(drawingRect){
				
				newRect = calcDrawRect();
				updateCropper(newRect);
				trace("CropSelectorEvent.DRAWING" + newRect);
				dispatchEvent(new CropSelectorEvent(CropSelectorEvent.DRAWING,false,false,null,drawInitPoint,drawEndPoint,newRect));
				
			}else if(resizingRect){
				
				newRect = calcResizeRect();
				updateCropper(newRect);
				trace("CropSelectorEvent.RESIZE" + newRect);
				dispatchEvent(new CropSelectorEvent(CropSelectorEvent.RESIZE,false,false,null,resizeInitPoint,resizeEndPoint,newRect));
			
			}else if(movingRect){
				
				newRect = calcMoveRect();
				updateCropper(newRect);
				trace("CropSelectorEvent.MOVE" + newRect);
				dispatchEvent(new CropSelectorEvent(CropSelectorEvent.MOVE,false,false,null,dragInitPoint,null,newRect));
			
			}
			
						
		}
		
		
		private function onMouseUp(e:MouseEvent):void{
			
			
			mouseUpHandler();
			
		}
		
		private function onStageMouseUp(e:MouseEvent):void{
			
			
			mouseUpHandler();
		}
		
		
		////////////////////////
		// handler util functions
		/////////////////////////
		
		private function sendLocatePoint():void{
			
			var locatePoint:Point = new Point(mouseX,mouseY);
			trace("CropSelectorEvent.LOCATING"+locatePoint);
			dispatchEvent(new CropSelectorEvent(CropSelectorEvent.LOCATING,false,false,locatePoint));
			
		}
		
		private function mouseUpHandler():void{
		
			if(drawingRect){
				
				//drawInitPoint = null;
				//drawEndPoint = null;
				drawingRect = false;
				if(drawEndPoint.equals(drawInitPoint)){
					trace("CropSelectorEvent.CANCEL");
					dispatchEvent(new CropSelectorEvent(CropSelectorEvent.DRAW_CANCEL,false,false,null));
					hideView();
					
				}else{
					trace("CropSelectorEvent.FINISH"+rect);
					dispatchEvent(new CropSelectorEvent(CropSelectorEvent.DRAW_FINISH,false,false,null,drawInitPoint,drawEndPoint,rect));
					
				}
				
				
			}else if(resizingRect){
				
				//resizeInitPoint = null;
				//resizeEndPoint = null;
				resizingRect = false;
				
			}else if(movingRect){
				
				//dragInitPoint = null;
				movingRect = false;
				
			}
			rectPoints = null;
			
			removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			removeEventListener(MouseEvent.MOUSE_MOVE,onMouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
		
		}
		
	}
}