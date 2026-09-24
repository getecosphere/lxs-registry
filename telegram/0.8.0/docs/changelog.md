# Changelog

## 0.8.0
- `strip_links` now also removes **schemeless locators** — bare `owner/repo`
  paths such as `getecosphere/private-lxs-registry` — in addition to URLs and
  bare domains. Any `/`-token carrying a `-` or `.` is replaced with
  `[tautan dihapus]`; ordinary prose (`client/server`, `and/or`, `TCP/IP`) is
  left untouched.

## 0.7.0
- **Per-binding delivery policy** for controlled destinations (e.g. a channel
  that must never leak a link):
  - `strip_links` — URLs and bare domains (`http(s)://…`, `www.…`, `t.me/…`,
    `domain.tld/path`) are removed from outbound text and captions and replaced
    with `[tautan dihapus]`. `/send` and `/ask` both honor it; the response
    reports `links_stripped`.
  - `images_only` — only images reach the chat; any non-image attachment
    (PDF, zip, …) is dropped and the text is sent instead (`file_dropped:true`).
  - Set at bind time: `POST /api/telegram/bind { …, "strip_links": true,
    "images_only": true }`; mergeable on re-bind. CLI:
    `eco telegram bind <key> --chat <id> --strip-links --images-only`.
  - Defaults are `false`, so all existing bindings are unchanged.
- `kind` may now be `channel` (channels use the same `chat_id` path as groups).
- NDJSON: `telegram links stripped` (with `links_stripped` count) and
  `attachment dropped by binding policy`.

## 0.6.0
- `TELEGRAM_AUTO_BIND` (default 1): set `0` to disable the `/start <key>`
  self-bind so the consumer's command webhook receives the raw
  `/start <token>` (used by the eco user bot, where account binding is owned
  by the agent).

## 0.5.0
- **Allowlist (`TELEGRAM_ALLOWED_USER_IDS`)**: when set, messages from any other
  Telegram user are ignored entirely (not recorded, not forwarded, not
  answered). Defense in depth for bots that should only serve their owner.

## 0.4.1
- `parse_mode` now also applies to the **caption** of an attached file (HTML/
  Markdown formatting on `sendPhoto`/`sendDocument`).

## 0.4.0
- **File attachments**: `POST /api/telegram/send` accepts optional `file`
  (base64) + `filename`; images go via `sendPhoto` (inline preview), everything
  else via `sendDocument` (PDF, zip, …). `text` becomes the caption; captions
  over 1024 chars are sent as a separate message first. 45 MB limit.

## 0.3.1
- Fix: the command webhook now receives **every** text message, not only
  `/commands`. A confirmation reply like `YA` (no leading slash) never reached
  the consumer before, so two-step confirmations were stuck. The consumer
  returns `None` for ordinary text, which then falls through to conversation
  answer matching as before.

## 0.3.0
- Optional **command webhook**: inbound messages starting with `/` are POSTed
  to `TELEGRAM_COMMAND_WEBHOOK` (Bearer `TELEGRAM_COMMAND_TOKEN`) and the
  returned `{"reply": "..."}` is sent back to the chat. Keeps this domain
  generic — the consumer owns the command set (e.g. eco's `/nodes`). Unset =
  no command handling (notification-only bots unchanged).

## 0.2.1
- Fix: store `last_seen` / `answered_at` as RFC 3339 **strings** (the
  convention email-manager uses) instead of BSON dates. Mixing the two made
  contact/conversation reads fail to deserialize, so `GET /api/telegram/chats`
  returned `[]` even though inbound messages were stored.

## 0.2.0
- `SERVER_HOST` (optional) — bind address; set `127.0.0.1` to keep the
  unauthenticated domain API off the public interface (used by the agent-host
  ops bot). Default remains `0.0.0.0` for estate-internal composition.

## 0.1.0 (initial release)
- Initial release — LXS manifest `telegram@0.1.0`.
  - Telegram bot channel domain: outbound `sendMessage` (private + group),
    inbound `getUpdates` long-polling with persisted offset, bindings
    (`key` → chat) with deep-link self-bind (`?start=<key>`), contacts ledger,
    and ask/answer conversations (reply-to or FIFO matching, timeout expiry).
  - MongoDB persistence (`bindings`, `contacts`, `conversations`, `settings`).
  - NDJSON logs to stdout (tracing-json), provider health endpoint.
