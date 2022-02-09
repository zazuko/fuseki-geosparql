# Fuseki with GeoSPARQL support

## Docker image

This Docker image is configured to have union graph enabled on tdb2 datasets.

You can pull the Docker image using:

```sh
docker pull ghcr.io/zazuko/fuseki-geosparql
```

It is listening on the 3030 port.

## Configuration

It is possible to use following environment variables for configuration:

- `ADMIN_PASSWORD` (default: `admin`), the password for the admin user
- `JAVA_OPTIONS` (default: `-Xmx2048m -Xms2048m`), allocate more resources by changing this values
