# Gotchas

- `JWT_SECRET` is required and must be the **shared estate secret** (configgen
  injects it); the gateway refuses to start without it.
- The gateway is **deny by default** — every path a service must serve has to be
  declared in `access.routes`. Miss one and it is a `404` (never a catch-all
  forward); declare it or accept the styled error page.
- `auth` routes treat any role not declared `public` as authenticated, so
  declare the `public` role explicitly in `auth.roles` if you have one.
- Multi-role JWTs carry both the legacy primary `role` and a `roles` array;
  gateway accepts either shape and grants a `role:<name>` route when any role
  matches.
- The gateway forwards the `Authorization` header unchanged, so upstream
  services that validate JWTs themselves keep working.
- TLS is not handled here — Cloudflare Tunnel terminates TLS in front. The
  gateway does, however, **redirect plain HTTP to HTTPS** (308) when the edge
  reports the original request was `http` via `X-Forwarded-Proto`/`CF-Visitor`,
  so a visitor who types `http://` never gets a page whose https-baked API
  calls the browser blocks as cross-scheme CORS. Direct local requests carry
  no forwarded scheme and are left alone. Disable with `force_https: false` in
  `gateway.json` only if an estate is intentionally served over plain HTTP.
- The gateway must be reachable only from the reverse-proxy/tunnel layer on a
  localhost-reachable port; never expose it directly on a public interface.
