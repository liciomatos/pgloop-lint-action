# pgloop-lint-action

GitHub Action that runs [`pgloop lint`](https://github.com/liciomatos/pgloop) on your SQL migration files and posts inline annotations directly in the PR diff.

```yaml
- uses: liciomatos/pgloop-lint-action@v1
  with:
    paths: migrations/
```

> No Go, no Docker, no database connection required.

---

## Quick start

```yaml
name: Lint migrations

on:
  pull_request:
    paths:
      - 'migrations/**'

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: liciomatos/pgloop-lint-action@v1
        with:
          paths: migrations/
```

---

## Inputs

| Input | Default | Description |
|---|---|---|
| `paths` | `migrations/` | SQL files or directories to lint (space-separated) |
| `version` | `latest` | pgloop version to use (e.g. `v0.1.1`). Defaults to the latest release. |
| `fail-on` | `CRITICAL` | Minimum severity to fail the step: `CRITICAL` or `WARN` |
| `ignore` | `''` | Comma-separated policy codes to suppress (e.g. `P9,P10`) |
| `pg-version` | `0` | Target PostgreSQL major version (e.g. `14`, `15`, `16`) |

---

## Outputs

| Output | Description |
|---|---|
| `exit-code` | pgloop exit code: `0` = clean, `1` = warnings only, `2` = critical issues |
| `critical` | Total CRITICAL issues found across all files |
| `warn` | Total WARN issues found across all files |

---

## Common examples

### Fail on any issue (warnings included)

```yaml
- uses: liciomatos/pgloop-lint-action@v1
  with:
    paths: migrations/
    fail-on: WARN
```

### Suppress P9 (your deploy tool already injects timeouts)

```yaml
- uses: liciomatos/pgloop-lint-action@v1
  with:
    paths: migrations/
    ignore: P9
```

### Target a specific PostgreSQL version

```yaml
- uses: liciomatos/pgloop-lint-action@v1
  with:
    paths: migrations/
    pg-version: '15'
```

### Multiple directories

```yaml
- uses: liciomatos/pgloop-lint-action@v1
  with:
    paths: services/users/migrations services/orders/migrations
```

### Read outputs and decide later

```yaml
- id: lint
  uses: liciomatos/pgloop-lint-action@v1
  continue-on-error: true
  with:
    paths: migrations/

- name: Post summary
  run: |
    echo "Critical: ${{ steps.lint.outputs.critical }}"
    echo "Warnings: ${{ steps.lint.outputs.warn }}"
    echo "Exit code: ${{ steps.lint.outputs.exit-code }}"
```

### Pin to an exact version

```yaml
- uses: liciomatos/pgloop-lint-action@v1.0.0
```

---

## How annotations work

When issues are found, pgloop emits [GitHub workflow commands](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions) that GitHub renders as inline annotations in the PR diff:

```
::error file=migrations/add_index.sql,line=3::[pgloop P2] CREATE INDEX without CONCURRENTLY acquires a lock that blocks writes
::warning file=migrations/add_index.sql,line=3::[pgloop P9] No lock_timeout or statement_timeout set
```

Annotations appear on the Files Changed tab of every PR, next to the exact line that triggered the issue.

---

## Platforms supported

| OS | amd64 | arm64 |
|---|---|---|
| Linux | ✅ | ✅ |
| macOS | ✅ | ✅ |
| Windows | ❌ | ❌ |

Windows is not supported because pgloop uses CGO (libpg_query) at build time. Linux and macOS self-hosted runners work fine.

---

## Permissions

This action only reads files from your repository. No special permissions are required beyond the default `contents: read`.

```yaml
permissions:
  contents: read
```

---

## Version pinning

| Reference | Meaning |
|---|---|
| `@v1` | Latest v1.x.x — receives bug fixes automatically |
| `@v1.0.0` | Exact release — fully reproducible |
| `@main` | Development tip — not recommended for production |

Use `@v1` for most workflows. Pin to an exact version if you need maximum reproducibility.

---

## FAQ

**Why does the action run pgloop twice?**

The first run uses `--format github` to emit inline PR annotations. The second uses `--format json` to calculate the `critical` and `warn` output counts. Both are fast reads of your SQL files — no database connection is made.

**Why does exit-code=1 not fail the action by default?**

Exit code `1` means warnings only — no blocking issues. The action only fails (non-zero exit) when there are CRITICAL issues (exit code `2`) or when you set `fail-on: WARN`. This matches pgloop's own exit code contract.

**Do I need to install Go or pgloop separately?**

No. The action downloads the prebuilt pgloop binary for your runner's platform from the GitHub release. Nothing else is needed.

---

## License

MIT — see [pgloop](https://github.com/liciomatos/pgloop) for policy details.
