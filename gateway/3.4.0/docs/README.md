# gateway — LXS docs

## Capability

The estate **front door**. A plain HTTP reverse-proxy + authorization engine,
all **deny by default**: routes are declared in `gateway.json` (written by eco's
`configgen` from `ecompose.yml` `access:` declarations), a request matching no
route returns `404`, `public` routes forward as-is, `auth` routes require a
valid Bearer JWT with an authenticated role, and `role:<name>` routes require a
JWT whose role claim equals `<name>`. The gateway verifies the token ONCE at the
edge and injects `X-Eco-User: <sub>,roles=<role>` upstream (any client-supplied
`X-Eco-User` is stripped), and supports `strip`/`rewrite` path-prefix
transforms (e.g. `/auth-api/*` → `/api/*`).

Gateway-origin errors are **content-negotiated**: API clients that ask for JSON
(`Accept: application/json`, or a `/api/*` path without an explicit HTML Accept)
get a machine-readable `{"error": ...}` body; browsers get a styled HTML page
following the Ecosphere design system. An estate can override the default page
with its own template via `error_page:` in `ecompose.yml` (see `api.md`).

An estate can go into **pre-release**: a `prerelease` block in `gateway.json`
(for prod only, written by configgen from `prerelease_redirect:`) sends every
request whose path is not in `exempt` to one launch page with a `302`, before
routing/authorization — so a staging site hides all features behind a single
`/returns`. See `api.md`.

TLS is deliberately absent: Cloudflare Tunnel terminates TLS at the edge. The
gateway still **forces HTTPS at the front door** — when the edge reports the
original request was plain HTTP (`X-Forwarded-Proto: http`, or `CF-Visitor`),
it answers a method-preserving `308` redirect to the same host/path/query over
`https` before routing. This is what stops a visitor on `http://<host>/` from
getting a page whose https-baked API calls the browser blocks as cross-scheme
CORS. Direct local requests (`eco up dev`, health probes) carry no forwarded
scheme and are never redirected. Opt out per estate with `force_https: false`
in `gateway.json` (default `true`).

## Compose it

```yaml
# ecompose.yml — declaring a `gateway` service flips the estate onto the
# middleware model: configgen writes gateway.json from access.routes + roles.
services:
  gateway:
    lxs: gateway@0.1.0
    grants:
      secrets: [SERVER_PORT, JWT_SECRET, GATEWAY_CONFIG]
```

Then declare `access.routes` on every HTTP service and an `auth.roles` block.
`eco deploy` writes `gateway.json` + the service `.env` and exposes the
estate through the gateway port.

To replace the built-in error page with the estate's own design, declare it on
the main estate:

```yaml
estates:
  myestate:
    hostname: myestate.com
    error_page: error.html   # relative to the estate root, {{PLACEHOLDER}} template
```

## Environment

| Variable | Required | Purpose |
|---|---|---|
| `SERVER_PORT` | yes | Listen port (plain HTTP). |
| `JWT_SECRET` | yes | HS512 signing key; refuses to start without it. |
| `GATEWAY_CONFIG` | yes | Path to the `gateway.json` route table. |

## Docs index

- `api.md` — the gateway.json config schema + behavior/response codes
- `changelog.md` — version history
- `examples.sh` — local run smoke test
- `gotchas.md` — operational constraints

## Source

- Repo: https://github.com/getecosphere/gateway
