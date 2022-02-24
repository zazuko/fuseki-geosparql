# OpenTelemetry

This Docker image is configured to include the OpenTelemetry Java agent.

We provide a `docker-compose` stack to let you test it.

## Presentation of the stack

The stack includes the following services:

- two Fuseki instances:
  - `fuseki-persons`, serving `data/persons.nt` and recheable at: http://localhost:3030/
  - `fuseki-relations`, serving `data/relations.nt` and recheable at: http://localhost:3031/
- `opentelemetry-collector` to receive traces and metrics via OTLP
- Jaeger "all in one", to ingest and visualize traces: http://localhost:16686/
- Prometheus, configured to scrape some exposed metrics: http://localhost:9090/
- a Filebeat module that parses Fuseki's logs
- an OpenSearch-Filebeat-OpenSearch Dashboard setup that ingests logs from the whole stack.
  OpenSearch Dashboard is running on http://localhost:5601/ (credentials: `admin` / `admin`)
- a Grafana instance, to visualize logs and traces: http://localhost:3000/

## Running

Run the following command:

```sh
docker-compose up
```

## Sample federated query

Run this query on [`fuseki-persons`](http://localhost:3030/#/dataset/ds/query):

```sparql
PREFIX schema: <http://schema.org/>

SELECT ?p ?givenName ?familyName ?additionalName (COUNT(?p) as ?relationships) WHERE {
  ?p a schema:Person ;
    schema:givenName ?givenName ;
    schema:familyName ?familyName .

  OPTIONAL {
    ?p schema:additionalName ?additionalName .

    SERVICE <http://fuseki-relations:3030/ds> {
      ?p schema:knows [] .
    }
  }
}
GROUP BY ?p ?givenName ?familyName ?additionalName
```

## Check logs and traces

Check the logs [in Grafana](http://localhost:3000):

- navigate to the [Explore view](http://localhost:3000/explore)
- in the query builder at the top, under "Metric" select "Logs" instead of "Count"
- unroll a log entry with a trace (basically anything else than the startup logs)
- click on "Jaeger" to view the associated trace

## Teardown

Run the following command to remvove the stack:

```sh
docker-compose down
```
