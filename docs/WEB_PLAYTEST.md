# Flutter Web playtest

Build the credential-free release from [draft PR #1](https://github.com/bofandra/ngobrol/pull/1) using the [README commands](../README.md), then serve its files over local HTTP. The **Flutter Web playtest** workflow is configured to create a `ngobrol-flutter-web` artifact after a successful run. The account billing lock prevented the initial workflow from starting. [GitHub Actions run](https://github.com/bofandra/ngobrol/actions/runs/46093342723)

## Hermit crab walkthrough

1. In Discover, search for **hermit** and open **What makes a good home for a hermit crab?**
2. In Talk, choose **Question**, enter **What about changing tides?**, and send. Your post, a simulated facilitator prompt, and a 5 XP increase should appear.
3. Open **Map**, inspect the direction and polarity of **Shell weight → Mobility (−)**, and open **List (5)**. Agree with a relationship, switch to Disagree, or select your vote again to withdraw. The counts show community agreement.
4. Choose **Suggest map change**. Enter **Tide height** as the cause, **Dry ground** as the effect, **Opposite (−)**, and **Incoming water covers dry ground** as the rationale. The proposal should appear in **Pending proposals**, and the relationship count should stay at five.
5. Return to Discover, open Profile, and check the contribution history. Reopen the topic to confirm that the discussion and proposal are still available during the session.
6. Choose **Create new topic** from Discover. Enter a question between 10 and 120 characters and optional context. Start the topic, return to Discover, and clear any search filter to find it again.

## Comparison with the product mockups

See the [core reference board](mockups/01_Core_Gameplay.png) and the browser captures for the [mobile baseline](playtest/baseline-mobile.webp), [mobile release](playtest/release-mobile.webp), and [desktop release](playtest/release-desktop.webp). Each board shows Discover, Create Topic, Talk, and Living Map in that order. The comparison baseline was captured with fonts available from the original bootstrap. The same baseline rendered many labels blank when network requests were blocked.

| Screen | Old web UI | Released web playtest |
| --- | --- | --- |
| [Discover](mockups/02_Discover.png) | Emoji rows and a generic introduction | Illustrated starter topics, session XP and progress, search, and a reachable primary Create action. Counts reflect the session. |
| [Create Topic](mockups/03_Create_Topic.png) | Modal with two fields | Full-screen illustrated form with labeled fields, validation, and a session visibility note. Tags and sharing controls are future features. |
| [Discussion](mockups/04_Discussion.png) | Repeated cards and a generic composer | Topic art, color-coded contribution types, a distinct simulated facilitator, and a composer that stays accessible in a short viewport. Reply threads are future features. |
| [Living Map](mockups/05_Living_Map.png) | Plain arrow canvas above rows | Gridded diagram with signed arrows and a separate list of individual relationship controls. The seeded shell pathways are causal hypotheses. Map gestures and version history are future features. |

The three topic illustrations use built-in ImageGen. The prompt called for text-free, painterly storybook game art with a central subject and turquoise, emerald, and coral tones. The scenes show a hermit crab at a tropical tide pool, a teal commuter train above a coastal-city road, and a tree-shaded street with rooftop solar. The [bundled art](../assets/topics/) and typefaces load from the local server. Nunito, the Noto Sans Symbols arrow subset, and Flutter's default Roboto fallback ship with their respective license files. [Nunito and Noto source](https://github.com/google/fonts/tree/5026800714d07231937d92eb4cceabf06e05d74e/ofl) · [Roboto source](https://github.com/googlefonts/roboto-2/tree/38062f4b4a0be4346d07a928408da21602545e9e)

## Verification

Chrome completed the release walkthrough at 360 × 800 and 1280 × 900 with external requests blocked. The exercise included creating a topic with a long question, composing in a shortened mobile viewport, scrolling through relationships, keyboard voting and withdrawal, and revisiting a discussion. No external requests or browser errors occurred during those walkthroughs. The Flutter widget tests also exercised a simulated mobile keyboard inset at 320 px.

<details>
<summary>Illustration prompts</summary>

The built-in ImageGen tool received this direction for all three bundled cards.

> Use case: stylized-concept. Create original text-free game art for an illustrated topic card in Ngobrol, a cozy systems thinking exploration game. Painterly 3D storybook videogame art, lush emerald vegetation, sunlit turquoise and coral with soft grain and sculptural rounded shapes, playful but polished, readable subject against a slightly darker environment. Wide landscape composition with central subject safe for square and wide crops. Edge-to-edge scene. No UI, text, letters, logos, frames, labels, numbers, panels, or watermark.

- [Hermit crab](../assets/topics/hermit-crab.webp) — A curious, expressive small orange hermit crab wearing a large ivory spiral shell, next to a couple of empty shells by a sparkling tropical tide pool under warm sun. Focus on the crab's eyes and silhouette.
- [Transportation](../assets/topics/transport.webp) — A teal commuter train curving above a small terracotta-orange car and a bike lane in a verdant Indonesian coastal city, a warm afternoon, layered blue and green hills in the distance. The train leads the composition.
- [Urban heat](../assets/topics/urban-heat.webp) — A green shaded city street with broad tropical trees cooling the walkways near compact ochre buildings, a nearby roof with blue solar panels, and a warm bright sky. Clearly show the neighborhood and tree shade.

</details>
