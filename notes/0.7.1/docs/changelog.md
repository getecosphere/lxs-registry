# notes changelog

## 0.7.1
- **Numbered and outline lists.** The floating toolbar gains two list buttons:
  **numbered** (auto-incrementing 1. 2. 3., restarting after a break) and
  **outline** (bullet points). Like checklist items, **Enter** adds the next
  item, an empty **Enter** returns to a normal text line, and **Backspace** on
  an empty item removes it. Existing notes are unaffected (old block types keep
  working).

## 0.6.0
- **Undo + keyboard delete for media.** `Cmd/Ctrl+Z` restores the previous
  note content (structural changes: add/remove blocks, tasks, images and
  documents). An image/document block can be removed with its × or by
  selecting it and pressing **Delete/Backspace**. Removed blobs are queued and
  deleted only when you switch notes, so Undo can bring the image back first.

## 0.5.0
- **Free-form blocks.** A note's content is now an ordered list of blocks —
  text, checklist items, and images/documents — that mix freely. The separate
  "Tugas"/"Gambar" sections are gone; a macOS-Notes-style floating toolbar
  inserts a checklist item or attaches a file at the cursor. **Enter** in a
  checklist item adds a new one below; **Backspace** on an empty one removes
  it. The image/file **quota now sums across the note's blocks**, and the
  storage/quota readout moved to the editor **footer**. Notes written before
  the block model (`body`/`items`/`images`) are migrated on startup.

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
