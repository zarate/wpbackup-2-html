enum ItemType
{
	PAGE;
	POST;
}

class Item 
{
	public function new(){}
	
	public var title : String;
	public var status : String;
	public var link : String; // as per WP XML file
	public var relativeLink : String; // relative
	public var content : String;
	public var name : String;
	public var date : Date;
	public var type : ItemType;
}