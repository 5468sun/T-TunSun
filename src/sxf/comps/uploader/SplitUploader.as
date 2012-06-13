package sxf.comps.uploader{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	public class SplitUploader extends EventDispatcher{
		
		private static var timeout:Number = 30*1000;
		private var timeoutTimer:Timer;
		private var urlLoader:URLLoader;
		private var urlRequest:URLRequest;
		private var _fileData:ByteArray;
		private var _fileName:String;
		private var _phpUrl:String;
		private var _uniqueId:Number;
		private var _partIndex:int;
		private var _partSize:Number;
		private var _partNum:int;
		
		public function SplitUploader(){
			
			super();
		}
		
		public function upload(fileData:ByteArray,fileName:String,uniqueID:Number,phpUrl:String,partNum:int=NaN,partSize:Number=NaN):void{
		
			_fileData = fileData;
			if(partNum && !partSize){
			
				_partNum = partNum;
				_partSize = _fileData.length/_partNum;
				
			}else if(!partNum && partSize){
			
				_partSize = partSize*1024;
				_partNum = Math.ceil(_fileData.length/_partSize);
			
			}else{
			
				throw Error("please set either partNum or partSize, not both.");
			
			}
			
			_partIndex = 0;
			_uniqueId = uniqueID;
			_fileName = fileName;
			_phpUrl = phpUrl;
			
			urlLoader = new URLLoader();
			urlRequest = new URLRequest();
			timeoutTimer = new Timer(timeout,1);
			
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.contentType = "application/octet-stream";
			
			urlLoader.addEventListener(Event.OPEN,onUploadOpen);
			urlLoader.addEventListener(Event.COMPLETE,onUploadComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onUploadIOError);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onUploadSecurityError);
			
			timeoutTimer.addEventListener(TimerEvent.TIMER,onTimeoutTimer);
			
			uploadPart(_partIndex);

			dispatchEvent(new SplitUploaderEvent(SplitUploaderEvent.BEGIN,false,false,0.01));
		}
		
		
		private function uploadPart(partIndex:int):void{
			
			_partIndex = partIndex;
			
			var url:String = _phpUrl + "?name=" + _fileName + "&id=" + _uniqueId + "&last=" + (_partIndex == _partNum);
			
			urlRequest.url = url;
			trace(urlRequest.url);
			var bytes:ByteArray = new ByteArray();
			
			var readSize:Number = (_partSize + _partSize * _partIndex)<_fileData.length?_partSize:_fileData.length-_partSize * _partIndex;
			bytes.writeBytes(_fileData, _partSize * _partIndex, readSize);
			urlRequest.data = bytes;
			
			urlLoader.load(urlRequest);
		
		}
		
		public function closeCurrentUpload():void{

			urlLoader.close();
			timeoutTimer.stop();
			sendDelRequest();
			
		}
		
		private function cleanUploader():void{
		
			_fileData = null;
			_fileName = null;
			_phpUrl = null;
			_uniqueId = NaN;
			_partIndex = NaN;
			_partSize = NaN;
			_partNum = NaN;
			urlRequest = null;
			
			urlLoader.removeEventListener(Event.OPEN,onUploadOpen);
			urlLoader.removeEventListener(Event.COMPLETE,onUploadComplete);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,onUploadIOError);
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onUploadSecurityError);
			urlLoader = null;
			
			timeoutTimer.removeEventListener(TimerEvent.TIMER,onTimeoutTimer);
			timeoutTimer = null;

		}
		

		private function onUploadOpen(e:Event):void{
			
			trace("onUploadOpen");
			timeoutTimer.start();
		}
		
		private function onUploadComplete(e:Event):void{
		
			trace("onPart "+_partIndex+"UploadComplete");
			var percent:Number = (_partIndex+1)/_partNum;
			timeoutTimer.stop();
			dispatchEvent(new SplitUploaderEvent(SplitUploaderEvent.PROGRESS,false,false,percent));
			
			if(_partIndex+1<_partNum){
				_partIndex += 1;
				uploadPart(_partIndex);
			
			}else{
				
				cleanUploader();
				dispatchEvent(new SplitUploaderEvent(SplitUploaderEvent.COMPLETE,false,false,percent));
				trace("onAllUploadComplete");
				
			}
		
		}
		
		private function onUploadIOError(e:IOErrorEvent):void{
		
			trace("onUploadIOError");
			sendDelRequest();
			cleanUploader();
			dispatchEvent(new SplitUploaderEvent(SplitUploaderEvent.IO_ERROR));
		}
		
		private function onUploadSecurityError(e:SecurityErrorEvent):void{
		
			trace("onUploadSecurityError");
			sendDelRequest();
			cleanUploader();
			dispatchEvent(new SplitUploaderEvent(SplitUploaderEvent.SECURITY_ERROR));
		
		}
		
		private function onTimeoutTimer(e:TimerEvent):void{
		
			trace("onTimer");
			urlLoader.close();
			sendDelRequest();
			cleanUploader();
			dispatchEvent(new SplitUploaderEvent(SplitUploaderEvent.TIMEOUT));
			
			
			
		
		}

		private function sendDelRequest():void{
		
			var delLoader:URLLoader = new URLLoader();
			delLoader.addEventListener(Event.OPEN,onDeleteBegin);
			delLoader.addEventListener(Event.COMPLETE,onDeleteComplete);
			delLoader.addEventListener(IOErrorEvent.IO_ERROR,onDeleteIOError);
			var delRequest:URLRequest = new URLRequest();
			delRequest.url = _phpUrl + "?name=" + _fileName + "&id=" + _uniqueId + "&timeout=true";
			delRequest.method = URLRequestMethod.GET;
			var timer:Timer = new Timer(1000,1);
			timer.addEventListener(TimerEvent.TIMER,function(e:TimerEvent):void{delLoader.load(delRequest)});
			timer.start();
			trace(delRequest.url);
		}
		
		private function onDeleteBegin(e:Event):void{
			
			trace("onDeleteBegin");
			
		}
		
		private function onDeleteComplete(e:Event):void{
			
			trace("onDeleteComplete");
			
		}
		private function onDeleteIOError(e:Event):void{
			
			trace("onDeleteIOError");			
			
		}
	}
}