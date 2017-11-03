#Author: Miguel Medina
# Commands: 
#   hubot search "enter item to search here"
jsonfile    = require 'jsonfile'
craigslist  = require 'node-craigslist'
config_path = 'clmonitor-config.json'

	
module.exports = (robot) ->


	#Testing craigslist api
	robot.respond /search "(.*)"/, (msg) ->
		options = jsonfile.readFileSync(config_path)
		client = new craigslist.Client()
		client
			.search(options, msg.match[1])
			.then (listings) ->
				listings.forEach (listing) -> 
					console.log(listing)
			.catch (err) ->
				console.error(err)
			
	
