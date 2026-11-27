# Game design

## Core loop
Explore → start or join a topic → ask/answer/suggest/challenge/evidence → AI proposes a map delta → inspect and vote → propose corrections → review and publish → receive XP → revisit. This loop is asynchronous by default; Realtime enriches it later. A player can contribute without manipulating a diagram.

Worlds (proposed): Daily Life, Mobility, Environment, Healthcare, Education, Technology. Optional roles: Explorer, Connector, Evidence Hunter, Critical Thinker, System Mapper. Roles are preferences, never permission gates. Stewards handle review and safety separately.

## Topic lifecycle
Draft → open → active/dormant derived from activity → active again when someone returns. No permanent completion state for legitimate discussions. Freeze or archive for safety/spam with reason and appeal. Scope edits are versioned; forks allow incompatible boundaries or viewpoints. Follow topic and show changes since last visit.

## Collaborative map rules
- Factor: measurable or directionally interpretable variable, with definition/context. Link: directed causal hypothesis with polarity, explanation, source and optional delay. Community may vote on both.
- One active vote per player per target revision; up/down/withdraw. Aggregate agreement is separate from evidence quality.
- Draft AI or human proposal never edits canonical state. Operations add/edit/merge/retire factors/links; require rationale, base version, provenance and preview.
- Initial governance proposal: topic stewards approve material changes with reason; conflicts and competing explanations remain visible. Rejected proposals are not erased. Reversal is a new version. Review policy may evolve after pilot.
- Explain + and - in plain language. Detect closed directed paths before labeling feedback loops. Reinforcing: even negative links; balancing: odd. No proof of causality from topology.

### Worked example: shell choice
Shell size → protection (+); shell size → shell weight (+); shell weight → mobility (-); mobility → survival chance (+); protection → survival chance (+).
This is a causal hypothesis map with competing paths, not yet a CLD. Investigate a possible balancing loop: growth → size mismatch (+) → shell-seeking effort (+) → suitable shell acquisition (+) → mismatch (-). Require time scale, context and evidence.

## XP proposal (not final rules)
| Contribution | XP | Quality gate |
|---|---:|---|
| Useful question | 5 | distinct and relevant |
| Useful answer / new factor | 10 | review / accepted factor |
| Causal link | 15 | accepted hypothesis |
| Correction | 20 | accepted improvement |
| Evidence | 25 | relevant source |
| Feedback loop | 30 | explicit valid cycle |
| Leverage point | 50 | justified hypothesis |
| Breakthrough | 100 | documented; proposed two steward approvals |

Use pending/earned/reversed events with immutable award key (contribution ID, rule version, award type). Only server assigns authoritative XP. Award after quality review, compensate reversal, prevent duplicate rewards, self-review, vote rings and farming. Cap repetitive reviews (initial example 20 XP/day). Demo uses provisional simple local XP only; no claim of quality assessment. Proposed level thresholds 0/100/250/500/1,000 cumulative XP. Optional badges and cohort leaderboards, opt-out; no privilege from score. Prefer cooperation over competition.

## Learning and safety
Contextual hints teach variables, polarity, delays, loops and leverage; missions can encourage testable questions, evidence gaps or reviewing a hypothesis. Accessible list is equivalent to map interaction. Add report/mute/block, moderator queue, appeal, rate limits, privacy controls. No doxxing, threats, or harmful advice; active physical incidents require safety first. Minimize data, private topics require membership, no private-content model training without opt-in. Age policy and retention are open decisions.
