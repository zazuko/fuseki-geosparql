#!/bin/sh

set -eu

docker-compose up -d --build
sleep 5
hurl --test *.hurl
docker-compose down
