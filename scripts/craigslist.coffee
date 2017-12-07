#Author: Miguel Medina
# Commands: 
#   hubot add "enter item to search here" to search
#	hubot start searching
#   hubot reset search

jsonfile    = require 'jsonfile'
craigslist  = require 'node-craigslist'
config_path = 'clmonitor-config.json'
millisec    = 300000/10 
Conversation = require 'hubot-conversation'

module.exports = (robot) ->

	switchBoard = new Conversation(robot)
	#Search for item every so often
	robot.respond /add "(.*)" to search/i, (msg) ->
		searchVal = msg.match[1]
		dialog    = switchBoard.startDialog(msg)
		msg.reply 'What city would you like to search?'
		dialog.addChoice /(.+)/i, (msg2) -> 
			city = msg2.match[1]
			searchCriteria = {
				search:searchVal
				city:city
				}
			options = jsonfile.readFileSync(config_path)
			options.items.push searchCriteria
			jsonfile.writeFileSync config_path, options
			
	robot.respond /start searching/i, (msg) ->	
		msg.send "checking every #{millisec/60000} minute(s)"
		setInterval ->
			options = jsonfile.readFileSync(config_path)
			client = new craigslist.Client()
			for option in options.items
				client
					.search(option, option.search)
					.then (listings) ->
						listings.forEach (listing) -> 
							msg.send(JSON.stringify listing)
					.catch (err) ->
						console.error(err)
		, millisec
		
	robot.respond /reset search/i, (msg) ->	
		options = jsonfile.readFileSync(config_path)
		options.items = []
		jsonfile.writeFileSync config_path, options
		
	
