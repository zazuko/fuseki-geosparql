---
"fuseki-geosparql": minor
---

Upgrade Apache Jena to 6.3.0

#### Removed: dataset creation from an uploaded assembler file

Apache Jena 6.3.0 removed the possibility to create a dataset by sending an
assembler file (Turtle) to the `$/datasets` endpoint of the Fuseki HTTP
Administration Protocol. This feature was already disabled by default since
Apache Jena 5.5.0. Such requests are now rejected with a `400 Bad Request`.

Datasets can still be created using `dbName` and `dbType` form parameters, or
by configuring them in the `config.ttl` file.
