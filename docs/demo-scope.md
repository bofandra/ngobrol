# Playtest scope v0.1

This is a vertical-slice prototype, not a public launch.

| Flow | Demo behavior | Next implementation |
|---|---|---|
| Discover | Three illustrated starter topics, session-created topics, search and empty state | Shared searchable topic catalog |
| Create topic | Session topic with validated question and optional context | Authenticated topic creation, moderation |
| Talk | Local posts and optional shared Supabase posts with manual refresh and local failure status | Realtime threads, evidence links, notifications |
| AI | Deterministic suggested question | Server-side model, structured extraction, provenance and review |
| Map | Signed directed edges, keyboard-accessible list, per-edge switching and withdrawal | Persistent graph, editable node labels, graph diff, versioning |
| Propose | Cause/effect/sign/rationale review queue | Author review, independent evidence, merge/reject, audit |
| XP | Provisional local rewards | Server ledger, anti-spam, significance review |
| Insights | Counts and next question | Evidence-weighted summaries, feedback loops |

Model design: signed edge polarity represents the direction of change, not whether a relationship is good or bad. The shell map is illustrative. Do not assert causality from votes or AI output. A genuine causal loop requires a cycle and an interpretable mechanism. Keep competing hypotheses rather than deleting minority opinions.

Supabase sandbox: authenticated anonymous sessions are still authenticated users. The sandbox schema exposes only `demo_posts`, with RLS, authenticated SELECT, limited INSERT columns, and an author ownership check. No service secrets. Before production: private rooms, per-topic membership, report/moderate/erase, abuse controls, consent and retention, rate limits, evidence provenance, authoritative XP.

See the [web playtest guide](WEB_PLAYTEST.md) for browser evidence. Durable topic and map storage, server-side AI, and native platform verification are future milestones.
