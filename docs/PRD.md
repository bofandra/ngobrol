# Product requirements and acceptance criteria

Priorities: P0 = verified offline web playtest; P1 = durable invite-only multiplayer pilot; P2 = expansion after learning. Scope is proposed, not a claim of completed implementation.

| ID | Priority | Requirement | Acceptance |
|---|---|---|---|
| FR01 | P0 | Discover/search seed topics | Shell, transport and urban heat discoverable; query filters; empty state clear |
| FR02 | P0 | Create and revisit topic | Title and context validated; topic opens and remains accessible in session |
| FR03 | P0 | Talk composer | Question/answer/suggestion posted once; invalid or oversized input rejected; pending/error clear |
| FR04 | P0 | Map and plain-language relationship list | Correct source/target, direction and +/- labels; no claim of proven causality; graph readable on mobile |
| FR05 | P0 | Vote on displayed links | Up/down toggles or withdraws; counts remain consistent; no double counting |
| FR06 | P0 | Propose relationship change | Cause, effect, sign, rationale validated; queue item visible; canonical map unchanged |
| FR07 | P0 | Contribution history/XP | Provisional XP reflected once per successful action, local-only labeled |
| FR08 | P0 | Offline operation | No API keys needed; deterministic mock facilitator labeled; all core flows usable |
| FR09 | P1 | Identity and membership | Authenticated player; guest read only if allowed; invite-only access enforced by RLS and API |
| FR10 | P1 | Durable topics and threaded posts | Author attribution, reply, mention, post type, follow and moderation; restart preserves data |
| FR11 | P1 | AI extraction | Schema-valid drafts with source post IDs, rationale, uncertainty and context; no invented evidence; manual fallback |
| FR12 | P1 | Factor/link detail and votes | Definition, sign, context, source, evidence, uncertainty; unique actor/target/revision; explain dissent |
| FR13 | P1 | Review and version | Diff, accept/reject/request revision; atomic graph version; stale conflict surfaced; reversal as new version |
| FR14 | P1 | Evidence | Add citation, URL, note, relevance and limits; attach to node/edge; report bad links |
| FR15 | P1 | Realtime and notifications | Authorized changes propagate; retry/resync; follow and mute; unread state |
| FR16 | P1 | Authoritative XP | Server-only quality award, idempotency, reversal, anti-abuse, pending/earned distinction |
| FR17 | P1 | Safety/privacy | Report/mute/block, moderation and appeal, invite isolation, deletion/retention, rate limits |
| FR18 | P1 | Insights/history | Version compare, known/unknown, competing hypotheses, loop detection and suggested question |
| FR19 | P1 | Onboarding/accessibility | Language, identity, privacy notice, contextual tutorial, keyboard/list access, no color-only info |
| FR20 | P2 | Worlds, missions, badges and cohort rankings | Optional, quality-focused, not pay-to-win; ranking opt-out |
| FR21 | P2 | Topic forks and linked submaps | Explicit scope/version/provenance; no implicit cross-topic causal merge |
| FR22 | P2 | Simulation and live facilitation | Validated quantitative models only; safety limits and context; no guaranteed resolution |

## Nonfunctional
Target p95 common reads <500 ms excluding AI, AI draft <15 s for short batches under expected load (targets to validate). Async AI, status, retry, idempotency and budgets. Paginate posts; cluster large maps, lazy load and accessible list. TLS, scoped secrets, backup/restore, audit, RLS, retention and privacy minimization. WCAG 2.2 AA target; 44px touch targets; keyboard/reduced motion; Indonesian/English localization. No production readiness claim until tested.

## Release gates
P0: dependency resolution, analyze, widget/unit tests, web build, mobile viewport manual smoke, offline full walkthrough and visual comparison. P1: real two-user test, private topic isolation, canonical version conflict/reversal, evidence and AI provenance, XP duplicate prevention, moderation, cost and backup controls. Pilot validate first contribution within two minutes and +/- comprehension. P2 based on evidence.
