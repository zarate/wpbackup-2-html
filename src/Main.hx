package;

import Arguments.Argument;

class Main
{	
	var wpBackupFilePath : String;
	
	var outputFolderPath : String;
	
	var posts : Array<Post>;
	
	static var DEFAULT_OUTPUT_FOLDER_PATH : String = "output";
	
	function new()
	{
		
		log("Welcome to the Wordpress to HTML recovery tool");
		log("We'll do our best");
		
		parseArguments();
		
		parseBackupFile();
		
		outputStaticHTMLPages();
	}
	
	function parseArguments() : Void
	{
		var args = xa.Application.getArguments();
		
		for(i in 0...args.length)
		{
			switch(Arguments.create(args[i]))
			{
				case Argument.WP_BACKUP_FILE_PATH:
					wpBackupFilePath = args[i+1];
					
				case Argument.OUTPUT_FOLDER_PATH:
					outputFolderPath = args[i+1];
				
			}
		}
		
		if(null == wpBackupFilePath)
		{
			exit("Empty path to the WP backup file");
		}
		
		if(null == outputFolderPath)
		{
			log("Going to use default output folder path: " + DEFAULT_OUTPUT_FOLDER_PATH);
			
			outputFolderPath = DEFAULT_OUTPUT_FOLDER_PATH;
		}
	}
	
	function parseBackupFile() : Void
	{
		if(!xa.File.isFile(wpBackupFilePath))
		{
			exit(wpBackupFilePath + " is not a valid file");
		}
		
		posts = Parser.parse(xa.File.read(wpBackupFilePath));
		
		log("Found " + posts.length + " posts");
	}
	
	function outputStaticHTMLPages() : Void
	{
		if(xa.Folder.isFolder(outputFolderPath))
		{
			log("Removing old output folder");
			xa.Folder.forceDelete(outputFolderPath);
		}
		
		xa.Folder.create(outputFolderPath);
		
		for(post in posts)
		{
			var postFolder = createDateFolder(post);
			
			var postContent = post.content;
			
			xa.File.write(postFolder + xa.System.UNIX_SEPARATOR + "index.htm", postContent);
		}
	}
	
	function createDateFolder(post : Post) : String
	{
		// Date.getMenth() is 0-based, we need to add 1 for a human readable version
		var bits = [post.date.getFullYear(), post.date.getMonth() + 1, post.date.getDate()];
		
		// start with the root of the output folder
		var fullFolderPath = outputFolderPath;
		
		// then we create the YYYY-MM-DD folder structure if needed
		for(bit in bits)
		{
			fullFolderPath += xa.System.UNIX_SEPARATOR + StringTools.lpad(Std.string(bit), "0", 2);
			
			if(!xa.Folder.isFolder(fullFolderPath))
			{
				xa.Folder.create(fullFolderPath);
			}
		}
		
		// finally, we add the post's "name", which is WP's
		// way of calling the web safe title
		fullFolderPath += xa.System.UNIX_SEPARATOR + post.name;
		
		xa.Folder.create(fullFolderPath);
		
		return fullFolderPath;
	}
	
	function exit(?txt : String) : Void
	{
		if(null != txt)
		{
			log(txt);
		}
		
		xa.Application.exit(1);
	}
	
	function log(txt : String) : Void
	{
		xa.Utils.print(txt);
	}
	
	public static function main()
	{
		new Main();
	}
}
