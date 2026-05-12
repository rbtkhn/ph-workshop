# Git Workflow

Use this repo with a simple fast-forward-first workflow:

For convenience, the repo includes `scripts/git-sync.ps1` with the same operations.

## Pull

1. Check status:

```powershell
git status --short
```

2. Fetch the remote:

```powershell
git fetch origin
```

3. Fast-forward only from `origin/main`:

```powershell
git pull --ff-only origin main
```

Or run:

```powershell
.\scripts\git-sync.ps1 pull
```

## Push

1. Confirm the working tree is clean:

```powershell
git status --short
```

2. Push the current `main` branch:

```powershell
git push origin main
```

Or run:

```powershell
.\scripts\git-sync.ps1 push
```

This checkout is configured to use the SSH key at `C:/Users/rober/.ssh/id_ed25519_codex_predictive_history`, so pushes should work without a token once the key is added to GitHub.

## Notes

- `--ff-only` keeps the history linear and avoids accidental merge commits.
- This checkout now uses SSH for GitHub pushes; the older HTTPS/openssl workaround is only useful as fallback context if you clone the repo somewhere else.
- If you make changes locally, commit them before pulling so merges do not get tangled with uncommitted work.
