## Dotfiles managed with Chezmoi

Getting started:

1. [Install Chezmoi](https://www.chezmoi.io/install) and [GitHub CLI](https://github.com/cli/cli#installation) (see below)
2. Authenticate GitHub: `gh auth login` and if using HTTPS, `gh auth setup-git`
3. Apply Chezmoi config:
   - HTTPS: `chezmoi init https://github.com/jace/dotfiles.git`
   - SSH: `chezmoi init git@github.com:jace/dotfiles.git`
   - Next: `chezmoi apply`

### Dependencies

This config depends on ZSH, [Nerd Fonts](https://www.nerdfonts.com/) – I like Fira Code and MesloLGS – and these optional, manually installed CLI tools (\* for required):

- [zsh](https://www.zsh.org/)\* (change your shell with `chsh -s $(which zsh)`)
- [chezmoi](https://www.chezmoi.io)\* - dotfile manager
- [7zip](https://www.7-zip.org/) - file archiver
- [bat](https://github.com/sharkdp/bat) - cat with wings
- [broot](https://github.com/Canop/broot) - cd+ls+find+tree (also see yazi)
- [chafa](https://github.com/hpjansson/chafa) - terminal image viewer
- [difftastic](https://github.com/Wilfred/difftastic) - better diff
- [direnv](https://direnv.net/)\* - manage environment per folder
- [doxx](https://github.com/bgreenwell/doxx) - view .docx files
- [dust](https://github.com/bootandy/dust) - better disk usage visualisation
- [et](https://eternalterminal.dev/) - ssh without disconnects from flaky internet
- [eza](https://github.com/eza-community/eza)\* - better ls (also see lsd; eza is slightly faster and more featured)
- [fd](https://github.com/sharkdp/fd) - better find
- [ffmpeg](https://www.ffmpeg.org/) - multimedia multitool
- [fq](https://github.com/wader/fq) - binary file processor (better than a hex viewer)
- [fzf](https://github.com/junegunn/fzf)\* - nicer tab autocompletion
- [gh](https://github.com/cli/cli) - GitHub CLI (for auth)
- [git-delta](https://github.com/dandavison/delta) - nicer git deltas
- [glow](https://github.com/charmbracelet/glow) - render markdown in the terminal
- [grc](https://github.com/garabik/grc) - generic colouriser
- [gron](https://github.com/tomnomnom/gron) - greppable JSON
- [hexyl](https://github.com/sharkdp/hexyl) - hex viewer
- [jc](https://github.com/kellyjonbrazil/jc) - convert CLI tool output into JSON
- [jless](https://jless.io/) - JSON viewer with folding
- [jq](https://jqlang.org/) - JSON processor
- [lazygit](https://github.com/jesseduffield/lazygit) - Git TUI
- [lsd](https://github.com/lsd-rs/lsd) - better ls (also see eza; lsd's options are more compatible with GNU ls)
- [mcfly](https://github.com/cantino/mcfly) - better ^R command history
- [numbat](https://github.com/sharkdp/numbat) - better bc (expression calculator)
- [pandoc](https://pandoc.org/) - convert between markup formats for terminal viewers
- [procs](https://github.com/dalance/procs) - better ps
- [resvg](https://github.com/linebender/resvg) - terminal SVG viewer
- [ripgrep](https://github.com/BurntSushi/ripgrep) - better grep
- [timg](https://github.com/hzeller/timg/) - terminal image viewer
- [uv](https://docs.astral.sh/uv/) - Python tool and dependency installer
- [yazi](https://yazi-rs.github.io/docs/installation) - three-pane file manager + cd (also see broot)
- [zoxide](https://github.com/ajeetdsouza/zoxide)\* - better cd

Most of these can be installed with `brew|apt|pkg install name…` but some distros need additional package repositories.

### macOS

```shell
brew install bat broot chafa chezmoi difftastic direnv doxx dust MisterTea/et/et eza fd ffmpeg font-meslo-lg-nerd-font font-fira-code-nerd-font wader/tap/fq fzf gh git-delta glow grc gron hexyl jc jless jq lsd pandoc procs resvg ripgrep sevenzip timg uv yazi zoxide
```

Sync iTerm2 config:

1. Go to Settings… -> General -> Settings
2. Enable "External settings"
3. Set folder to `~/.config/iterm2` and decline to write the current config
4. Set "Save changes" to "Automatically"
5. Quit iTerm2 and start it again to load the synced config

### Termux

```shell
pkg install 7zip bat broot chafa chezmoi difftastic direnv dust et eza fd ffmpeg fq fzf gh git-delta glow gron hexyl jc jless jq lsd pandoc procs resvg ripgrep timg uv yazi zoxide zsh
```

Missing: fq, grc, jc, numbat, resvg

### Ubuntu

```shell
# Add the apt.cli.rs repository for Rust-based tools (TODO: deprecated, remove this)
curl -fsSL https://apt.cli.rs/pubkey.asc | sudo tee -a /usr/share/keyrings/rust-tools.asc
curl -fsSL https://apt.cli.rs/rust-tools.list | sudo tee /etc/apt/sources.list.d/rust-tools.list
# Add the GitHub CLI repository
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
# Add the Eternal Terminal repository
sudo add-apt-repository ppa:jgmath2000/et
# add-apt-repository will invoke `apt update`
# Install deb-packaged tools
sudo apt install 7zip bat broot chafa direnv et eza fd-musl ffmpeg fq fzf gh git-delta glow gron hexyl jc jq lsd numbat pandoc procs resvg ripgrep timg zoxide zsh
# Install snap-packaged tools
sudo snap install difftastic dust
sudo snap install chezmoi --classic
sudo snap install yazi --classic
```

Missing: doxx, grc, jless, mcfly, lazygit (available via Linux Homebrew)

### Raspberry Pi OS and Armbian

These instructions work for both distributions, but while some packages are broken on a Raspberry Pi, they seem to work fine on a Rockchip device. Tested with a Raspberry Pi 5 running RPiOS Debian 12 Bookworm and a Radxa Rock 5B+ running Armbian 25.5.

```shell
sudo mkdir -p /etc/apt/keyrings
# Add the GitHub CLI repository
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
# Add the Eternal Terminal repository
echo "deb [signed-by=/etc/apt/keyrings/et.gpg] https://mistertea.github.io/debian-et/debian-source/ $(grep VERSION_CODENAME /etc/os-release | cut -d= -f2) main" | sudo tee -a /etc/apt/sources.list.d/et.list
curl -fsSL https://github.com/MisterTea/debian-et/raw/master/et.gpg | sudo tee /etc/apt/keyrings/et.gpg >/dev/null
# Add the Eza repository
curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
# Add the Glow repository
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
# Install deb-packaged tools
sudo apt update
sudo apt install 7zip bat chafa direnv et eza ffmpeg fd-find fq fzf gh glow gron hexyl jc jq lsd pandoc ripgrep timg zoxide zsh
```

For the remaining tools or for the latest versions, use another package manager. Snap and Homebrew both have broken binaries on a Raspberry Pi, but Homebrew is the better choice:

1. A larger selection of packages
2. More up-to-date
3. No overhead of containers and subtly broken functionality
4. Compile from source if the binary is broken or missing (but this is not always viable on resource-constrained devices)

#### Snap

```
# Install snap
sudo apt install snapd
# Install snap-packaged tools
sudo snap install chezmoi --classic
sudo snap install yazi --classic
```

Broken: dust, difftastic, lazygit (can't use gh for auth), procs, uv  
Missing: broot, doxx, fd, git-delta, numbat, procs, resvg, grc, jless, mcfly

#### Homebrew Linux

```
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# Install brew-packaged tools
brew install broot dust chezmoi git-delta numbat procs resvg grc jless mcfly uv yazi
```

Broken: difftastic, fd (on Raspberry Pi)  
Missing: lazygit (no binary bottle)  
Untested: doxx

Homebrew offers the option to build from source but this requires the entire toolchain for Go and Rust and may overload the device:

```
brew install --build-from-source fd lazygit difftastic
```

To avoid building from source, try a binary installer.

### Binary installer: gah

Gah! installs binaries from GitHub Releases into `~/.local/bin`. It does not have an uninstaller or updater.

```shell
# Install gah
bash -c "$(curl -fsSL https://raw.githubusercontent.com/marverix/gah/refs/heads/master/tools/install.sh)"
# Install uv (both GNU and MUSL releases work)
gah install lazygit --unattended
```

Unfortunately, some official binary releases are broken here as well (eg: [difftastic on Raspberry Pi](https://github.com/Wilfred/difftastic/issues/872)).

### Ecosystem installers

A final option is to use an ecosystem-specific installer. Since they are also project dependency managers, they need a disambiguating subcommand or flag:

- Go: `GOBIN=~/.local/bin go install`
- Cargo: `cargo binstall` ([get it here](https://github.com/cargo-bins/cargo-binstall); installs to `~/.cargo/bin`)
- Python: `uv tool install` or `pipx install`
- Rust: `gem install`
- NodeJS: `npm install -g` (system global)
