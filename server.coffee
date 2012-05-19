Express = require 'express'
Instagram = require 'instagram'

# heroku config:add CLIENT_ID=.......
client_id = process.env.CLIENT_ID or throw "Missing Client ID"
client_secret = process.env.CLIENT_SECRET or throw "Missing Client Secret"
access_token = process.env.ACCESS_TOKEN or throw "Missing User Access Token"

instagram = Instagram.createClient client_id, client_secret

app = Express.createServer Express.logger()
app.enable "jsonp callback"

app.get '^', (req, res) ->
	instagram.users.self { access_token: access_token, count: 100 }, (images, error, pagination) ->

		if error
			res.send "Something went wrong..", 503
			return

		output = []

		for img in images
			output.push {
				created_time: img.created_time
				link: img.link
				image: img.images.low_resolution
				text: img.caption.text
			}

		res.json output

port = process.env.PORT or 9000;
app.listen port, () ->
	console.log "Listening on port #{port}"