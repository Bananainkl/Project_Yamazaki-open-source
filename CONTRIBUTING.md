# Development Workflow

Use `main` as the stable branch. Preserve existing releases and do not commit build products, credentials, or local permission state.

## Local verification

```bash
swift build
./script/build_and_run.sh --install
```

Use the installed `/Applications/Yamazaki.app` for Screen Recording permission checks.

## Submit a change

Create a topic branch and open a pull request:

```bash
git switch -c feature/short-description
git commit -m "Describe the change"
git push -u origin feature/short-description
```

Review the staged diff before committing. Do not add third-party application bundles to this repository or to release packages without explicit redistribution permission.
