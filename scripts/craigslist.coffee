# Author: Miguel Medina
# Commands: 
#   hubot add "enter item to search here" to search
#	hubot start searching
#   hubot reset search

jsonfile        = require 'jsonfile'
craigslist      = require 'node-craigslist'
config_path     = 'clmonitor-config.json'
post_id_history = 'posting-id-history.json'
millisec        = 300000/10 
Conversation    = require 'hubot-conversation'
pid_list        = []
module.exports = (robot) ->

	switchBoard = new Conversation(robot)
	robot.respond /test/i, (msg) ->
		url = "https://" + process.env.HUBOT_FLOWDOCK_LOGIN_EMAIL + ":" + process.env.HUBOT_FLOWDOCK_LOGIN_PASSWORD + "@api.flowdock.com/flows/find?id=" + msg.message.user.room
		robot.http(url)
			.header('Accept', 'application/json')
			.get() (err, res, body) ->
				room_info = JSON.parse body
				console.log room_info.name

	#Add new item to monitor
	robot.respond /add "(.*)" to search/i, (msg) ->
		searchCriteria = {}
		searchCriteria.search = msg.match[1]
		dialog    = switchBoard.startDialog(msg)
		msg.reply 'What city would you like to search?'
		#dialog.addChoice /([^0]+)/i, (msg2) -> 
		dialog.addChoice /(.+)/i, (msg2) -> 
			searchCriteria.city = msg2.match[1]
			msg2.reply 'Which category would you like to search(examples, enter "cto" for cars and trucks sold by owner, or "hsw" for housing wanted )?'
			dialog.addChoice /(.+)/i, (msg3) -> 
				searchCriteria.category = msg3.match[1]
				msg3.reply 'search nearby(enter yes or no)?'
				dialog.addChoice /(yes|no)/i, (msg4) ->
					decision = msg4.match[1].toUpperCase()
					console.log decision
					isDecided = false #'#
					if decision == "YES" 
						searchCriteria.searchNearby = "true"
						isDecided = true
					else if decision == "NO"
						searchCriteria.searchNearby = "false"
						isDecided = true #'#
					else 
						msg4.reply 'please start over and reenter the initial command "add "item" to search"'
						isDecided = false
					if isDecided
						msg4.reply 'What is the base host(enter 0 for default "craigslist.org" base host)?'
						dialog.addChoice /([^0]+)/i, (msg5) -> 
							searchCriteria.baseHost = msg5.match[1]
							addToSearchFile(searchCriteria,msg5)
							msg5.reply "to start searching just type 'craiglistbot start searching' into the chat window"
						dialog.addChoice /(0)/i, (msg5) ->
							searchCriteria.baseHost = "craigslist.org"
							addToSearchFile(searchCriteria,msg5)
							msg5.reply "to start searching just type 'craiglistbot start searching' into the chat window"
							
	#Search for item every so often	
	robot.respond /start searching/i, (msg) ->	
		msg.send "checking every #{millisec/60000} minute(s)"
		setInterval ->
			options = jsonfile.readFileSync(config_path)
			client = new craigslist.Client()
			url = "https://" + process.env.HUBOT_FLOWDOCK_LOGIN_EMAIL + ":" + process.env.HUBOT_FLOWDOCK_LOGIN_PASSWORD + "@api.flowdock.com/flows/find?id=" + msg.message.user.room
			robot.http(url)
				.header('Accept', 'application/json')
				.get() (err, res, body) ->
					room_info = JSON.parse body
					room_name = room_info.name
					for item in options.items
						if item.room_name == room_name
							for searchCriteria in item.searchCriterias
								client
									.search(searchCriteria, searchCriteria.search)
									.then (listings) ->
										listings.forEach (listing) -> 
											pid_list = jsonfile.readFileSync(post_id_history)
											room_is_in_pidlist = false
											for pid_list_item in pid_list
												if pid_list_item.room_name == room_name
													if listing.pid not in pid_list_item.pids
														msg.reply("**Found new listing**, **title of listing**:  " + listing.title + ", **date**: " + listing.date.toString() + "\n**link**: " + listing.url + " \n**location**:" + listing.location + ",**price**:" + listing.price + ", **picture**:" + listing.hasPic)
														pid_list_item.pids.push listing.pid
														jsonfile.writeFileSync post_id_history, pid_list
													room_is_in_pidlist = true
														
											if room_is_in_pidlist == false
												msg.send(JSON.stringify listing)
												pid_item = {}
												pid_item.pids = []
												pid_item.room_name = room_name
												pid_item.pids.push listing.pid
												pid_list.push pid_item
												jsonfile.writeFileSync post_id_history, pid_list
									.catch (err) ->
										console.error(err)
		, millisec
	
	#reset all items that were being monitored
	robot.respond /reset search/i, (msg) ->	
		options = jsonfile.readFileSync(config_path)
		url = "https://" + process.env.HUBOT_FLOWDOCK_LOGIN_EMAIL + ":" + process.env.HUBOT_FLOWDOCK_LOGIN_PASSWORD + "@api.flowdock.com/flows/find?id=" + msg.message.user.room
		robot.http(url)
			.header('Accept', 'application/json')
			.get() (err, res, body) ->
				room_info = JSON.parse body
				room_name = room_info.name
				for item in options.items
					if item.room_name == room_name
						item.searchCriterias = []
						jsonfile.writeFileSync config_path, options
						break
				pid_list = jsonfile.readFileSync(post_id_history)
				for pid_list_item in pid_list
					if pid_list_item.room_name == room_name
						pid_list_item.pids = []
						jsonfile.writeFileSync post_id_history, pid_list
						break
				msg.reply "search has been reseted to add to search please type 'craiglistbot add \"search text\" to search'"
		
	addToSearchFile = (searchCriteria,msg) ->
		url = "https://" + process.env.HUBOT_FLOWDOCK_LOGIN_EMAIL + ":" + process.env.HUBOT_FLOWDOCK_LOGIN_PASSWORD + "@api.flowdock.com/flows/find?id=" + msg.message.user.room
		robot.http(url)
			.header('Accept', 'application/json')
			.get() (err, res, body) ->
				room_info = JSON.parse body
				room_name = room_info.name
				options = jsonfile.readFileSync(config_path)
				console.log options
				search = {}
				search.room_name = room_name
				room_is_found = false
				for item in options.items
					if item.room_name == search.room_name
						room_is_found = true
						item.searchCriterias.push searchCriteria
						break
				if room_is_found == false
					search.searchCriterias = []
					search.searchCriterias.push searchCriteria
					options.items.push search
				jsonfile.writeFileSync config_path, options
				
