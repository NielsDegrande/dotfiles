---
description: Open a PR and get it merge-ready, including CI and Claude review
argument-hint: "[PR URL or task context]"
---
Open or update a PR for the current changes. Keep working until CI is green and bot feedback is validated, addressed, and resolved. The Claude review runs automatically on PR creation; address its findings, re-run it with `@claude review` when needed to get it green, and recheck CI. Leave the PR merge-ready but unmerged; report any blockers.

Additional context: $@
