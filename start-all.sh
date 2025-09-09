#!/bin/bash

# Check for container runtime (Podman preferred, Docker fallback)
CONTAINER_RUNTIME=""
if command -v podman &> /dev/null; then
    CONTAINER_RUNTIME="podman"
    echo "✅ Using Podman for containers"
elif command -v docker &> /dev/null; then
    CONTAINER_RUNTIME="docker"
    echo "✅ Using Docker for containers"
else
    echo "❌ Neither Podman nor Docker is installed. Please install one to run Qdrant."
    echo "   Podman: https://podman.io/getting-started/installation"
    echo "   Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Start Qdrant if not already running
if [ "$CONTAINER_RUNTIME" = "podman" ]; then
    npm run start:qdrant:podman
else
    npm run start:qdrant
fi

# Create log directory if it doesn't exist
mkdir -p logs

# Function to stop container
function stop_container {
    echo "Stopping Qdrant $CONTAINER_RUNTIME container..."
    if [ "$CONTAINER_RUNTIME" = "podman" ]; then
        podman ps -q --filter 'ancestor=docker.io/qdrant/qdrant' | xargs -r podman stop
    else
        docker ps -q --filter 'ancestor=qdrant/qdrant' | xargs -r docker stop
    fi
    exit 0
}

# Trap SIGINT (Cmd + C) to stop container
trap stop_container SIGINT

# Set RUN_UI to true for local development with UI
export RUN_UI=true

# Start the unified server with UI
echo "Starting MCP Knowledge Graph Server with Dashboard..."
echo "Dashboard will be available at http://localhost:4000"
npm run start 