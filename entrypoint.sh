#!/bin/sh

export OTEL_RESOURCE_ATTRIBUTES="container.id=$(hostname),${OTEL_RESOURCE_ATTRIBUTES}"

cp "${FUSEKI_HOME}/shiro.ini" "${FUSEKI_BASE}"

/opt/fuseki/fuseki-server
