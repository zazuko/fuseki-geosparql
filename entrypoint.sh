#!/bin/sh

export OTEL_RESOURCE_ATTRIBUTES="container.id=$(hostname),${OTEL_RESOURCE_ATTRIBUTES}"

exec "$JAVA_HOME/bin/java" \
  $JAVA_OPTIONS \
  -javaagent:"${FUSEKI_HOME}/${OTEL_JAR}" \
  -Xshare:off \
  -Dlog4j.configurationFile="file:${FUSEKI_HOME}/log4j2.properties" \
  -jar "${FUSEKI_HOME}/${GEOSPARQL_JAR}" \
  --loopback false \
  -t "${FUSEKI_BASE}/databases/ds" \
  -t2 \
  --default_geometry \
  --validate \
  "$@"

  # --inference \
