# Fuseki HTTP Administration Protocol

More details: https://jena.apache.org/documentation/fuseki2/fuseki-server-protocol.html

Here are some information that will certainly help you to get started with the Fuseki HTTP Administration Protocol.

## Start a Fuseki instance

Start Fuseki with GeoSPARQL support using the following command:

```sh
docker run --rm -p3030:3030 -it ghcr.io/zazuko/fuseki-geosparql:latest
```

This will expose Fuseki to the 3030 port.

## Note about permissions

Administrator tasks require credentials if you are using the default configuration.
Default credentials are: `admin` / `admin`.

You can use the `-u` option of `curl` to send credentials.

If you try to perform restricted requests without sending the right credentials, you will get something like this:

```sh
> curl -v http://localhost:3030/$/datasets

*   Trying ::1:3030...
* Connected to localhost (::1) port 3030 (#0)
> GET /$/datasets HTTP/1.1
> Host: localhost:3030
> User-Agent: curl/7.77.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 401 Unauthorized
< Date: Wed, 16 Feb 2022 21:00:36 GMT
< WWW-Authenticate: BASIC realm="application"
< Content-Length: 0
<
* Connection #0 to host localhost left intact
```

Note the `401 Unauthorized` in the response headers.

We are using the `-v` option from `curl` to inspect the response headers, because without it you will only see an empty response.

## Fetch datasets

By default, the Docker image creates a dataset named `ds`.

So if we run the previous request by adding credentials, we should get this:

```sh
> curl -u admin:admin 'http://localhost:3030/$/datasets'

{
  "datasets" : [
      {
        "ds.name" : "/ds" ,
        "ds.state" : true ,
        "ds.services" : [
            {
              "srv.type" : "gsp-r" ,
              "srv.description" : "Graph Store Protocol (Read)" ,
              "srv.endpoints" : [
                  "get" ,
                  ""
                ]
            } ,
            {
              "srv.type" : "query" ,
              "srv.description" : "SPARQL Query" ,
              "srv.endpoints" : [
                  "query" ,
                  "sparql" ,
                  ""
                ]
            }
          ]
      }
    ]
}
```

## Create a new dataset

The only way to create a GeoSPARQL dataset will be to configure it directly in the `config.ttl` file.
All other methods are only working for non-GeoSPARQL datasets.

### Using the web interface

You can create a new dataset directly from the UI: http://localhost:3030/#/manage/new
But the created datasets will not support GeoSPARQL.

### Using a simple POST request

If you create the dataset using the following command, you will also have the same issue:

```sh
curl -u admin:admin 'http://localhost:3030/$/datasets' \
  -X POST \
  --data-raw 'dbName=test&dbType=tdb2'
```

the dataset will be created, but it will not support GeoSPARQL.

It's basically the same request that is triggered using the web UI.

### Using an assembly file

Older Apache Jena releases allowed creating a dataset by sending an assembler file (Turtle) to `$/datasets`.
This feature was disabled by default in Apache Jena 5.5.0, and has been removed in Apache Jena 6.3.0.

Such a request is now rejected with a `400 Bad Request` status and the following message:

> Service configuration from an upload file not supported

This applies to all datasets, with or without GeoSPARQL support.

## Delete a dataset

To delete the datasets (`test` and `classical`) we created, you can run the following commands:

```sh
curl -u admin:admin -X DELETE 'http://localhost:3030/$/datasets/test'
curl -u admin:admin -X DELETE 'http://localhost:3030/$/datasets/classical'
```

## Changing the state of a dataset

We can take a dataset (let's say our default `ds` dataset) offline using this command:

```sh
curl -u admin:admin -X POST 'http://localhost:3030/$/datasets/ds?state=offline'
```

And take it back online using the following command:

```sh
curl -u admin:admin -X POST 'http://localhost:3030/$/datasets/ds?state=active'
```

## Conclusions

GeoSPARQL support is something new on Fuseki, and the support for the GeoSPARQL assembler for the initial configuration (our `config.ttl` file) only came in the 4.4.0 release of Apache Jena.
The Fuseki HTTP Administration Protocol does not support creating GeoSPARQL datasets, and the assembler file upload it previously offered has been removed in Apache Jena 6.3.0.

So currently the only way to create datasets with GeoSPARQL support would be to edit the `config.ttl` file, and restart the Fuseki instance.

Since it's running in a Docker container, you can easilly mount a custom `config.ttl` file at `/fuseki/configuration/config.ttl`.
