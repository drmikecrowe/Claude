# Quick Start Guide for MCP Knowledge Graph

## Prerequisites
- Node.js 18+
- Docker
- OpenAI API key (optional, but recommended for semantic search)

## Setup (5 minutes)

1. **Clone and install:**
   ```bash
   git clone <your-repo>
   cd mcp-knowledge-graph
   npm install
   ```

2. **Setup environment:**
   Create `.env.local` file (copy from `.env.local.example` if available):
   ```env
   QDRANT_URL=http://localhost:6333
   OPENAI_API_KEY=sk-your-actual-key-here
   NODE_ENV=development
   UI_API_PORT=4000
   ```

3. **Run automated setup:**
   ```bash
   npm run setup
   ```
   This will build the application and start Qdrant database.

4. **Start the server:**
   ```bash
   npm run start:all
   ```

5. **Access the dashboard:**
   Open http://localhost:4000 in your browser

## Using with Claude Desktop (No Port Conflicts!)

Add to your Claude Desktop config:

```json
{
  "mcpServers": {
    "knowledge-graph": {
      "command": "node",
      "args": ["/absolute/path/to/mcp-only.js"],
      "cwd": "/absolute/path/to/mcp-knowledge-graph",
      "env": {
        "NODE_ENV": "production",
        "OPENAI_API_KEY": "your-key-here"
      }
    }
  }
}
```

## Using with Cursor

See [MCP_CLIENT_CONFIGS.md](MCP_CLIENT_CONFIGS.md) for Cursor and other client configurations.

## Troubleshooting

Run diagnostics:
```bash
npm run diagnose
```

Common issues and solutions:

**Qdrant Connection Issues:**
- If using Podman, ensure container binds to 127.0.0.1:
  ```bash
  podman run -d --name qdrant -p 127.0.0.1:6333:6333 -p 127.0.0.1:6334:6334 -v ./qdrant_storage:/qdrant/storage:z docker.io/qdrant/qdrant
  ```
- Check Qdrant health: `curl -s http://localhost:6333/health`
- Check running containers: `podman ps` or `docker ps`

**Build Issues:**
- Run `npm run preparepackage` before starting
- Ensure TypeScript builds successfully: `npm run build:server`
- For permission issues with volumes, add `:z` flag to volume mounts

**Environment Setup:**
- **Port in use**: Change `UI_API_PORT` in `.env.local`
- **Missing .env.local**: Copy from `.env.local.example` if available
- **No embeddings**: Add valid OpenAI API key to `.env.local`

## Example Usage

1. **Create a project:**
   - Click "New Project" in the dashboard
   - Or use MCP: `create_project project_id:"my-project" name:"My Project"`

2. **Add entities:**
   ```
   create_entity project_id:"my-project" name:"User Model" type:"class" description:"Main user data model"
   ```

3. **Create relationships:**
   ```
   create_relationship project_id:"my-project" source_id:"entity-1" target_id:"entity-2" type:"uses"
   ```

4. **Search semantically:**
   ```
   vector_search project_id:"my-project" query:"authentication components" limit:5
   ```

## Features

- 📊 **Visual Dashboard**: Interactive knowledge graph visualization
- 🤖 **AI Integration**: Natural language queries and smart suggestions
- 🔍 **Vector Search**: Semantic search powered by OpenAI embeddings
- 💬 **Context Intelligence**: Conversation memory and session management
- 🎯 **Multi-Project**: Organize knowledge into separate projects
- 🔧 **MCP Tools**: Full suite of knowledge graph management tools

## Next Steps

- Explore the dashboard at http://localhost:4000
- Try the natural language query interface
- Check out the [full documentation](README.md)
- View [implementation status](IMPLEMENTATION_STATUS.md)
