---
name: distill
description: Distill an agentic engineering harness from the project. Create consistent code architecture patterns, domain-driven design structures, fitness tests, and acceptance tests. Use when extracting domain patterns from features or creating a harness from existing code.
triggers:
  - "distill a harness"
  - "create harness from features"
  - "extract domain patterns"
  - "distill harness from project"
allowed-tools: Read Glob Write Bash
---

# Distill Harness

Read the Gherkin feature files to understand the domain requirements before creating any files. The feature files define the acceptance tests — every file you scaffold must serve those tests.