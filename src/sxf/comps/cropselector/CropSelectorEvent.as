package sxf.comps.cropselector{
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class CropSelectorEvent extends Event{
		

		public static const LOCATING:String = "LOCATING";
		public static const DRAW_BEGIN:String = "DRAW_BEGIN";
		public static const DRAW_CANCEL:String = "DRAW_CANCEL";
		public static const DRAWING:String = "DRAWING";
		public static const DRAW_FINISH:String = "DRAW_FINISH";
		public static const RESIZE:String = "RESIZE";
		public static const MOVE:String = "MOVE";
		
		
		
		private var _locatePoint:Point;
		private var _initPoint:Point;
		private var _endPoint:Point;
		private var _rect:Rectangle;
		
		public function CropSelectorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,locatePoint:Point=null,initPoint:Point=null,endPoint:Point=null,rect:Rectangle=null){

			super(type, bubbles, cancelable);
			
			this._locatePoint = locatePoint;
			this._initPoint = initPoint;
			this._endPoint = endPoint;
			this._rect = rect;

		}
		public function get rect():Rectangle{
		
			return _rect;
		
		}
		
		public function get locatePoint():Point{
		
			return _locatePoint;
		
		}
		public function get initPoint():Point{
			
			return _initPoint;
			
		}
		public function get endPoint():Point{
			
			return _endPoint;
			
		}
		
		
		override public function clone():Event{
		
			return new CropSelectorEvent(type, bubbles, cancelable,locatePoint,initPoint,endPoint, rect);
		}
	}
}