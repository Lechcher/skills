import { Hono } from 'hono'
import { logger } from 'hono/logger'
import { cors } from 'hono/cors'

type Bindings = {
  DB: D1Database
}

const app = new Hono<{ Bindings: Bindings }>()

app.use('*', logger())
app.use('/api/*', cors())

app.get('/', (c) => c.text('Hello Hono!'))

app.get('/api/users', async (c) => {
  return c.json({ users: [] })
})

export default app
