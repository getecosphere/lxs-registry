# geo — LXS docs

## Capability

Resolve an **IP address → location** (`country`, `city`, `lat`, `lng`). One
reusable capability, so any service (heartbeat "last seen", auth signup origin,
analytics, presence) gets geo the same way instead of embedding its own.

- **Offline first:** if `GEO_DB` points at a MaxMind-DB
  (GeoLite2-City or DB-IP Lite), lookups are local and fast.
- **HTTP fallback:** otherwise it calls `GEO_URL` (default `ip-api.com`).
- Lookups are **cached in-process (24h)**; private/loopback IPs return no geo.

`GET /api/whereami` resolves the **caller's** IP from the edge headers
(`cf-connecting-ip` → `X-Forwarded-For` → `X-Real-IP`), so a browser can learn
its own city without any permission prompt.

## Compose it

```yaml
services:
  geo-backend:
    lxs: geo@0.1.0
    registry: getecosphere/private-lxs-registry
    config:
      GEO_DB: "/opt/geo/dbip-city-lite.mmdb"   # optional; else GEO_URL
    access:
      routes:
        - { path: /api/geo/health,   level: public, strip: /api/geo, rewrite: /api }
        - { path: /api/geo/whereami, level: public, strip: /api/geo, rewrite: /api }
        - { path: /api/geo/lookup,   level: public, strip: /api/geo, rewrite: /api }
```

## Environment

| Variable | Required | Purpose |
|---|---|---|
| `SERVER_PORT` | yes | listen port |
| `CORS_ALLOWED_ORIGINS` | no | allowed browser origins |
| `GEO_DB` | no | absolute path to an ip→city `.mmdb` (offline geo) |
| `GEO_URL` | no | HTTP geo base when no DB is set (default `http://ip-api.com/json`) |

### Offline geo database

`scripts/fetch-geo-db.sh [dest.mmdb]` downloads a free ip→city MaxMind-DB from
**DB-IP Lite** — then set `GEO_DB` to the file. `.mmdb` files are gitignored.

## Source

- Repo: `getecosphere/geo` (private)
