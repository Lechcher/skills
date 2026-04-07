# Motia State Management & Real-Time Streams — Reference

## State Management

### How State Works

State in Motia is a **key-value store** organized into groups (namespaces). Think of it like folders and files:
- `groupId` = folder name (e.g., `orders`, `users`, `cache`)
- `key` = item name within the group (e.g., `user-123`)
- `value` = any JSON-serializable data

State is **shared across all steps** and all languages (TypeScript, Python) in the same project.

### All State Methods

```typescript
import { stateManager } from 'motia'

// OR destructure from handler context:
export const handler = async (input, { stateManager }) => {

  // SET — store a value (returns { new_value, old_value })
  const result = await stateManager.set('orders', 'order-123', {
    id: 'order-123',
    status: 'pending',
    total: 99.99,
    items: ['item-a', 'item-b'],
  })
  // result.new_value → the value just stored
  // result.old_value → the previous value (null if new)

  // GET — retrieve a single item (returns null if not found)
  const order = await stateManager.get('orders', 'order-123')

  // LIST — get all items in a group (returns array of values)
  const allOrders = await stateManager.list('orders')

  // DELETE — remove a specific item
  await stateManager.delete('orders', 'order-123')

  // CLEAR — remove all items in a group
  await stateManager.clear('orders')

  // UPDATE — atomic operations (preferred over get-then-set)
  await stateManager.update('orders', 'order-123', [
    { type: 'increment', path: 'completedSteps', by: 1 },
    { type: 'set', path: 'status', value: 'shipped' },
    { type: 'decrement', path: 'retries', by: 1 },
    { type: 'merge', path: 'metadata', value: { shippedAt: new Date().toISOString() } },
    { type: 'remove', path: 'tempField' },
  ])
}
```

### UpdateOp Types (Atomic Updates)

Use `stateManager.update()` instead of get + modify + set to prevent race conditions when multiple steps run concurrently.

| Op Type | Description | Required Fields |
|---------|-------------|-----------------|
| `set` | Set a field to a value | `path`, `value` |
| `merge` | Deep merge objects | `path`, `value` |
| `increment` | Add to a number | `path`, `by` |
| `decrement` | Subtract from a number | `path`, `by` |
| `remove` | Delete a field | `path` |

```typescript
// Example: parallel steps updating the same order safety
await stateManager.update('orders', orderId, [
  { type: 'increment', path: 'completedSteps', by: 1 },
  { type: 'set', path: 'lastUpdated', value: Date.now() },
])
```

### Python State

```python
from motia import state_manager

# Same API in Python
result = await state_manager.set("orders", "order-123", {"status": "pending", "total": 99.99})
order = await state_manager.get("orders", "order-123")
all_orders = await state_manager.list("orders")
await state_manager.delete("orders", "order-123")
await state_manager.clear("orders")

# Atomic updates
await state_manager.update("orders", order_id, [
    {"type": "increment", "path": "completedSteps", "by": 1},
    {"type": "set", "path": "status", "value": "shipped"},
])
```

### Real-World Example: Order Tracking

```typescript
// src/payment-check.step.ts — Step 1: Mark payment done
export const handler = async (input, { stateManager, enqueue, logger }) => {
  logger.info('Payment checked', { orderId: input.orderId })

  await stateManager.update('orders', input.orderId, [
    { type: 'set', path: 'paymentComplete', value: true },
    { type: 'set', path: 'paymentAt', value: new Date().toISOString() },
  ])
}

// src/inventory-check.step.ts — Step 2: Mark inventory done
export const handler = async (input, { stateManager, logger }) => {
  logger.info('Inventory reserved', { orderId: input.orderId })

  await stateManager.update('orders', input.orderId, [
    { type: 'set', path: 'inventoryReserved', value: true },
  ])
}

// src/order-complete.step.ts — State Trigger: Fires when BOTH are done
export const config = {
  name: 'OrderComplete',
  triggers: [{
    type: 'state',
    stateGroup: 'orders',
    condition: (state) =>
      state.paymentComplete === true && state.inventoryReserved === true,
  }],
  ...
}
```

### When to Use State

✅ **Use state when you need:**
- Data that persists across multiple steps in a workflow
- Shared counters or metrics between parallel steps
- Tracking multi-step workflow progress
- Caching expensive computation results

❌ **Don't use state for:**
- Passing data directly between steps (use `enqueue()` instead)
- Large binary files (use external storage like S3)
- Temporary per-request data

---

## Real-Time Streams

### What Are Streams?

Streams push live data to connected clients (browsers, mobile apps) using WebSockets — built-in, no setup required.

**Use cases:**
- AI/LLM response streaming (word by word)
- Chat applications and typing indicators
- Long-running operations (video processing, exports)
- Live dashboards and real-time metrics
- Collaborative tools with multi-user sync

### Creating a Stream

Create a `*.stream.ts` file in `src/`:

```typescript
// src/notifications.stream.ts
import { Stream, type StreamConfig } from 'motia'
import { z } from 'zod'

const notificationSchema = z.object({
  id: z.string(),
  userId: z.string(),
  message: z.string(),
  type: z.enum(['info', 'success', 'warning', 'error']),
  priority: z.enum(['low', 'normal', 'critical']),
  timestamp: z.string(),
  read: z.boolean().default(false),
})

export const config: StreamConfig = {
  name: 'notifications',
  schema: notificationSchema,
  baseConfig: {
    storageType: 'default',  // or 'redis' in production
  },
  onJoin: async (subscription, _context, authContext) => {
    if (!authContext?.userId) {
      return { unauthorized: true }
    }
    return { unauthorized: false }
  },
  onLeave: async (subscription, _context, authContext) => {
    // Cleanup on disconnect
  },
}

export const notificationsStream = new Stream(config)
export type Notification = z.infer<typeof notificationSchema>
```

### Using Streams in Steps

Import the stream instance and use its methods:

```typescript
// src/send-notification.step.ts
import type { Handlers, StepConfig } from 'motia'
import { notificationsStream } from './notifications.stream'

export const config = {
  name: 'SendNotification',
  triggers: [{ type: 'queue', topic: 'notification.created' }],
  enqueues: [],
  flows: ['notifications'],
} as const satisfies StepConfig

export const handler: Handlers<typeof config> = async (input, { logger }) => {
  const { userId, message, type, priority } = input
  const notifId = `notif-${Date.now()}`

  logger.info('Sending notification', { userId, notifId })

  // SET — persists data and notifies connected clients
  await notificationsStream.set(userId, notifId, {
    id: notifId,
    userId,
    message,
    type,
    priority,
    timestamp: new Date().toISOString(),
    read: false,
  })
}
```

### Stream Methods

```typescript
// SET — store data and push to connected clients
await myStream.set(groupId, key, value)

// GET — retrieve data
const item = await myStream.get(groupId, key)

// LIST — get all items in a group
const items = await myStream.list(groupId)

// DELETE — remove data
await myStream.delete(groupId, key)

// UPDATE — atomic updates (same UpdateOp types as stateManager)
await myStream.update(groupId, key, [
  { type: 'set', path: 'status', value: 'read' },
])

// EMIT — ephemeral event (no storage, one-time push)
await myStream.emit(groupId, { type: 'typing', userId: '123' })
```

### AI Streaming Example (LLM Word-by-Word)

```typescript
// src/ai-response.stream.ts
import { Stream, type StreamConfig } from 'motia'
import { z } from 'zod'

export const config: StreamConfig = {
  name: 'aiResponse',
  schema: z.object({
    sessionId: z.string(),
    chunk: z.string(),
    done: z.boolean(),
  }),
  baseConfig: { storageType: 'default' },
}
export const aiResponseStream = new Stream(config)

// src/generate-ai.step.ts
import { aiResponseStream } from './ai-response.stream'

export const handler = async (input, { logger }) => {
  const { sessionId, prompt } = input

  // Stream words as they arrive from LLM
  for await (const chunk of callLLM(prompt)) {
    await aiResponseStream.set(sessionId, `chunk-${Date.now()}`, {
      sessionId,
      chunk,
      done: false,
    })
  }

  // Signal completion
  await aiResponseStream.set(sessionId, 'done', {
    sessionId,
    chunk: '',
    done: true,
  })
}
```

### Frontend Client (React)

```typescript
// Install: npm install @motia/client
import { MotiaProvider, useStream } from '@motia/client'

// Wrap your app
<MotiaProvider streamUrl="ws://localhost:3112">
  <App />
</MotiaProvider>

// Subscribe to stream updates
function NotificationBell() {
  const { items } = useStream('notifications', userId, {
    token: userToken
  })
  return <Badge count={items.filter(n => !n.read).length} />
}
```

### Stream Authentication

Configure in `config.yaml`:
```yaml
- class: modules::stream::StreamModule
  config:
    port: 3112
    host: 0.0.0.0
    auth_function: src/stream-auth.ts   # optional external auth
```

In the stream config `onJoin`:
```typescript
onJoin: async (subscription, context, authContext) => {
  // authContext comes from client token/headers
  if (!authContext?.userId || authContext.userId !== subscription.groupId) {
    return { unauthorized: true }    // reject connection
  }
  return { unauthorized: false }     // allow connection
}
```

### Ephemeral Events

For one-shot events not stored in state (e.g., typing indicators):

```typescript
await myStream.emit(groupId, {
  type: 'typing',
  userId: '123',
  timestamp: Date.now(),
})
```

### Inspecting Streams

In the **iii development console**, the Streams tab shows:
- All active stream connections
- Current stream data per group/key
- Live updates as they happen
