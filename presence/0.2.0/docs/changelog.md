# presence changelog

## 0.2.0 (2026-09-27)
- **IP → city fallback.** When a pulse arrives without coords (geolocation
  declined), the city/country/coords are resolved from the client IP (first
  `X-Forwarded-For` hop, else `X-Real-IP`) via a geo lookup
  (`PRESENCE_GEO_URL`, default `ip-api.com`), cached for 24h. Private/loopback
  addresses are skipped. This fills the "location decline" case.

## 0.1.0 (2026-09-27)
- Initial release: realtime fan-out hub for the Living Globe. `POST /api/event`
  records a first-name-only pulse with city/coords; `GET /api/stream` streams
  them over SSE; `GET /api/stats` exposes counters (`signups`, `signins`,
  `online`, `total`, `latest`).
