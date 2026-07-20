# Codex release contract

For every task that changes shipped behavior, Codex must complete the release workflow before reporting the task finished:

1. Bump the semantic version in `VERSION`.
2. Add user-facing notes to `CHANGELOG.md` and replace `RELEASE_NOTES.md` with the notes for that version.
3. Run `swift build`, credential/path scanning, and the permission/package verification appropriate to the change.
4. Build and verify the DMG with `script/package_dmg.sh`. Snipaste and other third-party application bundles must not be included.
5. Commit all reviewed source and documentation changes. The local post-commit hook pushes the commit to GitHub automatically.
6. Create and push an annotated `v<VERSION>` tag. `.github/workflows/release.yml` then creates the public GitHub Release from `RELEASE_NOTES.md`.
7. Verify the remote commit, public Release page, version, notes, and source archives. Attach only a locally validated package.

Do not publish a release if tests, secret scanning, licensing checks, or packaging verification fail. Never commit local permission state, credentials, user paths, audit captures, or third-party application bundles.
