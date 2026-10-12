# presence API

Base path: `/api`. No auth (public read/write — the payload is a first name +
city only). In an estate the browser prefix is `/api/presence/*` (the gateway
strips it to `/api/*`).

## GET /api/health
Liveness. `200 {"status":"UP"}`.

## GET /api/stats
`200 {"signups":N,"signins":N,"online":N,"total":N,"latest":{...}|null}`.
Counters are in-process, or in Redis when `REDIS_URL` is set (so all replicas
agree).

## Scaling (Redis)
With `REDIS_URL` set, presence runs as N replicas: `POST /api/event` publishes
the pulse once to the shared channel and every replica fans it out to its own
SSE clients; counters are atomic in Redis. Unset → single-process (default).

## POST /api/event
Body: `{ "type": "signup" | "signin", "name": "Ali", "city": "Bandung",
"country": "ID", "lat": -6.9175, "lng": 107.6191 }`.
Only the first token of `name` is stored/returned. `200` returns the updated
stats. The pulse is fanned out to every connected SSE client.

If `lat`/`lng` are missing (geolocation declined) the city is resolved from
the client IP: first `X-Forwarded-For` hop, else `X-Real-IP`, looked up
**offline first** via `PRESENCE_GEO_DB` (a MaxMind-DB `.mmdb` — GeoLite2-City or
DB-IP Lite; see `scripts/fetch-geo-db.sh`), else via `PRESENCE_GEO_URL`
(default `http://ip-api.com/json`), cached 24h. Private/loopback IPs are
skipped (the pulse then keeps the caller's empty location).

### Heartbeat (`"type": "ping"`)
A silent keep-alive: refreshes the caller's last-seen only — **no pulse, no SSE
broadcast, no counter bump, no replay log**. Clients send one about every 60s
while the tab is visible so `online` reflects who is actually here.

`online` = distinct members seen (pulse or ping) within
`PRESENCE_ONLINE_WINDOW_SECS` (default 180). A member is keyed by the
gateway-injected `X-Eco-User` header (user id), falling back to the first name,
so two members who share a first name count twice. Redis mode keeps last-seen in
a shared sorted set (`presence:seen`).

## GET /api/replay
Today's pulses (UTC), for a first-paint time-lapse:
`200 {"date":"YYYY-MM-DD","count":N,"events":[Pulse,...]}` (last 5000).

## GET /api/stream
`text/event-stream`. Each event's `data:` is a JSON pulse:
```json
{"kind":"signup","name":"Ali","city":"Bandung","country":"ID","lat":-6.9175,"lng":107.6191,"at":1790503540}
```
Keep-alive comment every 15s.
