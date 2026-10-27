# Tracker: YAKS Mode

Use this procedure when `yx list --format json` succeeds.

## Procedure

Write every context with a quoted heredoc (`<<'CONTEXT'`), as below — never `echo "…"` or a
`printf` format string: contexts contain backticks, `$` and `%`, which the shell would expand.
Run the blocks without their list indentation: the closing `CONTEXT` must start at column 0.

1. **Create the epic** yak and write its context (the commit policy and the acceptance criteria, which `/implement` reads instead of the plan file):
   ```bash
   yx add "{Feature Name}"
   yx context "{Feature Name}" <<'CONTEXT'
   commit: {per-task|per-group|none}

   Acceptance criteria:
   {criteria}
   CONTEXT
   ```
2. **For each phase**, create yaks per the agent-step decomposition:
   - **Leaf phases** (schema, infrastructure): single yak under the epic with `--field "agent-type=no-test"`
   - **Journey fragment RED** (`P{N}-E2E-Red-{Step}`): single yak under the epic with `--field "agent-type=agent-test"`
   - **TDD phases**: parent yak under epic + 3 children (write-tests, implement, validate)
   - **Final verification**: single yak under epic with `--field "agent-type=agent-validate"`
3. **Set custom fields** on each yak: `--field "agent-type={agent-test|agent-impl|agent-validate|no-test}"`
4. **Pipe context** into each leaf yak (the Agent Context block from the plan):
   ```bash
   yx context "{yak name}" <<'CONTEXT'
   {agent context markdown}
   CONTEXT
   ```

## Creating a TDD Phase Group (YAKS)

```bash
# Create the phase group parent
yx add "P2-Core-Logic" --under "{Feature Name}"

# Create TDD triplet children
yx add "01-write-tests" --under "P2-Core-Logic" --field "agent-type=agent-test"
yx add "02-implement" --under "P2-Core-Logic" --field "agent-type=agent-impl"
yx add "03-validate" --under "P2-Core-Logic" --field "agent-type=agent-validate"

# Pipe agent context into each child
yx context "01-write-tests" <<'CONTEXT'
{write-tests agent context}
CONTEXT
yx context "02-implement" <<'CONTEXT'
{implement agent context}
CONTEXT
yx context "03-validate" <<'CONTEXT'
{validate agent context}
CONTEXT
```

## Creating a Leaf Phase (YAKS)

```bash
yx add "P1-Schema-Setup" --under "{Feature Name}" --field "agent-type=no-test"
yx context "P1-Schema-Setup" <<'CONTEXT'
{agent context}
CONTEXT
```

## Readiness Convention (YAKS)

The implement skill computes readiness from `yx list --format json` using these rules:

1. **Phase groups ordered by prefix**: P1 < P2 < P3 (extracted from name)
2. **Same-prefix groups are independent**: P2-Feature-A and P2-Feature-B can run in parallel
3. **A phase group is "active"** when all lower-prefix groups are done
4. **Within an active group**:
   - Leaf (no children): the yak itself is ready if state != done
   - Parent (has children): the first child by name sort with state != done is ready
5. **All ready tasks** from all active groups are dispatched in parallel
