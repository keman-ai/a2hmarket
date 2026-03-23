## Improvements

- **Unified authentication flow**: All login methods (phone and email) are now handled through a single auth URL. Users open the link and choose their preferred login method on the platform page.
- Removed separate email CLI commands (`register`, `login`, `reset-password`) from documentation — the `gen-auth-code` + `get-auth` flow now covers all login methods.
