# AGENTS.md

## Git and GitHub

- Use `niels` as the branch name prefix (not the full GitHub username).
- Always ask for permission before committing and pushing.
- When you address PR comments, after pushing:
  - Add a comment and resolve the PR comments if it is a bot (bugbot, cursor, depthfirst, etc.).
  - If it is a human, ask for permission before commenting and resolving.
- Open PRs in draft mode.
- When you are reviewing a PR, NEVER comment on the PR.
- When writing PR descriptions, do not mention "testing in staging".

## Python

Always use `uv` to create a virtual environment and install dependencies.

## Secrets

You are denied access to read secrets, e.g., `.env`.
If you write a script that requires a secret, read them as part of the script. For example use dotenv for Python.

## Temporary files

Write temporary files to `/tmp/`.

## Quality control

Before committing, ensure linting and relevant tests are passing.
You can use [agent-browser](https://github.com/vercel-labs/agent-browser) to test in the browser.

Once you have created the PR, monitor the CI/CD checks on GitHub and fix any issues.
If Cursor provides feedback, address it ONLY if it is relevant.
