# articles-ui

Standalone native SSR UI for the **articles** domain — ships the article list
and article-detail pages (`/articles/` and `/articles/[slug]/`) with SEO +
OpenGraph, rendered against the articles REST API. Built by `eco lxs build`
into a self-contained Rust binary for production and local Eco development.

## What it owns

Only the public article browsing surface (list + detail). It does **not** own
article authoring/admin, identity, or any estate data — those stay in the
`articles` backend and other domains.

## Compose

```yaml
services:
  articles-ui:
    lxs: articles-ui@0.3.0
    config:
      ARTICLES_API_URL: http://127.0.0.1:<articles-backend-port>/api/articles
      PUBLIC_SITE_URL: https://<estate-host>
      BRAND_TEXT: <estate name>
```

- `ARTICLES_API_URL` — full base URL of the `articles` REST API (origin +
  `/api/articles`); if it does not end in `/articles` the UI appends it.
- `PUBLIC_SITE_URL` — public origin used for canonical / OpenGraph URLs.

## Markdown rendering

The detail page renders the article body with a full **CommonMark** renderer:
headings, paragraphs, bold/emphasis, links, blockquotes, ordered and unordered
lists, tables, strikethrough, task lists, and fenced code blocks (with syntax
highlighting styling hooks). Raw HTML in article bodies is passed through as
authored — the Articles API restricts writing to the admin role.

## White-label copy (v0.3.0+)

Reader chrome is estate-configurable via optional env; every key falls back to
the original copy so existing consumers render identically until they opt in:

| Var | Default | Purpose |
|---|---|---|
| `HTML_LANG` | `id` | `<html lang>` |
| `BRAND_TEXT` | `Leadme.` | Brand label in the top-left |
| `HOME_URL` | `/` | Brand link target |
| `NAV_LABEL` | `Dashboard` | Secondary top nav label |
| `NAV_HREF` | `/dashboard` | Secondary top nav target |
| `LIST_TITLE` | `Ruang untuk bertumbuh dengan sadar.` | Articles index heading |
| `LIST_LEAD` | `Bacaan tentang Seven Habits…` | Articles index lead + list-page meta |
| `EMPTY_TEXT` | `Belum ada artikel yang diterbitkan.` | Empty / not-found copy |
| `DEFAULT_EXCERPT` | `Baca dan praktikkan pelan-pelan.` | Card fallback when an article has no excerpt |
| `BACK_TEXT` | `← Semua artikel` | Detail-page back-to-list label |

## Routes

- `GET /articles/` — published article list.
- `GET /articles/:slug` — one published article (reader-safe not-found page
  if unpublished/missing).

## Runtime

The compiled binary runs on each supported platform with no node_modules.
Logs are NDJSON to stdout per the platform LXS logging contract.
