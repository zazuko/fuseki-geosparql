FROM openjdk:17-alpine

ARG JENA_VERSION="4.1.0"
RUN apk add --no-cache maven patch

WORKDIR /app

RUN wget "https://github.com/apache/jena/archive/refs/tags/jena-${JENA_VERSION}.zip" -O jena.zip \
  && unzip jena.zip && mv "jena-jena-${JENA_VERSION}" jena

WORKDIR /app/jena/jena-fuseki2/jena-fuseki-geosparql
COPY uniongraph.diff .
RUN patch -p3 < uniongraph.diff

RUN mvn test
RUN mvn package
