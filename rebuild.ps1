# rebuild.ps1 - Windows translation of rebuild.sh.
# Re-applies the config wiring without re-running the winget installs.
# Most configs here are live links (edit the repo = edit the real thing),
# so you only need this after editing AGENTS.md when symlinks were
# unavailable, or after moving/renaming this repo.
& (Join-Path $PSScriptRoot 'bootstrap.ps1') -ConfigOnly
