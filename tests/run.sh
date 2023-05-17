#!/bin/sh

set -eu

DOCKER_BUILDKIT=1 docker-compose build
DOCKER_BUILDKIT=1 docker-compose up -d
sleep 10
hurl --test *.hurl
docker-compose down
