#!/bin/sh

set -eu

DOCKER_BUILDKIT=1 docker-compose up -d --build
sleep 10
hurl --test *.hurl
docker-compose down
