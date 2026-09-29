# notes changelog

## 0.3.0
- **Enter in the title moves to the body.** Pressing Enter in the title field
  now focuses the note body (the natural "return to start writing" gesture)
  instead of doing nothing.

## 0.2.0
- Contract now declares `MONGODB_URI` + `JWT_SECRET` as required env so
  configgen injects them (the service could not validate tokens without it).

## 0.1.0
- Initial: per-user notes (MongoDB) + self-contained macOS-Notes-style UI at
  `/notes-app`. Auth via estate JWT (HS512). Routes gated by the gateway
  (`level: auth`, cookie `eco_token`).
