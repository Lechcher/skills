# Motia Steps — Complete Reference

## What Is a Step?

A Step is the core primitive in Motia. One file, two exports:
- `config` — defines triggers, name, flow membership, and what topics it enqueues to
- `handler` — the async function that runs your business logic

Motia auto-discovers any file in `src/` ending in `.step.ts`, `.step.js`, or `_step.py`.

---

## 1. HTTP Step (API Endpoint)

Creates a REST API endpoint. Supports GET, POST, PUT, DELETE.

```typescript
// src/create-user.step.ts
import type { Handlers, StepConfig } from 'motia'
import { z } from 'zod'

export const config = {
  name: 'CreateUser',
  description: 'Creates a new user account',
  triggers: [
    {
      type: 'http',
      method: 'POST',
      path: '/users',
      bodySchema: z.object({
        email: z.string().email(),
        name: z.string().min(1),
      }),
      responseSchema: {
        201: z.object({ id: z.string(), success: z.boolean() }),
        400: z.object({ error: z.string() }),
      },
    },
  ],
  enqueues: ['user.created'],
  flows: ['onboarding'],
} as const satisfies StepConfig

export const handler: Handlers<typeof config> = async ({ request }, { enqueue, logger }) => {
  const { email, name } = request.body

  logger.info('Creating user', { email })
  const userId = `user-${Date.now()}`

  await enqueue({ topic: 'user.created', data: { userId, email, name } })

  return { status: 201, body: { id: userId, success: true } }
}
```

**HTTP trigger config options:**
```typescript
{
  type: 'http',
  method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH',
  path: '/your/path/:param',    // Express-style path params
  bodySchema: z.object({...}),  // Zod schema for request body validation
  querySchema: z.object({...}), // Zod schema for query params
  responseSchema: { 200: z.object({...}) },
  middleware: [authMiddleware],  // Array of middleware functions
}
```

**Accessing request data:**
```typescript
const { body, params, query, headers } = request
// params.id  → path param :id
// query.page → ?page=1
// headers.authorization
```

---

## 2. Queue Step (Background Job)

Processes messages from a queue topic asynchronously. Triggered by `enqueue()` calls from other steps.

```typescript
// src/send-welcome-email.step.ts
import type { Handlers, StepConfig } from 'motia'

export const config = {
  name: 'SendWelcomeEmail',
  description: 'Sends welcome email after user registration',
  triggers: [
    {
      type: 'queue',
      topic: 'user.created',
      config: {
        maxRetries: 3,
        visibilityTimeout: 30, // seconds before retry
      },
    },
  ],
  enqueues: ['email.sent'],
  flows: ['onboarding'],
} as const satisfies StepConfig

export const handler: Handlers<typeof config> = async (input, { enqueue, logger, stateManager }) => {
  const { userId, email, name } = input

  logger.info('Sending welcome email', { userId, email })

  // Simulate email send
  await sendEmail({ to: email, subject: `Welcome, ${name}!` })

  // Update state
  await stateManager.update('users', userId, [
    { type: 'set', path: 'emailSent', value: true },
  ])

  await enqueue({ topic: 'email.sent', data: { userId, type: 'welcome' } })

  logger.info('Welcome email sent', { userId })
}

async function sendEmail(opts: { to: string; subject: string }) {
  // Your email provider logic here
}
```

**Queue trigger config options:**
```typescript
{
  type: 'queue',
  topic: 'my.topic',
  condition: (data) => data.priority === 'high', // optional filter
  config: {
    maxRetries: 5,           // default: 3
    visibilityTimeout: 60,   // seconds
    concurrency: 10,         // parallel consumers
  },
}
```

---

## 3. Cron Step (Scheduled Task)

Runs on a schedule defined by a cron expression.

```typescript
// src/daily-report.step.ts
import type { Handlers, StepConfig } from 'motia'

export const config = {
  name: 'DailyReport',
  description: 'Generates daily sales report at midnight UTC',
  triggers: [
    {
      type: 'cron',
      cron: '0 0 * * *', // midnight every day
    },
  ],
  enqueues: ['report.generated'],
  flows: ['reporting'],
} as const satisfies StepConfig

export const handler: Handlers<typeof config> = async (_input, { enqueue, logger, stateManager }) => {
  logger.info('Starting daily report generation')

  const today = new Date().toISOString().split('T')[0]
  const orders = await stateManager.list('orders')

  const summary = {
    date: today,
    totalOrders: orders.length,
    totalRevenue: orders.reduce((sum: number, o: any) => sum + (o.value?.total ?? 0), 0),
  }

  await stateManager.set('reports', `daily-${today}`, summary)
  await enqueue({ topic: 'report.generated', data: summary })

  logger.info('Daily report generated', summary)
}
```

**Common cron expressions:**
```
0 * * * *     → every hour
0 0 * * *     → midnight every day
0 9 * * 1-5   → 9am weekdays
*/15 * * * *  → every 15 minutes
0 0 * * 0     → midnight every Sunday
```

---

## 4. State Trigger Step

Reacts automatically when a specific state key reaches a condition. Great for building parallel-then-merge workflows.

```typescript
// src/order-complete.step.ts
import type { Handlers, StepConfig } from 'motia'

export const config = {
  name: 'OrderComplete',
  description: 'Fires when all parallel order tasks are done',
  triggers: [
    {
      type: 'state',
      stateGroup: 'orders',
      condition: (state) =>
        state.paymentComplete === true && state.inventoryReserved === true,
    },
  ],
  enqueues: ['order.shipped'],
  flows: ['order-management'],
} as const satisfies StepConfig

export const handler: Handlers<typeof config> = async (input, { enqueue, logger }) => {
  logger.info('Order ready to ship', { orderId: input.key })
  await enqueue({ topic: 'order.shipped', data: { orderId: input.key } })
}
```

**State trigger context:**
```typescript
// input contains:
// input.key      → the state key that changed
// input.groupId  → the state group
// input.value    → the current state value
// input.oldValue → the previous value
```

---

## 5. Stream Trigger Step

Reacts automatically when stream data changes.

```typescript
// src/notify-on-stream.step.ts
import type { Handlers, StepConfig } from 'motia'

export const config = {
  name: 'NotifyOnStream',
  description: 'Sends push notification when stream updates',
  triggers: [
    {
      type: 'stream',
      streamName: 'notifications',
      condition: (data) => data.priority === 'critical',
    },
  ],
  enqueues: [],
  flows: ['notifications'],
} as const satisfies StepConfig

export const handler: Handlers<typeof config> = async (input, { logger }) => {
  logger.info('Critical notification received', input)
  // Send push notification, etc.
}
```

---

## 6. Multi-Trigger Step

A single step can respond to multiple trigger types simultaneously.

```typescript
// src/process-request.step.ts
import type { Handlers, StepConfig } from 'motia'

export const config = {
  name: 'ProcessRequest',
  description: 'Handles manual HTTP requests and automated queue messages',
  triggers: [
    { type: 'http', method: 'POST', path: '/process' },
    { type: 'queue', topic: 'auto.process' },
    { type: 'cron', cron: '0 * * * *' },
  ],
  enqueues: ['task.done'],
  flows: ['processing'],
} as const satisfies StepConfig

export const handler: Handlers<typeof config> = async (input, ctx) => {
  const { is, getData } = ctx

  if (is('http')) {
    const httpInput = getData('http')
    ctx.logger.info('HTTP trigger', { body: httpInput.request.body })
    await ctx.enqueue({ topic: 'task.done', data: { source: 'http' } })
    return { status: 200, body: { ok: true } }
  }

  if (is('queue')) {
    const queueInput = getData('queue')
    ctx.logger.info('Queue trigger', queueInput)
    await ctx.enqueue({ topic: 'task.done', data: { source: 'queue' } })
  }

  if (is('cron')) {
    ctx.logger.info('Cron trigger fired')
    await ctx.enqueue({ topic: 'task.done', data: { source: 'cron' } })
  }
}
```

---

## 7. NoOp Step (Visual Only)

A NoOp step has no handler — it only appears in the iii development console for diagram visualization.

```typescript
// src/order-received.step.ts
import type { StepConfig } from 'motia'

export const config = {
  name: 'OrderReceived',
  description: 'Visual connector — marks order receipt in the flow diagram',
  type: 'noop',
  virtualEmits: [
    { topic: 'payment.check', label: 'Check Payment' },
    { topic: 'inventory.check', label: 'Check Inventory' },
  ],
  virtualSubscribes: ['order.created'],
  flows: ['order-management'],
} as const satisfies StepConfig
```

---

## 8. Python Step

Python steps use the same model (`_step.py` suffix):

```python
# src/analyze_data_step.py
from motia import state_manager, logger

config = {
    'name': 'AnalyzeData',
    'description': 'Analyzes incoming data with Python',
    'triggers': [
        {'type': 'queue', 'topic': 'data.received'}
    ],
    'enqueues': ['analysis.complete'],
    'flows': ['data-pipeline'],
}

async def handler(input, ctx):
    logger.info('Analyzing data', {'payload': input})

    result = perform_analysis(input)

    await state_manager.set('analyses', input['id'], result)
    await ctx.enqueue({'topic': 'analysis.complete', 'data': result})

def perform_analysis(data):
    # Your Python data processing logic
    return {'score': 0.95, 'label': 'positive'}
```

---

## Project Structure

```
my-project/
├── config.yaml         # iii engine configuration
├── package.json
├── src/
│   ├── create-user.step.ts
│   ├── send-email.step.ts
│   ├── daily-report.step.ts
│   ├── notifications.stream.ts
│   └── python/
│       └── analyze_data_step.py
└── data/               # Local state/stream storage (dev)
```

## Step Context Object (ctx)

Every handler receives `ctx` as the second argument:

```typescript
export const handler = async (input, ctx) => {
  ctx.traceId        // Distributed trace ID linking all steps in a workflow
  ctx.logger         // Structured logger (info, warn, error, debug)
  ctx.stateManager   // State persistence (set/get/list/delete/update)
  ctx.enqueue        // Send messages to queue topics
  ctx.streams        // Access named streams
  ctx.is('http')     // Check current trigger type
  ctx.getData('http') // Get trigger-specific input data
}
```
