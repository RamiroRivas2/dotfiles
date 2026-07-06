# bootstrap.ps1 - Windows translation of bootstrap.sh + the whole Nix build.
#
# What it does, in order (same jobs nix-darwin/home-manager did on the Mac):
#   1. Installs the CLI tools with winget      (home.nix home.packages)
#   2. Installs Hack Nerd Font, per-user       (home.nix nerd-fonts.hack)
#   3. Wires every config file into place       (home.nix mkOutOfStoreSymlink)
#
# Safe to run again any time - it skips what's already done and backs up
# anything it would replace. Run with -ConfigOnly to skip the installs
# (that's all rebuild.ps1 does).
#
# Usage:  pwsh -File .\bootstrap.ps1

param([switch]$ConfigOnly)

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

function Step($msg) { Write-Host "`n== $msg" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "   $msg" -ForegroundColor Green }
function Note($msg) { Write-Host "   $msg" -ForegroundColor Yellow }

# ---------------------------------------------------------------- 1. tools
if (-not $ConfigOnly) {
    Step 'CLI tools (winget)'
    $tools = @(
        @{ cmd = 'rg';       id = 'BurntSushi.ripgrep.MSVC' }  # fast search
        @{ cmd = 'fd';       id = 'sharkdp.fd' }               # fast find
        @{ cmd = 'fzf';      id = 'junegunn.fzf' }             # fuzzy finder
        @{ cmd = 'jq';       id = 'jqlang.jq' }                # json on the command line
        @{ cmd = 'lazygit';  id = 'JesseDuffield.lazygit' }
        @{ cmd = 'nvim';     id = 'Neovim.Neovim' }
        @{ cmd = 'starship'; id = 'Starship.Starship' }        # prompt
        @{ cmd = 'wezterm';  id = 'wez.wezterm' }              # terminal
    )
    foreach ($t in $tools) {
        if (Get-Command $t.cmd -ErrorAction SilentlyContinue) {
            Ok "$($t.cmd) already installed"
        } else {
            Note "installing $($t.id)..."
            winget install --id $t.id -e --source winget `
                --accept-source-agreements --accept-package-agreements `
                --disable-interactivity | Out-Null
            if ($LASTEXITCODE -eq 0) { Ok "$($t.cmd) installed" }
            else { Note "$($t.id) failed (exit $LASTEXITCODE) - install it manually later" }
        }
    }

    # ---------------------------------------------------------- 2. the font
    Step 'Hack Nerd Font (per-user, no admin needed)'
    $userFonts = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
    if (Test-Path (Join-Path $userFonts 'HackNerdFont-Regular.ttf')) {
        Ok 'already installed'
    } else {
        $zip = Join-Path $env:TEMP 'HackNerdFont.zip'
        $dir = Join-Path $env:TEMP 'HackNerdFont'
        Note 'downloading from github.com/ryanoasis/nerd-fonts...'
        Invoke-WebRequest 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip' -OutFile $zip
        Expand-Archive $zip $dir -Force
        New-Item -ItemType Directory -Force $userFonts | Out-Null
        $reg = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
        if (-not (Test-Path $reg)) { New-Item -Path $reg -Force | Out-Null }
        foreach ($f in Get-ChildItem $dir -Filter '*.ttf') {
            $dest = Join-Path $userFonts $f.Name
            Copy-Item $f.FullName $dest -Force
            New-ItemProperty -Path $reg -Name "$($f.BaseName) (TrueType)" `
                -Value $dest -PropertyType String -Force | Out-Null
        }
        Remove-Item $zip, $dir -Recurse -Force -Confirm:$false
        Ok 'installed (restart apps to see it)'
    }
}

# --------------------------------------------------------------- 3. configs
# On the Mac, home-manager symlinks configs out of the repo so editing the
# repo edits the live config. Same idea here, per-tool, using whatever
# mechanism Windows allows without admin rights.

Step 'PowerShell profile (the zsh translation)'
# dot-source instead of symlink: $PROFILE stays a one-liner pointing here
$profilePath = $PROFILE.CurrentUserAllHosts   # Documents\PowerShell\profile.ps1
$sourceLine = ". `"$repo\home\powershell\profile.ps1`""
New-Item -ItemType Directory -Force (Split-Path $profilePath) | Out-Null
if (-not (Test-Path $profilePath)) {
    Set-Content $profilePath $sourceLine
    Ok "created $profilePath"
} elseif (-not (Select-String -Path $profilePath -SimpleMatch 'home\powershell\profile.ps1' -Quiet)) {
    Add-Content $profilePath "`n$sourceLine"
    Ok "added dot-source line to existing $profilePath"
} else {
    Ok 'already wired up'
}

Step 'WezTerm'
# WEZTERM_CONFIG_FILE beats symlinks: WezTerm reads the repo file directly
[Environment]::SetEnvironmentVariable('WEZTERM_CONFIG_FILE', "$repo\home\wezterm\wezterm.lua", 'User')
$env:WEZTERM_CONFIG_FILE = "$repo\home\wezterm\wezterm.lua"
$oldWez = Join-Path $HOME '.wezterm.lua'
if (Test-Path $oldWez) {
    Rename-Item $oldWez "$oldWez.backup-$stamp"
    Note "your old ~/.wezterm.lua was backed up to .wezterm.lua.backup-$stamp"
}
Ok 'WEZTERM_CONFIG_FILE -> repo (restart WezTerm to pick it up)'

Step 'starship'
[Environment]::SetEnvironmentVariable('STARSHIP_CONFIG', "$repo\home\starship.toml", 'User')
$env:STARSHIP_CONFIG = "$repo\home\starship.toml"
Ok 'STARSHIP_CONFIG -> repo'

Step 'Neovim'
# a junction is a directory link that needs no admin rights
$nvimLink = Join-Path $env:LOCALAPPDATA 'nvim'
$nvimSrc  = Join-Path $repo 'home\nvim'
$existing = Get-Item $nvimLink -Force -ErrorAction SilentlyContinue
if ($existing -and -not $existing.LinkType) {
    Rename-Item $nvimLink "$nvimLink.backup-$stamp"
    Note "your old nvim config was backed up to nvim.backup-$stamp"
    $existing = $null
}
if ($existing -and $existing.LinkType) {
    Ok 'junction already in place'
} else {
    New-Item -ItemType Junction -Path $nvimLink -Target $nvimSrc | Out-Null
    Ok "junction $nvimLink -> repo"
}

Step 'Claude Code settings (theme + status line)'
# merge into ~/.claude/settings.json instead of replacing it, so existing
# settings (plugins etc.) survive
$claudeDir = Join-Path $HOME '.claude'
New-Item -ItemType Directory -Force $claudeDir | Out-Null
$settingsPath = Join-Path $claudeDir 'settings.json'
$settings = @{}
if (Test-Path $settingsPath) {
    Copy-Item $settingsPath "$settingsPath.backup-$stamp"
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json -AsHashtable
}
$settings['theme'] = 'dark-ansi'
$settings['statusLine'] = @{
    type    = 'command'
    command = "pwsh -NoProfile -ExecutionPolicy Bypass -File `"$repo\home\claude\statusline.ps1`""
}
$settings | ConvertTo-Json -Depth 20 | Set-Content $settingsPath -Encoding utf8
Ok "merged into $settingsPath (backup saved)"

Step 'shared AGENTS.md (Claude / Codex / opencode)'
$agentsSrc = Join-Path $repo 'home\AGENTS.md'
$agentsTargets = @(
    (Join-Path $HOME '.claude\CLAUDE.md'),
    (Join-Path $HOME '.codex\AGENTS.md'),
    (Join-Path $HOME '.config\opencode\AGENTS.md')
)
$copyMode = $false
foreach ($t in $agentsTargets) {
    New-Item -ItemType Directory -Force (Split-Path $t) | Out-Null
    $item = Get-Item $t -Force -ErrorAction SilentlyContinue
    if ($item -and -not $item.LinkType) {
        Rename-Item $t "$t.backup-$stamp"
        Note "existing $(Split-Path $t -Leaf) backed up"
    }
    try {
        New-Item -ItemType SymbolicLink -Path $t -Target $agentsSrc -Force | Out-Null
        Ok "linked $t"
    } catch {
        Copy-Item $agentsSrc $t -Force
        $copyMode = $true
        Ok "copied $t"
    }
}
if ($copyMode) {
    Note 'symlinks need Windows Developer Mode (Settings > System > For developers).'
    Note 'Files were COPIED instead - run rebuild.ps1 after editing home\AGENTS.md.'
}

Write-Host "`nDone. Open a NEW terminal so PATH and the profile load fresh." -ForegroundColor Cyan
Write-Host 'Optional: pwsh -File .\windows-settings.ps1  (dark mode, key repeat, etc.)' -ForegroundColor DarkGray
