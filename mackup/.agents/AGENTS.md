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
- In the lovable repo, merge only when I asked, through the merge queue: `./tools/pr/index.mjs enqueue --pr <n>` from the PR's worktree (local head = PR head). Never `gh pr merge`: it needs my click. On `predicate-false`, run `./tools/pr/index.mjs merge-gate --pr <n> --agent NielsDegrande` to see the blocker (often an unacked bot review body or gates still running).

## Quality control

Before committing, ensure linting and relevant tests are passing.
You can use [agent-browser](https://github.com/vercel-labs/agent-browser) to test in the browser.

Offload heavy work (builds, lints, test suites, data jobs) to remote machines whenever the repo offers a way. I often run many worktrees and agents in parallel, so local heavy jobs pile up and overload my laptop. Run something heavy locally only when no remote option exists, and keep it scoped to what you changed.

Before opening a PR for a sizeable piece of work, review it yourself and fix what is needed. This catches issues early and avoids rounds of bot comments on the PR.

| Repo | Self-review before the PR | Reviewing someone else's PR |
|---|---|---|
| lovable | `/lov-review`, the repo's own reviewer (add `--preset standard` for large or risky changes) | `/pr-review <pr>` |
| Any other repo | `/pr-review --self` | `/pr-review <pr>` |

Still share the findings table with me, plus the fixes you made. After major follow-up changes, consider running it again. For trivial changes, skip it or do a light review instead (e.g. `/code-review low`).

Once you have created the PR, proactively monitor for both CI/CD check failures and review comments.
Fix CI failures and address review comments that are relevant without waiting to be asked.

## Slack

When I ask you to "draft a Slack message", save it as a draft in Slack. Do NOT send it: I will review, edit and send it myself. Only send directly when I explicitly tell you to send without my review.

Before you claim anything about Slack (a draft was or wasn't sent, an incident is open or closed, someone replied or not), read the channel or thread first. Never state it from memory, notes or an earlier summary.

## Browser

- When I need to log in or type in a browser you drive, or want to take over the browser later, use `agent-browser --headed`.
- agent-browser runs regular Google Chrome (set in `~/.agent-browser/config.json`), never with my personal Chrome profile. Don't install Chrome for Testing.
- Profiles:

  | Profile | Use for | Flags |
  |---|---|---|
  | Private | Personal tasks: travel, shopping, etc. | `--session private --profile ~/.agent-browser/profiles/private` |
  | Work | Work sites: Lovable dev UI, internal tools, etc. | `--session work --profile ~/.agent-browser/profiles/work` |
  | Empty (default) | Throwaway work: testing, scraping, screenshots | none |

  - Use Private or Work only when I name it. If a saved login would clearly save us auth back and forth, ask me first.
  - A profile can only be open in one browser at a time. Reuse its `--session` instead of launching a second browser on it.
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

## Deleting files

Delete with `trash <path>`, not `rm`: it can be undone, so auto mode allows it. Where `trash` doesn't exist (e.g. a Lovbox), `rm` is fine for paths you created.

## Languages

### Go

- Mark all tests `t.Parallel()` unless they can't run in parallel.
- In the lovable repo, build, vet, lint and test Go with `rgo`, which runs on CI's remote workers. Never run local `go test`/`go build`/`go vet`/`test-api`/`lint-go`: on a Mac they compile locally and overload my laptop.
  - `rgo test ./go/api/pkg/x/...` runs tests; `rgo test TestName -count=1` runs named tests.
  - `rgo compile <packages>` compiles, test files included.
  - `rgo vet <packages>` runs CI's analyzers (nogo: linters, vet, modernize). It replaces `lint-go`; the whole tree is `rgo vet //go/... //mcp/...`.
  - Run it on the packages you changed: unchanged tests come back as cache hits. It runs gazelle first, so BUILD.bazel files stay current.
  - Only one `rgo` runs per worktree; a second one waits. Long failure logs are summarized, and the full log path is printed.
- A modernize finding (from `rgo vet` or CI) is fixed by `go fix` in the module directory, scoped to the changed packages: `cd go/api && go fix ./pkg/x/...`. This is the one local Go command that's fine.
- `rgo` logs in to Buildbarn with my gcloud account. If it says "Buildbarn needs a Google login", ask me to run `! gcloud auth login` (@lovable.dev, Tailscale on). On a Lovbox, I run `lovbox grant <box>` from my laptop.
- If `rgo` fails for other infra reasons, fall back to local and tell me. Subagents never fall back: they report the failure.

### Python

- Always use `uv` to create a virtual environment and install dependencies.
- Docstrings are in reStructuredText format.
- Type hints required for all code except tests.

### TypeScript

- Write TSDoc comments for all public classes, methods, and functions. At least use the `@param` tag for parameters and `@returns` for return values.
