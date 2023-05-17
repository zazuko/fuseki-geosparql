# check the ping endpoint: Fuseki is alive
GET http://127.0.0.1:3031/$/ping
HTTP 200

# metrics should be exported
GET http://127.0.0.1:3031/$/metrics
HTTP 200

# precise stats are not reachable for unauthenticated users
GET http://127.0.0.1:3031/$/stats
HTTP 401

# admin user should have access to the stats
GET http://127.0.0.1:3031/$/stats
[BasicAuth]
admin: secret
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

# Is Bern in France? (should be 'no')
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
