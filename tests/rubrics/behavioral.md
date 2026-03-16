# Behavioral Rubric

Grading rubric for Category B skills. Use when code-grading cannot assess quality, relevance, or behavioral constraints.

## Applicable Skills

| Skill | Why LLM-judge | Scenario IDs |
|-------|---------------|--------------|
| `reflect` | Proposal relevance, actionability, anti-pattern adherence | reflect-02, reflect-03 |
| `pair` | Question-before-answer discipline, strictness enforcement, session exit quality | pair-01, pair-02, pair-03, pair-04, pair-05 |
| `research` (partial) | Parallel dispatch behavior, AskUserQuestion usage | research-02, research-04, research-05 |
| `craft` (partial) | RED gate hard stop, remediation limit enforcement | craft-03, craft-06 |
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

Session: craft session with one lint auto-fix remediation; lint fast-path absent from implement skill.md.

```
You are evaluating the output of the reflect skill.

SESSION CONTEXT:
- 3 craft commits: "craft: implement discount validator", "craft: fix failing test for edge case",
  "craft: add integration test"
- craft-execution-log.md shows one lint-error remediation cycle (auto-fixed)
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

## Example: pair Skill (scenario pair-05)

Session: pair session in COLLABORATIVE mode covering async/await patterns and error handling in a TypeScript service. Engineer typed `/unpair` to end the session.

```
You are evaluating the output of the pair skill.

SESSION CONTEXT:
- Pair session in COLLABORATIVE mode
- Familiarity: "Some experience"
- Task: Add a retry mechanism to the UserService.fetchProfile() method
- Concepts covered: async/await, Promise chaining, error boundaries, exponential backoff
- Engineer successfully implemented a retry wrapper with three attempts and backoff delays
- No mention of circuit breakers or rate limiting during the session

SKILL OUTPUT TO EVALUATE: {SKILL_OUTPUT}

Dimension 1 — Relevance (1-3): Are next steps grounded in concepts from THIS session?
  1 = Generic ("keep practicing") or references topics not discussed  2 = Most items session-specific; one generic  3 = All items traceable to session content
Dimension 2 — Completeness (1-3): Are all required summary sections present?
  1 = Missing 2+ sections (Concepts Covered, Key Learnings, What You Built/Fixed, Suggested Next Steps)  2 = Missing 1 section  3 = All four sections present
Dimension 3 — Actionability (1-3): Are next steps specific enough to act on without clarification?
  1 = Vague ("read more about async")  2 = Most actionable; one underspecified  3 = Every step names a concrete target (specific pattern, file, or library)
Dimension 4 — Strictness adherence in summary (1-3): Did the summary respect COLLABORATIVE mode boundaries?
  1 = Summary contains code the engineer did not write  2 = Summary shows code but only to compare approaches  3 = Summary describes what was built without writing new production code

Pass threshold: 9/12. Return: PASS or FAIL, total score, one sentence per dimension.
```

Expected: PASS 10–12/12 for a well-formed output (e.g., "Practice the exponential backoff pattern by applying it to the `NotificationService.send()` method"); FAIL 6–8/12 if next steps are generic or sections are missing.
