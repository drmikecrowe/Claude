#!/bin/bash

echo "🚀 MCP Knowledge Graph Server Setup"
echo "=================================="

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

echo "✅ Node.js $(node --version) detected"

# Check for container runtime (Podman preferred, Docker fallback)
CONTAINER_RUNTIME=""
if command -v podman &> /dev/null; then
    CONTAINER_RUNTIME="podman"
    echo "✅ Podman detected"
elif command -v docker &> /dev/null; then
    CONTAINER_RUNTIME="docker"
    echo "✅ Docker detected"
else
    echo "❌ Neither Podman nor Docker is installed. Please install one to run Qdrant."
    echo "   Podman: https://podman.io/getting-started/installation"
    echo "   Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if .env.local exists
if [ ! -f .env.local ]; then
    echo "📝 Creating .env.local from template..."
    cp .env.local.example .env.local
    echo "⚠️  Please edit .env.local and add your OpenAI API key"
else
    echo "✅ .env.local exists"
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Build the server
echo "🔨 Building TypeScript..."
npm run build:server

# Check if Qdrant is running
echo "🔍 Checking Qdrant status..."
if ! curl -s http://localhost:6333/health > /dev/null 2>&1; then
    echo "🐳 Starting Qdrant with $CONTAINER_RUNTIME..."
    if [ "$CONTAINER_RUNTIME" = "podman" ]; then
        npm run start:qdrant:podman
    else
        npm run start:qdrant
    fi
    sleep 5
else
    echo "✅ Qdrant is already running"
fi

# Build Next.js
echo "🏗️  Building Next.js..."
npm run build

echo ""
echo "✅ Setup complete!"
echo ""
echo "To start the server:"
echo "  npm run start:all    # Development mode with UI"
echo "  npm run start:prod   # Production mode"
echo ""
echo "To use with Claude Desktop, add to your config:"
echo '  {
    "mcpServers": {
      "knowledge-graph": {
        "command": "node",
        "args": ["'$(pwd)'/dist/standalone-server.js"],
        "cwd": "'$(pwd)'",
        "env": {
          "NODE_ENV": "production",
          "OPENAI_API_KEY": "your_key_here"
        }
      }
    }
  }'
