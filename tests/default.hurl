# Check the ping endpoint: Fuseki is alive
GET http://127.0.0.1:3030/$/ping
HTTP 200

# Metrics should be exported
GET http://127.0.0.1:3030/$/metrics
HTTP 200

# Precise stats are not reachable for unauthenticated users
GET http://127.0.0.1:3030/$/stats
HTTP 401

# Admin user should have access to the stats
GET http://127.0.0.1:3030/$/stats
[BasicAuth]
admin: secret
HTTP 200

GET http://127.0.0.1:3030/ds/
HTTP 200

POST http://127.0.0.1:3030/ds/query
Content-Type: application/x-www-form-urlencoded
`query=PREFIX%20rdf%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F1999%2F02%2F22-rdf-syntax-ns%23%3E%0APREFIX%20rdfs%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0ASELECT%20%2A%20WHERE%20%7B%0A%20%20%3Fsub%20%3Fpred%20%3Fobj%20.%0A%7D%20LIMIT%2010`
HTTP 200
