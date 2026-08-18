# Check the ping endpoint: Fuseki is alive
GET http://127.0.0.1:3031/$/ping
HTTP 200

# Metrics should be exported
GET http://127.0.0.1:3031/$/metrics
HTTP 200

# Statistics should be available
GET http://127.0.0.1:3031/$/stats
HTTP 200

GET http://127.0.0.1:3031/ds/
HTTP 200

POST http://127.0.0.1:3031/ds/query
Content-Type: application/x-www-form-urlencoded
`query=PREFIX%20rdf%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F1999%2F02%2F22-rdf-syntax-ns%23%3E%0APREFIX%20rdfs%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0ASELECT%20%2A%20WHERE%20%7B%0A%20%20%3Fsub%20%3Fpred%20%3Fobj%20.%0A%7D%20LIMIT%2010`
HTTP 200

##############################
# GeoSPARQL specific queries #
##############################

# Is Bern in France? (should be 'false')
POST http://127.0.0.1:3031/ds/query
Content-Type: application/x-www-form-urlencoded
`query=PREFIX%20rdf%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F1999%2F02%2F22-rdf-syntax-ns%23%3E%0APREFIX%20rdfs%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0APREFIX%20geo%3A%20%3Chttp%3A%2F%2Fwww.opengis.net%2Font%2Fgeosparql%23%3E%0A%0AASK%20%7B%0A%20%20%3Curn%3Atest%3Ageosparql%3Abern%3Ageometry%3E%20geo%3AsfWithin%20%3Curn%3Atest%3Ageosparql%3Afrance%3Ageometry%3E%20.%0A%7D%20%0A`
HTTP 200
[Asserts]
jsonpath "$.boolean" == false

# Is Strasbourg in France? (should be 'yes')
POST http://127.0.0.1:3031/ds/query
Content-Type: application/x-www-form-urlencoded
`query=PREFIX%20rdf%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F1999%2F02%2F22-rdf-syntax-ns%23%3E%0APREFIX%20rdfs%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0APREFIX%20geo%3A%20%3Chttp%3A%2F%2Fwww.opengis.net%2Font%2Fgeosparql%23%3E%0A%0AASK%20%7B%0A%20%20%3Curn%3Atest%3Ageosparql%3Astrasbourg%3Ageometry%3E%20geo%3AsfWithin%20%3Curn%3Atest%3Ageosparql%3Afrance%3Ageometry%3E%20.%0A%7D%20%0A`
HTTP 200
[Asserts]
jsonpath "$.boolean" == true

# How far is Strasbourg from Bern, in metres? (should be about 183 km)
#
# Regression test: Apache Jena < 6.2.0 computed a Euclidean distance in the
# units of the SRS, so asking for a linear unit on a geographic SRS such as
# CRS84 left the result unbound.
POST http://127.0.0.1:3031/ds/query
Content-Type: application/x-www-form-urlencoded
`query=PREFIX%20geo%3A%20%3Chttp%3A%2F%2Fwww.opengis.net%2Font%2Fgeosparql%23%3E%0APREFIX%20geof%3A%20%3Chttp%3A%2F%2Fwww.opengis.net%2Fdef%2Ffunction%2Fgeosparql%2F%3E%0APREFIX%20uom%3A%20%3Chttp%3A%2F%2Fwww.opengis.net%2Fdef%2Fuom%2FOGC%2F1.0%2F%3E%0A%0ASELECT%20%3Fdistance%20WHERE%20%7B%0A%20%20%3Curn%3Atest%3Ageosparql%3Abern%3Ageometry%3E%20geo%3AasWKT%20%3Fbern%20.%0A%20%20%3Curn%3Atest%3Ageosparql%3Astrasbourg%3Ageometry%3E%20geo%3AasWKT%20%3Fstrasbourg%20.%0A%20%20BIND%28geof%3Adistance%28%3Fbern%2C%20%3Fstrasbourg%2C%20uom%3Ametre%29%20AS%20%3Fdistance%29%0A%7D%0A`
HTTP 200
[Asserts]
jsonpath "$.results.bindings[0].distance.value" toFloat > 183000
jsonpath "$.results.bindings[0].distance.value" toFloat < 184000
