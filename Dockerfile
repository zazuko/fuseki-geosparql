ARG ALPINE_VERSION="3.15"
ARG JENA_VERSION="4.4.0"
ARG OTEL_VERSION="1.10.1"

ARG FUSEKI_HOME="/opt/fuseki"
ARG FUSEKI_BASE="/fuseki"
ARG OTEL_JAR="opentelemetry-javaagent.jar"
ARG GEOSPARQL_JAR="jena-fuseki-geosparql-${JENA_VERSION}.jar"
ARG JAVA_MINIMAL="/opt/java-minimal"
ARG JDEPS_EXTRA="jdk.crypto.cryptoki,jdk.crypto.ec"


FROM --platform=${BUILDPLATFORM} "docker.io/library/alpine:${ALPINE_VERSION}" AS builder

ARG ALPINE_VERSION
ARG JENA_VERSION
ARG OTEL_VERSION

ARG FUSEKI_HOME
ARG FUSEKI_BASE
ARG OTEL_JAR
ARG GEOSPARQL_JAR
ARG JAVA_MINIMAL
ARG JDEPS_EXTRA

RUN apk add --no-cache \
  binutils \
  maven \
  patch \
  binutils \
  openjdk16

WORKDIR /build

# get source code for jena and build Fuseki GeoSPARQL
RUN wget "https://github.com/apache/jena/archive/refs/tags/jena-${JENA_VERSION}.zip" -O jena.zip \
  && unzip jena.zip && mv "jena-jena-${JENA_VERSION}" jena

WORKDIR /build/jena/jena-fuseki2/jena-fuseki-geosparql
COPY uniongraph.diff .
RUN patch -p3 < uniongraph.diff

RUN mvn test
RUN mvn package -Dmaven.javadoc.skip=true
RUN mkdir -p "${FUSEKI_HOME}"
RUN mv "target/${GEOSPARQL_JAR}" "${FUSEKI_HOME}/"

WORKDIR "${FUSEKI_HOME}"

# add opentelemetry support
RUN wget "https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OTEL_VERSION}/${OTEL_JAR}"


RUN \
  JDEPS="$(jdeps --multi-release base --print-module-deps --ignore-missing-deps ${OTEL_JAR} ${GEOSPARQL_JAR})" && \
  jlink \
  --compress 2 --strip-debug --no-header-files --no-man-pages \
  --output "${JAVA_MINIMAL}" \
  --add-modules "${JDEPS},${JDEPS_EXTRA}"


FROM "docker.io/library/alpine:${ALPINE_VERSION}"

# install some required dependencies
RUN apk add --no-cache tini

ARG JENA_VERSION

ARG FUSEKI_HOME
ARG FUSEKI_BASE
ARG OTEL_JAR
ARG GEOSPARQL_JAR
ARG JAVA_MINIMAL

COPY --from=builder "${JAVA_MINIMAL}" "${JAVA_MINIMAL}"
COPY --from=builder "${FUSEKI_HOME}" "${FUSEKI_HOME}"

# Run as this user
# -H : no home directorry
# -D : no password
# -u : explicit UID
RUN adduser -H -D -u 1000 fuseki fuseki

RUN mkdir -p "${FUSEKI_BASE}/databases" \
  && chown -R fuseki "${FUSEKI_BASE}"

WORKDIR "${FUSEKI_HOME}"
COPY entrypoint.sh log4j2.properties ./

# Default environment variables
ENV \
  JAVA_HOME="${JAVA_MINIMAL}" \
  JAVA_OPTIONS="-Xmx2048m -Xms2048m" \
  JENA_VERSION="${JENA_VERSION}" \
  FUSEKI_HOME="${FUSEKI_HOME}" \
  FUSEKI_BASE="${FUSEKI_BASE}" \
  OTEL_JAR="${OTEL_JAR}" \
  GEOSPARQL_JAR="${GEOSPARQL_JAR}" \
  OTEL_TRACES_EXPORTER="none" \
  OTEL_METRICS_EXPORTER="none" \
  ENABLE_DEFAULT_GEOMETRY="true"

# run as "fuseki" (explicit UID so "run as non-root" policies can be enforced)
USER 1000
WORKDIR "${FUSEKI_BASE}"
EXPOSE 3030

# keep this path in sync with $FUSEKI_HOME since ENTRYPOINT does not do buildarg expansion
ENTRYPOINT [ "tini", "--", "/opt/fuseki/entrypoint.sh" ]
CMD []
