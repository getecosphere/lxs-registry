# gateway API / behavior

Every request goes through the route table; the only endpoints of its own are
`GET /healthz` and `GET /readyz` (loopback health probes). This document defines
the `gateway.json` config and the observable behavior.

## Config (`GATEWAY_CONFIG`)

```json
{
  "roles": { "public": "public", "authenticated": "auth" },
  "routes": [
    {
      "path": "/auth-api/auth/login",
      "upstream": "127.0.0.1:20605",
      "level": "public",
      "strip": "/auth-api",
      "rewrite": "/api"
    },
    {
      "path": "/api/auth/*",
      "upstream": "127.0.0.1:20605",
      "level": "auth"
    },
    {
      "path": "/api/v1/*",
      "upstream": "127.0.0.1:20606",
      "level": "public"
    }
  ]
}
```

### RouteRule fields

| Field | Required | Meaning |
|---|---|---|
| `path` | yes | Pattern. Ends with `/*` for a prefix match, `*` for a stem match, otherwise exact. |
| `upstream` | no | `127.0.0.1:<port>` target (single-upstream case). |
| `upstreams` | no | Pool of `127.0.0.1:<port>` targets. When non-empty it wins over `upstream`; requests round-robin across the pool with passive health (a member is ejected for a short cooldown after a connection failure or `502/503/504`, then re-probed). |
| `level` | yes | `public` \| `auth` \| `role:<name>`. |
| `strip` | no | Path prefix to strip before forwarding (with `rewrite`). |
| `rewrite` | no | Replacement prefix (used with `strip`). |
| `cookie` | no | Session cookie name to fall back to when no Bearer token is sent. |

Each route must declare `upstream` or `upstreams`. When every pool member is
ejected the gateway fails **open** (tries them all) rather than hard-503.

On a connection failure the gateway **fails over** to the next healthy member
immediately; for a **singleton** upstream it retries the same member for a
short bounded window (~3.5 s), so a `systemctl restart` (RestartSec ~2 s) does
not drop in-flight requests. Retries happen only on a connect failure (the
request never reached the server) and replay a buffered body (≤4 MiB); larger
uploads stream once.

### Health & hot-reload

- `GET /healthz` / `GET /readyz` → `200 {"status":"UP","routes":N}` (liveness +
  readiness for a gateway replica behind a load balancer).
- `SIGHUP` (`systemctl reload`) re-reads `GATEWAY_CONFIG` and swaps the route
  table atomically, so an upstream-pool change applies without a restart. A
  malformed file is logged and the current routes are kept.

### Route matching

Longest-prefix wins; an exact path beats a wildcard of the same length;
longer prefixes beat shorter ones.

## Behavior / response codes

| Case | Status | Body |
|---|---|---|
| No route matches the path | `404` | JSON `{"error":"no route declared for this path (deny by default)"}` or HTML error page |
| `auth` route, missing/invalid token | `401` | `{"error":"missing or invalid bearer token"}` |
| `auth` route, token role not authenticated | `403` | `{"error":"access denied for this role"}` |
| `role:<name>` route, role mismatch | `403` | `{"error":"access denied for this role"}` |
| Upstream unreachable / bad response | `502` | `{"error":"..."}` |
| Authorized / public request | `200` (upstream status) | upstream body |

### Error pages & content negotiation

Gateway-origin errors are rendered as JSON when the client asks for JSON and as
a styled HTML page otherwise:

- **JSON**: `Accept` contains `application/json` (or `application/*+json`), OR
  the path starts with `/api/` and `Accept` does not explicitly ask for HTML.
  Body is `{"error": "<message>"}` — includes the technical detail (upstream
  addresses, etc.).
- **HTML**: everything else. Uses the built-in Ecosphere design page unless the
  estate declares its own template. HTML bodies never leak internal topology —
  the message is a friendly generic text; the requested path is shown as
  `METHOD /path`.

### Custom error page (`error_page`)

Set `error_page` in `gateway.json` to an absolute path of an HTML template, or
declared `error_page:` under the main `estates:` entry in `ecompose.yml`
(configgen ships the file next to `gateway.json` and wires the path). The
template may use these tokens (all HTML-escaped by the gateway):

| Token | Meaning |
|---|---|
| `{{STATUS}}` | Numeric status code, e.g. `404` |
| `{{TITLE}}` | Status title, e.g. `Not found` |
| `{{MESSAGE}}` | Friendly message for the status |
| `{{METHOD}}` | Request method, e.g. `GET` |
| `{{PATH}}` | Requested path |
| `{{ESTATE}}` | Estate name |
| `{{ACTION}}` | Status-appropriate recovery link (raw HTML, not escaped): a "Sign in" button linking to `/signin` on `401`, empty otherwise |

If the file is missing/unreadable the gateway logs a warning and falls back to
the built-in page.

## Identity propagation

On authorized requests the gateway injects:

```
X-Eco-User: <sub>,roles=<role>
```

Any client-supplied `X-Eco-User` is stripped before forwarding. The
`Authorization` header is preserved so upstream services that verify the token
themselves (articles, storage, profile, ...) keep working unchanged.

## Path rewriting

When a request path starts with `strip`, it is replaced with `rewrite` before
forwarding — `/auth-api/auth/login` + `strip:/auth-api` + `rewrite:/api`
becomes `/api/auth/login` upstream.

## Pre-release gate (`prerelease`)

An optional top-level block that hides a whole estate behind one launch page
while it is staging. When present, the gateway runs it **after** the http→https
upgrade and **before** routing/authorization: any request whose path does not
match an `exempt` pattern is answered with `status` (default `302`) and
`Location: <redirect>`.

```json
{
  "roles": { "public": "public", "authenticated": "auth" },
  "routes": [ { "path": "/returns", "upstream": "127.0.0.1:20606", "level": "public" } ],
  "prerelease": {
    "redirect": "https://example.com/returns",
    "status": 302,
    "exempt": ["/returns", "/_astro/*", "/images/*", "/favicon.svg", "/robots.txt"]
  }
}
```

| Field | Required | Meaning |
|---|---|---|
| `redirect` | yes | Absolute URL every non-exempt request is sent to. |
| `status` | no | Redirect status; default `302` (temporary, so removing the gate later isn't defeated by a cached 301). |
| `exempt` | no | Path patterns that stay reachable: exact, `/*` prefix, or `*` stem. Without exempting the launch page and its assets the browser would never render it. |

Redirect responses carry `Cache-Control: no-store` and `X-Robots-Tag: noindex`.

Configgen writes this block only for server-side (prod) deploys, from the main
estate's `prerelease_redirect:` (and optional comma-separated
`prerelease_exempt:`). The client's local-dev gateway.json never includes it, so
`eco up dev` and direct local requests are un-gated.
