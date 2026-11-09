# Accessibility Reference Files

For maintainers. The research accessibility agent starts at `INDEX.md`, which holds the routing table. This file covers provenance and refreshing.

Each file in this folder is an adaptation of Community Access `accessibility-agents` material (MIT), reshaped for research: where to look in a codebase, requirements, common failures, and acceptance-criteria wording tagged `[auto]` or `[manual]`.

## Provenance

Every file except `INDEX.md` and this one starts with a source block with these lines, in this order:

- **Source repo:** the upstream repository.
- **Upstream commit:** the full commit at head of upstream `main` when the material was retrieved.
- **Retrieved:** the retrieval date.
- **License:** the upstream license and copyright holder.
- **Upstream files:** each upstream path used, as a backticked path on a `> - ` line.
- **Adapted:** what was changed and what was removed.

All files here were retrieved on 2026-11-09 from commit `a538edc9edfb98cdd8bae96d6b79542874b478f7`. The drift check reads these lines, so keep the format.

## Refreshing

Run `tests/local/check-a11y-reference-drift.sh <path to an upstream clone>`. It lists the upstream files that changed since each file's pinned commit. For each change, a person reads the upstream diff, edits the adaptation if the change matters, then updates that file's commit and retrieval date. The script reports and does not edit.

Two upstream sources are noisy. `mcp-server/server-core.js` changes often for reasons unrelated to the `GUIDELINES` constant, so check only that constant. Upstream summary text can also disagree with its own reference files (for example, which element gets focus when a dialog opens). When they disagree, `dialogs.md` follows the detailed reference file.

When you add or remove a reference file, update the routing table in `INDEX.md`.
