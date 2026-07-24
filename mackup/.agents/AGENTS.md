# AGENTS.md

## Git and GitHub

- Use `niels` as the branch name prefix (not the full GitHub username).
- Always ask for permission before committing and pushing.
- When you address PR comments, after pushing:
  - If it is a bot (bugbot, Claude, cursor, depthfirst, etc.), reply with a comment and resolve the thread.
  - If it is a human, do NOT comment or resolve the thread.
- When you are reviewing a PR, NEVER comment on the PR.
- NEVER post `@claude review always` on a PR. When a claude[bot] review is needed, post `@claude review once` instead (no push subscription).
- When writing PR descriptions, do not mention "testing in staging".
- When making significant changes to a PR, update the PR description to reflect the current state.

## Quality control

Before committing, ensure linting and relevant tests are passing.
You can use [agent-browser](https://github.com/vercel-labs/agent-browser) to test in the browser.

Once you have created the PR, proactively monitor for both CI/CD check failures and review comments.
Fix CI failures and address review comments that are relevant without waiting to be asked.

## Browser

- When I explicitly ask for interactive browser work, launch [agent-browser](https://github.com/vercel-labs/agent-browser) in headed mode (`agent-browser --headed open <url>`) so I can log in and handle any auth myself in the window, then keep driving the same session. Alternatively, attach with `--auto-connect` to a browser I started with `--remote-debugging-port=9222`. The browser is ephemeral (no persistent profile), so logins last only for that session.

## Code comments

- Keep comments short; avoid extremely lengthy comments.
- Do not document process or history in comments (e.g., "bug X happened on day Y, so I fixed it here"). Describe the why and what of the code, and only when it adds value beyond the code itself.

## Secrets

You are denied access to read secrets, e.g., `.env`.
If you write a script that requires a secret, read them as part of the script. For example use dotenv for Python.

## Temporary files

Write temporary files to `/tmp/`.
Files that might be useful to keep, for example datasets, plots or interim results, write to `.scratch` in the worktree.

## Languages

### Go

- Mark all tests `t.Parallel()` unless they can't run in parallel.
- CI runs `go fix -diff` and will fail on non-modernized code. Before committing, run `cd go/api && go fix ./...` (and any other affected module) to apply modernizations.

### Python

- Always use `uv` to create a virtual environment and install dependencies.
- Docstrings are in reStructuredText format.
- Type hints required for all code except tests.

### TypeScript

- Write TSDoc comments for all public classes, methods, and functions. At least use the `@param` tag for parameters and `@returns` for return values.
