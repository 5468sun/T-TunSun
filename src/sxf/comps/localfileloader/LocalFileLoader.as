package sxf.comps.localfileloader{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	
	public class LocalFileLoader extends EventDispatcher{
		
		private static var instance:LocalFileLoader;
		
		private var upFileList:ArrayList;

		public function LocalFileLoader(forceSingle:ForceSingle){
		
			clear();
		
		}
		
		public static function getInstance():LocalFileLoader{
		
			if(instance == null){
			
				instance = new LocalFileLoader(new ForceSingle());
			
			}
			
			return instance as LocalFileLoader;
		
		}
		
		
		
		public function clear():void{
		
			this.upFileList = new ArrayList();

		}
		
		
		
		public function loadFiles(fileList:ArrayList):void{
			
			if(fileList.length == 0) return;
			
			var fileRef:FileReference;
			for(var i:int=0; i<fileList.length; i++){
			
				fileRef = FileReference(fileList.getItemAt(i).file);
				fileRef.addEventListener(Event.OPEN,onFileLoadBegin);
				fileRef.addEventListener(ProgressEvent.PROGRESS,onFileLoadProgress);
				fileRef.addEventListener(Event.COMPLETE,onFileLoadComplete);
				fileRef.addEventListener(IOErrorEvent.IO_ERROR,onFileLoadError);
				
				this.upFileList.addItem(fileRef);
				fileRef.load();
			
			}
		
		}
		
		public function reloadFileAt(index:int):void{
		
			var fileRef:FileReference = upFileList.getItemAt(index) as FileReference;

			fileRef.load();
		
		}
		
		public function removeItemAt(index:int):void{
		
			var fileRef:FileReference = upFileList.getItemAt(index) as FileReference;
			fileRef.removeEventListener(Event.OPEN,onFileLoadBegin);
			fileRef.removeEventListener(ProgressEvent.PROGRESS,onFileLoadProgress);
			fileRef.removeEventListener(Event.COMPLETE,onFileLoadComplete);
			fileRef.removeEventListener(IOErrorEvent.IO_ERROR,onFileLoadError);
			upFileList.removeItemAt(index);
		
		}
		
		private function loadFileQueue():void{}
		
		////////////////////
		// event handlers
		//////////////////////
		
		private function onFileLoadBegin(e:Event):void{
		
			trace("onFileLoadBegin");
			var fileRef:FileReference = FileReference(e.target);
			var index:int = upFileList.getItemIndex(fileRef);
			dispatchEvent(new LocalFileLoaderEvent(LocalFileLoaderEvent.FILE_LOAD_BEGIN,false,false,index,0));
			
		}
		
		
		private function onFileLoadProgress(e:ProgressEvent):void{
		
			trace("onFileLoadProgress");
			var fileRef:FileReference = FileReference(e.target);
			var index:int = upFileList.getItemIndex(fileRef);
			trace(e.bytesTotal +"+++++"+ e.bytesLoaded);
			var percent:Number =  e.bytesLoaded/e.bytesTotal;

			dispatchEvent(new LocalFileLoaderEvent(LocalFileLoaderEvent.FILE_LOADING,false,false,index,percent));
		
		}
		
		private function onFileLoadComplete(e:Event):void{
		
			trace("onFileLoadComplete");
			var fileRef:FileReference = FileReference(e.target);
			var index:int = upFileList.getItemIndex(fileRef);

			dispatchEvent(new LocalFileLoaderEvent(LocalFileLoaderEvent.FILE_LOAD_COMPLETE,false,false,index,1,fileRef));
			
			/*fileRef.removeEventListener(Event.OPEN,onFileLoadBegin);
			fileRef.removeEventListener(ProgressEvent.PROGRESS,onFileLoadProgress);
			fileRef.removeEventListener(Event.COMPLETE,onFileLoadComplete);
			fileRef.removeEventListener(IOErrorEvent.IO_ERROR,onFileLoadError);*/
			
		}
		
		private function onFileLoadError(e:IOErrorEvent):void{
		
			trace("onFileLoadError");
			var fileRef:FileReference = FileReference(e.target);
			var index:int = upFileList.getItemIndex(fileRef);

			dispatchEvent(new LocalFileLoaderEvent(LocalFileLoaderEvent.FILE_LOAD_ERROR,false,false,index,0));
			
			
		
		}
	}
}

class ForceSingle{}