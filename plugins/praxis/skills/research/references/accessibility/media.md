# Video, Audio, and Media Players

> Provenance and license: `PROVENANCE.md`, `LICENSE-community-access.md`.

Read this when the feature plays, records, streams, or embeds video or audio, or builds a player.

## What to look for in the codebase

- `<video>`, `<audio>`, `<track>`, or a player library, and whether the project supplies its own controls.
- Where caption and transcript files come from, and who produces them.
- Autoplay and background media.
- Live or streamed media.

## WCAG time-based media

| SC | Level | Requirement |
|---|---|---|
| 1.2.1 | A | Audio-only and video-only: a transcript, or an equivalent track |
| 1.2.2 | A | Captions for prerecorded audio in video |
| 1.2.3 | A | Audio description or a text alternative for prerecorded video |
| 1.2.4 | AA | Captions for live audio in video |
| 1.2.5 | AA | Audio description for prerecorded video |
| 1.2.6 to 1.2.9 | AAA | Sign language, extended description, full text alternative, live audio-only alternative |

## Requirements

**Captions and transcripts**
- Captions cover speech, speaker changes (when two or more people speak), and meaningful sounds in brackets (`[applause]`, `[upbeat music]`). They are synchronized and reviewed. Auto-generated captions alone rarely reach the accuracy caption style guides target.
- Provide a full transcript beside or linked from the media. Speaker names and non-speech audio belong in it.
- Formats: WebVTT (starts with a `WEBVTT` header, period before milliseconds), SRT (comma before milliseconds, no styling), TTML or IMSC for broadcast and streaming.
- Style-guide targets, not WCAG requirements: about 99% accuracy, sync within 1 second, at most 2 lines and about 32 characters per line, at most about 200 words per minute, display time about 1 to 7 seconds.

**Audio description**
- Describe actions, scene changes, on-screen text, and visual details that matter. Do not narrate what the audio already says or add interpretation.
- Browsers do not voice a `kind="descriptions"` text track, and screen reader support is limited. To meet 1.2.5 reliably, offer a version with the description in the audio track, or a player that voices the text track, and keep the text track as a supplement.

**Player controls**
- Keyboard-operable play and pause, volume, seek, captions toggle, and fullscreen. Prefer native `<button>` and `<input type="range">`.
- Custom sliders carry `aria-valuemin`, `aria-valuemax`, `aria-valuenow`, and `aria-valuetext` (such as "2 minutes 30 seconds"). Toggles expose their state with `aria-pressed`.
- Announce state changes ("Playing", "Paused", "Captions on") through a polite live region (see `live-regions.md`).
- Convention for shortcuts: Space or Enter for play, arrows for seek and volume, M, C, and F for mute, captions, and fullscreen. Single-letter shortcuts work only while the player has focus, or can be turned off or remapped (2.1.4).
- No autoplay without user control (1.4.2). Upstream accepts muted autoplay only with a visible play and pause control. Identify the video with a visible heading or `aria-label`.

**Live captioning**
- 1.2.4 requires captions for live audio in synchronized media. Options are a human captioner (CART), automatic captions, or a hybrid, with human review recommended. Push live text into an `aria-live="polite"` container.

## Criteria wording

| Criterion | Check |
|---|---|
| Each prerecorded video with speech has a synchronized caption track | `[auto]` |
| Each audio-only item has a transcript link | `[auto]` |
| Play, pause, volume, seek, captions, and fullscreen work by keyboard and have names | `[auto]` |
| No media starts playing with sound without a control | `[auto]` |
| Caption text is accurate, in sync, and names speakers | `[manual]` |
| Audio description conveys the visual information a listener needs | `[manual]` |
| A screen reader announces player state changes | `[manual]` |
