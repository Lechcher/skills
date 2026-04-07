# Hono Backend Reference Documentation

## 1. App Initialization
The `Hono` object is the primary application instance.
```ts
import { Hono } from 'hono'
const app = new Hono()
```

## 2. Routing
Basic routing and parameters.
```ts
app.get('/', (c) => c.text('GET /'))
app.post('/', (c) => c.text('POST /'))
app.get('/user/:name', (c) => {
  const name = c.req.param('name')
  return c.text(`Hello ${name}`)
})
app.get('/posts/:id/comment/:comment_id', (c) => {
  const { id, comment_id } = c.req.param()
})
// Chained Route
app
  .get('/endpoint', (c) => c.text('GET'))
  .post((c) => c.text('POST'))

// Grouping
const book = new Hono()
book.get('/', (c) => c.text('List Books'))
app.route('/book', book)
```

## 3. Context (`c`)
The Context object is passed to every handler.
### Methods on Context
- `c.req.param('name')` - Get path param
- `c.req.header('User-Agent')` - Get header
- `c.status(201)` - Set Status code
- `c.header('X-Message', 'Hello')` - Set header
- `c.text('Hello')` - Return text (Content-Type:text/plain)
- `c.json({ message: 'Hello' })` - Return JSON
- `c.html('<h1>Hello</h1>')` - Return HTML
- `c.notFound()` - Trigger 404 response
- `c.redirect('/')` - 302 redirect

### Variables (Context State)
To pass states/variables inside a request lifecycle:
```ts
c.set('message', 'Hono is cool')
const message = c.get('message')

// Type safe generics
type Variables = { message: string }
const app = new Hono<{ Variables: Variables }>()
```

## 4. Middleware
Middleware follow an onion structure, executing before and after `next()`.
```ts
// Built in
import { logger } from 'hono/logger'
import { cors } from 'hono/cors'

app.use(logger())
app.use('/api/*', cors())

// Custom Middleware
import { createMiddleware } from 'hono/factory'
const customLogger = createMiddleware(async (c, next) => {
  console.log(`[${c.req.method}] ${c.req.url}`)
  await next()
  c.header('X-Processed', 'true')
})
```
