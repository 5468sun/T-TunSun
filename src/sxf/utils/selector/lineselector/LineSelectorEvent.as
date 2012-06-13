package sxf.utils.selector.lineselector
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import spark.primitives.Rect;
	
	public class LineSelectorEvent extends Event{
		
		public static const BEGIN:String = "SelectBegin";
		public static const PROCCESS:String = "SelectProgress";
		public static const FINISH:String = "SelectFinish";
		public static const CANCEL:String = "SelectCancel";
		
		
		private var _initPoint:Point;
		private var _endPoint:Point;
		private var _rect:Rectangle;
		
		public function LineSelectorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,initPoint:Point=null,endPoint:Point=null,rect:Rectangle=null){
			
			super(type, bubbles, cancelable);
			this._initPoint = initPoint;
			this._endPoint = endPoint;
			this._rect = rect;
		}
		
		public function get initPoint():Point{
		
			return _initPoint;
			
		}
		public function get endPoint():Point{
		
			return _endPoint;
		
		}
		public function get rect():Rectangle{
		
			return _rect;
		
		}
		
		override public function clone():Event{
			return new LineSelectorEvent(type,bubbles,cancelable,initPoint,endPoint,rect);
		}
	}
}