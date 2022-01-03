ARG OPENJDK_VERSION="16"
ARG ALPINE_VERSION="3.13"
ARG JENA_VERSION="4.3.2"
ARG OTEL_VERSION="1.2.0"

ARG FUSEKI_HOME="/opt/fuseki"
ARG FUSEKI_BASE="/fuseki"
ARG OTEL_JAR="opentelemetry-javaagent-all.jar"
ARG GEOSPARQL_JAR="jena-fuseki-geosparql-${JENA_VERSION}.jar"
ARG JAVA_MINIMAL="/opt/java-minimal"


FROM "openjdk:${OPENJDK_VERSION}-alpine${ALPINE_VERSION}" AS builder

ARG ALPINE_VERSION
ARG JENA_VERSION
ARG OTEL_VERSION

ARG FUSEKI_HOME
ARG FUSEKI_BASE
ARG OTEL_JAR
ARG GEOSPARQL_JAR
ARG JAVA_MINIMAL

RUN apk add --no-cache binutils maven patch

WORKDIR /build

# get source code for jena and build Fuseki GeoSPARQL
RUN wget "https://github.com/apache/jena/archive/refs/tags/jena-${JENA_VERSION}.zip" -O jena.zip \
  && unzip jena.zip && mv "jena-jena-${JENA_VERSION}" jena

WORKDIR /build/jena/jena-fuseki2/jena-fuseki-geosparql
COPY uniongraph.diff .
RUN patch -p3 < uniongraph.diff

RUN apk add --no-cache binutils

RUN mvn test
RUN mvn package -Dmaven.javadoc.skip=true
RUN mkdir -p "${FUSEKI_HOME}"
RUN mv "target/${GEOSPARQL_JAR}" "${FUSEKI_HOME}/"

WORKDIR "${FUSEKI_HOME}"

# add opentelemetry support
RUN wget "https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OTEL_VERSION}/${OTEL_JAR}"

ARG JDEPS_EXTRA="jdk.crypto.cryptoki,jdk.crypto.ec"
RUN \
  JDEPS="$(jdeps --multi-release base --print-module-deps --ignore-missing-deps ${OTEL_JAR} ${GEOSPARQL_JAR})" && \
  jlink \
  --compress 2 --strip-debug --no-header-files --no-man-pages \
  --output "${JAVA_MINIMAL}" \
  --add-modules "${JDEPS},${JDEPS_EXTRA}"


FROM "alpine:${ALPINE_VERSION}"

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
  JAVA_HOME=${JAVA_MINIMAL} \
  JAVA_OPTIONS="-Xmx2048m -Xms2048m" \
  JENA_VERSION=${JENA_VERSION} \
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
ENTRYPOINT [ "/opt/fuseki/entrypoint.sh" ]
CMD []
