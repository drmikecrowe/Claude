# Setup Troubleshooting Guide

This guide addresses common issues encountered during setup, based on real user experiences.

## Initial Setup Issues

### 1. Missing Environment File
**Problem:** Application fails to start due to missing `.env.local`

**Solution:**
```bash
# Create .env.local manually if no example exists
cat > .env.local << 'EOF'
QDRANT_URL=http://localhost:6333
OPENAI_API_KEY=your_openai_api_key_here
NODE_ENV=development
UI_API_PORT=4000
EOF
```

### 2. Build Dependencies Not Met
**Problem:** `npm run preparepackage` fails or scripts don't exist

**Solution:**
1. Always run `npm install` first
2. Check available scripts: `jq .scripts package.json`
3. Build in correct order:
   ```bash
   npm install
   npm run build:server  # TypeScript compilation
   npm run build         # Next.js build
   ```

## Container Runtime Issues

### 3. Podman vs Docker Configuration
**Problem:** Qdrant container binding issues or container not accessible

**Podman (Recommended):**
```bash
# Correct binding to localhost
podman run -d --name qdrant \
  -p 127.0.0.1:6333:6333 \
  -p 127.0.0.1:6334:6334 \
  -v ./qdrant_storage:/qdrant/storage:z \
  docker.io/qdrant/qdrant
```

**Docker (Alternative):**
```bash
docker run -d -p 6333:6333 -p 6334:6334 \
  -v ./qdrant_storage:/qdrant/storage:z \
  qdrant/qdrant
```

### 4. Container Permission Issues
**Problem:** Volume mount failures or permission denied

**Solutions:**
- Add `:z` flag to volume mounts for SELinux systems
- Create storage directory first: `mkdir -p qdrant_storage`
- Check container logs: `podman logs [container-name]`

## Network and Port Issues

### 5. Port Conflicts
**Problem:** Port 6333 or 4000 already in use

**Check ports:**
```bash
sudo netstat -lnpt | grep 6333
sudo netstat -lnpt | grep 4000
```

**Solutions:**
- Stop conflicting services
- Change `UI_API_PORT` in `.env.local`
- For Qdrant, stop existing container: `podman stop qdrant && podman rm qdrant`

### 6. Qdrant Health Check Failures
**Problem:** Application can't connect to Qdrant

**Diagnostics:**
```bash
# Check if Qdrant is running
curl -s http://localhost:6333/health

# Alternative check
curl -4 -v http://127.0.0.1:6333/

# Check container status
podman ps
podman logs qdrant
```

## Script and Command Issues

### 7. Script Execution Problems
**Problem:** `npm run start:all` or other scripts fail

**Common fixes:**
- Ensure `start-all.sh` is executable: `chmod +x start-all.sh`
- Use `bash` explicitly: `bash start-all.sh` 
- Check script dependencies are met
- Run setup first: `npm run setup` or `bash setup.sh`

### 8. Build Process Issues
**Problem:** TypeScript compilation or Next.js build failures

**Sequential build approach:**
```bash
# Step-by-step build process
npm install                    # Dependencies
npm run build:server         # TypeScript
npm run build                # Next.js
```

**Alternative combined build:**
```bash
npm run preparepackage       # Runs both builds
```

## Authentication and API Issues

### 9. OpenAI API Key Problems
**Problem:** Embedding generation fails

**Solutions:**
- Verify API key format starts with `sk-`
- Test API key independently
- Check OpenAI account usage/limits
- Ensure key has required permissions

### 10. 1Password CLI Integration
**Note:** Some users may use `op run` for secure environment variables

**Usage pattern from history:**
```bash
op run npm -- run start:prod
op run podman -- run [podman-command]
```

## Advanced Troubleshooting

### Container Management
```bash
# Stop all Qdrant containers
podman ps -q --filter 'ancestor=docker.io/qdrant/qdrant' | xargs -r podman stop

# Remove stopped containers
podman container prune

# Check container resource usage
podman stats qdrant
```

### Log Analysis
```bash
# Application logs
tail -f logs/application.log   # If exists

# Container logs
podman logs --tail 20 qdrant

# System logs for container issues
journalctl -u podman --since "1 hour ago"
```

### Network Debugging
```bash
# Test Qdrant connectivity
telnet localhost 6333
nc -zv localhost 6333

# Check network interfaces
ip addr show
```

## Workflow Summary

Based on successful user experience, the working setup flow is:

1. `npm install`
2. Create/edit `.env.local` with proper configuration
3. Run `npm run setup` (or manual setup steps)
4. Verify Qdrant health: `curl -s http://localhost:6333/health`
5. Start application: `npm run start:all` or `npm run start:prod`

## When All Else Fails

1. **Clean slate approach:**
   ```bash
   # Stop and remove containers
   podman stop qdrant && podman rm qdrant
   
   # Clean build artifacts
   rm -rf dist .next node_modules
   
   # Fresh install
   npm install
   npm run setup
   ```

2. **Check system requirements:**
   - Node.js 18+
   - Podman or Docker installed and running
   - Sufficient disk space for Qdrant storage
   - Network access for npm packages and OpenAI API

3. **Verify file permissions:**
   - Ensure shell scripts are executable
   - Check write permissions for qdrant_storage directory
   - Verify .env.local is readable by Node.js process
