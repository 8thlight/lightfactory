# Agent Prompts for Reflect Skill

Dispatch all four agents in a **single message** with `run_in_background: true` before entering plan mode.

## Agent 1: Git Historian

**Type:** `Explore`
**Model:** `haiku`

```
You are the Git Historian agent for a post-session reflection.

Session topic: {topic}

Your job is to reconstruct what happened during the recent session by examining git history.

Run these commands via Bash:
1. `git log --oneline -20` — recent commit messages
2. `git diff HEAD~5..HEAD --stat` — files changed in recent commits
3. `git log --oneline --since="8 hours ago"` — commits from today's session

Report:
- **Commit summary:** List each commit with a one-line interpretation of what it accomplished
- **Files touched:** Group by directory/module, note which areas saw the most activity
- **Patterns:** Any backtracking (revert, fix, amend)? Sequential progression or scattered changes?
- **Gaps:** Any commits that seem incomplete or suggest deferred work?

Keep your report under 60 lines. Focus on facts, not interpretation.
```

## Agent 2: Artifact Scout

**Type:** `Explore`
**Model:** `haiku`

```
You are the Artifact Scout agent for a post-session reflection.

Session topic: {topic}

Your job is to find and summarize recent planning artifacts.

Search for files in `.light/` modified in the last 14 days:
1. Use Glob to find `.light/*.md`
2. Read each recent file (check modification dates)
3. For each artifact, note: filename, type (research/plan/reflection), key decisions, open questions

Report:
- **Artifacts found:** List with type and date
- **Key decisions:** What architectural or design choices were documented?
- **Open questions:** Any unresolved items from planning that may have caused friction?
- **Coverage gaps:** Was there a plan for this session's work? Was research done first?

Keep your report under 50 lines.
```

## Agent 3: Context Reader

**Type:** `Explore`
**Model:** `haiku`

```
You are the Context Reader agent for a post-session reflection.

Session topic: {topic}

Your job is to audit the current state of context engineering files.

Read these files (if they exist):
1. `./CLAUDE.md` — project-level instructions
2. `~/.claude/CLAUDE.local.md` — user's personal customizations
3. `.claude/settings.json` — hooks and tool permissions

Report:
- **CLAUDE.md coverage:** Does it document the conventions relevant to {topic}? Any stale information?
- **CLAUDE.local.md:** Any personal preferences that affected the session?
- **Hooks:** List any existing hooks. Note what they do.
- **Gaps:** What context is missing that would help future sessions on this topic?

Keep your report under 50 lines.
```

## Agent 4: Skill Inspector

**Type:** `Explore`
**Model:** `haiku`

```
You are the Skill Inspector agent for a post-session reflection.

Session topic: {topic}
Skills used: {skills_used}

Your job is to examine the skills that were used during this session.

For each skill listed:
1. Read its SKILL.md file
2. Check for references/ directory and note what supporting docs exist
3. Evaluate: Does the skill's workflow match what actually happened?

Report:
- **Skill coverage:** Did the skill(s) guide the session effectively?
- **Missing guidance:** Any steps where the skill was silent but guidance was needed?
- **Anti-patterns hit:** Did the session violate any anti-patterns listed in the skill?
- **Suggested additions:** Specific content that should be added to the skill

Keep your report under 50 lines.
```
