# dotfiles (Windows)

My Windows translation of [kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles)
from the video [My whole Mac setup in one repo](https://youtu.be/5N-okeDdIuI).

His repo uses Nix + nix-darwin + home-manager, none of which exist on
Windows. This repo does the same jobs with what Windows ships with:
**winget** for packages and **PowerShell** for the glue.

This is the **Windows half**. The **Linux half** - my WSL Ubuntu, managed
with real Nix + home-manager like the video - lives in
[RamiroRivas2/dotfiles-wsl](https://github.com/RamiroRivas2/dotfiles-wsl).

## What you get

Running `bootstrap.ps1` builds:

- CLI tools via winget (ripgrep, fd, fzf, jq, lazygit, Neovim, starship, WezTerm)
- Hack Nerd Font, installed per-user (no admin needed)
- Shell: PowerShell 7 profile with his zsh aliases, ghost-text history
  suggestions (Ctrl+F to accept), green-when-valid commands, starship prompt
- Editor: his exact Neovim config (lazy.nvim, oil, snacks picker, neogit)
- Terminal: his WezTerm look (rose-pine-moon, Hack Nerd Font, blur) adapted
  to Windows (Acrylic backdrop, starts in PowerShell 7)
- Agent configs: Claude Code theme + status line, and one shared `AGENTS.md`
  for Claude, Codex, and opencode

## Mac -> Windows map

| His Mac piece | This repo's version |
|---|---|
| Nix / nix-darwin / home-manager | `bootstrap.ps1` + winget |
| `bootstrap.sh` | `bootstrap.ps1` |
| `rebuild.sh` | `rebuild.ps1` |
| zsh + autosuggestions + syntax highlighting | PowerShell 7 + PSReadLine (built in) |
| `~/.zshrc` (generated) | `home\powershell\profile.ps1`, dot-sourced from `$PROFILE` |
| starship (Nix) | starship (winget), config via `STARSHIP_CONFIG` env var |
| WezTerm cask + `~/.config/wezterm` symlink | WezTerm (winget) + `WEZTERM_CONFIG_FILE` env var |
| macOS window blur | `win32_system_backdrop = "Acrylic"` |
| `~/.config/nvim` symlink | junction at `%LOCALAPPDATA%\nvim` (no admin needed) |
| Hack Nerd Font (Nix) | downloaded from nerd-fonts GitHub releases |
| `system.defaults` (dark mode, key repeat, dock...) | `windows-settings.ps1` (optional, run separately) |
| `herdr` (terminal multiplexer) | skipped - not on Windows; WezTerm panes cover it |

## Fresh-machine setup

From PowerShell 7 (`pwsh`):

```powershell
git clone https://github.com/RamiroRivas2/dotfiles.git
cd dotfiles
pwsh -File .\bootstrap.ps1
```

Then **open a new terminal** so PATH and the profile load fresh.
Optionally run `pwsh -File .\windows-settings.ps1` for the system tweaks
(dark mode, fast key repeat, auto-hide taskbar - read it first).

`bootstrap.ps1` is safe to re-run: it skips what's installed and backs up
(never deletes) anything it replaces, with a `.backup-<timestamp>` suffix.

## Daily use

Almost everything is a live link - edit the file in this repo and the real
config changes with it:

- `home\powershell\profile.ps1` - shell aliases and prompt (new terminal to see it)
- `home\wezterm\wezterm.lua` - WezTerm reloads automatically
- `home\starship.toml` - prompt look
- `home\nvim\` - Neovim config
- `home\claude\statusline.ps1` - Claude Code status line

Only `AGENTS.md` may be a copy instead of a link (if Windows Developer Mode
is off) - after editing it, run:

```powershell
pwsh -File .\rebuild.ps1
```

## Make it yours

- **Aliases**: `home\powershell\profile.ps1`. Heads-up, same as his README:
  `cc` runs `claude --dangerously-skip-permissions` and `co` runs
  `codex --full-auto`. Convenient, but know what they do.
- **Agent policy**: `home\AGENTS.md` started as a copy of kunchen's personal
  rules and is shared by Claude Code, Codex, and opencode. Edit it to match
  how YOU want agents to behave.
- **Font/theme**: `home\wezterm\wezterm.lua` and `home\starship.toml`.
- **Git identity**: not managed here (already set globally via `git config`).

## Workflow tools (from the video description)

The layer on top of the configs - installed by `bootstrap.ps1` where possible:

| His tool | Here | Notes |
|---|---|---|
| skills CLI | `npx skills ...` on demand | no install needed; use `--copy` on Windows |
| gh-axi (AXI) | npm global, both sides | agent-friendly GitHub CLI; needs `gh auth login` once |
| lavish | Claude Code skill, both sides | agent writes HTML artifacts you annotate in the browser |
| no-mistakes | native install, both sides | `no-mistakes init` per repo, then `git push no-mistakes` |
| gnhf | npm global, both sides | overnight agent loops; run on a branch until you trust it |
| treehouse | WSL only | worktree pool for parallel agents; firstmate needs it |
| firstmate | cloned to WSL `~/github/firstmate` | multi-agent crew in tmux; start with `claude` inside it |
| OpenSuperWhisper | skipped - macOS-only | use Win+H voice typing, or install [Handy](https://github.com/cjpais/Handy) |

## Notes

- First `nvim` launch clones lazy.nvim and all plugins from GitHub - needs
  network once, then it's offline. Ignore the flash of messages; restart
  nvim after it finishes.
- The old `~\.wezterm.lua` (WSL Ubuntu + Tokyo Night setup) was backed up as
  `~\.wezterm.lua.backup-<timestamp>`. To launch into WSL again, flip the
  two lines at the bottom of `home\wezterm\wezterm.lua`.
- New fonts show up in apps only after the app restarts.
