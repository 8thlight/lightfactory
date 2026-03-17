# Behavioral Rubric

Grading rubric for Category B skills. Use when code-grading cannot assess quality, relevance, or behavioral constraints.

## Applicable Skills

| Skill | Why LLM-judge | Scenario IDs |
|-------|---------------|--------------|
| `reflect` | Proposal relevance, actionability, anti-pattern adherence | reflect-02, reflect-03 |
| `research` (partial) | Parallel dispatch behavior, AskUserQuestion usage | research-02, research-04, research-05 |
| `implement` (partial) | RED gate hard stop, remediation limit enforcement | implement-03, implement-06 |
| `hexagonal-architecture` | Layer classification correctness, naming convention adherence, anti-pattern detection | hexarch-01, hexarch-02, hexarch-03, hexarch-04, hexarch-05 |

---

## Judge Prompt Template

```
You are evaluating the output of the {SKILL} skill.

SESSION CONTEXT:
{SESSION_CONTEXT}

SKILL OUTPUT TO EVALUATE:
{SKILL_OUTPUT}

Score each dimension 1–3. Pass threshold: {PASS_THRESHOLD} out of {MAX_SCORE}.

{DIMENSIONS}

Return: PASS or FAIL, total score (e.g. "10/12"), one sentence per dimension.
Do not give partial credit — choose the closest whole number.
```

---

## Standard Scoring Dimensions

| # | Dimension | 1 — Fail | 2 — Partial | 3 — Pass |
|---|-----------|----------|-------------|----------|
| 1 | **Relevance** — outputs grounded in session context | Generic or references absent artifacts | Mostly grounded; one item weakly supported | All outputs traceable to session evidence |
| 2 | **Completeness** — all required elements present | Missing 2+ required elements | Missing 1 required element | All required elements present |
| 3 | **Actionability** — specific enough to act on without clarification | Vague ("improve the skill") | Most actionable; one underspecified | Every item has a clear target and concrete change |
| 4 | **Specificity** — narrow and targeted, no bundled concerns | Multiple broad or rewrite-scope items | One item broader than necessary | All items small, targeted, concern-separated |

**Default pass threshold: 9/12** (75%). Use 10/12 for high-stakes evaluations (proposals that will be committed).

---

## Example: reflect Skill (scenario reflect-03)

Session: implement session with one lint auto-fix remediation; lint fast-path absent from implement skill.md.

```
You are evaluating the output of the reflect skill.

SESSION CONTEXT:
- 3 implement commits: "implement: implement discount validator", "implement: fix failing test for edge case",
  "implement: add integration test"
- implement-execution-log.md shows one lint-error remediation cycle (auto-fixed)
- implement skill.md anti-patterns section does not mention lint fast-path; no AskUserQuestion hook in .claude/settings.json

SKILL OUTPUT TO EVALUATE: {SKILL_OUTPUT}

Dimension 1 — Relevance (1-3): Are proposals grounded in the actual session context?
  1 = Generic or references files not in the session  2 = One invented item  3 = All traceable to evidence
Dimension 2 — Completeness (1-3): Do proposals cover the key friction points?
  1 = Undocumented lint fast-path not addressed  2 = Addressed but missing hook gap  3 = Both gaps covered
Dimension 3 — Actionability (1-3): Specific enough to implement immediately?
  1 = Vague  2 = Most actionable; one underspecified  3 = All have Target file + Proposed change
Dimension 4 — Proposal count (1-3): Within the 5-proposal cap?
  1 = More than 5 (cap violated)  2 = Exactly 5  3 = 3–4 proposals (focused)

Pass threshold: 9/12. Return: PASS or FAIL, total score, one sentence per dimension.
```

Expected: PASS 10–12/12 for a well-formed output; FAIL 6–8/12 for generic or over-broad output.

---

