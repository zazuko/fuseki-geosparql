#!/bin/sh

set -eu

# Wait until the /$/ping endpoint is available, with a timeout of 20 seconds
wait_for() {
  port=$1
  nb_attempts=0
  echo "Waiting for /$/ping to be available on port ${port}..."
  until curl -s "http://localhost:${port}/$/ping" > /dev/null; do
    nb_attempts=$((nb_attempts + 1))
    if [ $nb_attempts -ge 20 ]; then
      echo "Error: /$/ping is not available after 20 attempts (for port ${port})"
      exit 1
    fi
    sleep 1
  done
  echo "/$/ping is available on port ${port}"
}

docker compose pull
DOCKER_BUILDKIT=1 docker compose build
DOCKER_BUILDKIT=1 docker compose up -d

wait_for 3030
wait_for 3031

hurl --test *.hurl
docker compose down
