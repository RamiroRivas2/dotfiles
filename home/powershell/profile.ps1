# dotfiles PowerShell profile
# Windows translation of the zsh setup in kunchenguid/dotfiles (home.nix).
# This is the real file - $PROFILE just dot-sources it, so edit HERE and
# open a new terminal to see changes. No rebuild needed.

# default editor (home.nix: home.sessionVariables.EDITOR = "nvim")
$env:EDITOR = 'nvim'

if (Get-Module PSReadLine) {
    # ghost-text suggestions from history (zsh autosuggestion.enable)
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle InlineView
    # Ctrl+F accepts the suggestion (bindkey '^f' autosuggest-accept)
    Set-PSReadLineKeyHandler -Key Ctrl+f -Function AcceptSuggestion
    # valid commands turn green as you type (zsh syntaxHighlighting.enable)
    Set-PSReadLineOption -Colors @{ Command = 'Green' }
}

# aliases (home.nix shellAliases)
function .. { Set-Location .. }
function add { git add . }
function push { git push }
function pull { git pull }
function m { git switch main }

# high-agency shortcuts straight from the video.
# know what these do before you lean on them:
# cc = Claude Code with ALL permission prompts skipped
# co = Codex in full-auto mode
function cc { claude --dangerously-skip-permissions @args }
function co { codex --full-auto @args }

# starship prompt (programs.starship in home.nix; config lives in home\starship.toml)
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
