# storage changelog

## 2.3.0 (2026-10-21)
- The contract declares where the data lives: `store: s3` (the bucket in `S3_BUCKET`). The objects are the estate's
  data, like a database: `eco sync` (eco with object-store sync) mirrors the production bucket into the local dev
  bucket over an ssh tunnel (exact copy). No API or behaviour change.

## 2.2.0 (2026-10-19)
- Video poster: every uploaded video now gets a WebP still (the frame at 0.5 s, the first frame for a shorter clip;
  ≤1280 px like the video) stored as its `thumbnail_key`, as images already had. Use it as `<video poster>` so a player
  shows a picture before it plays. Best effort: if no frame can be taken the video still uploads, without a poster.
- Video preview loop: every uploaded video also gets a short silent loop for feeds, `preview_key` (MP4 H.264, the first
  4 s, ≤480 px, 24 fps, faststart; ~20–300 KB): what a GIF would be at a fraction of the size. Play it with
  `<video autoplay muted loop playsinline>` in lists; load the full video (`key`) only when the item is opened.
  Additive field (absent when it could not be made, and on listings). Deleting a video: also delete its `-thumb.webp`
  and `-preview.mp4` keys.

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
