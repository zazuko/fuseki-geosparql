# Manage tools versions
## Base components
ARG ALPINE_VERSION="3.22.2"
ARG MAVEN_VERSION="3.9.11"
## Apache projects
ARG JENA_VERSION="6.0.0"
ARG SIS_VERSION="1.4"
ARG DERBY_VERSION="10.17.1.0"
## Other components
ARG OTEL_VERSION="2.22.0"

# Configure some paths, names and args
ARG FUSEKI_HOME="/opt/fuseki"
ARG FUSEKI_BASE="/fuseki"
ARG OTEL_JAR="opentelemetry-javaagent.jar"


#################################
# Fuseki with GeoSPARQL support #
#################################
FROM --platform=${BUILDPLATFORM} "docker.io/library/maven:${MAVEN_VERSION}-eclipse-temurin-21" AS builder

ARG JENA_VERSION
ARG DERBY_VERSION
ARG SIS_VERSION
ARG OTEL_VERSION
ARG OTEL_JAR

WORKDIR /build

# Override versions in pom.xml and download required jars
COPY pom.xml .
RUN sed -i \
  -e "s|<jena.version>.*</jena.version>|<jena.version>${JENA_VERSION}</jena.version>|" \
  -e "s|<derby.version>.*</derby.version>|<derby.version>${DERBY_VERSION}</derby.version>|" \
  -e "s|<sis.version>.*</sis.version>|<sis.version>${SIS_VERSION}</sis.version>|" \
  pom.xml
RUN mvn dependency:copy-dependencies -DoutputDirectory=.
RUN wget \
  "https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OTEL_VERSION}/${OTEL_JAR}" \
  -O otel.jar

############################
# Build final Docker image #
############################
FROM "docker.io/library/alpine:${ALPINE_VERSION}"

# Install some required dependencies
RUN apk add --no-cache \
  ca-certificates \
  openjdk21-jre \
  gettext \
  tini

ARG FUSEKI_HOME
ARG FUSEKI_BASE
ARG SIS_VERSION

# Copy required files from builder stage
COPY --from=builder /build/*.jar "${FUSEKI_HOME}/"

# Run as this user
# -H: no home directorry
# -D: no password
# -u: explicit UID
RUN adduser -H -D -u 1000 fuseki fuseki

RUN mkdir -p "${FUSEKI_BASE}/databases" "${FUSEKI_BASE}/configuration" /opt/derby \
  && chown -R fuseki:fuseki "${FUSEKI_HOME}" "${FUSEKI_BASE}" "${FUSEKI_BASE}/configuration" /opt/derby

WORKDIR "${FUSEKI_HOME}"
COPY config/log4j2.properties config/shiro.ini entrypoint.sh ./
COPY config/config.ttl "${FUSEKI_BASE}/configuration/config.ttl"
RUN chmod +x entrypoint.sh && chown -R 1000:1000 .

# Default environment variables
ENV \
  JAVA_OPTS="-Xmx2048m -Xms2048m" \
  FUSEKI_HOME="${FUSEKI_HOME}" \
  FUSEKI_BASE="${FUSEKI_BASE}" \
  OTEL_TRACES_EXPORTER="none" \
  OTEL_METRICS_EXPORTER="none" \
  ADMIN_PASSWORD="admin" \
  DISABLE_OTEL="false" \
  SIS_DATA="/apache-sis/data" \
  SIS_OPTS="--encoding UTF-8"

# Run as "fuseki" (explicit UID so "run as non-root" policies can be enforced)
USER 1000
WORKDIR "${FUSEKI_BASE}"
EXPOSE 3030

# Keep this path in sync with $FUSEKI_HOME
CMD [ "tini", "--", "/opt/fuseki/entrypoint.sh" ]
