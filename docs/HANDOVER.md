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
- The draft PR workflow is configured to package the static release. GitHub blocked the first job before execution because the account is locked for billing. The local build and archive are verified. [GitHub Actions run](https://github.com/bofandra/ngobrol/actions/runs/46093342723)
- Hosted preview, durable multiplayer, native host verification, and server-side AI are later roadmap milestones.

Review the draft PR and the release screenshots before deciding where to host a preview. Update this handover after each milestone with the change, verification evidence, and the next open item.

## Milestone Android Internal testing

The Android host for `com.bofandra.ngobrol` is part of `feat/flutter-demo` and draft PR #1. Its launcher label and icon follow the web playtest. The Android release targets API 36 and uses a dedicated `ngobrol-upload` signing configuration. The PKCS12 file and its Keychain password were provisioned locally. This is version `0.1.0`, version code `1`, for the owner to upload to Play Console Internal testing.

- Locked dependency resolution, `flutter analyze --no-pub`, all eight Flutter tests, and the no-CDN Web build passed. The Android release build used Flutter 3.35.2 and JDK 17. A release bundle build with its signing environment removed failed at `checkReleaseSigning`.
- Bundletool 1.18.3 validated the signed AAB and its package, version, min SDK 24, target SDK 36, and 16 KB bundle alignment. Native ELF load segments for ARM64 and x86-64 and ZIP alignment for the universal APK passed. The APK and AAB both use the dedicated upload certificate.
- Release SHA-256 is `b14c5df8cc6d7128fb539e3b84e15ee827ab5ac1966e7b2f81b700389fa7434b`. Upload certificate SHA-256 is `C0:B1:B5:2F:95:D0:35:1F:98:A0:5C:5B:95:87:2E:C9:4D:1F:20:82:B2:8C:42:40:B9:E7:88:4C:1A:56:A7:12`.
- The AAB-generated APK passed the offline playtest on Android 15 (API 35, 4 KB pages). The walkthrough created a topic, posted with the Android keyboard open, voted and withdrew, submitted a pending proposal, and confirmed 25 XP in Profile. Discover, Talk, and Map rendered inside the system bars.
- The same APK passed the offline walkthrough on Android 16 (API 36, 16 KB pages). The app created a topic, posted with the Android keyboard visible, voted and withdrew, kept the proposal pending, and showed 25 XP in Profile. The status and navigation bars stayed visible without covering the app controls.
- The build is ready for the owner to upload as `app-release.aab` to Internal testing. Use the [Android build instructions](../README.md#build-android-for-internal-testing) to reproduce it with the local upload key.

## Branch consolidation

- Fast-forwarded `feat/flutter-demo` to include Android commits `76af2dc` and `b217b8e`. Use draft PR #1 to review the web and Android demo before merging to `main`.
- Rechecked the combined branch on Flutter 3.35.2 and Dart 3.9.0. Locked dependency resolution, analysis, all eight tests, and the no-CDN web build passed. The web build still reports the Cupertino icon tree-shaking warning. Android bundle and emulator results are recorded above.
