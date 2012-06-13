package sxf.comps.localfileloader{
	
	import flash.events.Event;
	import flash.net.FileReference;
	
	public class LocalFileLoaderEvent extends Event{
		
		public static const FILE_LOAD_BEGIN:String = "fileLoadBegin";
		public static const FILE_LOADING:String = "fileLoading";
		public static const FILE_LOAD_COMPLETE:String = "fileLoadComplete";
		public static const FILE_LOAD_ERROR:String = "fileLoadError";
		
		//private var _fileList:Array;
		private var _index:int;
		private var _percent:Number;
		private var _fileRef:FileReference;
		
		public function LocalFileLoaderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,index:int=NaN,percent:Number=NaN,fileRef:FileReference=null){
			
			super(type, bubbles, cancelable);
			//_fileList = fileList;
			_index = index;
			_percent = percent;
			_fileRef = fileRef;
			
		}
		
		/*public function get fileList():Array{
		
			return this._fileList;
		
		}*/
		
		public function get index():int{
		
			return this._index;
			
		}
		
		public function get percent():Number{
		
			return this._percent;
			
		}
		
		public function get fileRef():FileReference{
			
			return this._fileRef;
			
		}
		
		override public function clone():Event{
		
			return new LocalFileLoaderEvent(type,bubbles,cancelable,index,percent,fileRef);
		
		}
	}
}