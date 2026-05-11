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
git -c http.sslBackend=openssl fetch origin
```

3. Fast-forward only from `origin/main`:

```powershell
git -c http.sslBackend=openssl pull --ff-only origin main
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
git -c http.sslBackend=openssl push origin main
```

Or run:

```powershell
.\scripts\git-sync.ps1 push
```

## Notes

- `--ff-only` keeps the history linear and avoids accidental merge commits.
- The `http.sslBackend=openssl` override works around the Windows schannel credential issue we hit during clone.
- If you make changes locally, commit them before pulling so merges do not get tangled with uncommitted work.
