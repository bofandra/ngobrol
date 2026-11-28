# Ngobrol project handover

Updated 2026-11-28. Work continues on `feat/flutter-demo` in [draft PR #1](https://github.com/bofandra/ngobrol/pull/1).

## Start here

Read [AGENTS.md](../AGENTS.md) and the [web playtest guide](WEB_PLAYTEST.md). The guide includes the four core screens, the product mockups, and a release walkthrough. Use the [README](../README.md) to build or serve the artifact locally.

Product context lives in the [vision](PRODUCT_VISION.md), [game design](GAME_DESIGN.md), [PRD](PRD.md), and [UI design](UI_UX_DESIGN.md). Engineering context lives in the [architecture](ARCHITECTURE.md), [decisions](DECISIONS.md), [demo scope](demo-scope.md), and [roadmap](ROADMAP.md).

## Current playtest

The credential-free release supports illustrated Discover, local topic creation, Talk, a signed causal diagram, per-relationship votes, pending proposals, Insights, and Profile. The session retains created topics, contributions, votes, proposals, and provisional XP until the app restarts. The facilitator provides a deterministic prompt. The shell diagram illustrates hypotheses with no feedback loop.

The optional Supabase code shares posts across the three seeded topics. It displays acknowledged rows immediately, reconciles refreshes by post ID, and keeps failed submissions locally. Local PostgreSQL verified the sandbox SQL with two identities. A dedicated Supabase project is still needed to verify live Auth and API behavior.

## Milestones

### Baseline verification

- Reviewed the draft PR, original Drive design document, and repository mockups. Flutter 3.35.2 with Dart 3.9.0 resolved the pinned Supabase Flutter dependency.
- The original source failed analysis, test compilation, and the web build at a missing parenthesis in the proposal dialog. The syntax fix and dependency lock are in commit `0fa282a`. After that fix, Chrome rendered the baseline at 360 × 800 and 1280 × 900 before restyling.
- The baseline relied on network fonts. Repeating the initial browser check with external requests blocked rendered many labels blank.

### Gameplay and UI

- Added original topic illustrations, a full-screen form, a compact composer, signed edges, and a keyboard-accessible relationship list. The session model keeps proposals pending and associates shared requests with their originating topic.
- Added eight regression tests covering search, validation, voting and withdrawal, topic revisit, proposal handling, session XP, simulated keyboard insets, and shared-response ordering and fallback.
- Bundled the app fonts, causal arrow glyphs, and Flutter's startup font to support the release without external requests.

### Release verification

- `flutter pub get --enforce-lockfile`, `flutter analyze --no-pub`, `flutter test --no-pub`, and `flutter build web --no-web-resources-cdn --no-pub` succeeded on Flutter 3.35.2 and Dart 3.9.0. All eight tests passed. The build reports Flutter's existing Cupertino icon tree-shaking warning.
- Chrome completed the full offline walkthrough at 360 × 800 and 1280 × 900 with external requests blocked. Search, creation, narrow composition, topic revisit, keyboard vote activation and withdrawal, pending proposals, and XP passed. The final screens and comparison are in the [playtest guide](WEB_PLAYTEST.md).
- Isolated PostgreSQL 14 verified an authenticated insert with a returned ID, a read and write by a second identity, and rejection of unauthenticated reads and mismatched author IDs. The Auth claim was stubbed. The separate fake-backend tests verify one local award on repeated submission and deduplication of acknowledged rows by ID.
- The draft PR workflow builds a downloadable static release. Hosted preview, durable multiplayer, native host verification, and server-side AI are later roadmap milestones.

Review the draft PR and the release screenshots before deciding where to host a preview. Update this handover after each milestone with the change, verification evidence, and the next open item.
