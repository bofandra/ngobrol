# UI/UX design — mobile-first
A cozy futuristic strategy game, not enterprise software. The primary mockup is [01_Core_Gameplay.png](mockups/01_Core_Gameplay.png). All PNGs are generated concept art, not pixel-perfect specs. Written requirements supersede inconsistent labels, XP values, names or arrows.

## Navigation
Target: Discover | My Topics | Contributions | Profile, Create always accessible, search/notifications from Discover. Inside a topic: Talk | Map | Evidence | Insights. Deep links to topic, post, map element and revision with authorization. P0 currently has Discover/Profile and Talk/Map/Insights. Keep a desktop/tablet map workspace with larger canvas later.

| Screen | Required states/interactions | Reference |
|---|---|---|
| 01 Welcome | language, guest/sign-in, optional role, privacy and tutorial, skip | 06 |
| 02 Discover | search, worlds, latest/trending/following, create, resume; empty/loading/error | 02 |
| 03 Create topic | question 10–120 chars; context <=2,000; desired understanding, <=5 tags, visibility, duplicate warning, publish | 03 |
| 04 Talk | scope, follow, contributor count, threaded composer (question/answer/idea/challenge/evidence), reply/report, pending/failed/retry | 04 |
| 05 Living map | pan/zoom/fit, selected node/edge, +/- and delay legend, status filters, map/list, version and draft overlay | 05 |
| 06 My topics | followed/created/contributed, unread deltas, dormant topics, invitation management | 06 |
| 07 Profile | XP ledger, levels, badges, interests, language, accessibility, privacy, sign-out | 07 |
| 08 Factor/link detail | definition, direction, sign, context, uncertainty, evidence/source, thumbs up/down/withdraw, explain vote | 06 |
| 09 Propose change | add/edit/merge/retire, select target, sign and rationale, source/context, diff preview, submit | 06 |
| 10 Review queue | filters/status, compare diff, conflicts, evidence, accept/reject/revise with reason | 06 |
| 11 Evidence | source URL/citation, note, relevance, limitations, attach to node/edge, report | 06 |
| 12 Insights/history | known/unknown, trade-offs, loops, compare versions, restore by proposal, next questions | 06 |
| 13 Rewards | pending/earned/reversed XP, badges, optional leaderboard opt-out | 07 |
| 14 Notifications/moderation | replies, invites, decisions, reports, mark read/mute/block, steward controls and appeal | 06 |

## Visual system
| Token | Hex | Meaning |
|---|---|---|
| Midnight | #101C2D | canvas |
| Surface | #1B3046 | cards, panels |
| Teal | #34D399 | discovery, primary |
| Blue | #60A5FA | information |
| Gold | #FBBF24 | XP |
| Purple | #C084FC | ideas |
| Red | #FF8787 | caution or negative link with minus label |

Rounded cards, modern rounded typography, minimal text, 44px minimum touch targets, generous spacing; avoid dense small labels. Use accessible text descriptions for all causal edges. Contrast, focus, reduced motion and responsive text scaling. The hermit crab is a friendly narrative example/possible mascot, not an exclusive topic.

## Primary walkthrough
Discover shell topic → open Talk → contribute “What about changing tides?” → AI-labeled suggestion → Map → select Shell weight → Mobility → view negative polarity and rationale → vote/withdraw → propose a new relationship with rationale → see Pending → return to profile XP/history → revisit topic. Demonstrate review and version publishing when P1 exists.

## Visual acceptance
Capture real rendered screenshots at narrow mobile and desktop sizes, compare to mockups, check text clipping, long labels, keyboard, contrast, map legibility and all touch actions. Do not claim the current prototype matches the mockups without actual screenshots.
