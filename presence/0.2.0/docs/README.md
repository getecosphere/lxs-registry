# presence — LXS docs

## Capability

Realtime social-proof hub for a live globe. The estate (or its onboarding
flow) POSTs **join/login pulses**; every connected browser receives them over
**Server-Sent Events** and lights up the visitor's city.

Privacy-first: only a **first name** is ever carried (never a full name), and
the caller decides the city/coords — geolocation is opt-in, with an IP/nearest-
city fallback chosen by the caller.

## API (base `/api`)

| Method | Path | Auth | Purpose |
|---|---|---|---|
| GET | `/api/health` | no | liveness |
| GET | `/api/stats` | no | `{signups, signins, online, total, latest}` |
| POST | `/api/event` | no | record a pulse `{type:"signup"\|"signin", name, city, country, lat, lng}` → returns stats |
| GET | `/api/stream` | no | SSE stream of pulses (JSON per `data:` line) |

In an estate the browser prefix is `/api/presence/*` (gateway strips it to
`/api/*`).

## Compose it

```yaml
services:
  presence-backend:
    lxs: presence@0.1.0
    access:
      routes:
        - { path: /api/presence/event, level: public, strip: /api/presence, rewrite: /api }
        - { path: /api/presence/stats, level: public, strip: /api/presence, rewrite: /api }
        - { path: /api/presence/stream, level: public, strip: /api/presence, rewrite: /api }
```

## Environment

| Variable | Required | Purpose |
|---|---|---|
| `SERVER_PORT` | yes | listen port |
| `CORS_ALLOWED_ORIGINS` | no | allowed browser origins |

## Source

- Repo: (local — publish before prod)
