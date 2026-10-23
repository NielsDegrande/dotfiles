# AGENTS.md

## Communication

- When replying to me, use simple language that a human can easily understand.
- Favor tables and visual approaches (e.g., ASCII diagrams) to make concepts clear.

## Scope

A feature or fix request does not authorize framework changes, shared infrastructure changes, or new plumbing across UI, SDK, backend, or schemas. Unless I explicitly requested that broader work, stop before implementing it, explain the scope and a smaller alternative, and get my approval. This applies even when the broader changes seem necessary to fulfill my request. If scope grows during implementation, stop and ask again before continuing.

## Git and GitHub

- Use `niels` as the branch name prefix (not the full GitHub username).
- When you address PR comments, after pushing:
  - If it is a bot (bugbot, Claude, cursor, depthfirst, etc.), reply with a comment and resolve the thread.
  - If it is a human, do NOT comment or resolve the thread.
- When you are reviewing a PR, NEVER comment on the PR.
- The claude[bot] review runs automatically when a PR is created. After that, decide yourself when to re-run it (one-off `@claude review`) to get the PR green and merge-ready, e.g. after fixing its findings or making significant changes. No need to ask me. Don't post `@claude review always`.
- When writing PR descriptions, do not mention "testing in staging".
- Keep PR bodies simple, short and human readable. Include examples and evidence (e.g., data) where possible.
- When making significant changes to a PR, update the PR description to reflect the current state.

## Quality control

Before committing, ensure linting and relevant tests are passing.
You can use [agent-browser](https://github.com/vercel-labs/agent-browser) to test in the browser.

Once you have created the PR, proactively monitor for both CI/CD check failures and review comments.
Fix CI failures and address review comments that are relevant without waiting to be asked.

## Browser

- When I need to log in or type in a browser you drive, use `agent-browser --headed`. Don't use Google Chrome.
- The full-page screenshot flag is `--full`, NEVER `--full-page`. agent-browser treats unrecognized tokens as the output path, so a wrong flag silently creates junk files (e.g. a file named `--full-page`) in the cwd.

## Code comments and tests

- No AI slop comments, no AI slop tests.
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
- In the lovable repo, build, vet and test Go with `rgo` (remote, on CI workers), never local `go test`/`go build`/`go vet`/`test-api`: local builds overload my laptop. E.g. `rgo test ./go/api/pkg/agent/...`, `rgo test TestName -count=1`, `rgo vet ./go/api/pkg/x/...`. Only fall back to local `go` if `rgo` fails for infra reasons, and tell me.

### Python

- Always use `uv` to create a virtual environment and install dependencies.
- Docstrings are in reStructuredText format.
- Type hints required for all code except tests.

### TypeScript

- Write TSDoc comments for all public classes, methods, and functions. At least use the `@param` tag for parameters and `@returns` for return values.
