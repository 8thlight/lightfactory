# Accessibility Reference Files

For maintainers. The research accessibility agent starts at `INDEX.md`, which holds the routing table. This file covers provenance and refreshing.

Each file in this folder is an adaptation of Community Access `accessibility-agents` material (MIT), reshaped for research: where to look in a codebase, requirements, common failures, and acceptance-criteria wording tagged `[auto]` or `[manual]`.

## Two kinds of sources

- **Where the adapted text came from** (Community Access files and commit): `PROVENANCE.md`, for maintainers.
- **Where the standards live** (WCAG, ARIA, platform docs, laws): `standards-and-docs.md`, for the agent. Routed from `INDEX.md`. Recheck its links when you refresh the references, and keep it free of Community Access paths.

## Provenance

Provenance for every reference file lives in `PROVENANCE.md`, not in the files themselves. Each file has a one-line pointer to `PROVENANCE.md` and `LICENSE-community-access.md`, so the agent's reading stays lean. `PROVENANCE.md` has one section per file with:

- **Upstream commit:** the full commit at head of upstream `main` when the material was retrieved.
- **Retrieved:** the retrieval date.
- **Upstream files:** each upstream path used, as a backticked path on a `  - ` line.
- **Adapted:** what was changed and what was removed.

The upstream repository and the license are stated once at the top of `PROVENANCE.md`. The license text is in `LICENSE-community-access.md`. The drift check reads `PROVENANCE.md`, so keep its format.

## Refreshing

Run `tests/local/check-a11y-reference-drift.sh <path to an upstream clone>`. It lists the upstream files that changed since each file's pinned commit. For each change, a person reads the upstream diff, edits the adaptation if the change matters, then updates that file's commit and retrieval date in `PROVENANCE.md`. The script reports and does not edit.

Two upstream sources are noisy. `mcp-server/server-core.js` changes often for reasons unrelated to the `GUIDELINES` constant, so check only that constant. Upstream summary text can also disagree with its own reference files (for example, which element gets focus when a dialog opens). When they disagree, `dialogs.md` follows the detailed reference file.

When you add or remove a reference file, update the routing table in `INDEX.md` and add or remove its section in `PROVENANCE.md`. New adapted files also get the pointer line under the title.
