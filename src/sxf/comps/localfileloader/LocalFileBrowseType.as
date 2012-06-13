package sxf.comps.localfileloader{
	import flash.net.FileFilter;
	
	public class LocalFileBrowseType extends Object{
		
		public static const IMAGE:String = "fileTypeImage";
		public static const DOCUMENT:String = "fileTypeDocument";
		public static const COMPRESS_FILE:String = "fileTypeCompressFile";
		
		public function LocalFileBrowseType(){}
		
		public static function getType(type:String):Array{
			
			var fileFilter:FileFilter;
			
			switch (type){
			
				case IMAGE:
					
					fileFilter = new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg;*.jpeg;*.gif;*.png");
					break;
				
				case DOCUMENT:
					fileFilter = new FileFilter("Documents (*.pdf, *.txt, *.doc)", "*.pdf;*.txt;*.doc");
					break;
				
				case COMPRESS_FILE:
					fileFilter = new FileFilter("Compressed Files (*.rar, *.zip, *.iso)", "*.rar;*.zip;*.iso");
					break;
			
			}
			
			return [fileFilter];
		
		}
	}
}