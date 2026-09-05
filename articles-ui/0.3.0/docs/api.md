# articles-ui API

The binary is a self-contained native Rust SSR service. There is no separate
REST API — it renders HTML server-side against the `articles` backend.

## Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/articles/` | Rendered list of published articles |
| GET | `/articles/:slug` | Rendered single article (SEO + OpenGraph, full CommonMark body) |

## Env contract

| Var | Required | Default | Purpose |
|---|---|---|---|
| `SERVER_PORT` | yes | — | Listen port (eco fills it) |
| `ARTICLES_API_URL` | no | `http://127.0.0.1:8080/api` | Articles REST base; `/articles` appended unless already present |
| `PUBLIC_SITE_URL` | no | `https://leadme.getecosphere.app` | Canonical/OG origin |
| `HTML_LANG` | no | `id` | `<html lang>` |
| `BRAND_TEXT` | no | `Leadme.` | Brand label in the top-left |
| `HOME_URL` | no | `/` | Brand link target |
| `NAV_LABEL` | no | `Dashboard` | Secondary top nav label |
| `NAV_HREF` | no | `/dashboard` | Secondary top nav target |
| `LIST_TITLE` | no | `Ruang untuk bertumbuh dengan sadar.` | Articles index heading |
| `LIST_LEAD` | no | `Bacaan tentang Seven Habits…` | Index lead + list-page meta |
| `EMPTY_TEXT` | no | `Belum ada artikel yang diterbitkan.` | Empty / not-found copy |
| `DEFAULT_EXCERPT` | no | `Baca dan praktikkan pelan-pelan.` | Card fallback excerpt |
| `BACK_TEXT` | no | `← Semua artikel` | Detail-page back-to-list label |

## Runtime

- Binary: self-contained static Linux amd64 and macOS Apple Silicon.
- Rendering: full CommonMark via pulldown-cmark at request time.
- Logs: NDJSON to stdout per the platform LXS logging contract.
