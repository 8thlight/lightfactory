# Tracker: YAKS Mode

Use this procedure when `yx list --format json` succeeds.

## Procedure

1. **Create the epic** yak: `yx add "{Feature Name}"`
2. **For each phase**, create yaks per the agent-step decomposition:
   - **Leaf phases** (schema, infrastructure): single yak under the epic with `--field "agent-type=no-test"`
   - **TDD phases**: parent yak under epic + 3 children (write-tests, implement, validate)
   - **Final verification**: single yak under epic with `--field "agent-type=agent-validate"`
3. **Set custom fields** on each yak: `--field "agent-type={agent-test|agent-impl|agent-validate|no-test}"`
4. **Pipe context** into each leaf yak (the Agent Context block from the plan):
   ```bash
   echo "{agent context markdown}" | yx context "{yak name}"
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
echo "{write-tests agent context}" | yx context "01-write-tests"
echo "{implement agent context}" | yx context "02-implement"
echo "{validate agent context}" | yx context "03-validate"
```

## Creating a Leaf Phase (YAKS)

```bash
yx add "P1-Schema-Setup" --under "{Feature Name}" --field "agent-type=no-test"
echo "{agent context}" | yx context "P1-Schema-Setup"
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
