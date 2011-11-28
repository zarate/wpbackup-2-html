package;

enum Argument
{
	WP_BACKUP_FILE_PATH;
	OUTPUT_FOLDER_PATH;
	TEMPLATE_FOLDER_PATH;
	HELP;
}

class Arguments
{
	public static function create(name : String) : Argument
	{
		return switch(name)
		{
			case "-wp" : Argument.WP_BACKUP_FILE_PATH;
			case "-o" : Argument.OUTPUT_FOLDER_PATH;
			case "-t" : Argument.TEMPLATE_FOLDER_PATH;
			case "-h" : Argument.HELP;
			case "-help" : Argument.HELP;
		}
	}
}