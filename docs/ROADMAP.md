# Roadmap — vertical slice first

## Milestone A — verified offline Flutter Web playtest
- Resolve dependencies, generate only missing host scaffolding, lock dependencies.
- Run flutter analyze, flutter test, flutter build web; fix real failures.
- Manual browser walkthrough for all P0 actions and mobile layout. Add missing tests for create topic, vote withdraw, proposals, search and errors.
- Align Discover, Create, Talk and Map UI with PNG references; capture screenshots.
- The offline release is verified locally and ready for owner review. See the [web playtest guide](WEB_PLAYTEST.md).

## Milestone B — hosted web preview
- Use the draft PR build artifact to evaluate GitHub Pages or another approved host. Verify the deployed base href and routing.
- Obtain owner approval before public deployment; publish offline demo without collecting personal data. Gate: working URL, mobile browser smoke, visible demo limitations.

## Milestone C — durable Supabase vertical slice
- Dedicated approved dev project; Auth, topics/membership/posts, graph revisions and proposals, RLS policies, test fixtures.
- Create → discuss → AI draft → human accept → version → authoritative XP. Server-side model integration only after provider approval.
- Gate: two users, no unauthorized private reads, atomic version, no duplicate XP, no invisible AI edits.

## Milestone D — collaborative pilot
- Votes on nodes/links, evidence, review queue, realtime, search/follow, notifications, report/mute/block, appeals, accessible map/list.
- Validate on 8–12 early players; seed 10–20 topics only if pilot ready. Invite-only recommended until safety review.
- Gate: quality and retention, usability (first contribution within 2 minutes proposed), safety and cost controls.

## Milestone E — expansion
- Optional missions/roles/leaderboards, richer worlds, Android/iOS release, cross-topic reusable maps/forks, advanced navigation, simulations, safe context-specific facilitation. Prioritize based on pilot evidence. No timeline or budget commitment yet.

## Risks
AI hallucination/false causality → sources, structured validation, review. Popularity/XP farming → evidence separate, caps, compensating ledger. Complexity → bounded maps and list. Toxicity/privacy → access and moderation. Cost/latency → async queue, quota, fallback. Avoid scope creep until P0 verified.
