# Motia Middleware, Observability & Flows — Reference

---

## Middleware

Middleware functions run **before** your HTTP handler. Use them for authentication, rate limiting, validation, logging, or any logic that spans multiple endpoints.

### How Middleware Works

```typescript
// Signature: (httpArgs, ctx, next) => Response | void
const myMiddleware: ApiMiddleware = async ({ request, response }, ctx, next) => {
  // Run before handler
  const result = await next()  // Run handler (and any remaining middleware)
  // Run after handler — modify result if needed
  return result
}
```

- Call `next()` to continue to the next middleware or the handler
- Return early (without calling `next()`) to stop the request
- Await `next()` to intercept the response

### Authentication Middleware

```typescript
// src/middleware/auth.ts
import type { ApiMiddleware } from 'motia'

export const authMiddleware: ApiMiddleware = async ({ request }, ctx, next) => {
  const token = request.headers.authorization?.replace('Bearer ', '')

  if (!token) {
    return { status: 401, body: { error: 'Missing authorization token' } }
  }

  const user = await verifyToken(token)
  if (!user) {
    return { status: 403, body: { error: 'Invalid or expired token' } }
  }

  // Pass user data to handler via request
  request.user = user
  return next()
}

async function verifyToken(token: string) {
  // Your JWT/OAuth verification logic
  return { id: 'user-123', email: 'user@example.com' }
}
```

### Using Middleware in Steps

```typescript
// src/protected-endpoint.step.ts
import type { Handlers, StepConfig } from 'motia'
import { authMiddleware } from './middleware/auth'
import { rateLimitMiddleware } from './middleware/rate-limit'
import { loggingMiddleware } from './middleware/logging'

export const config = {
  name: 'ProtectedEndpoint',
  description: 'Protected API endpoint with auth and rate limiting',
  triggers: [
    {
      type: 'http',
      method: 'GET',
      path: '/protected',
      middleware: [loggingMiddleware, authMiddleware, rateLimitMiddleware],
      // Runs in order: logging → auth → rateLimit → handler
    },
  ],
  enqueues: [],
  flows: ['protected-api'],
} as const satisfies StepConfig

export const handler: Handlers<typeof config> = async ({ request }, ctx) => {
  const user = (request as any).user  // Set by authMiddleware
  ctx.logger.info('Authenticated request', { userId: user.id })
  return { status: 200, body: { message: 'Success', user } }
}
```

### Common Middleware Patterns

```typescript
// Rate limiting
export const rateLimitMiddleware: ApiMiddleware = async ({ request }, ctx, next) => {
  const key = `ratelimit:${request.headers['x-forwarded-for']}`
  const count = await ctx.stateManager.get('rate-limits', key)

  if (count && count.calls >= 100) {
    return { status: 429, body: { error: 'Too many requests' } }
  }

  await ctx.stateManager.update('rate-limits', key, [
    { type: 'increment', path: 'calls', by: 1 },
  ])

  return next()
}

// Response timing
export const timingMiddleware: ApiMiddleware = async ({ request }, ctx, next) => {
  const start = Date.now()
  const response = await next()
  const duration = Date.now() - start

  ctx.logger.info('Request completed', { path: request.url, duration })

  return {
    ...response,
    headers: { ...response?.headers, 'X-Response-Time': `${duration}ms` },
  }
}

// Error handling
export const errorMiddleware: ApiMiddleware = async ({ request }, ctx, next) => {
  try {
    return await next()
  } catch (error) {
    ctx.logger.error('Unhandled error', { error, path: request.url })
    return { status: 500, body: { error: 'Internal server error' } }
  }
}

// Add traceId header to all responses
export const traceMiddleware: ApiMiddleware = async ({ request }, ctx, next) => {
  const response = await next()
  return {
    ...response,
    headers: { ...response?.headers, 'X-Trace-Id': ctx.traceId },
  }
}
```

---

## Observability (Logging & Tracing)

### Structured Logging

Every step has access to `logger` via the context (`ctx`):

```typescript
export const handler = async (input, { logger, traceId }) => {
  // Log at different levels
  logger.debug('Debug details for troubleshooting', { input })
  logger.info('Processing user request', { userId: input.userId })
  logger.warn('Retrying failed operation', { attempt: 3, maxRetries: 5 })
  logger.error('Operation failed', { error: err.message, stack: err.stack })
}
```

**Log Levels:**
| Level | Use |
|-------|-----|
| `debug` | Detailed dev/troubleshooting info |
| `info` | Normal operations (default level) |
| `warn` | Unexpected but non-fatal conditions |
| `error` | Errors requiring attention |

### Best Practices for Logging

```typescript
// ✅ Use objects for structured metadata
logger.info('User registered', { userId, email, source: 'oauth' })

// ❌ Don't concatenate strings
// logger.info('User registered: ' + userId)

// ✅ Track performance
const start = Date.now()
const result = await callExternalAPI()
logger.info('External API call', { duration: Date.now() - start, result })

// ✅ Log errors with full context
try {
  await processOrder(orderId)
} catch (error) {
  logger.error('Order processing failed', {
    orderId,
    error: error instanceof Error ? error.message : String(error),
    stack: error instanceof Error ? error.stack : undefined,
  })
  throw error // re-throw so queue retries
}
```

### Distributed Tracing (traceId)

Every workflow execution gets a unique `traceId`. It automatically links all steps in the same trace:

```typescript
export const handler = async (input, ctx) => {
  ctx.logger.info('Step started', {
    traceId: ctx.traceId,   // Same across all steps in this workflow
    step: 'CreateUser',
  })

  // When enqueueing, traceId propagates automatically
  await ctx.enqueue({ topic: 'user.created', data: input })
}
```

In the **iii development console**, you can filter logs by `traceId` to see the complete execution path across all steps.

### Python Logging

```python
from motia import logger

async def handler(input, ctx):
    logger.info("Processing request", {"userId": input["userId"]})
    logger.error("Something went wrong", {"error": str(e)})
```

### Debug Mode

Set `LOG_LEVEL=debug` in your `.env` to enable verbose output:
```env
LOG_LEVEL=debug
```

### iii Development Console

Navigate to `http://localhost:3113` (default — may vary) to access:
- **Flows** — visual diagram of all steps and their connections
- **Logs** — real-time structured log viewer with traceId filtering
- **Traces** — distributed trace explorer
- **State** — inspect stored state data
- **Streams** — monitor live stream connections and data
- **HTTP** — test HTTP endpoints directly from the console

---

## Flows

Flows are **visual groupings** for the iii development console diagram. They don't affect runtime behavior — they're purely organizational.

### Assigning Steps to Flows

```typescript
export const config = {
  name: 'CreateOrder',
  triggers: [{ type: 'http', method: 'POST', path: '/orders' }],
  enqueues: ['order.created'],
  flows: ['order-management'],    // ← appears in this flow diagram
} as const satisfies StepConfig
```

### Multiple Flows

A step can belong to multiple flows:

```typescript
export const config = {
  name: 'SendEmail',
  flows: ['onboarding', 'notifications', 'order-management'],
}
```

### NOOP Steps (Visual Connectors)

Use NOOP steps to add visual nodes to flow diagrams without business logic:

```typescript
// src/order-start.step.ts
export const config = {
  name: 'OrderStart',
  description: 'Visual entry point for the order flow',
  type: 'noop',
  virtualEmits: [
    { topic: 'payment.check', label: 'Check Payment' },
    { topic: 'inventory.check', label: 'Check Stock' },
  ],
  virtualSubscribes: ['order.created'],
  flows: ['order-management'],
} as const satisfies StepConfig
// No handler needed for NOOP steps
```

### Virtual Connections & Labels

In the flow diagram, you can label connections between steps:

```typescript
export const config = {
  name: 'OrderRouter',
  virtualEmits: [
    { topic: 'order.expedite', label: 'Priority Order' },
    { topic: 'order.standard', label: 'Standard Order' },
  ],
  flows: ['order-management'],
}
```

---

## Queue Configuration

Fine-tune retry and concurrency behavior for queue steps:

```typescript
export const config = {
  name: 'ProcessPayment',
  triggers: [
    {
      type: 'queue',
      topic: 'payment.requested',
      config: {
        maxRetries: 5,              // default: 3
        visibilityTimeout: 120,     // seconds before retry
        concurrency: 10,            // parallel consumers (default: 1)
        backoff: {
          type: 'exponential',      // 'fixed' | 'exponential'
          delay: 1000,              // base delay in ms
        },
      },
    },
  ],
}
```

## Conditional Triggers

Filter which queue messages activate a step:

```typescript
export const config = {
  name: 'HighPriorityHandler',
  triggers: [
    {
      type: 'queue',
      topic: 'task.created',
      condition: (data) => data.priority === 'high' && data.amount > 1000,
    },
  ],
}
```
