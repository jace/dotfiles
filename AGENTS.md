# Dotfiles — agent instructions

These are the operator's dotfiles, managed with [chezmoi](https://www.chezmoi.io). This folder is chezmoi's source directory (`~/.local/share/chezmoi`). The same files deploy to every machine the operator uses, across device capability and purpose profiles. Every change has to work on all of them or be gated to the platforms it's for.

`AGENTS.md` is the only instructions file. Don't add another, and don't symlink to this file: symlinks don't work everywhere chezmoi runs. `AGENTS.md`, `README.md` and `install.sh` are listed in `.chezmoiignore`, so they stay in the repo and never deploy into a home folder.

## Ground rules

- **This repo is public.** Never write anything about the operator's machines, networks, hosts or accounts, or how many devices there are: no hostnames, no hardware lists, no deployment notes. Name platforms only as public generics (macOS, Debian, Ubuntu, Raspberry Pi OS, Armbian, Termux). Anything specific to one machine belongs in an untracked local file on that machine (see Local overrides), not here.
- **Never commit or push.** The operator reviews and commits. Edit files in this folder directly.
- **Never run `chezmoi add`, `chezmoi edit`, `chezmoi re-add` or `chezmoi apply` without asking.** `.chezmoi.toml.tmpl` sets `git.autoCommit = true`, so the first three commit on their own, and `apply` changes the live home folder.
- **Check with `chezmoi diff`** to see what an apply would change, and test in a throwaway home (see Testing) before calling a change ready.
- **Every tool is optional except the minimal tier** (see Dependencies). Shell config must stay quiet and working when a tool is missing: guard with `(( $+commands[x] ))` in zsh, `command -v x >/dev/null` in POSIX sh and bash.
- **Write for the oldest shell that will read the file.** `~/.profile` is read by dash, bash and zsh (`emulate sh`), so it must be plain POSIX sh: no `[[ ]]`, arrays, `local`, `source` or `$OSTYPE`-only tests. `~/.bashrc` must run on bash 3.2 (macOS `/bin/bash`) and later.
- Comments in shell files explain *why*; match the density of the surrounding file.

## Platforms

| Platform | Login shell | Notes |
|---|---|---|
| macOS | zsh | Homebrew in `/opt/homebrew`; GNU tools go first on PATH via the gnubin folders. |
| Debian, Ubuntu, Raspberry Pi OS, Armbian | zsh or bash | Homebrew Linux under `/home/linuxbrew/.linuxbrew` is optional. Linux desktops don't start login shells in terminals, so `~/.zshrc` bootstraps `~/.zprofile` and `~/.bashrc` bootstraps `~/.profile`. |
| Termux (Android) | bash or zsh | **Never probe the root filesystem** (`/opt`, `/home`, `/usr/local`): it's unsafe on Android. `~/.profile` skips Homebrew detection there. Detect Termux by `$TERMUX_VERSION` or `$PREFIX` containing `com.termux`; `$OSTYPE` is set only by bash and zsh. |
| Systems where the login shell can't be changed | often bash | `~/.bashrc` reads `~/.bashrc.local` last, so such a system can `exec zsh -l` from there (see Local overrides). |

## Shell startup

Who reads what. Flags stop files being read twice: `~/.profile` sets `DOT_PROFILE_SOURCED=1`, `~/.zprofile` sets `DOT_ZPROFILE_SOURCED=1`, `~/.bashrc` sets `DOT_BASHRC_SOURCED=1` (not exported).

**zsh**, in this order:

1. `/etc/zshenv`, `~/.zshenv`: every zsh, including `zsh -c` and scripts.
2. `/etc/zprofile`, `~/.zprofile`: login shells. On macOS `/etc/zprofile` runs `path_helper` (`/etc/paths`, `/etc/paths.d/*`).
3. `/etc/zshrc`, `~/.zshrc`: interactive shells.
4. `/etc/zlogin`, `~/.zlogin`: login shells.

**bash**:

- Login shell (`bash -l`, console or SSH login): `/etc/profile`, then the *first* of `~/.bash_profile`, `~/.bash_login`, `~/.profile`. These dotfiles ship no `~/.bash_profile`; if a distro made one, it usually sources `~/.bashrc`, which then reads `~/.profile`.
- Interactive non-login (a new terminal on Linux, `bash` typed at a prompt): `/etc/bash.bashrc` (Debian), then `~/.bashrc`.
- Non-interactive (`bash script.sh`, `bash -c`): only the file named by `$BASH_ENV`.
- **Exception, run by sshd:** when bash runs a command over SSH (`ssh host cmd`), it reads `~/.bashrc` even though it's non-interactive. Debian and Ubuntu build bash to detect sshd by `$SSH_CLIENT`; upstream bash only notices when stdin is a socket, so on other builds (macOS's bash 3.2) don't count on it.
- Invoked as `sh`: behaves like POSIX sh (below), with `--login` still reading `/etc/profile` and `~/.profile`. Some systems' `/etc/profile` also sources `~/.bashrc` directly, so `~/.bashrc` must cope with being read before `~/.profile`.

**POSIX sh** (dash): login shells read `/etc/profile` and `~/.profile`; interactive shells read the file named by `$ENV`; non-interactive shells read nothing.

**sshd:** `ssh host` (no command) starts a login shell with a terminal. `ssh host cmd` runs `$SHELL -c cmd`: not login, not interactive, so zsh reads only `~/.zshenv` and bash only `~/.bashrc`. That's deliberate: scp, rsync, git and Eternal Terminal's `etterminal` bootstrap talk over that channel, so nothing may print or prompt.

How these dotfiles use that:

- `~/.profile` (POSIX) sets up PATH for every shell: Homebrew (`brew shellenv`, not on Termux) and the personal bin folders (`~/.cargo/bin`, `~/.local/bin`, `~/bin`). At the end, an interactive bash login also reads `~/.bashrc`.
- `~/.zshenv` reads `~/.profile` for commands run over SSH (non-login, non-interactive, `$SSH_CONNECTION` set), so `ssh host brew …` and `et host` find Homebrew tools. It does nothing else for non-interactive shells, to keep scripts fast.
- `~/.zprofile` reads `~/.profile`, then adds zsh-only paths (completions, gnubin, keg-only formulae).
- `~/.zshrc` reads `~/.zprofile` if a non-login terminal skipped it, then loads oh-my-zsh.
- `~/.bashrc` reads `~/.profile` if needed (SSH commands, Linux terminals), returns at once when non-interactive, sets up bash with whichever optional tools exist, then reads `~/.bashrc.local`.

## Local overrides

Machine-specific shell setup goes in untracked files that the dotfiles read if present, never in this repo:

- `~/.bashrc.local`: read at the end of `~/.bashrc`, for interactive bash only. For example, where the login shell can't be changed to zsh:
  ```sh
  if [ -x /usr/local/bin/zsh ]; then
    export SHELL=/usr/local/bin/zsh
    exec "$SHELL" -l
  fi
  ```

## Optional tools in zsh

Stock oh-my-zsh plugins print a warning at every shell start when their tool is missing (`eza`, `direnv`, `zoxide`). oh-my-zsh loads `$ZSH_CUSTOM/plugins/<name>/<name>.plugin.zsh` in preference to the stock plugin of the same name, so `dot_oh-my-zsh-custom/plugins/` holds quiet guarded versions of those names that source the stock plugin only when the tool exists. Keep the plugin names in `.zshrc` unchanged.

The fzf family (oh-my-zsh's `fzf` plugin for key bindings, plus the external `fzf-tab`, `fzf-tab-source` and `forgit`) loads through one guarded plugin, `dot_oh-my-zsh-custom/plugins/fzf/`, which shadows the stock `fzf` name and loads all four only when `fzf` is installed. Without fzf, `fzf-tab` and `forgit` load silently and then fail on use.

Terminal configs (Konsole, kitty, Ghostty) deploy only where that terminal is installed (`lookPath`, or the app in `/Applications` on macOS), and `run_onchange_after_konsole-default-profile.sh` makes the `Dotfiles` profile Konsole's default. iTerm2's shell integration loads only when `LC_TERMINAL` is `iTerm2`, as its prompt marks (OSC 133) show up in other terminals' margins.

`.chezmoiignore` skips the zsh and tmux config, and the git checkouts `.chezmoiexternal.toml` would clone for them, where `lookPath` doesn't find zsh or tmux. An external inside an ignored folder is only skipped if the pattern includes the folder's contents (`.oh-my-zsh-custom/**`, not just `.oh-my-zsh-custom`); check with `chezmoi managed --include externals`.

Files sourced from the root of `~/.oh-my-zsh-custom/` (`*.zsh`) run after the plugins and must guard their own tools too (`unalias` included: an alias only exists if its plugin loaded).

## Dependencies

The tiers and per-platform install commands are in `README.md`, and `install.sh` installs a chosen tier.

- **Minimal:** what's needed to deploy and use the dotfiles at all: POSIX sh, git, curl or wget, chezmoi.
- **Essential:** a comfortable shell on any server: zsh, tmux, less, and the core tools.
- **Recommended:** everything else, for personal and versatile machines.
- **Toolbox:** network and disk diagnostics, on request.

`install.sh` takes each missing tool from the first source that has it: the system's package manager (Homebrew on macOS), then Homebrew, then Snap, then `uv tool install` for the Python tools listed in `UV_TOOLS`. It offers to install Homebrew only when the tier has tools none of these can provide. Keep its tier lists in step with the README.

Package availability shifts between releases. Check the distro's package index before writing install instructions (for Debian: `curl -s https://sources.debian.org/api/src/<source-package>/`; Rust tools use source names like `rust-eza`). Facts checked on 2026-11-26: chezmoi is in Debian forky/sid and Ubuntu 26.10, **not** in trixie; eza, zoxide, bat, broot, fd, ripgrep, dust, procs, numbat, lazygit, glow, git-delta and resvg are in trixie; yazi, jless and uv are in forky/sid only; difftastic, mcfly and doxx aren't in Debian at all.

## Testing

Render into a throwaway home and start shells there, with a stripped PATH to imitate a bare server:

```sh
T=$(mktemp -d)
chezmoi apply --destination "$T" --exclude externals,scripts --force
ln -s ~/.oh-my-zsh "$T/.oh-my-zsh"
for p in ~/.oh-my-zsh-custom/plugins/* ~/.oh-my-zsh-custom/themes; do ln -sfn "$p" "$T/.oh-my-zsh-custom/${p#$HOME/.oh-my-zsh-custom/}"; done
# A command over SSH must find Homebrew
env -i HOME="$T" PATH=/usr/bin:/bin SSH_CONNECTION=test zsh -c 'command -v brew'
# POSIX shells
env -i HOME="$T" PATH=/usr/bin:/bin dash -l -c 'echo $PATH'
env -i HOME="$T" PATH=/usr/bin:/bin PREFIX=/data/data/com.termux/files/usr dash -l -c 'echo ${HOMEBREW_PREFIX:-no Homebrew}'
# bash, interactive and login
env -i HOME="$T" TERM=xterm-256color PATH=/usr/bin:/bin bash -l -i -c 'echo "$DOT_PROFILE_SOURCED $DOT_BASHRC_SOURCED"'
```

`~/.profile` finds Homebrew by fixed paths, so on a Mac with Homebrew these shells always find the tools. To check that zsh stays quiet without them, load oh-my-zsh with the custom plugins and a PATH without Homebrew, skipping `.zshrc`:

```sh
env -i HOME="$(mktemp -d)" TERM=xterm-256color PATH=/usr/bin:/bin zsh -f -i -c \
  "ZSH=$HOME/.oh-my-zsh ZSH_CUSTOM=$T/.oh-my-zsh-custom plugins=(git direnv eza fzf zoxide); source \$ZSH/oh-my-zsh.sh"
```

`chezmoi apply --destination` still runs templates against *this* machine (`.chezmoi.os`, `lookPath`), so platform gates have to be checked by reading the rendered output (`chezmoi execute-template < file.tmpl`) or on a real system.
