# fuseki-geosparql

## 3.1.0

### Minor Changes

- c185675: Upgrade Apache Jena to 4.10.0

### Patch Changes

- 6237906: Upgrade various components in the Docker image:

  - Alpine to 3.18.4
  - Maven to 3.9.5 (only at `builder` stage)
  - OpenTelemetry Java instrumentation to 1.31.0

## 3.0.0

### Major Changes

- bd23ac8: Require to be authenticated for endpoints with write access.

  Starting this version, all routes that are ending with:

  - `/data`
  - `/upload`
  - `/update`

  are also protected and require authentication.

## 2.3.1

### Patch Changes

- 5ff6c99: Add v prefix in Docker image tags

## 2.3.0

### Minor Changes

- c07c73c: Upgrade Apache Jena to 4.9.0

### Patch Changes

- c07c73c: Improve the release process
