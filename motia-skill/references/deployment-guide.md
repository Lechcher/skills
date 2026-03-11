# Motia Deployment Guide

## Production Checklist

Before deploying to production:
- [ ] Swap `BuiltinQueueAdapter` → `RedisAdapter` in config.yaml
- [ ] Swap `KvStore` (state & stream) → `RedisAdapter` in config.yaml
- [ ] Swap `LocalAdapter` (pubsub) → `RedisAdapter` in config.yaml
- [ ] Set all env vars: `REDIS_URL`, `PORT`, etc.
- [ ] Build production bundle: `npx motia build`
- [ ] Configure CORS `allowed_origins` to your frontend domain

---

## Docker Deployment

The iii engine is the Docker entrypoint. Your Motia application runs as a child process.

### Dockerfile

```dockerfile
FROM node:20-alpine

WORKDIR /app

# Install iii engine
RUN npm install -g iii

# Copy and install dependencies
COPY package*.json ./
RUN npm ci --production

# Copy application code and config
COPY . .

# Build production bundle
RUN npx motia build

# Expose ports
EXPOSE 3111 3112

# iii is the entrypoint — it runs your app and manages infrastructure
CMD ["iii", "start", "--config", "config.yaml"]
```

### docker-compose.yml (with Redis)

```yaml
version: '3.9'

services:
  app:
    build: .
    ports:
      - "3111:3111"   # HTTP API
      - "3112:3112"   # WebSocket streams
    environment:
      - REDIS_URL=redis://redis:6379
      - PORT=3111
      - NODE_ENV=production
    depends_on:
      redis:
        condition: service_healthy
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 10
    restart: unless-stopped

volumes:
  redis_data:
```

### Production config.yaml (Docker)

```yaml
modules:
  - class: modules::api::RestApiModule
    config:
      port: "${PORT:3111}"
      host: 0.0.0.0
      cors:
        allowed_origins:
          - "${FRONTEND_URL:https://yourapp.com}"

  - class: modules::queue::QueueModule
    config:
      adapter:
        class: modules::queue::RedisAdapter
        config:
          redis_url: "${REDIS_URL}"

  - class: modules::state::StateModule
    config:
      adapter:
        class: modules::state::adapters::RedisAdapter
        config:
          redis_url: "${REDIS_URL}"

  - class: modules::stream::StreamModule
    config:
      port: "${STREAM_PORT:3112}"
      host: 0.0.0.0
      adapter:
        class: modules::stream::adapters::RedisAdapter
        config:
          redis_url: "${REDIS_URL}"

  - class: modules::pubsub::PubSubModule
    config:
      adapter:
        class: modules::pubsub::RedisAdapter
        config:
          redis_url: "${REDIS_URL}"

  - class: modules::cron::CronModule
    config:
      adapter:
        class: modules::cron::KvCronAdapter

  - class: modules::shell::ExecModule
    config:
      exec:
        - node dist/server.js
```

---

## Railway Deployment

Railway provides managed Redis — the simplest production path for Motia.

### Steps

1. **Install Railway CLI:**
   ```bash
   npm install -g @railway/cli
   railway login
   ```

2. **Initialize project:**
   ```bash
   cd your-motia-project
   railway init
   ```

3. **Add Redis service:**
   ```bash
   railway add --plugin redis
   ```

   Railway auto-sets `REDIS_URL` in your environment.

4. **Set environment variables:**
   ```bash
   railway variables set PORT=3111
   railway variables set STREAM_PORT=3112
   railway variables set NODE_ENV=production
   railway variables set FRONTEND_URL=https://yourapp.com
   ```

5. **Create railway.json:**
   ```json
   {
     "build": {
       "builder": "NIXPACKS"
     },
     "deploy": {
       "startCommand": "iii start --config config.yaml",
       "healthcheckPath": "/health",
       "healthcheckTimeout": 30
     }
   }
   ```

6. **Deploy:**
   ```bash
   railway up
   ```

7. **Add health check endpoint** (recommended):
   ```typescript
   // src/health.step.ts
   export const config = {
     name: 'HealthCheck',
     triggers: [{ type: 'http', method: 'GET', path: '/health' }],
     enqueues: [],
     flows: [],
   } as const satisfies StepConfig

   export const handler = async () => ({
     status: 200,
     body: { status: 'ok', timestamp: new Date().toISOString() },
   })
   ```

---

## Fly.io Deployment (Global Edge)

Fly.io with Upstash Redis (serverless Redis — great for global distribution).

### fly.toml

```toml
app = "my-motia-app"
primary_region = "iad"

[build]
  dockerfile = "Dockerfile"

[env]
  PORT = "3111"
  STREAM_PORT = "3112"
  NODE_ENV = "production"

[[services]]
  internal_port = 3111
  protocol = "tcp"

  [[services.ports]]
    port = 80
    handlers = ["http"]
  [[services.ports]]
    port = 443
    handlers = ["tls", "http"]

  [services.concurrency]
    type = "connections"
    hard_limit = 500
    soft_limit = 200

[[services]]
  internal_port = 3112
  protocol = "tcp"

  [[services.ports]]
    port = 3112
    handlers = ["tls"]
```

### Deploy steps

```bash
# Install Fly CLI
curl -L https://fly.io/install.sh | sh

# Authenticate
fly auth login

# Create app
fly apps create my-motia-app

# Set secrets (Upstash Redis URL from upstash.com)
fly secrets set REDIS_URL="redis://default:TOKEN@host.upstash.io:6379"
fly secrets set FRONTEND_URL="https://yourapp.com"

# Deploy
fly deploy
```

---

## Environment Variables Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `PORT` | No | `3111` | HTTP API port |
| `STREAM_PORT` | No | `3112` | WebSocket stream port |
| `REDIS_URL` | Production | — | Redis connection string |
| `RABBITMQ_URL` | Optional | — | RabbitMQ connection string |
| `FRONTEND_URL` | No | `*` | CORS allowed origin |
| `NODE_ENV` | No | `development` | Environment mode |
| `LOG_LEVEL` | No | `info` | Logging level (debug/info/warn/error) |
| `OTEL_ENDPOINT` | Optional | — | OpenTelemetry collector endpoint |

---

## Scaling Considerations

- **Horizontal scaling:** Multiple iii instances behind a load balancer — **requires Redis** for shared state, queues, and streams
- **Queue concurrency:** Tune `config.concurrency` per queue step based on workload
- **Stream connections:** WebSocket connections are stateful — use sticky sessions or Redis pub/sub
- **Cron steps:** Only one instance should run cron jobs — use a dedicated iii instance or disable cron on workers

## Quick Start (Local Development)

```bash
# Install global dependencies
npm install -g iii motia-cli

# Create project
npx motia-cli create my-app
cd my-app

# Install dependencies
npm install

# Start development (auto-reloads on file changes)
iii start --config config.yaml

# Motia runs on http://localhost:3111
# Streams on ws://localhost:3112
# iii console on http://localhost:3113
```
