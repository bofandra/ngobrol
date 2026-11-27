# Playtest scope v0.1

This is a vertical-slice prototype, not a public launch.

| Flow | Demo behavior | Next implementation |
|---|---|---|
| Discover | Three seeded worlds; text search | Shared searchable topic catalog |
| Create topic | Local topic and context | Authenticated topic creation, moderation |
| Talk | Local posts and optional shared Supabase posts | Realtime threads, evidence links, notifications |
| AI | Deterministic suggested question | Server-side model, structured extraction, provenance and review |
| Map | Signed directed edges and per-edge vote | Persistent graph, editable node labels, graph diff, versioning |
| Propose | Cause/effect/sign/rationale review queue | Author review, independent evidence, merge/reject, audit |
| XP | Provisional local rewards | Server ledger, anti-spam, significance review |
| Insights | Counts and next question | Evidence-weighted summaries, feedback loops |

Model design: signed edge polarity represents the direction of change, not whether a relationship is good or bad. The shell map is illustrative. Do not assert causality from votes or AI output. A genuine causal loop requires a cycle and an interpretable mechanism. Keep competing hypotheses rather than deleting minority opinions.

Supabase sandbox: authenticated anonymous sessions are still authenticated users. The only exposed table is demo_posts, RLS enabled, authenticated SELECT, limited INSERT columns, author ownership check. No service secrets. Before production: private rooms, per-topic membership, report/moderate/erase, abuse controls, consent and retention, rate limits, evidence provenance, authoritative XP.

Next: test on Android and web, compare actual UI against the approved mockups, then implement durable topic/graph/vote/proposal storage and a server-side AI pipeline. No production deployment or live AI is included.
