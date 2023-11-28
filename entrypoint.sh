#!/bin/sh

export OTEL_RESOURCE_ATTRIBUTES="container.id=$(hostname),${OTEL_RESOURCE_ATTRIBUTES}"

envsubst '$ADMIN_PASSWORD' \
  < "${FUSEKI_HOME}/shiro.ini" \
  > "${FUSEKI_BASE}/shiro.ini"

JAVA_AGENT="-javaagent:${FUSEKI_HOME}/otel.jar"

# Check if the environment variable DISABLE_OTEL is set to "true"
if [ "$DISABLE_OTEL" = "true" ]; then
  echo "Removing OpenTelemetry Java Agent…"
  JAVA_AGENT=""
fi

exec \
  "${JAVA_HOME}/bin/java" \
  ${JAVA_OPTS} \
  ${JAVA_AGENT} \
  -Xshare:off \
  -Dlog4j.configurationFile="${FUSEKI_HOME}/log4j2.properties" \
  -cp "${FUSEKI_HOME}/fuseki-server.jar" \
  org.apache.jena.fuseki.cmd.FusekiCmd
