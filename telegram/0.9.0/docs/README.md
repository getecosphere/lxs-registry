# telegram — LXS docs

## Capability

Reusable **Telegram bot channel** for an estate. Owns outbound push to bound
recipients (private chats + groups), inbound message consumption via
`getUpdates` long-polling, the chat/binding map (estate identity → Telegram
chat), and **ask/answer conversations** so any producer can ask a human a
question over Telegram and collect the reply asynchronously. This is the
reliable push channel to a person that doesn't depend on email deliverability —
Telegram delivers or visibly fails fast.

## What it owns / never owns

- **Owns:** Bot API outbound (`sendMessage`), the getUpdates poll loop, binding
  records (`key` → chat), contacts (chats the bot has seen), and conversation
  documents (question → answer → status).
- **Never owns:** credentials — `TELEGRAM_BOT_TOKEN` is operator-set in `.env`.
  Message content decisions (a producing domain composes the text). User
  identity/auth — a consumer decides what `key` means (eco user email, ops
  handle, group slug) and binds it. Fallback delivery logic — if a `key` has no
  channel the caller should fall back to email (this domain returns `404
  no_channel`).

## Telegram ground rules (design constraints, not bugs)

- A bot **cannot initiate a chat** with a person who never contacted it. A
  private-chat recipient must first message the bot (`/start`); a group must
  add the bot and someone must message it. Only then can the bot push.
- This domain sees a chat **only after it receives a message there** (it
  long-polls `getUpdates`). Binding requires either the human to self-bind via a
  deep link, or the operator to bind after the contact appears in `chats`.
- One instance may run the poller; do **not** scale to multiple replicas of this
  domain (the getUpdates offset would split).

## Compose it

```yaml
# ecompose.yml
services:
  telegram-backend:
    lxs: telegram@0.1.0
    grants:
      secrets: [SERVER_PORT, MONGODB_URI, TELEGRAM_BOT_TOKEN]
```

Producers inside the estate call it over HTTP (internal). `TELEGRAM_BOT_TOKEN`
is created by the estate owner via @BotFather (never committed — Eco grants it).
Optional `SERVER_HOST=127.0.0.1` binds the (unauthenticated) API to loopback —
use it when the domain runs on a host with a public interface.

### Command webhook (optional)

Set `TELEGRAM_COMMAND_WEBHOOK` (and `TELEGRAM_COMMAND_TOKEN`) to turn the bot
into an interactive command surface. Any inbound message starting with `/` is
POSTed to the webhook as `{chat_id, user_id, username, text}` (Bearer token),
and the returned `{"reply": "..."}` is sent back to the chat. This keeps the
domain generic — the consumer owns the command set. Unset = notification-only
(the default).

## Typical flows

1. **Bind a recipient** — a user opens the bot and taps a deep link
   `https://t.me/<bot>?start=<key>` (arrives as `/start <key>`), which
   auto-binds `key` → their private chat. Or the operator binds explicitly:
   `POST /api/telegram/bind {"key":"ops:eko","telegram_user_id":12345}` after
   the user messaged the bot (id discoverable via `GET /api/telegram/chats`).
2. **Send** — `POST /api/telegram/send {"key":"ops:eko","text":"Deploy ok"}`.
   Attach a file with `file` (base64) + `filename` (PDF/zip via `sendDocument`,
   images inline via `sendPhoto`). If the key is unbound → `404 no_channel` →
   caller uses email instead.
3. **Ask & answer** — `POST /api/telegram/ask {"key":"ops:eko","text":"Deploy?","timeout_secs":180}`
   sends the question and returns a `conversation_id`. Poll
   `GET /api/telegram/conversations/<id>` until `status` becomes `answered`
   (reply matched) or `expired`. Replies are matched by Telegram reply-to, or
   FIFO when only one question is open in that chat.

## Delivery policy (per binding)

A binding can carry a policy for controlled destinations:

- `strip_links` — URLs and bare domains (`http(s)://…`, `www.…`, `t.me/…`,
  `domain.tld/path`) **and schemeless `owner/repo` locators**
  (`getecosphere/private-lxs-registry`, i.e. any token with a `/` that carries a
  `-` or `.`) are removed from outbound text and captions, replaced with
  `[tautan dihapus]`. Ordinary prose like `client/server` or `and/or` is left
  alone.
- `images_only` — only images reach the chat; any non-image attachment (PDF,
  zip, …) is dropped and the (stripped) text is sent instead.

Both default **off**. Set them at bind time, e.g. an investor channel that must
never leak a link:

```bash
eco telegram bind investor --chat -1004320838867 --strip-links --images-only
# or directly: POST /api/telegram/bind
#   { "key":"investor", "chat_id":-1004320838867, "strip_links":true, "images_only":true }
```

A **channel** is bound exactly like a group (negative `chat_id`), but the bot
must be an **administrator** of the channel to post.

## Docs index

- `api.md` — full endpoint reference with request/response JSON and errors
- `examples.sh` — executable smoke test
- `openapi.json` — machine-readable OpenAPI 3.0 spec
- `changelog.md` — version history + breaking changes
- `gotchas.md` — production-learned constraints and operational gotchas

## For AI agents

This LXS is distributed as a **binary only** — these docs are the entire
interface. Match `api.md` shapes exactly; run `examples.sh` against a pulled
binary or live estate URL before trusting behavior. Read `docs/gotchas.md` for
constraints invisible in the binary (notably the Telegram initiate-first rule
and single-instance polling).
