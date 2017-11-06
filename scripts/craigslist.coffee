#Author: Miguel Medina
# Commands: 
#   hubot search "enter item to search here"
jsonfile    = require 'jsonfile'
craigslist  = require 'node-craigslist'
config_path = 'clmonitor-config.json'
millisec= 300000/10 

module.exports = (robot) ->


	#Search for item every so often
	robot.respond /search "(.*)"/, (msg) ->
		msg.send "checking every #{millisec/60000} minute(s)"
		setInterval ->
			options = jsonfile.readFileSync(config_path)
			client = new craigslist.Client()
			
			for option in options.items
				client
					.search(option, msg.match[1])
					.then (listings) ->
						listings.forEach (listing) -> 
							msg.send(JSON.stringify listing)
					.catch (err) ->
						console.error(err)
		, millisec
	
