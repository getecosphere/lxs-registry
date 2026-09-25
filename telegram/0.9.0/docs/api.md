# telegram — API reference

Base URL is the domain's own port. All endpoints accept/return JSON. No auth on
any endpoint (reachable only from inside the estate network / agent host).

## Health

### `GET /health` and `GET /api/telegram/health`

```json
{ "status": "ok", "service": "telegram", "provider_configured": true }
```

`provider_configured:false` means `TELEGRAM_BOT_TOKEN` is empty — outbound
returns `503`.

## Bindings

### `POST /api/telegram/bind`

Associate a `key` (recipient identity chosen by the producer) with a Telegram
chat. At least one of `telegram_user_id` (private) or `chat_id` (group or
channel) is required. If `chat_id` is omitted for a private user who has already
messaged the bot, the stored contact is resolved automatically.

Two optional per-binding **delivery policies** (for channels where content must
be controlled):

- `strip_links` — URLs and bare domains (`http(s)://…`, `www.…`, `t.me/…`,
  `domain.tld/path`) and schemeless `owner/repo` locators (`getecosphere/private-lxs-registry`;
  any token with a `/` that carries a `-` or `.`) are removed from outbound
  text/captions and replaced with `[tautan dihapus]`.
- `images_only` — only images reach the chat; any non-image attachment (PDF,
  zip, …) is dropped and the (stripped) text is sent instead.

```json
{ "key": "ops:eko", "kind": "private", "telegram_user_id": 123456789 }
{ "key": "team-alerts", "kind": "group", "chat_id": -1001234567890 }
{ "key": "investor", "kind": "channel", "chat_id": -1004320838867,
  "strip_links": true, "images_only": true }
```

Response:

```json
{ "ok": true, "key": "ops:eko", "kind": "private",
  "chat_id": null, "telegram_user_id": 123456789,
  "strip_links": false, "images_only": false, "bound": false }
```

`bound` is `true` once a chat can be reached (chat_id resolved). The same key
can be re-bound to merge/update fields (including the policies).

### `GET /api/telegram/bindings`

```json
{ "bindings": [
  { "key": "ops:eko", "kind": "private", "chat_id": 123456789,
    "telegram_user_id": 123456789, "label": null,
    "strip_links": false, "images_only": false } ] }
```

### `DELETE /api/telegram/bindings/:key`

```json
{ "ok": true, "key": "ops:eko", "deleted": true }
```

## Chats (contacts the bot has seen)

### `GET /api/telegram/chats`

Chats where the bot has received at least one message (private DM or a group
that messaged it). Use this to discover a user's id/chat for binding.

```json
{ "chats": [
  { "chat_id": 123456789, "kind": "private", "username": "eko",
    "title": null, "first_name": "Eko", "last_seen": "2026-09-03T17:00:00Z" } ] }
```

## Sending

### `POST /api/telegram/send`

`key` must be bound to a reachable chat; otherwise `404 no_channel` (the caller
should fall back to email). `parse_mode` optional: `HTML`, `Markdown`,
`MarkdownV2` (absent = plain text; unsupported values are rejected).

If the binding has `strip_links`, URLs are removed from `text`/captions before
sending. If it has `images_only`, a non-image `file` is dropped and only the
text is sent. The response reports what was done.

Text only:

```json
{ "key": "ops:eko", "text": "Deploy finished", "parse_mode": "Markdown" }
```

With a file attachment (base64; images render inline via `sendPhoto`, anything
else goes via `sendDocument`). `text` becomes the caption:

```json
{ "key": "ops:eko", "text": "Nightly report attached",
  "filename": "report.pdf", "file": "<base64>" }
```

Response (text):
`{ "ok": true, "key", "chat_id", "message_id", "links_stripped": 0, "file_dropped": false }`
Response (file): adds `"kind": "file"` and `"filename"`. `links_stripped` counts
removed URLs; `file_dropped:true` means an images-only binding rejected a
non-image attachment (the text was still sent).

Limits: 45 MB decoded file; caption 1024 chars (longer text is sent as a
separate message first). The request body limit is 64 MB (≥ 0.9.0), so a
45 MB file fits after base64 inflation (~60 MB). Before 0.9.0 the router kept
axum's 2 MB default and attachments over ~1.5 MB failed with HTTP 413.

## Ask / answer conversations

### `POST /api/telegram/ask`

Sends a question to a bound chat and opens a conversation that waits for the
human's reply. `timeout_secs` (15–3600, default 300) controls expiry.

```json
{ "key": "ops:eko", "text": "Deploy to production now?", "timeout_secs": 180 }
```

Response (`201`):

```json
{ "conversation_id": "8f2c…", "key": "ops:eko", "chat_id": 123456789,
  "message_id": 43, "status": "open", "expires_at": "2026-09-03T17:03:00Z" }
```

### `GET /api/telegram/conversations`

All conversations (open/answered/canceled/expired), newest first. Open
conversations past `expires_at` are lazily marked `expired`.

```json
{ "conversations": [
  { "conversation_id": "8f2c…", "key": "ops:eko", "chat_id": 123456789,
    "status": "answered", "text": "Deploy to production now?",
    "answer": "yes", "reply_to_message_id": 43,
    "created_at": "…", "answered_at": "…", "expires_at": "…" } ] }
```

### `GET /api/telegram/conversations/:id`

Single conversation. **Poll this** to wait for a reply: `status` flips to
`answered` (with `answer`) when the human replies, or `expired` past timeout.

### `POST /api/telegram/conversations/:id/cancel`

Closes an open question early (`409` if already closed).

```json
{ "ok": true, "conversation_id": "8f2c…", "status": "canceled" }
```

## Error shapes

Errors are plain-text strings with a status code, except `/health`. The two
that matter for fallback logic:

- `404 no_channel: '<key>' has no Telegram channel — bind it first …` — no
  reachable chat for the key → use the email fallback.
- `503 provider not configured: TELEGRAM_BOT_TOKEN is empty` — no token set.

## Reply matching rules (inbound)

When a human messages the bot, an open conversation in that chat is answered if:

1. the message is a **reply to** the bot's question message, or
2. exactly one open conversation exists for that chat (FIFO: earliest open is
   answered when several are open and no reply-to is used).
