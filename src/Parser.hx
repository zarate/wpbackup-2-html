import Item.ItemType;

class Parser
{
	public static function parse(content : String) : Array<Item>
	{
		var items = [];
		
		var xml = Xml.parse(content);
		
		// first get the list of all the posts, pages, etc,
		// this includes drafts
		var itemNodes = new haxe.xml.Fast(xml.firstElement()).node.channel.nodes.item;
		
		for(itemNode in itemNodes)
		{
			var item = new Item();
			item.title = itemNode.node.title.innerData;
			item.link = (itemNode.hasNode.link)? itemNode.node.link.innerData : null;
			
			// i'm having trouble with namespaces in the WP XML, so
			// we'll brute force it for the time being
			for(element in itemNode.elements)
			{
				switch(element.name)
				{
					case "wp:status":
						item.status = element.innerData;
						
					case "content:encoded":
						
						var rawContent = element.innerData;
						
						// as a rule of thumb, we DO need the raw HTML that's stored in the 
						// XML. However, we should at least escape the HTML that's within the
						// [code][/code] blocks.
						
						var escape = ~/\[code.*?\/code\]/s;
						rawContent = escape.customReplace(rawContent, escapeHtml);
						
						// then we need to go from plain line breaks to brs
						rawContent = StringTools.replace(rawContent, "\r\n", "<br/>");
						
						item.content = rawContent;
						
					case "wp:post_date":
						item.date = Date.fromString(element.innerData);
						
					case "wp:post_name":
						item.name = element.innerData;
						
					case "wp:post_type":
						
						switch(element.innerData)
						{
							case "post": item.type = ItemType.POST;
							case "page": item.type = ItemType.PAGE;
						}
				}
			}
			
			// we need to put together a permalink structure either:
			// 		for posts: YYYY/MM/DD/web-safe-title
			// 		for pages: web-safe-title
			
			var bits = null;
			
			if(item.type == ItemType.POST)
			{
				// Date.getMenth() is 0-based, we need to add 1 for a human readable version
				bits = [pad(item.date.getFullYear()), pad(item.date.getMonth() + 1), pad(item.date.getDate()), item.name];
			}
			else
			{
				bits = [item.name];
			}
			
			item.relativeLink  = bits.join(xa.System.UNIX_SEPARATOR);
			
			// only return published posts and pages
			if(item.status == "publish")
			{
				items.push(item);
			}
		}
		
		return items;
	}
	
	static function escapeHtml(e : EReg) : String
	{
		return StringTools.htmlEscape(e.matched(0));
	}
	
	static function pad(value : Int) : String
	{
		return StringTools.lpad(Std.string(value), "0", 2);
	}
}
