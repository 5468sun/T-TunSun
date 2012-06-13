package sxf.comps.uploader{
	
	import flash.events.Event;
	
	public class SplitUploaderEvent extends Event{
		
		public static const BEGIN:String = "uploadBegin";
		public static const PROGRESS:String = "uploadProgress";
		public static const COMPLETE:String = "uploadComplete";
		public static const IO_ERROR:String = "uploadIOError";
		public static const SECURITY_ERROR:String = "uploadSecurityError";
		public static const TIMEOUT:String = "timeout";
		
		private var _percent:Number;
		
		public function SplitUploaderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, percent:Number=NaN){
			
			super(type, bubbles, cancelable);
			this._percent = percent;
		}
		
		public function get percent():Number{
		
			return this._percent;
		
		}
		
		override public function clone():Event{
		
			return new SplitUploaderEvent(type,bubbles,cancelable,percent);
		
		}
	}
}