# articles-ui changelog

## 0.3.0 (2026-09-05)

- Full **CommonMark** rendering of the article body (pulldown-cmark): code
  blocks, inline code, links, bold/emphasis, blockquotes, ordered/unordered
  lists, tables, strikethrough, and task lists — with matching reader CSS.
  Previously only paragraphs, `##` headings, and `- ` lists rendered; fenced
  code and links appeared as raw markdown.
- **White-label reader chrome** via optional env (`HTML_LANG`, `BRAND_TEXT`,
  `HOME_URL`, `NAV_LABEL`, `NAV_HREF`, `LIST_TITLE`, `LIST_LEAD`,
  `EMPTY_TEXT`, `DEFAULT_EXCERPT`, `BACK_TEXT`). Defaults preserve the original
  copy, so estates that do not opt in render exactly as before.
- Title/description/Og derived per estate brand; detail fallback description
  and list meta no longer hardcode the Leadme value.
- No API or route contract change. Logging contract unchanged (NDJSON).

## 0.2.0 (2026-08-22)

- Replace the Astro/Bun packaging path with a self-contained native Rust SSR
  binary. The public routes and Articles API contract are unchanged.
- Render published Markdown at request time and keep NDJSON stdout logging.

## 0.1.1 (2026-08-22)

- Add a darwin/arm64 artifact so the pluggable SSR UI works in `eco up dev`
  on the Mac build farm as well as on the Linux production target.

## 0.1.0 (2026-08-20)

- Initial release: `articles-ui` standalone Astro SSR binary.
- Splits the pluggable `@articles/frontend` library into a deployable UI
  service: `/articles/` + `/articles/[slug]/` rendered server-side with
  SEO/OpenGraph, bun-compiled into a single self-contained linux-x64 binary.
- `eco lxs build` gains Astro/Node bun-compile support for UI LXS.
