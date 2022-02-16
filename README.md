# Fuseki with GeoSPARQL support

## Docker image

This Docker image is configured to have GeoSPARQL support.

You can run the Docker image using:

```sh
docker run --rm -p3030:3030 -it ghcr.io/zazuko/fuseki-geosparql
```

It is listening on the 3030 port, so you should be able to access the web interface using: http://localhost:3030.

## Configuration

It is possible to use the following environment variables for configuration:

- `ADMIN_PASSWORD` (default: `admin`), the password for the admin user
- `JAVA_OPTIONS` (default: `-Xmx2048m -Xms2048m`), allocate more resources by changing this values

Feel free to edit the `config/config.ttl` file before building this image.
For information, this file will be mounted at the following path in the container: `/fuseki/config.ttl`.

## Routes

Here are some default routes, publicly available:

- `/$/status`: get Fuseki's status
- `/$/server`: get Fuseki's status
- `/$/ping`: health check endpoint
- `/$/metrics`: some Prometheus metrics

All other routes that have are prefixed with `/$/` needs basic authentication:

- username: `admin`
- password: value of the `ADMIN_PASSWORD` environment variable

All other routes are publicly available.

If you want to change this behavior, you will need to change the `config/shiro.ini` file.
It will be mounted at this location: `/opt/fuseki/shiro.ini`.
When the container is starting, the value for `ADMIN_PASSWORD` will be set, and the final file would be created at `/fuseki/shiro.ini`.

## Dataset

A dataset `ds` is already configured in the `config/config.ttl` file.
It's a read-only dataset, with union graph and GeoSPARQL enabled.
Feel free to update this file for your needs.

This dataset is stored at `/fuseki/databases/ds`.
If you want to persist this dataset, you can mount `/fuseki/databases/` as a volume.

If your dataset is huge, you may be interested in generating the spatial index file before starting the Fuseki instance.
You can have a look at this tool: https://github.com/zazuko/spatial-indexer.
