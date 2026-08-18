---
"fuseki-geosparql": minor
---

Upgrade Apache Jena to 6.2.0

#### Behaviour change: `geof:distance`

Apache Jena 6.2.0 changed `geof:distance` to compute a geodesic distance, instead
of a Euclidean distance expressed in the units of the SRS.

For geometries in a geographic SRS, such as `CRS84` or `EPSG:4326`:

- Linear units now return a proper distance, where the result was previously left
  unbound. `geof:distance(?a, ?b, uom:metre)` works from now on.
- Angular units (`uom:degree`, `uom:radian`) now leave the result unbound, as a
  geodesic distance cannot be expressed in them. Queries relying on those need to
  ask for a linear unit instead.

Geometries in a projected SRS, such as `EPSG:2056`, are not affected.
