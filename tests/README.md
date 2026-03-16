# Skill Testing

Test scenarios for the skills in this plugin. The testable units are markdown workflow documents whose behaviors are evaluated by running them with Claude.

Derived from AGENTS.md and skill testing research findings.

### Three Testing Areas

**1. Triggering** — Does the skill load at the right times?

The testable unit is the `description` frontmatter field. Probe with: "When would you use the [skill-name] skill?"

- Positive tests: phrases that SHOULD cause the skill to load
- Negative tests: phrases that MUST NOT cause the skill to load
- Measure precision (false positives = over-triggering) and recall (false negatives = under-triggering) separately

**2. Functional** — Does the skill produce correct outputs?

Express expected behaviors as Given/When/Then assertions. Skills fall into grading categories:

- Category A (structured output): research, plan-tasks, implement, tdd, refactor — code-grading viable
- Category B (behavioral/interactive): pair, reflect — LLM-as-judge required
- Category C (audit/fix hybrid): tidy, diagram — mix of both

**3. Performance** — Does the skill improve over baseline?

Compare with vs. without the skill: token count, clarification turns, error rate. Also run self-consistency checks: same input multiple times at temperature > 0; high output variance = ambiguous instructions (Finding 4).

### Grading Tiers

Prefer higher-certainty methods (Finding 2).

| Tier | Method | When to use |
|------|--------|-------------|
| 1 (preferred) | Code-based | File exists, section headers present, regex, exit condition enforced |
| 2 | LLM-as-judge | Subjective quality: tone, teaching behavior, proposal relevance |
| 3 (last resort) | Human review | Novel failure modes, calibrating LLM judge rubrics |

### Claude A/B Method

1. Complete a task with Claude A (expert). Note what context you repeatedly provide.
2. Ask Claude A to create or improve a skill capturing the pattern.
3. Test with Claude B (tester) on real tasks against scenario assertions.
4. Return specific failures to Claude A: "Claude B forgot to X when asked to Y."
5. Iterate. Test across models: Haiku, Sonnet, Opus.

## Three-Layer Testing Model

### Layer 1 — Deterministic (Local)

Fast structural and trigger validation. No API calls.

```bash
bash tests/local/validate-skills.sh
```

Checks 8 categories of rules:
- Skill directory structure and frontmatter validity
- Description length and content constraints
- Trigger format (multi-word phrases, top-level key)
- `allowed-tools` list
- SKILL.md line count (≤300)
- Scenario YAML schema
- Trigger coverage (positive and negative entries present)
- Rubric file references

All checks must pass before shipping a skill.

### Layer 2 — Promptfoo Evals (LLM)

Functional and behavioral evaluation using the Claude CLI as a provider. Makes real API calls; incurs cost.

```bash
cd tests/evals && promptfoo eval
```

See [`tests/evals/README.md`](evals/README.md) for full setup, cost expectations, and per-scenario breakdown.

### Layer 3 — Human Review

Manual review for subjective quality: tone, teaching behavior, proposal relevance. Use when grading tier is `human` or when calibrating LLM-judge rubrics.

### Manual (Claude A/B)

1. Open a new Claude Code session (Claude B — no prior context).
2. For each scenario in the skill's YAML file:
   - Triggering: send the `input` phrase; verify skill loaded or did not.
   - Functional: execute `given` setup, send `when` prompt, check `then` assertions.
3. Record pass/fail. Return failures to Claude A with scenario ID and observed behavior.

## Scenario YAML Format

Each file in `tests/scenarios/` covers one skill.

### Field Definitions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `skill` | string | yes | Kebab-case skill name matching `plugins/implementer/skills/` directory |
| `version` | string | yes | Date-stamped version (`YYYY-MM-DD`) |
| `category` | string | yes | `structured-output`, `behavioral`, `audit-fix`, or `reference` |
| `triggering.positive` | list of strings | yes | Phrases that SHOULD cause the skill to load |
| `triggering.negative` | list of strings | yes | Phrases that MUST NOT cause the skill to load |
| `functional[].id` | string | yes | Unique identifier within the file, e.g. `adr-01` |
| `functional[].description` | string | yes | One-sentence summary of what this scenario tests |
| `functional[].grading` | string | yes | `code`, `llm-judge`, or `human` |
| `functional[].given` | string | yes | Pre-conditions and setup before the test prompt |
| `functional[].when` | string | yes | Exact user prompt sent to Claude B |
| `functional[].then` | list of strings | yes | Assertions to verify after the skill completes |
| `functional[].notes` | string | no | Cross-model observations or known edge cases |

## Example Scenario

```yaml
skill: adr
version: "2026-02-24"
category: structured-output

triggering:
  positive:
    - "Write an ADR for switching from REST to GraphQL"
    - "Create an architecture decision record for our caching strategy"
    - "Document this design decision as an ADR"
  negative:
    - "What is an architecture diagram?"
    - "Help me refactor this function"
    - "What's the weather in Seattle?"

functional:
  - id: adr-01
    description: Produces a valid ADR file with all required sections at the correct path
    grading: code
    given: |
      A project with docs/decisions/ directory. No existing ADRs (next sequence is 0001).
    when: "Write an ADR for our decision to adopt hexagonal architecture for the payments service"
    then:
      - "File exists at docs/decisions/0001-*.md"
      - "File contains section: ## Context"
      - "File contains section: ## Decision"
      - "File contains section: ## Options Considered (>= 2 alternatives)"
      - "File contains section: ## Consequences"
      - "Status field is set to Proposed"
      - "Decision section uses active voice"

  - id: adr-02
    description: Enforces Harmel-Law signal check — does not write ADR if decision is not yet made
    grading: llm-judge
    given: |
      The user is uncertain which database to choose.
    when: "Write an ADR, I'm not sure whether to use Postgres or DynamoDB yet"
    then:
      - "Claude asks whether the decision has been made before creating a file"
      - "No ADR file is created until the decision is confirmed"
    notes: "Haiku may skip the signal check — watch for premature file creation"

  - id: adr-03
    description: Sequences correctly when ADRs already exist
    grading: code
    given: |
      docs/decisions/0001-use-hexagonal-architecture.md already exists.
    when: "Write an ADR for our decision to use JWT for authentication"
    then:
      - "New file is created at docs/decisions/0002-*.md"
      - "File does not overwrite docs/decisions/0001-*.md"
```

## Directory Layout

```
tests/
├── README.md          # This file — methodology and format specification
├── local/
│   └── validate-skills.sh  # Layer 1: deterministic structural/trigger checks
├── evals/
│   ├── README.md           # Layer 2: Promptfoo eval setup and scenario breakdown
│   └── promptfooconfig.yaml
├── scenarios/         # Per-skill YAML scenario files (one file per skill)
└── rubrics/           # Grading rubrics for LLM-as-judge evaluation
```
