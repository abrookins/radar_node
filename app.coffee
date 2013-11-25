http = require 'http'
express = require 'express'
params = require 'express-params'
kdt = require 'kdt'
crimes = require './data/2011.json'
haversine = require 'haversine'

# Create a kd-tree that uses the haversine formula to calculate distance
setupKdtree = ->
  # Make an array of objects that haversine and kdt can work with
  nodes = ({longitude: c.geometry.coordinates[0], \
            latitude: c.geometry.coordinates[1], crime: c} for c in crimes)
  dimensions = ["longitude", "latitude"]
  distance = (a, b) ->
    haversine(a, b, {unit: 'miles'})
  kdt.createKdTree(nodes, distance, dimensions)

kdtree = setupKdtree()

app = module.exports = express()

# Requests must include valid Numbers for `lat` and `lng`
params.extend(app)
app.param('lng', Number)
app.param('lat', Number)

app.configure ->
  app.set "port", process.env.PORT or 4000

  if 'development' == app.get('env')
    app.use express.errorHandler()


app.get '/crimes/near/:lng/:lat', (req, res) ->
  point =
    longitude: req.params.lng
    latitude: req.params.lat
  nearest = kdtree.nearest point, 1000, 0.5
  # We get the node and its distance, but only send the node.
  res.send JSON.stringify (n[0].crime for n in nearest)


if not module.parent
  port = app.get('port')
  app.listen port, ->
    console.log "Listening on port #{port}"
