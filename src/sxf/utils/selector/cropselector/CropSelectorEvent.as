package sxf.utils.selector.cropselector
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	public class CropSelectorEvent extends Event{
		
		public static const SELECT_BEGIN:String = "selectBegin";
		public static const SELECT_PROCCESS:String = "selectProgress";
		public static const SELECT_FINISH:String = "selectFinish";
		public static const SELECT_CANCEL:String = "selectCancel";
		
		public static const RESIZE_BEGIN:String = "resizeBegin";
		public static const RESIZE_PROCCESS:String = "resizeProgress";
		public static const RESIZE_FINISH:String = "resizeFinish";
		public static const RESIZE_CANCEL:String = "resizeCancel";
		
		public static const MOVE_BEGIN:String = "moveBegin";
		public static const MOVE_PROCCESS:String = "moveProgress";
		public static const MOVE_FINISH:String = "moveFinish";
		public static const MOVE_CANCEL:String = "moveCancel";
		
		public static const MOUSE_LOCATION:String = "mouseLocation";
		
		private var _initPoint:Point;
		private var _endPoint:Point;
		private var _rect:Rectangle;
		
		public function CropSelectorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,initPoint:Point=null,endPoint:Point=null,rect:Rectangle=null){
			
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
			return new CropSelectorEvent(type,bubbles,cancelable,initPoint,endPoint,rect);
		}
	}
}