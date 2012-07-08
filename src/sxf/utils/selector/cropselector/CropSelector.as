package sxf.utils.selector.cropselector
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.BitmapAsset;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	import sxf.utils.selector.cropselector.CropSelectorEvent;
	import sxf.utils.selector.lineselector.AntLine;
	
	[SkinState("normal")]
	[SkinState("selecting")]
	[SkinState("selected")]
	
	[Style(name="restrainRect",type="Rectangle",inherit="yes")]
	[Style(name="ratio",type="Number",inherit="yes")]
	
	public class CropSelector extends SkinnableComponent
	{
		private static var classConstructed:Boolean = classConstruct();
		private static const defaultRestrainRect:Rectangle = null;
		private static const defaultRatio:Number = 0;
		private static const mode1:String = "mode1";
		private static const mode2:String = "mode2";

		private var _rectPoints:Array;
		private var _activatedBtn:Sprite;
		
		private var _cropRect:Rectangle;

		private var _restrainRect:Rectangle;
		private var _ratio:Number;
		private var _mode:String = mode1;
		
		private var _selecting:Boolean = false;
		private var _resizing:Boolean = false;
		private var _moving:Boolean = false;
		
		private var _selectInitPoint:Point;
		private var _selectEndPoint:Point;
		
		private var _resizeInitPoint:Point;
		private var _resizeEndPoint:Point;
		
		private var _moveInitPoint:Point;
		private var _moveEndPoint:Point;
		
		private var handleLocalOffsetX:Number;//小方块上的鼠标触点到方块中心的水平偏移量
		private var handleLocalOffsetY:Number;//小方块上的鼠标触点到方块中心的垂直偏移量
		
		[SkinPart(required="true")]
		public var _antLine:AntLine;
		
		[SkinPart(required="true")]
		public var _solidLine:SolidLine;
		
		[SkinPart(required="true")]
		public var _tlBtn:HandleButton;
		
		[SkinPart(required="true")]
		public var _tmBtn:HandleButton;
		
		[SkinPart(required="true")]
		public var _trBtn:HandleButton;
		
		[SkinPart(required="true")]
		public var _mlBtn:HandleButton;
		
		[SkinPart(required="true")]
		public var _mrBtn:HandleButton;
		
		[SkinPart(required="true")]
		public var _blBtn:HandleButton;
		
		[SkinPart(required="true")]
		public var _bmBtn:HandleButton;
		
		[SkinPart(required="true")]
		public var _brBtn:HandleButton;
		
		[Embed(source="/TunSun/assets/cropping.png")]
		public var MouseCropping:Class;
		
		[Embed(source="/TunSun/assets/moving.png")]
		public var MouseMoving:Class;
		
		[Embed(source="/TunSun/assets/resize_vertical.png")]
		public var MouseResizeVertical:Class;
		
		[Embed(source="/TunSun/assets/resize-horizontal.png")]
		public var MouseResizeHorizontal:Class;
		
		[Embed(source="/TunSun/assets/resize_angel1.png")]
		public var MouseResizeAngel1:Class;
		
		[Embed(source="/TunSun/assets/resize_angel2.png")]
		public var MouseResizeAngel2:Class;
		
		public function CropSelector()
		{
			super();
			_cropRect = new Rectangle();
			addEventListener(FlexEvent.CREATION_COMPLETE,onCreateComplete);
			addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			
			addEventListener(MouseEvent.ROLL_OVER,onMouseOver);
			addEventListener(MouseEvent.ROLL_OUT,onMouseOut);
			
			addEventListener(Event.RESIZE,onResize);
		}
		
		public function get cropRect():Rectangle
		{
			return _cropRect;
		}
		
		public function set cropRect(value:Rectangle):void
		{
			if(!value.equals(_cropRect))
			{
				_cropRect = value;
				invalidateProperties();
			}
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
		/**
		 * 设置鼠标画框模式
		 * **/
		public function get mode():String{
			
			return _mode;
		}
		
		public function set mode(value:String):void{
			
			if(value != _mode)
			{
				_mode = value;
			}
		}
		
		public function deActivate():void
		{
			this.visible = false;
			_selecting = false;
			cropRect = new Rectangle();
			invalidateSkinState();
		}
		
		public function activate():void
		{
			this.visible = true;
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			if(instance == _antLine)
			{
				_antLine.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
				_antLine.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			}
			else if(instance == _solidLine)
			{
				_solidLine.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
				_solidLine.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			}
			else if(instance == _tlBtn || instance == _tmBtn || instance == _trBtn || instance == _mlBtn || instance == _mrBtn || instance == _blBtn || instance == _bmBtn || instance == _brBtn)
			{
				HandleButton(instance).addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
				HandleButton(instance).addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
				HandleButton(instance).addEventListener(MouseEvent.ROLL_OVER,onHandleOver);
				HandleButton(instance).addEventListener(MouseEvent.ROLL_OUT,onHandleOut);
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			if(instance == _antLine)
			{
				_antLine.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
				_antLine.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			}
			else if(instance == _solidLine)
			{
				_solidLine.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
				_solidLine.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			}
			else if(instance == _tlBtn || instance == _tmBtn || instance == _trBtn || instance == _mlBtn || instance == _mrBtn || instance == _blBtn || instance == _bmBtn || instance == _brBtn)
			{
				HandleButton(instance).removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
				HandleButton(instance).removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
				HandleButton(instance).removeEventListener(MouseEvent.ROLL_OVER,onHandleOver);
				HandleButton(instance).removeEventListener(MouseEvent.ROLL_OUT,onHandleOut);
			}
		}
		
		override public function styleChanged(styleProp:String):void
		{
			switch(styleProp)
			{
				case "restrainRect":
					
					restrainRect = getStyle("restrainRect");
					break;
				
				case "ratio":
					
					ratio = getStyle("ratio");
					break;
				
				default:
					break;
			}
		}
		
		override public function stylesInitialized():void
		{
			if(!restrainRect) restrainRect = getStyle("restrainRect");
			if(!ratio ) ratio = getStyle("ratio");
		}

		override protected function getCurrentSkinState():String
		{
			var skinState:String;

			if(_selecting && (cropRect.width && cropRect.height))
			{
				skinState = "selecting";
			}
			else if(!_selecting && (cropRect.width && cropRect.height))
			{
				skinState = "selected";
			}
			else if(!_selecting && cropRect.width == 0 && cropRect.height == 0)
			{
				skinState = "normal";
			}
			else
			{
				skinState = "normal";
			}
			return skinState;
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			_rectPoints = calcRectPoints();
			invalidateDisplayList();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			_antLine.rectangle = cropRect;
			_solidLine.rectangle = cropRect;
			
			_tlBtn.x = _rectPoints[0].x;
			_tlBtn.y = _rectPoints[0].y;
			_tmBtn.x = _rectPoints[1].x;
			_tmBtn.y = _rectPoints[1].y;
			_trBtn.x = _rectPoints[2].x;
			_trBtn.y = _rectPoints[2].y;
			_mlBtn.x = _rectPoints[3].x;
			_mlBtn.y = _rectPoints[3].y;
			_mrBtn.x = _rectPoints[4].x;
			_mrBtn.y = _rectPoints[4].y;
			_blBtn.x = _rectPoints[5].x;
			_blBtn.y = _rectPoints[5].y;
			_bmBtn.x = _rectPoints[6].x;
			_bmBtn.y = _rectPoints[6].y;
			_brBtn.x = _rectPoints[7].x;
			_brBtn.y = _rectPoints[7].y;
			
			super.updateDisplayList(unscaledWidth,unscaledHeight);
		}
		
		//  事件处理函数    /////////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * 创建成功，初始化约束矩形区域
		 * **/
		private function onCreateComplete(e:FlexEvent):void
		{
			if(!restrainRect)
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
		}
		
		/**
		 * 改变应用尺寸时调整约束矩形区域
		 * **/
		private function onResize(e:Event):void
		{
			if(!restrainRect)
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
			
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			e.stopPropagation();
			var newRect:Rectangle;
			
			if(e.currentTarget == this)//拖放选取
			{
				cropRect = new Rectangle();
				
				_resizing = false;
				_moving = false;
				_selecting = true;
				_activatedBtn = null;
				
				_selectInitPoint = restrainInitPoint(new Point(this.mouseX,this.mouseY),restrainRect);
				_selectEndPoint = _selectInitPoint;
				newRect = calcRectFromPoints(_selectInitPoint,_selectEndPoint);
				cropRect = newRect;
				dispatchEvent(new CropSelectorEvent(CropSelectorEvent.SELECT_BEGIN,false,false,_selectInitPoint,_selectEndPoint,newRect));
				
			}
			else if(e.currentTarget is SolidLine)//拖放移动
			{
				_selecting = false;
				_resizing = false;
				_moving = true;
				_activatedBtn = null;
				
				_moveInitPoint = new Point(this.mouseX - cropRect.x,this.mouseY - cropRect.y);
				_moveEndPoint = _moveInitPoint;
				newRect = cropRect;
				
				dispatchEvent(new CropSelectorEvent(CropSelectorEvent.MOVE_BEGIN,false,false,_moveInitPoint,_moveEndPoint,newRect));
			}
			else if(e.currentTarget is HandleButton)//拖放调整大小
			{
				_selecting = false;
				_moving = false;
				_resizing = true;
				
				handleLocalOffsetX = Math.round(HandleButton(e.currentTarget).width/2) - e.localX;
				handleLocalOffsetY = Math.round(HandleButton(e.currentTarget).height/2) - e.localY;
				
				//_rectPoints = calcRectPoints();
				
				switch (e.currentTarget){
					
					case _tlBtn:
						_activatedBtn = _tlBtn;
						_resizeInitPoint = _rectPoints[7];
						break;
					
					case _brBtn:
						_activatedBtn = _brBtn;
						_resizeInitPoint = _rectPoints[0];
						break;
					
					case _trBtn:
						_activatedBtn = _trBtn;
						_resizeInitPoint = _rectPoints[5];
						break;
					
					case _blBtn:
						_activatedBtn = _blBtn;
						_resizeInitPoint = _rectPoints[2];
						break;
					
					case _tmBtn:
						_activatedBtn = _tmBtn;
						_resizeInitPoint = _rectPoints[6];
						break;
					
					case _mlBtn:
						_activatedBtn = _mlBtn;
						_resizeInitPoint = _rectPoints[4];
						break;
					
					case _mrBtn:
						_activatedBtn = _mrBtn;
						_resizeInitPoint = _rectPoints[3];
						break;
					
					
					
					case _bmBtn:
						_activatedBtn = _bmBtn;
						_resizeInitPoint = _rectPoints[1];
						break;
				}

				_resizeEndPoint = _resizeInitPoint;
				newRect = cropRect;
				dispatchEvent(new CropSelectorEvent(CropSelectorEvent.MOVE_BEGIN,false,false,_resizeInitPoint,_resizeEndPoint,newRect));
			}
			
			invalidateSkinState();
			addEventListener(MouseEvent.MOUSE_MOVE,onMouseDownMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		private function onMouseDownMove(e:MouseEvent):void
		{
			invalidateSkinState();
			addEventListener(Event.ENTER_FRAME,onEnterFrame);
			removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		}
		
		private function onEnterFrame(e:Event):void{
			
			var newRect:Rectangle;
			var mousePoint:Point;
			
			if(_selecting){
				
				mousePoint = new Point(this.mouseX,this.mouseY);
				_selectEndPoint = getRestrainCrossPoint(mousePoint,restrainRect);
				
				newRect = calcRectFromPoints(_selectInitPoint,_selectEndPoint);
				cropRect = newRect;
				dispatchEvent(new CropSelectorEvent(CropSelectorEvent.SELECT_PROCCESS,false,false,_selectInitPoint,_selectEndPoint,newRect));
				
			}else if(_resizing){
				
				mousePoint = new Point(this.mouseX + handleLocalOffsetX,this.mouseY + handleLocalOffsetY);
				_resizeEndPoint = getRestrainCrossPoint(mousePoint,restrainRect);
				
				newRect = calcRectFromPoints(_resizeInitPoint,_resizeEndPoint);
				cropRect = newRect;
				dispatchEvent(new CropSelectorEvent(CropSelectorEvent.RESIZE_PROCCESS,false,false,_resizeInitPoint,_resizeEndPoint,newRect));
				
			}else if(_moving){
				
				var offx:Number;
				var offy:Number;
				var offsetx:Number;
				var offsety:Number;

				_moveEndPoint = restrainEndPoint(new Point(this.mouseX,this.mouseY));
				
				offx = _moveEndPoint.x - (_moveInitPoint.x + cropRect.x);
				offy = _moveEndPoint.y - (_moveInitPoint.y + cropRect.y);
				
				newRect = new Rectangle(cropRect.x+offx,cropRect.y + offy,cropRect.width,cropRect.height);
				cropRect = newRect;
				dispatchEvent(new CropSelectorEvent(CropSelectorEvent.MOVE_PROCCESS,false,false,_moveInitPoint,_moveEndPoint,newRect));
			}
		}
		
		
		
		private function onMouseUp(e:MouseEvent):void
		{
			
			if(_selecting)
			{
				if(cropRect.width && cropRect.height)
				{
					dispatchEvent(new CropSelectorEvent(CropSelectorEvent.SELECT_FINISH,false,false,_selectInitPoint,_selectEndPoint,cropRect));
				}
				else
				{
					dispatchEvent(new CropSelectorEvent(CropSelectorEvent.SELECT_CANCEL,false,false,_selectInitPoint,_selectEndPoint,cropRect));
				}
			}
			else if(_resizing)
			{
				if(cropRect.width && cropRect.height)
				{
					dispatchEvent(new CropSelectorEvent(CropSelectorEvent.RESIZE_FINISH,false,false,_resizeInitPoint,_resizeEndPoint,cropRect));
				}
				else
				{
					dispatchEvent(new CropSelectorEvent(CropSelectorEvent.RESIZE_CANCEL,false,false,_resizeInitPoint,_resizeEndPoint,cropRect));
				}
			}
			else if(_moving)
			{
				if(cropRect.width && cropRect.height)
				{
					dispatchEvent(new CropSelectorEvent(CropSelectorEvent.MOVE_FINISH,false,false,_moveInitPoint,_moveEndPoint,cropRect));
				}
				else
				{
					dispatchEvent(new CropSelectorEvent(CropSelectorEvent.MOVE_CANCEL,false,false,_moveInitPoint,_moveEndPoint,cropRect));
				}
			}
			
			
			
			_selecting = false;
			_moving = false;
			_resizing = false;
			invalidateSkinState();
			removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			removeEventListener(MouseEvent.MOUSE_MOVE,onMouseDownMove);
			//addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			//e.stopPropagation();
			addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		}
		
		private function onStageMouseUp(e:MouseEvent):void
		{
			onMouseUp(e);
		}
		
		private function onMouseOver(e:MouseEvent):void
		{
			if(_selecting || _resizing || _moving) return;
			addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			_solidLine.addEventListener(MouseEvent.ROLL_OVER,onSolidLineOver);
		}
		
		private function onMouseOut(e:MouseEvent):void
		{
			if(_selecting || _resizing || _moving) return;
			var mousePoint:Point = new Point(-1,-1);
			dispatchEvent(new CropSelectorEvent(CropSelectorEvent.MOUSE_LOCATION,false,false,mousePoint));
			removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		}
		
		private function onSolidLineOver(e:MouseEvent):void
		{
			if(_selecting || _resizing || _moving) return;
			removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			_solidLine.addEventListener(MouseEvent.ROLL_OUT,onSolidLineOut);
			_solidLine.addEventListener(MouseEvent.MOUSE_MOVE,onSolidLineMouseMove);
		}
		
		private function onSolidLineMouseMove(e:MouseEvent):void
		{
			if(_selecting || _resizing || _moving) return;
			var mousePoint:Point = new Point(-1,-1);
			dispatchEvent(new CropSelectorEvent(CropSelectorEvent.MOUSE_LOCATION,false,false,mousePoint));
		}
		
		private function onSolidLineOut(e:MouseEvent):void
		{
			if(_selecting || _resizing || _moving) return;
			addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			_solidLine.removeEventListener(MouseEvent.MOUSE_MOVE,onSolidLineMouseMove);
		}
		
		
		
		private function onMouseMove(e:MouseEvent):void
		{
			if(_selecting || _resizing || _moving) return;
			var mousePoint:Point = new Point();
			mousePoint.x = this.mouseX;
			mousePoint.y = this.mouseY;
			dispatchEvent(new CropSelectorEvent(CropSelectorEvent.MOUSE_LOCATION,false,false,mousePoint));
		}
		
		private function onHandleOver(e:MouseEvent):void
		{
			if(_selecting || _resizing || _moving) return;
			var mousePoint:Point = new Point(cropRect.x,cropRect.y);
			dispatchEvent(new CropSelectorEvent(CropSelectorEvent.MOUSE_LOCATION,false,false,mousePoint));
			removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		}
		
		private function onHandleOut(e:MouseEvent):void
		{
			if(_selecting || _resizing || _moving) return;
			addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
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
		 * 计算8个端点
		 * 
		 * **/
		private function calcRectPoints():Array{
			
			var rectPoints:Array = new Array();
			
			rectPoints.push(new Point(cropRect.x,cropRect.y));
			rectPoints.push(new Point(Math.round(cropRect.x+cropRect.width/2),cropRect.y));
			rectPoints.push(new Point(cropRect.x+cropRect.width,cropRect.y));
			
			rectPoints.push(new Point(cropRect.x,cropRect.y+Math.round(cropRect.height/2)));
			rectPoints.push(new Point(cropRect.x+cropRect.width,cropRect.y+Math.round(cropRect.height/2)));
			
			rectPoints.push(new Point(cropRect.x,cropRect.y+cropRect.height));
			rectPoints.push(new Point(cropRect.x+Math.round(cropRect.width/2),cropRect.y+cropRect.height));
			rectPoints.push(new Point(cropRect.x+cropRect.width,cropRect.y+cropRect.height));
			
			return rectPoints;
			
		}

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
			
			if(_selecting)
			{
				if((refPoint.x>_selectInitPoint.x && refPoint.y>_selectInitPoint.y) || (refPoint.x<_selectInitPoint.x && refPoint.y<_selectInitPoint.y)){
					
					a = 1/ratio;
					c = -1/a;
					
				}else{
					
					a = -1/ratio;
					c = -1/a;
					
				}
				
				b = _selectInitPoint.y - a*_selectInitPoint.x;
				d = refPoint.y - c*refPoint.x;
				
				if(ratio){
					
					if(mode == mode1)
					{
						crossPoint = new Point((d-b)/(a-c),(a*(d-b)/(a-c))+b);
						restrainRect = restrainRect;
					}
					else if(mode == mode2)
					{
						if(Math.abs((refPoint.x - _resizeInitPoint.x)/(refPoint.y - _resizeInitPoint.y))>ratio){
							
							crossPoint = new Point(Math.round((refPoint.y-b)/a),refPoint.y);
							
						}else{
							
							crossPoint = new Point(refPoint.x,Math.round(a*refPoint.x+b));
							
						}
					}
			
				}else{
					
					crossPoint = refPoint;
					restrainRect = restrainRect;
				}
			}
			else if(_resizing)
			{
				switch (_activatedBtn){
					
					case _tlBtn:
					case _brBtn:	
					case _trBtn:
					case _blBtn:
						
						if((refPoint.x>_resizeInitPoint.x && refPoint.y>_resizeInitPoint.y) || (refPoint.x<_resizeInitPoint.x && refPoint.y<_resizeInitPoint.y)){
							
							a = 1/ratio;
							c = -1/a;
							
						}else{
							
							a = -1/ratio;
							c = -1/a;
							
						}
						
						b = _resizeInitPoint.y - a*_resizeInitPoint.x;
						d = refPoint.y - c*refPoint.x;
						
						if(ratio){
							
							if(mode == mode1)
							{
								crossPoint = new Point((d-b)/(a-c),(a*(d-b)/(a-c))+b);
								restrainRect = restrainRect;
							}
							else if(mode == mode2)
							{
								if(Math.abs((refPoint.x - _resizeInitPoint.x)/(refPoint.y - _resizeInitPoint.y))>ratio){
									
									crossPoint = new Point(Math.round((refPoint.y-b)/a),refPoint.y);
									
								}else{
									
									crossPoint = new Point(refPoint.x,Math.round(a*refPoint.x+b));
									
								}
							}

						}else{
							
							crossPoint = refPoint;
							restrainRect = restrainRect;
							
							
						}
						
						break;
					
					case _tmBtn:
					case _bmBtn:	
						
						a = 2/ratio;
						b = _resizeInitPoint.y - a*_resizeInitPoint.x;
						
						crossPoint = new Point(_rectPoints[1].x,refPoint.y);
						restrainRect = recalcRestrainRect(restrainRect,_resizeInitPoint,"vertical");
						break;
					
					case _mlBtn:
					case _mrBtn:	
						
						a = 1/(ratio*2);
						b = _resizeInitPoint.y - a*_resizeInitPoint.x;
						
						crossPoint = new Point(refPoint.x,_rectPoints[3].y);
						restrainRect = recalcRestrainRect(restrainRect,_resizeInitPoint,"horizontal");
						
						break;
				}
			
			}
			
			if(ratio){
				
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
		 * 约束点
		 * @param targetPoint 约束的对象
		 * @param rulePoints 约束参照点
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
		
		/**
		 * 约束拖放移动时的目标点
		 * **/
		
		private function restrainEndPoint(point:Point):Point
		{
			if(_moveInitPoint.x>=0)
			{
				if(point.x<_moveInitPoint.x + restrainRect.x) point.x = _moveInitPoint.x + restrainRect.x;
				if(point.x>restrainRect.width + restrainRect.x -(cropRect.width-_moveInitPoint.x)) point.x = restrainRect.width + restrainRect.x -(cropRect.width-_moveInitPoint.x);
			}
			else
			{
				if(point.x<(_moveInitPoint.x-cropRect.width + restrainRect.x)) point.x = _moveInitPoint.x-cropRect.width + restrainRect.x;
				if(point.x>(restrainRect.width + _moveInitPoint.x + restrainRect.x)) point.x = (restrainRect.width + _moveInitPoint.x + restrainRect.x)
			}
			
			if(_moveInitPoint.y>=0)
			{
				if(point.y<_moveInitPoint.y + restrainRect.y) point.y = _moveInitPoint.y + restrainRect.y;
				if(point.y>restrainRect.height + restrainRect.y -(cropRect.height-_moveInitPoint.y)) point.y = restrainRect.height + restrainRect.y -(cropRect.height-_moveInitPoint.y);
			}
			else
			{
				if(point.y<(_moveInitPoint.y-cropRect.height)) point.y = _moveInitPoint.y-cropRect.height;
				if(point.y>(restrainRect.height + _moveInitPoint.y + restrainRect.y)) point.y = (restrainRect.height + _moveInitPoint.y + restrainRect.y)
			}
			return point;
		}
		
		/**
		 * 
		 * 根据两个点构造Rectangle对象
		 * 
		 * **/
		private function calcRectFromPoints(initPoint:Point,endPoint:Point):Rectangle{
			

			var x:Number;
			var y:Number;
			var w:Number;
			var h:Number;

			if(_selecting)
			{
				x = Math.min(initPoint.x,endPoint.x);
				y = Math.min(initPoint.y,endPoint.y);
				w = Math.abs(endPoint.x - initPoint.x);
				h = Math.abs(endPoint.y - initPoint.y);
			}
			else if(_resizing)
			{
				switch(_activatedBtn){
					
					case _tlBtn:
					case _brBtn:	
					case _trBtn:
					case _blBtn:
						
						x = Math.min(initPoint.x,endPoint.x);
						y = Math.min(initPoint.y,endPoint.y);
						w = Math.abs(endPoint.x - initPoint.x);
						h = Math.abs(endPoint.y - initPoint.y);
						break;
					
					case _tmBtn:
					case _bmBtn:
						
						h = Math.abs(endPoint.y - initPoint.y);
						y = Math.min(initPoint.y,endPoint.y);
						
						if(ratio){
							
							w = Math.abs(Math.round(h*ratio));
							x = initPoint.x - Math.round(w/2);
							
						}else{
							
							w = cropRect.width;
							x = cropRect.x;
							
						}
						break;
					
					case _mlBtn:
					case _mrBtn:
						w = Math.abs(endPoint.x - initPoint.x);
						x = Math.min(initPoint.x,endPoint.x);
						
						if(ratio){
							
							h = Math.abs(Math.round(w/ratio));
							y = initPoint.y - Math.round(h/2);
							
						}else{
							
							h = cropRect.height;
							y = cropRect.y;	
						}
						break;
					
				}
			}

			return new Rectangle(x,y,w,h);
			
		}
		
		private static function classConstruct():Boolean
		{
			var globalApp:UIComponent = FlexGlobals.topLevelApplication as UIComponent;
			var style:CSSStyleDeclaration = globalApp.styleManager.getStyleDeclaration("sxf.utils.selector.cropselector.CropSelector");
			
			if(!style)
			{
				style = new CSSStyleDeclaration();
				style.defaultFactory = function():void
				{
					this.restrainRect = defaultRestrainRect;
					this.ratio = defaultRatio;
				}
				globalApp.styleManager.setStyleDeclaration("sxf.utils.selector.cropselector.CropSelector",style,true);
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