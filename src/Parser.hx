import Post.PostType;

class Parser
{
	public static function parse(content : String) : Array<Post>
	{
		var posts = [];
		
		var xml = Xml.parse(content);
		
		// first get the list of all the posts, pages, etc,
		// this includes drafts
		var items = new haxe.xml.Fast(xml.firstElement()).node.channel.nodes.item;
		
		for(item in items)
		{
			var post : Post = new Post();
			post.title = item.node.title.innerData;
			post.link = (item.hasNode.link)? item.node.link.innerData : null;
			
			// i'm having trouble with namespaces in the WP XML, so
			// we'll brute force it for the time being
			for(element in item.elements)
			{
				switch(element.name)
				{
					case "wp:status":
						post.status = element.innerData;
						
					case "content:encoded":
						
						var rawContent = element.innerData;
						
						// as a rule of thumb, we DO need the raw HTML that's stored in the 
						// XML. However, we should at least escape the HTML that's within the
						// [code][/code] blocks.
						
						var escape = ~/\[code.*?\/code\]/s;
						rawContent = escape.customReplace(rawContent, escapeHtml);
						
						// then we need to go from plain line breaks to brs
						rawContent = StringTools.replace(rawContent, "\r\n", "<br/>");
						
						post.content = rawContent;
						
					case "wp:post_date":
						post.date = Date.fromString(element.innerData);
						
					case "wp:post_name":
						post.name = element.innerData;
						
					case "wp:post_type":
						
						switch(element.innerData)
						{
							case "post": post.type = PostType.POST;
							case "page": post.type = PostType.PAGE;
						}
				}
			}
			
			// we need to put together a permalink structure either:
			// 		for posts: YYYY/MM/DD/web-safe-title
			// 		for pages: web-safe-title
			
			var bits = null;
			
			if(post.type == PostType.POST)
			{
				// Date.getMenth() is 0-based, we need to add 1 for a human readable version
				bits = [pad(post.date.getFullYear()), pad(post.date.getMonth() + 1), pad(post.date.getDate()), post.name];
			}
			else
			{
				bits = [post.name];
			}
			
			post.relativeLink  = bits.join(xa.System.UNIX_SEPARATOR);
			
			// only return published posts and pages
			if(post.status == "publish")
			{
				posts.push(post);
			}
		}
		
		return posts;
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
