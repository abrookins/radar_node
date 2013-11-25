# radar (node.js version): find crimes in Portland, Oregon

This is a node.js web service that finds crime data near a WGS84 coordinate.

# Running the server

With Foreman:

    foreman run web

Or without:

    coffee app.coffee

# Running tests

    tool/tests

Or with the node.js debugger:

    tool/tests debug

# Loading data

The repo includes City of Portland crime data from 2011.

If you want to convert other crime data from the City's records, obtain a CSV
file from [Civic Apps](http://civicapps.org/). You can run it through [my
GeoJSON converter](https://github.com/abrookins/pdxcrime_to_geojson).

# Deploying

You can probably deploy to Heroku. I haven't tried it yet. Procfile included!

# Performance

It's bad, maxing out at 200 requests/second on good hardware and only getting
worse at higher concurrency. I started with a MongoDB version (still in the
"mongo" branch) but could not push that past 20 requests/second.

# Benchmarking with wrk

Benchmark with this command:

    wrk -t12 -c400 -d30s "http://localhost:4000/crimes/near/-122.6554/45.5184/"

You should see:

    Running 30s test @ http://localhost:4000/crimes/near/-122.6554/45.5184/
      6 threads and 400 connections
      Thread Stats   Avg      Stdev     Max   +/- Stdev
        Latency     3.37s   867.91ms   3.84s    75.44%
        Req/Sec    19.07     32.21   142.00     82.15%
      3388 requests in 30.01s, 1.09GB read
      Socket errors: connect 151, read 248, write 0, timeout 2744
    Requests/sec:    112.89
    Transfer/sec:     37.04MB

For a comparison, the [Go version](https://github.com/abrookins/radar) of this
app can do 1249.21 reqs/sec for the same benchmark. It's not exactly the same,
but it's not that much different.

# The API

There is only one endpoint right now: /crimes/near/{longitude}/{latitude}.
It returns GeoJSON.

Here is an example of a GET:

    GET http://localhost:4000/crimes/near/-122.6554/45.5184

Response:

    [
      {
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
