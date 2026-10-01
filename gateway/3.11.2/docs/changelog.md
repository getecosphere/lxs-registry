# Changelog

## 3.11.2 (2026-10-01)
- **Empty Bearer no longer blocks upstream bearer synthesis.** 3.11.1 made
  `resolve_token` fall back to the session cookie when a tokenless browser sent
  `Authorization: Bearer ` (empty) — but `apply_forward_identity` still only
  synthesized `Authorization: Bearer <token>` when the header was *absent*, so
  upstream services that verify the token themselves (e.g. Notes) received the
  empty bearer and 401'd. An empty client bearer is now treated as "no bearer"
  for forwarding too, so cookie-authenticated API calls work. Bugfix.

## 3.11.1 (2026-09-30)
- **Empty Bearer no longer shadows the session cookie.** A tokenless browser
  (HttpOnly-cookie model) that still sends `Authorization: Bearer ` (empty
  token) previously made `resolve_token` pick the empty bearer and skip the
  cookie fallback, so every cookie-authenticated API route 401'd. An empty
  bearer is now treated as absent and the cookie is used. Additive fix.

## 3.11.0 (2026-09-30)
- **Enforcing CSP (safe subset).** Every response now carries
  `Content-Security-Policy: base-uri 'self'; object-src 'none'` — the two
  directives that are safe for any estate (no inline-script refactor, no
  embedding/payment impact). `base-uri` blocks `<base>` injection; `object-src`
  blocks plugin/object embedding. The broader policy stays report-only.

## 3.10.0 (2026-09-30)
- **Session cookie fallback for authenticated routes.** An `auth`/`role:*`
  route that does not declare `cookie:` now reads the estate-wide session
  cookie (`eco_token`) — so an HttpOnly-cookie session authenticates API routes
  without per-route config. Bearer still takes precedence; a route can still
  pin a specific cookie name. Backward compatible and additive.

## 3.9.0 (2026-09-30)
- **Report-only CSP baseline.** Every response also carries
  `Content-Security-Policy-Report-Only` (never blocks) so inline-script usage
  that would violate a strict policy is surfaced ahead of enforcement. No
  report-uri yet, so there is no network overhead. An upstream-provided CSP is
  never overwritten.

## 3.8.1 (2026-09-30)
- **Security: `jsonwebtoken` updated to 10.4.0** (CVE-2026-25537, type
  confusion → potential authorization bypass; patched in 10.3.0). Enables the
  `rust_crypto` provider (pure-Rust, musl-friendly). No API/behaviour change.

## 3.8.0 (2026-09-30)
- **Cookie-only sessions.** When a client authenticates with the session
  **cookie** and sends no `Authorization` header (the HttpOnly-cookie model,
  where JS can no longer read the token), the gateway now synthesizes
  `Authorization: Bearer <token>` from the verified cookie token before
  forwarding upstream. Downstream LXS that verify the token themselves
  (profile, storage, ekoin, …) therefore keep working unchanged, and the
  browser never needs to hold a JS-readable token. A client-provided bearer is
  still preferred and never overwritten — fully backward compatible.

## 3.7.0 (2026-09-30)
- **Baseline security headers.** Every response the gateway serves now carries
  `X-Content-Type-Options: nosniff`, `Referrer-Policy:
  strict-origin-when-cross-origin`, and `Strict-Transport-Security:
  max-age=31536000` — applied to proxied upstream responses (so every composed
  LXS UI inherits them) and to gateway-origin responses (health, error pages,
  https/pre-release redirects). An upstream-provided value is never overwritten,
  so a service can opt out per header. Framing/CSP policy is intentionally left
  to the estate (`frame-ancestors` differs between estates that embed and those
  that are embedded).

## 3.6.0 (2026-09-29)
- **Pool retry across a full pass.** On a connection failure across a pool the
  gateway now makes two passes (fail over member-by-member, then a short pause
  and retry) so a brief moment where every replica is mid-restart is ridden out
  instead of surfacing as a 502. Measured on getecosphere.com: a rolling restart
  of both replicas under load went from 1/200 to 0 failed requests.

## 3.5.0 (2026-09-29)
- **Rolling-restart tolerance.** On a connection failure the gateway now
  **fails over** to the next healthy pool member immediately; for a
  **singleton** upstream it retries the same member a few times over a short,
  bounded window (~3.5 s) so a `systemctl restart` (RestartSec ~2 s) no longer
  surfaces as a 502 to in-flight requests. Small/empty request bodies are
  buffered (≤4 MiB) so they can be replayed on retry; larger/streamed uploads
  still send once. Requests are retried only on a *connect* failure (the request
  never reached the server) — safe for any method.

## 3.4.0 (2026-09-29)
- **Upstream pool (B1 step 4).** A route may declare `upstreams: ["127.0.0.1:<port>", …]`
  instead of a single `upstream`. Requests round-robin across the pool;
  **passive health** ejects a member for a short cooldown after a connection
  failure or a `502/503/504` and re-probes it, so a replica can be restarted or
  added without dropping traffic. `upstream` (single) stays as the 1-element
  case — existing `gateway.json` is unchanged. When every member is ejected the
  pool fails **open** (tries them all) rather than hard-503.
- **SIGHUP hot-reload.** The gateway re-reads `gateway.json` on `SIGHUP`
  (`systemctl reload`), swapping the route table atomically — an upstream-pool
  change (replica added/removed, deploy swap) applies without restarting the
  front door. Malformed config on reload is logged and the current routes are
  kept.
- **`GET /healthz` + `GET /readyz`.** The gateway is now health-checkable on
  loopback (returns `{"status":"UP","routes":N}`), so a gateway replica can be
  gated by a load balancer / start-before-kill deploy like any other service.

## 3.3.0 (2026-09-27)
- **Pre-release gate.** A new optional `prerelease` block in `gateway.json`
  (`{ "redirect", "status" = 302, "exempt": [...] }`) makes the gateway send
  every request whose path is not exempt to `redirect`, before routing or
  authorization — so a staging estate can hide every feature and show only one
  launch page (`/returns`). Written by server-side configgen from the main
  estate's `prerelease_redirect:` / `prerelease_exempt:` keys; the client's
  local-dev gateway.json never carries it, so `eco up dev` stays ungated.
  Responses are `Cache-Control: no-store` + `X-Robots-Tag: noindex`. Exempt
  patterns use the same shape as routes (`/returns` exact, `/_astro/*` prefix,
  `/admin*` stem).

## 3.2.0 (2026-09-21)
- **HTTP → HTTPS redirect at the front door.** The gateway now upgrades a
  visitor who arrives over plain HTTP to HTTPS with a method-preserving `308`,
  using the original scheme the edge reports in `X-Forwarded-Proto` (falling
  back to `CF-Visitor`). Previously a gateway estate served `http://<host>/`
  with `200`; because every API URL is baked `https://` and CORS origins are
  https-only, the browser then blocked the page's own API calls as a
  cross-scheme CORS failure and showed a misleading "connection failed" —
  before any request reached a backend. The redirect runs before routing and
  authorization, so every path (including undeclared ones) is upgraded.
  Direct local requests (`eco up dev`, health probes) carry no forwarded
  scheme and are never redirected. Configurable per estate via `force_https`
  in `gateway.json` (default `true`).

## 3.1.0 (2026-08-25)
- Gateway now authorizes `role:<name>` routes against Auth's complete JWT
  `roles` array while retaining the legacy primary `role` fallback.

## 3.0.1 (2026-08-20)
- Artifacts: added `darwin/arm64` so estates composing `gateway@3.0.0+` can run `eco up dev` locally.

## 3.0.0 (2026-08-19)
- **Single-session enforcement at the edge.** The gateway re-validates each
  protected request's `sid` against auth's `session-status` endpoint
  (`AUTH_SESSION_CHECK_URL`, injected by configgen). A token whose session was
  revoked by a newer login is denied 401 — the same account can no longer be
  signed in on two devices anywhere in the estate. Fails closed: without the
  check URL the gateway denies rather than trusts.
- **Breaking:** bearer tokens without a `sid` claim are rejected when
  `SESSION_REQUIRED` is true (default) — every client must re-login once after
  upgrade. Set `SESSION_REQUIRED=false` for a graceful legacy window.
- Contract: added optional `AUTH_SESSION_CHECK_URL` (managed:
  auth-session-check) and `SESSION_REQUIRED`; contract upgraded to v2
  `fields` schema.

## 2.0.0 (2026-08-19)
- Logging contract: service logs now emitted as newline-delimited JSON (NDJSON) to stdout per the platform LXS logging contract (`ts`/`level`/`msg` + optional `service`,`request_id`,`status`,`latency_ms`,`user_id`,`error`). Breaking change — log output format changed.

## 0.4.0

- the built-in 401 error page now renders a "Sign in" button linking to
  `/signin`; the new `{{ACTION}}` token lets custom error pages show a
  status-appropriate recovery link (empty when there's nothing to recover to)

## 0.2.0

- content-negotiated error pages: API clients get JSON, browsers get a styled
  HTML error page following the Ecosphere design system (default built in)
- undeclared routes now return `404` instead of `403` (the resource simply
  isn't routed; `401`/`403` still mean authorization failures)
- `error_page` config field: estate templates with `{{STATUS}}`/`{{TITLE}}`/
  `{{MESSAGE}}`/`{{METHOD}}`/`{{PATH}}`/`{{ESTATE}}` tokens, wired by configgen
  from `error_page:` in `ecompose.yml`; HTML pages never leak internal topology

## 0.1.0

- initial publish — the estate front door (default-deny reverse-proxy + JWT/role authorization)
- multi-arch artifacts: linux/amd64, linux/arm64, darwin/arm64, darwin/amd64, windows/amd64
