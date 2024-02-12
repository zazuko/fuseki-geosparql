# manage tools versions
ARG ALPINE_VERSION="3.19.1"
ARG JENA_VERSION="4.10.0"
ARG OTEL_VERSION="1.32.1"
ARG MAVEN_VERSION="3.9.5"
ARG APACHE_SIS_VERSION="1.4"
ARG DERBY_VERSION="10.17.1.0"

# configure some paths, names and args
ARG FUSEKI_HOME="/opt/fuseki"
ARG FUSEKI_BASE="/fuseki"
ARG OTEL_JAR="opentelemetry-javaagent.jar"
ARG JAVA_MINIMAL="/opt/java-minimal"
ARG JDEPS_EXTRA="jdk.crypto.cryptoki,jdk.crypto.ec,jdk.httpserver"


###########################################################
# Build Fuseki from sources and include GeoSPARQL support #
###########################################################
FROM --platform=${BUILDPLATFORM} "docker.io/library/maven:${MAVEN_VERSION}-eclipse-temurin-17" AS builder
ARG JENA_VERSION
ARG OTEL_VERSION
ARG FUSEKI_HOME
ARG OTEL_JAR

WORKDIR /build

# install some dependencies
RUN apt-get update && apt-get install -y \
  patch \
  unzip \
  wget

# get source code for Apache Jena
RUN wget "https://github.com/apache/jena/archive/refs/tags/jena-${JENA_VERSION}.zip" -O jena.zip \
  && unzip jena.zip && mv "jena-jena-${JENA_VERSION}" jena

# then build using GeoSPARQL support
WORKDIR /build/jena
COPY patches/enable-geosparql.diff .
RUN patch -p1 < enable-geosparql.diff
WORKDIR /build/jena/jena-fuseki2
RUN mvn package -Dmaven.javadoc.skip=true -DskipTests

RUN unzip "/build/jena/jena-fuseki2/apache-jena-fuseki/target/apache-jena-fuseki-${JENA_VERSION}.zip" \
  && mkdir -p "${FUSEKI_HOME}" \
  && cd "apache-jena-fuseki-${JENA_VERSION}" \
  && find ./ -maxdepth 1 -mindepth 1 -exec mv -t "${FUSEKI_HOME}" {} + \
  && cd .. \
  && rm -rf "apache-jena-fuseki-${JENA_VERSION}"

WORKDIR "${FUSEKI_HOME}"

# add opentelemetry support
RUN wget \
  "https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OTEL_VERSION}/${OTEL_JAR}" \
  -O otel.jar

# figure out JDEPS
RUN jdeps \
  --multi-release base \
  --print-module-deps \
  --ignore-missing-deps \
  fuseki-server.jar otel.jar \
  > /tmp/jdeps


#############################################################
# Generate all depedencies depending on the target platform #
#############################################################
FROM --platform=${TARGETPLATFORM} "docker.io/library/alpine:${ALPINE_VERSION}" as deps
ARG FUSEKI_HOME
ARG JAVA_MINIMAL
ARG JDEPS_EXTRA

WORKDIR "${FUSEKI_HOME}"
RUN apk add --no-cache openjdk16

COPY --from=builder "${FUSEKI_HOME}" "${FUSEKI_HOME}"
COPY --from=builder /tmp/jdeps /tmp/jdeps

RUN \
  jlink \
  --compress 2 --no-header-files --no-man-pages \
  --output "${JAVA_MINIMAL}" \
  --add-modules "$(cat /tmp/jdeps),${JDEPS_EXTRA}"


############################
# Build final Docker image #
############################
FROM --platform=${TARGETPLATFORM} "docker.io/library/alpine:${ALPINE_VERSION}"

# install some required dependencies
RUN apk add --no-cache \
  ca-certificates \
  gettext

ARG JENA_VERSION
ARG FUSEKI_HOME
ARG FUSEKI_BASE
ARG JAVA_MINIMAL
ARG APACHE_SIS_VERSION
ARG DERBY_VERSION

COPY --from=deps "${JAVA_MINIMAL}" "${JAVA_MINIMAL}"
COPY --from=deps "${FUSEKI_HOME}" "${FUSEKI_HOME}"

# Run as this user
# -H: no home directorry
# -D: no password
# -u: explicit UID
RUN adduser -H -D -u 1000 fuseki fuseki

RUN mkdir -p "${FUSEKI_BASE}/databases" \
  && chown -R fuseki "${FUSEKI_BASE}"

WORKDIR "${FUSEKI_HOME}"
COPY config/log4j2.properties config/shiro.ini entrypoint.sh ./
COPY config/config.ttl "${FUSEKI_BASE}"
RUN chmod +x entrypoint.sh

# Add Apache SIS
RUN wget "http://archive.apache.org/dist/sis/${APACHE_SIS_VERSION}/apache-sis-${APACHE_SIS_VERSION}-bin.zip" -O /tmp/apache-sis.zip \
  && cd /tmp/ \
  && unzip apache-sis.zip \
  && mv "/tmp/apache-sis-${APACHE_SIS_VERSION}/" /apache-sis \
  && chown -R 1000:1000 /apache-sis \
  && rm -f /tmp/apache-sis.zip

# Add Apache Derby
RUN cd /apache-sis/lib \
  && wget "https://repo1.maven.org/maven2/org/apache/derby/derby/${DERBY_VERSION}/derby-${DERBY_VERSION}.jar" \
  -O "derby-${DERBY_VERSION}.jar"

# default environment variables
ENV \
  JAVA_HOME="${JAVA_MINIMAL}" \
  JAVA_OPTS="-Xmx2048m -Xms2048m" \
  JENA_VERSION="${JENA_VERSION}" \
  FUSEKI_HOME="${FUSEKI_HOME}" \
  FUSEKI_BASE="${FUSEKI_BASE}" \
  OTEL_TRACES_EXPORTER="none" \
  OTEL_METRICS_EXPORTER="none" \
  ADMIN_PASSWORD="admin" \
  DISABLE_OTEL="false" \
  PATH="/apache-sis/bin:${JAVA_HOME}/bin:${PATH}" \
  SIS_DATA="/apache-sis/data" \
  SIS_OPTS="--encoding UTF-8"

# run as "fuseki" (explicit UID so "run as non-root" policies can be enforced)
USER 1000
WORKDIR "${FUSEKI_BASE}"
EXPOSE 3030

# keep this path in sync with $FUSEKI_HOME
CMD [ "/opt/fuseki/entrypoint.sh" ]
