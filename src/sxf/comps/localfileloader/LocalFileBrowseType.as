package sxf.comps.localfileloader{
	import flash.net.FileFilter;
	
	public class LocalFileBrowseType extends Object{
		
		public static const IMAGE:Array = [new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg;*.jpeg;*.gif;*.png")];
		public static const DOCUMENT:Array = [new FileFilter("Documents (*.pdf, *.txt, *.doc)", "*.pdf;*.txt;*.doc")];
		public static const COMPRESS_FILE:Array = [new FileFilter("Compressed Files (*.rar, *.zip, *.iso)", "*.rar;*.zip;*.iso")];
		
		public function LocalFileBrowseType(){}

	}
}