## Dotfiles managed with Chezmoi

These dotfiles apply on macOS, Termux, Debian and Ubuntu, on desktops, servers and single-board computers. They target heavy CLI use and lean towards batteries-included. zsh with oh-my-zsh is the preferred setup, but zsh and every tool beyond the minimal tier is optional: bash and plain POSIX shells such as dash get the same PATH setup, and missing tools are skipped quietly.

### Getting started

One line, on any target platform:

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/jace/dotfiles/main/install.sh)"
```

(or `wget -qO-` in place of `curl -fsSL`). It installs Chezmoi and the recommended tools from the list below, trying with the system's package manager first, then [deb-get](#deb-get) on Debian and Ubuntu, then Homebrew if present, then Snap, and Python tools last with `uv tool install`. If the selected tier has tools none of them can install, it offers to install deb-get (on Debian and Ubuntu) and then Homebrew. Declining skips those tools, and Chezmoi then comes from its own installer. Finally it sets up the dotfiles with `chezmoi init`, showing the changes before applying them. Prefix `DOTFILES_YES=1` to answer yes to all prompts.

#### By hand

1. [Install Chezmoi](https://www.chezmoi.io/install). Homebrew and Snap carry it but mainstream distro packaging hasn't caught up. Install directly with `sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin` or consult the per-platform notes below.
2. Optionally install the [GitHub CLI](https://github.com/cli/cli#installation) and authenticate: `gh auth login`. If using HTTPS, `gh auth setup-git`.
3. Initialize Chezmoi:
   - HTTPS: `chezmoi init https://github.com/jace/dotfiles.git`
   - SSH: `chezmoi init git@github.com:jace/dotfiles.git`
4. Review with `chezmoi diff`, then apply with `chezmoi apply`. For future updates, `chezmoi update`.
5. Make zsh your login shell if you want the full setup: `chsh -s $(which zsh)`.

Maintenance notes for agents (and humans) are in [AGENTS.md](AGENTS.md).

### When the login shell can't be changed

If your system doesn't allow `chsh` to switch to `zsh`, put this in `~/.bashrc.local`, adjusting the path:

```shell
if [ -x /usr/local/bin/zsh ]; then
  export SHELL=/usr/local/bin/zsh
  exec "$SHELL" -l
fi
```

### Dependencies

Fonts: [Nerd Fonts](https://www.nerdfonts.com/) for icons in the prompt, eza, yazi and tmux. I prefer MesloLGS in terminals and Fira Code in editors. Only machines with a local terminal app need them and `install.sh` will check for you.

- **macOS and Linux desktops with Homebrew**: `brew install --cask font-meslo-lg-nerd-font font-fira-code-nerd-font`
- **Linux desktops without Homebrew**:

  ```shell
  mkdir -p ~/.local/share/fonts/NerdFonts
  for f in Meslo FiraCode; do
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$f.tar.xz" | tar -xJ -C ~/.local/share/fonts/NerdFonts
  done
  fc-cache -f
  ```

- **Termux**: the terminal font is the single file `~/.termux/font.ttf`. `install.sh` puts MesloLGS there if there's none yet; by hand, extract `MesloLGSNerdFont-Regular.ttf` from the same `Meslo.tar.xz` to that path and run `termux-reload-settings`.

Tools come in tiers. Each tier includes the ones above it. `install.sh` installs a tier; the platform sections below have the same lists as package-manager commands, with what each platform lacks.

#### Minimal: just the dotfiles

Enough to deploy and use the dotfiles at all.

- [git](https://git-scm.com/) and [curl](https://curl.se/) (or wget)
- [chezmoi](https://www.chezmoi.io) - dotfile manager

#### Essential: servers and SSH targets

A comfortable shell on any machine you log in to.

- [zsh](https://www.zsh.org/) - the full shell setup (oh-my-zsh, powerlevel10k); bash works without it
- [tmux](https://github.com/tmux/tmux) - terminal sessions that survive disconnects; panes and windows
- [et](https://eternalterminal.dev/) - Eternal Terminal: ssh sessions that survive flaky connections and sleep (`etserver` runs on the remote end)
- [ssh-import-id](https://launchpad.net/ssh-import-id) - add your GitHub or Launchpad public keys to `authorized_keys` (`ssh-import-id gh:<user>`)
- [less](https://www.gnu.org/software/less/)/[lesspipe](https://lesspipe.org/), [rsync](https://rsync.samba.org/), [htop](https://htop.dev/), [ncdu](https://dev.yorhel.nl/ncdu) - pager, file sync, process and disk-usage viewers.
- [jq](https://jqlang.org/) - JSON processor
- [ripgrep](https://github.com/BurntSushi/ripgrep) - better grep
- [fd](https://github.com/sharkdp/fd) - better find
- [bat](https://github.com/sharkdp/bat) - cat with wings
- [fzf](https://github.com/junegunn/fzf) - fuzzy finder: Ctrl+T files, Ctrl+G or Alt+C cd, fuzzy tab completion
- [zoxide](https://github.com/ajeetdsouza/zoxide) - better cd
- [direnv](https://direnv.net/) - manage environment per folder

#### Recommended: personal and versatile machines

Shell and files:

- [eza](https://github.com/eza-community/eza) - better ls (also see lsd; eza is slightly faster and more featured)
- [lsd](https://github.com/lsd-rs/lsd) - better ls (lsd's options are more compatible with GNU ls)
- [yazi](https://yazi-rs.github.io/docs/installation) - three-pane file manager + cd, with previews (`y`; also see broot)
- [broot](https://github.com/Canop/broot) - cd+ls+find+tree (`br`; also see yazi)
- [dust](https://github.com/bootandy/dust) - better disk usage visualisation
- [duf](https://github.com/muesli/duf) - better df
- [procs](https://github.com/dalance/procs) - better ps
- [btop](https://github.com/aristocratos/btop) - better system monitor
- [mcfly](https://github.com/cantino/mcfly) - better ^R command history
- [uv](https://docs.astral.sh/uv/) - Python tool and dependency installer
- [gh](https://github.com/cli/cli) - GitHub CLI (for auth)
- [7zip](https://www.7-zip.org/) - file archiver
- [numbat](https://github.com/sharkdp/numbat) - better bc (expression calculator)

Viewers (try these before `less`):

- [jless](https://jless.io/) - JSON viewer with folding
- [fq](https://github.com/wader/fq) - binary file processor (better than a hex viewer)
- [hexyl](https://github.com/sharkdp/hexyl) - hex viewer
- [gron](https://github.com/tomnomnom/gron) - greppable JSON
- [jc](https://github.com/kellyjonbrazil/jc) - convert CLI tool output into JSON for processing with `jq` and `gron`
- [glow](https://github.com/charmbracelet/glow) - render markdown in the terminal
- [doxx](https://github.com/bgreenwell/doxx) - view .docx files
- [chafa](https://github.com/hpjansson/chafa), [timg](https://github.com/hzeller/timg/) - terminal image viewers
- [resvg](https://github.com/linebender/resvg) - terminal SVG viewer
- [pandoc](https://pandoc.org/) - convert between markup formats for terminal viewers
- [ffmpeg](https://www.ffmpeg.org/) - multimedia multitool
- [grc](https://github.com/garabik/grc) - generic colouriser

Git:

- [git-delta](https://github.com/dandavison/delta) - nicer git deltas
- [difftastic](https://github.com/Wilfred/difftastic) - better diff
- [lazygit](https://github.com/jesseduffield/lazygit) - Git TUI

#### Toolbox: network and disk work

Installed by `install.sh toolbox`:

- [rclone](https://rclone.org/) - sync and mount cloud and SFTP storage
- [mtr](https://www.bitwizard.nl/mtr/) (`mtr-tiny` on Debian), [nmap](https://nmap.org/), [iperf3](https://iperf.fr/), [tcpdump](https://www.tcpdump.org/) - network diagnostics
- [smartmontools](https://www.smartmontools.org/) - disk health (`smartctl`)
- [tio](https://github.com/tio/tio), [picocom](https://github.com/npat-efault/picocom) - serial consoles


## Getting dependencies

### macOS

```shell
brew install bat broot btop chafa chezmoi difftastic direnv doxx duf dust et eza fd ffmpeg font-meslo-lg-nerd-font font-fira-code-nerd-font wader/tap/fq fzf gh git-delta glow grc gron hexyl htop jc jless jq lazygit lesspipe lsd mcfly ncdu numbat pandoc procs resvg ripgrep sevenzip timg tmux uv yazi zoxide
uv tool install ssh-import-id
```

### Termux

```shell
pkg install 7zip bat broot chafa chezmoi difftastic direnv dust et eza fd ffmpeg fq fzf gh git-delta glow gron hexyl jc jless jq lesspipe lsd pandoc procs resvg ripgrep timg uv yazi zoxide zsh
uv tool install ssh-import-id
```

Missing: fq, grc, jc, numbat, resvg. btop is only in the root repository (`pkg install root-repo`) and needs root to read system stats.

### Debian 13 (trixie)

Trixie packages most of the essential and recommended tiers. Eternal Terminal and the latest GitHub CLI come from their own repositories:

```shell
sudo mkdir -p /etc/apt/keyrings
# Eternal Terminal
curl -fsSL https://github.com/MisterTea/debian-et/raw/master/et.gpg | sudo tee /etc/apt/keyrings/et.gpg >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/et.gpg] https://mistertea.github.io/debian-et/debian-source/ $(. /etc/os-release && echo "$VERSION_CODENAME") main" | sudo tee /etc/apt/sources.list.d/et.list
# GitHub CLI (newer than Debian's)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
# Install deb-packaged tools
sudo apt update
sudo apt install git curl zsh tmux et ssh-import-id less rsync htop ncdu jq ripgrep fd-find bat fzf zoxide direnv \
  eza broot fq gron jc glow git-delta lazygit du-dust duf procs btop hexyl numbat chafa timg resvg ffmpeg pandoc 7zip gh grc lsd
```

Debian installs `bat` as `batcat` and `fd-find` as `fdfind`. The shell config aliases both back.

Next, get Chezmoi and Yazi from [deb-get](#deb-get), and the rest from Homebrew or Snap.

### Ubuntu 26.04

Ubuntu packages nearly all of the essential and recommended tiers in universe. Eternal Terminal comes from its PPA, GitHub CLI's latest version from its own repository.

```shell
# Add the Eternal Terminal PPA (a release upgrade disables PPAs: run this again afterwards)
sudo add-apt-repository ppa:jgmath2000/et
# GitHub CLI (newer than Ubuntu's)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
# Install deb-packaged tools
sudo apt install git curl zsh tmux et ssh-import-id less rsync htop ncdu jq ripgrep fd-find bat fzf zoxide direnv \
  eza broot fq gron jc glow git-delta lazygit du-dust duf procs btop hexyl numbat chafa timg resvg ffmpeg pandoc 7zip gh grc lsd doxx
```

Next, get Chezmoi and Yazi from [deb-get](#deb-get), and the rest from Homebrew or Snap.

### Raspberry Pi OS and Armbian

Releases based on Debian trixie can follow the Debian section above. These instructions are for releases based on Bookworm and work for both distributions.

```shell
sudo mkdir -p /etc/apt/keyrings
# GitHub CLI (bookworm's gh is too old)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
# Add the Eternal Terminal repository
echo "deb [signed-by=/etc/apt/keyrings/et.gpg] https://mistertea.github.io/debian-et/debian-source/ $(. /etc/os-release && echo "$VERSION_CODENAME") main" | sudo tee /etc/apt/sources.list.d/et.list
curl -fsSL https://github.com/MisterTea/debian-et/raw/master/et.gpg | sudo tee /etc/apt/keyrings/et.gpg >/dev/null
# Add the Eza repository
curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
# Install deb-packaged tools
sudo apt update
sudo apt install 7zip bat btop chafa direnv et eza ffmpeg fd-find fq gh gron hexyl jc jq pandoc ripgrep timg zoxide zsh
```

Get the rest from [deb-get](#deb-get) or Homebrew (see below). Bookworm's fzf (0.38) is too old for the shell config's key bindings, so take deb-get's:

```shell
deb-get install chezmoi duf fzf git-delta glow lsd numbat yazi
```

### Other package managers

For the remaining tools or for the latest versions, use another package manager, listed here by order of preference.

**Raspberry Pi:** Some packages may be broken due to builds using `jemalloc` with the wrong flags. I've encountered this across all of Snap, Homebrew and GitHub releases. Test your luck. Working builds need `DISABLE_JEMALLOC=1` ([source](https://www.home-assistant.io/installation/alternative#optimizations)) or `JEMALLOC_SYS_WITH_LG_PAGE=16` ([source](https://github.com/meilisearch/meilisearch/issues/1410#issuecomment-872410768)).

#### deb-get

[deb-get](https://github.com/wimpysworld/deb-get) installs the `.deb` packages that tools' makers publish on GitHub or in their own apt repositories, on Debian, Ubuntu and their derivatives (Raspberry Pi OS, Armbian). From these tiers it has chezmoi, yazi, glow, git-delta, du-dust, duf, numbat, lsd, jc, pandoc and rclone, plus newer builds of bat, fd, fzf and ripgrep than older releases ship.

```shell
# Install deb-get with deb-get
sudo apt install curl distro-info-data lsb-release wget jq
curl -sL https://raw.githubusercontent.com/wimpysworld/deb-get/main/deb-get | sudo -E bash -s install deb-get
# Install tools
deb-get install chezmoi yazi
```

Most of these are the `.deb` files from each tool's GitHub releases, which apt doesn't update: run `deb-get upgrade` for them. Glow is the exception: deb-get adds its apt repository, so `apt upgrade` updates it. Since `deb-get upgrade` is easy to forget, prefer apt and upstream apt repositories (as for et and gh above) wherever they have the tool. Over Homebrew, deb-get has two advantages: apt resolves its packages' dependencies with the system's, where Homebrew brings its own (its python3 can shadow the system's), and it installs as root instead of in your user account. It's also the light way to get chezmoi itself, where Homebrew and Snap are whole frameworks. deb-get reads GitHub's API, which allows 60 requests an hour without a token. For more, set `DEBGET_TOKEN`, for example to `$(gh auth token)`.

#### Homebrew Linux

I prefer Homebrew for:

1. A larger selection of packages,
2. Faster updates,
3. No overhead of containers and subtly broken functionality, and
4. Compile from source if the binary is broken or missing.

…with one major downside: the package manager runs in your user account with no privilege separation.

```shell
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# Install brew-packaged tools
brew install broot dust chezmoi git-delta numbat procs resvg grc jless mcfly uv yazi
```

Homebrew offers the option to build from source but this requires the entire toolchain for Go and Rust and may overload an SBC:

```shell
brew install --build-from-source fd lazygit difftastic
```

#### Snap

```shell
# Install snap
sudo apt install snapd
# Install tools that need --classic
sudo snap install chezmoi --classic
sudo snap install yazi --classic
```

Snap does better privilege separation but bloats your mount table and subtly breaks tools that don't expect containment.

#### Ecosystem installers

A final option is to use an ecosystem installer. Since they are typically also project dependency managers, they need a disambiguating subcommand or flag:

- Go: `GOBIN=~/.local/bin go install`
- Rust: `cargo binstall` ([get it here](https://github.com/cargo-bins/cargo-binstall); installs to `~/.cargo/bin`)
- Python: `uv tool install` or `pipx install`
- Ruby: `gem install`
- NodeJS: `npm install -g` (system global)
- GitHub Releases:
    - Install Gah: `bash -c "$(curl -fsSL https://raw.githubusercontent.com/marverix/gah/refs/heads/master/tools/install.sh)"`
    - Use it: `gah install lazygit --unattended` (installs to `~/.local/bin`)
    - Note: gah has no uninstaller, you'll have to remove from `~/.local/bin` yourself.
