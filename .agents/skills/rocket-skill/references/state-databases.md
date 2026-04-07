# State & Databases — Rocket v0.5

## Managed State

Share data across requests using Rocket's managed state. State is managed per-type (one value per type). All managed state must implement `Send + Sync`.

### Adding State

```rust
use rocket::State;
use std::sync::Mutex;

struct AppConfig {
    max_items: usize,
    debug: bool,
}

#[launch]
fn rocket() -> _ {
    let config = AppConfig { max_items: 100, debug: true };
    rocket::build()
        .manage(config)
        .mount("/", routes![index])
}
```

### Retrieving State in Handlers

```rust
#[get("/config")]
fn show_config(config: &State<AppConfig>) -> String {
    format!("Max items: {}, debug: {}", config.max_items, config.debug)
}
```

### Mutable State (with Mutex/RwLock)

```rust
use std::sync::{Mutex, atomic::{AtomicUsize, Ordering}};

// Atomic for simple counters
struct Counter(AtomicUsize);

#[get("/count")]
fn count(c: &State<Counter>) -> String {
    format!("{}", c.0.fetch_add(1, Ordering::Relaxed))
}

// Mutex for complex structures
struct HitMap(Mutex<HashMap<String, usize>>);

#[get("/hits/<path>")]
fn hits(path: &str, map: &State<HitMap>) -> usize {
    let mut m = map.0.lock().unwrap();
    *m.entry(path.to_string()).or_insert(0) += 1;
    m[path]
}
```

### State in Request Guards

```rust
#[rocket::async_trait]
impl<'r> FromRequest<'r> for AdminUser {
    type Error = Infallible;

    async fn from_request(req: &'r Request<'_>) -> Outcome<Self, Self::Error> {
        let config = req.guard::<&State<AppConfig>>().await.unwrap();
        // use config...
        Outcome::Success(AdminUser)
    }
}
```

## Request-Local State

State tied to a single request, cached per request. Dropped with the request.
Useful for caching expensive computations (auth, DB lookups) across multiple guards in the same request.

```rust
use rocket::request::{self, Request, FromRequest};
use std::sync::atomic::{AtomicUsize, Ordering};

static ID_COUNTER: AtomicUsize = AtomicUsize::new(0);

struct RequestId(pub usize);

#[rocket::async_trait]
impl<'r> FromRequest<'r> for &'r RequestId {
    type Error = ();

    async fn from_request(req: &'r Request<'_>) -> request::Outcome<Self, ()> {
        let id = req.local_cache(|| {
            RequestId(ID_COUNTER.fetch_add(1, Ordering::Relaxed))
        });
        request::Outcome::Success(id)
    }
}

#[get("/")]
fn handler(id: &RequestId) -> String {
    format!("Request #{}", id.0)
}
```

## Databases — rocket_db_pools

### Setup

```toml
# Cargo.toml
[dependencies.rocket_db_pools]
version = "0.2.0"
features = ["sqlx_sqlite"]  # Choose one driver
```

**Supported drivers and feature names:**

| Database | Feature | Pool Type |
|----------|---------|-----------|
| SQLite | `sqlx_sqlite` | `sqlx::SqlitePool` |
| PostgreSQL | `sqlx_postgres` | `sqlx::PgPool` |
| MySQL | `sqlx_mysql` | `sqlx::MySqlPool` |
| MongoDB | `mongodb` | `mongodb::Client` |
| Redis | `deadpool_redis` | `deadpool_redis::Pool` |
| Memcached | `deadpool_memcache` | `deadpool_memcache::Pool` |

### Configuration

```toml
# Rocket.toml
[default.databases.my_db]
url = "sqlite:///path/to/db.sqlite"
min_connections = 1
max_connections = 10
connect_timeout = 5
idle_timeout = 300
```

### Usage

```rust
use rocket_db_pools::{Database, Connection};
use rocket_db_pools::sqlx::{self, Row};

#[derive(Database)]
#[database("my_db")]
struct Db(sqlx::SqlitePool);

#[get("/users")]
async fn list_users(mut db: Connection<Db>) -> Result<String, String> {
    let users = sqlx::query("SELECT name FROM users")
        .fetch_all(&mut **db).await
        .map_err(|e| e.to_string())?;
    
    let names: Vec<String> = users.iter()
        .map(|r| r.get(0))
        .collect();
    Ok(names.join(", "))
}

#[post("/users", data = "<name>")]
async fn create_user(db: Connection<Db>, name: String) -> Result<String, String> {
    sqlx::query("INSERT INTO users (name) VALUES (?)")
        .bind(&name)
        .execute(&mut **db).await
        .map_err(|e| e.to_string())?;
    Ok(format!("Created user: {}", name))
}

#[launch]
fn rocket() -> _ {
    rocket::build()
        .attach(Db::init())
        .mount("/", routes![list_users, create_user])
}
```

### With sqlx Migrations

```toml
# Cargo.toml
[dependencies.sqlx]
version = "0.7"
default-features = false
features = ["macros", "migrate"]
```

```rust
// In your fairing or ignite hook:
use sqlx::migrate::MigrateDatabase;

#[rocket::async_trait]
impl Fairing for DbMigratorFairing {
    fn info(&self) -> Info { Info { name: "DB Migrator", kind: Kind::Ignite } }
    async fn on_ignite(&self, rocket: Rocket<Build>) -> fairing::Result {
        // sqlx migrations run automatically from migrations/ folder
        // when using the `sqlx::migrate!()` macro
        Ok(rocket)
    }
}
```

### Additional Driver Features

If you need features beyond the defaults, depend on the driver directly:

```toml
[dependencies.sqlx]
version = "0.7"
default-features = false
features = ["macros", "migrate"]

[dependencies.rocket_db_pools]
version = "0.2.0"
features = ["sqlx_sqlite"]
```

## Synchronous ORMs (Diesel)

For Diesel and other blocking ORMs, use `rocket_sync_db_pools`:

```toml
[dependencies.rocket_sync_db_pools]
version = "0.1"
features = ["diesel_sqlite_pool"]
```

```toml
[default.databases.diesel_db]
url = "db.sqlite"
```

```rust
use rocket_sync_db_pools::{database, diesel};

#[database("diesel_db")]
struct DieselDb(diesel::SqliteConnection);

#[get("/posts")]
async fn get_posts(db: DieselDb) -> String {
    db.run(|conn| {
        // diesel ORM calls here (blocking)
        "posts from DB".to_string()
    }).await
}
```
