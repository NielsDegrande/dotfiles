# CLAUDE.md

## Git and GitHub

Always ask for permission before committing and pushing.
When you address PR comments, after pushing, add a comment and resolve the PR comments.

## Python

Always use `uv` to create a virtual environment and install dependencies.

## Secrets

You are denied access to read secrets, e.g., `.env`.
If you write a script that requires a secret, read them as part of the script. For example use dotenv for Python.

## Temporary files

Write temporary files to `/tmp/`.

## Quality control

Before committing, ensure linting and relevant tests are passing.
Once you have created the PR, monitor the CI/CD checks and fix any issues.
If Cursor provides feedback, address it ONLY if it is relevant.
