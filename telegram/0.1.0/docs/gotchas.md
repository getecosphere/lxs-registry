# Gotchas

Production constraints that are NOT visible in the binary.

- **The bot cannot message a stranger first (Telegram platform rule).** A
  private-chat recipient must open the bot and send `/start` (or a deep link)
  before outbound push will work; a group must add the bot and someone must
  message it. Until then `resolve_chat` finds no channel and `/send` + `/ask`
  return `404 no_channel` — that response is the caller's email-fallback seam,
  not a bug.
- **Contacts only appear after the bot receives a message there.** The
  `contacts` collection is fed by inbound `getUpdates`, so bind-by-discovery
  (`GET /api/telegram/chats` → `/bind`) is inherently two-step: human messages
  bot first, operator binds second.
- **Single instance only.** The getUpdates long-poller holds one stream and
  persists its offset in the `settings` collection. Running two replicas splits
  updates and can skip/duplicate messages. Never scale this LXS horizontally.
- **Private chat_id == the user's id.** Resolution treats a bound
  `telegram_user_id` as reachable only when a `contacts` row of kind `private`
  with that id exists (proof the user messaged the bot).
- **Offset persists across restarts** (`settings._id = "poll"`), so the bot does
  not reprocess old messages after a restart. A crash mid-batch may re-deliver
  at most the in-flight batch (last id + 1 is written only after the batch).
- **`TELEGRAM_BOT_TOKEN` empty ⇒ outbound 503.** There is no startup guard; the
  service boots and long-polls are skipped (sleep loop) so an estate that has
  not been granted a token still passes health but cannot send.
- **HTML/Markdown content is passed through to Telegram.** When you set
  `parse_mode`, your text must be valid for that mode (Telegram rejects
  unescaped markup with 400). Prefer plain text or careful HTML.
- **Answers are matched, not commanded.** There is no free-form command routing:
  a reply answers a question; `/start <key>` self-binds; every other inbound
  text just updates the contact. Deeper conversational UX belongs to the
  producing estate, which consumes `/ask` + `/conversations/:id`.
- **DB default is localhost.** `MONGODB_URI` defaults to
  `mongodb://127.0.0.1:27017/telegram`; the database name comes from the
  connection string (else `telegram`).
