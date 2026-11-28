# Codex handover — Ngobrol v0.1

## Start here
Repository: https://github.com/bofandra/ngobrol
Branch: feat/flutter-demo
Draft PR: https://github.com/bofandra/ngobrol/pull/1
Baseline app commit: e9b3e51546d7c41a315e9ea44f2c2d223ae57f56
Date: 2026-11-27
Read ../AGENTS.md, PRODUCT_VISION.md, GAME_DESIGN.md, PRD.md, UI_UX_DESIGN.md, ARCHITECTURE.md, DECISIONS.md, ROADMAP.md, demo-scope.md. Actual visual assets in mockups/. The historical original DOCX is linked in mockups/README.md; these markdown files reconcile its older stack with owner's Flutter/Supabase choice.

## What exists (source committed, not runtime verified)
- Flutter Material 3 dark theme; Discover search, create local topic, Talk, Map, Insights, Profile/XP.
- Seed shell/transport/heat topics; signed graph via CustomPainter, per-link toggle votes, relationship proposal queue, local XP/history.
- Deterministic AI helper prompt; not real extraction or CLD generation. Map not yet draggable or selectable by node; use list.
- Optional Supabase anonymous Auth, sandbox shared posts for three seed topics, manual refresh; custom topics/votes/proposals/XP local only.
- RLS sandbox SQL, README commands, web entry point, tests authored. No live Supabase project, model, compiled app, actual UI screenshot or verified CI.
- Main initialized with README only; feature branch contains prototype and this handover. PR remains draft, do not merge.

## First Codex task (P0)
1. Inspect branch and files; read docs and mockups/01_Core_Gameplay.png then screen crops 02–05.
2. Install/configure stable Flutter SDK if environment allows. Check supabase_flutter dependency version/API against current docs (pin is unverified). Run flutter pub get; commit lockfile when successful. Generate missing host scaffolding safely without overwriting authored files. Verify web bootstrap.
3. Run flutter analyze, flutter test, flutter build web. Fix failures and extend tests (topic creation, voting withdrawal, invalid inputs, proposal queue and offline flow). Record exact command outputs; if tooling/network unavailable document blocker, do not invent pass.
4. Start actual web app; manually exercise shell walkthrough. Capture rendered screenshots narrow mobile and desktop, compare to reference art, fix layout and readability. Check navigation when keyboard open, dialog controller lifecycle, scrolling/voting and async stale refresh. Current tests may require scrolling/focus fixes; investigate.
5. Prepare repeatable CI and preview instructions. No production deployment or Supabase project changes without approval. Keep offline mode working.
6. Update this handover and decisions; commit to existing branch or derivative, update PR. Do not merge without approval.

## Milestone completion criteria
P0 passes build/analyze/tests and manual walkthrough, screenshot comparison documented, limitations explicit. Then propose shareable web preview; durable data/AI collaboration is next, not part of this verification.

## Open blockers
Flutter tooling not available during prior source authoring; dependency and tests unverified. No approved Supabase project credentials or AI provider. Public Drive permissions not confirmed, but repo now contains the original visual PNGs, and all essential context is local markdown. Original DOCX is historical reference only.

## Handover update template
Date / branch / commit:
Completed and evidence:
Commands and actual results:
Known issues and limitations:
Decisions changed:
Next smallest actionable task:

## 2026-11-28 baseline verification

- Reviewed draft PR #1, the original Drive product document, and the checked-in mockups. The written design uses Flutter and Supabase and depicts the shell example as a causal hypothesis map.
- Flutter 3.35.2 with Dart 3.9.0 resolved the pinned Supabase Flutter dependency. The original branch failed analysis, test compilation, and the release build at the same missing closing parenthesis in the proposal dialog. Applying the syntax correction let the no-CDN web build succeed and boot in Chrome.
- Captured Discover, Create Topic, Talk, and Map at 360 × 800 and 1280 × 900 before restyling. The baseline used emoji topic rows, a modal create form, generic post cards, and an ungridded graph with a scrolling relationship list.
- An isolated PostgreSQL 14 run with stub Auth claims verified author-owned inserts, reads by a second authenticated identity, and denial of unauthenticated reads and forged author IDs. Supabase Auth and API testing still require a dedicated sandbox.
