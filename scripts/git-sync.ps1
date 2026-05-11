param(
    [ValidateSet("status", "pull", "push")]
    [string]$Mode = "status"
)

$gitArgs = @("-c", "http.sslBackend=openssl")

switch ($Mode) {
    "status" {
        & git @gitArgs status --short
        exit $LASTEXITCODE
    }
    "pull" {
        & git @gitArgs fetch origin
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

        & git @gitArgs pull --ff-only origin main
        exit $LASTEXITCODE
    }
    "push" {
        & git @gitArgs push origin main
        exit $LASTEXITCODE
    }
}
