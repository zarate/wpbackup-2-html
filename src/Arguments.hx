package;

enum Argument
{
	WP_BACKUP_FILE_PATH;
	OUTPUT_FOLDER_PATH;
}

class Arguments
{
	public static function create(name : String) : Argument
	{
		return switch(name)
		{
			case "-wp" : Argument.WP_BACKUP_FILE_PATH;
			case "-o" : Argument.OUTPUT_FOLDER_PATH;
		}
	}
}