#!/bin/bash
set -e

# Set default values if environment variables are not set
POSTGRES_HOST=${POSTGRES_HOST:-postgres}
POSTGRES_PORT=${POSTGRES_PORT:-5432}

# Wait for Postgres to start before doing anything
echo ""
echo "== ⏱  Waiting for Postgres before running: $@ =="
echo "== 🔌 Connecting to ${POSTGRES_HOST}:${POSTGRES_PORT} =="
dockerize -wait tcp://${POSTGRES_HOST}:${POSTGRES_PORT} -timeout 60s -wait-retry-interval 5s

# Then exec the container's main process (what's set as CMD in the Dockerfile).
echo ""
echo "== 🏎  Running: $@ =="
exec "$@"
