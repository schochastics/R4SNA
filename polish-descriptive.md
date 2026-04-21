# Consistency review — Descriptive chapters of R4SNA

## Context

The book's "Descriptive Network Analysis" part currently contains eight chapter files. A consistency pass is overdue: the part's introduction is empty, `ego-networks.qmd` diverges from the rest in length, tone, and tooling, and several small inconsistencies have accumulated across chapters (heading conventions, `set.seed` usage, typos, smart quotes, table syntax). This plan lays out the concrete fixes grouped by severity, with file:line pointers so they can be executed in a single cleanup pass.

Chapters reviewed (in `descriptive/`):

1. `introduction.qmd` (1 line — empty)
2. `descriptives-basic.qmd` (420 lines)
3. `centrality-basic.qmd` (481 lines)
4. `clustering.qmd` (600 lines)
5. `two-mode-networks.qmd` (312 lines)
6. `signed-networks.qmd` (384 lines)
7. `ego-networks.qmd` (1067 lines)
8. `netropy.qmd` (790 lines)

---

## High-severity issues

### H2. `ego-networks.qmd` is stylistically and tonally out of line with the rest

Decision (per user): **flag but keep in scope** — do not restructure / split. The scope of fixes below is tone, typos, and cross-references only, not re-architecting the chapter.

Observed divergences vs. the other seven chapters:

- **Length:** 1067 lines (avg of the other six content chapters ≈ 498). The "Predicting Individual Outcomes Using Ego Network Measures" section alone runs from [ego-networks.qmd:541](descriptive/ego-networks.qmd#L541) to the end of the file (~500+ lines of regression content).
- **Tooling:** only chapter to `library(tidyverse)`, `library(MASS)`, `library(knitr)` at [ego-networks.qmd:16-18](descriptive/ego-networks.qmd#L16-L18). Other chapters stay with `igraph` + topic-specific packages and load `ggraph`/`patchwork` silently.
- **Smart quotes / curly apostrophes:** present throughout (e.g. `individual's`, `respondents'`, `isn't`). Other chapters use straight quotes.
- **Typos:** `incldue` at [ego-networks.qmd:571](descriptive/ego-networks.qmd#L571).
- **Duplicated prose:** [ego-networks.qmd:543](descriptive/ego-networks.qmd#L543) and [ego-networks.qmd:549](descriptive/ego-networks.qmd#L549) restate the same "ego networks can be treated as independent observations" argument back-to-back.
- **Voice:** heavy first-person plural ("we"), dense multi-sentence paragraphs, bolded inline emphasis (**bold**) used for definitions where other chapters use `*italic*`.
- **In-code headings used as Quarto `## Note` headings** at [ego-networks.qmd:22](descriptive/ego-networks.qmd#L22), [ego-networks.qmd:339](descriptive/ego-networks.qmd#L339), [ego-networks.qmd:660](descriptive/ego-networks.qmd#L660), [ego-networks.qmd:820](descriptive/ego-networks.qmd#L820) — these are inside `::: {.callout-note}` blocks and render a redundant "Note" title above the already-labelled callout. Other chapters' callouts (e.g. [centrality-basic.qmd:34](descriptive/centrality-basic.qmd#L34), [centrality-basic.qmd:310](descriptive/centrality-basic.qmd#L310)) omit the inner heading.

**Fix — single pass of polish:**

- Replace smart quotes with straight quotes throughout the file.
- Fix typo `incldue` → `include` at line 571.
- Remove duplicated "independent observations" paragraph at line 549 (or line 543).
- Remove the inner `## Note` headings inside `::: {.callout-note}` blocks — match the convention used in the rest of the book.
- Consider moving `library(tidyverse)`, `library(knitr)`, `library(MASS)` into a silent (`include: false`) block to match [descriptives-basic.qmd:14-18](descriptive/descriptives-basic.qmd#L14-L18) pattern, so the visible library list matches other chapters in feel.
- Leave regression content and length as-is per your decision.

### H3. `netropy.qmd` table syntax is non-standard

[netropy.qmd:27](descriptive/netropy.qmd#L27), [netropy.qmd:40](descriptive/netropy.qmd#L40), and further below use:

```
#### Table: Edge-Based Representation {.unnumbered}
```

as a section heading above a raw markdown table. No other chapter does this; elsewhere tables are rendered via `knitr::kable()` with standard Quarto captions (e.g. [centrality-basic.qmd:372-386](descriptive/centrality-basic.qmd#L372-L386)).

**Fix:** Convert each `#### Table:` pseudo-heading to a proper Quarto table with a label and caption:

```
: Edge-Based Representation {#tbl-edge-representation}

| observation | ... |
| ...         | ... |
```

This makes tables cross-referenceable via `@tbl-edge-representation` and removes the misleading heading-level-4 from the TOC. Also review the `#### Vertex Variables {.unnumbered}` style subsection headings at [netropy.qmd:92](descriptive/netropy.qmd#L92) and similar — keep those as headings, but note they are inconsistent with numbering in other chapters (see L1).

---

## Medium-severity issues

### M1. Cross-references between chapters that share datasets

Same networks are reintroduced without a pointer back:

- **Florentine marriage (`flo_marriage`)** introduced at [descriptives-basic.qmd:20-44](descriptive/descriptives-basic.qmd#L20-L44) and reused as the "Use Case" at [centrality-basic.qmd:333-402](descriptive/centrality-basic.qmd#L333-L402) with no reference back. A single sentence — "We return to the Florentine families network introduced in @sec-basic-network-statistics…" — plus a `{#sec-basic-network-statistics}` anchor on the chapter title would close this.
- **Zachary's karate club** introduced at [centrality-basic.qmd](descriptive/centrality-basic.qmd) and reused as the main example in clustering. Add a one-line pointer in [clustering.qmd:~193](descriptive/clustering.qmd).

**Fix:** Add `{#sec-basic-network-statistics}` to the title of `descriptives-basic.qmd`, add cross-references at the two reuse sites above. Do not try to unify dataset choice across all chapters — the current choices are driven by topical fit (`dbces11` for centrality, `southern_women` for two-mode, etc.).

### M2. Chapter opening structure varies

Most chapters open with one or two motivating paragraphs followed by a `## Packages Needed for this Chapter` block. Outliers:

- [ego-networks.qmd:2](descriptive/ego-networks.qmd#L2): single 500-word paragraph; no spacing/structure.
- [two-mode-networks.qmd:1-10](descriptive/two-mode-networks.qmd#L1-L10): four-paragraph opener is fine, but the bulleted list of two-mode examples runs before the motivation is complete.
- [netropy.qmd:2-9](descriptive/netropy.qmd#L2-L9) opens well but does not acknowledge its position at the end of the descriptive sequence.

**Fix:** Break the long ego-networks opening into 3–4 paragraphs; minor tightening elsewhere. Do not change `netropy.qmd` framing unless H1 (new introduction.qmd) explicitly sets up what netropy builds on.

### M3. `set.seed()` usage is inconsistent

Different seed values are used in different chapters with no pattern:

- [descriptives-basic.qmd:413](descriptive/descriptives-basic.qmd#L413): `set.seed(112)`
- [clustering.qmd](descriptive/clustering.qmd): `set.seed(1234)` and `set.seed(42)`
- [signed-networks.qmd](descriptive/signed-networks.qmd): `set.seed(44)`, `set.seed(424)`, `set.seed(42)`

**Fix:** Pick one seed (e.g. `42`) and use it everywhere a seed is needed, or document a per-example rationale. Low effort; improves reproducibility consistency.

### M4. `ego-networks.qmd` raw `DS0001/` / `DS0005/` data files at project root

The chapter's data-prep block at [ego-networks.qmd:47-322](descriptive/ego-networks.qmd#L47-L322) is wrapped in `include: false` and reads from `DS0001/36975-0001-Data.rda` and `DS0005/36975-0005-Data.rda`. These directories sit at [descriptive/DS0001](descriptive/DS0001) and [descriptive/DS0005](descriptive/DS0005). The code comment at [ego-networks.qmd:44](descriptive/ego-networks.qmd#L44) says the full prep code is in `@sec-apx-ucnets` (the UCNets appendix) but the chapter still embeds the same ~280 lines of prep.

**Fix:** Since the appendix exists ([appendix/ucnets-egor.qmd](appendix/ucnets-egor.qmd)), replace the embedded prep block with a single `readRDS()` or `load()` of a pre-built `egor` object, and point readers to the appendix. This would shorten the chapter by ~280 lines without removing any content.

---

## Low-severity polish (single cleanup pass)

All verified with file:line pointers so they can be fixed in one go.

- **L1. `{.unnumbered}` usage is inconsistent.** Used heavily in `netropy.qmd` (subsection headings under "Data Editing") and sparingly in `ego-networks.qmd`; not used in the other six chapters. Decide whether section numbering goes 3 levels deep everywhere or is capped at level 2.

- **L2. Library-loading style drift.**
  - `descriptives-basic.qmd`, `centrality-basic.qmd`, `clustering.qmd`, `two-mode-networks.qmd`, `signed-networks.qmd` all use `#| label: libraries` + a silent `#| label: libraries-silent` for `ggraph`/`patchwork` — good pattern.
  - `ego-networks.qmd` [L8-L19](descriptive/ego-networks.qmd#L8-L19) uses `#| message: false #| warning: false` with everything in one block.
  - `netropy.qmd` [L12-L18](descriptive/netropy.qmd#L12-L18) same as ego-networks, plus loads `patchwork` later at [netropy.qmd:132](descriptive/netropy.qmd#L132) instead of up top.

  **Fix:** Apply the `libraries` + `libraries-silent` pattern consistently; move `patchwork` to the silent top-of-chapter block in `netropy.qmd`.

- **L3. Chapter-title anchors missing in two files.**
  - `descriptives-basic.qmd:1` — has no `{#sec-…}`. Others do: `centrality-basic.qmd` → `{#sec-centrality}`, `clustering.qmd` → `{#sec-cohesive-subgroups}`, `signed-networks.qmd` → `{#sec-signed-networks}`, `ego-networks.qmd` → `{#sec-ego}`, `netropy.qmd` → `{#sec-netropy}`.
  - `two-mode-networks.qmd:1` — no `{#sec-…}`.

  **Fix:** Add `{#sec-basic-network-statistics}` to `descriptives-basic.qmd` and `{#sec-two-mode-networks}` to `two-mode-networks.qmd`.

- **L4. Smart quotes / curly apostrophes.** Present in `ego-networks.qmd` (covered under H2) and `two-mode-networks.qmd` (e.g. "women's", "author's"). Not present in the other five. Replace with straight quotes for visual consistency.

- **L5. `tidyverse` loaded locally inside `two-mode-networks.qmd`.** [two-mode-networks.qmd:56](descriptive/two-mode-networks.qmd#L56) calls `library(tidyverse)` mid-chapter inside a plotting block. Move to the silent libraries block at top of file, or convert the few `tidyverse` calls to base R / `dplyr::` prefixed calls to match the rest of the book.

- **L6. Typo.** `incldue` → `include` at [ego-networks.qmd:571](descriptive/ego-networks.qmd#L571).

- **L7. Duplicated sentence.** [ego-networks.qmd:543](descriptive/ego-networks.qmd#L543) and [ego-networks.qmd:549](descriptive/ego-networks.qmd#L549) state the same "independent observations" point. Keep one.

- **L8. Inner `## Note` headings inside callouts.** Several callouts in `ego-networks.qmd` include a redundant `## Note` heading inside the `::: {.callout-note}` block. The rest of the book uses bare callouts. Remove the inner headings.

---

## What I am *not* proposing

To keep the fix pass tight, these explicitly stay out:

- **Not** extracting a shared `_setup.R` or common libraries file. Each chapter's `library()` calls are short and make chapters executable standalone, which is a Quarto-book idiom.
- **Not** redefining shared concepts (density, degree) in one place and stripping them from the others. The repetition that exists is small and each chapter's use is context-specific (descriptives-basic defines density as a structural property; clustering references it inside the modularity formula).
- **Not** splitting or trimming the ego-networks regression section (per your call).
- **Not** reworking the chapter order. The current order (basics → centrality → clustering → two-mode → signed → ego → netropy) is pedagogically sound; H1 will make this explicit in prose.

---

## Files to modify

- [descriptive/introduction.qmd](descriptive/introduction.qmd) — write new content (H1).
- [descriptive/ego-networks.qmd](descriptive/ego-networks.qmd) — H2, M4, L4, L6, L7, L8.
- [descriptive/netropy.qmd](descriptive/netropy.qmd) — H3, L2.
- [descriptive/descriptives-basic.qmd](descriptive/descriptives-basic.qmd) — L3 (title anchor).
- [descriptive/centrality-basic.qmd](descriptive/centrality-basic.qmd) — M1 (cross-ref to flo_marriage origin).
- [descriptive/clustering.qmd](descriptive/clustering.qmd) — M1 (cross-ref to karate origin), M3 (seed).
- [descriptive/two-mode-networks.qmd](descriptive/two-mode-networks.qmd) — L3, L4, L5.
- [descriptive/signed-networks.qmd](descriptive/signed-networks.qmd) — M3 (seed).

`appendix/ucnets-egor.qmd` may need a small addition if M4 is adopted (save a pre-built `egor` object).

---

## Verification

1. `quarto render` the book locally and scan the built `_book/` output for:
   - The new descriptive introduction renders and reads like the visualization / inferential intros.
   - `@sec-basic-network-statistics` and the new ego-networks cross-references resolve (no "??" placeholders).
   - The netropy tables render as captioned numbered tables, and `@tbl-…` references (if added) resolve.
2. `grep -rn "['']['']" descriptive/` returns no matches (smart quotes gone).
3. `grep -rn "incldue" descriptive/` returns no matches.
4. Skim the TOC of the rendered book — heading levels across descriptive chapters should look uniform.
5. Spot-check `ego-networks.qmd` in browser: the callouts render without a redundant "Note" title, and the code still executes against the `DS0001/`/`DS0005/` data (or the prebuilt egor object if M4 was done).
