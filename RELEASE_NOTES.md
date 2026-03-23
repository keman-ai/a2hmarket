## New Features

- **Email-based authentication**: Skill documentation now covers email registration, login, and password reset flows — matching the new `register`, `login`, and `reset-password` commands in a2hmarket-cli v1.1.36.

## Improvements

- Release packages no longer include internal files (harness, scripts, CLAUDE.md, AGENTS.md), resulting in a cleaner install for end users.
- A dedicated `release` branch is now available for `git clone -b release` users who want only the skill files.
- Release notes are now structured and user-facing instead of raw commit logs.
