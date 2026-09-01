# AGENTS.md

Operating manual for every agent / maintainer working on this repository. **Read this before making any change.**

## Project Overview

**Mac × AI Agent — The Complete Development Environment Setup Guide**. A content repository: a 16-chapter macOS setup manual for AI-agent-driven development (works on every Apple Silicon Mac), published in both Markdown and styled HTML, auto-deployed via GitHub Pages.

## Bilingual Layout (important)

English is the **default** (no suffix); Chinese carries the `.zh-CN` suffix:

```
mac-mini-ai-dev-setup.md          # English manual — source of truth for content structure
mac-mini-ai-dev-setup.zh-CN.md    # Chinese manual — full mirror of the English version
mac-mini-ai-dev-setup.html        # English single-page edition (dark terminal aesthetic)
mac-mini-ai-dev-setup.zh-CN.html  # Chinese single-page edition — full mirror
README.md                         # Bilingual repo front page: English first, then 中文
CHANGELOG.md                      # Keep a Changelog, bilingual entries (EN first)
docs/                             # README screenshots, social-preview, readme-standard.md
```

The two language versions of each file are **full mirrors**: same sections, same order, same commands. Code, commands, paths, and identifiers stay in English in both versions; only prose and comments are translated.

## Change Sync Checklist (core discipline)

**For every content change, walk this list — no skipping:**

1. **Edit the English MD first** (`mac-mini-ai-dev-setup.md`)
2. **Mirror into the Chinese MD** (`mac-mini-ai-dev-setup.zh-CN.md`)
3. **Sync both HTML pages** — every component: `p.lead`, `.term` cards, `.tool` cards, `.agent` cards, `.note` blocks, `.rule` lists
4. **Check README** — chapter table, Agent lineup table, tech-stack block, badges (e.g. agent count)
5. **CHANGELOG.md entry** — bilingual, Added / Changed / Fixed, with date
6. **Cut a Release** — new content → minor, fixes → patch, restructure → major:
   `gh release create vX.Y.Z --title "..." --notes "..."`
7. **Verify Pages deploy** (auto-triggered on push):
   `gh api repos/x5/new-mac-setting/pages/builds/latest --jq '{status, commit: .commit[0:7]}'`

## Conventions

### MD footnotes

- Term explanations use footnotes: `[^name]` references, definitions grouped in the glossary section at the end of the file.
- Footnote = plain-language explanation + background + caveats; links allowed.

### HTML tooltips

- Inline term: `<span class="tip">term<span class="tip-bubble"><b>Title</b>explanation</span></span>`
- Tool cards: add `<span class="tip-bubble">` directly inside `.tool` (CSS already handles `.tool:hover`)
- **Never put tooltips inside `.term` code cards** (`overflow:hidden` clips the bubble)

### HTML new sections

- Structure: `section#sNN` + `.sec-head` (`.sec-no` outlined number + `.sec-title` with `.tag` and `h2`) + content blocks
- Add matching `<a href="#sNN">` to sidebar `#nav` — in **both** language pages
- All content blocks carry the `reveal` class (entrance animation)
- Code highlight classes inside `.term`: comments `.c`, prompts `.p`, strings `.s`

### Verification

- After any HTML change, re-verify with Playwright screenshots (`uv run --with playwright`, viewport 1440×900, screenshot files must not be committed)
- Hover-test tooltips at least once (CSS selector pitfalls have bitten us before)
- Verify **both** language pages

### Commits & releases

- Commit messages: English, Conventional Commits (`docs: ...`), single purpose
- Content languages: English + 中文; code / commands / identifiers stay in original form
- Push → Pages builds automatically → live when the build finishes

### Versioning

- minor: new tools, new sections, new content
- patch: errata, command fixes, wording
- major: section restructuring, directional changes

## Related Docs

- Publishing methodology: [docs/readme-standard.md](docs/readme-standard.md)
- Version history: [CHANGELOG.md](CHANGELOG.md)
