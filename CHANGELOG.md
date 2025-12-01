# fuseki-geosparql

## 4.0.0

### Major Changes

- 428b22a: Upgrade Apache Jena to 5.6.

  #### Breaking changes

  Please read the following points to update your setup accordingly, as your setup might be impacted by these changes:

  - The `[main]` section in `shiro.ini` should contain the following lines:

    ```
    statelessSessionManager = org.apache.shiro.web.session.mgt.DefaultWebSessionManager
    securityManager.sessionManager = $statelessSessionManager
    ```

  - In case you are not using the default entrypoint script, you might need to update the way the Fuseki server is started. The class to use is now `org.apache.jena.fuseki.main.cmds.FusekiServerCmd` instead of `org.apache.jena.fuseki.cmd.FusekiCmd`, and update some argument accordingly.
  - The Fuseki configuration file should be mounted at `/fuseki/configuration/config.ttl` instead of `/fuseki/config.ttl`.

### Minor Changes

- 428b22a: Updated OpenTelemetry Java instrumentation to version 2.22.0
- 428b22a: Upgraded Alpine base image to 3.22.2

## 3.3.1

### Patch Changes

- 56cff42: Upgrade OTEL to 1.32.1
- ea1e00f: Rename default environment variable `JAVA_OPTIONS` to `JAVA_OPTS`
- 321e2dd: Upgrade Alpine to 3.19.1

## 3.3.0

### Minor Changes

- a64353f: Include Apache SIS in the Docker image

## 3.2.0

### Minor Changes

- 9b9510e: OpenTelemetry support can be disabled by configuring the `DISABLE_OTEL` environment variable to `true`.

### Patch Changes

- 5bbdc79: Upgrade OpenTelemetry Instrumentation for Java to 1.32.0

## 3.1.1

### Patch Changes

- aa583ff: Improve formatting of default configuration file

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
