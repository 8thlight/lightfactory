# Tracker: YAKS Mode

Use this procedure when `yx list --format json` succeeds.

## Procedure

Child names (`01-write-tests`, …) repeat in every group, and `yx` resolves a repeated name to
whichever match it finds first, without an error. So never address a yak by name after creating
it: `yx add` prints the new yak's ID, and stdin piped into `yx add` becomes its context. Use the
printed ID for `--under` and for anything `/implement` does later.

Write every context with a quoted heredoc (`<<'CONTEXT'`), as below — never `echo "…"` or a
`printf` format string: contexts contain backticks, `$` and `%`, which the shell would expand.
Run the blocks without their list indentation: the closing `CONTEXT` must start at column 0.

1. **Create the epic** yak with its context (the commit policy and the acceptance criteria, which `/implement` reads instead of the plan file), and note the printed `{epic id}`:
   ```bash
   yx add "{Feature Name}" <<'CONTEXT'
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
4. **Pipe context** into each task yak as you add it (the Agent Context block from the plan):
   ```bash
   yx add "{yak name}" --under "{parent id}" --field "agent-type={type}" <<'CONTEXT'
   {agent context markdown}
   CONTEXT
   ```

## Creating a TDD Phase Group (YAKS)

```bash
# Create the phase group parent; it prints {group id}
yx add "P2-Core-Logic" --under "{epic id}"

# Create TDD triplet children, each with its agent context
yx add "01-write-tests" --under "{group id}" --field "agent-type=agent-test" <<'CONTEXT'
{write-tests agent context}
CONTEXT
yx add "02-implement" --under "{group id}" --field "agent-type=agent-impl" <<'CONTEXT'
{implement agent context}
CONTEXT
yx add "03-validate" --under "{group id}" --field "agent-type=agent-validate" <<'CONTEXT'
{validate agent context}
CONTEXT
```

## Creating a Leaf Phase (YAKS)

```bash
yx add "P1-Schema-Setup" --under "{epic id}" --field "agent-type=no-test" <<'CONTEXT'
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
