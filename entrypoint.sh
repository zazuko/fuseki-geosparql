#!/bin/sh

export OTEL_RESOURCE_ATTRIBUTES="container.id=$(hostname),${OTEL_RESOURCE_ATTRIBUTES}"

envsubst '$ADMIN_PASSWORD' \
  < "${FUSEKI_HOME}/shiro.ini" \
  > "${FUSEKI_BASE}/shiro.ini"

exec \
  "${JAVA_HOME}/bin/java" \
  ${JAVA_OPTS} \
  -javaagent:"${FUSEKI_HOME}/otel.jar" \
  -Xshare:off \
  -Dlog4j.configurationFile="${FUSEKI_HOME}/log4j2.properties" \
  -cp "${FUSEKI_HOME}/fuseki-server.jar" \
  org.apache.jena.fuseki.cmd.FusekiCmd
