# Cheat sheet - how to actually use all of this

Everything from the kunchen setup, translated to my machines.
Windows = PowerShell 7 in WezTerm. WSL = Ubuntu (type `wsl` to enter, zsh + tmux live there).

## Shell (works in BOTH PowerShell and zsh)

| Type | Does |
|---|---|
| `..` | go up one folder |
| `add` | `git add .` (stage everything) |
| `push` / `pull` | git push / pull |
| `m` | switch to main branch |
| `cc` | Claude Code with NO permission prompts (powerful - be intentional) |
| `co` | Codex full-auto (only if Codex is installed) |

- Gray **ghost text** appears from your history as you type → press **Ctrl+F** to accept it.
- The prompt `❯` turns **red** when the last command failed.
- Inside a git repo, the prompt shows the **branch name** and a marker when files changed.
- `nvim <file>` edits anything; `lazygit` opens a visual git UI in any repo (`q` quits it).

## Changing my setup (the rebuild loop)

**Windows** - edit in `Documents\GitHub\dotfiles`:

| Change what | Edit | Apply |
|---|---|---|
| aliases, prompt behavior | `home\powershell\profile.ps1` | open new terminal |
| terminal look | `home\wezterm\wezterm.lua` | instant (auto-reload) |
| prompt style | `home\starship.toml` | new terminal |
| Neovim | `home\nvim\` | restart nvim |
| agent rules | `home\AGENTS.md` | `.\rebuild.ps1` |
| add a program | `$tools` list in `bootstrap.ps1` | re-run `bootstrap.ps1` |

**WSL** - edit in `~/github/dotfiles-wsl`:

| Change what | Edit | Apply |
|---|---|---|
| packages, aliases, zsh, prompt | `home.nix` | `./rebuild.sh` |
| Neovim / tmux / agent rules | `home/nvim/`, `home/tmux.conf`, `home/AGENTS.md` | live (symlinked) |

Then always: `add` → `git commit -m "what I did"` → `push`.

## WezTerm

| Keys | Does |
|---|---|
| Ctrl+Shift+T / Ctrl+Shift+W | new / close tab |
| Ctrl+Tab | switch tabs |
| Ctrl+Shift+C / Ctrl+Shift+V | copy / paste |
| Ctrl+= / Ctrl+- | font bigger / smaller |
| **Ctrl+Shift+P** | command palette - search ANY action (splits, themes...) |
| Ctrl+Shift+L | debug overlay (shows config errors) |

## tmux (inside WSL - terminal sessions that survive closing the window)

Start with `tmux`. Reattach later with `tmux attach`. The **prefix is Ctrl+a**
(press Ctrl+a, release, then the key):

| After Ctrl+a | Does |
|---|---|
| `\|` / `-` | split side-by-side / stacked (keeps current folder) |
| `h j k l` | jump between panes (left/down/up/right) |
| `H J K L` | resize pane |
| `c` | new window (tab) |
| `d` | detach (everything keeps running!) |
| `[` | scroll/copy mode (vi keys: `v` select, `y` copy, `q` exit) |
| `r` | reload tmux config |
| **`A`** | **the Kun layout: Claude Code left, `nvim .` right** |

No prefix needed: **Alt+1..5** jumps straight to window 1-5. Mouse works too.

## Neovim (same config both sides)

Survival basics: `i` = type text, `Esc` = back to normal mode (**also saves!**),
`:q` = quit, `:q!` = quit without saving, `u` = undo, `Ctrl+R` = redo,
`/word` = search (`n` = next hit), `dd` = delete line, `v` = select, `y` = copy, `p` = paste.

Leader key = **Space**. Press Space and wait → menu of everything (which-key):

| Keys | Does |
|---|---|
| Space `f` | find files by name (type fuzzy, Enter opens) |
| Space `s` | search TEXT across the whole project |
| Space `b` | switch between open files |
| Space `e` | file browser (oil) - it's a TEXT LIST: rename/delete/create by editing lines, `:w` applies, `-` goes up |
| Space `g` | git UI (neogit): `s` = stage, `cc` = commit (write msg, `:wq`), `P p` = push, `q` = quit |
| `gd` | jump to definition |
| Ctrl+A | select all |

The gray text at the end of lines = git blame (who changed it, when). Automatic.

## Claude Code

- `claude` anywhere (or `cc` to skip permission prompts). First WSL run: log in once.
- The video workflow: `wsl` → `tmux` → `Ctrl+a A` → talk to Claude on the left, watch/edit code on the right.

## Workflow tools

| Tool | How to use it |
|---|---|
| **lavish** | Ask Claude: "show me the plan **as a lavish artifact**" → browser page opens → click elements to annotate → tell Claude "check my lavish feedback" |
| **no-mistakes** | Once per repo: `no-mistakes init`. Then push with `git push no-mistakes` - it reviews/tests/fixes before it ever hits GitHub. Health check: `no-mistakes doctor` |
| **gnhf** | `gnhf "make all tests pass"` inside a repo → agents grind on it in a loop (overnight). FIRST TIMES: run on a branch: `git switch -c experiment` first |
| **gh-axi** | For Claude, not you: tell Claude "use gh-axi" for GitHub tasks - cheaper + more reliable than raw gh |
| **skills CLI** | `npx skills find` (browse), `npx skills add owner/repo -g` (install for Claude), `npx skills list` |
| **treehouse** | Plumbing for parallel agents - firstmate uses it automatically, you don't touch it |
| **firstmate** (WSL) | `wsl` → `tmux` → `cd ~/github/firstmate && claude` → describe work → it spawns a crew in tmux panes. The deep end - try last |
| dictation | **Win+H** anywhere in Windows (built in). Liking it? Install Handy (open-source, local) |

## When something looks broken

- Prompt looks plain → you're in old Windows PowerShell; use PowerShell 7 (`pwsh`) / WezTerm.
- WezTerm looks default → `Ctrl+Shift+L` shows config errors.
- WSL rebuild errors → read the message; `home-manager news` after big updates.
- no-mistakes acting weird → `no-mistakes doctor`.
- Anything else → ask Claude, paste the error.
