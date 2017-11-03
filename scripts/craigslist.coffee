#Author: Miguel Medina
# Commands: 
#   hubot search "enter item to search here"
jsonfile    = require 'jsonfile'
craigslist  = require 'node-craigslist'
config_path = 'clmonitor-config.json'
millisec= 300000/5 
	
module.exports = (robot) ->


	#Search for item every so often
	robot.respond /search "(.*)"/, (msg) ->
		msg.send "checking every #{millisec/60000} minute(s)"
		setInterval ->
			options = jsonfile.readFileSync(config_path)
			client = new craigslist.Client()
			client
				.search(options, msg.match[1])
				.then (listings) ->
					listings.forEach (listing) -> 
						console.log(listing)
				.catch (err) ->
					console.error(err)
		, millisec
	
