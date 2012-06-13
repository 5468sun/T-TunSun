package sxf.comps.localfileloader{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileReferenceList;
	
	public class LocalFileBrowser extends EventDispatcher{
		
		private var fileRefList:FileReferenceList;
		
		private static var instance:LocalFileBrowser;
		
		public function LocalFileBrowser(forceSingle:ForceSingle){
			
			super();
		}
		
		public static function getInstance():LocalFileBrowser{
		
			if(instance == null){
				instance = new LocalFileBrowser(new ForceSingle());
			}
			
			return instance;
		
		}
		
		public function browseFile(fileType:Array):void{
			
			trace("browseFile");
			fileRefList = new FileReferenceList();
			
			fileRefList.addEventListener(Event.SELECT,onFileSelected);
			fileRefList.addEventListener(Event.CANCEL,onBrowseCancel);
			fileRefList.browse(fileType);
			
		}
		
		////////////////////
		// event handlers
		//////////////////////
		private function onFileSelected(e:Event):void{
			
			trace("onFileSelected");
			var fileList:Array = FileReferenceList(e.target).fileList;
			dispatchEvent(new LocalFileBrowseEvent(LocalFileBrowseEvent.BROWSE_SELECT,false,false,fileList));
			
		}
		
		private function onBrowseCancel(e:Event):void{
			
			trace("onBrowseCancel");
			dispatchEvent(new LocalFileBrowseEvent(LocalFileBrowseEvent.BROWSE_CANCEL,false,false));
		}
		
	}
}

class ForceSingle{}