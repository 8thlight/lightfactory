# TODO List of feature improvements, bugs, and clean up items

## Harness Engineering
- refactor harness:scaffold skill to be more about the patterns in a harness than about DDD. need to have example libraries of how to implement in each language. Build out language specific references for java, c#, rust, typescript, go. Patterns include: fitness functions, test layers, acceptance tests, gherkin/bdd and better BDD patterns, arch unit/etc, TDD, context management, skills, hooks, agents, etc.
- refactor harness:distill to figure out the patterns\
- Change hexagonal architecture to hexagonal DDD, keep it clean. Look at good examples like yaks and some DDD distilled examples for simplicity and credit authors.

## Agentic Engineering Praxis
- Add in patterns from Simon Willison, etc.
- redo tests and evals, skill-creator flow
- Plan Tasks: fix implement skill workflow detail reference which is unwieldy, it task planning should be centralized, clean up mess of yaks vs beads vs native tasks to just one place, use a skill called `tasks` or `task-graph`
