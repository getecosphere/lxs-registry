# compose — changelog

## 0.11.0

- **Step 3 is now a guided setup wizard** instead of a single dense screen.
  Four screens, one at a time, each with a product screenshot and a single
  action: **1** install the eco CLI · **2** open your project in an AI agent ·
  **3** paste the prompt · **4** run it, then publish. Prev/Next with a `N / 4`
  counter; browser Back steps through the screens too. The prompt (with Copy /
  Edit) lives on screen 3.
- Tutorial images are product mock-ups rendered from
  `assets-src/tutorial-mocks.html` (terminal, agent window, browser).

## 0.10.0

- **The prompt is editable.** "Copy prompt" moved above the prompt box, next to a
  new **Edit** button. Edit swaps the prompt for a textarea; Done commits the
  change, and Copy copies exactly what's shown (typed, generated, or edited).
  Edits reset when the profession or capabilities change, since the prompt is
  regenerated from them.

## 0.9.1

- **All eleven profession illustrations shipped.** Added art for lawyer,
  home-service pro, salon owner, landlord, community organizer, and student
  (WebP 1600×900). Every role card and its steps 2/3 now show artwork; the
  generic step images remain only as the no-profession fallback.

## 0.9.0

- **Six more professions — eleven in total.** Added Lawyer, Home-service pro,
  Salon owner, Landlord, Community organizer, and Student (alongside
  accountant, doctor, teacher, café owner, freelance designer).
- **The profession cards are now a carousel.** A horizontal scroll-snap track
  with prev/next arrows and a `NN / 11` counter; swipe on touch, ~4 cards per
  view on desktop, a peek on mobile. The chosen role's artwork still follows the
  visitor into steps 2 and 3.
- New role artwork is pending — those cards show the themed placeholder.
  Prompts and spec for all roles: `docs/illustrations.md`.

## 0.8.2

- **Profession cards trimmed.** Removed the trailing link line from each card
  (the "Continue" button is the single call to action now); the card ends at the
  short story.

## 0.8.1

- **Uniform card link.** Every profession card now ends with the same
  "See the app it becomes →" line instead of a different-length description, so
  the row of cards aligns cleanly.

## 0.8.0

- **Browser Back steps through the wizard.** Each step pushes a history entry,
  so Back moves 3 → 2 → 1 and Forward restores it, instead of leaving the page.
- **The chosen profession's artwork follows the visitor.** Steps 2 ("Your app")
  and 3 ("Your build") now show the role selected in step 1; the generic
  `step-app` / `step-build` images are only a fallback for the "start directly"
  path where no profession was chosen.
- **The starter prompt types itself in** on the build step (typewriter with a
  blinking caret), so it doesn't appear all at once. `prefers-reduced-motion`
  shows it immediately; Copy always yields the full text.

## 0.7.0

- **Full illustration set shipped.** All five profession cards (accountant,
  doctor, teacher, café owner, freelance designer) and the two step headers
  (`step-app`, `step-build`) now carry artwork. Assets are WebP (1600×900,
  ~23–45 KB each), embedded at compile time and served from
  `/compose-app/static/img/:name`; prompts and spec in `docs/illustrations.md`.

## 0.6.1

- **The chosen profession's illustration carries through the wizard.** Steps 2
  ("Your app") and 3 ("Your build") now show the selected role's artwork instead
  of a separate, not-yet-shipped step image — so picking Accountant shows the
  accountant art on the next pages too. Falls back to the themed placeholder
  when a role's asset isn't shipped yet.

## 0.6.0

- **Supporting artwork.** The intro's profession cards and the step 2/3 headers
  now carry an illustration slot, with a themed placeholder (brand gradient)
  until the asset ships. Assets are embedded at compile time and served from
  `/compose-app/static/img/:name`. Prompts and delivery spec:
  `docs/illustrations.md`. First asset shipped: `prof-accountant.webp`.

## 0.5.1

- **Agentic step is eco-first and agent-agnostic.** Step 1 now installs the
  `eco` CLI (it was implicit before); step 2 says to open the project in *any*
  agent — the Ecosphere Assistant is one option, not a requirement. The note
  states the Assistant is optional.
- **Starter prompt no longer assumes eco is installed.** It now begins with an
  install guard: if `eco --version` fails, install via
  `curl -fsSL https://getecosphere.com/install.sh | sh`, then run `eco agents`.

## 0.5.0

- **Step 3 is now agentic-first.** The AI agent is the primary way to build: a
  three-step hero (install the Ecosphere Assistant, open your project, paste a
  ready starter prompt). The prompt is generated from the chosen app and its
  capabilities and points the agent at the estate's `AGENTS.md` (written by
  `eco agents`) — so a free model can build, because the hard parts already
  shipped as LXS. CLI and the visual IDE move under "Prefer to do it by hand?".
- **Access control is a recommended toggle.** The `gateway` LXS is no longer
  hard-coded into the generated manifest; it is offered first, marked
  *recommended*, and on by default for every app. Turning it off warns that
  every route becomes reachable. The starter presets include it too.
- Starter prompt and `eco serve` copy use the correct free-URL domain
  (`getecosphere.app`).

## 0.4.3

- Step changes animate: the incoming step lifts and fades in, its capability
  chips / way cards / profession cards stagger in behind it, and the wizard
  rail fades. Returning to a step replays the transition. Reduced-motion users
  get the instant swap.

## 0.4.2

- Choosing a profession only selects it (the card highlights) — it no longer
  jumps to the next step. A **Continue** button, enabled once something is
  chosen, advances to "Your app".

## 0.4.1

- One step per screen. Choosing a profession (step 1) and "Your app" (step 2)
  no longer stack: picking a profession replaces the intro, and "Different
  work" brings it back. The wizard owns the top gap itself, since the intro is
  hidden while a step is shown.

## 0.4.0

- Warm, AI-era front door. The page now opens by saying **anyone can code now**
  and asks what work the visitor does — five professions (accountant, doctor,
  teacher, café owner, freelance designer). Picking one tells the story of the
  app that work could become, lists the reusable capabilities it needs as
  toggleable chips, then reveals the builder with a **contextual title**
  ("Compose your clinic") and that app pre-selected. The technical composer is
  unchanged; it is simply reached through the wizard now.
- Added `wizard.js` (served at `/compose-app/static/wizard.js`). It drives the
  composer through a small `window.ecoCompose` API (`setSelection`, `setWay`,
  `selected`) instead of holding composition state itself.
- A host that bridges a real estate, or `&hero=0`, skips the intro and opens
  the builder directly.
- Homepage-like vertical rhythm on `/compose` (the intro owns the top gap), so
  the page no longer crowds the header.

## 0.3.0

- Three ways to build, presented as a switchable guide: **CLI** (install eco,
  `eco init`, `eco lxs add`, `eco up dev`, `eco deploy` with copy buttons),
  **IDE** (the composer), and **AI agent** (the Ecosphere Assistant extension +
  OpenCode). No way is assumed on first visit — the chooser is the entry, each
  panel cross-links to the next, and the choice is remembered.

## 0.2.0

- Estate bridge: when a host connects the composer to a machine (the Ecosphere
  Assistant side panel), the composer loads the estate's real `ecompose.yml`,
  shows its current capabilities, and adds/removes them by running `eco lxs
  add` / `eco lxs remove` — the CLI merges each recipe, so the file is never
  rewritten by the UI. Adds Run locally / Deploy buttons with a live log.
  The host protocol is postMessage (`eco-compose:*`); without a host the
  composer behaves exactly as before.

## 0.1.4

- Fix: the extracted stylesheet still hid the page title under `?embed=1`, so
  `hero=0` had no effect. `embed` now hides only the composer's bar.

## 0.1.3

- Split the embed flags: `?embed=1` hides only the composer's own bar (the host
  supplies chrome), while `&hero=0` additionally hides the page title/lede.
  An estate wrapping the tool can therefore keep the title.

## 0.1.2

- Serve the composer at `/compose-app` instead of `/compose`, so an estate can
  keep `/compose` as its own page and wrap the tool in the estate's real
  header/footer (the LXS stays the single implementation of the composer).

## 0.1.1

- Style the composer's own top bar and hide it under `?embed=1` (the first
  release shipped it unstyled and visible in embedded hosts).

## 0.1.0

- First release. Composer page extracted from the getecosphere estate so it can
  be composed anywhere (and framed by the Ecosphere Assistant side panel).
- Live LXS registry palette (via the host estate's `/api/lxs`), estate canvas
  with docked capability nodes and rays into the application core, live
  `ecompose.yml` + `eco lxs add` / `eco up dev` output with copy buttons, and
  starter-estate presets.
- `?embed=1` to drop the composer's own top bar for embedding hosts.
- Newline-delimited JSON logging on stdout per the LXS logging contract.
