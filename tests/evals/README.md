# Promptfoo Evals

Automated functional evaluation of implement skills using [Promptfoo](https://promptfoo.dev/).

The config at `promptfooconfig.yaml` maps directly to the scenario YAML files in
`tests/scenarios/`. Each functional scenario becomes one test case; triggering
scenarios are not evaluated here (they require separate skill-invocation harness testing).

---

## Prerequisites

```bash
npm install -g promptfoo
```

The eval provider calls the Claude CLI directly:

```yaml
providers:
  - id: exec:claude --print "{{prompt}}"
```

Ensure the `claude` CLI is on your `PATH` and authenticated before running evals.

---

## Running Evals

```bash
# From the project root
cd tests/evals

# Run all scenarios
promptfoo eval

# Run a specific skill's scenarios only
promptfoo eval --filter-description "^\[research"

# Run with a specific config file
promptfoo eval --config promptfooconfig.yaml
```

---

## Viewing Results

```bash
# Open the interactive results browser
promptfoo view

# Output results to the terminal in tabular form
promptfoo eval --output table

# Export results as JSON for CI processing
promptfoo eval --output json > results.json
```

---

## Cost Expectations

Each test case makes one call to the Claude API via the `claude` CLI. The config
contains **24 test cases** total (see breakdown below). LLM-judge assertions make an
additional API call per assertion (the judge model evaluates the output).

| Scenario type | Test cases | LLM-judge assertions | Total API calls (approx.) |
|---------------|-----------|---------------------|--------------------------|
| research      | 5          | 3 (research-02, -04, -05) | 8 |
| draft         | 5          | 2 (draft-03, -04)   | 7 |
| craft         | 6          | 3 (craft-03, -05, -06) | 9 |
| tdd           | 5          | 2 (tdd-04, -05)     | 7 |
| reflect       | 3          | 1 (reflect-03)      | 4 |
| **Total**     | **24**     | **11**              | **~35** |

At typical Sonnet pricing (~$0.003 per 1K output tokens), a full eval run is
estimated at **$0.50–$2.00** depending on response length. LLM-judge calls add
roughly the same amount again.

Run frequency recommendations:
- **Before releases**: always run the full suite
- **After significant skill changes**: run the affected skill's scenarios at minimum
- **During development**: run individual scenarios with `--filter-description`

---

## Recommended Frequency

| Event | Recommended action |
|-------|--------------------|
| Skill SKILL.md edited | Run that skill's scenarios |
| New skill version tagged | Run all scenarios |
| Pre-release validation | Run all scenarios; require 100% pass rate |
| Weekly CI (optional) | Run all scenarios against latest `main` |

---

## Test Case Breakdown

| ID | Skill | Description | Grading |
|----|-------|-------------|---------|
| research-01 | research | Valid artifact with all required sections | code |
| research-02 | research | Agents dispatched in parallel | llm-judge |
| research-03 | research | Confidence levels on every web finding | code |
| research-04 | research | AskUserQuestion called with findings summary | llm-judge |
| research-05 | research | Hard stop after next-steps output | llm-judge |
| draft-01 | draft | Valid plan file with all required sections | code |
| draft-02 | draft | Agent Context blocks in every TDD phase | code |
| draft-03 | draft | TDD phases decomposed into 3 yaks tasks | llm-judge |
| draft-04 | draft | Self-contained yaks task descriptions | llm-judge |
| draft-05 | draft | Inline task graph fallback when yaks unavailable | code |
| craft-01 | craft | craft-execution-log.md created with structured entries | code |
| craft-02 | craft | Full gate pass path (RED, GREEN, VALIDATE) | code |
| craft-03 | craft | RED gate fail hard stop | llm-judge |
| craft-04 | craft | GREEN gate fail enters remediation | code |
| craft-05 | craft | Lint fast path — biome-only failure auto-fixed | llm-judge |
| craft-06 | craft | Escalates to user after 2 failed remediations | llm-judge |
| tdd-01 | tdd | tdd-session-log.md created before any code | code |
| tdd-02 | tdd | [TEST] comments before production code with ZOMBIES | code |
| tdd-03 | tdd | All 7 ZOMBIES letters present | code |
| tdd-04 | tdd | Phase separation — RED confirmed before implementation | llm-judge |
| tdd-05 | tdd | Simplification removes unjustified code after GREEN | llm-judge |
| reflect-01 | reflect | Agent Dispatch Manifest with all 4 agent rows | code |
| reflect-02 | reflect | Proposals capped at 5, priority-ordered, complete fields | code |
| reflect-03 | reflect | Proposals actionable and session-relevant | llm-judge |

**Total: 24 test cases — 13 code-graded, 11 llm-judge**

---

## Adding New Eval Scenarios

Scenarios are defined as YAML in `tests/scenarios/<skill>.yaml`. Each functional
scenario follows this format:

```yaml
functional:
  - id: skill-NN
    description: One sentence describing what behavior is being tested
    grading: code          # or: llm-judge
    given: |
      Context the model should assume (simulated environment state).
    when: "The exact user prompt to send"
    then:
      - "Observable assertion 1"
      - "Observable assertion 2"
    notes: "Optional notes for test authors about known failure modes"
```

### For `grading: code` scenarios

Assertions in `then[]` map to promptfoo assertion types:

| then[] pattern | promptfoo type |
|----------------|---------------|
| "File contains section: ## Foo" | `icontains` with `## Foo` |
| "File contains string matching pattern" | `regex` with the pattern |
| "File does NOT contain string" | `not-icontains` with the string |
| "File exists at path" | `icontains` with the path fragment |

### For `grading: llm-judge` scenarios

Assertions map to a single `llm-rubric` assertion whose value contains a structured
scoring rubric (1-3 per dimension, pass threshold 9/12). The rubric should reference
the specific observable behaviors from `then[]`.

After adding scenarios to the YAML file, add corresponding test cases to
`tests/evals/promptfooconfig.yaml` following the existing patterns in each skill group.
