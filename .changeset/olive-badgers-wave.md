---
"fuseki-geosparql": patch
---

Remove the stale `SIS_DATA` and `SIS_OPTS` environment variables

They pointed at `/apache-sis`, a directory that is no longer created since the
Apache SIS binary distribution got replaced by the Maven artifacts. Apache SIS
reads its EPSG dataset from the `sis-embedded-data` and `sis-epsg` jars on the
classpath, so this changes nothing in practice.

In case you were mounting your own Apache SIS data at `/apache-sis/data`, you now
have to set `SIS_DATA` yourself.
