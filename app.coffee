http = require 'http'
express = require 'express'
util = require 'util'
params = require 'express-params'

MongoClient = require('mongodb').MongoClient

hostEnv = "MONGO_NODE_DRIVER_HOST"
portEnv = "MONGO_NODE_DRIVER_PORT"
dbHost = if process.env.hostEnv? then process.env.hostEnv else "localhost"
dbPort = if process.env.portEnv? then process.env.portEnv else 27017
dbUri = util.format("mongodb://%s:%s/crimes", dbHost, dbPort)

app = module.exports = express()

app.configure ->
  app.set "port", process.env.PORT or 4000
  params.extend(app)

  if 'development' == app.get('env')
    app.use express.errorHandler()


app.param('lng', Number)
app.param('lat', Number)

app.get '/crimes/near/:lng/:lat', (req, res) ->
  options = 
    geometry:
      $near:
        $geometry:
          type: "Point"
          coordinates: [req.params.lng, req.params.lat]
        $maxDistance: 804.672
  app.crimes.find(options).toArray (err, crimes) ->
    if err
      console.log util.format('Error in DB query: %s', err)
      res.status 500
      res.send 'Server encountered an error'
      return
    res.send JSON.stringify crimes


options = 
  server:
    poolSize: 200
    auto_reconnect: true
    socketOptions:
      connectTimeoutMS: 1000

MongoClient.connect dbUri, options, (err, db) ->
  if err
    console.log err
    return

  app.crimes = db.collection('crimes')

  app.emit 'dbReady'

  if not module.parent
      port = app.get('port')
      app.listen port, ->
        console.log "Listening on port #{port}"
