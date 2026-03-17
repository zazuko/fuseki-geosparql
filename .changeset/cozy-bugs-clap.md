---
"fuseki-geosparql": patch
---

Expose `/$/stats` instead of `/$/status`, as reported by @cfollenf (#76).

With the Apache Jena upgrade, the `/$/status` endpoint is no longer available, as it returns a 404 error.

There is a `/$/stats` endpoint that provides some statistics about the datasets, so we can expose this one instead.

It contains some statistics that are also exposed in the `/$/metrics` endpoint, that is already publicly available with the default configuration, so it should not be a problem to expose it as well.
