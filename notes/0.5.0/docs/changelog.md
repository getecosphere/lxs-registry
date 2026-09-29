# notes changelog

## 0.4.0
- **Checklist + images with a per-user quota.** Notes carry a checklist
  (`items`) and pasted images (`images`). The browser uploads images to the
  estate's **storage LXS** under the user's own key (owner = user, namespace
  `notes`); the service records every attachment and is the quota authority.
  `GET /api/notes/quota` reports usage vs the plan limit — **free = 10 MB**,
  **paid = 1 GB** (`plan` claim from the auth token), warning at 80%. Attaching
  past the limit is rejected (413) and the UI shows an upgrade prompt.

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
