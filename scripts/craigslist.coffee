jsonfile   = require 'jsonfile'
craigslist = require 'node-craigslist'
config_path       = 'clmonitor-config.json'
module.exports = (robot) ->


  
	robot.respond /test/, (res) ->
		config = jsonfile.readFileSync(config_path)
		client = new craigslist.Client {
			city : config.city
		}
		client
			.list()
			.then (listings) ->
				listings.forEach (listing) -> 
					console.log(listing)
			.catch (err) ->
				console.error(err)
			
	
