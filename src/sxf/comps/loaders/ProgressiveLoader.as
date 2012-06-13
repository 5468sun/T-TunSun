package sxf.comps.loaders
{
	import flash.display.LoaderInfo;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.system.LoaderContext;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	/**
	 * 渐进式加载类
	 * 用法跟Loader一样,
	 * <p><b>不同点:</b></p>
	 * 1.当加载流错误时只能获取到 "Error #2124: 加载的文件为未知类型。" <br/>
	 * 2.侦听contentLoaderInfo的Progress事件的bytesLoaded,bytesTotal是整个文件的已加载字节和总字节.<br/>
	 * 3.contentLoaderInfo.bytesLoaded, contentLoaderInfo.bytesTotal指当前loader里的字节数和总字节
	 * 
	 * @author lite3
	 */
	public class ProgressiveLoader extends Loader
	{
		private var bytesLoaded:uint = 0;            // 已加载的字节数
		private var bytesToal:uint = 0;             // 总字节数
		
		private var dataChange:Boolean = false;        // buffer的数据是否改变    
		private var streamComplete:Boolean = false;    // 文件是否加载完成
		
		private var context:LoaderContext;            // 
		
		private var buffer:ByteArray;                // 数据缓存
		private var stream:URLStream;                // 流
		
		/**
		 * 关闭流,并清理所有侦听器
		 */
		override public function close():void 
		{
			// 清除流相关
			if (stream)
			{
				if (stream.connected) stream.close();
				streamRemoveEvent(stream);
			}
			// 清除conentLoaderInfo相关的事件
			if (contentLoaderInfo.hasEventListener(Event.COMPLETE))
			{
				loaderInfoRemoveEvent(super.contentLoaderInfo);
			}
			// 清除显示数据事件
			if (hasEventListener(Event.ENTER_FRAME))
			{
				removeEventListener(Event.ENTER_FRAME, showData);
			}
			buffer = null;
		}
		/**
		 * 加载字节数据,不会在内部触发contentLoaderInfo相关事件
		 * @param    bytes
		 * @param    context
		 */
		override public function loadBytes(bytes:ByteArray, context:LoaderContext = null):void
		{
			close();
			super.unload();
			super.loadBytes(bytes, context);
		}
		
		/**
		 * 加载一个url文件,并渐进显示(如果是渐进格式)
		 * @param    request
		 * @param    context
		 */
		override public function load(request:URLRequest, context:LoaderContext = null):void 
		{
			streamComplete = false;
			if (!stream) stream = new URLStream();
			if (stream.connected) stream.close();
			this.context = context;
			dataChange = false;
			
			buffer = new ByteArray();
			super.unload();
			addEventListener(Event.ENTER_FRAME, showData);
			loaderInfoAddEvent(super.contentLoaderInfo);
			streamAddEvent(stream);
			stream.load(request);
		}
		
		// 将缓存中的数据显示为图像
		private function showData(e:Event = null):void 
		{
			if (!dataChange || !stream.connected) return;
			
			dataChange = false;
			if (stream.bytesAvailable > 0)
			{
				stream.readBytes(buffer, buffer.length, stream.bytesAvailable);
			}
			if (buffer.length > 0)
			{
				super.unload();
				super.loadBytes(buffer, context);
			}
			
			// 加载完成
			if (streamComplete)
			{
				close();
				streamComplete  = false;
			}
		}
		// 修正contentLoaderInfo的ProgressEvent.PROGRESS事件的进度值
		private function loaderProgressHandler(e:ProgressEvent):void 
		{
			e.bytesLoaded = bytesLoaded;
			e.bytesTotal = bytesToal;
		}
		
		// 显示完成
		private function loaderCompleteHandler(e:Event):void 
		{
			if (streamComplete)
			{
				streamComplete = false;
				loaderInfoRemoveEvent(super.contentLoaderInfo);
			}else
			{
				e.stopImmediatePropagation();
			}
		}
		
		// 数据加载完成
		private function streamCompleteHandler(e:Event):void 
		{
			streamRemoveEvent(stream);
			// 这里不删除EnterFrame事件,最后一段总是不会显示,
			// 并且complete事件里showData也不行,
			// 所以最后延时显示一次,
			streamComplete = true;
			dataChange = true;
		}
		// 数据加载中,保存数据加载的值
		private function streamProgressHandler(e:ProgressEvent):void 
		{
			bytesLoaded = e.bytesLoaded;
			bytesToal = e.bytesTotal;
			dataChange = true;
		}
		// 数据流错误, 但是也会加载400K左右的数据,
		// 然后由contentLoaderInfo抛出IOError或者IOErrorEvent
		// 但不会是流错误,而是未知文件类型
		private function streamErrorHandler(e:IOError):void 
		{
			close();
		}
		
		private function streamAddEvent(stream:URLStream):void
		{
			stream.addEventListener(Event.COMPLETE, streamCompleteHandler);
			stream.addEventListener(ProgressEvent.PROGRESS, streamProgressHandler);
			stream.addEventListener(IOErrorEvent.IO_ERROR, streamErrorHandler);
		}
		
		private function streamRemoveEvent(stream:URLStream):void
		{
			stream.removeEventListener(Event.COMPLETE, streamCompleteHandler);
			stream.removeEventListener(ProgressEvent.PROGRESS, streamProgressHandler);
			stream.removeEventListener(IOErrorEvent.IO_ERROR, streamErrorHandler);
		}
		
		private function loaderInfoAddEvent(loaderInfo:LoaderInfo):void
		{
			loaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler, false, int.MAX_VALUE);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, loaderProgressHandler, false, int.MAX_VALUE);
		}
		
		private function loaderInfoRemoveEvent(loaderInfo:LoaderInfo):void
		{
			loaderInfo.removeEventListener(Event.COMPLETE, loaderCompleteHandler);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, loaderProgressHandler);
		}
	}
}