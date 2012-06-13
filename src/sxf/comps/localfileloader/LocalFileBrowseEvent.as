package sxf.comps.localfileloader{
	
	import flash.events.Event;
	
	public class LocalFileBrowseEvent extends Event{
		
		public static const BROWSE_SELECT:String = "browseSelect";
		public static const BROWSE_CANCEL:String = "browseCancel";
		
		private var _fileList:Array;

		public function LocalFileBrowseEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,fileList:Array=null){
			
			super(type, bubbles, cancelable);
			this._fileList = fileList;
		}
		
		public function get fileList():Array{
			
			return _fileList;
		}
		
		override public function clone():Event{
		
			return new LocalFileBrowseEvent(type,bubbles,cancelable,fileList);
		}
	}
}