# radar (node.js version): find crimes in Portland, Oregon

This is a node.js web service that finds crime data near a WGS84 coordinate.

# Running the server

With Foreman:

    foreman run web

Or without:

    coffee app.coffee

You also need Mongo running with a [2dsphere spatial index](http://docs.mongodb.org/manual/applications/geospatial-indexes/) on the crimes.geometry field.

# Running tests

    tool/tests

Or with the node.js debugger:

    tool/tests debug

# Loading data

The repo includes City of Portland crime data from 2011. Load it into Mongo
like this -- split into two files because Mongo has an input size limit:

    mongoimport --db crimes --collection crimes --file test.json --type json --jsonArray
    mongoimport --db crimes --collection crimes --file test2.json --type json --jsonArray

If you want to convert other crime data from the City's records, obtain a CSV
file from [Civic Apps](http://civicapps.org/). You can run it through [my
GeoJSON converter](https://github.com/abrookins/pdxcrime_to_geojson).

# Deploying

You can probably deploy to Heroku. I haven't tried it yet. Procfile included!

# Performance

It's absolutely terrible. I have no idea why.

Facts:

* Maxes out at 20 requests/second for the benchmark query
* Mongo has a 2d-sphere index on the geometry field, with no index misses
* Mongo query response time is around 50 ms for the first query and 0 ms
  afterward during the `wrk` benchmark
* Mongo seems to max out at 40 queries/second from the app during the benchmark
* Available connections in Mongo is around 1200 with 200 open connections from
  the app, so the connection pool is working

# Benchmarking with wrk

Benchmark with this command:

    wrk -t12 -c400 -d30s "http://localhost:4000/crimes/near/-122.6554/45.5184/"

You should see:

    Running 30s test @ http://localhost:4000/crimes/near/-122.6554/45.5184/
      12 threads and 400 connections
      Thread Stats   Avg      Stdev     Max   +/- Stdev
        Latency     0.00us    0.00us   0.00us     nan%
        Req/Sec     0.00      0.00     0.00       nan%
      239 requests in 30.01s, 168.06MB read
      Socket errors: connect 157, read 105, write 0, timeout 5468
    Requests/sec:      7.96
    Transfer/sec:      5.60MB

For a comparison, the [Go version](https://github.com/abrookins/radar) of this
app can do 1249.21 reqs/sec for this benchmark.

# The API

There is only one endpoint right now: /crimes/near/{longitude}/{latitude}.
It returns GeoJSON.

Here is an example of a GET:

    GET http://localhost:4000/crimes/near/-122.6554/45.5184

Response:

    [
      {
        "_id": "528fd5dbd7e972c30fa01b77",
        "geometry": {
          "coordinates": [
            -122.65566800319907,
            45.51792335276695
          ],
          "type": "Point"
        },
        "id": 13757361,
        "properties": {
          "address": "SE ALDER ST and SE 10TH AVE, PORTLAND, OR 97214",
          "crimeType": "Larceny",
          "neighborhood": "BUCKMAN-WEST",
          "policeDistrict": 711,
          "policePrecinct": "PORTLAND PREC CE",
          "reportTime": "2011-09-08T18:40:00"
        },
        "type": "Feature"
      },
      {
        "_id": "528fd5e2d7e972c30fa02675",
        "geometry": {
          "coordinates": [
            -122.65566800319907,
            45.51792335276695
          ],
          "type": "Point"
        },
        "id": 13622531,
        "properties": {
          "address": "SE ALDER ST and SE 10TH AVE, PORTLAND, OR 97214",
          "crimeType": "Larceny",
          "neighborhood": "BUCKMAN-WEST",
          "policeDistrict": 711,
          "policePrecinct": "PORTLAND PREC CE",
          "reportTime": "2011-01-30T03:41:00"
        },
        "type": "Feature"
      }
    ]


# License

MIT. See LICENSE for details.
Copyright Andrew Brookins, 2013.
