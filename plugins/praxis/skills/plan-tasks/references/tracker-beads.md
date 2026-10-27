# Tracker: BEADS Mode

Use this procedure when `ls .beads/config.yaml` succeeds (and yaks is unavailable).

## Procedure

1. **Create the epic**: `Skill: beads:epic --title "{Feature Name}"`, with a description holding `commit: {per-task|per-group|none}` and the acceptance criteria (which `/implement` reads instead of the plan file)
2. **For each phase**, create issues per the agent-step decomposition:
   - **Leaf phases**: `Skill: beads:create --title "P1-Schema-Setup [no-test]" --epic "{epic-id}" --label "no-test"`
   - **Journey fragment RED**: `Skill: beads:create --title "P{N}-E2E-Red-{Step} [agent-test]" --epic "{epic-id}" --label "agent-test"`
   - **TDD phases**: three issues per phase group (write-tests, implement, validate)
   - **Final verification**: `Skill: beads:create --title "P6-Full-Integration [agent-validate]" --epic "{epic-id}" --label "agent-validate"`
3. **Set dependencies** between issues: `Skill: beads:dep --from "{child-id}" --to "{parent-id}"`
   - Each TDD child depends on its predecessor within the phase group
   - Each phase group's first task (a leaf group's only task) depends on the last task of every group at the next-lower P{N}, so parallel groups all finish first
4. **Store agent context** in each issue's description body (the Agent Context block from the plan)

## Creating a TDD Phase Group (BEADS)

```
Skill: beads:create --title "P2-Core-Logic / 01-write-tests" --epic "{epic-id}" --label "agent-test"
  description: {write-tests agent context}

Skill: beads:create --title "P2-Core-Logic / 02-implement" --epic "{epic-id}" --label "agent-impl"
  description: {implement agent context}

Skill: beads:create --title "P2-Core-Logic / 03-validate" --epic "{epic-id}" --label "agent-validate"
  description: {validate agent context}

# Set sequential dependencies within the phase group
Skill: beads:dep --from "02-implement-id" --to "01-write-tests-id"
Skill: beads:dep --from "03-validate-id" --to "02-implement-id"

# Set phase group dependency on every group at the next-lower P{N}
Skill: beads:dep --from "P2/01-write-tests-id" --to "P1-last-task-id"   # repeat per P1 group
```

## Creating a Leaf Phase (BEADS)

```
Skill: beads:create --title "P1-Schema-Setup [no-test]" --epic "{epic-id}" --label "no-test"
  description: {agent context}
```

## Readiness Convention (BEADS)

The implement skill computes readiness from `Skill: beads:list --epic "{epic-id}"` using the same P{N} prefix ordering rules as YAKS mode. Tasks with all dependencies resolved and status != done are ready.
