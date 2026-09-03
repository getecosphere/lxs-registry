# Changelog

## 0.1.0 (initial release)
- Initial release — LXS manifest `telegram@0.1.0`.
  - Telegram bot channel domain: outbound `sendMessage` (private + group),
    inbound `getUpdates` long-polling with persisted offset, bindings
    (`key` → chat) with deep-link self-bind (`?start=<key>`), contacts ledger,
    and ask/answer conversations (reply-to or FIFO matching, timeout expiry).
  - MongoDB persistence (`bindings`, `contacts`, `conversations`, `settings`).
  - NDJSON logs to stdout (tracing-json), provider health endpoint.
