# Motia iii Engine — Configuration Reference

## What Is the iii Engine?

The **iii engine** is a standalone runtime that powers all Motia infrastructure:
- Message queues
- Key-value state storage
- Real-time streams with WebSocket support
- Cron scheduling
- HTTP server
- OpenTelemetry observability
- Multi-language step execution (TypeScript via Node.js, Python)

All infrastructure is declared in a single `config.yaml` file — no application code changes needed to swap adapters.

---

## config.yaml — Full Structure

```yaml
# config.yaml — root of your Motia project
modules:
  # REST API — serves HTTP step endpoints
  - class: modules::api::RestApiModule
    config:
      port: 3111
      host: 0.0.0.0
      default_timeout: 30000          # ms
      concurrency_request_limit: 1024
      cors:
        allowed_origins:
          - http://localhost:3000
          - https://yourapp.com
        allowed_methods:
          - GET
          - POST
          - PUT
          - DELETE
          - OPTIONS
        allowed_headers:
          - Content-Type
          - Authorization

  # Message Queue — async step-to-step communication
  - class: modules::queue::QueueModule
    config:
      adapter:
        class: modules::queue::BuiltinQueueAdapter  # dev default

        # Redis (production):
        # class: modules::queue::RedisAdapter
        # config:
        #   redis_url: "${REDIS_URL:redis://localhost:6379}"

        # RabbitMQ:
        # class: modules::queue::RabbitMQAdapter
        # config:
        #   amqp_url: "${RABBITMQ_URL:amqp://localhost:5672}"

  # State Storage — persistent key-value store
  - class: modules::state::StateModule
    config:
      adapter:
        class: modules::state::adapters::KvStore
        config:
          store_method: file_based     # 'file_based' or 'in_memory'
          file_path: ./data/state_store.db

        # Redis (production):
        # class: modules::state::adapters::RedisAdapter
        # config:
        #   redis_url: "${REDIS_URL:redis://localhost:6379}"

  # Streams — WebSocket real-time data
  - class: modules::stream::StreamModule
    config:
      port: 3112
      host: 0.0.0.0
      adapter:
        class: modules::stream::adapters::KvStore
        config:
          store_method: file_based
          file_path: ./data/stream_store

        # Redis (production):
        # class: modules::stream::adapters::RedisAdapter
        # config:
        #   redis_url: "${REDIS_URL:redis://localhost:6379}"

  # Cron Scheduler
  - class: modules::cron::CronModule
    config:
      adapter:
        class: modules::cron::KvCronAdapter

  # PubSub — internal engine messaging
  - class: modules::pubsub::PubSubModule
    config:
      adapter:
        class: modules::pubsub::LocalAdapter

        # Redis (production):
        # class: modules::pubsub::RedisAdapter
        # config:
        #   redis_url: "${REDIS_URL:redis://localhost:6379}"

  # OpenTelemetry — distributed tracing (optional)
  - class: modules::otel::OpenTelemetryModule
    config:
      enabled: true
      endpoint: "${OTEL_EXPORTER_OTLP_ENDPOINT:http://localhost:4318}"
      service_name: my-motia-app

  # Exec — run Motia application processes
  - class: modules::shell::ExecModule
    config:
      watch:
        - steps/**/*.ts
        - motia.config.ts
      exec:
        - npx motia dev
```

---

## Environment Variable Interpolation

Use `${VAR_NAME:default_value}` syntax in config.yaml:

```yaml
modules:
  - class: modules::api::RestApiModule
    config:
      port: "${PORT:3111}"
      host: "${HOST:0.0.0.0}"

  - class: modules::queue::QueueModule
    config:
      adapter:
        class: modules::queue::RedisAdapter
        config:
          redis_url: "${REDIS_URL:redis://localhost:6379}"
```

Your `.env` file:
```env
PORT=8080
REDIS_URL=redis://my-redis:6379
DATABASE_URL=postgresql://...
```

---

## Module Reference

### REST API Module

```yaml
- class: modules::api::RestApiModule
  config:
    port: 3111                          # HTTP port
    host: 0.0.0.0                       # Bind address
    default_timeout: 30000              # Request timeout (ms)
    concurrency_request_limit: 1024     # Max concurrent requests
    cors:
      allowed_origins: ["*"]            # Or specific origins
      allowed_methods: [GET, POST, PUT, DELETE]
      allowed_headers: [Content-Type, Authorization]
```

### Queue Module — Adapters

| Adapter | Class | Config |
|---------|-------|--------|
| Built-in (dev) | `modules::queue::BuiltinQueueAdapter` | none |
| Redis | `modules::queue::RedisAdapter` | `redis_url` |
| RabbitMQ | `modules::queue::RabbitMQAdapter` | `amqp_url` |

### State Module — Adapters

| Adapter | Class | Config |
|---------|-------|--------|
| File-based (dev) | `modules::state::adapters::KvStore` | `store_method: file_based`, `file_path` |
| In-memory | `modules::state::adapters::KvStore` | `store_method: in_memory` |
| Redis | `modules::state::adapters::RedisAdapter` | `redis_url` |

### Stream Module — Adapters

| Adapter | Class | Config |
|---------|-------|--------|
| File-based (dev) | `modules::stream::adapters::KvStore` | `store_method: file_based`, `file_path` |
| Redis | `modules::stream::adapters::RedisAdapter` | `redis_url` |

### PubSub Module — Adapters

| Adapter | Class | Config |
|---------|-------|--------|
| Local (dev) | `modules::pubsub::LocalAdapter` | none |
| Redis | `modules::pubsub::RedisAdapter` | `redis_url` |

---

## Development Commands

```bash
# Install iii engine (required)
npm install -g iii

# Install Motia CLI
npm install -g motia-cli

# Create new project
npx motia-cli create my-project
cd my-project

# Start development server (watches for changes)
iii start --config config.yaml

# Start Motia dev process
npx motia dev

# Build for production
npx motia build

# Open iii development console
# Navigate to http://localhost:3113 (default)
```

---

## Multi-Language Projects

TypeScript and Python steps coexist in the same project seamlessly:

```yaml
# config.yaml — register Python step runner
modules:
  - class: modules::shell::ExecModule
    config:
      exec:
        - npx motia dev          # TypeScript/JavaScript steps
        - python -m motia.runner # Python steps
```

Python requirements:
```bash
pip install motia
```

---

## Production config.yaml (Redis)

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

  - class: modules::otel::OpenTelemetryModule
    config:
      enabled: true
      endpoint: "${OTEL_ENDPOINT}"
      service_name: "${SERVICE_NAME:my-app}"
```
