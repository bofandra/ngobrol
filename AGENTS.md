# Ngobrol — instructions for coding agents

Ngobrol is a cooperative multiplayer Systems Thinking game. Read [docs/HANDOVER.md](docs/HANDOVER.md) first, then the relevant design documents. The repository is the persistent project context; no prior chat or Google Drive access is required.

## Non-negotiable product principles
- Conversation first, map second. Players learn systems thinking by playing, not by completing an academic course.
- Anyone may start a topic, ask, answer, challenge or suggest. Discussions remain open indefinitely unless moderation requires restriction.
- AI proposes factors, causal links and questions; it does not adjudicate truth, assign blame, fabricate evidence or silently change the canonical map.
- Votes are agreement signals, never causal proof. Preserve dissent, uncertainty, evidence and provenance.
- Reward meaningful improvement, not comment volume or popularity. Provisional demo XP is not authoritative.
- Signed causal links use + for same-direction change and - for opposite-direction change; these are not good/bad ratings. A map with no closed directed path is not yet a CLD.
- Safety and privacy precede growth. Do not enable public production data collection until moderation, access control and retention are implemented.

## Engineering
- User-selected stack: Flutter (mobile/web) + Supabase (Auth, PostgreSQL, Realtime, Edge Functions). Earlier React/Node proposals are superseded. Do not replace the stack without owner approval.
- Keep an offline demo runnable without credentials. Distinguish mocked, configured, tested and deployed behavior explicitly.
- Use publishable client keys only; no service-role keys or model secrets in Flutter, repo, logs or fixtures. RLS for every exposed table. Deny cross-topic unauthorized access; server controls canonical graph and XP.
- Check current Flutter and Supabase docs for API compatibility; pin resolved dependencies and commit lockfile after successful resolution.
- Prefer small vertical slices and clear repository/data boundaries. No unnecessary platform/framework churn.
- Preserve the mobile-first visual direction: midnight navy, teal, gold, rounded cards, playful exploration; use [docs/mockups/](docs/mockups/) as design references, not exact copy or data.
- No direct merge into main without owner approval. Continue feat/flutter-demo / draft PR #1 or a derivative branch. Never force-push over another contributor.
- Verify with Flutter 3.35.2 and Dart 3.9.0. Run `flutter pub get --enforce-lockfile`, `flutter analyze --no-pub`, `flutter test --no-pub`, and `flutter build web --no-web-resources-cdn --no-pub`. Record actual results and limitations. For backend changes, run RLS tests with distinct users and verify idempotency.
- Do not deploy or create paid resources without explicit owner approval. Never claim a live AI or Supabase project exists unless verified.
- Update docs/HANDOVER.md after each milestone (what changed, test results, outstanding risks, next action). Record material product and architecture decisions in docs/DECISIONS.md. Keep PRs scoped.

## Documentation map
- [PRODUCT_VISION](docs/PRODUCT_VISION.md): why, audience, philosophy, examples.
- [GAME_DESIGN](docs/GAME_DESIGN.md): gameplay, topic lifecycle, rewards, governance.
- [PRD](docs/PRD.md): features, acceptance criteria, priorities and gates.
- [UI_UX_DESIGN](docs/UI_UX_DESIGN.md): 14 screens and navigation, design tokens.
- [ARCHITECTURE](docs/ARCHITECTURE.md): current and target data/AI architecture.
- [DECISIONS](docs/DECISIONS.md): owner decisions versus proposals.
- [ROADMAP](docs/ROADMAP.md): staged delivery.
- [HANDOVER](docs/HANDOVER.md): current state and next task.
- [WEB_PLAYTEST](docs/WEB_PLAYTEST.md): browser walkthrough and visual comparison.
- [demo-scope](docs/demo-scope.md): prototype behavior and limits.
