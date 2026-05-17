# Predictive History Audience Profile

This internal profile summarizes public audience signals and the product implications for Predictive History and `civ-ph`.

It should guide corpus design, review priorities, Civilization Museum planning, contributor onboarding, and future `civ-ph` package work. Public audience numbers are approximate and should be refreshed before publication or fundraising use.

## Executive Read

Predictive History now reaches a hybrid audience:

- viral geopolitical prediction viewers
- long-form Jiang students
- civilizational pattern-seekers
- AI-assisted learners
- skeptical analysts and critics
- audio-first and clip-first listeners
- unofficial-channel and repost audiences

The core audience need is not only information. It is **orientation before information**: where a lecture sits, what to notice, how strongly to trust the frame, what limits apply, and how to return to source material.

That is the role of `civ-ph`: a civilizational context layer, not a transcript archive, commentary substitute, endorsement layer, or prediction registry.

## Public Growth Signals

As of May 2026 public third-party listings suggest substantial scale:

- vidIQ listed the Predictive History YouTube channel at roughly 2.5M subscribers, 84M+ views, and strong recent monthly growth.
- Sidestack listed the Predictive History Substack at 100K+ free subscribers, 1K+ paid subscribers, and a top History ranking.
- Apple Podcasts listed an unofficial/no-ads audio feed with more than 100 episodes, suggesting meaningful audio-first study behavior.

Reference links:

- https://vidiq.com/youtube-stats/channel/UC11aHtNnc5bEPLI4jf6mnYg/
- https://sidestack.io/directory/substack/predictivehistory
- https://podcasts.apple.com/gb/podcast/predictive-history-professor-jiang-no-ads/id1891673031

Use these as directional signals only. They are not canonical analytics.

## Audience Segments

### Viral Prediction Audience

Arrives through Iran, Trump, WWIII, China, Ukraine, dollar-system, or “he predicted it” clips.

Needs:

- quick orientation
- prediction provenance
- date-sensitive caveats
- “what did he actually say?” routing

### Jiang Student

Watches or listens to full lectures and wants the series to cohere as a course.

Needs:

- chapter paths
- stable IDs
- return paths
- lecture-to-lecture continuity
- review status and trust vocabulary

### Civilizational Pattern-Seeker

Wants Homer, Rome, Dante, Shakespeare, Dostoevsky, Tolstoy, America, and Apocalypse in one larger frame.

Needs:

- `civ-ph` cards
- literary and historical spines
- cross-volume corridors
- placement weight and limits

### AI-Assisted Learner

Wants to use ChatGPT, Claude, Cursor, local agents, notebooks, or study guides without pasting unstructured lecture text.

Needs:

- importable context
- first-good-question prompts
- JSON/Markdown portability
- no source transcript or commentary leakage
- clear provenance boundaries

### Skeptical Analyst

Arrives through criticism, debate, debunking, or concern about methodology and controversial claims.

Needs:

- counter-reading prompts
- source-status language
- representation-not-endorsement
- high-risk review queues
- explicit uncertainty

### Media Curator

Can help students see the objects, maps, artworks, actors, and pressure structures behind a lecture.

Needs:

- scoped media inventory tasks
- link-first rights-safe workflow
- museum-label captions
- validation before publication

## Trust Tensions

The audience environment is noisy.

- Viral prediction clips can flatten the project into prophecy rather than study.
- Unofficial copies and derivative channels can blur source provenance.
- High-risk topics include religion, race, empire, antisemitism/Nazism, finance, state violence, current politics, and war prediction.
- AI users may accidentally treat raw ASR, summaries, or orientation cards as quote-grade source material.

The repo should answer this with structure rather than defensiveness:

- exact transcript fidelity
- clear distinction between transcript, commentary, `civ-ph`, Civilization Museum exhibits, and quote-grade claims
- visible review status
- high-risk review queues
- bounded public language

## Implications For Predictive History

Predictive History should assume three arrival modes:

1. Cold viral arrival: “I saw the prediction. What is this?”
2. Study arrival: “I want to work through the course.”
3. AI-tool arrival: “I want to load this into an assistant.”

The repo should therefore keep strengthening:

- `chapter-manifest.yaml` as canonical routing
- `civ-ph` as orientation and re-entry layer
- cross-volume corridors as guided paths
- Civilization Museum exhibits as what-to-encounter-before-reading aids
- transcript fidelity and quote-grade boundaries
- recursive review loops and weekly review sprint tooling

## Implications For civ-ph

The product thesis is:

> `civ-ph` packages the Predictive History civilizational context layer as portable cards, paths, prompts, and metadata so students, teachers, and AI systems can import the course's interpretive frame without importing transcripts, commentary bodies, or private source material.

The strongest user promise is:

> Do not make the user know the right question before the tool helps them.

Future `civ-ph` commands should prioritize:

- `civ-ph start`
- `civ-ph spark <source_id>`
- `civ-ph path <path_id>`
- `civ-ph show <source_id>`
- `civ-ph prompt <source_id> --mode counter-reading`

The viral hook is:

> Import the civilizational context layer.

## Operating Posture

The right posture is:

```text
serious -> source-disciplined -> tool-native
```

Avoid sounding like a fan archive or a debunking project. The stronger identity is:

> We help students and AI systems study the Predictive History corpus with context, boundaries, and routes.

## Design Consequences

- Start users with paths and first questions, not blank search.
- Keep all public cards compact, bounded, and source-routed.
- Treat review warnings as quality queues, not hidden defects.
- Build Civilization Museum exhibits for orientation, not proof.
- Preserve transcript exactness even when commentary adds guardrails.
- Make contribution tasks concrete enough for open-source helpers.
- Keep `civ-ph` provider-neutral and portable.

## Refresh Triggers

Refresh this profile before:

- public launch of `civ-ph`
- major contributor recruitment
- Civilization Museum bounty expansion
- package release
- public claims about audience size or growth
- adding official-looking branding or affiliation language
