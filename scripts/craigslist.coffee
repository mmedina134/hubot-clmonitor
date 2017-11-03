#Developer: Miguel Medina

jsonfile    = require 'jsonfile'
craigslist  = require 'node-craigslist'
config_path = 'clmonitor-config.json'

	
module.exports = (robot) ->


	#Testing craigslist api
	robot.respond /test/, (res) ->
		config = jsonfile.readFileSync(config_path)
		options = {
			searchTitlesOnly:config.searchTitlesOnly
			category: config.category
			city : config.city
			baseHost: config.baseHost
			}
		client = new craigslist.Client(config)
		client
			.search(options, config.search)
			.then (listings) ->
				listings.forEach (listing) -> 
					console.log(listing)
			.catch (err) ->
				console.error(err)
			
	
