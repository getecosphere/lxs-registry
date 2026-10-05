# storage changelog

## 2.1.0 (2026-10-06)
- Audio support: `POST /api/storage/objects` accepts audio MIME types
  (`audio/mpeg`, `audio/mp4`/`m4a`, `audio/webm`, `audio/ogg`, `audio/wav`,
  `audio/aac`). Audio is stored as-is (`kind: "audio"`) and served `inline`
  (Range-aware) so `<audio>` plays and seeks. Size cap reuses
  `MAX_DOCUMENT_MB`. MIME parameters (e.g. `audio/webm;codecs=opus` from
  MediaRecorder) are tolerated. Enables per-brief voice notes on RWID Brief.

## 2.0.0 (2026-08-19)
- Logging contract: service logs now emitted as newline-delimited JSON (NDJSON) to stdout per the platform LXS logging contract (`ts`/`level`/`msg` + optional `service`,`request_id`,`status`,`latency_ms`,`user_id`,`error`). Breaking change — log output format changed.

## 1.0.6 — port fix (2026-08-16)
- Read `SERVER_PORT` (matching the contract) before falling back to `PORT`.
  The binary previously only read `PORT` while the LXS contract declared
  `SERVER_PORT`, so configgen's allocated port was ignored and the service
  listened on 8081.

## 1.0.5 — previous
See 1.0.5 docs.
