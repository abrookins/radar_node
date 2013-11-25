http = require 'http'
app = require '../app'
assert = require 'assert'
request = require 'request'
haversine = require 'haversine'

PORT = 4001
URL = "http://localhost:#{PORT}"

EARTH_RADIUS = 3959.0  # Miles

describe 'app', ->
  before (done) ->
      @server = app.listen PORT, (err, result) ->
        if err
          done err
        else
          done()

  after ->
    @server.close()

  it 'should exist', (done) ->
    assert.ok app
    done()

  it 'should be listening on localhost:4000', (done) ->
    expected = 404
    request.get "#{URL}/", (err, resp, body) ->
      assert.equal resp.statusCode, expected 
      done()

  it 'should respond with crimes near a valid location', (done) ->
    expectedStatus = 200
    expectedDocuments = 576
    targetPoint =
      longitude: -122.6488921
      latitude: 45.5085219 
    url = "#{URL}/crimes/near/#{targetPoint.longitude}/#{targetPoint.latitude}"

    request.get url, (err, resp, body) ->
      parsedBody = JSON.parse(body)
      assert.equal resp.statusCode, expectedStatus
      assert.equal parsedBody.length, expectedDocuments
      done()

  it 'should only respond with crimes less than half mile away', (done) ->
    targetPoint =
      longitude: -122.6488921
      latitude: 45.5085219 
    url = "#{URL}/crimes/near/#{targetPoint.longitude}/#{targetPoint.latitude}"

    request.get url, (err, resp, body) ->
      parsedBody = JSON.parse(body)

      # Test every crime!
      for crime in parsedBody
        crimePoint =
          longitude: crime.geometry.coordinates[0]
          latitude: crime.geometry.coordinates[1]
        expectedMaxDistance = 0.5
        distance = haversine(crimePoint, targetPoint, {unit: 'miles'})
        assert.ok expectedMaxDistance >= distance

      done()

  it 'should 404 with a bad latitude', (done) ->
    expectedStatus = 404
    targetPoint =
      longitude: -122.6488921
      latitude: 'Badness!'
    url = "#{URL}/crimes/near/#{targetPoint.longitude}/#{targetPoint.latitude}"

    request.get url, (err, resp, body) ->
      assert.equal resp.statusCode, expectedStatus
      done()

  it 'should 404 with a bad longitude', (done) ->
    expectedStatus = 404
    targetPoint =
      longitude: "Ruh roh!"
      latitude: 45.5085219
    url = "#{URL}/crimes/near/#{targetPoint.longitude}/#{targetPoint.latitude}"

    request.get url, (err, resp, body) ->
      assert.equal resp.statusCode, expectedStatus
      done()

