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
						post.content = element.innerData;
						
					case "wp:post_date":
						post.date = Date.fromString(element.innerData);
						
					case "wp:post_name":
						post.name = element.innerData;
				}
			}
			
			// only return published posts and pages
			if(post.status == "publish")
			{
				posts.push(post);
			}
		}
		
		return posts;
	}
}
