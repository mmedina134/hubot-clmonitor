
craigslist = require 'node-craigslist'

module.exports = (robot) ->


  
	robot.respond /test/, (res) ->
		client = new craigslist.Client {
			city : 'seattle'
		}
		client
			.list()
			.then (listings) ->
				listings.forEach (listing) -> 
					console.log(listing)
			.catch (err) ->
				console.error(err)
	 
	
