Express = require 'express'
Instagram = require 'instagram'

# heroku config:add CLIENT_ID=.......
client_id = process.env.CLIENT_ID or throw "Missing Client ID"
client_secret = process.env.CLIENT_SECRET or throw "Missing Client Secret"
access_token = process.env.ACCESS_TOKEN or throw "Missing User Access Token"
user_id = process.env.USER_ID or throw "Missing Instagram UserID"

instagram = Instagram.createClient client_id, client_secret

app = Express.createServer Express.logger()
app.enable "jsonp callback"

querycache = null

app.get '/', (req, res) ->
	
	if querycache is not null
		res.json querycache
		return
	
	instagram.users.media user_id, { access_token: access_token, count: 200 }, (images, error, pagination) ->

		if error
			res.send "Something went wrong..", 503
			return
				
		output = []

		for img in images
			
			output.push {
				created_time: new Date (img.created_time * 1000)
				link: img.link
				image: img.images.low_resolution
				text: if img.caption?.text? then img.caption.text else "Untitled"
			}
		
		res.json output
		querycache = output
		
		setTimeout (() -> querycache = null), 20*1000

port = process.env.PORT or 9000;
app.listen port, () ->
	console.log "Listening on port #{port}"