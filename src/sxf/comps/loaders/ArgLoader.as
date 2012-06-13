package sxf.comps.loaders{
	
	import flash.display.Loader;
	
	public class ArgLoader extends Loader{
		
		private var _index:int;

		public function ArgLoader(index:int=NaN){
			
			super();
			
			this._index = index;
		}
		
		public function get index():int{
			
			return _index;
		}

		private function set index(value:int):void{
			
			_index = value;
		}
		
	}
}