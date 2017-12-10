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
	
	#Add new item to monitor
	robot.respond /add "(.*)" to search/i, (msg) ->
		searchCriteria = {}
		searchCriteria.search = msg.match[1]
		dialog    = switchBoard.startDialog(msg)
		msg.reply 'What city would you like to search?'
		#dialog.addChoice /([^0]+)/i, (msg2) -> 
		dialog.addChoice /(.+)/i, (msg2) -> 
			searchCriteria.city = msg2.match[1]
			msg2.reply 'Which category would you like to search?'
			dialog.addChoice /(.+)/i, (msg3) -> 
				searchCriteria.category = msg3.match[1]
				msg3.reply 'search nearby(enter yes or no)?'
				dialog.addChoice /(yes|no)/i, (msg4) ->
					decision = msg4.match[1].toUpperCase()
					console.log decision
					isDecided = false
					if decision == "YES" 
						searchCriteria.searchNearby = "true"
						isDecided = true
					else if decision == "NO"
						searchCriteria.searchNearby = "false"
						isDecided = true
					else
						msg4.reply 'please start over and reenter the initial command "add "item" to search"'
						isDecided = false
					if isDecided
						msg4.reply 'What is the base host(enter 0 for default "craigslist.org" base host)?'
						dialog.addChoice /([^0]+)/i, (msg5) -> 
							searchCriteria.baseHost = msg5.match[1]
							addToSearchFile(searchCriteria)
						dialog.addChoice /(0)/i, (msg5) ->
							searchCriteria.baseHost = "craigslist.org"
							addToSearchFile(searchCriteria)
							
	#Search for item every so often	
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
	
	#reset all items that were being monitored
	robot.respond /reset search/i, (msg) ->	
		options = jsonfile.readFileSync(config_path)
		options.items = []
		jsonfile.writeFileSync config_path, options
		
addToSearchFile = (searchCriteria) ->
	options = jsonfile.readFileSync(config_path)
	options.items.push searchCriteria
	jsonfile.writeFileSync config_path, options
