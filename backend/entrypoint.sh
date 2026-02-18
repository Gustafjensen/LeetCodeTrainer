#!/bin/sh
set -e

echo "Starting Docker daemon..."
dockerd &

echo "Waiting for Docker daemon..."
for i in $(seq 1 30); do
    if docker info > /dev/null 2>&1; then
        echo "Docker daemon is ready."
        break
    fi
    sleep 1
done

echo "Building Python sandbox image..."
docker build -t leetcode-python-sandbox -f /app/runner/Dockerfile.python /app/runner/

echo "Starting Node.js application..."
exec node /app/server.js
