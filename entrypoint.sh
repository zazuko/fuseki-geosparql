#!/bin/sh

export OTEL_RESOURCE_ATTRIBUTES="container.id=$(hostname),${OTEL_RESOURCE_ATTRIBUTES}"

envsubst '$ADMIN_PASSWORD' \
  < "${FUSEKI_HOME}/shiro.ini" \
  > "${FUSEKI_BASE}/shiro.ini"

/opt/fuseki/fuseki-server
