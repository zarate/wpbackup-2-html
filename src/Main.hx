package;

import Arguments.Argument;
import haxe.Template;
import Item.ItemType;

class Main
{	
	var wpBackupFilePath : String;
	
	var outputFolderPath : String;
	
	var templateFolderPath : String;
	
	var items : Array<Item>;
	
	static var DEFAULT_OUTPUT_FOLDER_PATH : String = "output";
	
	static var DEFAULT_TEMPLATE_FOLDER_PATH : String = "templates";
	
	static var MAIN_TEMPLATE_PATH : String = "template.html";
	
	static var INDEX_TEMPLATE_PATH : String = "index.html";
	
	static var POST_TEMPLATE_PATH : String = "post.html";
	
	function new()
	{
		log("Welcome to the Wordpress to HTML recovery tool. Fingers crossed.");
		
		parseArguments();
		
		parseBackupFile();
		
		outputStaticHTMLPages();
	}
	
	function parseArguments() : Void
	{
		var args = xa.Application.getArguments();
		
		if(args.length <= 0)
		{
			printHelp();
		}
		
		for(i in 0...args.length)
		{
			switch(Arguments.create(args[i]))
			{
				case Argument.WP_BACKUP_FILE_PATH:
					wpBackupFilePath = args[i+1];
					
				case Argument.OUTPUT_FOLDER_PATH:
					outputFolderPath = args[i+1];
					
				case Argument.TEMPLATE_FOLDER_PATH:
					templateFolderPath = args[i+1];
				
				case Argument.HELP:
					printHelp();
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
		
		if(null == templateFolderPath)
		{
			log("Going to use defatult template folder path: " + DEFAULT_TEMPLATE_FOLDER_PATH);
			
			templateFolderPath = DEFAULT_TEMPLATE_FOLDER_PATH;
		}
	}
	
	function parseBackupFile() : Void
	{
		if(!xa.File.isFile(wpBackupFilePath))
		{
			exit(wpBackupFilePath + " is not a valid file");
		}
		
		items = Parser.parse(xa.File.read(wpBackupFilePath));
		items.sort(sortByDate);
		
		log("Found " + items.length + " items");
	}
	
	function sortByDate(a : Item, b : Item) : Int
	{
		var ret : Int = null;
		
		var diff : Float = a.date.getTime() - b.date.getTime();
		
		if(diff == 0)
		{
			ret = 0;
		}
		else if(diff > 0)
		{
			ret = -1;
		}
		else
		{
			ret = 1;
		}
		
		return ret;
	}
	
	function outputStaticHTMLPages() : Void
	{
		if(xa.Folder.isFolder(outputFolderPath))
		{
			log("Removing old output folder");
			xa.Folder.forceDelete(outputFolderPath);
		}
		
		xa.Folder.create(outputFolderPath);
		
		var posts = [];
		var pages = [];
		
		
		var postTemplatePath = templateFolderPath + xa.System.getSeparator() + POST_TEMPLATE_PATH;
		
		if(!xa.File.isFile(postTemplatePath))
		{
			exit("Cannot read post template file: " + postTemplatePath);
		}
		
		var postTemplateContent = xa.File.read(postTemplatePath);
		
		for(item in items)
		{
			switch(item.type)
			{
				case ItemType.POST:
					posts.push(item);
					
				case ItemType.PAGE:
					pages.push(item);
			}
			
			var postFolder = createDateFolder(item);
			
			var postTemplate = new haxe.Template(postTemplateContent);
				
			// this back to index thing is far from elegant, i know
			var backToIndexLink = "index.html";
			
			var postDeepness = item.relativeLink.split(xa.System.UNIX_SEPARATOR).length;
			
			for(i in 0...postDeepness)
			{
				backToIndexLink = "../" + backToIndexLink;
			}
			
			xa.File.write(postFolder + xa.System.UNIX_SEPARATOR + "index.htm", renderPage(postTemplate.execute({content: item.content, title: item.title, linkToIndex: backToIndexLink}), item.title));
		}
		
		var indexTemplatePath = templateFolderPath + xa.System.getSeparator() + INDEX_TEMPLATE_PATH;
		
		if(!xa.File.isFile(indexTemplatePath))
		{
			exit("Cannot read index template file: " + indexTemplatePath);
		}
		
		var indexTemplate = new haxe.Template(xa.File.read(indexTemplatePath));
		
		xa.File.write(outputFolderPath + xa.System.getSeparator() + "index.html", renderPage(indexTemplate.execute({posts: posts, pages: pages})));
	}
	
	function renderPage(content : String, ?title : String = "") : String
	{
		var mainTemplate = new haxe.Template(xa.File.read(templateFolderPath + xa.System.getSeparator() + MAIN_TEMPLATE_PATH));
		return mainTemplate.execute({content: content, title: title});
	}
	
	function createDateFolder(item : Item) : String
	{
		// start at the root of the output folder
		var fullFolderPath = outputFolderPath;
		
		// then we create the YYYY/MM/DD/post-title folder structure as needed
		var folders = item.relativeLink.split(xa.System.UNIX_SEPARATOR);
		
		for(folder in folders)
		{
			fullFolderPath += xa.System.UNIX_SEPARATOR + folder;
			
			if(!xa.Folder.isFolder(fullFolderPath))
			{
				xa.Folder.create(fullFolderPath);
			}
		}
		
		return fullFolderPath;
	}
	
	function printHelp() : Void
	{
		var help = [];
		
		help.push("Options:");
		help.push("\t-wp: path to the WordPress backup file. Mandatory.");
		help.push("\t-o: output folder path. Optional, defaults to: " + DEFAULT_OUTPUT_FOLDER_PATH);
		help.push("\t-t: template folder path. Optional, defatuls to: " + DEFAULT_TEMPLATE_FOLDER_PATH);
		help.push("\t-h: prints this help!");
		
		exit(help.join("\n"));
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
	
	/**
	 * Application's entry point
	 */
	public static function main()
	{
		new Main();
	}
}
